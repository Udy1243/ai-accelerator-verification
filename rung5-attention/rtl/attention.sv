module attention #(
    parameter int SEQ_LEN     = 8,   // number of tokens (rows in Q/K/V)
    parameter int D_K         = 16,  // embedding depth (cols in Q/K/V)
    parameter int DATA_WIDTH  = 8,   // bits per Q/K/V element
    parameter int ACCUM_WIDTH = 20   // dot-product accumulator width (16 terms, 8-bit elements)
)(
    input  logic clk,
    input  logic rst_n,

    // Shared load bus: loads one Q/K/V row per cycle instead of exposing the
    // full 8x16 matrices as combinational chip pins. An earlier flat-bus
    // version (q_flat/k_flat/v_flat/out_flat, all SEQ_LEN*D_K*DATA_WIDTH
    // bits) needed 4100 IO pins and couldn't get through OpenLane's IO
    // placer (max ~1308 at a cell-count-sized die) or, once the die was
    // force-enlarged to fit them, routing (congestion from the resulting
    // very sparse placement). This interface needs ~267 pins total.
    // matrix_sel picks which matrix row_addr's row belongs to; load_valid
    // is a one-cycle strobe. Loading is only honored while state==IDLE.
    input  logic [D_K*DATA_WIDTH-1:0] row_data,
    input  logic [2:0]                row_addr,    // 0-7
    input  logic [1:0]                matrix_sel,  // 00=Q, 01=K, 10=V
    input  logic                      load_valid,
    input  logic                      start,       // begin compute once Q/K/V are loaded

    // Output streams one row per cycle (push model, same valid+last shape
    // as dot_product's own AXI-Stream tvalid/tlast, reused a third time in
    // this file) instead of asserting the whole matrix in one cycle.
    output logic signed [D_K*DATA_WIDTH-1:0] out_row_data,
    output logic                              out_valid,
    output logic                              out_tlast   // high on the last (row 7) output
);

    // Q/K/V loaded one row at a time via row_data/row_addr/matrix_sel (see
    // port comment above) -- all three are now plain unpacked arrays built
    // by direct indexed writes during loading. No flat-bus part-select
    // slicing needed for any of them (the earlier row-vs-column asymmetry,
    // where only V needed an unpacked array because Q/K rows were
    // contiguous in a flat bus, no longer applies once there's no flat bus
    // to slice from).
    logic signed [DATA_WIDTH-1:0] q [SEQ_LEN-1:0][D_K-1:0];
    logic signed [DATA_WIDTH-1:0] k [SEQ_LEN-1:0][D_K-1:0];
    logic signed [DATA_WIDTH-1:0] v [SEQ_LEN-1:0][D_K-1:0];

    // Q*K^T needs ACCUM_WIDTH (20b) to not overflow; after >>>2 scaling,
    // worst case shrinks by 2 bits -> SCORE_WIDTH (18b). See CLAUDE.md
    // power-of-two-boundary lesson for why 18, not 17.
    localparam int SCORE_WIDTH = ACCUM_WIDTH - 2;

    typedef enum logic [2:0] {
        IDLE, SCORE, SCALE, SOFTMAX_ST, WEIGHTED_SUM, OUTPUT_ST
    } state_t;
    state_t state;

    logic [2:0] q_row, k_row;  // SCORE state: sweep Q rows x K rows, 0-7 each

    logic signed [ACCUM_WIDTH-1:0] raw_scores    [SEQ_LEN-1:0][SEQ_LEN-1:0];
    logic signed [SCORE_WIDTH-1:0] scaled_scores  [SEQ_LEN-1:0][SEQ_LEN-1:0];

    // --- dot_product instance, reused for all 64 Q*K^T calls in SCORE ---
    logic dp_tvalid, dp_tready, dp_accum_valid;
    logic signed [ACCUM_WIDTH-1:0] dp_accum;
    logic signed [D_K*DATA_WIDTH-1:0] dp_a_flat, dp_b_flat;

    assign dp_tvalid = (state == SCORE);

    // pack this cycle's Q row / K row into dot_product's flat operand ports
    always_comb begin
        for (int m = 0; m < D_K; m++) begin
            dp_a_flat[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH] = q[q_row][m];
            dp_b_flat[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH] = k[k_row][m];
        end
    end

    dot_product #(
        .VECTOR_LEN(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) u_score_dp (
        .clk(clk),
        .rst_n(rst_n),
        .a_flat(dp_a_flat),
        .b_flat(dp_b_flat),
        .tvalid(dp_tvalid),
        .tlast(1'b1),
        .accum(dp_accum),
        .tready(dp_tready),
        .accum_valid(dp_accum_valid)
    );

    // --- softmax instance, streamed 1 row/cycle (fully pipelined, no backpressure) ---
    localparam int WEIGHT_WIDTH = 8;  // matches softmax.sv's own OUTPUT_WIDTH default

    logic [3:0] sm_cycle;  // 0..8: feeds rows 0-7, catches last output at 8 (needs 4b, not 3b)
    logic sm_valid_in, sm_valid_out;
    logic [SEQ_LEN*SCORE_WIDTH-1:0]  sm_inputs_flat;
    logic [SEQ_LEN*WEIGHT_WIDTH-1:0] sm_weights_flat;
    logic [WEIGHT_WIDTH-1:0] weights [SEQ_LEN-1:0][SEQ_LEN-1:0];

    assign sm_valid_in = (state == SOFTMAX_ST) && (sm_cycle < SEQ_LEN);

    // guard against reading scaled_scores[8] (out of range) once sm_cycle
    // has counted past the last real row -- value is don't-care once
    // sm_valid_in drops, but an out-of-range index is worth avoiding anyway
    always_comb begin
        for (int j = 0; j < SEQ_LEN; j++) begin
            sm_inputs_flat[SCORE_WIDTH*(j+1)-1 -: SCORE_WIDTH] =
                scaled_scores[(sm_cycle < SEQ_LEN) ? sm_cycle : SEQ_LEN-1][j];
        end
    end

    softmax #(
        .NUM_INPUTS(SEQ_LEN),
        .INPUT_WIDTH(SCORE_WIDTH),
        .OUTPUT_WIDTH(WEIGHT_WIDTH)
    ) u_softmax (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(sm_valid_in),
        .valid_out(sm_valid_out),
        .inputs(sm_inputs_flat),
        .weights_flat(sm_weights_flat)
    );

    // --- second dot_product instance: weights(8x8) x V(8x16) -> out(8x16) ---
    // weights are UNSIGNED 0-255 (Q0.8); dot_product treats operands as
    // signed, so a raw 8-bit weight like 200 would misread as -56. Widen
    // to 9b (zero-extend weights, sign-extend V) so max weight value 255
    // fits as a non-negative signed 9-bit number: 2^(9-1)-1 = 255, exact.
    localparam int WEIGHTED_DATA_WIDTH  = 9;
    // worst case: |weight|=255, |V|=128, product=32640, x8 terms=261120
    // -> needs 19b signed (2^18-1=262143 fits, 2^17-1=131071 doesn't).
    localparam int WEIGHTED_ACCUM_WIDTH = 19;

    logic [2:0] out_row;  // 0-7: sweeps weights rows during WEIGHTED_SUM,
                           // reused as the streaming row index during OUTPUT_ST
    logic [3:0] out_col;  // 0-15, sweeps V columns (needs 4b: 0-15 doesn't fit in 3b)

    logic dp2_tvalid, dp2_tready, dp2_accum_valid;
    logic signed [WEIGHTED_ACCUM_WIDTH-1:0] dp2_accum;
    logic signed [SEQ_LEN*WEIGHTED_DATA_WIDTH-1:0] dp2_a_flat, dp2_b_flat;

    assign dp2_tvalid = (state == WEIGHTED_SUM);

    always_comb begin
        for (int m = 0; m < SEQ_LEN; m++) begin
            // weights[][] is unsigned -> zero-extends automatically when
            // assigned into a wider signed slot (extension follows the
            // SOURCE's declared signedness, not the destination's)
            dp2_a_flat[WEIGHTED_DATA_WIDTH*(m+1)-1 -: WEIGHTED_DATA_WIDTH] = weights[out_row][m];
            // v[][] is already signed -> sign-extends automatically
            dp2_b_flat[WEIGHTED_DATA_WIDTH*(m+1)-1 -: WEIGHTED_DATA_WIDTH] = v[m][out_col];
        end
    end

    dot_product #(
        .VECTOR_LEN(SEQ_LEN),
        .DATA_WIDTH(WEIGHTED_DATA_WIDTH),
        .ACCUM_WIDTH(WEIGHTED_ACCUM_WIDTH)
    ) u_weighted_dp (
        .clk(clk),
        .rst_n(rst_n),
        .a_flat(dp2_a_flat),
        .b_flat(dp2_b_flat),
        .tvalid(dp2_tvalid),
        .tlast(1'b1),
        .accum(dp2_accum),
        .tready(dp2_tready),
        .accum_valid(dp2_accum_valid)
    );

    // defensive clip on the final rescaled output, same pattern as
    // gear_quantizer's INT4_MAX/MIN and softmax's own normalization clip
    localparam signed [DATA_WIDTH-1:0] OUT_MAX = (1 <<< (DATA_WIDTH-1)) - 1;
    localparam signed [DATA_WIDTH-1:0] OUT_MIN = -(1 <<< (DATA_WIDTH-1));

    logic signed [DATA_WIDTH-1:0] out [SEQ_LEN-1:0][D_K-1:0];

    // undo the Q0.8 scale (weights carry an implicit x256) before clipping
    logic signed [WEIGHTED_ACCUM_WIDTH-1:0] dp2_rescaled;
    assign dp2_rescaled = dp2_accum >>> 8;

    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            state      <= IDLE;
            q_row      <= 0;
            k_row      <= 0;
            sm_cycle   <= 0;
            out_row    <= 0;
            out_col    <= 0;
            out_valid  <= 1'b0;
            out_tlast  <= 1'b0;
        end else begin
            out_valid <= 1'b0;  // unconditional default -- only OUTPUT_ST overrides it
            out_tlast <= 1'b0;

            case (state)
                IDLE: begin
                    q_row <= 0;
                    k_row <= 0;
                    if (load_valid) begin
                        case (matrix_sel)
                            2'b00: for (int m = 0; m < D_K; m++)
                                       q[row_addr][m] <= row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH];
                            2'b01: for (int m = 0; m < D_K; m++)
                                       k[row_addr][m] <= row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH];
                            2'b10: for (int m = 0; m < D_K; m++)
                                       v[row_addr][m] <= row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH];
                            default: ; // matrix_sel == 2'b11 unused
                        endcase
                    end else if (start) begin
                        state <= SCORE;
                    end
                end

                SCORE: begin
                    if (dp_accum_valid) begin
                        raw_scores[q_row][k_row] <= dp_accum;
                        if (q_row == SEQ_LEN-1 && k_row == SEQ_LEN-1) begin
                            state <= SCALE;
                        end else if (k_row == SEQ_LEN-1) begin
                            k_row <= 0;
                            q_row <= q_row + 1'b1;
                        end else begin
                            k_row <= k_row + 1'b1;
                        end
                    end
                end

                SCALE: begin
                    for (int i = 0; i < SEQ_LEN; i++) begin
                        for (int j = 0; j < SEQ_LEN; j++) begin
                            scaled_scores[i][j] <= raw_scores[i][j] >>> 2;
                        end
                    end
                    sm_cycle <= 0;
                    state    <= SOFTMAX_ST;
                end

                SOFTMAX_ST: begin
                    if (sm_cycle < SEQ_LEN) sm_cycle <= sm_cycle + 1'b1;
                    if (sm_valid_out) begin
                        for (int j = 0; j < SEQ_LEN; j++) begin
                            weights[sm_cycle-1][j] <= sm_weights_flat[WEIGHT_WIDTH*(j+1)-1 -: WEIGHT_WIDTH];
                        end
                        if (sm_cycle == SEQ_LEN) begin
                            out_row <= 0;
                            out_col <= 0;
                            state   <= WEIGHTED_SUM;
                        end
                    end
                end

                WEIGHTED_SUM: begin
                    if (dp2_accum_valid) begin
                        if (dp2_rescaled > OUT_MAX) begin
                            out[out_row][out_col] <= OUT_MAX;
                        end else if (dp2_rescaled < OUT_MIN) begin
                            out[out_row][out_col] <= OUT_MIN;
                        end else begin
                            out[out_row][out_col] <= dp2_rescaled[DATA_WIDTH-1:0];
                        end

                        if (out_row == SEQ_LEN-1 && out_col == D_K-1) begin
                            out_row <= 0;  // repurposed as OUTPUT_ST's streaming row index
                            state   <= OUTPUT_ST;
                        end else if (out_col == D_K-1) begin
                            out_col <= 0;
                            out_row <= out_row + 1'b1;
                        end else begin
                            out_col <= out_col + 1'b1;
                        end
                    end
                end

                OUTPUT_ST: begin
                    for (int m = 0; m < D_K; m++) begin
                        out_row_data[DATA_WIDTH*(m+1)-1 -: DATA_WIDTH] <= out[out_row][m];
                    end
                    out_valid <= 1'b1;
                    out_tlast <= (out_row == SEQ_LEN-1);
                    if (out_row == SEQ_LEN-1) begin
                        state <= IDLE;
                    end else begin
                        out_row <= out_row + 1'b1;
                    end
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

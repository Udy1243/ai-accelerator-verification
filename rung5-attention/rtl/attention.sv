module attention #(
    parameter int SEQ_LEN     = 8,   // number of tokens (rows in Q/K/V)
    parameter int D_K         = 16,  // embedding depth (cols in Q/K/V)
    parameter int DATA_WIDTH  = 8,   // bits per Q/K/V element
    parameter int ACCUM_WIDTH = 20   // dot-product accumulator width (16 terms, 8-bit elements)
)(
    input  logic clk,
    input  logic rst_n,
    input  logic valid_in,
    output logic valid_out,

    input  logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] q_flat,
    input  logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] k_flat,
    input  logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] v_flat,

    output logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] out_flat
);

    // Q/K rows are contiguous in q_flat/k_flat (row-major) -> sliced directly
    // with indexed part-select where needed, no unpacked array required.
    // V's COLUMNS (needed by WEIGHTED_SUM) are strided, not contiguous ->
    // still need per-element access, so only v[][] gets unpacked.
    logic signed [DATA_WIDTH-1:0] v [SEQ_LEN-1:0][D_K-1:0];

    genvar r, c;
    generate
        for (r = 0; r < SEQ_LEN; r++) begin : unpack_row
            for (c = 0; c < D_K; c++) begin : unpack_col
                assign v[r][c] = v_flat[DATA_WIDTH*(r*D_K+c+1)-1 -: DATA_WIDTH];
            end
        end
    endgenerate

    // Q*K^T needs ACCUM_WIDTH (20b) to not overflow; after >>>2 scaling,
    // worst case shrinks by 2 bits -> SCORE_WIDTH (18b). See CLAUDE.md
    // power-of-two-boundary lesson for why 18, not 17.
    localparam int SCORE_WIDTH = ACCUM_WIDTH - 2;

    typedef enum logic [2:0] {
        IDLE, SCORE, SCALE, SOFTMAX_ST, WEIGHTED_SUM, DONE
    } state_t;
    state_t state;

    logic [2:0] q_row, k_row;  // SCORE state: sweep Q rows x K rows, 0-7 each

    logic signed [ACCUM_WIDTH-1:0] raw_scores    [SEQ_LEN-1:0][SEQ_LEN-1:0];
    logic signed [SCORE_WIDTH-1:0] scaled_scores  [SEQ_LEN-1:0][SEQ_LEN-1:0];

    // --- dot_product instance, reused for all 64 Q*K^T calls in SCORE ---
    logic dp_tvalid, dp_tready, dp_accum_valid;
    logic signed [ACCUM_WIDTH-1:0] dp_accum;

    assign dp_tvalid = (state == SCORE);

    dot_product #(
        .VECTOR_LEN(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) u_score_dp (
        .clk(clk),
        .rst_n(rst_n),
        .a_flat(q_flat[q_row*D_K*DATA_WIDTH +: D_K*DATA_WIDTH]),
        .b_flat(k_flat[k_row*D_K*DATA_WIDTH +: D_K*DATA_WIDTH]),
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

    logic [2:0] out_row;  // 0-7, sweeps weights rows
    logic [3:0] out_col;  // 0-15, sweeps V columns (needs 4b: 0-15 doesn't fit in 3b)

    logic dp2_tvalid, dp2_tready, dp2_accum_valid;
    logic signed [WEIGHTED_ACCUM_WIDTH-1:0] dp2_accum;
    logic signed [SEQ_LEN*WEIGHTED_DATA_WIDTH-1:0] dp2_a_flat, dp2_b_flat;

    assign dp2_tvalid = (state == WEIGHTED_SUM);

    always_comb begin
        for (int m = 0; m < SEQ_LEN; m++) begin
            // weights[][] is unsigned -> zero-extends automatically when
            // assigned into a wider signed slot (extension follows the
            // SOURCE's signedness, not the destination's)
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
            valid_out  <= 1'b0;
        end else begin
            valid_out <= 1'b0;  // unconditional default -- only DONE overrides it

            case (state)
                IDLE: begin
                    q_row <= 0;
                    k_row <= 0;
                    if (valid_in) state <= SCORE;
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
                            state <= WEIGHTED_SUM;
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
                            state <= DONE;
                        end else if (out_col == D_K-1) begin
                            out_col <= 0;
                            out_row <= out_row + 1'b1;
                        end else begin
                            out_col <= out_col + 1'b1;
                        end
                    end
                end

                DONE: begin
                    for (int i = 0; i < SEQ_LEN; i++) begin
                        for (int j = 0; j < D_K; j++) begin
                            out_flat[DATA_WIDTH*(i*D_K+j+1)-1 -: DATA_WIDTH] <= out[i][j];
                        end
                    end
                    valid_out <= 1'b1;
                    state     <= IDLE;
                end

                default: state <= IDLE;
            endcase
        end
    end

endmodule

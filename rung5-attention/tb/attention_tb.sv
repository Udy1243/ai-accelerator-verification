`timescale 1ns/1ps

module attention_tb;

    localparam int SEQ_LEN     = 8;
    localparam int D_K         = 16;
    localparam int DATA_WIDTH  = 8;
    localparam int ACCUM_WIDTH = 20;

    logic clk, rst_n;
    logic valid_in, valid_out;

    logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] q_flat;
    logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] k_flat;
    logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] v_flat;
    logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] out_flat;

    attention #(
        .SEQ_LEN(SEQ_LEN),
        .D_K(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .q_flat(q_flat),
        .k_flat(k_flat),
        .v_flat(v_flat),
        .out_flat(out_flat)
    );

    // fill one row (D_K contiguous elements) of q_flat/k_flat/v_flat with a
    // single repeated scalar -- no unpacked array arg needed since every
    // element in a test row is the same constant (offset math mirrors the
    // RTL's own row part-select in attention.sv)
    task automatic set_q_row(input int row, input int val);
        for (int c = 0; c < D_K; c++)
            q_flat[DATA_WIDTH*(row*D_K+c+1)-1 -: DATA_WIDTH] = val[DATA_WIDTH-1:0];
    endtask

    task automatic set_k_row(input int row, input int val);
        for (int c = 0; c < D_K; c++)
            k_flat[DATA_WIDTH*(row*D_K+c+1)-1 -: DATA_WIDTH] = val[DATA_WIDTH-1:0];
    endtask

    task automatic set_v_row(input int row, input int val);
        for (int c = 0; c < D_K; c++)
            v_flat[DATA_WIDTH*(row*D_K+c+1)-1 -: DATA_WIDTH] = val[DATA_WIDTH-1:0];
    endtask

    task automatic fill_all(input int q_val, input int k_val, input int v_val);
        for (int r = 0; r < SEQ_LEN; r++) begin
            set_q_row(r, q_val);
            set_k_row(r, k_val);
            set_v_row(r, v_val);
        end
    endtask

    initial clk = 0;
    always #5 clk = ~clk;

    // ~400 cycles is the expected full-pipeline latency (192 SCORE + 9
    // SOFTMAX_ST + 192 WEIGHTED_SUM + a few more) -- 1000 gives headroom
    // above that without letting a real hang run forever undetected
    localparam int TIMEOUT_CYCLES = 1000;

    task automatic run_and_wait(input string label);
        int cycles;
        cycles = 0;
        valid_in = 1;
        @(posedge clk); #1;
        valid_in = 0;
        while (!valid_out) begin
            @(posedge clk); #1;
            cycles++;
            if (cycles > TIMEOUT_CYCLES) begin
                $display("FAIL [%s]: timeout waiting for valid_out (>%0d cycles)", label, TIMEOUT_CYCLES);
                $finish;
            end
        end
    endtask

    // extract one signed element from out_flat -- part-select of a packed
    // vector is ALWAYS unsigned regardless of the parent's declared
    // signedness, so $signed() must wrap the extraction itself, not just
    // the later comparison
    function automatic logic signed [DATA_WIDTH-1:0] get_out(input int row, input int col);
        get_out = $signed(out_flat[DATA_WIDTH*(row*D_K+col+1)-1 -: DATA_WIDTH]);
    endfunction

    task automatic check_uniform_output(input int expected, input string label);
        int errors;
        errors = 0;
        for (int r = 0; r < SEQ_LEN; r++) begin
            for (int c = 0; c < D_K; c++) begin
                if (get_out(r, c) !== expected[DATA_WIDTH-1:0]) begin
                    $display("  MISMATCH [%s] out[%0d][%0d] = %0d, expected %0d", label, r, c, get_out(r,c), expected);
                    errors++;
                end
            end
        end
        if (errors == 0)
            $display("PASS [%s]: all %0d elements = %0d", label, SEQ_LEN*D_K, expected);
        else
            $display("FAIL [%s]: %0d/%0d elements mismatched", label, errors, SEQ_LEN*D_K);
    endtask

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, attention_tb);
        rst_n = 0; valid_in = 0;
        q_flat = 0; k_flat = 0; v_flat = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

        // Test 1: all-zero. Weakest possible check (a stuck-at-0 output
        // bug would pass by accident) but still confirms the FSM runs to
        // completion and valid_out fires without X's/garbage.
        fill_all(0, 0, 0);
        run_and_wait("Test 1: all-zero");
        check_uniform_output(0, "Test 1: all-zero");

        // Test 2: all-ones. raw_scores=16 uniform -> scaled=4 uniform ->
        // softmax's near-uniform exact case (weight=32 each, sum=256,
        // zero rounding error, per softmax_tb) -> weighted sum = 32*8*1 =
        // 256 -> rescaled 256>>>8 = 1. Expected output: all 1s, matching
        // input exactly -- and unlike Test 1, a stuck-at-0 bug WOULD be
        // caught here.
        fill_all(1, 1, 1);
        run_and_wait("Test 2: all-ones");
        check_uniform_output(1, "Test 2: all-ones");

        // Test 3: dominant attention row + negative V, exercising both the
        // softmax dominant-score clip (weight -> 255, not 256, per
        // softmax_tb's dominant_score_clips_255 case) and signed rescale.
        // Q uniform -100 so every output row picks the same dominant K row.
        // dp2_accum = 255 * (-50) = -12750; rescaled = -12750 >>> 8 = -50
        // (floor toward -inf, NOT truncate-toward-zero -- see CLAUDE.md's
        // Rung 4 phase 2 floor-vs-truncate lesson).
        fill_all(-100, 0, 0);
        set_k_row(3, -100);
        set_v_row(3, -50);
        run_and_wait("Test 3: dominant row, negative V");
        check_uniform_output(-50, "Test 3: dominant row, negative V");

        // Test 4: back-to-back transactions -- confirms the FSM actually
        // returns cleanly to IDLE after DONE and can accept a brand-new
        // job immediately, not just run once. Reuses Test 2's all-ones
        // pattern since its expected value is already known-good.
        fill_all(1, 1, 1);
        run_and_wait("Test 4a: back-to-back #1");
        check_uniform_output(1, "Test 4a: back-to-back #1");
        run_and_wait("Test 4b: back-to-back #2");
        check_uniform_output(1, "Test 4b: back-to-back #2");

        $display("\nAll tests done.");
        $finish;
    end

endmodule

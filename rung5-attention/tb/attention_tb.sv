`timescale 1ns/1ps

module attention_tb;

    localparam int SEQ_LEN     = 8;
    localparam int D_K         = 16;
    localparam int DATA_WIDTH  = 8;
    localparam int ACCUM_WIDTH = 20;

    logic clk, rst_n;
    logic [D_K*DATA_WIDTH-1:0] row_data;
    logic [2:0] row_addr;
    logic [1:0] matrix_sel;
    logic load_valid, start;

    logic signed [D_K*DATA_WIDTH-1:0] out_row_data;
    logic out_valid, out_tlast;

    attention #(
        .SEQ_LEN(SEQ_LEN),
        .D_K(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .row_data(row_data),
        .row_addr(row_addr),
        .matrix_sel(matrix_sel),
        .load_valid(load_valid),
        .start(start),
        .out_row_data(out_row_data),
        .out_valid(out_valid),
        .out_tlast(out_tlast)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // drives one row-load cycle over the shared load bus -- broadcasts a
    // single repeated scalar across all D_K elements (every test in this
    // file only ever needs uniform rows, matching the original flat-bus
    // testbench's set_*_row tasks)
    task automatic load_row(input logic [1:0] sel, input int row, input int val);
        for (int c = 0; c < D_K; c++)
            row_data[DATA_WIDTH*(c+1)-1 -: DATA_WIDTH] = val[DATA_WIDTH-1:0];
        row_addr   = row[2:0];
        matrix_sel = sel;
        load_valid = 1;
        @(posedge clk); #1;
        load_valid = 0;
    endtask

    task automatic set_q_row(input int row, input int val); load_row(2'b00, row, val); endtask
    task automatic set_k_row(input int row, input int val); load_row(2'b01, row, val); endtask
    task automatic set_v_row(input int row, input int val); load_row(2'b10, row, val); endtask

    task automatic fill_all(input int q_val, input int k_val, input int v_val);
        for (int r = 0; r < SEQ_LEN; r++) begin
            set_q_row(r, q_val);
            set_k_row(r, k_val);
            set_v_row(r, v_val);
        end
    endtask

    // ~400 cycles is the expected full-pipeline latency (192 SCORE + 9
    // SOFTMAX_ST + 192 WEIGHTED_SUM + 8 OUTPUT_ST) -- 1000 gives headroom
    // above that without letting a real hang run forever undetected
    localparam int TIMEOUT_CYCLES = 1000;

    // captures the streamed output (one row per out_valid cycle) into a
    // testbench-side array so check_uniform_output can inspect the whole
    // transaction after it completes, instead of reading a static bus
    logic signed [DATA_WIDTH-1:0] captured_out [SEQ_LEN-1:0][D_K-1:0];

    task automatic run_and_wait(input string label);
        int cycles;
        int row_idx;
        cycles  = 0;
        row_idx = 0;
        start = 1;
        @(posedge clk); #1;
        start = 0;
        while (row_idx < SEQ_LEN) begin
            @(posedge clk); #1;
            cycles++;
            if (out_valid) begin
                for (int c = 0; c < D_K; c++)
                    captured_out[row_idx][c] = $signed(out_row_data[DATA_WIDTH*(c+1)-1 -: DATA_WIDTH]);
                if (row_idx == SEQ_LEN-1 && !out_tlast)
                    $display("FAIL [%s]: out_tlast not set on last row (row %0d)", label, row_idx);
                row_idx++;
            end
            if (cycles > TIMEOUT_CYCLES) begin
                $display("FAIL [%s]: timeout waiting for output (>%0d cycles, got %0d/%0d rows)",
                          label, TIMEOUT_CYCLES, row_idx, SEQ_LEN);
                $finish;
            end
        end
    endtask

    task automatic check_uniform_output(input int expected, input string label);
        int errors;
        errors = 0;
        for (int r = 0; r < SEQ_LEN; r++) begin
            for (int c = 0; c < D_K; c++) begin
                if (captured_out[r][c] !== expected[DATA_WIDTH-1:0]) begin
                    $display("  MISMATCH [%s] out[%0d][%0d] = %0d, expected %0d", label, r, c, captured_out[r][c], expected);
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
        rst_n = 0; load_valid = 0; start = 0;
        row_data = 0; row_addr = 0; matrix_sel = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

        // Test 1: all-zero. Weakest possible check (a stuck-at-0 output
        // bug would pass by accident) but still confirms the FSM runs to
        // completion and streams all 8 output rows without X's/garbage.
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
        // returns cleanly to IDLE after OUTPUT_ST and can accept a
        // brand-new load+compute cycle immediately, not just run once.
        // Reuses Test 2's all-ones pattern since its expected value is
        // already known-good.
        fill_all(1, 1, 1);
        run_and_wait("Test 4a: back-to-back #1");
        check_uniform_output(1, "Test 4a: back-to-back #1");
        fill_all(1, 1, 1);
        run_and_wait("Test 4b: back-to-back #2");
        check_uniform_output(1, "Test 4b: back-to-back #2");

        $display("\nAll tests done.");
        $finish;
    end

endmodule

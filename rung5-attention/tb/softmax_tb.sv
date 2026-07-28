`timescale 1ns/1ps
module softmax_tb;
    parameter int NUM_INPUTS   = 8;
    parameter int INPUT_WIDTH  = 11;
    parameter int OUTPUT_WIDTH = 8;

    logic clk;
    logic rst_n;
    logic valid_in;
    logic valid_out;
    logic [NUM_INPUTS*INPUT_WIDTH-1:0] inputs;
    logic [NUM_INPUTS*OUTPUT_WIDTH-1:0] weights_flat;

    softmax #(
        .NUM_INPUTS(NUM_INPUTS),
        .INPUT_WIDTH(INPUT_WIDTH),
        .OUTPUT_WIDTH(OUTPUT_WIDTH)
    ) dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    // helper: pack readable per-score array into the flat bus the DUT expects
    logic signed [INPUT_WIDTH-1:0] scores [NUM_INPUTS-1:0];

    always_comb begin
        for (int k = 0; k < NUM_INPUTS; k++) begin
            inputs[INPUT_WIDTH*(k+1)-1 -: INPUT_WIDTH] = scores[k];
        end
    end

    task automatic send();
        valid_in = 1;
        @(posedge clk); #1;
        valid_in = 0;
    endtask

    task automatic check(input int max_idx, input string label, input int expected_max_w = -1);
        logic [OUTPUT_WIDTH-1:0] w;
        int sum;
        int max_w;
        int max_w_idx;

        do @(posedge clk); while (!valid_out);
        #1;

        sum = 0;
        max_w = -1;
        max_w_idx = -1;
        for (int j = 0; j < NUM_INPUTS; j++) begin
            w = weights_flat[OUTPUT_WIDTH*(j+1)-1 -: OUTPUT_WIDTH];
            sum += w;
            if ($signed({1'b0, w}) > max_w) begin
                max_w = w;
                max_w_idx = j;
            end
        end

        if (max_w_idx !== max_idx)
            $display("FAIL [%s]: max weight at idx %0d, expected idx %0d", label, max_w_idx, max_idx);
        else if (sum < 250 || sum > 256)
            $display("FAIL [%s]: weight sum = %0d, expected in [250,256]", label, sum);
        else if (expected_max_w !== -1 && max_w !== expected_max_w)
            $display("FAIL [%s]: max weight = %0d, expected exactly %0d", label, max_w, expected_max_w);
        else
            $display("PASS [%s]: max weight at idx %0d (%0d), sum = %0d", label, max_w_idx, max_w, sum);
    endtask

    task automatic check_all_equal(input int expected_w, input string label);
        logic [OUTPUT_WIDTH-1:0] w;
        int sum;
        bit all_match;

        do @(posedge clk); while (!valid_out);
        #1;

        sum = 0;
        all_match = 1;
        for (int j = 0; j < NUM_INPUTS; j++) begin
            w = weights_flat[OUTPUT_WIDTH*(j+1)-1 -: OUTPUT_WIDTH];
            sum += w;
            if (w !== expected_w) all_match = 0;
        end

        if (!all_match)
            $display("FAIL [%s]: not all weights equal %0d", label, expected_w);
        else if (sum !== expected_w * NUM_INPUTS)
            $display("FAIL [%s]: sum = %0d, expected exactly %0d", label, sum, expected_w * NUM_INPUTS);
        else
            $display("PASS [%s]: all weights = %0d, sum = %0d", label, expected_w, sum);
    endtask

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, softmax_tb);
        clk = 0; rst_n = 0; valid_in = 0;
        foreach (scores[i]) scores[i] = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

        // Test 1: normal spread, no outlier/corner values, clear single max
        scores[0] = 1000;
        scores[1] = 90;
        scores[2] = -107;
        scores[3] = 304;
        scores[4] = -578;
        scores[5] = 11;
        scores[6] = -20;
        scores[7] = 0;
        send();
        check(0, "normal_spread_max_at_0");

        // Test 2: one dominant score, all others decay to exactly 0 in the
        // LUT (distance > 1584) -> forces get_weight's clip-to-255 path
        scores[0] = 1023;
        scores[1] = -600;
        scores[2] = -700;
        scores[3] = -750;
        scores[4] = -800;
        scores[5] = -900;
        scores[6] = -1000;
        scores[7] = -1024;
        send();
        check(0, "dominant_score_clips_255", 255);

        // Test 3: rail extremes (max=1023, min=-1024) -> stage 2's 12-bit
        // shifted signal must hold exactly -2047 with no wraparound
        scores[0] = 1023;
        scores[1] = -1024;
        scores[2] = 500;
        scores[3] = -200;
        scores[4] = 100;
        scores[5] = -50;
        scores[6] = 300;
        scores[7] = -300;
        send();
        check(0, "rail_extremes");
        if (dut.shifted[1] !== -2047)
            $display("FAIL [rail_extremes_shifted]: shifted[1] = %0d, expected -2047", dut.shifted[1]);
        else
            $display("PASS [rail_extremes_shifted]: shifted[1] = %0d (12-bit headroom holds)", dut.shifted[1]);

        // Test 4: near-uniform scores, all within 16 of the max -> all 8
        // map to LUT index 0, giving identical exp_val and an exact,
        // evenly-split weight (no unique "max" to check, so check_all_equal)
        scores[0] = 10;
        scores[1] = 12;
        scores[2] = 9;
        scores[3] = 11;
        scores[4] = 10;
        scores[5] = 13;
        scores[6] = 8;
        scores[7] = 10;
        send();
        check_all_equal(32, "near_uniform_even_split");

        $display("\nAll tests done.");
        $finish;
    end

endmodule

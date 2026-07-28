`timescale 1ns/1ps
module softmax_cosim_tb;

    localparam int NUM_INPUTS   = 8;
    localparam int INPUT_WIDTH  = 11;
    localparam int OUTPUT_WIDTH = 8;

    logic clk, rst_n, valid_in, valid_out;
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

    // expected weights read from file
    int exp_weights [NUM_INPUTS-1:0];

    int fd, passes, fails;
    logic [OUTPUT_WIDTH-1:0] w;
    bit all_match;

    initial begin
        $dumpfile("sim/waves_cosim.vcd");
        $dumpvars(0, softmax_cosim_tb);
        clk = 0; rst_n = 0; valid_in = 0;
        foreach (scores[i]) scores[i] = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

        passes = 0; fails = 0;
        fd = $fopen("sim/vectors.txt", "r");

        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d %d %d %d %d %d %d %d %d %d %d %d %d %d %d %d\n",
                        scores[0], scores[1], scores[2], scores[3],
                        scores[4], scores[5], scores[6], scores[7],
                        exp_weights[0], exp_weights[1], exp_weights[2], exp_weights[3],
                        exp_weights[4], exp_weights[5], exp_weights[6], exp_weights[7]) == 16) begin
                valid_in = 1;
                @(posedge clk); #1;
                valid_in = 0;

                if (valid_out !== 1'b1) begin
                    $display("FAIL: valid_out not high");
                    fails++;
                end else begin
                    all_match = 1;
                    for (int j = 0; j < NUM_INPUTS; j++) begin
                        w = weights_flat[OUTPUT_WIDTH*(j+1)-1 -: OUTPUT_WIDTH];
                        if (w !== exp_weights[j]) begin
                            $display("FAIL: weight[%0d] got %0d exp %0d", j, w, exp_weights[j]);
                            all_match = 0;
                        end
                    end
                    if (all_match)
                        passes++;
                    else
                        fails++;
                end
            end               // closes if ($fscanf) begin
        end                   // closes while begin

        $fclose(fd);
        $display("\nCo-sim done: %0d/%0d passed", passes, passes+fails);
        $finish;
    end

endmodule

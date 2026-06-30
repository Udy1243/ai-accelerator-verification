`timescale 1ns/1ps
module tb_cosim;

    localparam int DATA_WIDTH = 8;
    localparam int INT4_WIDTH = 4;

    logic                         clk, rst_n, valid_in, valid_out;
    logic signed [DATA_WIDTH-1:0] data_in;
    logic        [DATA_WIDTH-1:0] threshold;
    logic        [INT4_WIDTH-1:0] scale;
    logic                         round_mode;
    logic signed [INT4_WIDTH-1:0] int4_out;
    logic signed [DATA_WIDTH-1:0] sideband_out;
    logic                         is_outlier;

    gear_quantizer #(.DATA_WIDTH(DATA_WIDTH), .INT4_WIDTH(INT4_WIDTH)) dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;

    // expected values read from file
    logic signed [DATA_WIDTH-1:0] exp_sideband;
    logic signed [INT4_WIDTH-1:0] exp_int4;
    logic                         exp_outlier;

    int fd, passes, fails;

    initial begin
        $dumpfile("sim/waves_cosim.vcd");
        $dumpvars(0, tb_cosim);
        clk = 0; rst_n = 0; valid_in = 0; round_mode = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

        passes = 0; fails = 0;
        fd = $fopen("sim/vectors.txt", "r");

        while (!$feof(fd)) begin
            if ($fscanf(fd, "%d %d %d %d %d %d\n",
                        data_in, threshold, scale,
                        exp_outlier, exp_int4, exp_sideband) == 6) begin
                // drive and check — what goes here?
                valid_in = 1;
                @(posedge clk); #1;
                valid_in = 0;
                if (valid_out !== 1'b1) begin
                    $display("FAIL: valid_out not high");
                    fails++;
                end else if (is_outlier !== exp_outlier) begin
                    $display("FAIL: is_outlier got %0b exp %0b", is_outlier, exp_outlier);
                    fails++;
                end else if (exp_outlier && sideband_out !== exp_sideband) begin
                    $display("FAIL: sideband got %0d exp %0d", sideband_out, exp_sideband);
                    fails++;
                end else if (!exp_outlier && int4_out !== exp_int4) begin
                    $display("FAIL: int4_out got %0d exp %0d", int4_out, exp_int4);
                    fails++;
                end else begin
                    $display("PASS");
                    passes++;
                end           // closes else begin
            end               // closes if ($fscanf) begin
        end                   // closes while begin

        $fclose(fd);
        $display("\nCo-sim done: %0d/%0d passed", passes, passes+fails);
        $finish;
    end

endmodule
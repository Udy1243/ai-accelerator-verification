`timescale 1ns/1ps

module tb_gear_quantizer;

    // DUT parameters
    localparam int DATA_WIDTH = 8;
    localparam int INT4_WIDTH = 4;

    // DUT signals
    logic                          clk, rst_n;
    logic                          valid_in, valid_out;
    logic signed [DATA_WIDTH-1:0]  data_in;
    logic        [DATA_WIDTH-1:0]  threshold;
    logic        [INT4_WIDTH-1:0]  scale;
    logic                          round_mode;
    logic signed [INT4_WIDTH-1:0]  int4_out;
    logic signed [DATA_WIDTH-1:0]  sideband_out;
    logic                          is_outlier;

    // DUT instantiation
    gear_quantizer #(
        .DATA_WIDTH(DATA_WIDTH),
        .INT4_WIDTH(INT4_WIDTH)
    ) dut (.*);

    // Clock
    initial clk = 0;
    always #5 clk = ~clk;  // 100 MHz

task automatic send(
    input logic signed [DATA_WIDTH-1:0] d_in,
    input logic        [DATA_WIDTH-1:0] thresh,
    input logic        [INT4_WIDTH-1:0] sc,
    input logic                         rmode
);
    data_in    = d_in;
    threshold  = thresh;
    scale      = sc;
    round_mode = rmode;
    valid_in   = 1;
    @(posedge clk); #1;
    valid_in = 0;
endtask

task automatic check(
    input logic signed [INT4_WIDTH-1:0] exp_int4,
    input logic                         exp_outlier,
    input logic signed [DATA_WIDTH-1:0] exp_sideband,
    input string label
);
    if (valid_out !== 1'b1)
        $display("FAIL [%s]: valid_out not high", label);
    else if (is_outlier !== exp_outlier)
        $display("FAIL [%s]: is_outlier got %0b exp %0b", label, is_outlier, exp_outlier);
    else if (exp_outlier && sideband_out !== exp_sideband)
        $display("FAIL [%s]: sideband got %0d exp %0d", label, sideband_out, exp_sideband);
    else if (!exp_outlier && int4_out !== exp_int4)
        $display("FAIL [%s]: int4_out got %0d exp %0d", label, int4_out, exp_int4);
    else
        $display("PASS [%s]", label);
endtask

initial begin
    $dumpfile("sim/waves.vcd");
    $dumpvars(0, tb_gear_quantizer);
    clk = 0; rst_n = 0; valid_in = 0;
    round_mode = 0; scale = 0; threshold = 0;
    repeat(2) @(posedge clk);
    rst_n = 1;
    @(posedge clk); #1;

    send(8,   20, 2, 0); check(1,  0,   0,  "Test 1: Normal quantization");
    send(30,  20, 2, 0); check(0,  1,  30,  "Test 2: Positive outlier");
    send(-25, 20, 2, 0); check(0,  1, -25,  "Test 3: Negative outlier");
    send(20,  20, 1, 0); check(1,  0,   0,  "Test 4: Boundary (abs==threshold)");
    send(10,  20, 0, 0); check(0,  0,   0,  "Test 5: Scale zero");
    send(-4,  20, 1, 0); check(-1, 0,   0,  "Test 6: Negative normal, truncate");
    send(8,   20, 3, 0); check(1,  0,   0,  "Test 7a: round_mode=0 truncates");
    send(8,   20, 3, 1); check(2,  0,   0,  "Test 7b: round_mode=1 rounds up (same inputs as 7a)");
    send(127, 127, 1, 0); check(7,  0,   0,  "Test 8a: round_mode=0, at max, no overflow");
    send(127, 127, 1, 1); check(7,  0,   0,  "Test 8b: round_mode=1 overflows max, clip saturates back to 7");

    $display("\nAll tests done.");
    $finish;
end

endmodule

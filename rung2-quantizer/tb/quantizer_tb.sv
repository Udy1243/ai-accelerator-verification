`timescale 1ns/1ps

module quantizer_tb;
    logic clk;
    logic rst_n;
    logic valid_in;
    logic signed [15:0] data_in;
    logic [7:0] scale;
    logic round_mode;
    logic signed [7:0] data_out;
    logic valid_out;
    logic overflow;


quantizer #(.INPUT_WIDTH(16), .OUTPUT_WIDTH(8)) dut (.*);
always #5 clk = ~clk;

task automatic send(input signed [15:0] data_in_tb, input round_mode_tb, input [7:0] scale_tb);
    data_in= data_in_tb; round_mode = round_mode_tb; scale = scale_tb; valid_in = 1;
    @(posedge clk); #1;
    valid_in = 0;
endtask

task automatic check(input signed [7:0] expected, input expected_overflow, input string label);
    @(posedge clk); #1;
    if(data_out !== expected || overflow !== expected_overflow)
        $display("FAIL [%s]: got %0d expected %0d", label, data_out, expected);
    else
        $display("PASS [%s]: data_out = %0d", label, data_out);
endtask

initial begin
    $dumpfile("sim/waves.vcd");
    $dumpvars(0, quantizer_tb);

    clk = 0; rst_n = 0; valid_in = 0;
    data_in = 0; scale = 0; round_mode = 0;
    @(posedge clk); #1;
    rst_n = 1;

    //test 1
    send(5,0,3);
    check(15,0, "normal quantizer");
     // Test 2: clear works
     @(posedge clk); #1; 
    send(32767, 0, 255);
    check(127,1, "max saturation");

        // Test 3: negative input -4*3 = -12
     @(posedge clk); #1;
    send(-30, 0,3);
    check(-90,0, "negative input");

        // Test 4: max negative -128*-128 = 16384
     @(posedge clk); #1; 
    send(10, 1,3);
    check(31,0, "rounding check");

        $display("\nAll tests done.");
    $finish;
end


endmodule


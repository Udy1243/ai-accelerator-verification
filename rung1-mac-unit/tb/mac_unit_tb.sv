`timescale  1ns/1ps

module mac_unit_tb;
    logic clk,rst_n,valid_in,clear;
    logic signed [7:0] a,b;
    logic signed [31:0] accum_out;
    logic valid_out;

mac_unit #(.INPUT_WIDTH(8), .ACCUM_WIDTH(32)) dut (.*);
always #5 clk = ~clk;

task automatic send(input signed [7:0] in_a, in_b);
    a = in_a; b = in_b; valid_in = 1;
    @(posedge clk); #1;
    valid_in = 0;
endtask

task automatic check(input signed [31:0] expected, input string label);
    @(posedge clk); #1;
    if(accum_out !== expected)
        $display("FAIL [%s]: got %0d", label, accum_out);
    else
        $display("PASS [%s]: accum = %0d", label, accum_out);
endtask

initial begin
    $dumpfile("sim/waves.vcd");
    $dumpvars(0, mac_unit_tb);

    clk = 0; rst_n = 0; valid_in = 0;
    clear = 0; a = 0; b = 0;
    @(posedge clk); #1;
    rst_n = 1;

    //test 1
    send(3,4);
    send(2,5);
    check(22, "basic accumulation");
     // Test 2: clear works
    clear = 1; @(posedge clk); #1; clear = 0;
    send(1, 1);
    check(1, "after clear");

        // Test 3: negative input -4*3 = -12
    clear = 1; @(posedge clk); #1; clear = 0;
    send(-4, 3);
    check(-12, "negative input");

        // Test 4: max negative -128*-128 = 16384
    clear = 1; @(posedge clk); #1; clear = 0;
    send(-128, -128);
    check(16384, "max negative squared");

        // Test 5: accumulate 16 values of 2*3 = 96
    clear = 1; @(posedge clk); #1; clear = 0;
    repeat(16) send(2, 3);
    check(96, "16x accumulation");

    

    // Test 6: overflow check - 128 accumulations of 127*127 = 2,064,512
        clear = 1; @(posedge clk); #1; clear = 0;
        repeat(128) send(127, 127);
        check(2064512, "overflow check");

        $display("\nAll tests done.");
    $finish;
end

endmodule
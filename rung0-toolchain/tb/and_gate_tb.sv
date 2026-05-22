`timescale 1ns/1ps

module and_gate_tb;
    logic a, b, y;

    and_gate dut (.a(a), .b(b), .y(y));

    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, and_gate_tb);

        a=0; b=0; #10;
        if (y !== 0) $display("FAIL: 0&0 should be 0");
        else         $display("PASS: 0&0 = 0");

        a=0; b=1; #10;
        if (y !== 0) $display("FAIL: 0&1 should be 0");
        else         $display("PASS: 0&1 = 0");

        a=1; b=0; #10;
        if (y !== 0) $display("FAIL: 1&0 should be 0");
        else         $display("PASS: 1&0 = 0");

        a=1; b=1; #10;
        if (y !== 1) $display("FAIL: 1&1 should be 1");
        else         $display("PASS: 1&1 = 1");

        $display("\nAll tests done.");
        $finish;
    end
endmodule
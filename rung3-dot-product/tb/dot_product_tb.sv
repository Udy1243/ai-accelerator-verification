`timescale 1ns/1ps
module dot_product_tb;
    parameter int VECTOR_LEN  = 8;
    parameter int DATA_WIDTH  = 4;
    parameter int ACCUM_WIDTH = 11;

    logic clk;
    logic rst_n;
    logic signed [DATA_WIDTH*VECTOR_LEN-1:0] a_flat;
    logic signed [DATA_WIDTH*VECTOR_LEN-1:0] b_flat;
    logic tvalid;
    logic tlast;
    logic signed [ACCUM_WIDTH-1:0] accum;
    logic tready;
    logic accum_valid;

    dot_product #(
        .VECTOR_LEN(VECTOR_LEN),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (.*);

    initial clk = 0;
    always #5 clk = ~clk;
// helper to pack array into flat signal
// add this before initial block
logic signed [DATA_WIDTH-1:0] a [VECTOR_LEN-1:0];
logic signed [DATA_WIDTH-1:0] b [VECTOR_LEN-1:0];

always_comb begin
    for (int k = 0; k < VECTOR_LEN; k++) begin
        a_flat[DATA_WIDTH*(k+1)-1 -: DATA_WIDTH] = a[k];
        b_flat[DATA_WIDTH*(k+1)-1 -: DATA_WIDTH] = b[k];
    end
end

  task automatic send();
    tvalid = 1; tlast = 1;
    // sample tready at posedge BEFORE NBA changes state
    do @(posedge clk); while (!tready);
    #1;
    tvalid = 0;
endtask

task automatic check(
    input signed [ACCUM_WIDTH-1:0] expected,
    input string label
);
    // #1 inside loop so we sample AFTER NBA — catches accum_valid=1
    do begin @(posedge clk); #1; end while (!accum_valid);
    // MAC hasn't cleared yet — accum is valid here
    if (accum !== expected)
        $display("FAIL [%s]: got %0d expected %0d", label, accum, expected);
    else
        $display("PASS [%s]: accum = %0d", label, accum);
endtask
    initial begin
        $dumpfile("sim/waves.vcd");
        $dumpvars(0, dot_product_tb);
        rst_n = 0; tvalid = 0; tlast = 0;
        foreach (a[i]) a[i] = 0;
        foreach (b[i]) b[i] = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

       // Test 1: all zeros
    foreach (a[i]) a[i] = 0;
    foreach (b[i]) b[i] = 0;
    send();
    check(0, "all zeroes");

        // Test 2: single element at index 0
        foreach (a[i]) a[i] = 0;
        foreach (b[i]) b[i] = 0;
        a[0] = 1; b[0] = 1;
        send();
        check(1, "identity_elem_0");

        // Test 3: single element at index 7
        foreach (a[i]) a[i] = 0;
        foreach (b[i]) b[i] = 0;
        a[7] = 1; b[7] = 1;
        send();
        check(1, "identity_elem_7");

        // Test 4: all max positive (8 * 7*7 = 392)
        foreach (a[i]) a[i] = 7;
        foreach (b[i]) b[i] = 7;
        send();
        check(392, "all_max_pos");

        // Test 5: max neg x max pos (8 * -8*7 = -448)
        foreach (a[i]) a[i] = -8;
        foreach (b[i]) b[i] = 7;
        send();
        check(-448, "max_neg_x_max_pos");

        // Test 6: max neg x max neg (8 * -8*-8 = 512)
        foreach (a[i]) a[i] = -8;
        foreach (b[i]) b[i] = -8;
        send();
        check(512, "max_neg_x_max_neg");

        // Test 7: alternating signs (4*7 + 4*-8 = 28-32 = -4)
        for (int i = 0; i < VECTOR_LEN; i++) begin
            a[i] = (i % 2 == 1) ? -8 : 7;
        end
        foreach (b[i]) b[i] = 1;
        send();
        check(-4, "alternating_signs");

        $display("\nAll tests done.");
        $finish;
    end

endmodule
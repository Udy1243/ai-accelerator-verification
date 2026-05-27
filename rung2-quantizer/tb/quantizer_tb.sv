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

    // original 4 directed tests
    send(5, 0, 3);
    check(15, 0, "normal");

    send(32767, 0, 255);
    check(127, 1, "saturation");

    send(-30, 0, 3);
    check(-90, 0, "negative");

    send(10, 1, 3);
    check(31, 0, "rounding");

    // 1000 random vectors from golden.txt
    begin
        integer fd;
        integer status;
        logic signed [15:0] f_data_in;
        logic [7:0]         f_scale;
        logic               f_round_mode;
        logic signed [7:0]  f_expected;
        logic               f_overflow;
        integer             vec_num;
        integer             pass_count;
        integer             fail_count;

        fd = $fopen("tb/golden.txt", "r");
        if (fd == 0) begin
            $display("ERROR: could not open golden.txt");
            $finish;
        end

        vec_num    = 0;
        pass_count = 0;
        fail_count = 0;

        while (!$feof(fd)) begin
            status = $fscanf(fd, "%d %d %d %d %d\n",
                             f_data_in, f_scale, f_round_mode,
                             f_expected, f_overflow);
            if (status == 5) begin
                send(f_data_in, f_round_mode, f_scale);
                @(posedge clk); #1;
                if (data_out !== f_expected || overflow !== f_overflow) begin
                    $display("FAIL vec %0d: data_in=%0d scale=%0d mode=%0d got=%0d exp=%0d ovf=%0d exp_ovf=%0d",
                             vec_num, f_data_in, f_scale, f_round_mode,
                             data_out, f_expected, overflow, f_overflow);
                    fail_count = fail_count + 1;
                end else begin
                    pass_count = pass_count + 1;
                end
                vec_num = vec_num + 1;
            end
        end

        $fclose(fd);
        $display("\nRandom vectors: %0d passed, %0d failed", pass_count, fail_count);
    end

    $display("\nAll tests done.");
    $finish;
end

endmodule


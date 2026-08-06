`timescale 1ns/1ps

module attention_cosim_tb;

    localparam int SEQ_LEN     = 8;
    localparam int D_K         = 16;
    localparam int DATA_WIDTH  = 8;
    localparam int ACCUM_WIDTH = 20;
    localparam int NUM_EL      = SEQ_LEN * D_K;  // 128

    logic clk, rst_n;
    logic valid_in, valid_out;

    logic signed [SEQ_LEN*D_K*DATA_WIDTH-1:0] q_flat, k_flat, v_flat, out_flat;

    attention #(
        .SEQ_LEN(SEQ_LEN),
        .D_K(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in),
        .valid_out(valid_out),
        .q_flat(q_flat),
        .k_flat(k_flat),
        .v_flat(v_flat),
        .out_flat(out_flat)
    );

    initial clk = 0;
    always #5 clk = ~clk;

    // one vector = 4*NUM_EL plain ints (Q, K, V, expected-out) -- read
    // element-by-element via a FIXED-count loop, not by scanning for
    // whitespace: $fscanf's %d already skips all whitespace/newlines
    // between numbers, and we already know exactly how many numbers
    // exist per vector from our own array sizes.
    int q_arr [NUM_EL-1:0];
    int k_arr [NUM_EL-1:0];
    int v_arr [NUM_EL-1:0];
    int exp_arr [NUM_EL-1:0];

    function automatic logic signed [DATA_WIDTH-1:0] get_out(input int row, input int col);
        get_out = $signed(out_flat[DATA_WIDTH*(row*D_K+col+1)-1 -: DATA_WIDTH]);
    endfunction

    localparam int TIMEOUT_CYCLES = 1000;

    int fd, ok, r, c, idx;
    int passes, fails, errors;
    bit read_ok;

    initial begin
        $dumpfile("sim/waves_attn_cosim.vcd");
        $dumpvars(0, attention_cosim_tb);
        rst_n = 0; valid_in = 0;
        q_flat = 0; k_flat = 0; v_flat = 0;
        repeat(2) @(posedge clk);
        rst_n = 1;
        @(posedge clk); #1;

        passes = 0; fails = 0;
        fd = $fopen("sim/attention_vectors.txt", "r");

        while (!$feof(fd)) begin
            read_ok = 1;
            for (idx = 0; idx < NUM_EL; idx++)
                if ($fscanf(fd, "%d", q_arr[idx]) != 1) read_ok = 0;
            for (idx = 0; idx < NUM_EL; idx++)
                if ($fscanf(fd, "%d", k_arr[idx]) != 1) read_ok = 0;
            for (idx = 0; idx < NUM_EL; idx++)
                if ($fscanf(fd, "%d", v_arr[idx]) != 1) read_ok = 0;
            for (idx = 0; idx < NUM_EL; idx++)
                if ($fscanf(fd, "%d", exp_arr[idx]) != 1) read_ok = 0;

            if (read_ok) begin
                for (r = 0; r < SEQ_LEN; r++) begin
                    for (c = 0; c < D_K; c++) begin
                        q_flat[DATA_WIDTH*(r*D_K+c+1)-1 -: DATA_WIDTH] = q_arr[r*D_K+c][DATA_WIDTH-1:0];
                        k_flat[DATA_WIDTH*(r*D_K+c+1)-1 -: DATA_WIDTH] = k_arr[r*D_K+c][DATA_WIDTH-1:0];
                        v_flat[DATA_WIDTH*(r*D_K+c+1)-1 -: DATA_WIDTH] = v_arr[r*D_K+c][DATA_WIDTH-1:0];
                    end
                end

                valid_in = 1;
                @(posedge clk); #1;
                valid_in = 0;

                ok = 0;
                while (!valid_out) begin
                    @(posedge clk); #1;
                    ok++;
                    if (ok > TIMEOUT_CYCLES) begin
                        $display("FAIL: timeout waiting for valid_out (>%0d cycles)", TIMEOUT_CYCLES);
                        $fclose(fd);
                        $finish;
                    end
                end

                errors = 0;
                for (r = 0; r < SEQ_LEN; r++) begin
                    for (c = 0; c < D_K; c++) begin
                        if (get_out(r, c) !== exp_arr[r*D_K+c][DATA_WIDTH-1:0]) begin
                            $display("FAIL: out[%0d][%0d] = %0d, expected %0d", r, c, get_out(r,c), exp_arr[r*D_K+c]);
                            errors++;
                        end
                    end
                end

                if (errors == 0)
                    passes++;
                else
                    fails++;
            end
        end

        $fclose(fd);
        $display("\nAttention co-sim done: %0d/%0d passed", passes, passes+fails);
        $finish;
    end

endmodule

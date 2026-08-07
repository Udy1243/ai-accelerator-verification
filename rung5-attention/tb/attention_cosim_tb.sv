`timescale 1ns/1ps

module attention_cosim_tb;

    localparam int SEQ_LEN     = 8;
    localparam int D_K         = 16;
    localparam int DATA_WIDTH  = 8;
    localparam int ACCUM_WIDTH = 20;
    localparam int NUM_EL      = SEQ_LEN * D_K;  // 128

    logic clk, rst_n;
    logic [D_K*DATA_WIDTH-1:0] row_data;
    logic [2:0] row_addr;
    logic [1:0] matrix_sel;
    logic load_valid, start;

    logic signed [D_K*DATA_WIDTH-1:0] out_row_data;
    logic out_valid, out_tlast;

    attention #(
        .SEQ_LEN(SEQ_LEN),
        .D_K(D_K),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clk(clk),
        .rst_n(rst_n),
        .row_data(row_data),
        .row_addr(row_addr),
        .matrix_sel(matrix_sel),
        .load_valid(load_valid),
        .start(start),
        .out_row_data(out_row_data),
        .out_valid(out_valid),
        .out_tlast(out_tlast)
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

    logic signed [DATA_WIDTH-1:0] captured_out [SEQ_LEN-1:0][D_K-1:0];

    localparam int TIMEOUT_CYCLES = 1000;

    // drives one row-load cycle over the shared load bus, sourcing D_K
    // elements from the module-level q_arr/k_arr/v_arr starting at row*D_K.
    // Three explicit tasks instead of one generic task taking an array
    // argument -- iverilog doesn't support unpacked arrays as task/function
    // arguments (see CLAUDE.md known limitations), confirmed the hard way.
    task automatic load_q_row(input int row);
        for (int c = 0; c < D_K; c++)
            row_data[DATA_WIDTH*(c+1)-1 -: DATA_WIDTH] = q_arr[row*D_K+c][DATA_WIDTH-1:0];
        row_addr = row[2:0]; matrix_sel = 2'b00; load_valid = 1;
        @(posedge clk); #1;
        load_valid = 0;
    endtask

    task automatic load_k_row(input int row);
        for (int c = 0; c < D_K; c++)
            row_data[DATA_WIDTH*(c+1)-1 -: DATA_WIDTH] = k_arr[row*D_K+c][DATA_WIDTH-1:0];
        row_addr = row[2:0]; matrix_sel = 2'b01; load_valid = 1;
        @(posedge clk); #1;
        load_valid = 0;
    endtask

    task automatic load_v_row(input int row);
        for (int c = 0; c < D_K; c++)
            row_data[DATA_WIDTH*(c+1)-1 -: DATA_WIDTH] = v_arr[row*D_K+c][DATA_WIDTH-1:0];
        row_addr = row[2:0]; matrix_sel = 2'b10; load_valid = 1;
        @(posedge clk); #1;
        load_valid = 0;
    endtask

    int fd, ok, r, c, idx;
    int passes, fails, errors;
    int row_idx;
    bit read_ok;

    initial begin
        $dumpfile("sim/waves_attn_cosim.vcd");
        $dumpvars(0, attention_cosim_tb);
        rst_n = 0; load_valid = 0; start = 0;
        row_data = 0; row_addr = 0; matrix_sel = 0;
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
                    load_q_row(r);
                    load_k_row(r);
                    load_v_row(r);
                end

                start = 1;
                @(posedge clk); #1;
                start = 0;

                ok = 0;
                row_idx = 0;
                while (row_idx < SEQ_LEN) begin
                    @(posedge clk); #1;
                    ok++;
                    if (out_valid) begin
                        for (c = 0; c < D_K; c++)
                            captured_out[row_idx][c] = $signed(out_row_data[DATA_WIDTH*(c+1)-1 -: DATA_WIDTH]);
                        row_idx++;
                    end
                    if (ok > TIMEOUT_CYCLES) begin
                        $display("FAIL: timeout waiting for output (>%0d cycles, got %0d/%0d rows)",
                                  TIMEOUT_CYCLES, row_idx, SEQ_LEN);
                        $fclose(fd);
                        $finish;
                    end
                end

                errors = 0;
                for (r = 0; r < SEQ_LEN; r++) begin
                    for (c = 0; c < D_K; c++) begin
                        if (captured_out[r][c] !== exp_arr[r*D_K+c][DATA_WIDTH-1:0]) begin
                            $display("FAIL: out[%0d][%0d] = %0d, expected %0d", r, c, captured_out[r][c], exp_arr[r*D_K+c]);
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

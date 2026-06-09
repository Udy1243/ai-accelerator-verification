interface dot_product_if #(
    parameter int DATA_WIDTH  = 4,
    parameter int VECTOR_LEN  = 8,
    parameter int ACCUM_WIDTH = 11
)(input logic clk);

    logic signed [DATA_WIDTH*VECTOR_LEN-1:0] a_flat;
    logic signed [DATA_WIDTH*VECTOR_LEN-1:0] b_flat;
    logic tvalid;
    logic tlast;
    logic tready;
    logic rst_n;
    logic signed [ACCUM_WIDTH-1:0] accum;
    logic accum_valid;

    // clocking block for driver — drives signals 1 step after clock
    clocking driver_cb @(posedge clk);
        default input #1step output #1;
        output a_flat, b_flat, tvalid, tlast, rst_n;
        input  tready;
    endclocking

    // clocking block for monitor — samples signals 1 step before clock
    clocking monitor_cb @(posedge clk);
        default input #1step;
        input tvalid, tready, tlast, accum, accum_valid;
    endclocking

endinterface
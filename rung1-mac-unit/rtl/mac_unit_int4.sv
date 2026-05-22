module mac_unit_int4 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        valid_in,
    input  logic signed [3:0] a,
    input  logic signed [3:0] b,
    input  logic        clear,
    output logic signed [31:0] accum_out,
    output logic        valid_out
);
    mac_unit #(.INPUT_WIDTH(4), .ACCUM_WIDTH(32)) u0 (.*);
endmodule
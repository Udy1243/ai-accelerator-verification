module mac_unit_int16 (
    input  logic        clk,
    input  logic        rst_n,
    input  logic        valid_in,
    input  logic signed [15:0] a,
    input  logic signed [15:0] b,
    input  logic        clear,
    output logic signed [63:0] accum_out,
    output logic        valid_out
);
    mac_unit #(.INPUT_WIDTH(16), .ACCUM_WIDTH(64)) u0 (.*);
endmodule
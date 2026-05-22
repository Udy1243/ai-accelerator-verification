module mac_unit #(
    parameter int INPUT_WIDTH = 8,
    parameter int ACCUM_WIDTH = 32
)(
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic signed [INPUT_WIDTH-1:0] a,
    input logic signed [INPUT_WIDTH-1:0] b,
    input logic clear,
    output logic signed [ACCUM_WIDTH-1:0] accum_out,
    output logic valid_out
);

//internal signals
logic signed [INPUT_WIDTH*2-1:0] product;
logic signed [ACCUM_WIDTH-1:0] accum_reg;

assign product = a * b;

always_ff @(posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        accum_reg <= '0;
        valid_out <= 1'b0;
    end else if (clear) begin
        accum_reg <= '0;
        valid_out <= 1'b0;
    end else if (valid_in) begin
        accum_reg <= accum_reg + ACCUM_WIDTH'(product);
        valid_out <= 1'b1;
    end
end

assign accum_out = accum_reg;
endmodule

module gear_quantizer #(
    parameter int DATA_WIDTH = 8,
    parameter int INT4_WIDTH = 4
)(
    input logic signed [DATA_WIDTH-1:0] data_in,
    input logic  [INT4_WIDTH-1:0] scale,
    input logic valid_in,
    input logic [DATA_WIDTH-1:0] threshold,
    output logic signed [INT4_WIDTH-1:0] int4_out,
    output logic valid_out,
    output logic signed [DATA_WIDTH-1:0] sideband_out,
    output logic is_outlier,
    input logic clk,
    input logic rst_n,
    input logic round_mode
);

logic  [DATA_WIDTH-1:0] abs_data_in;
logic signed  [DATA_WIDTH + INT4_WIDTH - 1:0] mult_res;
logic signed  [DATA_WIDTH + INT4_WIDTH - 1:0] shifted_res;
logic signed  [DATA_WIDTH + INT4_WIDTH - 1:0] rounded_res;
logic signed  [1:0] round_incr;
logic round_bit;
logic signed  [INT4_WIDTH-1:0] post_clip_res;
logic outlier_comp_res;

// scale is interpreted as a fixed-point fraction scale/2^INT4_WIDTH (0 to 15/16),
// so it can only attenuate data_in, never amplify it
localparam int SHIFT_BITS = INT4_WIDTH;
localparam signed [INT4_WIDTH-1:0] INT4_MAX =  (1 << (INT4_WIDTH-1)) - 1;
localparam signed [INT4_WIDTH-1:0] INT4_MIN = -(1 << (INT4_WIDTH-1));

always_comb begin
    abs_data_in = (data_in[DATA_WIDTH-1]) ? -data_in : data_in;
    mult_res = data_in * $signed({1'b0, scale});
    shifted_res = mult_res >>> SHIFT_BITS;
    round_bit = mult_res[SHIFT_BITS-1];
    round_incr = (round_mode && round_bit) ? 2'sb01 : 2'sb00;
    rounded_res = shifted_res + round_incr;
    post_clip_res = (rounded_res > INT4_MAX) ? INT4_MAX : (rounded_res < INT4_MIN) ? INT4_MIN : rounded_res[INT4_WIDTH-1:0];
    outlier_comp_res = (abs_data_in > threshold);
end

always_ff @(posedge clk or negedge rst_n) begin
    if (!rst_n) begin
        int4_out <= '0;
        valid_out <= 1'b0;
        sideband_out <= '0;
        is_outlier <= 1'b0;
    end else begin
        valid_out <= valid_in;
        if (valid_in) begin
            int4_out <= outlier_comp_res ? '0 : post_clip_res;
            sideband_out <= outlier_comp_res ? data_in : '0;
            is_outlier <= outlier_comp_res;
        end
    end
end
endmodule

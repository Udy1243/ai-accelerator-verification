module quantizer #(
parameter int INPUT_WIDTH = 16,
parameter int OUTPUT_WIDTH = 8

)
(
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic signed [INPUT_WIDTH-1:0] data_in,
    input logic [7:0] scale,
    input logic round_mode,
    output logic signed [OUTPUT_WIDTH-1:0] data_out,
    output logic valid_out,
    output logic overflow

);

// internal signals
    logic signed [23:0] scaled;
    logic signed [23:0] rounded;
    logic signed [23:0] saturated;

    // stage 1 — scale
    assign scaled = data_in * $signed({1'b0, scale});

    //stage 2 - round
    always_comb begin
        if(round_mode == 1'b0)
            rounded = scaled;
        else 
            rounded = scaled + 24'sh1;
    end

    // stage 3 — saturate
    localparam signed [23:0] MAX_VAL = (2**(OUTPUT_WIDTH-1)) - 1;
    localparam signed [23:0] MIN_VAL = -(2**(OUTPUT_WIDTH-1));

    always_comb begin
        if (rounded > MAX_VAL) begin
            saturated = MAX_VAL;
            overflow  = 1'b1;
        end else if (rounded < MIN_VAL) begin
            saturated = MIN_VAL;
            overflow  = 1'b1;
        end else begin
            saturated = rounded;
            overflow  = 1'b0;
        end
    end

    // stage 4 — register output
    always_ff @(posedge clk or negedge rst_n) begin
        if (!rst_n) begin
            data_out  <= '0;
            valid_out <= 1'b0;
        end else if (valid_in) begin
            data_out  <= saturated[OUTPUT_WIDTH-1:0];
            valid_out <= 1'b1;
        end
    end

    endmodule
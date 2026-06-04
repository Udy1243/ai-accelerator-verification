module dot_product #(
parameter int VECTOR_LEN = 8,
parameter int DATA_WIDTH = 4,
parameter int ACCUM_WIDTH = 11

)
(
    input logic clk,
    input logic rst_n,
    input logic signed [DATA_WIDTH - 1:0]  a [VECTOR_LEN-1:0],
    input logic signed [DATA_WIDTH - 1:0]  b [VECTOR_LEN-1:0],
    input logic tvalid,
    input logic tlast,
    output logic signed [ACCUM_WIDTH - 1 : 0] accum,
    output logic tready,
    output logic accum_valid
 

);

logic clear_mac;
logic valid_in_mac;

typedef enum  logic [1:0]{IDLE, COMPUTE, DONE} state_t;
state_t state;
assign tready    = (state == IDLE);
assign clear_mac = (state == IDLE);
assign valid_in_mac = (state == COMPUTE);

always_ff @ (posedge clk or negedge rst_n) begin
    if(!rst_n) begin
        state <= IDLE;
        accum_valid <= 0;
    end else begin
        case(state)
        IDLE: begin
            accum_valid <= 1'b0;
            if (tvalid) state <= COMPUTE;
        end
        COMPUTE: begin
            state <= DONE;
            accum_valid <= (state == COMPUTE);
        end
        DONE: begin
            accum_valid <= 1'b1;
            state <= IDLE;
        end
        endcase
    end

end 

logic signed [DATA_WIDTH*2-1:0] mac_out [VECTOR_LEN - 1 : 0];

genvar i;
generate
    for(i = 0; i < VECTOR_LEN; i++) begin : mac_gen
    mac_unit #(
        .INPUT_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(DATA_WIDTH * 2)
    ) u_mac (
        .clk(clk),
        .rst_n(rst_n),
        .valid_in(valid_in_mac),
        .a(a[i]),
        .b(b[i]),
        .clear(clear_mac),
        .accum_out(mac_out[i]),
        .valid_out()
    );
    end


endgenerate

always_comb begin
    accum = '0;
    for(int j = 0; j < VECTOR_LEN; j++) begin
        accum = accum + ACCUM_WIDTH'(signed'(mac_out[j]));
    end
end





endmodule







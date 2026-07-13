// Concurrent SVA for gear_quantizer, attached via `bind` so gear_quantizer.sv
// itself never changes. iverilog cannot parse `property`/`assert property`
// syntax (confirmed: hard syntax error, not degraded support) — this file is
// NOT part of the local `make sim` build. Paste it alongside gear_quantizer.sv
// into EDA Playground's design.sv tab to exercise it under Aldec Riviera-PRO.

module gear_quantizer_sva_checker (
    input logic clk,
    input logic rst_n,
    input logic valid_in,
    input logic valid_out
);

    property p_valid_out_delay;
        @(posedge clk) disable iff (!rst_n)
        valid_out === $past(valid_in);
    endproperty

    assert property (p_valid_out_delay)
        else $error("FAIL: valid_out did not follow valid_in by one cycle at time %0t", $time);

endmodule

bind gear_quantizer gear_quantizer_sva_checker sva_checker_inst (
    .clk(clk),
    .rst_n(rst_n),
    .valid_in(valid_in),
    .valid_out(valid_out)
);
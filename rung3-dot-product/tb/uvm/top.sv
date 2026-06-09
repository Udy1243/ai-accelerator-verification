`include "uvm_macros.svh"
import uvm_pkg::*;

`include "tb/uvm/interface/dot_product_if.sv"
`include "tb/uvm/seq_item/dot_product_seq_item.sv"
`include "tb/uvm/sequence/dot_product_sequence.sv"
`include "tb/uvm/driver/dot_product_driver.sv"
`include "tb/uvm/monitor/dot_product_monitor.sv"
`include "tb/uvm/scoreboard/dot_product_scoreboard.sv"
`include "tb/uvm/agent/dot_product_agent.sv"
`include "tb/uvm/env/dot_product_env.sv"
`include "tb/uvm/test/dot_product_test.sv"

module top;
    parameter int DATA_WIDTH  = 4;
    parameter int VECTOR_LEN  = 8;
    parameter int ACCUM_WIDTH = 11;

    logic clk;
    logic rst_n;

    // clock generator
    initial clk = 0;
    always #5 clk = ~clk;

    // interface instance
    dot_product_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_LEN(VECTOR_LEN),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) vif (.clk(clk));

    // DUT
    dot_product #(
        .VECTOR_LEN(VECTOR_LEN),
        .DATA_WIDTH(DATA_WIDTH),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) dut (
        .clk        (clk),
        .rst_n      (vif.rst_n),
        .a_flat     (vif.a_flat),
        .b_flat     (vif.b_flat),
        .tvalid     (vif.tvalid),
        .tlast      (vif.tlast),
        .tready     (vif.tready),
        .accum      (vif.accum),
        .accum_valid(vif.accum_valid)
    );

    initial begin
        // put interface in config database
        uvm_config_db #(virtual dot_product_if)::set(
            null, "*", "vif", vif);

        // drive reset
        vif.rst_n = 0;
        repeat(3) @(posedge clk);
        vif.rst_n = 1;

        // start UVM test
        run_test("dot_product_test");
    end

endmodule
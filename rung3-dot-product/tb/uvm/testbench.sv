// Code your testbench here
// or browse Examples
`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"

typedef class dot_product_scoreboard;

// ─────────────────────────────────────────
// Interface
// ─────────────────────────────────────────
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

    clocking driver_cb @(posedge clk);
    default input #1step output #1;
    output a_flat, b_flat, tvalid, tlast, rst_n;
    input  tready, accum_valid;
endclocking

    clocking monitor_cb @(posedge clk);
    default input #1step;
    input accum, accum_valid, a_flat, b_flat, tvalid, tready;
	endclocking
endinterface

// ─────────────────────────────────────────
// Sequence Item
// ─────────────────────────────────────────
class dot_product_seq_item extends uvm_sequence_item;
    `uvm_object_utils(dot_product_seq_item)

    parameter int DATA_WIDTH  = 4;
    parameter int VECTOR_LEN  = 8;
    parameter int ACCUM_WIDTH = 11;

    rand logic [DATA_WIDTH*VECTOR_LEN-1:0] a_flat;
    rand logic [DATA_WIDTH*VECTOR_LEN-1:0] b_flat;
    logic signed [ACCUM_WIDTH-1:0] expected;
    logic signed [ACCUM_WIDTH-1:0] actual;

    function new(string name = "dot_product_seq_item");
        super.new(name);
    endfunction

    // compute expected dot product from a_flat and b_flat
    function void compute_expected();
    logic signed [DATA_WIDTH-1:0]  a_elem;
    logic signed [DATA_WIDTH-1:0]  b_elem;
    logic signed [2*DATA_WIDTH-1:0] product;
    logic signed [ACCUM_WIDTH-1:0] sum;
    sum = '0;
    for (int i = 0; i < VECTOR_LEN; i++) begin
        a_elem  = a_flat[DATA_WIDTH*i +: DATA_WIDTH];
        b_elem  = b_flat[DATA_WIDTH*i +: DATA_WIDTH];
        product = a_elem * b_elem;
        sum     = sum + product;
    end
    expected = sum;
endfunction
  
    function void post_randomize();
        compute_expected();
    endfunction

endclass

// ─────────────────────────────────────────
// Sequence
// ─────────────────────────────────────────
class dot_product_sequence extends uvm_sequence #(dot_product_seq_item);
    `uvm_object_utils(dot_product_sequence)

    dot_product_scoreboard sb;   // direct handle, not a port
    int unsigned num_transactions;

    function new(string name = "dot_product_sequence");
        super.new(name);
        num_transactions = 20;
    endfunction

    task body();
        dot_product_seq_item item;
        repeat(num_transactions) begin
            item = dot_product_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal("RAND_FAIL", "Randomization failed")
            finish_item(item);
          $display("SEQ: a_flat=%h b_flat=%h expected=%0d",
         item.a_flat, item.b_flat, item.expected);
            // push expected directly to scoreboard
            if (sb != null)
                sb.push_expected(item.expected);
        end
    endtask

endclass
// ─────────────────────────────────────────
// Driver
// ─────────────────────────────────────────
class dot_product_driver extends uvm_driver #(dot_product_seq_item);
    `uvm_component_utils(dot_product_driver)

    virtual dot_product_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual dot_product_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Driver could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
    dot_product_seq_item item;
    vif.driver_cb.tvalid <= 0;
    vif.driver_cb.tlast  <= 0;
    vif.driver_cb.a_flat <= 0;
    vif.driver_cb.b_flat <= 0;
    wait(vif.rst_n === 1'b1);
    @(vif.driver_cb);
    forever begin
        seq_item_port.get_next_item(item);
        vif.driver_cb.a_flat <= item.a_flat;
        vif.driver_cb.b_flat <= item.b_flat;
        vif.driver_cb.tvalid <= 1;
        vif.driver_cb.tlast  <= 1;
        do @(vif.driver_cb); while (!vif.driver_cb.tready);
        vif.driver_cb.tvalid <= 0;
        vif.driver_cb.tlast  <= 0;
        // HOLD inputs until the result is produced
        do @(vif.driver_cb); while (!vif.driver_cb.accum_valid);
        seq_item_port.item_done();
    end
endtask

endclass

// ─────────────────────────────────────────
// Monitor
// ─────────────────────────────────────────
class dot_product_monitor extends uvm_monitor;
    `uvm_component_utils(dot_product_monitor)

    virtual dot_product_if vif;
    uvm_analysis_port #(dot_product_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual dot_product_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Monitor could not get virtual interface")
    endfunction

   task run_phase(uvm_phase phase);
    dot_product_seq_item item;
    forever begin
        @(vif.monitor_cb);
        if (vif.monitor_cb.accum_valid) begin
            item = dot_product_seq_item::type_id::create("item");
            item.a_flat = vif.monitor_cb.a_flat;
            item.b_flat = vif.monitor_cb.b_flat;
            item.actual = vif.monitor_cb.accum;
            ap.write(item);
        end
    end
endtask
      

endclass

// ─────────────────────────────────────────
// Scoreboard
// ─────────────────────────────────────────
class dot_product_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dot_product_scoreboard)

    uvm_analysis_export #(dot_product_seq_item) mon_export;
    uvm_tlm_analysis_fifo #(dot_product_seq_item) mon_fifo;

    // queue of expected values from sequence
    logic signed [10:0] expected_q[$];

    int pass_count;
    int fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_export = new("mon_export", this);
        mon_fifo   = new("mon_fifo",   this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void connect_phase(uvm_phase phase);
        mon_export.connect(mon_fifo.analysis_export);
    endfunction

    // sequence calls this to push expected values
    function void push_expected(logic signed [10:0] exp);
        expected_q.push_back(exp);
    endfunction

    task run_phase(uvm_phase phase);
    dot_product_seq_item item;
    forever begin
        mon_fifo.get(item);
        item.compute_expected();   // recompute from captured inputs
        if (item.actual !== item.expected) begin
            `uvm_error("SCOREBOARD",
                $sformatf("FAIL: got %0d expected %0d",
                item.actual, item.expected))
            fail_count++;
        end else begin
            `uvm_info("SCOREBOARD",
                $sformatf("PASS: accum = %0d", item.actual),
                UVM_LOW)
            pass_count++;
        end
    end
endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("\nResults: %0d passed, %0d failed\n",
            pass_count, fail_count), UVM_LOW)
    endfunction

endclass
// ─────────────────────────────────────────
// Agent
// ─────────────────────────────────────────
class dot_product_agent extends uvm_agent;
    `uvm_component_utils(dot_product_agent)

    dot_product_driver                     driver;
    dot_product_monitor                    monitor;
    uvm_sequencer #(dot_product_seq_item)  sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = dot_product_driver::type_id::create("driver",    this);
        monitor   = dot_product_monitor::type_id::create("monitor",  this);
        sequencer = uvm_sequencer #(dot_product_seq_item)::type_id::create(
                        "sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass

// ─────────────────────────────────────────
// Environment
// ─────────────────────────────────────────
class dot_product_env extends uvm_env;
    `uvm_component_utils(dot_product_env)

    dot_product_agent      agent;
    dot_product_scoreboard scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = dot_product_agent::type_id::create("agent",      this);
        scoreboard = dot_product_scoreboard::type_id::create(
                         "scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(scoreboard.mon_export);
    endfunction

endclass
// ─────────────────────────────────────────
// Test
// ─────────────────────────────────────────
class dot_product_test extends uvm_test;
    `uvm_component_utils(dot_product_test)

    dot_product_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = dot_product_env::type_id::create("env", this);
    endfunction

  task run_phase(uvm_phase phase);
    dot_product_sequence seq;
    phase.raise_objection(this);
    seq = dot_product_sequence::type_id::create("seq");
    seq.num_transactions = 100;
    seq.sb = env.scoreboard;   // give sequence the scoreboard handle
    seq.start(env.agent.sequencer);
    phase.drop_objection(this);
endtask

endclass

// ─────────────────────────────────────────
// Top module
// ─────────────────────────────────────────
module top;
    parameter int DATA_WIDTH  = 4;
    parameter int VECTOR_LEN  = 8;
    parameter int ACCUM_WIDTH = 11;

    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;

    dot_product_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .VECTOR_LEN(VECTOR_LEN),
        .ACCUM_WIDTH(ACCUM_WIDTH)
    ) vif (.clk(clk));

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

  // run_test MUST be called at time 0
    initial begin
        uvm_config_db #(virtual dot_product_if)::set(
            null, "*", "vif", vif);
        run_test("dot_product_test");
    end

    // reset sequence runs in parallel
    initial begin
        vif.rst_n  = 0;
        vif.tvalid = 0;
        vif.tlast  = 0;
        vif.a_flat = 0;
        vif.b_flat = 0;
        repeat(3) @(posedge clk);
        vif.rst_n = 1;
    end
endmodule
// Code your testbench here
// or browse Examples
`timescale 1ns/1ns
import uvm_pkg::*;
`include "uvm_macros.svh"

typedef class gear_quantizer_scoreboard;

// ─────────────────────────────────────────
// Interface
// ─────────────────────────────────────────
interface gear_quantizer_if #(
    parameter int DATA_WIDTH = 8,
    parameter int INT4_WIDTH = 4
)(input logic clk);

    logic signed [DATA_WIDTH-1:0] data_in;
    logic [DATA_WIDTH-1:0]        threshold;
    logic [INT4_WIDTH-1:0]        scale;
    logic                          round_mode;
    logic                          valid_in;
    logic                          rst_n;

    logic                          valid_out;
    logic                          is_outlier;
    logic signed [INT4_WIDTH-1:0]  int4_out;
    logic signed [DATA_WIDTH-1:0]  sideband_out;

    clocking driver_cb @(posedge clk);
        default input #1step output #1;
        output data_in, threshold, scale, round_mode, valid_in, rst_n;
        input  valid_out;
    endclocking

    clocking monitor_cb @(posedge clk);
        default input #1step;
        input data_in, threshold, scale, round_mode, valid_in,
              valid_out, is_outlier, int4_out, sideband_out;
    endclocking

endinterface

// ─────────────────────────────────────────
// Sequence Item
// ─────────────────────────────────────────
class gear_quantizer_seq_item extends uvm_sequence_item;
    `uvm_object_utils(gear_quantizer_seq_item)

    parameter int DATA_WIDTH = 8;
    parameter int INT4_WIDTH = 4;

    rand logic signed [DATA_WIDTH-1:0] data_in;
    rand logic [DATA_WIDTH-1:0]        threshold;
    rand logic [INT4_WIDTH-1:0]        scale;
    rand logic                         round_mode;
    rand bit                           force_boundary;

    // outputs captured for checking
    logic          exp_is_outlier, act_is_outlier;
    logic signed [INT4_WIDTH-1:0] exp_int4, act_int4;
    logic signed [DATA_WIDTH-1:0] exp_sideband, act_sideband;
    logic          round_applied;  // did round_mode actually add +1 this txn?

    constraint c_threshold_range { threshold inside {[0:100]}; }

    constraint c_force_boundary_dist {
        force_boundary dist {1'b1 :/ 15, 1'b0 :/ 85};
    }

    constraint c_force_boundary {
        if (force_boundary) data_in inside {threshold, -threshold};
    }

    function new(string name = "gear_quantizer_seq_item");
        super.new(name);
    endfunction

    // golden model — mirrors gear_quantizer.sv exactly
    function void compute_expected();
        logic [DATA_WIDTH-1:0] abs_val;
        logic signed [DATA_WIDTH+INT4_WIDTH-1:0] mult_res;
        logic signed [DATA_WIDTH+INT4_WIDTH-1:0] shifted_res;
        logic signed [DATA_WIDTH+INT4_WIDTH-1:0] rounded_res;
        logic signed [1:0] round_incr;
        logic round_bit;
        localparam int SHIFT_BITS = INT4_WIDTH;
        localparam signed [INT4_WIDTH-1:0] INT4_MAX =  (1 << (INT4_WIDTH-1)) - 1;
        localparam signed [INT4_WIDTH-1:0] INT4_MIN = -(1 << (INT4_WIDTH-1));

        abs_val     = data_in[DATA_WIDTH-1] ? -data_in : data_in;
        mult_res    = data_in * $signed({1'b0, scale});
        shifted_res = mult_res >>> SHIFT_BITS;
        round_bit   = mult_res[SHIFT_BITS-1];
        round_incr  = (round_mode && round_bit) ? 2'sb01 : 2'sb00;
        rounded_res = shifted_res + round_incr;

        exp_is_outlier = (abs_val > threshold);
        if (exp_is_outlier) begin
            exp_int4      = '0;
            exp_sideband  = data_in;
            round_applied = 1'b0;
        end else begin
            exp_int4      = (rounded_res > INT4_MAX) ? INT4_MAX :
                             (rounded_res < INT4_MIN) ? INT4_MIN : rounded_res[INT4_WIDTH-1:0];
            exp_sideband  = '0;
            round_applied = (round_incr != 0);
        end
    endfunction

    function void post_randomize();
        compute_expected();
    endfunction

endclass

// ─────────────────────────────────────────
// Sequence
// ─────────────────────────────────────────
class gear_quantizer_sequence extends uvm_sequence #(gear_quantizer_seq_item);
    `uvm_object_utils(gear_quantizer_sequence)

    int unsigned num_transactions;

    function new(string name = "gear_quantizer_sequence");
        super.new(name);
        num_transactions = 200;
    endfunction

    task body();
        gear_quantizer_seq_item item;
        repeat (num_transactions) begin
            item = gear_quantizer_seq_item::type_id::create("item");
            start_item(item);
            if (!item.randomize())
                `uvm_fatal("RAND_FAIL", "Randomization failed");
            finish_item(item);
        end
    endtask

endclass

// ─────────────────────────────────────────
// Driver
// ─────────────────────────────────────────
class gear_quantizer_driver extends uvm_driver #(gear_quantizer_seq_item);
    `uvm_component_utils(gear_quantizer_driver)

    virtual gear_quantizer_if vif;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        if (!uvm_config_db #(virtual gear_quantizer_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Driver could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        gear_quantizer_seq_item item;
        vif.driver_cb.valid_in    <= 0;
        vif.driver_cb.data_in     <= 0;
        vif.driver_cb.threshold   <= 0;
        vif.driver_cb.scale       <= 0;
        vif.driver_cb.round_mode  <= 0;
        wait (vif.rst_n === 1'b1);
        @(vif.driver_cb);
        forever begin
            seq_item_port.get_next_item(item);
            vif.driver_cb.data_in    <= item.data_in;
            vif.driver_cb.threshold  <= item.threshold;
            vif.driver_cb.scale      <= item.scale;
            vif.driver_cb.round_mode <= item.round_mode;
            vif.driver_cb.valid_in   <= 1;
            @(vif.driver_cb);
            vif.driver_cb.valid_in   <= 0;
            // HOLD data_in/threshold/scale until the result is captured
            do @(vif.driver_cb); while (!vif.driver_cb.valid_out);
            seq_item_port.item_done();
        end
    endtask

endclass

// ─────────────────────────────────────────
// Monitor
// ─────────────────────────────────────────
class gear_quantizer_monitor extends uvm_monitor;
    `uvm_component_utils(gear_quantizer_monitor)

    virtual gear_quantizer_if vif;
    uvm_analysis_port #(gear_quantizer_seq_item) ap;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        ap = new("ap", this);
        if (!uvm_config_db #(virtual gear_quantizer_if)::get(
                this, "", "vif", vif))
            `uvm_fatal("NO_VIF", "Monitor could not get virtual interface")
    endfunction

    task run_phase(uvm_phase phase);
        gear_quantizer_seq_item item;
        forever begin
            @(vif.monitor_cb);
            if (vif.monitor_cb.valid_out) begin
                item = gear_quantizer_seq_item::type_id::create("item");
                item.data_in        = vif.monitor_cb.data_in;
                item.threshold      = vif.monitor_cb.threshold;
                item.scale          = vif.monitor_cb.scale;
                item.round_mode     = vif.monitor_cb.round_mode;
                item.act_is_outlier = vif.monitor_cb.is_outlier;
                item.act_int4       = vif.monitor_cb.int4_out;
                item.act_sideband   = vif.monitor_cb.sideband_out;
                ap.write(item);
            end
        end
    endtask

endclass

// ─────────────────────────────────────────
// Scoreboard
// ─────────────────────────────────────────
class gear_quantizer_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(gear_quantizer_scoreboard)

    uvm_analysis_imp #(gear_quantizer_seq_item, gear_quantizer_scoreboard) imp;

    int pass_count;
    int fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    function void write(gear_quantizer_seq_item item);
        item.compute_expected();
        if (item.exp_is_outlier !== item.act_is_outlier ||
            item.exp_int4       !== item.act_int4       ||
            item.exp_sideband   !== item.act_sideband) begin
            `uvm_error("SCOREBOARD", $sformatf(
                "FAIL: data_in=%0d threshold=%0d scale=%0d | exp(outlier=%0b int4=%0d sb=%0d) act(outlier=%0b int4=%0d sb=%0d)",
                item.data_in, item.threshold, item.scale,
                item.exp_is_outlier, item.exp_int4, item.exp_sideband,
                item.act_is_outlier, item.act_int4, item.act_sideband))
            fail_count++;
        end else begin
            pass_count++;
        end
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("\nResults: %0d passed, %0d failed\n",
            pass_count, fail_count), UVM_LOW)
    endfunction

endclass

// ─────────────────────────────────────────
// Coverage Collector
// ─────────────────────────────────────────
class gear_quantizer_coverage extends uvm_component;
    `uvm_component_utils(gear_quantizer_coverage)

    uvm_analysis_imp #(gear_quantizer_seq_item, gear_quantizer_coverage) imp;

    // sampled copies — covergroup coverpoints reference these members
    logic signed [7:0] cov_data_in;
    logic [7:0]        cov_threshold;
    logic [3:0]        cov_scale;
    logic              cov_round_mode;
    logic              cov_round_applied;
    logic              cov_is_outlier;
    logic signed [3:0] cov_int4;
    int                cov_boundary_rel;  // -1: abs<th, 0: abs==th, 1: abs>th

    covergroup cg;
        option.per_instance = 1;

        cp_data_in_range: coverpoint cov_data_in {
            bins neg  = {[-128:-1]};
            bins zero = {0};
            bins pos  = {[1:127]};
        }

        cp_outlier: coverpoint cov_is_outlier {
            bins not_outlier = {0};
            bins outlier     = {1};
        }

        cp_boundary: coverpoint cov_boundary_rel {
            bins less    = {-1};
            bins equal   = {0};
            bins greater = {1};
        }

        cp_clip: coverpoint cov_int4 {
            bins min_clip = {-8};
            bins max_clip = {7};
            bins mid      = {[-7:6]};
        }

        cp_scale: coverpoint cov_scale {
            bins zero = {0};
            bins mid  = {[1:14]};
            bins max  = {15};
        }

        cp_round_mode: coverpoint cov_round_mode {
            bins truncate = {0};
            bins round    = {1};
        }

        // Confirms round_mode isn't just driven as stimulus — the +1
        // round-up increment must have actually fired at least once,
        // and also been skipped at least once (round_mode=0 or no
        // fractional remainder), proving distinct observed behavior.
        cp_round_applied: coverpoint cov_round_applied {
            bins applied     = {1};
            bins not_applied = {0};
        }
    endgroup

    function new(string name, uvm_component parent);
        super.new(name, parent);
        cg = new();
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        imp = new("imp", this);
    endfunction

    function void write(gear_quantizer_seq_item item);
        logic [7:0] abs_val;
        abs_val = item.data_in[7] ? -item.data_in : item.data_in;

        // compute_expected() must be called here rather than relied on from
        // the scoreboard's write() — both are independent subscribers of the
        // same monitor item, with no guaranteed call order between them
        item.compute_expected();

        cov_data_in      = item.data_in;
        cov_threshold    = item.threshold;
        cov_scale        = item.scale;
        cov_round_mode   = item.round_mode;
        cov_round_applied = item.round_applied;
        cov_is_outlier   = item.act_is_outlier;
        cov_int4         = item.act_int4;
        cov_boundary_rel = (abs_val < item.threshold) ? -1 :
                            (abs_val == item.threshold) ? 0 : 1;
        cg.sample();
    endfunction

    function void report_phase(uvm_phase phase);
        `uvm_info("COVERAGE", $sformatf(
            "\nOverall covergroup coverage: %0.2f%%\n  cp_data_in_range: %0.2f%%\n  cp_outlier:       %0.2f%%\n  cp_boundary:      %0.2f%%\n  cp_clip:          %0.2f%%\n  cp_scale:         %0.2f%%\n  cp_round_mode:    %0.2f%%\n  cp_round_applied: %0.2f%%\n",
            cg.get_coverage(),
            cg.cp_data_in_range.get_coverage(),
            cg.cp_outlier.get_coverage(),
            cg.cp_boundary.get_coverage(),
            cg.cp_clip.get_coverage(),
            cg.cp_scale.get_coverage(),
            cg.cp_round_mode.get_coverage(),
            cg.cp_round_applied.get_coverage()), UVM_LOW)
    endfunction

endclass

// ─────────────────────────────────────────
// Agent
// ─────────────────────────────────────────
class gear_quantizer_agent extends uvm_agent;
    `uvm_component_utils(gear_quantizer_agent)

    gear_quantizer_driver                     driver;
    gear_quantizer_monitor                    monitor;
    uvm_sequencer #(gear_quantizer_seq_item)  sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = gear_quantizer_driver::type_id::create("driver",    this);
        monitor   = gear_quantizer_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer #(gear_quantizer_seq_item)::type_id::create(
                        "sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass

// ─────────────────────────────────────────
// Environment
// ─────────────────────────────────────────
class gear_quantizer_env extends uvm_env;
    `uvm_component_utils(gear_quantizer_env)

    gear_quantizer_agent      agent;
    gear_quantizer_scoreboard scoreboard;
    gear_quantizer_coverage   coverage;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = gear_quantizer_agent::type_id::create("agent", this);
        scoreboard = gear_quantizer_scoreboard::type_id::create(
                         "scoreboard", this);
        coverage   = gear_quantizer_coverage::type_id::create(
                         "coverage", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        agent.monitor.ap.connect(scoreboard.imp);
        agent.monitor.ap.connect(coverage.imp);
    endfunction

endclass

// ─────────────────────────────────────────
// Test
// ─────────────────────────────────────────
class gear_quantizer_test extends uvm_test;
    `uvm_component_utils(gear_quantizer_test)

    gear_quantizer_env env;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        env = gear_quantizer_env::type_id::create("env", this);
    endfunction

    task run_phase(uvm_phase phase);
        gear_quantizer_sequence seq;
        phase.raise_objection(this);
        seq = gear_quantizer_sequence::type_id::create("seq");
        seq.num_transactions = 200;
        seq.start(env.agent.sequencer);
        phase.drop_objection(this);
    endtask

endclass

// ─────────────────────────────────────────
// Top module
// ─────────────────────────────────────────
module top;
    parameter int DATA_WIDTH = 8;
    parameter int INT4_WIDTH = 4;

    logic clk;

    initial clk = 0;
    always #5 clk = ~clk;

    gear_quantizer_if #(
        .DATA_WIDTH(DATA_WIDTH),
        .INT4_WIDTH(INT4_WIDTH)
    ) vif (.clk(clk));

    gear_quantizer #(
        .DATA_WIDTH(DATA_WIDTH),
        .INT4_WIDTH(INT4_WIDTH)
    ) dut (
        .clk         (clk),
        .rst_n       (vif.rst_n),
        .data_in     (vif.data_in),
        .threshold   (vif.threshold),
        .scale       (vif.scale),
        .round_mode  (vif.round_mode),
        .valid_in    (vif.valid_in),
        .valid_out   (vif.valid_out),
        .is_outlier  (vif.is_outlier),
        .int4_out    (vif.int4_out),
        .sideband_out(vif.sideband_out)
    );

    // run_test MUST be called at time 0
    initial begin
        uvm_config_db #(virtual gear_quantizer_if)::set(
            null, "*", "vif", vif);
        run_test("gear_quantizer_test");
    end

    // reset sequence runs in parallel
    initial begin
        vif.rst_n      = 0;
        vif.valid_in   = 0;
        vif.data_in    = 0;
        vif.threshold  = 0;
        vif.scale      = 0;
        vif.round_mode = 0;
        repeat(3) @(posedge clk);
        vif.rst_n = 1;
    end
endmodule

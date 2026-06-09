class dot_product_monitor extends uvm_monitor;
    `uvm_component_utils(dot_product_monitor)

    virtual dot_product_if vif;

    // analysis port — sends captured transactions to scoreboard
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
        // wait for accum_valid to go high
        do @(vif.monitor_cb); while (!vif.monitor_cb.accum_valid);

        // capture the output
        item = dot_product_seq_item::type_id::create("item");
        item.a_flat = vif.monitor_cb.a_flat;
        item.b_flat = vif.monitor_cb.b_flat;
        item.expected = vif.monitor_cb.accum; // ← actual output from DUT

        // send to scoreboard via analysis port
        ap.write(item);
    end
endtask

endclass
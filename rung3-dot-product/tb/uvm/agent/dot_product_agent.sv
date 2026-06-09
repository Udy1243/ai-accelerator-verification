class dot_product_agent extends uvm_agent;
    `uvm_component_utils(dot_product_agent)

    dot_product_driver    driver;
    dot_product_monitor   monitor;
    uvm_sequencer #(dot_product_seq_item) sequencer;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        driver    = dot_product_driver::type_id::create("driver", this);
        monitor   = dot_product_monitor::type_id::create("monitor", this);
        sequencer = uvm_sequencer #(dot_product_seq_item)::type_id::create(
                        "sequencer", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // connect driver to sequencer
        driver.seq_item_port.connect(sequencer.seq_item_export);
    endfunction

endclass
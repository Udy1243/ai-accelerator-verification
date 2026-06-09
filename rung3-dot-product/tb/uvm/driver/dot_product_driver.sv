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
        // initialize signals
        vif.driver_cb.tvalid <= 0;
        vif.driver_cb.tlast  <= 0;
        vif.driver_cb.a_flat <= 0;
        vif.driver_cb.b_flat <= 0;
        // wait for reset to release
        @(posedge vif.clk);
        wait(vif.rst_n === 1'b1);

        forever begin
            // get next item from sequencer
            seq_item_port.get_next_item(item);

            // drive inputs
            vif.driver_cb.a_flat <= item.a_flat;
            vif.driver_cb.b_flat <= item.b_flat;
            vif.driver_cb.tvalid <= 1;
            vif.driver_cb.tlast  <= 1;

            // wait for handshake — tready high means DUT accepted
            do @(vif.driver_cb); while (!vif.driver_cb.tready);

            // drop valid
            vif.driver_cb.tvalid <= 0;
            vif.driver_cb.tlast  <= 0;

            // tell sequencer this item is done
            seq_item_port.item_done();
        end
    endtask

endclass
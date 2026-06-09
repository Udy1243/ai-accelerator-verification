class dot_product_sequence extends uvm_sequence #(dot_product_seq_item);
    `uvm_object_utils(dot_product_sequence)

    // handle to scoreboard analysis port for sending expected values
    uvm_analysis_port #(dot_product_seq_item) sb_ap;

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

            // send expected value to scoreboard
            if (sb_ap != null)
                sb_ap.write(item);
        end
    endtask

endclass
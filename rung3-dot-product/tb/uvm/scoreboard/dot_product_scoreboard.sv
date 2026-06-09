class dot_product_scoreboard extends uvm_scoreboard;
    `uvm_component_utils(dot_product_scoreboard)

    // two analysis exports — one from monitor, one from sequence
    uvm_analysis_export #(dot_product_seq_item) mon_export;
    uvm_analysis_export #(dot_product_seq_item) seq_export;

    // TLM FIFOs to buffer incoming transactions
    uvm_tlm_analysis_fifo #(dot_product_seq_item) mon_fifo;
    uvm_tlm_analysis_fifo #(dot_product_seq_item) seq_fifo;

    int pass_count;
    int fail_count;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        mon_export = new("mon_export", this);
        seq_export = new("seq_export", this);
        mon_fifo   = new("mon_fifo",   this);
        seq_fifo   = new("seq_fifo",   this);
        pass_count = 0;
        fail_count = 0;
    endfunction

    function void connect_phase(uvm_phase phase);
        mon_export.connect(mon_fifo.analysis_export);
        seq_export.connect(seq_fifo.analysis_export);
    endfunction

    task run_phase(uvm_phase phase);
        dot_product_seq_item mon_item, seq_item;
        forever begin
            // get actual result from monitor
            mon_fifo.get(mon_item);
            // get expected result from sequence
            seq_fifo.get(seq_item);

            // compare
            if (mon_item.expected !== seq_item.expected) begin
                `uvm_error("SCOREBOARD",
                    $sformatf("FAIL: got %0d expected %0d",
                    mon_item.expected, seq_item.expected))
                fail_count++;
            end else begin
                `uvm_info("SCOREBOARD",
                    $sformatf("PASS: accum = %0d", mon_item.expected),
                    UVM_LOW)
                pass_count++;
            end
        end
    endtask

    function void report_phase(uvm_phase phase);
        `uvm_info("SCOREBOARD",
            $sformatf("\n\nResults: %0d passed, %0d failed\n",
            pass_count, fail_count), UVM_LOW)
    endfunction

endclass
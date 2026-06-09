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

        // create and configure sequence
        seq = dot_product_sequence::type_id::create("seq");
        seq.num_transactions = 100;

        // connect sequence analysis port to scoreboard
        seq.sb_ap = new("sb_ap", null);
        seq.sb_ap.connect(env.scoreboard.seq_export);

        // run sequence on agent's sequencer
        seq.start(env.agent.sequencer);

        phase.drop_objection(this);
    endtask

endclass
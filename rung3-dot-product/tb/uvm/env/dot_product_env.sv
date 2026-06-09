class dot_product_env extends uvm_env;
    `uvm_component_utils(dot_product_env)

    dot_product_agent       agent;
    dot_product_scoreboard  scoreboard;

    function new(string name, uvm_component parent);
        super.new(name, parent);
    endfunction

    function void build_phase(uvm_phase phase);
        super.build_phase(phase);
        agent      = dot_product_agent::type_id::create("agent", this);
        scoreboard = dot_product_scoreboard::type_id::create(
                         "scoreboard", this);
    endfunction

    function void connect_phase(uvm_phase phase);
        // connect monitor analysis port to scoreboard
        agent.monitor.ap.connect(scoreboard.mon_export);
    endfunction

endclass
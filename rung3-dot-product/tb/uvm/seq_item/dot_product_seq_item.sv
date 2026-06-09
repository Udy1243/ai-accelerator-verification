class dot_product_seq_item extends uvm_sequence_item;
    `uvm_object_utils(dot_product_seq_item)

    parameter int DATA_WIDTH  = 4;
    parameter int VECTOR_LEN  = 8;
    parameter int ACCUM_WIDTH = 11;

    // randomized inputs
    rand logic signed [DATA_WIDTH*VECTOR_LEN-1:0] a_flat;
    rand logic signed [DATA_WIDTH*VECTOR_LEN-1:0] b_flat;

    // computed — not randomized
    logic signed [ACCUM_WIDTH-1:0] expected;

    // constraints
    constraint valid_inputs {
        // mix of small and large values
        a_flat dist {
            [-(2**(DATA_WIDTH*VECTOR_LEN-1)):-(2**(DATA_WIDTH*VECTOR_LEN-2))] := 30,
            [-(2**(DATA_WIDTH*VECTOR_LEN-2)):0]                                := 20,
            [0:(2**(DATA_WIDTH*VECTOR_LEN-2))]                                 := 20,
            [(2**(DATA_WIDTH*VECTOR_LEN-2)):(2**(DATA_WIDTH*VECTOR_LEN-1)-1)]  := 30
        };
    }

    function new(string name = "dot_product_seq_item");
        super.new(name);
    endfunction

    // compute expected after randomization
    function void post_randomize();
        logic signed [DATA_WIDTH-1:0] a [VECTOR_LEN-1:0];
        logic signed [DATA_WIDTH-1:0] b [VECTOR_LEN-1:0];
        logic signed [ACCUM_WIDTH-1:0] sum;
        sum = '0;
        for (int i = 0; i < VECTOR_LEN; i++) begin
            a[i] = a_flat[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH];
            b[i] = b_flat[DATA_WIDTH*(i+1)-1 -: DATA_WIDTH];
            sum  = sum + ACCUM_WIDTH'(signed'(a[i] * b[i]));
        end
        expected = sum;
    endfunction

endclass
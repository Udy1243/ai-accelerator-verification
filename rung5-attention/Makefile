.PHONY: sim sim_attn cosim cosim_attn waves synth clean

MAC = ../rung1-mac-unit/rtl/mac_unit.sv
DP  = ../rung3-dot-product/rtl/dot_product.sv

sim:
	mkdir -p sim
	iverilog -g2012 -o sim/out rtl/softmax.sv tb/softmax_tb.sv && vvp sim/out

sim_attn:
	mkdir -p sim
	iverilog -g2012 -o sim/attn_out $(MAC) $(DP) rtl/softmax.sv rtl/attention.sv tb/attention_tb.sv && vvp sim/attn_out

cosim_attn:
	mkdir -p sim
	python3 tb/generate_attention_vectors.py
	iverilog -g2012 -o sim/attn_cosim_out $(MAC) $(DP) rtl/softmax.sv rtl/attention.sv tb/attention_cosim_tb.sv && vvp sim/attn_cosim_out

cosim:
	mkdir -p sim
	python3 tb/generate_vectors.py
	iverilog -g2012 -o sim/cosim rtl/softmax.sv tb/softmax_cosim_tb.sv && vvp sim/cosim

waves:
	gtkwave sim/waves.vcd &

synth:
	mkdir -p sim
	yosys -p "read_verilog -sv rtl/softmax.sv; synth -top softmax; stat" 2>&1 | tee sim/synth.log

clean:
	rm -rf sim/

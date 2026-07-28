.PHONY: sim cosim waves synth clean

sim:
	mkdir -p sim
	iverilog -g2012 -o sim/out rtl/softmax.sv tb/softmax_tb.sv && vvp sim/out

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

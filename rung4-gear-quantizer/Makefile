.PHONY: sim cosim waves synth clean

sim:
	mkdir -p sim
	iverilog -g2012 -o sim/out rtl/gear_quantizer.sv tb/tb_gear_quantizer.sv && vvp sim/out

cosim:
	mkdir -p sim
	python3 tb/generate_vectors.py
	iverilog -g2012 -o sim/cosim rtl/gear_quantizer.sv tb/tb_cosim.sv && vvp sim/cosim

waves:
	gtkwave sim/waves.vcd &

synth:
	mkdir -p sim
	yosys -p "read_verilog -sv rtl/gear_quantizer.sv; synth -top gear_quantizer; stat" 2>&1 | tee sim/synth.log

clean:
	rm -rf sim/

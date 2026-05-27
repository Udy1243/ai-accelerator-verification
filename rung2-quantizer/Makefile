SIM_DIR = sim
RTL     = rtl/quantizer.sv
TB      = tb/quantizer_tb.sv

.PHONY: sim waves synth clean

sim:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/quant_sim $(RTL) $(TB) && vvp $(SIM_DIR)/quant_sim

waves:
	gtkwave $(SIM_DIR)/waves.vcd &

synth:
	yosys -p "read_verilog -sv $(RTL); synth -top quantizer; stat"

clean:
	rm -f $(SIM_DIR)/quant_sim $(SIM_DIR)/waves.vcd
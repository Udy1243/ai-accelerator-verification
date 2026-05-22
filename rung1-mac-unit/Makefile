SIM_DIR = sim
RTL     = rtl/mac_unit.sv
TB      = tb/mac_unit_tb.sv
.PHONY: sim waves synth clean

sim:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/mac_sim $(RTL) $(TB) && vvp $(SIM_DIR)/mac_sim

waves:
	gtkwave $(SIM_DIR)/waves.vcd &

synth:
	yosys -p "read_verilog -sv $(RTL); synth -top mac_unit; stat"

clean:
	rm -f $(SIM_DIR)/mac_sim $(SIM_DIR)/waves.vcd
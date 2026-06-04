SIM_DIR = sim
RTL     = rtl/dot_product.sv ../rung1-mac-unit/rtl/mac_unit.sv
TB      = tb/dot_product_tb.sv

.PHONY: sim waves synth clean

sim:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/dot_product_sim $(RTL) $(TB) && vvp $(SIM_DIR)/dot_product_sim

waves:
	gtkwave $(SIM_DIR)/waves.vcd &

synth:
	yosys -p "read_verilog -sv $(RTL); synth -top dot_product; stat"

clean:
	rm -f $(SIM_DIR)/dot_product_sim $(SIM_DIR)/waves.vcd
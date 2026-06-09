SIM_DIR  = sim
RTL      = rtl/dot_product.sv
MAC      = ../rung1-mac-unit/rtl/mac_unit.sv
TB       = tb/dot_product_tb.sv
UVM_TOP  = tb/uvm/top.sv
UVM_HOME = $(HOME)/uvm-1.2/src

.PHONY: sim uvm waves synth clean

sim:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 -o $(SIM_DIR)/dot_product_sim \
		$(RTL) $(MAC) $(TB) && vvp $(SIM_DIR)/dot_product_sim

uvm:
	mkdir -p $(SIM_DIR)
	iverilog -g2012 \
		-I$(UVM_HOME) \
		-o $(SIM_DIR)/dot_product_uvm \
		$(UVM_HOME)/uvm_pkg.sv \
		$(RTL) $(MAC) $(UVM_TOP) && vvp $(SIM_DIR)/dot_product_uvm

waves:
	gtkwave $(SIM_DIR)/waves.vcd &

synth:
	yosys -p "read_verilog -sv $(RTL) $(MAC); synth -top dot_product; stat"

clean:
	rm -f $(SIM_DIR)/dot_product_sim $(SIM_DIR)/dot_product_uvm \
		$(SIM_DIR)/waves.vcd
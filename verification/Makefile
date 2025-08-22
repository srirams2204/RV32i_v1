# -----------------------------------------------------------
# Makefile
# A flexible Makefile for running Cocotb simulations
#
# To run the test, use the following command:
#   make MODULE=test_pc
# -----------------------------------------------------------

# Define the top-level Verilog module name
TOPLEVEL := pc

# Specify the simulator to use (icarus, ghdl, verilator, etc.)
SIM := icarus

# Location of the Verilog source file
VERILOG_SOURCES := pc.sv

# Location of the Python testbench file
# This variable can be overridden on the command line,
# making the Makefile flexible for multiple testbenches.
MODULE ?= test_pc

# The main simulation target
sim:
	@echo "Running simulation for module '$(MODULE)'..."
	@cocotb-config --make --sim-env --verilog-libs $(VERILOG_SOURCES)

# Clean up simulation files
clean:
	@echo "Cleaning up simulation files..."
	@rm -rf sim_build
	@rm -rf __pycache__
	@rm -f *.vcd *.log

.PHONY: sim clean


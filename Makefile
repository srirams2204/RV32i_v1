# Directories
SRC_DIR := src
TB_DIR := testbench
SIM_DIR := sim
WAVE_DIR := waveform

# Tools
IVERILOG := iverilog
VVP := vvp

# Pass filenames (without .v) from terminal
# Example: make run SRC=adder TB=tb_adder
SRC ?= my_design
TB ?= tb_my_design


# File paths
SRC_FILE := $(SRC_DIR)/$(SRC).v
TB_FILE := $(TB_DIR)/$(TB).v
VVP_FILE := $(SIM_DIR)/$(SRC).vvp
VCD_FILE := $(WAVE_DIR)/$(SRC).vcd

# Default target
all: run

# Compile only the selected source and testbench
$(VVP_FILE): $(SRC_FILE) $(TB_FILE)
	@mkdir -p $(SIM_DIR) $(WAVE_DIR)
	$(IVERILOG) -o $(VVP_FILE) $(SRC_FILE) $(TB_FILE)

# Run simulation
run: $(VVP_FILE)
	$(VVP) $(VVP_FILE)

# Open waveform in GTKWave
wave: $(VCD_FILE)
	gtkwave $(VCD_FILE) 

# Clean generated files
clean:
	rm -rf $(SIM_DIR)/* $(WAVE_DIR)/*

.PHONY: all run wave clean
# Compiler tools
RISCV_GCC := riscv32-unknown-elf-gcc
RISCV_LD := riscv32-unknown-elf-ld
RISCV_OBJCOPY := riscv32-unknown-elf-objcopy
PYTHON := python3

# Flags
CFLAGS := -O0 -march=rv32i -mabi=ilp32

# Directories (relative to rv32i_gcc/)
SRC_DIR := src
BUILD_DIR := build
OUTPUT_HEX_DIR := output_hex
TOOLS_DIR := tools

# Program name (without extension), pass with "make PROGRAM=add"
PROGRAM ?= add

# Paths
SRC_FILE := $(SRC_DIR)/$(PROGRAM).c
OBJ_FILE := $(BUILD_DIR)/$(PROGRAM).o
ELF_FILE := $(BUILD_DIR)/$(PROGRAM).elf
SREC_FILE := $(BUILD_DIR)/$(PROGRAM).srec
HEX_RAW_FILE := $(OUTPUT_HEX_DIR)/$(PROGRAM)_raw.hex
HEX_FILE := $(OUTPUT_HEX_DIR)/$(PROGRAM).hex

# Default target
all: $(HEX_FILE)

# Step 1: Compile C to object
$(OBJ_FILE): $(SRC_FILE)
	@mkdir -p $(BUILD_DIR)
	$(RISCV_GCC) $(CFLAGS) -c -o $@ $<

# Step 2: Link object to ELF
$(ELF_FILE): $(OBJ_FILE)
	$(RISCV_LD) -Ttext=0x0 -o $@ $<

# Step 3: Convert ELF to SREC
$(SREC_FILE): $(ELF_FILE)
	$(RISCV_OBJCOPY) -O srec $< $@

# Step 4: Convert SREC to Verilog HEX (raw)
$(HEX_RAW_FILE): $(SREC_FILE)
	@mkdir -p $(OUTPUT_HEX_DIR)
	$(RISCV_OBJCOPY) -I srec -O verilog --verilog-data-width=4 $< $@

# Step 5: Format HEX for $readmemh
$(HEX_FILE): $(HEX_RAW_FILE)
	$(PYTHON) $(TOOLS_DIR)/hex_formatter.py $(HEX_RAW_FILE) $(HEX_FILE)
	@rm -f $(HEX_RAW_FILE)   # cleanup raw file

clean:
	rm -rf $(BUILD_DIR)/* $(OUTPUT_HEX_DIR)/*

.PHONY: all clean

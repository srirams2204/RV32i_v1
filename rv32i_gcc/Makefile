# Compiler
RISCV_GCC := riscv32-unknown-elf-gcc
RISCV_OBJCOPY := riscv32-unknown-elf-objcopy

# Flags
#CFLAGS := -march=rv32i -mabi=ilp32 -O2 -Wall
CFLAGS := -march=rv32i -mabi=ilp32 -Os -Wl,--gc-sections #to produce a smaller, more compact output

# Directories
SRC_DIR := src
BUILD_DIR := build

# Filename to compile (without extension), passed from command line
# Default value if none provided
PROGRAM ?= hello_world

# Full paths
SRC_FILE := $(SRC_DIR)/$(PROGRAM).c
ELF_FILE := $(BUILD_DIR)/$(PROGRAM).elf
HEX_FILE := $(BUILD_DIR)/$(PROGRAM).hex

# Default target
all: build

build: $(HEX_FILE)

$(ELF_FILE): $(SRC_FILE)
	@mkdir -p $(BUILD_DIR)
	$(RISCV_GCC) $(CFLAGS) -o $@ $<

$(HEX_FILE): $(ELF_FILE)
	$(RISCV_OBJCOPY) -O ihex $< $@

#$(HEX_FILE): $(ELF_FILE)
#	$(RISCV_OBJCOPY) -O verilog $< $@

clean:
	rm -rf $(BUILD_DIR)/*

.PHONY: all build clean

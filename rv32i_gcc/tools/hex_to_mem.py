#!/usr/bin/env python3
from intelhex import IntelHex
import sys

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} input.hex output.mem")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

# Read HEX file
ih = IntelHex(input_file)

# Get address range
start_addr = ih.minaddr()
end_addr = ih.maxaddr()

# Write output
with open(output_file, "w") as f:
    for addr in range(start_addr, end_addr + 1, 4):  # Step by 4 bytes per instruction
        b0 = ih[addr]       # LSB
        b1 = ih[addr + 1]
        b2 = ih[addr + 2]
        b3 = ih[addr + 3]   # MSB
        word = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0
        f.write(f"{word:08x}\n")

print(f"[OK] Wrote instruction memory file: {output_file}")

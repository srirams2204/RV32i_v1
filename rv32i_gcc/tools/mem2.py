#!/usr/bin/env python3
from intelhex import IntelHex
import sys

if len(sys.argv) != 3:
    print(f"Usage: {sys.argv[0]} input.hex output.mem")
    sys.exit(1)

input_file = sys.argv[1]
output_file = sys.argv[2]

ih = IntelHex(input_file)

instructions = []
last_non_zero_index = -1

for start_addr, end_addr in ih.segments():
    # Align start_addr to next multiple of 4
    if start_addr % 4 != 0:
        start_addr += 4 - (start_addr % 4)
    for addr in range(start_addr, end_addr + 1, 4):
        b0 = ih[addr]
        b1 = ih[addr + 1]
        b2 = ih[addr + 2]
        b3 = ih[addr + 3]
        word = (b3 << 24) | (b2 << 16) | (b1 << 8) | b0
        instructions.append(f"{word:08x}")

        if word != 0:
            last_non_zero_index = len(instructions) - 1

# Keep only up to last non-zero instruction
instructions = instructions[:last_non_zero_index + 1]

with open(output_file, "w") as f:
    f.write("\n".join(instructions) + "\n")

print(f"[OK] Wrote {len(instructions)} instructions up to last non-zero to {output_file}")

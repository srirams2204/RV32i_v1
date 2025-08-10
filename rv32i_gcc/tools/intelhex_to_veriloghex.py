import sys

def intel_hex_to_verilog_hex(intel_hex_file, verilog_hex_file):
    memory = dict()

    with open(intel_hex_file, 'r') as f:
        upper_addr = 0
        for line in f:
            line = line.strip()
            if not line.startswith(':'):
                continue
            # Parse record
            byte_count = int(line[1:3], 16)
            addr = int(line[3:7], 16)
            record_type = int(line[7:9], 16)
            data = line[9:9+byte_count*2]
            # checksum = line[9+byte_count*2:9+byte_count*2+2] # ignored here

            if record_type == 0:  # Data record
                full_addr = (upper_addr << 16) + addr
                for i in range(0, byte_count):
                    byte_str = data[2*i:2*i+2]
                    memory[full_addr + i] = byte_str

            elif record_type == 4:  # Extended linear address record
                upper_addr = int(data, 16)

            elif record_type == 1:  # End Of File
                break

    # Find min and max addresses to output
    if not memory:
        print("No data found in HEX file!")
        return

    min_addr = min(memory.keys())
    max_addr = max(memory.keys())

    # Output 32-bit words in little endian
    with open(verilog_hex_file, 'w') as out:
        addr = min_addr
        while addr <= max_addr:
            # Read 4 bytes (handle missing bytes as 0)
            b0 = memory.get(addr, "00")
            b1 = memory.get(addr+1, "00")
            b2 = memory.get(addr+2, "00")
            b3 = memory.get(addr+3, "00")
            # Little endian word
            word = b3 + b2 + b1 + b0
            out.write(word + "\n")
            addr += 4

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python intelhex_to_veriloghex.py input.hex output.mem")
        sys.exit(1)
    intel_hex_to_verilog_hex(sys.argv[1], sys.argv[2])

import sys

def clean_hex(input_file, output_file):
    with open(input_file, "r") as f:
        lines = f.readlines()

    cleaned_lines = []
    for line in lines:
        # Remove leading/trailing whitespace
        line = line.strip()

        if not line:  # skip blank lines
            continue

        # Split instructions separated by spaces
        parts = line.split()
        for p in parts:
            cleaned_lines.append(p)

    # Write cleaned hex file
    with open(output_file, "w") as f:
        for l in cleaned_lines:
            f.write(l + "\n")

    print(f"[INFO] Cleaned hex written to {output_file}")

if __name__ == "__main__":
    if len(sys.argv) != 3:
        print("Usage: python3 hex_formatter.py <input.hex> <output.hex>")
        sys.exit(1)

    input_file = sys.argv[1]
    output_file = sys.argv[2]
    clean_hex(input_file, output_file)

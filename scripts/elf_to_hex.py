#!/usr/bin/env python3

import argparse
import subprocess
import sys


def main():
    parser = argparse.ArgumentParser(
        description="Convert a RISC-V ELF into a word-oriented Verilog hex file."
    )

    parser.add_argument("elf", help="Input ELF file")
    parser.add_argument("output", help="Output .hex file")
    parser.add_argument(
        "--objcopy",
        default="riscv64-unknown-elf-objcopy",
        help="Path to objcopy (default: riscv64-unknown-elf-objcopy)",
    )

    args = parser.parse_args()

    # Temporary byte-oriented file
    temp_hex = args.output + ".tmp"

    try:
        subprocess.run(
            [
                args.objcopy,
                "-O",
                "verilog",
                args.elf,
                temp_hex,
            ],
            check=True,
        )
    except subprocess.CalledProcessError:
        print("objcopy failed.")
        sys.exit(1)

    with open(temp_hex) as f:
        tokens = []

        for line in f:
            line = line.strip()

            if not line:
                continue

            if line.startswith("@"):
                continue

            tokens.extend(line.split())

    if len(tokens) % 4 != 0:
        print(
            f"Warning: byte count ({len(tokens)}) is not divisible by 4.",
            file=sys.stderr,
        )

    with open(args.output, "w") as out:
        out.write("@00000000\n")

        for i in range(0, len(tokens), 4):
            if i + 3 >= len(tokens):
                break

            # Convert little-endian bytes into one 32-bit word
            word = (
                tokens[i + 3]
                + tokens[i + 2]
                + tokens[i + 1]
                + tokens[i]
            )

            out.write(word.lower() + "\n")

    subprocess.run(["rm", "-f", temp_hex])


if __name__ == "__main__":
    main()
#!/usr/local/bin/python
# Translate riscv hex to a byte reversed .mem file
import byteReverseMem

fin = "bootrom.hex"

with open(fin, "r") as f:
	contents = f.read().split()
	contents = "\n".join(contents)

print(contents)
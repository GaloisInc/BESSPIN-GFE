#!/usr/local/bin/python
import codecs
codecs.getencoder('hex')(b'foo')[0]

fin = "bootrom.hex"
fout = "bootrom.coe"

mem_header = """memory_initialization_radix=16;
memory_initialization_vector="""
mem_string = ""
mem_string += mem_header + "\n"

with open(fin, "r") as f:
    for line in f:
        hex_values = line.split()
        for value in hex_values:
            # Flip the byte order for the .coe format
            n = 2
            byte_chars = [ value[i:i+2] for i in range(0, len(value), n) ]
            byte_chars = byte_chars[::-1]
            for c in byte_chars:
                mem_string += c + ",\n"

mem_string = mem_string[:-2] + ";"

print(mem_string)
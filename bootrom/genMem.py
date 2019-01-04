#!/usr/local/bin/python
import codecs
codecs.getencoder('hex')(b'foo')[0]

fin = "bootrom.hex"
fout = "bootrom.mem"

mem_header = "@00000000"
mem_string = ""
mem_string += mem_header + "\n"

with open(fin, "r") as f:
    for line in f:
        hex_values = line.split()
        for value in hex_values:
            mem_string += value + "\n"

# mem_string = mem_string[:-2] + ";"

print(mem_string)
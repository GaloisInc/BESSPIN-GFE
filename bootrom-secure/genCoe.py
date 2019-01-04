#!/usr/local/bin/python
import codecs
codecs.getencoder('hex')(b'foo')[0]

fin = "bootrom.hex"
fout = "bootrom.coe"

coe_header = """*******************************************************
********  Single Port Block Memory .COE file  *********
*******************************************************
; Memory initialization file for Single Port Block Memory, 
; v3.0 or later.
;
; This .COE file specifies initialization values for a block 
; memory of width=32. In this case, values are 
; specified in hexadecimal format.
memory_initialization_radix=16;
memory_initialization_vector="""

coe_string = ""
coe_string += coe_header + "\n"

with open(fin, "r") as f:
    for line in f:
        hex_values = line.split()
        for value in hex_values:
            coe_string += value + ",\n"

coe_string = coe_string[:-2] + ";"

print(coe_string)
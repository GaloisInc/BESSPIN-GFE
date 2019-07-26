#!/bin/bash
# This is a simple script that uploads a bitstream and a binary to flash
# After finishes, you have to power-cycle the FPGA and then press CPU_RESET
# button to start running the code

if (($# != 2)); then
    echo "Illegal number of parameters"
    echo "Usage: $0 path-to-bitfile path-to-elf"
    exit -1
fi

prog=$(basename $2)
echo "Copying " $prog

# Make a flash-compatible binary
echo "Copying " $2
cp $2 bootmem/.
cd bootmem
PROG=$prog make -f Makefile.freertos
rm -f bootmem/$prog
cd ..


bitfile_path=$1
echo "Bitstream path: " $bitfile_path

echo "Uploading bitstream"
tcl/program_flash bitfile $bitfile_path
echo "Bitstream upload finished"

echo "Uploading binary"
tcl/program_flash datafile bootmem/bootmem.bin
echo "Binary upload finished"

echo "Done! Power cycle your FPGA."

#!/bin/bash
# This is a simple script that uploads a bitstream and a binary to flash
# After finishes, you have to power-cycle the FPGA and then press CPU_RESET
# button to start running the code

if (($# != 2)); then
    echo "Illegal number of parameters"
    echo "Usage: $0 processor_name path-to-elf"
    exit -1
fi

prog=$(basename $2)
echo "Copying " $prog

# Make a flash-compatible binary
cp $2 bootmem/.
cd bootmem
PROG=$prog make -f Makefile.freertos
rm -f bootmem/$prog
cd ..

if [ $1 == "chisel_p1" ]; then
    bitfile_path=bitstreams/soc_chisel_p1.bit
elif [ $1 == "bluespec_p1" ]; then
    bitfile_path=bitstreams/soc_bluespec_p1.bit
else
    echo "Unsupported processor: " $1
    exit -1
fi

echo "Uploading bitstream"
tcl/program_flash bitfile $bitfile_path
echo "Bitstream upload finished"

tcl/program_flash datafile bootmem/bootmem.bin
echo "Done! Power cycle your FPGA."

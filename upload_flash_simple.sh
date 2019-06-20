#!/bin/bash
# This is a simple script that uploads a bitstream and a binary to flash
# After finishes, you have to power-cycle the FPGA and then press CPU_RESET
# button to start running the code

if (( $# != 2 )); then
    echo "Illegal number of parameters"
    echo "Usage: $0 path-to-bitfile path-to-datafile"
    exit -1
fi

tcl/program_flash bitfile $1
tcl/program_flash datafile $2
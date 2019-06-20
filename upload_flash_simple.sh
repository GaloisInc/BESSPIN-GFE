#!/bin/bash
# This is a simple script that uploads a bitstream and a binary to flash
# After finishes, you have to power-cycle the FPGA and then press CPU_RESET
# button to start running the code

if (( $# != 2 )); then
    echo "Illegal number of parameters"
    echo "Usage: $0 processor_name path-to-elf"
    exit -1
fi

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"

prog=`basename $2`
echo "Copying " $prog

# Make a flash-compatible binary
cp $2 bootmem/.
cd bootmem
PROG=$prog make -f Makefile.freertos
rm bootmem/$prog
cd -

if [ "$proc_name" == "chisel_p1" ] ; then 
    bitfile_path=bitstreams/soc_chisel_p1.bit
elif [ "$proc_name" == "bluespec_p1" ] ; then 
    bitfile_path=bitfile bitstreams/soc_bluespec_p1.bit
else
    echo "Unsupported processor: " $proc_name
    exit -1
fi

echo "Uploading bitstream"
tcl/program_flash bitfile $bitfile_path
echo "Bitstream upload finished"

tcl/program_flash datafile bootmem/bootmem.bin
echo "Done! Power cycle your FPGA."

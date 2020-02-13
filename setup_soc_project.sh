#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_DIR
source $BASE_DIR/setup_env.sh
source $BASE_DIR/init_submodules.sh

proc_name=""
proc_path=""
# Clock frequency is in MHz
clock_freq_mhz=50

# Parse the processor selection
proc_picker $1

no_xdma=1

case "$proc_name" in
    *p2_pcie)
	no_xdma=0
	;;
    *)
	echo "use_xdma is valid only for P2 processors"
	;;
    esac

# Compile the bootrom and set the clock frequency
cd $BASE_DIR/bootrom
case "$proc_name" in
    *p1)
	make --always-make CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=50000000 NO_PCI=$no_xdma
	clock_freq_mhz=50
	;;
    *p2*)
	make --always-make CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=100000000 NO_PCI=$no_xdma
	clock_freq_mhz=100
	;;
    *p3)
	make --always-make CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=25000000 NO_PCI=$no_xdma
	clock_freq_mhz=25
	;;
    *)
	echo "WARNING: don't know how to make a boot ROM for processor $proc_name"
	;;
esac

err_msg $? "Making the bootrom failed"

echo "Please run with Vivado 2019.1"
# i.e.
# source /Xilinx/Vivado/2019.1/settings64.sh
mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado

# Run vivado to create a top level project
# See soc.tcl for detailed options
vivado -mode batch -source $BASE_DIR/tcl/soc.tcl \
-tclargs --origin_dir $BASE_DIR/tcl \
--proc_name $proc_name \
--clock_freq_mhz $clock_freq_mhz \
--no_xdma $no_xdma


err_msg $? "Creating the vivado project failed"

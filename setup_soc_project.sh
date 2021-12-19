#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $BASE_DIR
source $BASE_DIR/setup_env.sh
source $BASE_DIR/init_submodules.sh

# utility function to move old bootrom folder out of the way
move_old_bootrom() {
    if [ -d "$BASE_DIR/bootrom-configured" ]; then
        echo "moving old configured bootrom"
        msec=`date +%s`
        mv "$BASE_DIR/bootrom-configured" "$BASE_DIR/bootrom-configured.$msec"
    fi
}

proc_name=""
proc_path=""
# Clock frequency is in MHz
clock_freq_mhz=50

# Parse the processor selection
proc_picker $1

no_xdma=0
# Currently there is an issue when no_xdma=1 and en_frame_buff=1 as the block
# design of the video output was created with no_xmda=1. Setting both to 1
# causes a Vivado error when running .tcl scripts due to overlapping nets.
en_frame_buff=1

if [[ $proc_name == *p2_pcie ]]; then
    no_xdma=0
    echo "enabling PCIe, disabling SVF"
fi
if [[ $proc_name != *p2* ]]; then
    en_frame_buff=0
    echo "disabling frame buffer, only supported with p2"
fi
    
# Set up the bootrom directory

if [ -z "$2" ]; then
    # if there isn't a second parameter, use the default bootrom
    echo "generating default bootrom"
    move_old_bootrom
    cp -pr "$BASE_DIR/bootrom" "$BASE_DIR/bootrom-configured"
elif [ -f "$2" ]; then
    # if the second parameter points to an existing file, first check to see
    # that it's a binary image, i.e., _not_ an ELF
    filetype=`file -b $2`
    if [[ $filetype == ELF* ]]; then
        err_msg 1 "secure bootrom requires binary image, not ELF"
    fi
    # if it is, measure it and configure the bootrom
    sha=`sha256sum $2 | awk '{print $1}'`
    len=`ls -nl $2 | awk '{print $5}'`
    echo "generating secure bootrom for binary '$2'"
    echo "       length: $len"
    echo "    sha256sum: $sha"
    move_old_bootrom
    cp -pr "$BASE_DIR/bootrom-secure" "$BASE_DIR/bootrom-configured"
    $BASE_DIR/bootrom-configured/configure.sh $sha $len
    err_msg $? "failed to configure the secure bootrom"
else
    proc_usage
    err_msg 1 "specified secure boot binary image doesn't exist"
fi

# Compile the bootrom and set the clock frequency
cd $BASE_DIR/bootrom-configured
case "$proc_name" in
    *p1)
	make --always-make XLEN=32 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=50000000 NO_PCI=$no_xdma
	clock_freq_mhz=50 ENABLE_FRAME_BUFFER=$en_frame_buff
	;;
    *p2*)
	make --always-make XLEN=64 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=100000000 NO_PCI=$no_xdma
	clock_freq_mhz=100 ENABLE_FRAME_BUFFER=$en_frame_buff
	;;
    bluespec_p3)
	make --always-make XLEN=64 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=25000000 RTC_FREQ=250000 NO_PCI=$no_xdma
	clock_freq_mhz=25 ENABLE_FRAME_BUFFER=$en_frame_buff
	;;
    chisel_p3)
	make --always-make XLEN=64 CROSS_COMPILE=riscv64-unknown-elf- CPU_SPEED=25000000 NO_PCI=$no_xdma
	clock_freq_mhz=25 ENABLE_FRAME_BUFFER=$en_frame_buff
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
source /opt/Xilinx/Vivado/2019.1/settings64.sh
vivado -mode batch -source $BASE_DIR/tcl/soc.tcl \
-tclargs --origin_dir $BASE_DIR/tcl \
--proc_name $proc_name \
--clock_freq_mhz $clock_freq_mhz \
--no_xdma $no_xdma \
--en_frame_buff $en_frame_buff

err_msg $? "Creating the vivado project failed"

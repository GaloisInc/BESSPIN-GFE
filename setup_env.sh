#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
SETUP_ENV_ERR=0

# Use the custom fork of openocd
export PATH=$BASE_DIR/riscv-tools/bin:$PATH
OPENOCD_BIN=$BASE_DIR/riscv-tools/bin/openocd
if [ ! -f $OPENOCD_BIN ]; then
	echo "ERROR: Could not find OpenOCD binary at $OPENOCD_BIN"
	SETUP_ENV_ERR=-1
fi

# Check if RISCV path has been previously set by user
# if not, use local installation
if [ "a$RISCV" == "a" ]; then
	echo "ERROR: RISCV variable not found."
	echo "Please set RISCV to your installation of the riscv-gnu-toolchain"
	SETUP_ENV_ERR=-1
else
	echo "RISCV variable found, adding $RISCV/bin to your PATH"
	export PATH=$RISCV/bin:$PATH
	echo "PATH = $PATH"
fi

function err_msg { 
	if [[ $1 -ne 0 ]]; then
		echo $2
		exit 1
	fi
}

function check_file {
	if [ ! -f $1 ]; then
		echo $2
		exit 1
	fi
}

function proc_usage {
    echo "Usage: $0 [chisel_p1|chisel_p2|bluespec_p1|bluespec_p2]"
    echo "Please specify a bluespec or chisel processor!"
}

function proc_picker {
	# Parse the processor selection
	if [ "$1" == "bluespec_p1" ]; then
	        proc_name="bluespec_p1"
	elif [ "$1" == "bluespec_p2" ]; then
	        proc_name="bluespec_p2"
	elif [ "$1" == "chisel_p1" ]; then
	        proc_name="chisel_p1"
	elif [ "$1" == "chisel_p2" ]; then
	        proc_name="chisel_p2"
	else
	        proc_usage
	        exit -1
	fi
}

function proc_xlen_usage {
        echo "Usage: $0 [32|64]"
        echo "Please specify a 32 or 64 bit processor!"
}

function xlen_picker {
	# Parse the processor selection
	if [ "$1" == "32" ]; then
	        XLEN="32"
	elif [ "$1" == "64" ]; then
	        XLEN="64"
	else
	        proc_xlen_usage
	        exit -1
	fi
}

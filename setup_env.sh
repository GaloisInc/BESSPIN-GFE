#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Check if RISCV path has been previously set by user
# if not, use local installation
if [ "a$RISCV" == "a" ]; then
	export RISCV=$BASE_DIR/riscv-tools
	export PATH=$BASE_DIR/riscv-tools/bin:$PATH
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

function p1_usage {
        echo "Usage: $0 [chisel|bluespec]"
        echo "Please specify bluespec or chisel!"
}

function p1_picker {
	# Parse the processor selection
	if [ "$1" == "bluespec" ]; then
	        p1_name="bluespec"
	elif [ "$1" == "chisel" ]; then
	        p1_name="chisel"
	else
	        p1_usage
	        exit -1
	fi
}

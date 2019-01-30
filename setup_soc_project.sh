#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh

p1_name=""
p1_path=""

# Parse the processor selection
if [ "$1" == "bluespec" ]; then
	p1_name="bluespec"
elif [ "$1" == "chisel" ]; then
	p1_name="chisel"
fi 

# Compile the bootrom
cd $BASE_DIR/bootrom
make
if [ $? -ne 0 ]; then
	echo "Making the bootrom failed"
	exit 1
fi

echo "Please run with Vivado 2017.4"
# i.e.
# source /Xilinx/Vivado/2017.4/settings64.sh
mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado

# Run vivado to create a top level project
# See p1_soc.tcl for detailed options
vivado -mode batch -source $BASE_DIR/tcl/p1_soc.tcl \
-tclargs --origin_dir $BASE_DIR/tcl \
--p1_name $p1_name
if [ $? -ne 0 ]; then
	echo "Creating the vivado project failed"
	exit 1
fi



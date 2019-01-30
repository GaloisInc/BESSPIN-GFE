#!/usr/bin/env bash

echo "Please run with Vivado 2017.4"
# i.e.
# source /Xilinx/Vivado/2017.4/settings64.sh

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

p1_name=""
p1_path=""

# Parse the processor selection
if [ "$1" == "bluespec" ]; then
	p1_name="bluespec"
elif [ "$1" == "chisel" ]; then
	p1_name="chisel"
fi 

mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado

# Run vivado to build a top level project
# See p1_soc.tcl for detailed options
vivado -mode batch -source $BASE_DIR/tcl/p1_soc.tcl \
-tclargs --origin_dir $BASE_DIR/tcl \
--p1_name $p1_name

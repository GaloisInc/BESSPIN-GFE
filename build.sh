#!/usr/bin/env bash

echo "Please run with Vivado 2017.4"
# i.e.
# source /Xilinx/Vivado/2017.4/settings64.sh

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# Parse the processor selection
if [ "$1" == "bluespec" ]; then
	p1_name="bluespec"
elif [ "$1" == "chisel" ]; then
	p1_name="chisel"
fi 

# Check that the vivado project exits
vivado_project=$BASE_DIR/vivado/p1_soc_$p1_name/p1_soc_$p1_name.xpr
if [ ! -f $vivado_project ]; then
	echo "$vivado_project does not exist. Cannot build project. Please specify a valid p1_name"
	echo "For example, run ./build.sh chisel"
	exit 1
fi

# Run vivado to build a top level project
cd $BASE_DIR/vivado
vivado -mode batch $vivado_project -source $BASE_DIR/tcl/build.tcl
if [ $? -ne 0 ]; then
	echo "Vivado build failed"
	exit 1
fi

# Copy bitstream to the bitstreams folder
bitstream=$BASE_DIR/vivado/$vivado_project/$vivado_project.runs/impl_1/design_1.bit 
output_bitstream=$BASE_DIR/bitstreams/$vivado_project.bit
if [ ! -f $bitstream ]; then
	echo "Bitstream $bitstream not generated. Check Vivado logs"
	exit 1
fi
cp $bitstream $output_bitstream

#!/usr/bin/env bash

echo "Please run with Vivado 2017.4"
# i.e.
# source /Xilinx/Vivado/2017.4/settings64.sh

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh

p1_picker $1

# Check that the vivado project exits
project_name=p1_soc_${p1_name}
vivado_project=$BASE_DIR/vivado/${project_name}/${project_name}.xpr
check_file $vivado_project "$vivado_project does not exist. Cannot build project.
Please specify a valid p1_name For example, run ./build.sh chisel"

# Run vivado to build a top level project
cd $BASE_DIR/vivado
#vivado -mode batch $vivado_project -source $BASE_DIR/tcl/build.tcl
err_msg $? "Vivado build failed"

# Copy bitstream to the bitstreams folder
bitstream=$BASE_DIR/vivado/${project_name}/${project_name}.runs/impl_1/design_1.bit 
output_bitstream=$BASE_DIR/bitstreams/${project_name}.bit
check_file $bitstream "Bitstream $bitstream not generated. Check Vivado logs"
cp $bitstream $output_bitstream

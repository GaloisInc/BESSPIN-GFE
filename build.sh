#!/usr/bin/env bash

echo "Please run with Vivado 2019.1"
# i.e.
# source /Xilinx/Vivado/2019.1/settings64.sh

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh

proc_picker $1

# Check that the vivado project exits
project_name=soc_${proc_name}
vivado_project=$BASE_DIR/vivado/${project_name}/${project_name}.xpr
check_file $vivado_project "$vivado_project does not exist. Cannot build project.
Please run setup_soc_project.sh first and/or specify a valid proc_name For example,
run ./build.sh chisel_p1"

# AWS F1 Targets
if [[ $1 == *"aws"* ]]; then
  shift # This blasts $1 so that we don't pass invalid arguments to hdk_setup
  export CL_DIR=$BASE_DIR/$proc_name
  echo "CL_DIR: "$CL_DIR
  source $BASE_DIR/aws-fpga/hdk_setup.sh
  $HDK_SHELL_DIR/build/scripts/prepare_build_environment.sh
  cd $CL_DIR/build/scripts
  $BASE_DIR/aws-fpga/hdk/common/shell_stable/build/scripts/aws_build_dcp_from_cl.sh -foreground

# VC118 Targets
else

# Run vivado to build a top level project
cd $BASE_DIR/vivado
vivado -mode batch $vivado_project -source $BASE_DIR/tcl/build.tcl
err_msg $? "Vivado build failed"

# Copy bitstream to the bitstreams folder
bitstream=$BASE_DIR/vivado/${project_name}/${project_name}.runs/impl_1/design_1.bit 
output_bitstream=$BASE_DIR/bitstreams/${project_name}.bit
check_file $bitstream "Bitstream $bitstream not generated. Check Vivado logs"
cp $bitstream $output_bitstream

fi


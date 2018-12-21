#!/usr/bin/env bash

echo "Please run with Vivado 2017.4"
# i.e.
# source /opt/Xilinx/Vivado/2017.4/settings64.sh

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado

# Run vivado to build a top level project
vivado -mode batch -source $BASE_DIR/gfe-xilinx-subsystem/open_gfe_subsystem_project.tcl \
	-tclargs --origin_dir $BASE_DIR/gfe-xilinx-subsystem/
start_gui
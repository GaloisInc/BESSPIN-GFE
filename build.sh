#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

# TODO: Consider updating the vivado scripting to use non-project mode
mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado
vivado -mode batch -source $BASE_DIR/tcl/p1_chisel_soc.tcl -tclargs --origin_dir $BASE_DIR/tcl

#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
# TODO: Make these paths generic or pass them as arguments
BITFILE=$BASE_DIR/vivado/p1_chisel_soc/p1_chisel_soc.runs/impl_2/design_1.bit
LTXFILE=$BASE_DIR/vivado/p1_chisel_soc/p1_chisel_soc.runs/impl_2/design_1.ltx

# TODO: Finish scripting the steps to generate blk_mem_gen_0.mmi
# For now, open the implemented design in Vivado and run the following:
# source ../tcl/write_mmi.tcl
# write_mmi blk_mem_gen_0

mkdir -p $BASE_DIR/vivado
cd $BASE_DIR/vivado
updatemem -force --meminfo $BASE_DIR/vivado/blk_mem_gen_0.mmi \
--data $BASE_DIR/bootrom/bootrom.mem \
--bit $BITFILE --proc dummy -debug \
-out $BASE_DIR/bitstreams/design_1_bootrom.bit
cp $LTXFILE $BASE_DIR/bitstreams/design_1_bootrom.ltx

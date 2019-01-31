#!/usr/bin/env bash

usage () {
	echo "Usage: $0 [chisel|bluespec]"
        echo "Please pick specify bluespec or chisel!"
}

# Parse the processor selection
if [ "$1" == "bluespec" ]; then
        p1_name="bluespec"
elif [ "$1" == "chisel" ]; then
        p1_name="chisel"
else
	usage
	exit -1
fi

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
PRJNAME=p1_soc_${p1_name}
BITFILE=$BASE_DIR/vivado/${PRJNAME}/${PRJNAME}.runs/impl_1/design_1.bit
LTXFILE=$BASE_DIR/vivado/${PRJNAME}/${PRJNAME}.runs/impl_1/design_1.ltx
PRJFILE=${PRJNAME}/${PRJNAME}.xpr

if [ ! -f $BITFILE ]; then
	echo "Error! Cannot find bit file at $BITFILE"
	exit -1
fi
if [ ! -f $LTXFILE ]; then
	echo "Error! Cannot find LTX file at $LTXFILE"
	exit -1
fi
if [ ! -f vivado/$PRJFILE ]; then
	echo "Error! Cannot find Vivado Project file at $PRJFILE"
	exit -1
fi

# Generate the MMI necessary for finding the memory
echo "Running Vivado to extract memory information..."
cd $BASE_DIR/vivado
vivado -mode batch -nojournal -nolog -notrace -source ../tcl/update_bootrom.tcl $PRJFILE
if [ $? -ne 0 ]; then
	echo "Error! Extracting memory information failed!"
	exit -1
fi

echo "Updating memory with data from $BASE_DIR/bootrom/bootrom.mem"
updatemem -force --meminfo $BASE_DIR/vivado/blk_mem_gen_0.mmi \
--data $BASE_DIR/bootrom/bootrom.mem \
--bit $BITFILE --proc dummy -debug \
-out $BASE_DIR/bitstreams/design_1_bootrom.bit
if [ $? -ne 0 ]; then
	echo "Error! Updating memory failed!"
	exit -1
fi

cp $LTXFILE $BASE_DIR/bitstreams/design_1_bootrom.ltx
echo "Success! New bit file can found at $BASE_DIR/bitstreams/design1_bootrom.bit"


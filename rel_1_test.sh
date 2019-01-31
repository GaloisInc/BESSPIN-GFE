#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

# Compile a set of assembly tests for the GFE
cd $BASE_DIR/testing/baremetal/asm
make

if [ $? -ne 0 ]; then
	echo "Making the assembly tests failed"
	exit 1
fi

# Build FreeRTOS
cd $BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin
make
if [ $? -ne 0 ]; then
	echo "Building FreeRTOS-RISCV failed"
	exit 1
fi


# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py

if [ $? -ne 0 ]; then
	echo "GFE unittests failed. Run python test_gfe_unittest.py"
	exit 1
fi



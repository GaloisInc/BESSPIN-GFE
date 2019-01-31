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

# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestGfe

if [ $? -ne 0 ]; then
	echo "GFE unittests failed. Run python test_gfe_unittest.py"
	exit 1
fi

# Build FreeRTOS
cd $BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin
make MAIN_FILE=uart_test.c 
if [ $? -ne 0 ]; then
	echo "Building FreeRTOS-RISCV uart_driver test failed"
	exit 1
fi
freertos_folder=$BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin/
cp $freertos_folder/riscv-p1-vcu118.elf $freertos_folder/uart_test.elf
make clean && make
if [ $? -ne 0 ]; then
	echo "Building FreeRTOS-RISCV demo failed"
	exit 1
fi

cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestFreeRTOS
if [ $? -ne 0 ]; then
	echo "One or more FreeRTOS Tests failed"
	exit 1
fi

#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

# Build FreeRTOS
cd $BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin
make MAIN_FILE=uart_test.c 
# if [ $? -ne 0 ]; then
# 	echo "Building FreeRTOS-RISCV uart_driver test failed"
# 	exit 1
# fi
freertos_folder=$BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin/
cp $freertos_folder/riscv-p1-vcu118.elf $freertos_folder/uart_test.elf
# make clean && make
# if [ $? -ne 0 ]; then
# 	echo "Building FreeRTOS-RISCV demo failed"
# 	exit 1
# fi

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running a FreeRTOS tests."
read -p "After resetting the CPU, press enter to continue... "

cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestFreeRTOS.test_uart_driver
if [ $? -ne 0 ]; then
	echo "UART driver test failed"
	exit 1
fi

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) in between FreeRTOS tests."
read -p "After resetting the CPU, press enter to continue... "

python test_gfe_unittest.py TestFreeRTOS.test_uart_driver
if [ $? -ne 0 ]; then
	echo "One or more FreeRTOS Tests failed"
	exit 1
fi

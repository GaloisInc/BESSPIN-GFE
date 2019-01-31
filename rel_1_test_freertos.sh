#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

# Build FreeRTOS
cd $BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin
make MAIN_FILE=uart_test.c 
err_msg $? "Building FreeRTOS-RISCV uart_driver test failed"

freertos_folder=$BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin/
cp $freertos_folder/riscv-p1-vcu118.elf $freertos_folder/uart_test.elf
make clean && make
err_msg $? "Building FreeRTOS-RISCV demo failed"

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running a FreeRTOS tests."
read -p "After resetting the CPU, press enter to continue... "

cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestFreeRTOS.test_freertos
err_msg $? "One or more FreeRTOS Tests failed"


echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) in between FreeRTOS tests."
read -p "After resetting the CPU, press enter to continue... "

python test_gfe_unittest.py TestFreeRTOS.test_uart_driver
err_msg $? "UART driver test failed"



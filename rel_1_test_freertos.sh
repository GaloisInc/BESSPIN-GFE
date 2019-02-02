#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

# Build FreeRTOS
freertos_folder=$BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin/
cd $freertos_folder
make PROG=uart_test 
err_msg $? "Building FreeRTOS-RISCV uart_driver test failed"

make PROG=main
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

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running anymore tests."
read -p "After resetting the CPU, press enter to continue... "



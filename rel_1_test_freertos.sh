#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

# Build FreeRTOS
freertos_folder=$BASE_DIR/FreeRTOS-mirror/Demo/RISCV-V_Bluespec_Picollo/
cd $freertos_folder
make clean; DEMO_TYPE=1 make
err_msg $? "Building FreeRTOS-RISCV blinky test failed"

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running a FreeRTOS tests."
read -p "After resetting the CPU, press enter to continue... "

cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestFreeRTOS.test_freertos
err_msg $? "One or more FreeRTOS Tests failed"

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running anymore tests."
read -p "After resetting the CPU, press enter to continue... "



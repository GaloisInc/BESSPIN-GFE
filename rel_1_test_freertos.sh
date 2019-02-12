#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

freertos_folder=$BASE_DIR/FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Bluespec_Picollo/
python_unittest_script=test_gfe_unittest.py

# $1: DEMO_TYPE
# $2: python test name
function freertos_test {
	cd $freertos_folder
	make clean; DEMO_TYPE=${1} make
	err_msg $? "Building FreeRTOS-RISCV DEMO_TYPE=${1} test failed"

	cd $BASE_DIR/testing/scripts
	python $python_unittest_script TestFreeRTOS.$2
	err_msg $? "One or more FreeRTOS Tests failed"
}

freertos_test 1 test_blink

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running anymore tests."
read -p "After resetting the CPU, press enter to continue... "



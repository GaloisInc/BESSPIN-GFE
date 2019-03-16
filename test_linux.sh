#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"
cd $BASE_DIR/testing/scripts

linux_folder=$BASE_DIR/bootmem/
python_unittest_script=test_gfe_unittest.py

function linux_test {
	cd $linux_folder
	make
	err_msg $? "Building Linux failed"

	cd $BASE_DIR/testing/scripts
	python $python_unittest_script TestLinux.$1
	err_msg $? "One or more FreeRTOS Tests failed"
}

linux_test test_boot



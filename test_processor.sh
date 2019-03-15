#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"

proc_picker $1

# Program the FPGA with the appropriate bitstream
# ./program_fpga.sh $proc_name

echo "Testing $proc_name"

# Run all P1 processor tests
if [ "$proc_name" == "chisel_p1" ] || [ "$proc_name" == "bluespec_p1" ]; then
	./test.sh 32
	err_msg $? "test.sh 32 failed"
	./test_freertos.sh
	err_msg $? "test_freertos.sh failed"
fi

# Run all P2 processor tests
if [ "$proc_name" == "chisel_p2" ] || [ "$proc_name" == "bluespec_p2" ]; then
	./test.sh 64
	err_msg $? "test.sh 64 failed"
	./test_linux.sh
	err_msg $? "test_linux.sh failed"
fi

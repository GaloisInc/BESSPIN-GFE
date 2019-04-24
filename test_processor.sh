#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"

proc_picker $1

# Program the FPGA with the appropriate bitstream
./program_fpga.sh $proc_name
err_msg $? "test_processor.sh: Programming the FPGA failed"
sleep 1

echo "Testing $proc_name"

# Run all P1 processor tests
if [ "$proc_name" == "chisel_p1" ] || [ "$proc_name" == "bluespec_p1" ]; then
	./test.sh 32
	err_msg $? "test.sh 32 failed"
	./test_freertos.sh
	err_msg $? "test_freertos.sh failed"
	./test_freertos_ethernet.sh
	err_msg $? "test_freertos_ethernet.sh failed"
fi

# Run all P2/P3 processor tests
if [ "$proc_name" == "chisel_p2" ] || [ "$proc_name" == "bluespec_p2" ] || [ "$proc_name" == "chisel_p3" ] || [ "$proc_name" == "bluespec_p3" ]; then
	./test.sh 64
	err_msg $? "test.sh 64 failed"
	./test_linux.sh busybox
	err_msg $? "test_linux.sh busybox failed"
	./test_linux.sh debian 
	err_msg $? "test_linux.sh debian failed"
	./test_linux.sh debian --flash
	err_msg $? "test_linux.sh debian boot from flash failed"
	./test_linux_ethernet.sh busybox
	err_msg $? "test_linux_ethernet.sh busybox failed"
	./test_linux_ethernet.sh debian
	err_msg $? "test_linux_ethernet.sh debian failed"
fi

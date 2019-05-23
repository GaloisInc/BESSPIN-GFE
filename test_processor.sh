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
	err_msg $? "test.sh 32 failed" "test.sh 32 OK"
	./test_freertos.sh
	err_msg $? "test_freertos.sh failed" "test_freertos.sh OK"
fi

# Run all P2/P3 processor tests
if [ "$proc_name" == "chisel_p2" ] || [ "$proc_name" == "bluespec_p2" ] || [ "$proc_name" == "chisel_p3" ] || [ "$proc_name" == "bluespec_p3" ]; then
	./test.sh 64
	err_msg $? "test.sh 64 failed" "test.sh 64 OK"
	./test_linux.sh busybox
	err_msg $? "test_linux.sh busybox failed" "test_linux.sh busybox OK"
	./test_linux.sh debian
	err_msg $? "test_linux.sh debian failed" "test_linux.sh debian OK"
	./test_linux.sh busybox --ethernet
	err_msg $? "test_linux.sh busybox ethernet failed" "test_linux.sh busybox ethernet OK"
	./test_linux.sh debian --ethernet
	err_msg $? "test_linux.sh debian ethernet failed" "test_linux.sh debian ethernet OK"
	./test_linux.sh debian --flash $proc_name	
	err_msg $? "test_linux.sh debian boot from flash failed" "test_linux.sh debian boot from flash OK"
fi

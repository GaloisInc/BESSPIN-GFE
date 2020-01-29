#!/usr/bin/env bash
echo "This script is obsolete, use pytest_processor.py instead."
echo "Press ENTER if you want to continue, or CTRL-C to abort"
read


# Get the path to the script folder of the git repository
BASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" >/dev/null && pwd)"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"

proc_picker $1

if [[ $2 == "--full_ci" ]]; then
	full_ci=true
else
	full_ci=false
fi

# Allow different kernel configurations - with PCIe enabled or without
if [[ $3 == "--no-pcie" ]]; then
	PCIE_OPTION=--no-pcie
fi

# Make sure the Bluespec P1 is programmed with a valid flash content
# This is a workaround for https://gitlab-ext.galois.com/ssith/gfe/issues/58
if [ "$proc_name" == "bluespec_p1" ]; then
	tcl/program_flash datafile bootmem/small.bin
fi

# Program the FPGA with the appropriate bitstream
./program_fpga.sh $proc_name
err_msg $? "test_processor.sh: Programming the FPGA failed"
sleep 1

echo "Testing $proc_name"

# Run all P1 processor tests
if [ "$proc_name" == "chisel_p1" ] || [ "$proc_name" == "bluespec_p1" ]; then
	./test.sh 32 $proc_name
	err_msg $? "test.sh 32 failed" "test.sh 32 OK"
	./test_freertos.sh
	err_msg $? "test_freertos.sh basic failed" "test_freertos.sh basic OK"
	if [ "$full_ci" = true ]; then
		# Test the peripherals, assuming we have the right setup
		./test_freertos.sh --full_ci
		err_msg $? "test_freertos.sh full CI failed" "test_freertos.sh full CI OK"
		./test_freertos.sh --ethernet
		err_msg $? "test_freertos.sh ethernet failed" "test_freertos.sh ethernet OK"
		# TODO: fix flash loading
		#./test_freertos.sh --flash $proc_name blinky
		#err_msg $? "test_freertos.sh flash failed" "test_freertos.sh flash OK"
	fi
fi

# Run all P2/P3 processor tests
if [ "$proc_name" == "chisel_p2" ] || [ "$proc_name" == "bluespec_p2" ] || [ "$proc_name" == "chisel_p3" ] || [ "$proc_name" == "bluespec_p3" ]; then
	export XARCH=64
	./test_freertos.sh
	err_msg $? "test_freertos.sh basic failed" "test_freertos.sh basic OK"
	./test_freertos.sh --ethernet
	err_msg $? "test_freertos.sh ethernet failed" "test_freertos.sh ethernet OK"
	./test.sh 64 $proc_name
	err_msg $? "test.sh 64 failed" "test.sh 64 OK"
	./test_linux.sh busybox --dummy $PCIE_OPTION
	err_msg $? "test_linux.sh busybox failed" "test_linux.sh busybox OK"
	#./test_linux.sh debian --dummy $PCIE_OPTION
	#err_msg $? "test_linux.sh debian failed" "test_linux.sh debian OK"
	if [ "$full_ci" = true ]; then
		# Run ethernet test only if we have the proper hardware setup
		./test_linux.sh busybox --ethernet $PCIE_OPTION
		err_msg $? "test_linux.sh busybox ethernet failed" "test_linux.sh busybox ethernet OK"
		./test_linux.sh debian --ethernet $PCIE_OPTION
		err_msg $? "test_linux.sh debian ethernet failed" "test_linux.sh debian ethernet OK"
		# TODO: don't test flash until PCIe options are properly parametrized
		# ./test_linux.sh debian --flash $proc_name
		# err_msg $? "test_linux.sh debian boot from flash failed" "test_linux.sh debian boot from flash OK"
	fi
fi

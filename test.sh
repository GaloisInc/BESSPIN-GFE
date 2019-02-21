#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

xlen_picker $1

# Compile a set of assembly tests for the GFE
cd $BASE_DIR/testing/baremetal/asm
make XLEN=${XLEN}
err_msg $? "Making the assembly tests failed"

# compile riscv-tests
cd $BASE_DIR/riscv-tools/riscv-tests
CC=riscv${XLEN}-unknown-elf-gcc ./configure --with-xlen=${XLEN} --target=riscv${XLEN}-unknown-elf
make XLEN=${XLEN}
err_msg $? "Failed to make isa tests"

echo "Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running this test suite."
read -p "After resetting the CPU, press enter to continue... "

# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestGfe${XLEN}
err_msg $? "GFE unittests failed. Run python test_gfe_unittest.py"

cd $BASE_DIR
# Skip generating a new test file
#./testing/scripts/gen-test-all rv32imacu > test.gdb
riscv${XLEN}-unknown-elf-gdb --batch -x $BASE_DIR/testing/scripts/rel_1_isa_tests.gdb
echo "riscv-tests summary:"
grep -E "(PASS|FAIL)" gdb-client.log | uniq -c

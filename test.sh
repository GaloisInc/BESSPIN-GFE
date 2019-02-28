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

# Compile riscv-tests
cd $BASE_DIR/riscv-tools/riscv-tests
CC=riscv${XLEN}-unknown-elf-gcc ./configure --with-xlen=${XLEN} --target=riscv${XLEN}-unknown-elf
make
err_msg $? "Failed to make isa tests"

# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestGfe${XLEN}
err_msg $? "GFE unittests failed. Run python test_gfe_unittest.py"

# Generate gdb isa test script
# Reset the gfe
cd $BASE_DIR/testing/scripts
python softReset.py
cd $BASE_DIR
if [ ${XLEN} == 64 ]
then
  ./testing/scripts/gen-test-all rv64gcsu > test_64.gdb
else
  ./testing/scripts/gen-test-all rv32imacu > test_32.gdb
fi
riscv${XLEN}-unknown-elf-gdb --batch -x $BASE_DIR/test_${XLEN}.gdb
# riscv${XLEN}-unknown-elf-gdb --batch -x $BASE_DIR/testing/scripts/test
# riscv${XLEN}-unknown-elf-gdb --batch -x $BASE_DIR/testing/scripts/rel_1_isa_tests.gdb
echo "riscv-tests summary:"
grep -E "(PASS|FAIL)" gdb-client.log | uniq -c

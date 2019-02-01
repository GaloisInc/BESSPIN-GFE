#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
cd $BASE_DIR/testing/scripts

# Compile a set of assembly tests for the GFE
cd $BASE_DIR/testing/baremetal/asm
# make
err_msg $? "Making the assembly tests failed"

# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestGfe
err_msg $? "GFE unittests failed. Run python test_gfe_unittest.py"

# compile, run riscv-tests
cd $BASE_DIR/riscv-tools/riscv-tests
CC=riscv32-unknown-elf-gcc ./configure --with-xlen=32 --target=riscv32-unknown-elf
make
err_msg $? "Failed to make isa tests"

cd $BASE_DIR
./testing/scripts/gen-test-all rv32imacu > test.gdb
riscv32-unknown-elf-gdb --batch -x test.gdb
echo "riscv-tests summary:"
grep -E "(PASS|FAIL)" gdb-client.log | uniq -c

#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $BASE_DIR/testing/scripts

# Check that it is possible to GDB into the riscv core
python gdbserver.py ../targets/p1.py ExamineTarget

# Compile and run the UART, BOOTROM, and DDR smoke tests
cd $BASE_DIR/testing/baremetal/asm
make

cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py

# Optionally, boot FreeRTOS

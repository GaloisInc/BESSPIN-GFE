#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $BASE_DIR

# Check that it is possible to GDB into the riscv core
python gdbserver.py ../targets/p1.py ExamineTarget

# Compile and run the UART, BOOTROM, and DDR smoke tests
cd ../baremetal/asm
make

cd $BASE_DIR
python run_gfe_test.py ../baremetal/asm/rv32ui-p-uart

# Optionally, boot FreeRTOS

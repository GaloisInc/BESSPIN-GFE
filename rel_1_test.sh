#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
export RISCV=$BASE_DIR/riscv-tools

cd $BASE_DIR/testing/scripts

# Compile a set of assembly tests for the GFE
cd $BASE_DIR/testing/baremetal/asm

# Build FreeRTOS
cd $BASE_DIR/FreeRTOS-RISCV/Demo/p1-besspin

# Run some unittests including UART, DDR, and Bootrom
# The final unittest tests booting freeRTOS
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py

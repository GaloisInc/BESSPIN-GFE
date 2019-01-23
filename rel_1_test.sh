#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

cd $BASE_DIR/testing/scripts

# Compile and run the UART, BOOTROM, and DDR smoke tests
cd $BASE_DIR/testing/baremetal/asm
make

cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py

# Optionally, boot FreeRTOS

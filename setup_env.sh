#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

export RISCV=$BASE_DIR/riscv-tools
export PATH=$BASE_DIR/riscv-tools/bin:$PATH

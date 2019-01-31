#!/usr/bin/env bash

# Get the path to the root folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

function err_msg { 
	if [[ $1 -ne 0 ]]; then
		echo $2
		exit 1
	fi
}

export RISCV=$BASE_DIR/riscv-tools
export PATH=$BASE_DIR/riscv-tools/bin:$PATH

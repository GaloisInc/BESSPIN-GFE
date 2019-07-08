#!/usr/bin/env bash

#### Environment setup and verifying parameters
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

source $BASE_DIR/setup_env.sh

err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"

if [ "$1" == "--help" ] || [ $# -lt 3 ] ; then runOnLinux_usage; exit; fi

proc_picker $1
if [ ${proc_name: -1} -eq 1 ]; then xlen_picker 32; else xlen_picker 64; fi
linux_picker $2
check_file $3 "$0: Error: $3 is not found."
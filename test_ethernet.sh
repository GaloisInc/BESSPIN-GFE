#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"
cd $BASE_DIR/testing/scripts

linux_folder=$BASE_DIR/bootmem/

# Build busybox
cd $linux_folder
make
err_msg $? "Building Linux failed"

# Load test
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestLinux.test_busybox_ethernet
err_msg $? "Busybox Ethernet test failed"

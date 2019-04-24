#!/usr/bin/env bash

# Get the path to the script folder of the git repository
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
source $BASE_DIR/setup_env.sh
err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"
cd $BASE_DIR/testing/scripts

linux_folder=$BASE_DIR/bootmem/
python_unittest_script=test_gfe_unittest.py

function proc_linux_usage {
    echo "Usage: $0 [busybox|debian]"
    echo "Please specify busybox or debian!"
}

function linux_picker {
	# Parse the processor selection
	if [ "$1" == "debian" ]; then
	        linux_image="debian"
	elif [ "$1" == "busybox" ]; then
	        linux_image="busybox"
	else
        proc_linux_usage
        exit -1
	fi
}

# Parse command line arguments
linux_picker $1

# Build the Linux image
cd $linux_folder
if [ "$linux_image" == "debian" ]; then
	make debian
else
	make
fi
err_msg $? "Building Linux failed"

# Run the appropriate Linux unittest
cd $BASE_DIR/testing/scripts
python test_gfe_unittest.py TestLinux.test_${linux_image}_ethernet
err_msg $? "Busybox Ethernet test failed"

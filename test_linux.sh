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
    echo "Usage: $0 [busybox|debian] --flash"
    echo "Usage: $0 [busybox|debian] --ethernet"
    echo "Please specify busybox or debian!"
    echo "Add --flash if you want to program the image into flash and boot from it"
    echo "Add --ethernet if you want to test ethernet on Linux"
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
if [[ $2 == "--flash" ]]; then
	use_flash=true
	test_ethernet=false
elif [[ $2 == "--ethernet" ]]; then
	test_ethernet=true
	use_flash=false
else
	use_flash=false
	test_ethernet=false
fi

# Build the Linux image
cd $linux_folder
if [ "$linux_image" == "debian" ]; then
	make debian
else
	make
fi
err_msg $? "Building Linux failed"

# Optionally, program the flash 
if [ "$use_flash" = true ]; then
	cd $BASE_DIR
	echo "Programming flash with Linux image"
	$BASE_DIR/tcl/program_flash datafile bootmem/bootmem.bin
	err_msg $? "Programming flash failed"
fi

# Run the appropriate Linux unittest
cd $BASE_DIR/testing/scripts
if [ "$use_flash" = true ]; then
	python $python_unittest_script TestLinux.test_${linux_image}_flash_boot
elif [ "$test_ethernet" = true ]; then
	python $python_unittest_script TestLinux.test_${linux_image}_ethernet
else
	python $python_unittest_script TestLinux.test_${linux_image}_boot
fi
err_msg $? "The Linux test failed"
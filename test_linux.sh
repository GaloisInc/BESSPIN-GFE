#!/usr/bin/env bash
# Get the path to the script folder of the git repository

echo "This script is obsolete, use pytest_processor.py instead."
echo "Press ENTER if you want to continue, or CTRL-C to abort"
read

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

# Use PCIe config for tests
if [[ $3 == "--no-pcie" ]]; then
	echo "Linux config without PCIe"
	LINUX_CONFIG_PATH=`pwd`/../../bootmem/linux-no-pcie.config
	DEBIAN_CONFIG_PATH=`pwd`/../../bootmem/debian-linux-no-pcie.config
else
	LINUX_CONFIG_PATH=`pwd`/../../bootmem/linux.config
	DEBIAN_CONFIG_PATH=`pwd`/../../bootmem/debian-linux.config
fi

# Build the Linux image
cd $linux_folder
if [ "$linux_image" == "debian" ]; then
	DEBIAN_CONFIG=$DEBIAN_CONFIG_PATH make debian
else # busybox
	LINUX_CONFIG=$LINUX_CONFIG_PATH make
fi
err_msg $? "Building Linux failed"

# Optionally, program the flash 
if [ "$use_flash" = true ]; then
	cd $BASE_DIR/testing/scripts/
	echo "test_linux.sh: Programming flash with Linux image"
	python test_upload_flash.py
	err_msg $? "test_linux.sh: Programming flash failed" "test_linux.sh: Programming flash OK"
fi

# Run the appropriate Linux unittest
cd $BASE_DIR/testing/scripts
if [ "$use_flash" = true ]; then
	cd $BASE_DIR
	echo "test_linux.sh: Programming FPGA with a bitstream after a flash upload"
	./program_fpga.sh $proc_name $3
	err_msg $? "test_linux.sh: Programming the FPGA failed" "test_linux.sh: Programming the FPGA OK"
	cd $BASE_DIR/testing/scripts
	./$python_unittest_script TestLinux.test_${linux_image}_flash_boot
elif [ "$test_ethernet" = true ]; then
	./$python_unittest_script TestLinux.test_${linux_image}_ethernet
else
	./$python_unittest_script TestLinux.test_${linux_image}_boot
fi
err_msg $? "The Linux test failed"

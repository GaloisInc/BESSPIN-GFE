#!/usr/bin/env bash

#### Environment setup and verifying parameters
echo "$0: Setting up the environment.."

source setup_env.sh

BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"

err_msg $SETUP_ENV_ERR "Sourcing setup_env.sh failed"

if [ "$1" == "--help" ] || [ $# -lt 3 ] ; then runOnLinux_usage; exit; fi

proc_picker $1
if [ ${proc_name: -1} -eq 1 ]; then xlen_picker 32; else xlen_picker 64; fi
linux_picker $2
check_file $3 "$0: Error: $3 is not found."
checkMode $4

#### Cross compiling the user C file
echo "$0: Cross compiling $3.."
make clean 
make PROG=$3 XLEN=$XLEN
err_msg $? "$0: Cross compiling $3 failed"

#### Building linux and programming the FPGA
if [ $doSkipFPGA -ne 1 ]; then
    echo "$0: Building the linux [$2] image.."
    linux_folder=$BASE_DIR/../bootmem/
    cd $linux_folder
    if [ "$linux_image" == "debian" ]; then
        make debian
    else
        make
    fi
    err_msg $? "Building Linux failed."

    echo "$0: Programming the FPGA.."
    cd ..
    ./program_fpga.sh $proc_name
    err_msg $? "$0: Programming the FPGA failed"
    sleep 1
else
    echo "$0: SkipFPGA mode is activated."
    echo "$0: Assuming linux is up on the FPGA."
fi

#### Booting linux on the FPGA
echo "$0: Booting $linux_image on the FPGA.."
cd $BASE_DIR/../testing/scripts/
#python test_gfe_unittest.py TestLinux.test_${linux_image}_terminal
echo "python test_runOnLinux.py TestRunOnLinux.test_${linux_image}_terminal"
python runOnLinux.py RunOnLinux.test_${linux_image}_terminal
err_msg $? "$0: Testing the program failed."
echo "$0: The program ran successfully."
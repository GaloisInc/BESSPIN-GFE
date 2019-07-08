#!/usr/bin/env bash

function runOnLinux_usage {
    echo "Usage: $0 proc_name linux_image prog_to_run"
    echo "Usage: $0 --help"
}


function proc_linux_usage {
    echo "Usage: $0 linux_image = [busybox|debian]"
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

source $BASE_DIR/../setup_env.sh

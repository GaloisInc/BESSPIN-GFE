#!/usr/bin/env bash

# Check whether being run as sudo
if [[ $EUID -ne 0 ]]; then
	echo "Error: This script must be run as root"
	exit 1
fi

# Get the path to debian directory script is being run from 
DEBIAN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CHROOT_DIR=$DEBIAN_DIR/riscv64-chroot/
GFE_REPO=$DEBIAN_DIR/..

cd $CHROOT_DIR
sudo find . -print0 | sudo cpio --null --create --verbose --format=newc | gzip --best > $GFE_REPO/bootmem/debian.cpio.gz 

echo "Create cpio archive"

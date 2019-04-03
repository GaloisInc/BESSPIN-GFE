#!/usr/bin/env bash

# Get the path to debian directory script is being run from 
DEBIAN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CHROOT_DIR=$DEBIAN_DIR/riscv64-chroot/
GFE_REPO=$DEBIAN_DIR/..

cd $CHROOT_DIR
sudo find . -print0 | sudo cpio --null --create --verbose --format=newc | gzip --best > $GFE_REPO/bootmem/debian.cpio.gz 

echo "Create cpio archive"

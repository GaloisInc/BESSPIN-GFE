#!/usr/bin/env bash

# Get the path to debian directory script is being run from 
DEBIAN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CHROOT_DIR=$DEBIAN_DIR/riscv64-chroot/
GFE_REPO=$DEBIAN_DIR/..

sudo cp -R $DEBIAN_DIR/setup_scripts $CHROOT_DIR/

sudo /usr/sbin/chroot $CHROOT_DIR /setup_scripts/create_cpio.sh $UID || exit

if [ ! -f $CHROOT_DIR/debian.cpio.gz ]
then
	echo "Failed to create the CPIO archive!"
	exit -1
fi

mv $CHROOT_DIR/debian.cpio.gz $GFE_REPO/bootmem/debian.cpio.gz 

echo "Created cpio archive"

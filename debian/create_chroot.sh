#!/usr/bin/env bash

# Check whether being run as sudo
if [[ $EUID -ne 0 ]]; then
	echo "Error: This script must be run as root"
	exit 1
fi

# Get the path to debian directory script is being run from 
DEBIAN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CHROOT_DIR=$DEBIAN_DIR/riscv64-chroot
GFE_REPO=$DEBIAN_DIR/..

# Check for necessary packages
array=( "libssl-dev" "debian-ports-archive-keyring" "binfmt-support" "qemu-system-misc")
for i in "${array[@]}"
do
	dpkg -s $i &> /dev/null
	if [ $? -eq 0 ]; then
		echo "$i installed"
	else
		echo "$i required"
		exit 1;
	fi
done

# Check for necessary commands 
array=( "mmdebstrap" )
for i in "${array[@]}"
do
    command -v $i >/dev/null 2>&1 || { 
        echo >&2 "$i required"; 
        exit 1; 
    }
done

# Create chroot
if [ -d $CHROOT_DIR ]; then
	echo "Please remove $CHROOT_DIR then run again"
	exit 1;
fi
mkdir $CHROOT_DIR 
if [ ! -d $CHROOT_DIR ]; then
	err_msg $? "Error: Could not create $CHROOT_DIR"	
fi

echo "Creating chroot..."
mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring" sid $CHROOT_DIR "deb http://deb.debian.org/debian-ports/ sid main" "deb http://deb.debian.org/debian-ports/ unreleased main"

echo "Created chroot"

echo "Configuring chroot... "

cp $DEBIAN_DIR/clean_chroot.sh $CHROOT_DIR/clean_chroot.sh

# Enter chroot to configure and reduce size
cp $DEBIAN_DIR/config_chroot.sh $CHROOT_DIR/config_chroot.sh
chroot $CHROOT_DIR ./config_chroot.sh "$@" || exit 

echo "Configured chroot"

# Create compressed cpio archive
echo "Creating cpio archive..."

cd $CHROOT_DIR
sudo find . -print0 | sudo cpio --null --create --format=newc | gzip --best > $GFE_REPO/bootmem/debian.cpio.gz

echo "Created cpio archive"

#!/usr/bin/env bash

# Check whether being run as sudo
if [[ $EUID -ne 0 ]]; then
	echo "Error: This script must be run as root"
	exit 1
fi

# Get the path to the root folder of the git repository
GFE_REPO="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
cd $GFE_REPO

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
if [ -d $GFE_REPO/riscv64-chroot ]; then
	echo "Please remove $GFE_REPO/riscv64-chroot then run again"
	exit 1;
fi
mkdir $GFE_REPO/riscv64-chroot
if [ ! -d $GFE_REPO/riscv64-chroot ]; then
	err_msg $? "Error: Could not create $GFE_REPO/riscv64-chroot"	
fi

echo "Creating chroot..."
mmdebstrap --architectures=riscv64 --include="debian-ports-archive-keyring" sid $GFE_REPO/riscv64-chroot "deb http://deb.debian.org/debian-ports/ sid main" "deb http://deb.debian.org/debian-ports/ unreleased main"

echo "Created chroot"

echo "Configuring chroot... "

# Enter chroot to configure and reduce size
cat << EOF | chroot $GFE_REPO/riscv64-chroot/ 
# Create systemd symlink
ln -s /lib/systemd/systemd /init

# Set root password
yes riscv | passwd

# Modify network configuration
echo "
# Use DHCP to automatically configure eth0
auto eth0
allow-hotplug eth0
iface eth0 inet dhcp" >> /etc/network/interfaces

# Remove debconf internationalization for debconf
dpkg --remove debconf-i18n

# Remove foreign language man files
rm -rf /usr/share/man/??
rm -rf /usr/share/man/??_*

# Remove locale directory
rm -rf /usr/share/locale/

# Remove documentation
rm -rf /usr/share/doc/

# Remove dictionary
rm -rf /usr/share/dict/
EOF

echo "Configured chroot"

# Create compressed cpio archive
echo "Creating cpio archive..."

cd $GFE_REPO/riscv64-chroot
sudo find . -print0 | sudo cpio --null --create --format=newc | gzip --best > $GFE_REPO/bootmem/debian.cpio.gz

echo "Created cpio archive"

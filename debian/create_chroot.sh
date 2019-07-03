#!/usr/bin/env bash

# Get the path to debian directory script is being run from 
DEBIAN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
CHROOT_DIR=$DEBIAN_DIR/riscv64-chroot
GFE_REPO="$(dirname "$DEBIAN_DIR")"
# Pointing to a particular snapshot of debian as the master repo can be unstable!
DEBIAN_URL="https://snapshot.debian.org/archive/debian-ports/20190424T014031Z/"
DEBIAN_URL="http://deb.debian.org/debian-ports/"

# Init Type - Use either "systemd" or "sysv"
INIT_TYPE="systemd"

# Check for necessary packages
array=( "libssl-dev" "debian-ports-archive-keyring" "binfmt-support" "qemu-user-static" "mmdebstrap")
for i in "${array[@]}"
do
	dpkg -s $i &> /dev/null
	if [ $? -ne 0 ]; then
		echo "$i required"
		exit 1;
	fi
done

# Create chroot
if [ -d $CHROOT_DIR ]; then
	echo "Please remove $CHROOT_DIR then run again"
	exit 1;
fi

if [ "$INIT_TYPE" == "sysv" ]; then 
	echo "Creating chroot with SysV..."
	sudo mmdebstrap --architectures=riscv64 \
	--include="sysvinit-core,apt-utils,netbase,busybox,ifupdown,isc-dhcp-client,debian-ports-archive-keyring" \
	--dpkgopt='path-exclude=/usr/share/man/*' \
        --dpkgopt='path-exclude=/usr/share/locale/*' \
        --dpkgopt='path-include=/usr/share/locale/locale.alias' \
        --dpkgopt='path-exclude=/usr/share/doc/*' \
        --dpkgopt='path-include=/usr/share/doc/*/copyright' \
        --dpkgopt='path-exclude=/usr/share/dict/*' \
	--variant=minbase \
	sid $CHROOT_DIR "deb $DEBIAN_URL sid main" "deb $DEBIAN_URL unreleased main" || exit
else
	echo "Creating chroot with systemd..."
	sudo mmdebstrap --architectures=riscv64 \
	--include="debian-ports-archive-keyring" \
	--dpkgopt='path-exclude=/usr/share/man/*' \
        --dpkgopt='path-exclude=/usr/share/locale/*' \
        --dpkgopt='path-include=/usr/share/locale/locale.alias' \
        --dpkgopt='path-exclude=/usr/share/doc/*' \
        --dpkgopt='path-include=/usr/share/doc/*/copyright' \
        --dpkgopt='path-exclude=/usr/share/dict/*' \
	sid $CHROOT_DIR "deb $DEBIAN_URL sid main" "deb $DEBIAN_URL unreleased main" || exit
fi

echo "Created chroot"

echo "Copying scripts to chroot... "

# Use chroot to set proper permissions
sudo /usr/sbin/chroot $CHROOT_DIR chmod 775 / || exit
sudo /usr/sbin/chroot $CHROOT_DIR chown root:$UID / || exit

sudo cp -R $DEBIAN_DIR/setup_scripts $CHROOT_DIR/ || exit

# Enter chroot to configure and reduce size
sudo /usr/sbin/chroot $CHROOT_DIR /setup_scripts/config_chroot.sh "$@" || exit 

echo "Configured chroot"


#!/bin/bash

# Create systemd symlink
ln -s /lib/systemd/systemd /init

# Set root password
yes riscv | passwd

# Modify network configuration
# Temporarily disable networking on boot
#echo "
## Use DHCP to automatically configure eth0
#auto eth0
#allow-hotplug eth0
#iface eth0 inet dhcp" >> /etc/network/interfaces

# Fixup serial service for slower processors
sed -i 's/getty-pre.target/getty-pre.target systemd-udevd.service/' /etc/systemd/system/getty.target.wants/getty\@tty1.service 
sed -i 's/SendSIGHUP=yes/SendSIGHUP=yes\nTimeoutSec=240/' /etc/systemd/system/getty.target.wants/getty\@tty1.service

# Remove debconf internationalization for debconf
dpkg --remove debconf-i18n

# apt-get then cleanup
apt-get update

# Install packages here
apt-get install "$@" || exit $? 

./clean_chroot.sh

# Remove chroot script
rm config_chroot.sh

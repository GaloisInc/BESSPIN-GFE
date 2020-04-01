#!/usr/bin/env bash
set -e

# This script runs inside the chroot after basic setup is complete.  You can
# customize it to change the set of packages installed or to set up custom
# configuration files.

debian_dir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
setup_scripts_dir="${debian_dir}/setup_scripts"

# NOTE: not excluding docs, because the script fails to build as such
# As a result we have a larger binary that might not fit into flash
#"${setup_scripts_dir}/exclude_docs.sh"
echo "Skipping exclude_docs.sh - this might lead to a larger binary"
"${setup_scripts_dir}/install_important.sh"

# Install an init system.
if [ -n "$SET_SYSVINIT" ]; then
    echo "using sysvinit as init script"
    "${setup_scripts_dir}/install_sysvinit.sh"
else
    echo "using systemd as init script"
    "${setup_scripts_dir}/install_systemd.sh"
fi

# Common setup

# Set root password
yes riscv | passwd

# Modify network configuration
echo "
# # Use DHCP to automatically configure eth1
# auto eth1
# allow-hotplug eth1
# iface eth1 inet dhcp

# Use static IP on the on-board interface
auto eth1
allow-hotplug eth1
iface eth1 inet static
    address 10.88.88.2
    netmask 255.255.255.0
    gateway 10.88.88.1
    broadcast 10.88.88.255
" >> /etc/network/interfaces


if [ -n "$EXTRA_SETUP" ]; then
    echo "running extra setup script: $EXTRA_SETUP"
    "$EXTRA_SETUP"
fi

# Remove debconf internationalization for debconf
dpkg --remove debconf-i18n

# apt-get then cleanup
apt-get update
apt-get autoremove -y
apt-get clean
rm -f /var/lib/apt/lists/*debian*

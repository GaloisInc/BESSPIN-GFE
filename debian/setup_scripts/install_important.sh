#!/usr/bin/env bash
set -e

# Install all packages marked "Priority: important".  This mimics the default
# behavior of `mmdebstrap`.  The "important" set contains systemd and some
# other basic packages.
apt-cache dumpavail | \
    awk '/^Package: / { pkg = $2; } /^Priority: important/ { print pkg; }' |
    xargs apt-get install -y --no-install-recommends

#netcat is needed to communicated with the OS after booting. Used for both qemu and fpga.
#keyutils is needed for some of the Permission, Privileges and Access Control tests.
#In case we needed a debian snapshot: Everything was working on 09/19/19 .
apt-get install -y netcat
apt-get install -y keyutils

# for lcpci
apt-get install -y pciutils

# for remote access
apt-get install -y openssh-server
# enable root login
echo "PermitRootLogin yes" >>> /etc/ssh/sshd_config

# for lsusb
apt install -y usbutils

# (not needed yet) set of tools for manipulating NVMe drives
# apt-get install -y nvme-cli
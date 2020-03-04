#!/bin/bash
# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host, from the repo root dir.
set -eux

# For riscv-linux build:
apt install -y curl openssl bc bison flex make autoconf debootstrap proot libssl-dev debian-ports-archive-keyring device-tree-compiler

# RTL simulator and RISC-V emulator:
apt install -y verilator qemu qemu-user qemu-system-misc

# Needed for GDB
apt install -y libpython2.7

# Needed for manual tests
apt install -y minicom

# System-wide python packages needed by testing scripts
apt install -y python3-pip
pip3 install pyserial pexpect

# Xilinx vivado_lab dependency
apt install -y libtinfo5

# Clang and LLVM for RISC-V:
wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
add-apt-repository 'deb http://apt.llvm.org/buster/ llvm-toolchain-buster main'
apt-get update
apt-get install -y clang-11 lldb-11 lld-11 clangd-11

# Set llvm symlinks and variables
ln -s /usr/bin/clang-11 /usr/bin/clang
ln -s /usr/bin/llvm-objcopy-11 llvm-objcopy
ln -s /usr/bin/llvm-objdump-11 llvm-objdump
ln -s /usr/bin/llvm-ar-11 llvm-ar
ln -s /usr/bin/llvm-ranlib-11 llvm-ranlib

# Instal dependencies for FreeBSD
apt install -y libtool pkg-config bison cmake ninja-build samba flex texinfo libarchive-dev
apt install -y libglib2.0-dev libpixman-1-dev libarchive-dev bsdtar libbz2-dev

# Install and configure TFTP server
apt install -y atftpd
chmod 777 /srv/tftp

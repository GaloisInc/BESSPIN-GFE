#!/bin/bash
# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host, from the repo root dir.
set -eux

# For riscv-linux build:
apt install -y curl openssl bc bison flex make autoconf debootstrap proot libssl-dev debian-ports-archive-keyring

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
apt-get install -y clang-10 lldb-10 lld-10 clangd-10
# TODO: set up a symlink
ln -s /usr/bin/clang-10 /usr/bin/clang

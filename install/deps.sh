#!/bin/bash
# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host, from the repo root dir.

set -eux

# Vivado Lab 2017.4 needs an old version of libtinfo:
apt-get install -y libtinfo5
# It may also need debug cable drivers and a udev rule:
cd /opt/Xilinx/Vivado_Lab/2017.4/data/xicom/cable_drivers/lin64/install_script/install_drivers/
./install_drivers
cd -

# For riscv-linux build:
apt-get install -y openssl bc bison flex make autoconf debootstrap proot

# RTL simulator and RISC-V emulator:
apt-get install -y verilator qemu qemu-user

# System-wide python packages needed by testing scripts
apt-get install -y python3-pip
pip3 install pyserial pexpect

# TODO: Clang and LLVM for RISC-V:
# wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
# add-apt-repository 'http://apt.llvm.org/buster/ llvm-toolchain-buster-9 main'
# apt-get update
# XXX 2019-10-07 the install below fails with some weird 'unmet dependencies'
# See https://bugs.llvm.org/show_bug.cgi?id=43451
# Restore when LLVM 9 packages are working again:
# apt-get install -y clang-9 lldb-9 lld-9 clangd-9

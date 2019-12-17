#!/bin/bash
# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host, from the repo root dir.

set -eux

# For riscv-linux build:
apt install -y openssl bc bison flex make autoconf debootstrap proot libssl-dev debian-ports-archive-keyring

# RTL simulator and RISC-V emulator:
apt install -y verilator qemu qemu-user qemu-system-misc

# Needed for GDB
apt install -y libpython2.7

# System-wide python packages needed by testing scripts
apt install -y python3-pip
pip3 install pyserial pexpect

# Xilinx vivado_lab dependency
apt install -y libtinfo5

# TODO: Clang and LLVM for RISC-V:
# wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
# add-apt-repository 'http://apt.llvm.org/buster/ llvm-toolchain-buster-9 main'
# apt-get update
# XXX 2019-10-07 the install below fails with some weird 'unmet dependencies'
# See https://bugs.llvm.org/show_bug.cgi?id=43451
# Restore when LLVM 9 packages are working again:
# apt-get install -y clang-9 lldb-9 lld-9 clangd-9

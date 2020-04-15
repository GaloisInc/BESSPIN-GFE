#! /bin/bash
# Build a GFE-specific version of OpenOCD
# and install it in /usr/local/bin
set -eux

cd riscv-openocd
./bootstrap
./configure --enable-remote-bitbang --enable-jtag_vpi --enable-ftdi
make
make install
cd -

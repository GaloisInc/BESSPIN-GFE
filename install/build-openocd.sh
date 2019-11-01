#! /bin/bash
# Build a GFE-specific version of OpenOCD
# and install it in /usr/local/bin
set -eux

apt-get install -y libftdi1-2 libusb-1.0-0-dev libtool pkg-config texinfo
cd riscv-openocd
./bootstrap
./configure --enable-remote-bitbang --enable-jtag_vpi --enable-ftdi
make
make install
cd -

# Compile and archive both linux and newlib versions of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.

set -eux

# WARNING: it wipes out any existing /opt/riscv directory,
# so you may want to back that up before running this!
rm -rf /opt/riscv/

# System packages needed for the build:
apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

git clone --recursive https://github.com/riscv/riscv-gnu-toolchain
cd riscv-gnu-toolchain
# Snapshot of master on 2019-10-1 -- update as needed
git checkout 2855d82
source configure --prefix /opt/riscv --enable-multilib
make linux
make

tar -czf riscv-gnu-toolchains.tar.gz /opt/riscv

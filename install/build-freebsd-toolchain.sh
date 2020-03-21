# Compile and archive both linux and newlib versions of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.

set -eux

# Avoid overwriting any existing /opt/riscv directory
if [ -d /opt/riscv ]; then
    mv /opt/riscv /opt/riscv.old
fi

# System packages needed for the build:
apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

if [ ! -d riscv-gnu-toolchain-freebsd ]; then
    git clone git@github.com:freebsd-riscv/riscv-gnu-toolchain.git riscv-gnu-toolchain-freebsd
fi

cd riscv-gnu-toolchain-freebsd
git checkout master
git clean -f
make clean
rm -f Makefile
git pull

# Snapshot of master on 2019-10-10 -- update as needed
git checkout 1505830a3b757b3e65c15147388dd1a91ee2c786
git submodule update --init --recursive
./configure --prefix /opt/riscv
make freebsd
cd ..

#tar -czf riscv-gnu-toolchains.tar.gz /opt/riscv

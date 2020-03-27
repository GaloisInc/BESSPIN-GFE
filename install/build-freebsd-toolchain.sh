# Compile and archive both linux and newlib versions of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.

set -eux

# Avoid overwriting any existing /opt/riscv directory
if [ -d /opt/riscv ]; then
    mv -f /opt/riscv /opt/riscv.old
fi

# System packages needed for the build:
apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

if [ ! -d riscv-gnu-toolchain-freebsd ]; then
    git clone https://github.com/riscv/riscv-gnu-toolchain.git riscv-gnu-toolchain-freebsd
fi

cd riscv-gnu-toolchain-freebsd
git checkout master
git clean -f
git pull

# Snapshot of master on 2019-10-10 -- update as needed
git checkout d8243f7f81140bc732b91b7e02c45f425b204191
git submodule update --init --recursive
./configure --prefix /opt/riscv
make freebsd
cd ..

#tar -czf riscv-gnu-toolchains.tar.gz /opt/riscv

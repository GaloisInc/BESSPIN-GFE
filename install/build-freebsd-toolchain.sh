# Compile and archive both linux and newlib versions of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.

set -eux

OSREL=12.1
SYSROOT=''

# Avoid overwriting any existing /opt/riscv directory
if [ -d /opt/riscv ]; then
    mv -f /opt/riscv /opt/riscv.old
fi

# System packages needed for the build:
apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

# Clone the repo, name it different from standard riscv-gnu-toolchain
if [ ! -d riscv-gnu-toolchain-freebsd ]; then
    git clone https://github.com/freebsd-riscv/riscv-gnu-toolchain.git riscv-gnu-toolchain-freebsd
fi
cd riscv-gnu-toolchain-freebsd

git checkout master
git clean -f
git pull

# Snapshot of master on 2020-3-26 -- update as needed
git checkout 1505830a3b757b3e65c15147388dd1a91ee2c786
git submodule update --init --recursive

# Configure and Make
./configure --prefix /opt/riscv 
make clean
make freebsd OSREL=$OSREL #SYSROOT=$SYSROOT
cd ..


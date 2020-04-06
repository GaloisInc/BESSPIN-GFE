# Compile and archive both linux and newlib versions of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.

set -eux

# Expected to run from the root of the repository
if [ `basename $PWD` != "gfe" ]
then
    echo "Error! Must run this script from the root directory of the GFE repository!"
    exit 1
fi

# Avoid overwriting any existing /opt/riscv directory
if [ -d /opt/riscv ]; then
    mv /opt/riscv /opt/riscv.old
fi

# System packages needed for the build:
apt-get install -y autoconf automake autotools-dev curl libmpc-dev libmpfr-dev libgmp-dev gawk build-essential bison flex texinfo gperf libtool patchutils bc zlib1g-dev libexpat-dev

echo "Bulding GNU toolchain"
if [ ! -d riscv-gnu-toolchain ]; then
    git clone https://github.com/riscv/riscv-gnu-toolchain
fi
cd riscv-gnu-toolchain
git clean -f
rm -f Makefile
git pull
# Snapshot of master on 2019-10-10 -- update as needed
git checkout d5bea51083ec38172b84b7cd5ee99bfcb8d2e7b0
git submodule update --init --recursive
./configure --prefix /opt/riscv --enable-multilib --with-cmodel=medany
make linux
make
cd ..
echo "GNU toolchain built!"

# Avoid overwriting any existing /opt/riscv directory
if [ -d /opt/riscv-freebsd ]; then
    mv -f /opt/riscv-freebsd /opt/riscv-freebsd.old
fi

# Create FreeBSD Sysroot (world directory)
echo "Bulding FreeBSD sysroot"
cd freebsd
make clean
make
cd ..
SYSROOT=`realpath freebsd/world`
OSREL=12.1
echo "SYSROOT=$SYSROOT, OSREL=$OSREL"

echo "Bulding FreeBSD toolchain"
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
./configure --prefix /opt/riscv-freebsd
make clean
make freebsd OSREL=$OSREL SYSROOT=$SYSROOT
cd ..
echo "FreeBSD toolchain built!"

tar -czf riscv-gnu-toolchains.tar.gz /opt/riscv /opt/riscv-freebsd

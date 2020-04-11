# Compile and archive freebsd version of
# riscv-gnu-toolchain on Debian 10.1
# This should be run with sudo, and takes several hours to complete.
# Assume we start in gfe/install dir
set -eux

FREEBSD_DIR=/opt/riscv-freebsd

# Avoid overwriting any existing /opt/riscv-freebsd directory
if [ -d $FREEBSD_DIR ]; then
    mv -f $FREEBSD_DIR $FREEBSD_DIR.old
fi

# Create FreeBSD Sysroot (world directory)
echo "Bulding FreeBSD sysroot"
cd ../freebsd
make clean
TOOLCHAIN= make $PWD/world

cd ../install
SYSROOT=$FREEBSD_DIR/sysroot
OSREL=12.1
echo "SYSROOT=$SYSROOT, OSREL=$OSREL"

# Copy sysroot
mkdir -p $SYSROOT/usr
cp -r ../freebsd/world/usr/lib ../freebsd/world/usr/include $SYSROOT/usr

echo "Bulding FreeBSD toolchain"
# Clone the repo, name it different from standard riscv-gnu-toolchain
if [ ! -d /tmp/riscv-gnu-toolchain-freebsd ]; then
    git clone https://github.com/freebsd-riscv/riscv-gnu-toolchain.git /tmp/riscv-gnu-toolchain-freebsd
fi
cd /tmp/riscv-gnu-toolchain-freebsd

git checkout master
git clean -f
git pull

# Snapshot of master on 2020-3-26 -- update as needed
git checkout 1505830a3b757b3e65c15147388dd1a91ee2c786
git submodule update --init --recursive

# Configure and Make
./configure --prefix $FREEBSD_DIR
make clean
make freebsd OSREL=$OSREL SYSROOT=$SYSROOT
cd ..
echo "FreeBSD toolchain built!"

# Cleanup
rm -rf /tmp/riscv-gnu-toolchain-freebsd
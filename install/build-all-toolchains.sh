# Compile and package all GFE toolchains
set -eux

./build-toolchain.sh
./build-llvm.sh
./build-freebsd-toolchain.sh

echo "Archiving toolchains"
tar -czf riscv-gnu-toolchains.tar.gz /opt/riscv /opt/riscv-llvm /opt/riscv/riscv-freebsd
echo "Building toolchains done"
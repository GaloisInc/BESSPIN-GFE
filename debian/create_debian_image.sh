#!/usr/bin/env bash

# Get the path to debian directory script is being run from 
DEBIAN_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null && pwd )"
GFE_REPO="$(dirname "$DEBIAN_DIR")"

# Check for necessary commands 
array=( "riscv64-unknown-linux-gnu-gcc" )
for i in "${array[@]}"
do
    command -v $i >/dev/null 2>&1 || { 
        echo >&2 "$i required"; 
        exit 1; 
    }
done

cd $GFE_REPO/riscv-linux
make mrproper

echo "Building kernel..."
# Build kernel
cd $GFE_REPO/bootmem
make build-linux/vmlinux

echo "Kernel built"

# Build BBL (Berkeley Boot Loader)
cd $GFE_REPO/riscv-tools/riscv-pk
if [ -d $GFE_REPO/riscv-tools/riscv-pk/build ]; then
	rm -r build
fi
mkdir build
cd build
../configure --prefix=/tmp --host=riscv64-unknown-linux-gnu --with-payload=$GFE_REPO/bootmem/build-linux/vmlinux
echo "Building BBL..."
make || exit $?

echo "BBL built"

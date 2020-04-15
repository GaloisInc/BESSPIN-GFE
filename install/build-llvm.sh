# Compile and archive LLVM
# This should be run with sudo, and takes couple of minutes to compile, depending on the machine
set -eux

BASEDIR=/opt/riscv-llvm

# Avoid overwriting any existing /opt/riscv directory
if [ -d $BASEDIR ]; then
    mv $BASEDIR $BASEDIR.old
fi

# Compile LLVM
rm -rf $BASEDIR/llvm-project
git clone https://github.com/llvm/llvm-project.git $BASEDIR/llvm-project

cd $BASEDIR/llvm-project
git clean -f
git pull

# Snapshot of master on 2020-4-10 -- update as needed
git checkout 49e20c4c9efe1c0e74f9c0dc224a8014b93faa3c
mkdir -p build
cd build
cmake -G Ninja \
    -DCMAKE_BUILD_TYPE=Release \
    -DLLVM_OPTIMIZED_TABLEGEN=OFF \
    -DLLVM_ENABLE_ASSERTIONS=ON \
    -DCLANG_DEFAULT_RTLIB=compiler-rt  \
    -DLLVM_ENABLE_PROJECTS="llvm;clang;lld" \
    ../llvm
cmake --build .

# Update PATH, the compiled binaries are now in `bin` folder
export PATH=$BASEDIR/llvm-project/build/bin:$PATH
LLVM_BIN_PATH=$BASEDIR/llvm-project/build/bin

# Compile newlib
rm -rf /tmp/riscv-newlib
git clone https://github.com/riscv/riscv-newlib.git /tmp/riscv-newlib

cd /tmp/riscv-newlib
# Release 3.2.0
git checkout f289cef6be67da67b2d97a47d6576fa7e6b4c858
mkdir build32
cd build32
../configure \
    CC_FOR_TARGET=clang \
    CFLAGS_FOR_TARGET="-target riscv32-unknown-elf -march=rv32im -mabi=ilp32 -mcmodel=medany -mno-relax -g -O2" \
    AR_FOR_TARGET=llvm-ar \
    RANLIB_FOR_TARGET=llvm-ranlib \
    --target=riscv32-unknown-elf \
    --with-newlib \
    --disable-libgloss \
    --prefix=$BASEDIR
make -j6
make install 

cd /tmp/riscv-newlib
mkdir build64
cd build64
../configure \
    CC_FOR_TARGET=clang \
    CFLAGS_FOR_TARGET="-target riscv64-unknown-elf -march=rv64imac -mabi=lp64 -mcmodel=medany -mno-relax -g -O2" \
    AR_FOR_TARGET=llvm-ar \
    RANLIB_FOR_TARGET=llvm-ranlib \
    --target=riscv64-unknown-elf \
    --with-newlib \
    --disable-libgloss \
    --prefix=$BASEDIR
make -j6
make install

# Compile compiler-rt
# rt64
cd $BASEDIR/llvm-project
mkdir build64-c_rt
cd build64-c_rt
cmake -G Ninja \
    -DCMAKE_C_COMPILER=$LLVM_BIN_PATH/clang \
    -DCMAKE_AR=$LLVM_BIN_PATH/llvm-ar \
    -DCMAKE_NM=$LLVM_BIN_PATH/llvm-nm \
    -DCMAKE_RANLIB=$LLVM_BIN_PATH/llvm-ranlib \
    -DLLVM_CONFIG_PATH=$LLVM_BIN_PATH/llvm-config \
    -DCMAKE_C_FLAGS="-target riscv64-unknown-elf -march=rv64imac -mabi=lp64 -mcmodel=medany -mno-relax" \
    -DCMAKE_CXX_FLAGS="-target riscv64-unknown-elf -march=rv64imac -mabi=lp64 -mcmodel=medany -mno-relax" \
    -DCMAKE_ASM_FLAGS="-target riscv64-unknown-elf -march=rv64imac -mabi=lp64 -mcmodel=medany -mno-relax" \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DCMAKE_SYSROOT=$BASEDIR/riscv64-unknown-elf \
    -DCOMPILER_RT_DEFAULT_TARGET_ARCH=riscv64 \
    -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=riscv64-unknown-elf \
    -DCOMPILER_RT_OS_DIR=baremetal \
    -DCOMPILER_RT_BAREMETAL_BUILD=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    ../compiler-rt
cmake --build .
# Copy library to sysroot
cp lib/baremetal/libclang_rt.builtins-riscv64.a $BASEDIR/riscv64-unknown-elf/lib/.

# rt32
cd $BASEDIR/llvm-project
mkdir build32-c_rt
cd build32-c_rt
cmake -G Ninja \
    -DCMAKE_C_COMPILER=$LLVM_BIN_PATH/clang \
    -DCMAKE_AR=$LLVM_BIN_PATH/llvm-ar \
    -DCMAKE_NM=$LLVM_BIN_PATH/llvm-nm \
    -DCMAKE_RANLIB=$LLVM_BIN_PATH/llvm-ranlib \
    -DLLVM_CONFIG_PATH=$LLVM_BIN_PATH/llvm-config \
    -DCMAKE_C_FLAGS="-target riscv32-unknown-elf -march=rv32im -mabi=ilp32 -mcmodel=medany -mno-relax" \
    -DCMAKE_CXX_FLAGS="-target riscv32-unknown-elf -march=rv32im -mabi=ilp32 -mcmodel=medany -mno-relax" \
    -DCMAKE_ASM_FLAGS="-target riscv32-unknown-elf -march=rv32im -mabi=ilp32 -mcmodel=medany -mno-relax" \
    -DCMAKE_TRY_COMPILE_TARGET_TYPE=STATIC_LIBRARY \
    -DCMAKE_SYSROOT=/opt/riscv-llvm/riscv32-unknown-elf \
    -DCOMPILER_RT_DEFAULT_TARGET_ARCH=riscv32 \
    -DCOMPILER_RT_DEFAULT_TARGET_TRIPLE=riscv32-unknown-elf \
    -DCOMPILER_RT_OS_DIR=baremetal \
    -DCOMPILER_RT_BAREMETAL_BUILD=ON \
    -DCOMPILER_RT_BUILD_SANITIZERS=OFF \
    -DCOMPILER_RT_BUILD_XRAY=OFF \
    -DCOMPILER_RT_BUILD_LIBFUZZER=OFF \
    -DCOMPILER_RT_BUILD_PROFILE=OFF \
    ../compiler-rt
cmake --build .
cp lib/baremetal/libclang_rt.builtins-riscv32.a $BASEDIR/riscv32-unknown-elf/lib/.

# Cleanup
rm -rf $BASEDIR/llvm-project/.git
rm -rf /tmp/riscv-newlib
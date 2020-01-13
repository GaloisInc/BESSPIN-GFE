#!/usr/bin/env bash

home=$(pwd)

# Initialize the minimum number of submodules necessary to build the project
# This reduces the runtime of git status and other git commands
git submodule sync

git submodule update --init benchmarks/coremark

git submodule update --init riscv-openocd

git submodule update --init riscv-tests
cd riscv-tests
git submodule sync
cd ..

git submodule update --init FreeRTOS-mirror busybox newlib
git submodule update --init --recursive \
bluespec-processors/P1/Piccolo bluespec-processors/P2/Flute \
riscv-linux bluespec-processors/P3/Toooba riscv-tests riscv-pk

cd $home

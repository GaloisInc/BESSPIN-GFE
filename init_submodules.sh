#!/usr/bin/env bash

home=$(pwd)

# Initialize the minimum number of submodules necessary to build the project
# This reduces the runtime of git status and other git commands
git submodule sync

git submodule update --init riscv-tests
cd riscv-tests
git submodule sync
cd ..

git submodule update --init --recursive \
FreeRTOS-mirror bluespec-processors/P1/Piccolo bluespec-processors/P2/Flute busybox \
riscv-linux bluespec-processors/P3/Tuba riscv-tests riscv-pk
git submodule update --init chisel_processors

cd chisel_processors
git submodule sync
git submodule update --init rocket-chip
git submodule update --init P3/boom-template
cd P3/boom-template
git submodule sync
git submodule update --init boom rocket-chip
cd rocket-chip
git submodule sync
git submodule update --init firrtl chisel3 hardfloat
cd ../../../rocket-chip
git submodule sync
git submodule update --init firrtl chisel3 hardfloat

#!/usr/bin/env bash

home=$(pwd)

# Initialize the minimum number of submodules necessary to build the project
# This reduces the runtime of git status and other git commands
git submodule sync

git submodule update --init benchmarks/coremark
git submodule update --init benchmarks/mibench2
git submodule update --init riscv-openocd

git submodule update --init riscv-tests
cd riscv-tests
git submodule sync
cd ..

git submodule update --init FreeRTOS-mirror
git submodule update --init busybox
git submodule update --init --recursive \
bluespec-processors/P1/Piccolo
git submodule update --init --recursive \
bluespec-processors/P2/Flute
git submodule update --init --recursive \
bluespec-processors/P3/Toooba
git submodule update --init --recursive \
riscv-linux
git submodule update --init --recursive \
riscv-tests
git submodule update --init --recursive \
riscv-pk
git submodule update --init chisel_processors
git submodule update --init freebsd/cheribsd


cd chisel_processors
git submodule sync
git submodule update --init rocket-chip
git submodule update --init chipyard
cd rocket-chip
git submodule sync
git submodule update --init firrtl chisel3 hardfloat

cd $home

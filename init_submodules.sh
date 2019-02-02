#!/usr/bin/env bash

home=$(pwd)

# Initialize the minimum number of submodules necessary to build the project
# This reduces the runtime of git status and other git commands
git submodule update --init --recursive riscv-tools \
FreeRTOS-RISCV bluespec-processors/P1/Piccolo
git submodule update --init chisel_processors

cd chisel_processors
git submodule update --init P1/rocket-chip
cd P1/rocket-chip
git submodule update --init firrtl chisel3 hardfloat

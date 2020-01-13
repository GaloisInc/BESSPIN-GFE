#! /bin/bash
set -eux
# Make vivado_lab and riscv gnu toolchains available to all users:
echo 'export PATH=/opt/Xilinx/Vivado_Lab/2019.1/bin:$PATH' | tee -a /etc/bash.bashrc
echo 'export PATH=/opt/riscv/bin:$PATH' | tee -a /etc/bash.bashrc
echo 'export RISCV=/opt/riscv' | tee -a /etc/bash.bashrc

# Set up RISCV_C_INCLUDE_PATH for Clang compilation
echo 'export RISCV_C_INCLUDE_PATH=/opt/riscv/riscv64-unknown-elf/include' | tee -a /etc/bash.bashrc

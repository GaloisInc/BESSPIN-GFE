#! /bin/bash
set -eux
# Make vivado_lab and riscv gnu toolchains available to all users:
echo 'export PATH=/opt/Xilinx/Vivado_Lab/2019.1/bin:$PATH' | tee -a /etc/bash.bashrc
echo 'export PATH=/opt/riscv/bin:$PATH' | tee -a /etc/bash.bashrc
echo 'export RISCV=/opt/riscv' | tee -a /etc/bash.bashrc


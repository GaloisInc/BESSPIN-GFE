# This script installs GFE dependencies on Debian 10.
# It should only be run as root, once per host, from the repo root dir.

set -eux

# Vivado Lab 2017.4 needs an old version of libtinfo:
apt-get install -y libtinfo5
# It may also need debug cable drivers and a udev rule:
cd /opt/Xilinx/Vivado_Lab/2017.4/data/xicom/cable_drivers/lin64/install_script/install_drivers/
./install_drivers
cd -
# Make vivado_lab available to all users:
echo 'source /opt/Xilinx/Vivado_Lab/2017.4/settings64.sh' | tee -a /etc/bash.bashrc

# For riscv-linux build:
apt-get install -y openssl bc bison flex make autoconf debootstrap proot

# RTL simulator and RISC-V emulator:
apt-get install -y verilator qemu qemu-user

# System-wide python packages needed by testing scripts
apt-get install -y python3-pip
pip3 install pyserial pexpect

# OpenOCD
apt-get install -y libftdi1-2 libusb-1.0-0-dev libtool pkg-config texinfo
cd riscv-openocd
./bootstrap
./configure --enable-remote-bitbang --enable-jtag_vpi --enable-ftdi
make
make install
cd -
# TODO: maybe provide a pre-built binary instead of the submodule?


# RISC-V toolchains (both linux and newlib versions):

# Google Drive download adapted from
# https://www.matthuisman.nz/2019/01/download-google-drive-files-wget-curl.html
fileid='1aw2VKZG05-Pa2q57T4Z7ffJG_qe9-h2I'
filename='riscv-gnu-toolchains.tar.gz'
tmp_file="$filename.$$.file"
tmp_cookies="$filename.$$.cookies"
tmp_headers="$filename.$$.headers"
url='https://docs.google.com/uc?export=download&id='$fileid
echo Downloading confirmation cookie...
wget --save-cookies "$tmp_cookies" -q -S -O - $url 2> "$tmp_headers" 1> "$tmp_file"
if [[ ! $(find "$tmp_file" -type f -size +10000c 2>/dev/null) ]]; then
   confirm=$(cat "$tmp_file" | sed -rn 's/.*confirm=([0-9A-Za-z_]+).*/\1/p')
fi
if [ ! -z "$confirm" ]; then
   url='https://docs.google.com/uc?export=download&id='$fileid'&confirm='$confirm
   echo Downloading file: $url
   wget --load-cookies "$tmp_cookies" -q -S -O - $url 2> "$tmp_headers" 1> "$tmp_file"
fi
mv "$tmp_file" "install/$filename"
rm -f "$tmp_cookies" "$tmp_headers"
echo Saved: "install/$filename"
# Unpack into /opt/riscv/ -- not automated here
# tar -C / -xf "install/$filename"

# Make these available to all users:
echo 'export RISCV=/opt/riscv' | tee -a /etc/bash.bashrc
echo 'export PATH=/opt/riscv/bin:$PATH' | tee -a /etc/bash.bashrc


# TODO: Clang and LLVM for RISC-V:
# wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
# add-apt-repository 'http://apt.llvm.org/buster/ llvm-toolchain-buster-9 main'
# apt-get update
# XXX 2019-10-07 the install below fails with some weird 'unmet dependencies'
# See https://bugs.llvm.org/show_bug.cgi?id=43451
# Restore when LLVM 9 packages are working again:
# apt-get install -y clang-9 lldb-9 lld-9 clangd-9

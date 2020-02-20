FROM debian:10

# Enable HTTPS support in wget and set nsswitch.conf to make resolution work within containers
RUN apt-get update
RUN apt-get install -y ssh openssl ca-certificates  \
  && echo hosts: dns files > /etc/nsswitch.conf

# make sure your domain is accepted
RUN mkdir -p /root/.ssh/ && touch /root/.ssh/known_hosts
RUN ssh-keyscan github.com >> /root/.ssh/known_hosts

RUN apt-get install -y git
RUN apt-get install -y software-properties-common wget
RUN apt-get install -y gnupg
RUN apt-get install -y vim

# Install dependencies

# For riscv-linux build:
RUN apt install -y curl openssl bc bison flex make autoconf debootstrap proot libssl-dev debian-ports-archive-keyring

# RTL simulator and RISC-V emulator:
RUN apt install -y verilator qemu qemu-user qemu-system-misc

# Needed for GDB
RUN apt install -y libpython2.7

# Needed for manual tests
RUN apt install -y minicom

# System-wide python packages needed by testing scripts
RUN apt install -y python3-pip
RUN pip3 install pyserial pexpect

# Xilinx vivado_lab dependency
RUN apt install -y libtinfo5

# Clang and LLVM for RISC-V:
RUN wget -O - https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -
RUN add-apt-repository 'deb http://apt.llvm.org/buster/ llvm-toolchain-buster main'
RUN apt-get update
RUN apt-get install -y clang-11 lldb-11 lld-11 clangd-11

# Set llvm symlinks and variables
RUN ln -s /usr/bin/clang-11 /usr/bin/clang
RUN ln -s /usr/bin/llvm-objcopy-11 llvm-objcopy
RUN ln -s /usr/bin/llvm-objdump-11 llvm-objdump
RUN ln -s /usr/bin/llvm-ar-11 llvm-ar
RUN ln -s /usr/bin/llvm-ranlib-11 llvm-ranlib

# Instal dependencies for FreeBSD
RUN apt install -y libtool pkg-config bison cmake ninja-build samba flex texinfo libarchive-dev
RUN apt install -y libglib2.0-dev libpixman-1-dev libarchive-dev bsdtar libbz2-dev

# RISC-V toolchains (both linux and newlib versions):
# Set PATH for RISCV-tools and LLVM Sysroot
ADD riscv-gnu-toolchains.tar.gz /
ENV RISCV="/opt/riscv"
ENV PATH="/opt/riscv/bin:${PATH}"
ENV RISCV_C_INCLUDE_PATH="/opt/riscv/riscv64-unknown-elf/include"

# OpenOCD dependencies
RUN apt-get install -y libftdi1-2 libusb-1.0-0-dev libtool pkg-config texinfo

WORKDIR /gfe


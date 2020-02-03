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
RUN apt-get install -y openssl bc bison flex make autoconf proot debootstrap

# RTL simulator and RISC-V emulator:
RUN apt-get install -y verilator qemu qemu-user

# System-wide python packages needed by testing scripts
RUN apt-get install -y python3-pip
RUN pip3 install pyserial pexpect

# Clang and LLVM for RISC-V:
RUN wget https://apt.llvm.org/llvm.sh
RUN chmod +x llvm.sh
RUN ./llvm.sh 9
RUN rm llvm.sh

# Set llvm symlinks and variables
RUN cd /usr/bin && ln -s clang-9 clang
RUN cd /usr/bin && ln -s llvm-objcopy-9 llvm-objcopy
RUN cd /usr/bin && ln -s llvm-objdump-9 llvm-objdump
RUN cd /usr/bin && ln -s llvm-ar-9 llvm-ar
RUN cd /usr/bin && ln -s llvm-ranlib-9 llvm-ranlib

# RISC-V toolchains (both linux and newlib versions):
# Set PATH for RISCV-tools and LLVM Sysroot
ADD riscv-gnu-toolchains.tar.gz /
ENV RISCV="/opt/riscv"
ENV PATH="/opt/riscv/bin:${PATH}"
ENV RISCV_C_INCLUDE_PATH="/opt/riscv/riscv64-unknown-elf/include"

# OpenOCD dependencies
RUN apt-get install -y libftdi1-2 libusb-1.0-0-dev libtool pkg-config texinfo

WORKDIR /gfe


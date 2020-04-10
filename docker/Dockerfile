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
ADD deps.sh /tmp
RUN /tmp/deps.sh

# Build toolchains

# Set PATH

# Clean up...


# # RISC-V toolchains (both linux and newlib versions):
# # Set PATH for RISCV-tools and LLVM Sysroot
# #ADD riscv-gnu-toolchains.tar.gz /opt
# #ENV RISCV="/opt/riscv"
# #ENV PATH="/opt/riscv/bin:/opt/riscv-freebsd/bin:${PATH}"
# #ENV RISCV_C_INCLUDE_PATH="/opt/riscv/riscv64-unknown-elf/include"

WORKDIR /gfe


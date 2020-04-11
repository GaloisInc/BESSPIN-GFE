# Define certain global variables
CROSS_COMPILE?=riscv64-unknown-linux-gnu-
MKDIR?=mkdir
CP?=cp
CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

# For Busybox build
BUSYBOX_CONFIG?=$(CURDIR)/busybox.config
LINUX_CONFIG?=$(CURDIR)/linux.config

# Debian build
DEBIAN_CONFIG?=$(CURDIR)/debian-linux.config
BUSYBOX_PREFIX=$(CURDIR)/_install
CPIO_UTILS_PREFIX=$(CURDIR)/build-cpio-utils/
# change to DEBIAN_TARGET=debian-network for rootfs served over ethernet
DEBIAN_TARGET?=debian

# "DEBIAN_TARGET?=debian" Builds traditional debian executable
# i.e. everything is packed in single bbl executable

# "DEBIAN_TARGET=debian-network" Builds smaller network-based debian executable
# Uses a minimal chainloader bbl, and then servers the cpio
# archive over network

# Chainloader build
CHAINLOADER_CONFIG=$(CURDIR)/chainloader-linux.config

$(info DEBIAN_TARGET=$(DEBIAN_TARGET))
$(info LINUX_CONFIG=$(LINUX_CONFIG))
$(info CHAINLOADER_CONFIG=$(CHAINLOADER_CONFIG))
$(info DEBIAN_CONFIG=$(DEBIAN_CONFIG))

# Build and source directories
LINUX_SRC=../riscv-linux
BUSYBOX_SRC=../busybox
BBL_SRC=../../riscv-pk
DEBIAN_DIR=../debian
OUT_DIR=$(CURDIR)/virtfs

# Export variables
export CROSS_COMPILE CPIO_UTILS_PREFIX BUSYBOX_PREFIX

# For faster builds, use all available cores
UNAME = $(shell uname -s)
NPROCS:=1
ifeq ($(UNAME),Linux)
        NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(UNAME),Darwin)
        NPROCS := $(shell sysctl hw.ncpu | awk '{print $$2}')
endif
# Limit NPROCS to 8 so qemu can handle it
QEMU_NPROCS:=$(shell echo $$(($(NPROCS)>8 ? 8 : $(NPROCS))))

###################################
#                                 #
#         PUBLIC TARGETS          #
#                                 #
###################################
default: busybox
busybox: build-busybox-bbl/bbl.asm bootmem-busybox.bin
debian: build-$(DEBIAN_TARGET)-bbl/bbl.asm bootmem-$(DEBIAN_TARGET).bin
clean: clean-busybox clean-debian

.PHONY: default debian clean-debian clean

###################################
#                                 #
#        GENERAL TARGETS          #
#                                 #
###################################
# Provide dissassembly for manual inspection
%.asm: %
	$(OBJDUMP) -dS $< > $@


###################################
#                                 #
#        BUSYBOX TARGETS          #
#                                 #
###################################
# Busybox config
# Prepares build-busybox directory and copies busybox config
build-busybox/.config: $(BUSYBOX_CONFIG)
	@echo "build-busybox/.config, BUSYBOX_CONFIG=$(BUSYBOX_CONFIG)"
	$(MKDIR) -p $(@D)
	$(MAKE) -C $(BUSYBOX_SRC) O=$(CURDIR)/build-busybox -j$(NPROCS) defconfig
	$(CP) $< $@
	$(MAKE) -C $(@D) -j$(NPROCS) oldconfig
	@echo "build-busybox/.config done"

# Busybox target
# Compiles busybox, creates build-busybox/_install directory
# and build-busybox/busybox_unstripped binary (which we don't really use)
build-busybox/busybox_unstripped: build-busybox/.config
	@echo "build-busybox/busybox_unstripped"
	$(MAKE) -C $(@D) -j$(NPROCS) all
	$(MAKE) -C $(@D) -j$(NPROCS) install
	@echo "build-busybox/busybox_unstripped done"

# Linux kernel
# Statically linked linux kernel executable, has CONFIG_INITRAMFS_SOURCE baked in it
# For busybox, we have `CONFIG_INITRAMFS_SOURCE="../initramfs.files ../_rootfs ../build-busybox/_install"`
# LINUX_CONFIG provides linux kernel configuration, build-busybox/_install provides utility programs
build-linux/vmlinux: $(LINUX_CONFIG) build-busybox/busybox_unstripped
	@echo "Building Linux with config: $$LINUX_CONFIG"
	export KCONFIG_CONFIG=$(LINUX_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-linux olddefconfig
	export KCONFIG_CONFIG=$(LINUX_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-linux $(@F)
	@echo "build-linux/vmlinux done"

# Busybox binary (linux kernel + busybox utils) + bootloader - for loading through GDB
build-busybox-bbl/bbl: build-linux/vmlinux
	@echo "build-busybox-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-linux/vmlinux --enable-zero-bss --with-mem-start=0xC0000000
	$(MAKE) -C $(@D) -j$(NPROCS)
	@echo "build-busybox-bbl/bbl done"

# Intermediate stripped busybox binary + bootloader
bbl-busybox.bin: build-busybox-bbl/bbl
	$(OBJCOPY) -O binary $< $@

# Intermediate ELF file for booting busybox from flash
bootmem-busybox: bootmem.S linker.ld bbl-busybox.bin
	@rm -rf bbl.bin
	@ln -s bbl-busybox.bin bbl.bin
	$(CC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@

# Stripped Binary file for booting busybox from flash
bootmem-busybox.bin: bootmem-busybox
	$(OBJCOPY) -O binary $< $@

# Clean busybox build artifacts
clean-busybox:
	@rm -rf build-linux 
	@rm -rf build-busybox
	@rm -rf build-busybox-bbl
	@rm -f bootmem-busybox bootmem-busybox.bin bbl-busybox.bin
###################################
#                                 #
#    END BUSYBOX TARGETS          #
#                                 #
###################################



###################################
#                                 #
#        DEBIAN TARGETS           #
#                                 #
###################################

# Helper initramfs utils from riscv-linux folder
build-cpio-utils:
	$(MKDIR) -p $(CPIO_UTILS_PREFIX)
	gcc $(LINUX_SRC)/usr/gen_init_cpio.c -o $(CPIO_UTILS_PREFIX)gen_init_cpio
	cp $(LINUX_SRC)/usr/gen_initramfs_list.sh $(CPIO_UTILS_PREFIX)

# Busybox utils
# We are using `_install` folder from busybox build to provide
# some handy tools to the chainloader image
# We store _install in a separate folder, so it is independent of
# the busybox folder
$(BUSYBOX_PREFIX): build-busybox/busybox_unstripped
	cp -r build-busybox/_install _install

# Chainloader initramfs
# contains busybox utils (_install) as well as
# the chainloader-init script (loads )
chainloader-initramfs.cpio.gz: $(BUSYBOX_PREFIX)
	./build_chainloader_initramfs.sh

# Chainloader network initramfs
# contains busybox utils (_install) as well as
# the chainloader-init-network script
chainloader-initramfs-network.cpio.gz: $(BUSYBOX_PREFIX)
	./build_chainloader_initramfs.sh network

# First half of deboostrap stage 1 image
$(DEBIAN_DIR)/riscv64-chroot.tar: $(DEBIAN_DIR)/create_chroot.sh
	@echo "$(DEBIAN_DIR)/riscv64-chroot.tar"
	$(DEBIAN_DIR)/build_stage1_initramfs.sh stage1
	@echo "$(DEBIAN_DIR)/riscv64-chroot.tar done"

# Second half of deboostrap stage 1 image: update only if the stage1-init script changed
$(OUT_DIR)/initramfs.cpio.gz: $(DEBIAN_DIR)/stage1-init $(DEBIAN_DIR)/riscv64-chroot.tar
	@echo "$(OUT_DIR)/initramfs.cpio.gz"
	$(MKDIR) -p $(OUT_DIR)
	$(DEBIAN_DIR)/build_stage1_initramfs.sh
	mv $(DEBIAN_DIR)/stage1-initramfs.cpio.gz $(OUT_DIR)/initramfs.cpio.gz
	@echo "$(OUT_DIR)/initramfs.cpio.gz done"

# Debian startup scripts: always copy over because it is quick
debian-startup-scripts:
	$(MKDIR) -p $(OUT_DIR)/scripts
	cp $(DEBIAN_DIR)/setup_chroot.sh $(OUT_DIR)/scripts/
	cp -r $(DEBIAN_DIR)/setup_scripts $(OUT_DIR)/scripts/

# Kernel arguments for debootstrap run
# default arguments are for network install (QEMU has a network adapter),
# using systemd
# and use dhcp for automatic network configuration
#
# Arguments:
# besspin.sysvinit=1 to use sysvinit instead of systemd
# besspin.dhcp_addr=1 enables QEMU network install
# besspin.debian_repo=http://deb.debian.org/debian-ports/ is the url of the debian repo
# (or a path to file in case we are booting offline)
extraSetupArg?=besspin.debian_repo=http://deb.debian.org/debian-ports/ besspin.dhcp_addr=1

# Debian.cpio rootfs (uncompressed)
# Run debian chainloader initramfs in QEMU and finish seting up the system via debootstrap
# Requires:
# * $(OUT_DIR)/initramfs.cpio.gz created by chroot/debootstrap
# * $(OUT_DIR)/debian-startup-scripts to finish system setup
# * build-qemu-bbl/bbl is an actual executable (linux kernel + bootloader) that will run the rest of debootstrap
debian.cpio: build-cpio-utils $(OUT_DIR)/initramfs.cpio.gz debian-startup-scripts build-qemu-bbl/bbl
	@echo "debian.cpio"
	qemu-system-riscv64 \
      -nographic -machine virt -m 2G -smp ${QEMU_NPROCS} \
      -kernel build-qemu-bbl/bbl \
      -append "console=ttyS0 besspin.set_clock=$$(date --iso-8601=sec) ${extraSetupArg}" \
      -fsdev local,id=virtfs,path=$(CURDIR)/virtfs,security_model=mapped-file \
      -device virtio-9p-device,fsdev=virtfs,mount_tag=virtfs \
	  -device virtio-net-device,netdev=usernet \
   	  -netdev user,id=usernet,hostfwd=tcp::10001-:22
	mv $(OUT_DIR)/debian-initramfs.cpio debian.cpio
	@echo "debian.cpio done"

# Linux kernel for qemu chainloader
# Statically linked linux kernel executable, has CONFIG_INITRAMFS_SOURCE baked in it
# For busybox, we have `CONFIG_INITRAMFS_SOURCE="../chainloader-initramfs.cpio.gz"`
# * chainloader-initramfs.cpio.gz is a minimal initramfs with busybox utils
build-qemu-linux/vmlinux: $(CHAINLOADER_CONFIG) build-busybox/busybox_unstripped chainloader-initramfs.cpio.gz
	@echo "Building Linux with config: $$CHAINLOADER_CONFIG"
	export KCONFIG_CONFIG=$(CHAINLOADER_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-qemu-linux olddefconfig
	export KCONFIG_CONFIG=$(CHAINLOADER_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-qemu-linux $(@F)
	@echo "build-qemu-linux/vmlinux done"

# Qemu chainloader binary (linux kernel + rootfs) + bootloader
build-qemu-bbl/bbl: build-qemu-linux/vmlinux
	@echo "build-qemu-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-qemu-linux/vmlinux --enable-zero-bss --with-mem-start=0x80000000
	$(MAKE) -C $(@D) -j$(NPROCS)
	@echo "build-qemu-bbl/bbl done"

# Linux kernel
# Statically linked linux kernel executable, has CONFIG_INITRAMFS_SOURCE baked in it
# For debian, we have `CONFIG_INITRAMFS_SOURCE="../debian.cpio.gz"`
# Note that debian.cpio.gz is in this case just renamed chainloader-initramfs-network.cpio.gz
# DEBIAN_CONFIG provides linux kernel configuration, build-busybox/_install provides utility programs
# This kernel + initramfs will start up eth1 and request debian.cpio archive (created by qemu) over ethernet
# and then unpack it and switch root, which is considerable faster than pushing full debian.cpio.gz archive over JTAG
build-debian-network-linux/vmlinux: $(DEBIAN_CONFIG) build-busybox/busybox_unstripped chainloader-initramfs-network.cpio.gz
	@echo "Building Linux with config: $$DEBIAN_CONFIG"
	@rm -rf debian.cpio.gz
	@ln -s chainloader-initramfs-network.cpio.gz debian.cpio.gz
	export KCONFIG_CONFIG=$(DEBIAN_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-debian-network-linux olddefconfig
	export KCONFIG_CONFIG=$(DEBIAN_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-debian-network-linux $(@F)
	@echo "build-qemu-linux/vmlinux done"

build-debian-linux/vmlinux: $(DEBIAN_CONFIG) build-busybox/busybox_unstripped debian.cpio
	@echo "Building Linux with config: $$DEBIAN_CONFIG"
	@rm -rf debian.cpio.gz
	gzip -c --best <debian.cpio >debian.cpio.gz
	export KCONFIG_CONFIG=$(DEBIAN_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-debian-linux olddefconfig
	export KCONFIG_CONFIG=$(DEBIAN_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-debian-linux $(@F)
	@echo "build-qemu-linux/vmlinux done"

# Debian binary (linux kernel + rootfs) + bootloader - for loading through GDB
# * debian.cpio is a dependency, because we need it to fully boot (but it is not baked in the bbl image itself)
build-debian-network-bbl/bbl: debian.cpio build-debian-network-linux/vmlinux
	@echo "build-debian-network-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-debian-network-linux/vmlinux --enable-zero-bss --with-mem-start=0xC0000000
	$(MAKE) -C $(@D) -j$(NPROCS)
	@echo "build-debian-network-bbl/bbl done"

build-debian-bbl/bbl: build-debian-linux/vmlinux
	@echo "build-debian-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-debian-linux/vmlinux --enable-zero-bss --with-mem-start=0xC0000000
	$(MAKE) -C $(@D) -j$(NPROCS)
	@echo "build-debian-bbl/bbl done"

# Intermediate stripped debian binary + bootloader
bbl-$(DEBIAN_TARGET).bin: build-$(DEBIAN_TARGET)-bbl/bbl
	$(OBJCOPY) -O binary $< $@

# Intermediate ELF file for booting debian from flash
bootmem-$(DEBIAN_TARGET): bootmem.S linker.ld bbl-$(DEBIAN_TARGET).bin
	@rm -rf bbl.bin
	@ln -s bbl-$(DEBIAN_TARGET).bin bbl.bin
	$(CC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@

# Stripped Binary file for booting debian from flash
bootmem-$(DEBIAN_TARGET).bin: bootmem-$(DEBIAN_TARGET)
	$(OBJCOPY) -O binary $< $@

# Clean all debian build artifacts
clean-debian:
	@rm -rf $(CPIO_UTILS_PREFIX)
	@rm -f bootmem-$(DEBIAN_TARGET) bootmem-$(DEBIAN_TARGET).bin bbl-$(DEBIAN_TARGET).bin
	@rm -rf build-$(DEBIAN_TARGET)-bbl
	@rm -f debian.cpio
	@rm -f debian.cpio.gz
	@rm -rf build-$(DEBIAN_TARGET)-linux
	@rm -rf build-qemu-linux
	@rm -rf build-qemu-bbl
	@rm -rf $(BUSYBOX_PREFIX)
	@rm -rf debian-linux.config.old
	@rm -rf chainloader-linux.config.old
	@rm -rf chainloader-initramfs.files
	@rm -rf chainloader-initramfs.cpio.gz
	@rm -rf chainloader-initramfs-network.files
	@rm -rf chainloader-initramfs-network.cpio.gz
	@rm -rf $(OUT_DIR)
	$(MAKE) -C $(DEBIAN_DIR) clean

# Serve cpio archive over network
# Assumes your host network is configured with:
# ```
# ip addr add 10.88.88.1/24 broadcast 10.88.88.255 dev eth1
# ip link set eth1 up
# ```
# where `eth1` is the ethernet adapter connected to the FPGA
# on the guest, do:
# ```
# ip addr add 10.88.88.2/24 broadcast 10.88.88.255 dev eth0
# ip link set eth0 up
# ```
# To remove the address, do:
# ```
# ip link set eth0 down
# ip addr del 10.88.88.2/24 dev eth0
# ```
serve-cpio-archive:
	python3 -m http.server 8000 --bind 10.88.88.1 -d .
###################################
#                                 #
#      END DEBIAN TARGETS         #
#                                 #
###################################

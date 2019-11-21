# Define some global variables
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
DEBIAN_CONFIG=$(CURDIR)/debian-linux.config
# Chainloader build
CHAINLOADER_CONFIG=$(CURDIR)/chainloader-linux.config

BUSYBOX_PREFIX=$(CURDIR)/_install
CPIO_UTILS_PREFIX=$(CURDIR)/build-cpio_utils/

# Define build directories
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

# Public targets
default: busybox
busybox: build-busybox-bbl/bbl.text bootmem-busybox.bin
debian: build-debian-bbl/bbl.text bootmem-debian.bin

FORCE:

.PHONY: default debian clean-debian clean-busybox


# General targets
%.text: %
	@echo "text, target name: $@, first prereq: $<"
	$(OBJDUMP) -dS $< > $@
	@echo "text done"

# Busybox target
build-busybox/.config: $(BUSYBOX_CONFIG)
	@echo "build-busybox/.config, BUSYBOX_CONFIG=$(BUSYBOX_CONFIG)"
	$(MKDIR) -p $(@D)
	$(MAKE) -C $(BUSYBOX_SRC) O=$(CURDIR)/build-busybox -j$(NPROCS) defconfig
	$(CP) $< $@
	$(MAKE) -C $(@D) -j$(NPROCS) oldconfig
	@echo "build-busybox/.config done"

build-busybox/busybox_unstripped: build-busybox/.config
	@echo "build-busybox/busybox_unstripped"
	$(MAKE) -C $(@D) -j$(NPROCS) all
	$(MAKE) -C $(@D) -j$(NPROCS) install
	@echo "build-busybox/busybox_unstripped done"

build-linux/vmlinux: $(LINUX_CONFIG) build-busybox/busybox_unstripped
	@echo "Building Linux with config: $$LINUX_CONFIG"
	export KCONFIG_CONFIG=$(LINUX_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-linux olddefconfig
	export KCONFIG_CONFIG=$(LINUX_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-linux $(@F)
	@echo "build-linux/vmlinux done"

build-busybox-bbl/bbl: build-linux/vmlinux
	@echo "build-busybox-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-linux/vmlinux
	$(MAKE) -C $(@D) -j$(NPROCS)
	@echo "build-busybox-bbl/bbl done"

bbl-busybox.bin: build-busybox-bbl/bbl
	@echo "bbl.bin"
	$(OBJCOPY) -O binary $< $@
	@echo "bbl.bin done"

bootmem-busybox: bootmem.S linker.ld bbl-busybox.bin
	@echo "bootmem"
	@rm -rf bbl.bin
	@ln -s bbl-busybox.bin bbl.bin
	$(CC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@
	@echo "bootmem done"

bootmem-busybox.bin: bootmem-busybox
	@echo "bootmem.bin"
	$(OBJCOPY) -O binary $< $@
	@echo "bootmem.bin done"

clean-busybox:
	@rm -rf build-linux build-busybox
	@rm -f bootmem-busybox bootmem-busybox.bin bbl-busybox.bin
	@rm -rf build-busybox-bbl




# Debian build

# we also have to compile initramfs utils from riscv-linux
build-cpio-utils:
	@echo "Compiling cpio utils in $(CPIO_UTILS_PREFIX)"
	$(MKDIR) -p $(CPIO_UTILS_PREFIX)
	gcc $(LINUX_SRC)/usr/gen_init_cpio.c -o $(CPIO_UTILS_PREFIX)gen_init_cpio
	cp $(LINUX_SRC)/usr/gen_initramfs_list.sh $(CPIO_UTILS_PREFIX)
	@echo "Compiling cpio utils done"

# busybox utils
$(BUSYBOX_PREFIX): build-busybox/busybox_unstripped
	@echo "busybox-install"
	cp -r build-busybox/_install _install
	@echo "busybox-install done"

# chainloader initramfs
debian-chainloader-initramfs: $(BUSYBOX_PREFIX)
	@echo "debian-chainloader-initramfs"
	./build_chainloader_initramfs.sh
	@echo "debian-chainloader-initramfs done"

debian-chainloader-initramfs-network: $(BUSYBOX_PREFIX)
	@echo "debian-chainloader-initramfs-network"
	./build_chainloader_initramfs_network.sh
	@echo "debian-chainloader-initramfs-network done"

# split creating chroot
$(DEBIAN_DIR)/riscv64-chroot.tar: $(DEBIAN_DIR)/create_chroot.sh
	@echo "$(DEBIAN_DIR)/riscv64-chroot.tar"
	$(DEBIAN_DIR)/build_stage1_initramfs.sh stage1
	@echo "$(DEBIAN_DIR)/riscv64-chroot.tar done"

# deboostrap image: update only if the stage1-init script changed
$(OUT_DIR)/initramfs.cpio.gz: $(DEBIAN_DIR)/stage1-init $(DEBIAN_DIR)/riscv64-chroot.tar
	@echo "$(OUT_DIR)/initramfs.cpio.gz"
	mkdir -p $(OUT_DIR)
	$(DEBIAN_DIR)/build_stage1_initramfs.sh
	mv $(DEBIAN_DIR)/stage1-initramfs.cpio.gz $(OUT_DIR)/initramfs.cpio.gz
	@echo "$(OUT_DIR)/initramfs.cpio.gz done"

# startup scripts
debian-startup-scripts:
	@echo "debian-startup-scripts"
	mkdir -p $(OUT_DIR)/scripts
	cp $(DEBIAN_DIR)/setup_chroot.sh $(OUT_DIR)/scripts/
	cp -r $(DEBIAN_DIR)/setup_scripts $(OUT_DIR)/scripts/
	@echo "debian-startup-scripts done"	

# kernel arguments
extraSetupArg?=besspin.debian_repo=http://deb.debian.org/debian-ports/ besspin.sysvinit=1 besspin.dhcp_addr=1

# run debian chainloader image through qemu and finish seting up the system via debootstrap
debian.cpio: build-cpio-utils $(OUT_DIR)/initramfs.cpio.gz debian-startup-scripts debian-chainloader-initramfs build-qemu-bbl/bbl
	@echo "debian-chainloader-image"
	qemu-system-riscv64 \
      -nographic -machine virt -m 2G -smp ${QEMU_NPROCS} \
      -kernel build-qemu-bbl/bbl \
      -append "console=ttyS0 besspin.set_clock=$$(date --iso-8601=sec) ${extraSetupArg}" \
      -fsdev local,id=virtfs,path=$(CURDIR)/virtfs,security_model=mapped-file \
      -device virtio-9p-device,fsdev=virtfs,mount_tag=virtfs \
	  -device virtio-net-device,netdev=usernet \
   	  -netdev user,id=usernet,hostfwd=tcp::10001-:22
	mv $(OUT_DIR)/debian-initramfs.cpio debian.cpio
	@echo "debian-chainloader-image done"

# compile chainloader linux image
build-qemu-linux/vmlinux: $(CHAINLOADER_CONFIG) build-busybox/busybox_unstripped
	@echo "Building Linux with config: $$CHAINLOADER_CONFIG"
	export KCONFIG_CONFIG=$(CHAINLOADER_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-qemu-linux olddefconfig
	export KCONFIG_CONFIG=$(CHAINLOADER_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-qemu-linux $(@F)
	@echo "build-qemu-linux/vmlinux done"

# builds chainloader image for qemu
build-qemu-bbl/bbl: build-qemu-linux/vmlinux
	@echo "build-qemu-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-qemu-linux/vmlinux
	$(MAKE) -C $(@D) TARGET_QEMU=yes -j$(NPROCS)
	@echo "build-qemu-bbl/bbl done"

# compile final debian image
build-debian-linux/vmlinux: $(DEBIAN_CONFIG) build-busybox/busybox_unstripped debian-chainloader-initramfs-network
	@echo "Building Linux with config: $$DEBIAN_CONFIG"
	export KCONFIG_CONFIG=$(DEBIAN_CONFIG) && $(MAKE) -C $(LINUX_SRC) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-debian-linux olddefconfig
	export KCONFIG_CONFIG=$(DEBIAN_CONFIG) && $(MAKE) -C $(@D) -j$(NPROCS) ARCH=riscv O=$(CURDIR)/build-debian-linux $(@F)
	@echo "build-qemu-linux/vmlinux done"

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
	@echo "serve-cpio-archive"
	python3 -m http.server 8000 --bind 10.88.88.1 -d .
	@echo "serve-cpio-archive done"

# build final debian image
build-debian-bbl/bbl: debian.cpio build-debian-linux/vmlinux
	@echo "build-debian-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-debian-linux/vmlinux
	$(MAKE) -C $(@D) -j$(NPROCS)
	@echo "build-debian-bbl/bbl done"

bbl-debian.bin: build-debian-bbl/bbl
	@echo "bbl.bin"
	$(OBJCOPY) -O binary $< $@
	@echo "bbl.bin done"

bootmem-debian: bootmem.S linker.ld bbl-debian.bin
	@echo "bootmem"
	@rm -rf bbl.bin
	@ln -s bbl-debian.bin bbl.bin
	$(CC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@
	@echo "bootmem done"

bootmem-debian.bin: bootmem-debian
	@echo "bootmem.bin"
	$(OBJCOPY) -O binary $< $@
	@echo "bootmem.bin done"

clean-debian:
	@echo "clean-debian"
	@rm -rf build-cpio-utils
	@rm -f bootmem-debian bootmem-debian.bin bbl-debian.bin
	@rm -rf build-debian-bbl
	@rm -f debian.cpio
	@rm -rf build-debian-linux
	@rm -rf build-qemu-linux
	@rm -rf build-qemu-bbl
	@rm -rf _install
	@rm -rf debian-linux.config.old
	@rm -rf chainloader-linux.config.old
	@rm -rf chainloader-initramfs.files
	@rm -rf chainloader-initramfs.cpio.gz
	@rm -rf chainloader-initramfs-network.files
	@rm -rf chainloader-initramfs-network.cpio.gz
	@rm -rf $(OUT_DIR)
	$(MAKE) -C $(DEBIAN_DIR) clean


CROSS_COMPILE?=riscv64-unknown-linux-gnu-

MKDIR?=mkdir
CP?=cp

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

BUSYBOX_CONFIG?=$(CURDIR)/busybox.config
#KCONFIG_CONFIG?=$(CURDIR)/linux.config
DEBIAN_CONFIG=$(CURDIR)/debian-linux.config
CHAINLOADER_CONFIG=$(CURDIR)/chainloader-linux.config
KCONFIG_CONFIG=$(CHAINLOADER_CONFIG)
CPIO_UTILS_PREFIX=$(CURDIR)/build-cpio_utils/

#export GFE_DEBIAN_URL=/nix/store/kjycmkx2mv9v7x7wdb5rn3da6cxj2d8r-debian-repo-snapshot-src-fixed
#export GFE_DEBIAN_URL=http://localhost:3142

NPROCS := 1
ifeq ($(UNAME),Linux)
        NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(UNAME),Darwin)
        NPROCS := $(shell sysctl hw.ncpu | awk '{print $$2}')
endif # $(UNAME)
# Limit NPROCS to 8 so qemu can handle it
NPROCS=$(shell echo $$((NPROCS>8 ? 8 : NPROCS)))
$(info NPROCS=$(NPROCS))

export CROSS_COMPILE KCONFIG_CONFIG CPIO_UTILS_PREFIX

LINUX_SRC=../riscv-linux
BUSYBOX_SRC=../busybox
BBL_SRC=../../riscv-pk
DEBIAN_DIR=../debian
OUT_DIR=$(CURDIR)/virtfs

TARGET_QEMU=no

#TARGET=build-busybox/busybox_unstripped

default: build-bbl/bbl.text bootmem.bin
#debian: override TARGET=deb
debian: build-bbl/bbl.text bootmem.bin

%.text: %
	@echo "text, target name: $@, first prereq: $<"
	$(OBJDUMP) -dS $< > $@
	@echo "text done"

build-busybox/.config: $(BUSYBOX_CONFIG)
	@echo "build-busybox/.config, BUSYBOX_CONFIG=$(BUSYBOX_CONFIG)"
	$(MKDIR) -p $(@D)
	$(MAKE) -C $(BUSYBOX_SRC) O=$(CURDIR)/build-busybox defconfig
	$(CP) $< $@
	$(MAKE) -C $(@D) oldconfig
	@echo "build-busybox/.config done"

build-busybox/busybox_unstripped: build-busybox/.config
	@echo "build-busybox/busybox_unstripped"
	$(MAKE) -C $(@D) all
	$(MAKE) -C $(@D) install
	@echo "build-busybox/busybox_unstripped done"

build-linux/.config: $(KCONFIG_CONFIG) # this means we should recompile when KCONFIG_CONFIG changes
	@echo "build-linux/.config: KCONFIG_CONFIG=$(KCONFIG_CONFIG)"
	$(MAKE) -C $(LINUX_SRC) ARCH=riscv O=$(CURDIR)/build-linux olddefconfig
	@echo "build-linux/.config done"

build-linux/vmlinux: build-linux/.config build-busybox/busybox_unstripped
	@echo "build-linux/vmlinux"
	@echo "Building Linux with config: $$KCONFIG_CONFIG"
	$(MAKE) -C $(@D) ARCH=riscv O=$(CURDIR)/build-linux $(@F)
	@echo "build-linux/vmlinux done"

build-bbl/bbl: build-linux/vmlinux
	@echo "build-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-linux/vmlinux
	$(MAKE) -C $(@D)
	@echo "build-bbl/bbl done"

build-qemu-bbl/bbl: build-linux/vmlinux
	@echo "build-qemu-bbl/bbl"
	$(MKDIR) -p $(@D)
	cd $(@D) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=../build-linux/vmlinux
	$(MAKE) -C $(@D) TARGET_QEMU=yes
	@echo "build-qemu-bbl/bbl done"

bbl.bin: build-bbl/bbl
	@echo "bbl.bin"
	$(OBJCOPY) -O binary $< $@
	@echo "bbl.bin done"

bootmem: bootmem.S linker.ld bbl.bin
	@echo "bootmem"
	$(CC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@
	@echo "bootmem done"

bootmem.bin: bootmem
	@echo "bootmem.bin"
	$(OBJCOPY) -O binary $< $@
	@echo "bootmem.bin done"

clean-cpio-utils:
	@rm -rf build-cpio-utils

clean:
	@rm -f bootmem bootmem.bin bbl.bin
	@rm -rf build-bbl
	@rm -rf chainloader-initramfs.cpio.gz
	@rm -rf chainloader-initramfs.files
	@make -f Makefile.deb clean
	@make -f Makefile.bb clean
	@rm -rf $(OUT_DIR)
FORCE:
	
.PHONY: default debian

# we also have to compile initramfs utils from riscv-linux
build-cpio-utils:
	@echo "Compiling cpio utils in $(CPIO_UTILS_PREFIX)"
	$(MKDIR) -p $(CPIO_UTILS_PREFIX)
	gcc $(LINUX_SRC)/usr/gen_init_cpio.c -o $(CPIO_UTILS_PREFIX)gen_init_cpio
	cp $(LINUX_SRC)/usr/gen_initramfs_list.sh $(CPIO_UTILS_PREFIX)
	@echo "Compiling cpio utils done"

$(OUT_DIR)/initramfs.cpio.gz:
	@echo "stage1-initramfs.cpio.gz"
	mkdir -p $(OUT_DIR)
	$(DEBIAN_DIR)/build_stage1_initramfs.sh
	mv $(DEBIAN_DIR)/stage1-initramfs.cpio.gz $(OUT_DIR)/initramfs.cpio.gz
	@echo "stage1-initramfs.cpio.gz done"

debian-stage1-virtual-disk:
	@echo "debian-stage1-virtual-disk"
	mkdir -p $(OUT_DIR)/scripts
	cp $(DEBIAN_DIR)/setup_chroot.sh $(OUT_DIR)/scripts/
	cp -r $(DEBIAN_DIR)/setup_scripts $(OUT_DIR)/scripts/
	@echo "debian-stage1-virtual-disk done"	

debian-chainloader-initramfs: build-busybox/busybox_unstripped
	@echo "debian-chainloader-initramfs"
	$(eval export BUSYBOX_PREFIX=$(CURDIR)/build-busybox/_install)
	./build_chainloader_initramfs.sh
	@echo "debian-chainloader-initramfs done"

extraSetupArg=besspin.debian_repo=http://deb.debian.org/debian/ besspin.inet_addr=10.0.2.15/24

debian-chainloader-image: debian-stage1-virtual-disk $(OUT_DIR)/initramfs.cpio.gz debian-chainloader-initramfs build-qemu-bbl/bbl | build-cpio-utils
	@echo "debian-chainloader-image"
	qemu-system-riscv64 \
      -nographic -machine virt -m 2G -smp ${NPROCS} \
      -kernel build-qemu-bbl/bbl \
      -append "console=ttyS0 besspin.set_clock=$$(date --iso-8601=sec) ${extraSetupArg}" \
      -fsdev local,id=virtfs,path=$(CURDIR)/virtfs,security_model=mapped-file \
      -device virtio-9p-device,fsdev=virtfs,mount_tag=virtfs \
	  -device virtio-net-device,netdev=usernet \
   	  -netdev user,id=usernet,hostfwd=tcp::10001-:22
	@echo "debian-chainloader-image done"

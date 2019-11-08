CROSS_COMPILE?=riscv64-unknown-linux-gnu-

MKDIR?=mkdir
CP?=cp

CC=$(CROSS_COMPILE)gcc
LD=$(CROSS_COMPILE)ld
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump

BUSYBOX_CONFIG?=$(CURDIR)/busybox.config
KCONFIG_CONFIG?=$(CURDIR)/linux.config
DEBIAN_CONFIG=$(CURDIR)/debian-linux.config
CHAINLOADER_CONFIG=$(CURDIR)/chainloader-linux.config
CPIO_UTILS_PREFIX=$(CURDIR)/build-cpio_utils/

NPROCS := 1
ifeq ($(UNAME),Linux)
        NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(UNAME),Darwin)
        NPROCS := $(shell sysctl hw.ncpu | awk '{print $$2}')
endif # $(UNAME)



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
	@echo "Building Linux with config: $$KCONFIG_CONFIG and $(PAYLOAD)"
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
	$(eval export KCONFIG_CONFIG=$(CURDIR)/chainloader-linux.config)
	$(eval PAYLOAD=initramfs.cpio.gz)
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

clean-stage1-initramfs.cpio.gz:
	@rm -rf $(DEBIAN_DIR)/stage1-initramfs.cpio.gz
	@rm -rf initramfs.cpio.gz
	@rm -rf $(OUT_DIR)

clean:
	@rm -f bootmem bootmem.bin bbl.bin
	@rm -rf build-bbl
	@make -f Makefile.deb clean
	@make -f Makefile.bb clean
	@rm -rf initramfs.cpio.gz
FORCE:
	
.PHONY: default debian

# we also have to compile initramfs utils from riscv-linux
build-cpio-utils:
	@echo "Compiling cpio utils in $(CPIO_UTILS_PREFIX)"
	$(MKDIR) -p $(CPIO_UTILS_PREFIX)
	gcc $(LINUX_SRC)/usr/gen_init_cpio.c -o $(CPIO_UTILS_PREFIX)gen_init_cpio
	cp $(LINUX_SRC)/usr/gen_initramfs_list.sh $(CPIO_UTILS_PREFIX)
	@echo "Compiling cpio utils done"

# target : prerequisitites ; recipe
stage1-initramfs.cpio.gz: #initramfs.cpio.gz
	@echo "stage1-initramfs.cpio.gz"
	mkdir -p $(OUT_DIR)
	$(DEBIAN_DIR)/build_stage1_initramfs.sh
	mv $(DEBIAN_DIR)/stage1-initramfs.cpio.gz $(OUT_DIR)/initramfs.cpio.gz
	@echo "stage1-initramfs.cpio.gz done"

debian-stage1-virtual-disk: stage1-initramfs.cpio.gz
	@echo "debian-stage1-virtual-disk"
	mkdir -p $(OUT_DIR)/scripts
	cp $(DEBIAN_DIR)/setup_chroot.sh $(OUT_DIR)/scripts/
	cp -r $(DEBIAN_DIR)/setup_scripts $(OUT_DIR)/scripts/
	@echo "debian-stage1-virtual-disk done"	

debian-chainloader-initramfs: build-busybox/busybox_unstripped
	@echo "debian-chainloader-initramfs"
	$(eval export BUSYBOX_PREFIX=$(CURDIR)/build-busybox/_install)
	./build_chainloader_initramfs.sh
	ln -s chainloader-initramfs.cpio.gz initramfs.cpio.gz
	@echo "debian-chainloader-initramfs done"

debian-chainloader-image: debian-stage1-virtual-disk debian-chainloader-initramfs build-qemu-bbl/bbl | build-cpio-utils
	@echo "debian-chainloader-image"
	qemu-system-riscv64 \
      -nographic -machine virt -m 2G \
      -kernel build-qemu-bbl/bbl \
      -append "console=ttyS0 besspin.set_clock=@$(date +%s) ${extraSetupArg}" \
      -fsdev local,id=virtfs,path=$(CURDIR)/virtfs,security_model=mapped-file \
      -device virtio-9p-device,fsdev=virtfs,mount_tag=virtfs
	@echo "debian-chainloader-image done"

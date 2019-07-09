
CHROOT_DIR=riscv64-chroot
BOOTMEM_DIR=../bootmem

default: riscv64-chroot $(BOOTMEM_DIR)/debian.cpio.gz

riscv64-chroot:
	@echo "Building chroot environment"
	./create_chroot2.sh

$(BOOTMEM_DIR)/debian.cpio.gz: riscv64-chroot
	@echo "Building cpio.gz image"
	./create_chroot2.sh create_cpio
	cp riscv64-chroot/debian.cpio.gz $@

.PHONY: default

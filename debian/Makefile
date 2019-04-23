
CHROOT_DIR=riscv64-chroot
BOOTMEM_DIR=../bootmem

default: riscv64-chroot $(BOOTMEM_DIR)/debian.cpio.gz

riscv64-chroot: config_chroot.sh
	@echo "Building chroot environment"
	@echo "Your password may be requested for superuser privileges"
	./create_chroot.sh

$(BOOTMEM_DIR)/debian.cpio.gz: riscv64-chroot
	@echo "Building cpio.gz image"
	@echo "Your password may be requested for superuser privileges"
	./create_cpio.sh

.PHONY: default

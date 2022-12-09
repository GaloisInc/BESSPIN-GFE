
CHROOT_DIR=riscv64-chroot
BOOTMEM_DIR=../bootmem

default: riscv64-chroot $(BOOTMEM_DIR)/debian.cpio.gz

riscv64-chroot:
	@echo "Building chroot environment"
	./create_chroot.sh

$(BOOTMEM_DIR)/debian.cpio.gz: riscv64-chroot
	@echo "Cleaning up apt remnants"
	./create_chroot.sh apt_cleanup
	@echo "Building cpio.gz image"
	./create_chroot.sh create_cpio
	cp riscv64-chroot/debian.cpio.gz $@

clean:
	@rm -rf build riscv64-chroot $(BOOTMEM_DIR)/debian.cpio.gz riscv64-chroot.tar

.PHONY: default clean

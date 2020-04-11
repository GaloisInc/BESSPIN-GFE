# For faster builds, use all available cores
UNAME = $(shell uname -s)
NPROCS:=1
ifeq ($(UNAME),Linux)
        NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(UNAME),Darwin)
        NPROCS := $(shell sysctl hw.ncpu | awk '{print $$2}')
endif

# Define toolchain
export XCC=$(shell which clang)
export XCXX=$(shell which clang++)
export XCPP=$(shell which clang-cpp)
export XLD=$(shell which ld.lld)
export XOBJDUMP=$(shell which llvm-objdump)
export XOBJCOPY=$(shell which llvm-objcopy)
export XCFLAGS=-fuse-ld=$(shell which ld.lld) -Qunused-arguments -fcommon

# Directory with freebsd repo
FREEBSD_DIR = cheribsd

# Destination directory for 'world'
WORLD_DIR = $(CURDIR)/world

# Destination directory for objects
OBJ_DIR = $(CURDIR)/obj
export MAKEOBJDIRPREFIX=$(OBJ_DIR)

# Define compilation flags
FLAGS = -DDB_FROM_SRC -DNO_ROOT -DBUILD_WITH_STRICT_TMPPATH TARGET=riscv \
	TARGET_ARCH=riscv64 -DNO_WERROR WERROR= -DWITHOUT_TESTS -DWITHOUT_MAN \
	-DWITHOUT_MAIL -DWITHOUT_VT -DWITHOUT_DEBUG_FILES -DWITHOUT_BOOT -DWITH_AUTO_OBJ \
	-DWITHOUT_GCC_BOOTSTRAP -DWITHOUT_CLANG_BOOTSTRAP -DWITHOUT_LLD_BOOTSTRAP \
	-DWITHOUT_LIB32 -DWITH_ELFTOOLCHAIN_BOOTSTRAP -DWITHOUT_BINUTILS_BOOTSTRAP \
	-DWITHOUT_RESCUE -DWITHOUT_BLUETOOTH -DWITHOUT_SVNLITE -DWITHOUT_CDDL -DWITHOUT_PF \
	-DWITHOUT_PROFILE -DWITHOUT_VI -DWITHOUT_SYSCONS -DWITHOUT_CTF -DWITHOUT_LOCALES -DWITHOUT_DICT \
	-DWITHOUT_EXAMPLES -DWITHOUT_HTML -DWITHOUT_FILE -DWITHOUT_MAKE -DWITHOUT_PORTSNAP \
	-DWITHOUT_PKGBOOTSTRAP -DWITHOUT_OPENMP -DWITHOUT_SHAREDOCS -DWITHOUT_WIRELESS -DWITHOUT_KDUMP \
	-DWITHOUT_AUDIT -DWITHOUT_TFTP -DWITHOUT_CXGBETOOL -DWITHOUT_LDNS -DWITHOUT_QUOTAS \
	-DWITHOUT_TALK -DWITHOUT_USB -DWITHOUT_NLS -DWITHOUT_UTMPX -DWITHOUT_KERNEL_SYMBOLS \
	-DWITHOUT_OPENSSH -DWITHOUT_KERBEROS MODULES_OVERRIDE= -DNO_CLEAN -DI_REALLY_MEAN_NO_CLEAN \
	LOCAL_XTOOL_DIRS="lib/libnetbsd usr.sbin/makefs usr.bin/mkimg"

TOOLCHAIN ?= -DWITHOUT_TOOLCHAIN
FLAGS += $(TOOLCHAIN)

default: freebsd.bbl

# Build world
$(OBJ_DIR):
	@echo "Building world"
	@mkdir -p $(OBJ_DIR)
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) -j$(NPROCS) buildworld
	@echo "Building done"

# Copy 'world' into WORLD_DIR and run 'distribution'
$(WORLD_DIR): $(OBJ_DIR)
	@echo "Installing world"
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) DESTDIR=$(WORLD_DIR) -j$(NPROCS) installworld
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) DESTDIR=$(WORLD_DIR) -j$(NPROCS) distribution
	@echo "Installing world done"

# Location of FSTAB
FSTAB=$(CURDIR)/fstab.freebsd
# Location of USERDB
USERDB=$(CURDIR)/freebsd-userdb
# Name of FreeBSD rootfs image
FREEBSD_IMAGE=$(WORLD_DIR)/riscv.img
# Image size - necessary for makefs
IMAGE_SIZE = 65m
# Aux var for freebsd root dir
ROOT_DIR = $(OBJ_DIR)/$(CURDIR)/$(FREEBSD_DIR)/riscv.riscv64
# Path for 'makefs'
MAKEFS = $(ROOT_DIR)/tmp/usr/sbin/makefs

$(FREEBSD_IMAGE): $(WORLD_DIR)
	@echo "Build $(FREEBSD_IMAGE)"
	@cd $(WORLD_DIR) && sed -i -E 's/time=[0-9\.]+$$//' METALOG
	@cd $(WORLD_DIR) && egrep -v "usr/lib/[^ ]*\\.a|usr/share/i18n|^./var/" METALOG > METALOG.new
	@cd $(WORLD_DIR) && mv METALOG.new METALOG
	@cd $(WORLD_DIR) && mkdir -p home
	@cd $(WORLD_DIR) && echo 'hostname="gfe"' > etc/rc.conf
	@cd $(WORLD_DIR) && cp $(FSTAB) etc/fstab
	@cd $(WORLD_DIR) && echo "./etc/fstab type=file uname=root gname=wheel mode=0644" >> METALOG
	@cd $(WORLD_DIR) && echo "./etc/rc.conf type=file uname=root gname=wheel mode=0644" >> METALOG
	@cd $(WORLD_DIR) && echo "./home type=dir uname=root gname=wheel mode=0755" >> METALOG
	@cd $(WORLD_DIR) && $(MAKEFS) -N $(USERDB) -D -f 10000 -o version=2 -s $(IMAGE_SIZE) $(FREEBSD_IMAGE) METALOG
	@echo "Build $(FREEBSD_IMAGE) done"


# Kernel config directory
KERN_DIR=$(CURDIR)/$(FREEBSD_DIR)/sys/riscv/conf
# Kernel config file (FPGA only for now)
KERN_CONF=TSFREEBSD-FPGA

# Build kernel
$(ROOT_DIR)/sys/$(KERN_CONF)/kernel: $(FREEBSD_IMAGE)
	@echo "Building kernel"
	@echo KERN_DIR=$(KERN_DIR)
	@echo KERNCONF=$(KERN_CONF)
	@mkdir -p $(KERN_DIR)
	@echo 'include     "GENERIC"'                    >  $(KERN_DIR)/$(KERN_CONF)
	@echo 'options     TMPFS'                        >> $(KERN_DIR)/$(KERN_CONF)
	@echo 'options     MD_ROOT'                      >> $(KERN_DIR)/$(KERN_CONF)
	@echo 'makeoptions MFS_IMAGE=$(FREEBSD_IMAGE)'   >> $(KERN_DIR)/$(KERN_CONF)
	@echo 'options ROOTDEVNAME=\"ufs:/dev/md0\"'     >> $(KERN_DIR)/$(KERN_CONF)
	@cat $(KERN_DIR)/$(KERN_CONF)
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) -j$(NPROCS) KERNCONF=$(KERN_CONF) -j$(NPROCS) buildkernel
	@echo "Building kernel done"

# Install kernel
KERNEL_IMAGE_DIR = $(WORLD_DIR)/boot/kernel
$(KERNEL_IMAGE_DIR)/kernel: $(ROOT_DIR)/sys/$(KERN_CONF)/kernel
	@echo "Installing kernel"
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) -j$(NPROCS) KERNCONF=$(KERN_CONF) -j$(NPROCS) DESTDIR=$(WORLD_DIR) installkernel
	@echo "Installing kernel done"	

# Package with riscv-pk
BBL_SRC=../../../../riscv-pk
freebsd.bbl: $(KERNEL_IMAGE_DIR)/kernel
	@echo "Build freebsd.bbl"
	cd $(KERNEL_IMAGE_DIR) && $(BBL_SRC)/configure --host=riscv64-unknown-elf --with-payload=kernel
	$(MAKE) -C $(KERNEL_IMAGE_DIR) -j$(NPROCS)
	@cp $(KERNEL_IMAGE_DIR)/bbl freebsd.bbl
	@echo "Build freebsd.bbl done"

clean:
	@rm -rf $(OBJ_DIR)
	@rm -rf $(WORLD_DIR)
	@rm -rf freebsd.bbl
	@rm -rf $(ROOT_DIR)/sys/$(KERN_CONF)/kernel

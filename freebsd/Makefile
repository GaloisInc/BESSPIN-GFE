# For faster builds, use all available cores
UNAME = $(shell uname -s)
NPROCS:=1
ifeq ($(UNAME),Linux)
        NPROCS := $(shell grep -c ^processor /proc/cpuinfo)
else ifeq ($(UNAME),Darwin)
        NPROCS := $(shell sysctl hw.ncpu | awk '{print $$2}')
endif

# Define toolchain
export XCC=/usr/bin/clang-11
export XCXX=/usr/bin/clang++-11
export XCPP=/usr/bin/clang-cpp-11
export XLD=/usr/bin/ld.lld-11
export XOBJDUMP=/usr/bin/llvm-objdump-11
export XOBJCOPY=/usr/bin/llvm-objcopy-11
export XCFLAGS=-fuse-ld=/usr/bin/ld.lld-11 -Qunused-arguments

FREEBSD_DIR=cheribsd
DESTDIR=$(CURDIR)/world

# Define output directory
export MAKEOBJDIRPREFIX=$(CURDIR)/obj

# Define compilation flags
FLAGS=-DDB_FROM_SRC -DNO_ROOT -DBUILD_WITH_STRICT_TMPPATH TARGET=riscv \
	TARGET_ARCH=riscv64 -DNO_WERROR WERROR= -DWITHOUT_TESTS -DWITHOUT_MAN \
	-DWITHOUT_MAIL -DWITHOUT_VT -DWITHOUT_DEBUG_FILES -DWITHOUT_BOOT -DWITH_AUTO_OBJ \
	-DWITHOUT_GCC_BOOTSTRAP -DWITHOUT_CLANG_BOOTSTRAP -DWITHOUT_LLD_BOOTSTRAP \
	-DWITHOUT_LIB32 -DWITH_ELFTOOLCHAIN_BOOTSTRAP -DWITHOUT_TOOLCHAIN -DWITHOUT_BINUTILS_BOOTSTRAP \
	-DWITHOUT_RESCUE -DWITHOUT_BLUETOOTH -DWITHOUT_SVNLITE -DWITHOUT_CDDL -DWITHOUT_PF \
	-DWITHOUT_PROFILE -DWITHOUT_VI -DWITHOUT_SYSCONS -DWITHOUT_CTF -DWITHOUT_LOCALES -DWITHOUT_DICT \
	-DWITHOUT_EXAMPLES -DWITHOUT_HTML -DWITHOUT_FILE -DWITHOUT_MAKE -DWITHOUT_PORTSNAP \
	-DWITHOUT_PKGBOOTSTRAP -DWITHOUT_OPENMP -DWITHOUT_SHAREDOCS -DWITHOUT_WIRELESS -DWITHOUT_KDUMP \
	-DWITHOUT_AUDIT -DWITHOUT_TFTP -DWITHOUT_CXGBETOOL -DWITHOUT_LDNS -DWITHOUT_QUOTAS \
	-DWITHOUT_TALK -DWITHOUT_USB -DWITHOUT_NLS -DWITHOUT_UTMPX -DWITHOUT_KERNEL_SYMBOLS \
	-DWITHOUT_OPENSSH -DWITHOUT_KERBEROS MODULES_OVERRIDE= -DNO_CLEAN -DI_REALLY_MEAN_NO_CLEAN

default: buildworld

buildworld:
	@echo "Building world"
	rm -rf $(MAKEOBJDIRPREFIX)
	mkdir $(MAKEOBJDIRPREFIX)
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) -j$(NPROCS) buildworld

installworld: #buildworld
	@echo "Install world"
	@rm -rf $(DESTDIR)
	@mkdir -p $(DESTDIR)
	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) DESTDIR=$(DESTDIR) -j$(NPROCS) installworld

FSTAB=$(CURDIR)/fstab.freebsd
USERDB=$(CURDIR)/freebsd-userdb
FREEBSD_IMAGE=riscv.img
IMAGE_SIZE = 65m


makefs -N ./freebsd-userdb -D -f 10000 -o version=2 -s 65m riscv.img METALOG

rootfs: # installworld
	@echo "Build rootfs"
	cd $(DESTDIR) && sed -i -E 's/time=[0-9\.]+$$//' METALOG
	cd $(DESTDIR) && egrep -v "usr/lib/[^ ]*\\.a|usr/share/i18n|^./var/" METALOG > METALOG.new
	cd $(DESTDIR) && mv METALOG.new METALOG
	cd $(DESTDIR) && mkdir -p home
	cd $(DESTDIR) && echo 'hostname="gfe"' > etc/rc.conf
	cd $(DESTDIR) && cp $(FSTAB) etc/fstab
	cd $(DESTDIR) && echo "./etc/fstab type=file uname=root gname=wheel mode=0644" >> METALOG
	cd $(DESTDIR) && echo "./etc/rc.conf type=file uname=root gname=wheel mode=0644" >> METALOG
	cd $(DESTDIR) && echo "./home type=dir uname=root gname=wheel mode=0755" >> METALOG
	makefs -N $(USERDB) -D -f 10000 -o version=2 -s $(IMAGE_SIZE) $(FREEBSD_IMAGE) METALOG

HOMEDIR=$(CURDIR)/obj/$(CURDIR)/$(FREEBSD_DIR)/riscv.riscv64
KERNDIR=$(HOMEDIR)/sys/riscv/conf
KERNCONF=TSFREEBSD-FPGA


kernel: # rootfs
	@echo "Building kernel"
	@echo 'include     "GENERIC"'                    > $(KERNDIR)/$(KERNCONF)
	@echo 'options     TMPFS'                        >> $(KERNDIR)/$(KERNCONF)
	@echo 'options     MD_ROOT'                      >> $(KERNDIR)/$(KERNCONF)
	@echo 'makeoptions   MFS_IMAGE=$(FREEBSD_IMAGE)'  >> $(KERNDIR)/$(KERNCONF)
	@echo 'options ROOTDEVNAME=\"ufs:/dev/md0\"'     >> $(KERNDIR)/$(KERNCONF)
	@cat $(KERNDIR)/$(KERNCONF)

#	./$(FREEBSD_DIR)/tools/build/make.py $(FLAGS) -j$(NPROCS) buildworld
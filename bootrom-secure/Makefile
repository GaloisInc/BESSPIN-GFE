bootrom_rev_mem = bootrom.bytereversed.mem
bootrom_mem = bootrom.mem
bootrom_coe = bootrom.coe

CCPATH 		?=
TARGET=$(CCPATH)riscv64-unknown-elf

XLEN?=32
NO_PCI?=0
CPU_SPEED?=0
RTC_FREQ?=0

ifeq ($(XLEN),64)
	ARCH		= -march=rv64imac
	ABI		= -mabi=lp64
	CLANG_ARCH 	= riscv64
	LLVM_TARGET = x86_64-pc-none-eabi
else
	XLEN		= 32 # if it's not 64 normalize it to 32
	ARCH		= -march=rv32im
	ABI		= -mabi=ilp32
	CLANG_ARCH	= riscv32
	LLVM_TARGET = i386-pc-none-eabi
endif

$(info XLEN=${XLEN})

# Decide which compiler to use
ifeq ($(USE_CLANG),yes)
	CC		= clang --target=$(CLANG_ARCH)
	# Note, we're always using the GCC CPP because it's just preprocessing
	# device trees
	CPP		= $(TARGET)-cpp
	# LLVM doesn't support linking RISC-V files yet,
	# so we have to use GCC linker to do so
	LD		= $(TARGET)-gcc
	OBJCOPY	= llvm-objcopy
	# LLVM doesn't uderstand debug symbols created by GCC linker
	# using GCC objdump for the time being (instead of llvm-objdump)
	OBJDUMP	= $(TARGET)-objdump
	AR		= llvm-ar
	RANLIB	= llvm-ranlib
else
	CC		= $(TARGET)-gcc
	CPP		= $(TARGET)-cpp
	LD		= $(CC)
	OBJCOPY	= $(TARGET)-objcopy
	OBJDUMP	= $(TARGET)-objdump
	AR		= $(TARGET)-ar
	RANLIB	= $(TARGET)-ranlib
endif

COMPILER_FLAGS = -ffreestanding -O0 -Wall -Wextra --std=c11 -MMD -I. -mcmodel=medany -static

CFLAGS += -O0 -g3 $(ARCH) $(ABI) $(COMPILER_FLAGS)

$(info CC=${CC})
$(info CFLAGS=${CFLAGS})

DTC=dtc

CLANG ?= clang
LLVM_LINK ?= llvm-link
LLVM_OPT ?= opt

C_OBJS= \
    main.o \
    string.o \
    sbassert.o \
    secure-boot/sha_256.o \
    secure-boot/peripherals.o \
    secure-boot/peripheral_commands.o \
    secure-boot/peripherals_generated_code.o \

OBJS= $(C_OBJS) \
    bootrom.o \

all: $(bootrom_mem) $(bootrom_coe) $(bootrom_rev_mem)

-include $(patsubst %.o,%.d,$(OBJS))
-include $(patsubst %.o,%.bcd,$(OBJS))

%.bcd: %.d
	cat $< | sed 's/\.o/.bc/' > $@

%.hex: %.bin
	hexdump -e '16/4 "%02x " "\n"' $< > $@

%.mem: %.bin
	(echo @00000000; od -tx4 -An -w4 -v $<) > $@

%.bytereversed.mem: %.mem
	cat $< | python byteReverseMem.py > $@

%.coe: %.hex
	python genCoe.py > $@

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.dtb: %.dts
	$(CPP) $(ARCH) $(ABI) -x assembler-with-cpp -DCPU_SPEED=$(CPU_SPEED) -DRTC_FREQ=$(RTC_FREQ) -DNO_PCI=$(NO_PCI) $< | $(DTC) -O dtb -o $@

bootrom.elf: $(OBJS) linker.ld devicetree.dtb
	$(CC) $(CFLAGS) -Tlinker.ld $(OBJS) -nostdlib -static -Wl,--no-gc-sections -o $@

%.bc: %.c
	$(CLANG) -DSAW_BUILD=1 -emit-llvm -MMD -O0 -g -target $(LLVM_TARGET) -c --std=c11 -I. -o $@ $<

check_sha256: bootrom.bc
	# We want to find a way to pass an argument to SAW, since we can read arbitrary
	# command-line arguments. Unfortunately, the SAW argument parser won't accept
	# other random arguments that we want to use in the saw script. We get around
	# this issue by abusing the --classpath option as a way to pass the bit-width
	# to the script. Since we're not using the java functionality, the value of
	# the classpath option remains untouched, so it's safe for use to abuse to
	# pass the bit-width.
	saw secure-boot/sha256_crucible.saw --classpath $(XLEN)

bootrom.bc: $(patsubst %.o,%.bc, $(C_OBJS))
	$(LLVM_LINK) -o $@ $^
	#$(LLVM_OPT) -o $@ -mem2reg unopt-$@

bootrom.o: bootrom.S devicetree.dtb
	$(CC) $(CFLAGS) -c -o bootrom.o bootrom.S
  
secure-boot/peripherals_generated_code.o: secure-boot/peripherals_generated_code.c devicetree.dtb
secure-boot/peripherals_generated_code.bc: secure-boot/peripherals_generated_code.c devicetree.dtb
secure-boot/peripherals_generated_code.c: $(wildcard secure-boot/peripherals/*.py)
	# NOTE: this should be python3-compatible, but some of our systems do
	# not have python3 installed, and it's not contained within their
	# package managers. For ease of portability, we use python2.
	python2 secure-boot/peripherals/config.py c_source > $@
secure-boot/PeripheralCommands.cry: $(wildcard secure-boot/peripherals/*.py)
	# NOTE: this should be python3-compatible, but some of our systems do
	# not have python3 installed, and it's not contained within their
	# package managers. For ease of portability, we use python2.
	python2 secure-boot/peripherals/config.py cryptol$(XLEN) > $@

check_secure_boot: secure-boot/PeripheralCommands.saw secure-boot/PeripheralCommands.cry bootrom.bc
	saw $<

check: check_secure_boot check_sha256
	@echo "ALL CHECKS PASSED"

clean:
	rm -f *.coe *.img bootrom.bin *.dtb *.dump *.elf *.mem.bytereversed *.mem $(OBJS) $(patsubst %.o,%.d,$(OBJS)) $(patsubst %.o,%.bcd,$(OBJS)) bootrom.bc unopt-bootrom.bc secure-boot/peripherals_generated_code.c secure-boot/PeripheralCommands.cry $(patsubst %.o,%.bc,$(OBJS))

reformat:
	clang-format -style=file -i $(shell find . -name '*.c') $(shell find . -name '*.h') $(shell find . -name '*.inc')
	yapf --in-place $(shell find secure-boot -name '*.py')

.PHONY: all clean reformat check check_sha256 check_secure_boot
.SECONDARY: bootrom.bin

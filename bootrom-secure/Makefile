bootrom_rev_mem = bootrom.bytereversed.mem
bootrom_mem = bootrom.mem
bootrom_coe = bootrom.coe

CROSS_COMPILE?=riscv64-unknown-elf-
CPP=$(CROSS_COMPILE)cpp
CC=$(CROSS_COMPILE)gcc
OBJCOPY=$(CROSS_COMPILE)objcopy
OBJDUMP=$(CROSS_COMPILE)objdump
DTC=dtc

CLANG ?= clang
LLVM_LINK ?= llvm-link
LLVM_OPT ?= opt

CFLAGS=-ffreestanding -O0 -Wall -Wextra --std=c11 -MMD -I. -mcmodel=medany -static

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

ifneq (,$(findstring 32,$(CROSS_COMPILE)))
    BIT_WIDTH_32=true
endif

ifdef BIT_WIDTH_32
    BIT_WIDTH=32
else
    BIT_WIDTH=64
endif

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
	$(CPP) -x assembler-with-cpp $< | $(DTC) -O dtb -o $@

bootrom.elf: $(OBJS) linker.ld devicetree.dtb
	$(CC) -Tlinker.ld $(OBJS) -nostdlib -static -Wl,--no-gc-sections -o $@

# We match the target width of the cross compilation target.
ifdef BIT_WIDTH_32
    LLVM_TARGET=i386-pc-none-eabi
else
    LLVM_TARGET=x86_64-pc-none-eabi
endif

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
	saw secure-boot/sha256_crucible.saw --classpath $(BIT_WIDTH)

bootrom.bc: $(patsubst %.o,%.bc, $(C_OBJS))
	$(LLVM_LINK) -o $@ $^
	#$(LLVM_OPT) -o $@ -mem2reg unopt-$@

bootrom.o: bootrom.S devicetree.dtb

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
	python2 secure-boot/peripherals/config.py cryptol$(BIT_WIDTH) > $@

check_secure_boot: secure-boot/PeripheralCommands.saw secure-boot/PeripheralCommands.cry bootrom.bc
	saw $<

check: check_secure_boot check_sha256
	@echo "ALL CHECKS PASSED"

clean:
	rm -f *.coe *.img *.bin *.dump *.elf *.mem.bytereversed *.mem $(OBJS) $(patsubst %.o,%.d,$(OBJS)) $(patsubst %.o,%.bcd,$(OBJS)) bootrom.bc unopt-bootrom.bc secure-boot/peripherals_generated_code.c secure-boot/PeripheralCommands.cry $(patsubst %.o,%.bc,$(OBJS))

reformat:
	clang-format -style=file -i $(shell find . -name '*.c') $(shell find . -name '*.h') $(shell find . -name '*.inc')
	yapf --in-place $(shell find secure-boot -name '*.py')

.PHONY: all clean reformat check check_sha256 check_secure_boot
.SECONDARY: bootrom.bin

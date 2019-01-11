#=======================================================================
# Makefile for riscv-tests/isa
#-----------------------------------------------------------------------

XLEN ?= 32

src_dir := .

default: all

#--------------------------------------------------------------------
# Build rules
#--------------------------------------------------------------------

RISCV_PREFIX ?= $(RISCV)/bin/riscv$(XLEN)-unknown-elf-
RISCV_GCC ?= $(RISCV_PREFIX)gcc
RISCV_GCC_OPTS ?= -static -mcmodel=medany -fvisibility=hidden -nostdlib -nostartfiles
RISCV_OBJDUMP ?= $(RISCV_PREFIX)objdump --disassemble-all --disassemble-zeroes --section=.text --section=.text.startup --section=.text.init --section=.data

vpath %.S $(src_dir)

#------------------------------------------------------------
# Build assembly tests

%.dump: build/%.elf
	$(RISCV_OBJDUMP) $< > $@

build/%.elf: %.S
	mkdir -p build
	$(RISCV_GCC) $< $(RISCV_GCC_OPTS) -I$(src_dir)/../macros -T$(src_dir)/../../targets/p1/p1.lds $< -o $@

#------------------------------------------------------------
# Default

all: build/add.elf

#------------------------------------------------------------
# Clean up

clean:
	rm -rf $(junk)

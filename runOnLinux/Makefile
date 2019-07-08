
XLEN ?= 32

ifeq ($(XLEN),32)
RISCV_LIB = elf
else ifeq ($(XLEN),64)
RISCV_LIB  = linux-gnu
else
$(error Invalid XLEN)
endif

TARGET=riscv${XLEN}-unknown-${RISCV_LIB}
GCC		= $(TARGET)-gcc
OBJCOPY	= $(TARGET)-objcopy
OBJDUMP	= $(TARGET)-objdump

.PHONY:
	clean default

default: binary.dump

binary2run: $(PROG)
	$(GCC) $< -o $@

binary.dump: binary2run
	$(OBJDUMP) -dS $< > $@

clean:
	rm -rf binary*
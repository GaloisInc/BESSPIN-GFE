bootrom_img = bootrom.img
bootrom_mem = bootrom.mem

GCC=riscv32-unknown-elf-gcc
OBJCOPY=riscv32-unknown-elf-objcopy
OBJDUMP=riscv32-unknown-elf-objdump

all: $(bootrom_img) $(bootrom_mem)

%.mem: %.bin
	hexdump -e '16/4 "%02x " "\n"' $*.bin > $*.hex
	python genMem.py > $@

%.img: %.bin
	dd if=$< of=$@ bs=128 count=1

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.dump: %.elf
	$(OBJDUMP) -d $< > $@

%.elf: %.S linker.ld
	$(GCC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@

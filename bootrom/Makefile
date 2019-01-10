bootrom_img = bootrom.img
bootrom_mem = bootrom.mem
bootrom_coe = bootrom.coe

GCC=riscv32-unknown-elf-gcc
OBJCOPY=riscv32-unknown-elf-objcopy
OBJDUMP=riscv32-unknown-elf-objdump

all: $(bootrom_img) $(bootrom_mem) $(bootrom_coe)

%.mem: %.bin
	hexdump -e '16/4 "%02x " "\n"' $*.bin > $*.hex
	python genMem.py > $@

%.coe: %.bin
	hexdump -e '16/4 "%02x " "\n"' $*.bin > $*.hex
	python genCoe.py > $@

%.img: %.bin
	dd if=$< of=$@ bs=128 count=1

%.bin: %.elf
	$(OBJCOPY) -O binary $< $@

%.dump: %.elf
	$(OBJDUMP) -d $< > $@

%.elf: %.S linker.ld
	$(GCC) -Tlinker.ld $< -nostdlib -static -Wl,--no-gc-sections -o $@

TOPDIR=..

XLEN=64

default_local: accel_aes2

include ../Makefile

accel_aes2: config.h  aes.h  aes.c  accel_aes2.c
	$(CC) -g -I$(TOPDIR)/lib -march=rv64imafd -mabi=lp64d \
		-specs=$(TOPDIR)/lib/bare.specs \
		-DRV64 -DCONSOLE_UART -mcmodel=medany  \
		-L$(TOPDIR)/lib  \
		-Wl,-e,_reset -Wl,-T$(TOPDIR)/lib/bare.lds  \
		-Wl,-Map,accel_aes2.map -Wl,-Ttext-segment=0x80000000  \
		accel_aes2.c  aes.c \
		-lm -o accel_aes2
	$(OBJDUMP) --all-headers --disassemble --source accel_aes2 > accel_aes2.text

.PHONY: install
install:
	cp -p  accel_aes2       ../bin_rv$(XLEN)
	cp -p  accel_aes2.map   ../bin_rv$(XLEN)
	cp -p  accel_aes2.text  ../bin_rv$(XLEN)

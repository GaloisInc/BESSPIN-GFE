TOPDIR=..

XLEN=64

default_local: accel_aes3

include ../Makefile

accel_aes3: accel_aes3.c
	$(CC) -g -I$(TOPDIR)/lib -march=rv64imafd -mabi=lp64d \
		-specs=$(TOPDIR)/lib/bare.specs \
		-DRV64 -DCONSOLE_UART -mcmodel=medany  \
		-L$(TOPDIR)/lib  \
		-Wl,-e,_reset -Wl,-T./bare.lds  \
		-Wl,-Map,accel_aes3.map -Wl,-Ttext-segment=0x80000000  \
		accel_aes3.c  \
		-lm -o accel_aes3
	$(OBJDUMP) --all-headers --disassemble --source accel_aes3 > accel_aes3.text

.PHONY: install
install:
	cp -p  accel_aes3       ../bin_rv$(XLEN)
	cp -p  accel_aes3.map   ../bin_rv$(XLEN)
	cp -p  accel_aes3.text  ../bin_rv$(XLEN)

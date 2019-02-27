#define FLASH_BASE 0x40000000

	.text
	.globl _start
_start:
	// Rocket apparently needs this, but it will likely trap on Piccolo and Flute
	csrwi 0x7c1, 0 // disable chicken bits

	csrr a0, mhartid
	la a1, _dtb

	//li t0, FLASH_BASE
	//jr t0
1:
	j 1b

	.data
	.globl _dtb
	.align 5, 0
_dtb:
	.incbin "devicetree.dtb"

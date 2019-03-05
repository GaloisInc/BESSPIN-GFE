#define FLASH_BASE 0x40000000

	.text
	.globl _start
_start:
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

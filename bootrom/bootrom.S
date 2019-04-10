#define BOOT_START 0x44000000

	.text
	.globl _start
_start:
	csrr a0, mhartid
	la a1, _dtb

#ifdef _BLUESPEC_P2_
1:
	j 1b
#else
	li t0, BOOT_START
	jr t0
#endif
	.data
	.globl _dtb
	.align 5, 0
_dtb:
	.incbin "devicetree.dtb"

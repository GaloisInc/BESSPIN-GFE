    .section .text_start, "ax", @progbits
    .globl _start
_start:
	csrr a0, mhartid
	la a1, _dtb

    // Now we need to setup the stack so that we can enter the C code
    // We place the stack high up in memory so that we're extraordinarily
    // unlikely to overwrite it when we copy the binary to boot into memory.
    li sp, 0xF0400000
    // The call operation doesn't misalign the stack, because it doesn't even
    // touch the stack. It just writes the return address to a register, which
    // ought to be caller-saved.
    call bootrom_main
    // If the call returns, we loop forever. It shouldn't return, though.
1:
    j 1b

    .section .rodata, "a", @progbits
    .globl _dtb
    .align 5, 0
_dtb:
    .incbin "devicetree.dtb"

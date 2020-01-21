OUTPUT_ARCH("riscv")
ENTRY("_start")

SECTIONS
{
    ROM_BASE       = 0x70000000;
    DRAM_BASE      = 0xC0000000;
/*
 * We intentionally have the end of the stack be the beginning of DRAM. This
 * way, (assuming nothing is mapped immediately before DRAM) stack overflows
 * will trigger a trap.
 */
    STACK_SIZE = 0x400000;
    STACK_MAX_ADDR = DRAM_BASE + STACK_SIZE;
/******************************************************************************
 * Exactly one of these lines should be commented. The other should be
 * uncommmented.
 */
    /*. = STACK_MAX_ADDR + 16;*/ /* For TESTING PURPOSES ONLY */
    . = ROM_BASE; /* For PRODUCTION */
/*****************************************************************************/
    .text :  { *(.text_start) *(.text.*) }
    .rodata : { *(.rodata.*) }
    /* We don't want to have mutable data in the bootrom. */
    /DISCARD/ :
    {
        *(.data)
        *(.sdata)
        *(.bss)
    }
}


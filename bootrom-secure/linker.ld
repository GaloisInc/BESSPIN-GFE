OUTPUT_ARCH("riscv")
ENTRY("_start")

SECTIONS
{
    ROM_BASE       = 0x70000000;
    DRAM_BASE      = 0xC0000000;
/* 
 * we intentionally place the stack high in RAM, so loading the actual trusted
 * binary into RAM doesn't clobber it.
 */
    STACK_BASE     = 0xF0000000;
    STACK_SIZE     = 0x400000;
    STACK_MAX_ADDR = STACK_BASE + STACK_SIZE;
    
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


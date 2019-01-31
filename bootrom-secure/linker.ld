SECTIONS
{
    ROM_BASE = 0x00000; /* ... but actually position independent */

    . = ROM_BASE;
    .text.start : { *(.text.start) }
}

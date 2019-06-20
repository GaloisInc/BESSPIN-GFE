OUTPUT_ARCH( "riscv" )
ENTRY(_start)

SECTIONS
{
  . = 0xC0000000;
  .text.init : { *(.text.init); . = ALIGN(0x1000); } = 0xaa
  . = ALIGN(0x1000);
  .tohost : { *(.tohost); . = ALIGN(0x1000); } = 0xaa
  . = ALIGN(0x1000);
  .text : { *(.text); . = ALIGN(0x1000); } = 0xaa
  . = ALIGN(0x1000);
  .data : { *(.data); . = ALIGN(0x1000); } = 0xaa
  . = ALIGN(8);
  _bss_begin = .;
  .bss : { *(.bss) }
  . = ALIGN(8);
  _end = .;
}


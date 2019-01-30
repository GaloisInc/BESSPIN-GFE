#define DRAM_BASE 0x80000000

.section .text.start, "ax", @progbits
.globl _start
_start:
  csrwi 0x7c1, 0 // disable chicken bits
  csrr a0, mhartid
  csrwi mie, 0
1:
  j 1b


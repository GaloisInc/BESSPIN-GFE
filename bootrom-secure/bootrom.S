#define DRAM_BASE 0x80000000
#define UART_REG 0x6000101C

.section .text.start, "ax", @progbits
.globl _start
_start:
  csrwi 0x7c1, 0 // disable chicken bits
  csrr a0, mhartid
  csrwi mie, 0
1:
  wfi
  j 1b


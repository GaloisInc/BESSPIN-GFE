SECTIONS
{
    __startup_save = .;
    .startup 0xc0000000: { KEEP(startup.o(.text)) }
    . = __startup_save;
}
INSERT AFTER .bss;
INPUT(syscalls.o)
INPUT(riscv_counters.o)
INPUT(ns16550.o)

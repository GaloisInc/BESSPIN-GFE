from types import SimpleNamespace


addr_map = SimpleNamespace(
    # GFE peripheral address space

    ########### DDR ############
    DDR_BASE=0x80000000,

    ########### BOOTROM ############
    BOOTROM_BASE=0x70000000,
    BOOTROM_SIZE=0x1000,

    ########### UART ############
    UART_BASE=0x62300000,
    UART_SCR=0x1C, # offset of UART scratch register
    UART_LSR=0x14,
    UART_IIR=0x8,
    UART_LCR=0xc, # line control register
    UART_DLL=0x0, # Divisor Latch LSB
    UART_DLM=0x4, # Divisor Latch MSB

    ########### RESET ###########
    RESET_BASE=0x6FFF0000,
    RESET_VAL =0x1,

    ########### PLIC ###########
    PLIC_BASE=0xc000000,
    PLIC_PRIORITY_OFFSET=0x0000,
    PLIC_PENDING_OFFSET=0x1000,
    PLIC_ENABLE_OFFSET=0x2000,
    PLIC_THRESHOLD_OFFSET=0x200000,
    PLIC_CLAIM_OFFSET=0x200004,
    PLIC_MAX_SOURCE=1023,
    PLIC_SOURCE_MASK=0x3FF,
    PLIC_MAX_TARGET=15871,
    PLIC_TARGET_MASK=0x3FFF,
    PLIC_NUM_INTERRUPTS=16,
)

gdb_params = SimpleNamespace(
    gdb='riscv64-unknown-elf-gdb',
    openocd='openocd',
    openocd_config_filename='openocd.cfg',
    timeout=60,
    xlen=32,
)
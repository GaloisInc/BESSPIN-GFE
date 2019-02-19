from lib import *


def UART(base, size):
    # For the UART specified in
    # https://www.xilinx.com/support/documentation/ip_documentation/axi_uart16550/v2_0/pg143-axi-uart16550.pdf
    # Our documentation of the assurance case, is explaining why we don't either
    # read or write some bit.
    d = Device('UART', base, size)
    UART_LCR = base + 0xC

    # bit 7 of the LCR is used to control access to other pieces of the UART.
    # Updating this bit will be a common operation.
    def set_lcr_7(flag):
        d.comment('Setting bit 7 of the LCR to %r' % flag)
        d.fence()
        d.write8(UART_LCR, 0b10111111, (1 if flag else 0) << 7)
        d.fence()

    ###########################################################################
    # Receiver Buffer Register
    # We don't read anything from here, since this is just the bytes that come in
    # on UART.
    ###########################################################################

    ###########################################################################
    # Transmitter Holding Register
    # This register is write-only, so we can't check it. In addition, this register
    # is only used to send bytes on the UART, so it doesn't control its state.
    ###########################################################################

    ###########################################################################
    # Interrupt Enable Register
    UART_IER = base + 0x4
    set_lcr_7(False)
    # Bits 31-4 cannot be accessed. We read all the other bits.
    d.write8(UART_IER, 0b0001111, 0)
    ###########################################################################

    ###########################################################################
    # Interrupt Identification Register
    UART_IIR = base + 0x8
    # Bits 31-8 cannot be acessed. Bits 3-0 represent current interrupts. We don't
    # want to touch that piece of state.
    # This is a read-only register.
    d.read8(UART_IIR, 0b11110000, 0)
    ###########################################################################

    ###########################################################################
    # FIFO Control Register
    UART_FCR = base + 0x8
    # Bits 31-8 are not accessible.
    # According to the docs, we can write to the FIFO control register regardless
    # of the status of LCR(7). We can only read it when it's high, however.
    set_lcr_7(True)
    d.write8(UART_FCR, 0b11001111, 0)
    # Read the reserved bits. They should be 0
    d.read8(UART_FCR, 0b00110000, 0)
    ###########################################################################

    ###########################################################################
    # Line Control Register
    # Bits 31-8 are not accessible.
    # We don't touch bit 7, since it's used to control access to various bits in
    # the UART. It's being written to in other places.
    d.write8(UART_LCR, 0b0111111, 0)
    ###########################################################################

    ###########################################################################
    # Modem Control Register
    UART_MCR = base + 0x10
    # Bits 31-8 are not accessible.
    # We don't touch bit 7, since it's used to control access to various bits in
    # the UART. It's being written to in other places.
    d.write8(UART_MCR, 0b00011111, 0)
    d.read8(UART_MCR, 0b11100000, 0)
    ###########################################################################

    ###########################################################################
    # Line Status Register
    UART_LSR = base + 0x14
    # Bits 31-8 are not accessible.
    d.write8(UART_MCR, 0b11111111, 0b01100000)
    ###########################################################################

    # TODO: MODEM STATUS REGISTER, what do we do for this?

    ###########################################################################
    # Scratch Register
    UART_SCRATCH = base + 0x1c
    # Bits 31-8 are not accessible.
    d.write8(UART_SCRATCH, 0b11111111, 0)
    ###########################################################################

    ###########################################################################
    # Divisor Latch
    set_lcr_7(True)
    # Bits 31-8 are not accessible for either the LSB or MSB register.
    UART_DIVISOR_LATCH_LSB = base + 0x00
    UART_DIVISOR_LATCH_MSB = base + 0x04
    d.write8(UART_DIVISOR_LATCH_LSB, 0b11111111, 0)
    d.write8(UART_DIVISOR_LATCH_MSB, 0b11111111, 0)
    ###########################################################################

    set_lcr_7(False)  # reset this to the default at the end
    return d

import fixtures


"""Smoke tests for GFE peripherals."""


def test_soft_reset(addr_map, gdb):
    """
    Write to a UART register and ensure the value is reset after calling softReset.
    """
    # UART scratch register address
    scratch = addr_map.UART_BASE + addr_map.UART_SCR
    test_value = 0xef

    # Check the initial reset value
    initial_scr_value = gdb.riscvRead32(scratch)
    assert initial_scr_value == 0x0

    # Write to the UART register, check that the write succeeded
    gdb.riscvWrite32(scratch, test_value)
    scr_value = gdb.riscvRead32(scratch)
    assert scr_value == test_value

    # Reset the SoC, check that the value was reset
    gdb.softReset()
    reset_scr_value = gdb.riscvRead32(scratch)
    assert reset_scr_value == 0x0

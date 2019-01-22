#!/usr/bin/env python
"""Script to run a compiled elf on the GFE
"""

import unittest
import argparse
import gfetester
import gfeparameters
import os
import time


class TestGfe(unittest.TestCase):

    def setUp(self):
        self.gfe = gfetester.gfetester()
        self.gfe.startGdb()
        self.path_to_asm = os.path.join(
                os.path.dirname(os.getcwd()), 'baremetal', 'asm')

    def tearDown(self):
        if not self.gfe.gdb_session:
            return
        self.gfe.gdb_session.interrupt()
        self.gfe.gdb_session.command("disassemble", ops=20)
        self.gfe.gdb_session.command("info registers all", ops=100)
        self.gfe.gdb_session.command("flush regs")
        self.gfe.gdb_session.command("info threads", ops=100)
        del self.gfe

    def test_uart(self):
        # Load up the UART test program
        uart_elf = os.path.abspath(
            os.path.join(self.path_to_asm, 'rv32ui-p-uart'))
        self.gfe.setupUart(
            timeout = 1,
            baud=9600,
            parity="NONE",
            stopbits=2,
            bytesize=8)
        self.gfe.launchElf(uart_elf)

        for test_char in [b'a', b'z', b'd']:
            print("sent {}".format(test_char))
            self.gfe.uart_session.write(test_char)
            b = self.gfe.uart_session.read()
            print("received {}".format(b))
            self.assertEqual(
                b, test_char,
                "Character received %x does not match test test_char %x".format(
                    b, test_char) )
        return

    def test_uart_driver(self):
        uart_base = gfeparameters.UART_BASE;
        # Load FreeRTOS binary
        print( "beginning")
        freertos_elf = os.path.abspath(
           os.path.join( os.path.dirname(
           os.getcwd()), 'riscv-p1-vcu118.elf'))
        # Setup pi serial UART
        self.gfe.setupUart(
            timeout = 1,
            baud=9600,
            parity="NONE",
            stopbits=2,
            bytesize=8)
        print( "setup UART")
        # Run elf in gdb
        self.gfe.launchElf(freertos_elf)
        print( "launched freertos")
        # Examine LSR (line status register)
        #print("Line status register: ")
        #self.gfe.r.command("x/1w 0x62300014", ops=4)
        #self.gfe.riscvRead32( uart_base + 20 )
        #self.gfe.gdb_session.interrupt()
        #self.gfe.gdb_session.command("x/1w 0x62300014")
        # Examine LCR (line control register)
        #print("Line control register: ")
        #self.gfe.r.command("x/1w 0x6230000c", ops=4)
        
        
        rx = self.gfe.uart_session.read()
        print("received 1 {}".format(rx))

        self.gfe.uart_session.write( b'a' )
        print( "Sent 'a'")
        
        rx = self.gfe.uart_session.read()
        print("received 2 {}".format(rx))

        return

    def test_ddr(self):
        # Read the base address of ddr
        ddr_base = gfeparameters.DDR_BASE
        base_val = self.gfe.riscvRead32(ddr_base)
        # Perform enough writes to force a writeback to ddr
        addr_incr = 0x100000
        write_n = 10
        for i in range(write_n):
            self.gfe.riscvWrite32(
                ddr_base + i * addr_incr,
                i)
        # Perform enough reads to force a fetch from ddr
        for i in range(write_n):
            val = self.gfe.riscvRead32(
                ddr_base + i * addr_incr)
            self.assertEqual(i, val)
        return

    def test_bootrom(self):
        """Read some values bootrom and perform some basic checks"""

        # Read the first value from the bootrom
        bootrom_base = gfeparameters.BOOTROM_BASE
        bootrom_size = gfeparameters.BOOTROM_SIZE
        base_val = self.gfe.riscvRead32(bootrom_base)

        # Check that it isn't zeros or ones
        self.assertNotEqual(base_val, 0)
        self.assertNotEqual(base_val, 0xFFFFFFFF)

        # Read a value higher up in the address space
        self.assertGreater(bootrom_size, 0xf0)
        self.gfe.riscvRead32(
            bootrom_base + bootrom_size - 0xf0)

        # Make sure the read operations complete by checking
        # the first value again
        self.assertEqual(
            base_val,
            self.gfe.riscvRead32(bootrom_base)
            )
        return

if __name__ == '__main__':
    unittest.main()

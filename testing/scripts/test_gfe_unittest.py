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
        self.path_to_freertos = os.path.join(
                os.path.dirname(os.getcwd()), 'FreeRTOS-RISCV', 'Demo', 'p1-besspin')       

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

        # Allow the riscv program to get started and configure UART
        time.sleep(0.1)

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


class TestFreeRTOS(unittest.TestCase):

    def setUp(self):
        self.gfe = gfetester.gfetester()
        self.gfe.startGdb()
        self.path_to_freertos = os.path.join(
                os.path.dirname(os.path.dirname(os.getcwd())),
                'FreeRTOS-RISCV', 'Demo', 'p1-besspin')       

    def tearDown(self):
        if not self.gfe.gdb_session:
            return
        self.gfe.gdb_session.interrupt()
        self.gfe.gdb_session.command("disassemble", ops=20)
        self.gfe.gdb_session.command("info registers all", ops=100)
        self.gfe.gdb_session.command("flush regs")
        self.gfe.gdb_session.command("info threads", ops=100)
        del self.gfe
        
    def test_uart_driver(self):
        # Run with FreeRTOS elf built with
        # 'make MAIN_FILE=test_uart.c'
        # Load FreeRTOS binary
        freertos_elf = os.path.abspath(
           os.path.join( self.path_to_freertos, 'uart_test.elf'))
        print(freertos_elf)
        # Setup pySerial UART
        self.gfe.setupUart(
            timeout = 1,
            baud=9600,
            parity="NONE",
            stopbits=2,
            bytesize=8)
        print( "Setup UART")
        # Run elf in gdb
        self.gfe.launchElf(freertos_elf)
        print( "Launched FreeRTOS")

        # Allow FreeRTOS to boot up
        time.sleep(0.5)
        
        # Loopback test of chars 
        for test_char in [b'a', b'z', b'd']:
            self.gfe.uart_session.write(test_char)
            print("sent {}".format(test_char))
            rx = self.gfe.uart_session.read()
            print("received {}".format(rx))
            self.assertEqual(
                rx, test_char,
                "Character received %x does not match test test_char %x".format(
                    rx, test_char) )
        # Loopback test of strings
        for test_char in [b'H', b'e', b'l', b'l', b'o', b'!']:
            self.gfe.uart_session.write(test_char)
            print("sent {}".format(test_char))
            time.sleep(1)
        num_rxed =  self.gfe.uart_session.in_waiting
        rx = self.gfe.uart_session.read( num_rxed ) 
        print("received {}".format(rx))
        self.assertEqual(rx, 'Hello!')
        return   

    def test_freertos(self):
        # Load FreeRTOS binary
        freertos_elf = os.path.abspath(
           os.path.join( self.path_to_freertos, 'riscv-p1-vcu118.elf'))
        print(freertos_elf)
        # Setup pySerial UART
        self.gfe.setupUart(
            timeout = 1,
            baud=9600,
            parity="NONE",
            stopbits=2,
            bytesize=8)
        print( "Setup UART")
        # Run elf in gdb
        self.gfe.launchElf(freertos_elf)
        print( "Launched FreeRTOS")

        # Wait for FreeRTOS tasks to start and run
        # Making this sleep time longer will allow the timer callback
        # function in FreeRTOS main.c to check the demo tasks more times
        time.sleep(20)

        # Receive print statements
        num_rxed =  self.gfe.uart_session.in_waiting
        rx = self.gfe.uart_session.read( num_rxed ) 
        print("received {}".format(rx))

        # No auto-checking
        return

if __name__ == '__main__':
    unittest.main()

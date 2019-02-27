#!/usr/bin/env python
"""Script to run a compiled elf on the GFE
"""

import unittest
import argparse
import gfetester
import gfeparameters
import os
import time
import struct

# def requestReset():
#     print("Please manually reset the VCU118 by pressing the CPU Reset button (SW5) before running a FreeRTOS tests.")
#     raw_input("After resetting the CPU, press enter to continue...")

class BaseGfeTest(unittest.TestCase):
    def getArch(self):
        return 'rv32ui'

    def getGdbPath(self):
        if '32' in self.getArch():
            return gfeparameters.gdb_path32
        return gfeparameters.gdb_path64   

    def setUp(self):
        # Reset the GFE
        self.gfe = gfetester.gfetester(gdb_path=self.getGdbPath())
        self.gfe.startGdb()
        self.path_to_asm = os.path.join(
                os.path.dirname(os.getcwd()), 'baremetal', 'asm')
        self.path_to_freertos = os.path.join(
                os.path.dirname(os.getcwd()), 'FreeRTOS-RISCV', 'Demo', 'p1-besspin')       
        self.gfe.softReset()

    def tearDown(self):
        if not self.gfe.gdb_session:
            return
        self.gfe.gdb_session.interrupt()
        self.gfe.gdb_session.command("disassemble", ops=20)
        self.gfe.gdb_session.command("info registers all", ops=100)
        self.gfe.gdb_session.command("flush regs")
        self.gfe.gdb_session.command("info threads", ops=100)
        del self.gfe  

class TestGfe(BaseGfeTest):

    def test_soft_reset(self):
        """Write to the UART scratch register, then reset and check the value
        has been reset"""
        UART_SCRATCH_ADDR = gfeparameters.UART_BASE + gfeparameters.UART_SCR
        test_value = 0xef

        # Check the initial reset value
        scr_value = self.gfe.riscvRead32(UART_SCRATCH_ADDR)
        self.assertEqual(scr_value, 0x0)

        # Write to the UART register and check the write succeeded
        self.gfe.riscvWrite32(UART_SCRATCH_ADDR, test_value)
        scr_value = self.gfe.riscvRead32(UART_SCRATCH_ADDR)
        err_msg = "Value read from UART scratch register {} "
        err_msg += "does not match {} written to it."
        err_msg = err_msg.format(hex(scr_value), hex(test_value))
        self.assertEqual(test_value, scr_value, err_msg)

        # Reset the SoC
        self.gfe.softReset()

        # Check that the value was reset
        scr_value = self.gfe.riscvRead32(UART_SCRATCH_ADDR)
        self.assertEqual(scr_value, 0x0)

    def test_uart(self):
        # Load up the UART test program
        print("arch = " + self.getArch())
        if '64' in self.getArch():
            uart_elf = 'rv64ui-p-uart'
        else:
            uart_elf = 'rv32ui-p-uart'

        uart_elf_path = os.path.abspath(
            os.path.join(self.path_to_asm, uart_elf))
        print("Using: " + uart_elf_path)
        self.gfe.setupUart(
            timeout=1,
            baud=9600,
            parity="EVEN",
            stopbits=2,
            bytesize=8)

        self.gfe.launchElf(uart_elf_path)

        # Allow the riscv program to get started and configure UART
        time.sleep(0.2)

        for test_char in [b'a', b'z', b'd']:

            self.gfe.uart_session.write(test_char)
            print("host sent ", test_char)
            b = self.gfe.uart_session.read()
            print("riscv received ", b)
            self.assertEqual(
                b, test_char,
                "Character received {} does not match test test_char {}".format(
                    b, test_char) )
        return

    def test_interrupt(self):
        if '64' in self.getArch():
            interrupt_elf = 'rv64ui-p-uart_interrupt'
        else:
            interrupt_elf = 'rv32ui-p-uart_interrupt'

        # Load the UART Interrupt test program
        interrupt_elf_path = os.path.abspath(
            os.path.join(self.path_to_asm, interrupt_elf))
        self.gfe.setupUart(
            timeout = 1,
            baud=9600,
            parity="EVEN",
            stopbits=2,
            bytesize=8)
        self.gfe.launchElf(interrupt_elf_path)

        # Allow the riscv program to get started and configure UART
        time.sleep(0.1)

        # Run test 10 times
        for test_run in range(0,10):

            # DEBUG
            self.gfe.gdb_session.interrupt()
            self.gfe.gdb_session.command("x/10i $pc")
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_ENABLE_OFFSET,
                dbg_txt="INTERRUPT_ENABLE", verbose=True)
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET,
                dbg_txt="PRIORITY 0", verbose=True)
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET + 1,
                dbg_txt="PRIORITY 1", verbose=True)           
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PENDING_OFFSET,
                dbg_txt="INTERRUPT PENDING", verbose=True)
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_CLAIM_OFFSET,
                dbg_txt="CLAIM REG", verbose=True)
            self.gfe.riscvRead32(gfeparameters.UART_BASE + gfeparameters.UART_LSR,
                dbg_txt="UART_LSR", verbose=True)
            # print(self.gfe.getGdbLog())
            self.gfe.gdb_session.c(wait=False)
            # END DEBUG

            print("Generating interrupt #{}".format(test_run))
            self.gfe.uart_session.write("0")

            # DEBUG
            self.gfe.gdb_session.interrupt()
            self.gfe.gdb_session.command("x/10i $pc")
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_ENABLE_OFFSET,
                dbg_txt="INTERRUPT_ENABLE", verbose=True)
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET,
                dbg_txt="PRIORITY 0", verbose=True)
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET + 1,
                dbg_txt="PRIORITY 1", verbose=True)           
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PENDING_OFFSET,
                dbg_txt="INTERRUPT PENDING", verbose=True)
            self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_CLAIM_OFFSET,
                dbg_txt="CLAIM REG", verbose=True)
            self.gfe.riscvRead32(gfeparameters.UART_BASE + gfeparameters.UART_LSR,
                dbg_txt="UART_LSR", verbose=True)
            # print(self.gfe.getGdbLog())
            self.gfe.gdb_session.c(wait=False)
            # END DEBUG

            res = self.gfe.uart_session.read()
            self.assertEqual(res, str(test_run))
            print("\tReceived interrupt #{}".format(test_run))
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

class TestGfe32(TestGfe):

    def getArch(self):
        return 'rv32ui'

class TestGfe64(TestGfe):

    def getArch(self):
        return 'rv64ui'

class TestFreeRTOS(BaseGfeTest):

    def setUp(self):
        # Reset the GFE
        self.gfe = gfetester.gfetester(gdb_path=self.getGdbPath())
        self.gfe.startGdb()
        self.gfe.softReset()
        self.path_to_freertos = os.path.join(
                os.path.dirname(os.path.dirname(os.getcwd())),
                'FreeRTOS-mirror', 'FreeRTOS', 'Demo',
                'RISC-V_Galois_P1')
        # Setup pySerial UART
        self.gfe.setupUart(
            timeout = 1,
            baud=9600,
            parity="NONE",
            stopbits=2,
            bytesize=8)
        print("Setup pySerial UART")     

    def test_full(self):
        # Load FreeRTOS binary
        freertos_elf = os.path.abspath(
           os.path.join( self.path_to_freertos, 'main_full.elf'))
        print(freertos_elf)
        
        # Run elf in gdb
        self.gfe.launchElf(freertos_elf)

        time.sleep(3)

        # Receive print statements
        num_rxed =  self.gfe.uart_session.in_waiting
        rx = self.gfe.uart_session.read( num_rxed ) 
        print("received {}".format(rx))

        self.assertIn("main_full", rx)
        self.assertIn("Pass", rx)

        return
        
    def test_blink(self):
        # Load FreeRTOS binary
        freertos_elf = os.path.abspath(
           os.path.join( self.path_to_freertos, 'main_blinky.elf'))
        print(freertos_elf)
        
        # Run elf in gdb
        self.gfe.launchElf(freertos_elf, True, False)
        print( "Launched FreeRTOS")

        # Wait for FreeRTOS tasks to start and run
        # Making this sleep time longer will allow the timer callback
        # function in FreeRTOS main.c to run the demo tasks more times
        time.sleep(3)

        # Receive print statements
        num_rxed =  self.gfe.uart_session.in_waiting
        rx = self.gfe.uart_session.read( num_rxed ) 
        print("received {}".format(rx))

        # Check that important print statements were received
        self.assertIn("Blink", rx)
        self.assertIn("RX: received value", rx)
        self.assertIn("TX: sent", rx)
        self.assertIn("Hello from RX", rx)
        self.assertIn("Hello from TX", rx)

        # No auto-checking
        return

class TestFreeRTOS32(TestGfe):

    def getArch(self):
        return 'rv32ui'

class TestFreeRTOS64(TestGfe):

    def getArch(self):
        return 'rv64ui'

if __name__ == '__main__':
    unittest.main()

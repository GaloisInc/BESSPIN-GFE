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
import glob
from parameterized import parameterized

class BaseGfeTest(unittest.TestCase):
    """GFE base testing class. All GFE Python unittests inherit from this class"""
    def getXlen(self):
        return '32'

    def getGdbPath(self):
        if '32' in self.getXlen():
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
    """Collection of smoke tests to exercise the GFE peripherals.
    This class is inherited by TestGfe32 and TestGfe64 for testing P1
    and P2/3 processors respectively."""

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
        print("xlen = " + self.getXlen())
        if '64' in self.getXlen():
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

    # def test_interrupt(self):
    #     if '64' in self.getXlen():
    #         interrupt_elf = 'rv64ui-p-uart_interrupt'
    #     else:
    #         interrupt_elf = 'rv32ui-p-uart_interrupt'

    #     # Load the UART Interrupt test program
    #     interrupt_elf_path = os.path.abspath(
    #         os.path.join(self.path_to_asm, interrupt_elf))
    #     self.gfe.setupUart(
    #         timeout = 1,
    #         baud=9600,
    #         parity="EVEN",
    #         stopbits=2,
    #         bytesize=8)
    #     self.gfe.launchElf(interrupt_elf_path)

    #     # Allow the riscv program to get started and configure UART
    #     time.sleep(0.1)

    #     # Run test 10 times
    #     for test_run in range(0,10):

    #         # DEBUG
    #         self.gfe.gdb_session.interrupt()
    #         self.gfe.gdb_session.command("x/10i $pc")
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_ENABLE_OFFSET,
    #             dbg_txt="INTERRUPT_ENABLE", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET,
    #             dbg_txt="PRIORITY 0", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET + 4,
    #             dbg_txt="PRIORITY 1", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET + 8,
    #             dbg_txt="PRIORITY 2", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET + 12,
    #             dbg_txt="PRIORITY 3", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PENDING_OFFSET,
    #             dbg_txt="INTERRUPT PENDING", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_CLAIM_OFFSET,
    #             dbg_txt="CLAIM REG", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.UART_BASE + gfeparameters.UART_LSR,
    #             dbg_txt="UART_LSR", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.UART_BASE + gfeparameters.UART_IIR,
    #             dbg_txt="UART_IIR", verbose=True)
    #         self.gfe.gdb_session.c(wait=False)
    #         # END DEBUG

    #         print("Generating interrupt #{}".format(test_run))
    #         self.gfe.uart_session.write("0")

    #         # DEBUG
    #         self.gfe.gdb_session.interrupt()
    #         self.gfe.gdb_session.command("x/10i $pc")
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_ENABLE_OFFSET,
    #             dbg_txt="INTERRUPT_ENABLE", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET,
    #             dbg_txt="PRIORITY 0", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PRIORITY_OFFSET + 4,
    #             dbg_txt="PRIORITY 1", verbose=True)           
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_PENDING_OFFSET,
    #             dbg_txt="INTERRUPT PENDING", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.PLIC_BASE + gfeparameters.PLIC_CLAIM_OFFSET,
    #             dbg_txt="CLAIM REG", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.UART_BASE + gfeparameters.UART_LSR,
    #             dbg_txt="UART_LSR", verbose=True)
    #         self.gfe.riscvRead32(gfeparameters.UART_BASE + gfeparameters.UART_IIR,
    #             dbg_txt="UART_IIR", verbose=True)
    #         self.gfe.gdb_session.c(wait=False)
    #         # END DEBUG

    #         res = self.gfe.uart_session.read()
    #         self.assertEqual(res, str(test_run))
    #         print("\tReceived interrupt #{}".format(test_run))
    #     return

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

# Create test classes for 64 and 32 bit processors
class TestGfe32(TestGfe):

    def getXlen(self):
        return '32'

class TestGfe64(TestGfe):

    def getXlen(self):
        return '64'

# Create ISA unittest base class for P1 and P2 processors
class TestIsaGfe(BaseGfeTest):

    def run_isa_test(self, test_path):
        test_name = os.path.basename(test_path)
        if '32' in test_name:
            xlen = '32'
        if '64' in test_name:
            xlen = '64'
        if 'p' in test_name:
            return self.run_isa_p_test(xlen, test_path)
        if 'v' in test_name:
            return self.run_isa_v_test(xlen, test_path)           

    def run_isa_p_test(self, xlen, test_path):
        test_name = os.path.basename(test_path)
        print("Running {}".format(test_path))
        self.gfe.gdb_session.command("file {}".format(test_path))
        self.gfe.gdb_session.load()
        self.gfe.gdb_session.b("write_tohost")
        self.gfe.gdb_session.c()
        gp = self.gfe.gdb_session.p("$gp")
        self.assertEqual(gp, 1)
        return

    def run_isa_v_test(self, xlen, test_path):
        test_name = os.path.basename(test_path)
        print("Running {}".format(test_path))
        self.gfe.gdb_session.command("file {}".format(test_path))
        self.gfe.gdb_session.load()
        self.gfe.gdb_session.b("terminate")
        self.gfe.gdb_session.c()
        a0 = self.gfe.gdb_session.p("$a0")
        self.assertEqual(a0, 1)
        return

riscv_isa_tests_path = os.path.join(
    os.path.dirname(os.path.dirname(os.getcwd())),
    'riscv-tools',
    'riscv-tests',
    'isa')
p2_isa_list = glob.glob(os.path.join(riscv_isa_tests_path, 'rv64*-*-*'))
p2_isa_names = [os.path.basename(k) for k in p2_isa_list]
p2_isa_names = [k for k in p2_isa_names if '.' not in k] # Remove all .dump files etc
p2_isa_list = [os.path.join(riscv_isa_tests_path, k) for k in p2_isa_names]

p1_isa_list = glob.glob(os.path.join(riscv_isa_tests_path, 'rv32*-p-*'))
p1_isa_names = [os.path.basename(k) for k in p1_isa_list]
p1_isa_names = [k for k in p1_isa_names if '.' not in k] # Remove all .dump files etc
p1_isa_list = [os.path.join(riscv_isa_tests_path, k) for k in p1_isa_names]

# Create ISA unittests for P2
class TestP2IsaGfe(TestIsaGfe):

    def getXlen(self):
        return '64'

    def test_isa(self):
        for test_path in p2_isa_list:
            self.run_isa_test(test_path)

# Create ISA unittests for P1
class TestP1IsaGfe(TestIsaGfe):

    def getXlen(self):
        return '32'

    def test_isa(self):
        for test_path in p1_isa_list:
            self.run_isa_test(test_path)


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

    def getXlen(self):
        return '32'

class TestFreeRTOS64(TestGfe):

    def getXlen(self):
        return '64'

if __name__ == '__main__':
    unittest.main()

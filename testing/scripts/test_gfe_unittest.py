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
        return
        # self.assertEqual(sum([1, 2, 3]), 6, "Should be 6")

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
        print(self.gfe.getGdbLog())
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

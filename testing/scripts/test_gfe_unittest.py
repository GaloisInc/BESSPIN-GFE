#!/usr/bin/env python
"""Script to run a compiled elf on the GFE
"""

import unittest
import argparse
import gfetester
import os
import time


class TestAdd(unittest.TestCase):

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
        # Perform enough writes to force a writeback to ddr
        # Perform enough reads to force a read from ddr
        # Repeat this for several addresses. Test high addresses of ddr
        return

    def test_bootrom(self):
        """Read some values bootrom and perform some basic checks"""

        # Read the first value from the bootrom
        # Check that it isn't zeros or ones

        # Read some values higher up in the address space

        # Make sure the reads complete by checking the first value
        # again
        return

if __name__ == '__main__':
    unittest.main()

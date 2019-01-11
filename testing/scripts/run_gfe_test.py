#!/usr/bin/env python
"""Script to run a compiled test on the GFE
"""

import argparse
import gfetester
import os
import time

# Parse the input binary
parser = argparse.ArgumentParser(description='Run a binary test on the GFE.')
parser.add_argument("binary", required=True,
                    help="path to a RISCV elf", metavar="FILE",
                    type=str)
args = parser.parse_args()
if not os.path.exists(args.binary):
    raise Exception("Path {} does not exist".format(args.binary))

# Gdb into the GFE and run the elf
gfe = gfetester.gfetester()
gfe.startGdb(binary=args.binary)
gfe.gdb_session.load()
# Run the ELF
gfe.gdb_session.c(wait=False)
time.sleep(0.5)
gfe.gdb_session.interrupt()
print(gfe.gdb_session.command("info registers"))

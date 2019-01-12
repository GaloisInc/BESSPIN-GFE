#!/usr/bin/env python
"""Script to run a compiled elf on the GFE
"""

import argparse
import gfetester
import os
import time

# Parse the input binary and other arguments
parser = argparse.ArgumentParser(description='Run a binary test on the GFE.')
parser.add_argument(
    "binary",
    help="path to a RISCV elf", metavar="FILE",
    type=str)
tohost_desc = "tohost address. Memory address containing the "
tohost_desc += "passing condition of a test"
parser.add_argument(
    "--tohost",
    help=tohost_desc,
    default=0x80001000,
    type=int)
parser.add_argument(
    "--runtime",
    help="Seconds of wait time while running the program on the gfe",
    default=0.5,
    type=float)
args = parser.parse_args()

# Validate the inputs
if not os.path.exists(args.binary):
    raise Exception("Path {} does not exist".format(args.binary))

# Gdb into the GFE
gfe = gfetester.gfetester()
gfe.startGdb(binary=args.binary)
gdblog = open(gfe.gdb_session.logfiles[0].name, 'r')
openocdlog = open(gfe.openocd_session.logfile.name, 'r')

# Load the program, run it, then check for the passing condition
tohost_val = None
try:
    gfe.gdb_session.load()
    gfe.gdb_session.c(wait=False)
    time.sleep(args.runtime)
    gfe.gdb_session.interrupt()
    tohost_val = gfe.riscvRead32(args.tohost)
    print("tohost_val {}".format(tohost_val))
    print(gfe.gdb_session.command("info registers"))
except Exception as e:
    print("------- GDB Log -------")
    print(gdblog.read())
    # print("------- OpenOCD Log -------")
    # print(openocdlog.read())
    raise e

# Check if the test passed
# A one in the LSB of tohost indicates a passing test
if tohost_val == 1:
    msg = "passed"
elif tohost_val == 0:
    msg = "Did not complete. tohost value = 0"
else:
    msg = "failed"
print(
    "Test {} {} after running for {} seconds".format(
        args.binary, msg, args.runtime))

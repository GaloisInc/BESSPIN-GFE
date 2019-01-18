import os
import inspect

"""
Collection of parameters concerning the GFE and machine environment.
These parameters are used as default values for testing functions and classes.
"""

script_dir = os.path.dirname(
    os.path.abspath(
        inspect.getfile(inspect.currentframe())))
if 'RISCV' not in os.environ:
    raise Exception(
        "RISCV environment variable needs to be set " +
        "to the riscv-tools path")

gdb_port = 3333

# riscv_home = os.environ['RISCV']
riscv_home = "/besspin/riscv-tools"
gdb_path = os.path.join(riscv_home, "bin", "riscv32-unknown-elf-gdb")
openocd_command = os.path.join(riscv_home, "bin", "openocd")
openocd_cfg_path = os.path.join(
    os.path.dirname(script_dir), "targets", "p1_external_hs2.cfg")
uart_serial_dev = '/dev/ttyUSB1'

########### DDR ############
DDR_BASE = 0x80000000

########### BOOTROM ############
BOOTROM_BASE = 0x70000000
BOOTROM_SIZE = 0x1000

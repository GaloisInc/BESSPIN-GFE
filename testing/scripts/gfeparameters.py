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

riscv_home = os.environ['RISCV']
gdb_path = os.path.join(riscv_home, "bin", "riscv32-unknown-elf-gdb")
gdb_path32 = os.path.join(riscv_home, "bin", "riscv32-unknown-elf-gdb")
gdb_path64 = os.path.join(riscv_home, "bin", "riscv64-unknown-elf-gdb")
openocd_command = os.path.join(riscv_home, "bin", "openocd")
openocd_cfg_path = os.path.join(
    os.path.dirname(script_dir), "targets", "ssith_gfe.cfg")
# Can use 'auto' to search for correct UART port or override directly
uart_serial_dev = 'auto'

########### DDR ############
DDR_BASE = 0x80000000

########### BOOTROM ############
BOOTROM_BASE = 0x70000000
BOOTROM_SIZE = 0x1000

########### UART ############
UART_BASE = 0x62300000

########### RESET ###########
RESET_BASE = 0x6FFF0000
RESET_VAL  = 0x1

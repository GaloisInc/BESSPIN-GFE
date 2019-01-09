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
openocd_command = os.path.join(riscv_home, "bin", "riscv32-unknown-elf-gdb")
openocd_cfg_path = os.path.join(script_dir, "external_hs2.cfg")

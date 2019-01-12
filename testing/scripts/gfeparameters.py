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
openocd_command = os.path.join(riscv_home, "bin", "openocd")
openocd_cfg_path = os.path.join(
    os.path.dirname(script_dir), "targets", "p1_external_hs2.cfg")


# ------------------ UART Parameters ------------------

default_axi_clock_ns = 40
default_uart_baud = 9600

UART_BASE = 0x62300000

ULITE_RX = 0x00
ULITE_TX = 0x04
ULITE_STATUS = 0x08
ULITE_CONTROL = 0x0c

ULITE_REGION = 16

ULITE_STATUS_RXVALID = 0x01
ULITE_STATUS_RXFUL L 0x02
ULITE_STATUS_TXEMPTY = 0x04
ULITE_STATUS_TXFUL L 0x08
ULITE_STATUS_IE = 0x10
ULITE_STATUS_OVERRUN = 0x20
ULITE_STATUS_FRAME = 0x40
ULITE_STATUS_PARIT Y 0x80

ULITE_CONTROL_RST_TX = 0x01
ULITE_CONTROL_RST_RX = 0x02
ULITE_CONTROL_IE = 0x10
UART_AUTOSUSPEND_TIMEOUT = 3000


from lib import *

from ethernet import Ethernet
from uart import UART
from dram import DRAM
from flash_os import Flash_OS

RAM_DEVICE = DRAM(base=0xC0000000, size=0x40000000)
DEVICES = [
    Ethernet(base=0x62100000, size=256 * 1024),
    UART(base=0x62300000, size=4 * 1024),
    Flash_OS(flash_base=0x44000100, ram_base=0xC0000000, size=537356,
             sha256sum=0xa110cdd552e7388ee39c24a0ff5cb2b6f4cd15e9c1ebc317100fbcfe982138fb,
             ram_device=RAM_DEVICE)
]
BOOT_ADDRESS=0xC0000000

if __name__ == '__main__':
    peripherals_config(DEVICES, BOOT_ADDRESS)

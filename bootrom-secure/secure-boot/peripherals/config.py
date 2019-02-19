from lib import *

from ethernet import Ethernet
from uart import UART
from dram import DRAM
from flash_os import Flash_OS

RAM_DEVICE = DRAM(base=0x80000000, size=2 * 1024 * 1024 * 1024)
DEVICES = [
    Ethernet(base=0x62100000, size=256 * 1024),
    UART(base=0x62300000, size=4 * 1024),
    Flash_OS(flash_base=0x40000000, ram_base=0x80000000, size=8423280,
             sha256sum=0x70a6c1a560359502594450aafff1577639109d65a62766a3e845cedfb16b8217,
             ram_device=RAM_DEVICE)
]
BOOT_ADDRESS=0x80000000

if __name__ == '__main__':
    peripherals_config(DEVICES, BOOT_ADDRESS)

from lib import *

from ethernet import Ethernet
from uart import UART
from dram import DRAM
from flash_os import Flash_OS

RAM_DEVICE = DRAM(base=0xC0000000, size=0x40000000)
DEVICES = [
    Ethernet(base=0x62100000, size=256 * 1024),
    UART(base=0x62300000, size=4 * 1024),
    Flash_OS(flash_base=0x44000100, ram_base=0xC4000000, size=541028,
             sha256sum=0xfbc49333ec87ed7a78482f16667a13c32756ed5177b2cbdd1bc4acf7285f036d,
             ram_device=RAM_DEVICE)
]
BOOT_ADDRESS=0xC4000000

if __name__ == '__main__':
    peripherals_config(DEVICES, BOOT_ADDRESS)

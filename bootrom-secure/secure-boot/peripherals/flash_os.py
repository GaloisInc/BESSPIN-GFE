from lib import *
from dram import STACK_SIZE

def Flash_OS(flash_base, ram_base, size, sha256sum, ram_device):
    d = Device('Flash-based OS', flash_base, size, ram_device)
    assert(ram_base >= ram_device.start_addr + STACK_SIZE)
    d.copy(ram_base, flash_base, size)
    d.fence()
    d.sha256(ram_base, size, sha256sum)
    return d

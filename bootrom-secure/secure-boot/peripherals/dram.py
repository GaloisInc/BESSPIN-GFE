from lib import *

STACK_SIZE = 0x400000

def DRAM(base, size):
    return Device('DRAM', base, size)

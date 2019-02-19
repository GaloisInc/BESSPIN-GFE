from itertools import chain
from collections import namedtuple
import sys

# The instructions
_FENCE = object()
_Comment = namedtuple('Comment', 'contents')
_Read32 = namedtuple('Read32', 'addr mask expected_value')
_Write32 = namedtuple('Write32', 'addr mask value')
_Copy = namedtuple('Copy', 'dst src size')
_SHA256 = namedtuple('SHA256', 'addr size expected_value')

# NOTE: python3 should be preferred to python2 wherever possible. Python2 may
# run into problems with the integer type not being large enough for 64-bit
# architectures.


class Device(object):
    def __init__(self, name, start_addr, size, ram_device=None):
        self.name = name
        self.start_addr = start_addr
        self.size = size
        self.ram_device = ram_device
        self.instructions = []

    def comment(self, content):
        assert '\n' not in content
        self.instructions.append(_Comment(content))

    def fence(self):
        self.instructions.append(_FENCE)

    def _check_addr(self, start, size):
        assert type(start) == int
        assert type(size) == int
        assert size >= 0
        assert start >= self.start_addr
        assert start + size <= self.start_addr + self.size

    def _check_ram_addr(self, start, size):
        assert type(start) == int
        assert type(size) == int
        assert size >= 0
        assert start >= self.ram_device.start_addr
        assert start + size <= self.ram_device.start_addr + self.ram_device.size

    def _check_int32(self, v):
        assert type(v) == int
        assert 0 <= v
        assert v <= 0xffffffff

    def read32(self, addr, mask, expected_value):
        self._check_addr(addr, 4)
        assert (addr % 4) == 0
        self._check_int32(mask)
        self._check_int32(expected_value)
        assert (expected_value & (0xffffffff ^ mask)) == 0
        self.instructions.append(_Read32(addr, mask, expected_value))

    def write32(self, addr, mask, value):
        self._check_addr(addr, 4)
        assert (addr % 4) == 0
        self._check_int32(mask)
        self._check_int32(value)
        assert (value & (0xffffffff ^ mask)) == 0
        self.instructions.append(_Write32(addr, mask, value))

    def write8(self, addr, mask, value):
        offset = addr % 4
        self.write32(addr - offset, mask << (offset * 8),
                     value << (offset * 8))

    def read8(self, addr, mask, value):
        offset = addr % 4
        self.read32(addr - offset, mask << (offset * 8), value << (offset * 8))

    def copy(self, dst_addr, src_addr, size):
        self._check_addr(src_addr, size)
        self._check_ram_addr(dst_addr, size)
        assert dst_addr + size < src_addr or src_addr + size < dst_addr
        self.instructions.append(_Copy(dst_addr, src_addr, size))

    def sha256(self, addr, size, expected_value):
        self._check_ram_addr(addr, size)
        assert type(expected_value) == long
        assert 0 <= expected_value
        assert expected_value < pow(2,256)
        self.instructions.append(_SHA256(addr, size, expected_value))

    def __str__(self):
        return 'Device(%r, start_addr=0x%x, size=0x%x)' % (
            self.name, self.start_addr, self.size)


_TEMPLATE = '''
// DO NOT MODIFY. THIS FILE WAS AUTOMATICALLY GENERATED BY PYTHON CODE IN:
// secure-boot/peripherals
#include "peripherals_generated_code.h"

world_t secure_boot_measure_peripherals_internal(world_t world, bool* no_failures) {
%(peripheral_commands)s
return world;
}

void successful_secure_boot() {
    __asm__ volatile(
        "csrr a0, mhartid\\n\\t"
        "la a1, _dtb\\n\\t"
        "li t0, %(boot_address)s\\n\\t"
        "jr t0\\n\\t"
        ".data\\n\\t"
        ".globl _dtb\\n\\t"
        ".align 5, 0\\n"
        "_dtb:\\n\\t"
        ".incbin \\"../devicetree.dtb\\""
        :::);
}
'''

def sha256sum_to_bytes(sha256sum):
    bytes = []
    for i in xrange(32):
        # the int() looks funny; it's so that hex() will generate e.g. 0xff
        # instead of 0xffL
        bytes.insert(0, sha256sum % 256)
        sha256sum = sha256sum // 256
    return bytes

def sha256sum_to_c_struct(sha256sum):
    # the int() looks funny; it's so that hex() will generate e.g. 0xff instead of 0xffL
    return '(sha256_bytes){%s}' % ','.join(hex(int(byte)) for byte in sha256sum_to_bytes(sha256sum))

def sha256sum_to_cryptol_tuple(sha256sum):
    return '(%s)' % ','.join(str(byte) for byte in sha256sum_to_bytes(sha256sum))

def peripheral_commands_c_source(devices, boot_address):
    all_instructions = []
    for d in devices:
        all_instructions.append(_Comment('Starting device %s' % d))
        all_instructions += d.instructions
        all_instructions.append(_Comment('Ending device %s' % d))

    peripheral_commands = []
    for i in all_instructions:
        if i is _FENCE:
            peripheral_commands.append('world = secure_boot_cmd_fence(world);')
        elif isinstance(i, _Comment):
            peripheral_commands.append('// %s' % i.contents)
        elif isinstance(i, _Read32):
            peripheral_commands.append('''world = secure_boot_cmd_read32((uint32_t *)UINTMAX_C(%s), %sul, %sul, world, no_failures);'''
                % (hex(i.addr), hex(i.mask), hex(i.expected_value)))
        elif isinstance(i, _Write32):
            peripheral_commands.append('''world = secure_boot_cmd_write32((uint32_t *)UINTMAX_C(%s), %sul, %sul, world);'''
                % (hex(i.addr), hex(i.mask), hex(i.value)))
        elif isinstance(i, _Copy):
            peripheral_commands.append('''world = secure_boot_cmd_copy((uint8_t *)UINTMAX_C(%s), (uint8_t *)UINTMAX_C(%s), %sul, world);'''
                % (hex(i.dst), hex(i.src), hex(i.size)))
        elif isinstance(i, _SHA256):
            peripheral_commands.append('''world = secure_boot_cmd_sha256((uint8_t *)UINTMAX_C(%s), %sul, %s, world, no_failures);'''
                % (hex(i.addr), hex(i.size), sha256sum_to_c_struct(i.expected_value)))
        else:
            raise Exception('Unexpected instruction: %r' % i)

    return _TEMPLATE % dict(
        peripheral_commands='\n'.join(peripheral_commands),
        boot_address=boot_address)


def print_peripheral_commands_crytol_source(DEVICES, addr_width):
    print('''
// DO NOT MODIFY. THIS FILE WAS AUTOMATICALLY GENERATED BY PYTHON CODE IN:
// secure-boot/peripherals
type Word = [32]
type Addr = [%d]
type Mask = [32]
type World = [32]
type SHA256Sum = ([8], [8], [8], [8], [8], [8], [8], [8]
                 ,[8], [8], [8], [8], [8], [8], [8], [8]
                 ,[8], [8], [8], [8], [8], [8], [8], [8]
                 ,[8], [8], [8], [8], [8], [8], [8], [8])
type IOBit = World -> {world : World, no_failures : Bit}
type IO = World -> World

cmd_read32 : Addr -> Mask -> Word -> IOBit
cmd_read32 = undefined

cmd_write32 : Addr -> Mask -> Word -> IO
cmd_write32 = undefined

cmd_copy : Addr -> Addr -> Word -> IO
cmd_copy = undefined

cmd_fence : IO
cmd_fence = undefined

cmd_sha256 : Addr -> Word -> SHA256Sum -> IOBit
cmd_sha256 = undefined

never_fails : IO -> IOBit
never_fails f world = {world = f world, no_failures = True}

mempty : IOBit
mempty world = {world = world, no_failures = True}

mappend : IOBit -> IOBit -> IOBit
mappend f g world = {world = gRes.world, no_failures = fRes.no_failures && gRes.no_failures} where
  fRes = f world
  gRes = g (fRes.world)

out_0 : IOBit
out_0 = mempty
    '''.strip() % addr_width)

    all_instructions = list(
        chain.from_iterable(d.instructions for d in DEVICES))
    for i, insn in enumerate(all_instructions):
        if insn is _FENCE:
            insn_cryptol = 'never_fails cmd_fence'
        elif isinstance(insn, _Comment):
            insn_cryptol = 'mempty'
        elif isinstance(insn, _Read32):
            insn_cryptol = 'cmd_read32 %d %d %d' % (insn.addr, insn.mask, insn.expected_value)
        elif isinstance(insn, _Write32):
            insn_cryptol = 'never_fails (cmd_write32 %d %d %d)' % (insn.addr, insn.mask, insn.value)
        elif isinstance(insn, _Copy):
            insn_cryptol = 'never_fails (cmd_copy %d %d %d)' % (insn.dst, insn.src, insn.size)
        elif isinstance(insn, _SHA256):
            insn_cryptol = 'cmd_sha256 %d %d %s' % (insn.addr, insn.size, sha256sum_to_cryptol_tuple(insn.expected_value))
        else:
            raise Exception('Unexpected instruction: %r' % insn)
        print('out_%d : IOBit' % (i + 1))
        print('out_%d = mappend out_%d (%s)' % (i + 1, i, insn_cryptol))
    print('result : IOBit')
    print('result = out_%d' % len(all_instructions))


def peripherals_config(DEVICES, BOOT_ADDRESS):
    cmd = sys.argv[1] if len(sys.argv) > 0 else None
    if cmd == 'c_source':
        print(peripheral_commands_c_source(DEVICES, BOOT_ADDRESS))
    elif cmd == 'cryptol32':
        print_peripheral_commands_crytol_source(DEVICES, 32)
    elif cmd == 'cryptol64':
        print_peripheral_commands_crytol_source(DEVICES, 64)
    else:
        print('USAGE: python config.py (c_source | cryptol)')
        sys.exit(1)


__all__ = ['Device', 'peripherals_config']

#! /usr/bin/env python3

from argparse import ArgumentParser
from sys import exit


def main():
    parser = ArgumentParser(description='Run GFE unit tests.')
    parser.add_argument('arch', help='RISC-V arch string, e.g. rv32imac')
    parser.add_argument('bitfile', help='Path to Vivado .bit file')
    parser.add_argument('--eth', help='Test ethernet device',
        action='store_true')
    parser.add_argument('--flash', help='Test loading OS from flash',
        action='store_true')
    parser.add_argument('--freq', help='CPU frequency')
    parser.add_argument('--cc', help='C compiler command')
    args = parser.parse_args()

    program_fpga(args.bitfile)

    isa_ok = isa_test(args.arch)

    os_ok = False
    if '32' in args.arch:
        # Assuming 32-bit CPUs will only run FreeRTOS
        os_ok = freertos_test(ethernet=args.eth, flash=args.flash)
    elif '64' in args.arch:
        # Assuming 64-bit CPUs will only run Linux
        os_ok = linux_test(ethernet=args.eth, flash=args.flash)

    exit(0 if isa_ok and os_ok else 1)


def program_fpga(bitfile_path):
    pass


def isa_test(arch_string):
    pass


def freertos_test(ethernet=False, flash=False):
    pass


def linux_test(ethernet=False, flash=False):
    pass


if __name__ == '__main__':
    main()

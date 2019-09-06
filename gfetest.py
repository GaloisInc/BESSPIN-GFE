#! /usr/bin/env python3

from argparse import ArgumentParser
from pathlib import Path
from subprocess import run
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


def program_fpga(bitfile_path_string):
    bitpath = Path(bitfile_path_string)
    if not bitpath.is_file():
        print('Could not locate bitstream at {}'.format(bitpath))
        exit(1)
    ltxpath = bitpath.with_suffix('.ltx')
    if not ltxpath.is_file():
        print('Could not locate probe file at {}'.format(ltxpath))
        exit(1)
    print('Programming FPGA...')
    result = run([
        'vivado_lab',
        '-nojournal',
        '-notrace',
        '-nolog',
        '-source ./tcl/prog_bit.tcl',
        '-mode batch',
        '-tclargs {} {}'.format(bitpath, ltxpath),
    ])
    if result.returncode != 0:
        print('Programming FPGA failed!')
        exit(1)
    for junk in ('webtalk.log', 'webtalk.jou'):
        p = Path(junk)
        if p.is_file():
            p.unlink()


def isa_test(arch_string):
    pass


def freertos_test(ethernet=False, flash=False):
    pass


def linux_test(ethernet=False, flash=False):
    pass


if __name__ == '__main__':
    main()

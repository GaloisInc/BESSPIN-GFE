#! /usr/bin/env python3

from argparse import ArgumentParser
from pathlib import Path
from re import compile as regex
from subprocess import run
import sys
from unittest import defaultTestLoader, TextTestRunner

sys.path.insert(1, 'testing/scripts')
from test_gfe_unittest import mkTestGfe, TestFreeRTOS, TestLinux
from softReset import reset_gfe


if __name__ == '__main__':
    main()

def main():
    parser = ArgumentParser(description='Run GFE unit tests.')
    parser.add_argument('arch', help='RISC-V arch string, e.g. rv32imac')
    parser.add_argument('bitfile', help='Path to Vivado .bit file')
    parser.add_argument('--eth', help='Test ethernet device',
        action='store_true')
    parser.add_argument('--flash', help='Test loading OS from flash',
        action='store_true')
    parser.add_argument('--freq', help='CPU frequency in MHz',
        type=int, default=None)
    parser.add_argument('--cc', help='C compiler command',
        default=None)
    args = parser.parse_args()

    try:
        xlen = args.arch[2:4]
        assert xlen in ('32', '64')
    except (ValueError, AssertionError):
        print('Malformed arch string; it should start with rv32 or rv64')
        sys.exit(1)

    program_fpga(args.bitfile)

    # If either of these fail, there's no point in running OS tests.
    # They both should raise CalledProcessError on failure.
    soc_test(xlen, args.freq)
    isa_test(xlen, args.arch, args.cc)

    os_ok = False
    if xlen == '32':
        # Assuming 32-bit CPUs will only run FreeRTOS
        os_ok = freertos_test(ethernet=args.eth, flash=args.flash)
    elif xlen == '64':
        # Assuming 64-bit CPUs will only run Linux
        os_ok = linux_test(ethernet=args.eth, flash=args.flash)

    sys.exit(0 if os_ok else 1)


def program_fpga(bitfile_path_string):
    bitpath = Path(bitfile_path_string)
    if not bitpath.is_file():
        print('Could not locate bitstream at {}'.format(bitpath))
        sys.exit(1)
    ltxpath = bitpath.with_suffix('.ltx')
    if not ltxpath.is_file():
        print('Could not locate probe file at {}'.format(ltxpath))
        sys.exit(1)
    print('Programming FPGA...')
    run([
        'vivado_lab',
        '-nojournal',
        '-notrace',
        '-nolog',
        '-source ./tcl/prog_bit.tcl',
        '-mode batch',
        '-tclargs {} {}'.format(bitpath, ltxpath),
        ], check=True)
    for junk in ('webtalk.log', 'webtalk.jou'):
        p = Path(junk)
        if p.is_file():
            p.unlink()


def soc_test(xlen, cpu_mhz=None):
    if cpu_mhz is not None:
        cpu_mhz *= 1e6  # convert to Hz

    run(['make', 'XLEN={}'.format(xlen)],
        cwd='testing/baremetal/asm', check=True)

    TestClass = mkGfeTest(xlen, cpu_mhz)
    suite = defaultTestLoader.loadTestsFromTestCase(TestClass)
    TextTestRunner().run(suite)


def isa_test(xlen, arch_string, cc=None):
    if not cc:
        cc = 'riscv{}-unknown-elf-gcc'.format(xlen)

    run([
        'CC={}'.format(cc),
        './configure',
        '--with-xlen={}'.format(xlen),
        '--target=riscv{}-unknown-elf'.format(xlen)
        ], shell=True, cwd='riscv-tests', check=True)

    run('make', cwd='riscv-tests', check=True)

    gdbscript = 'test_{}'.format(xlen)
    run('gen-test-all {}'.format(arch_string),
        cwd='testing/scripts',
        stdout=open(gdbscript, 'w'))

    reset_gfe()

    # TODO: Optionally use test_gfe_unittest.TestP2IsaGfe test class
    # instead of calling GDB. Maybe it can be sped up?

    run(['riscv{}-unknown-elf-gdb', '--batch', '-x', gdbscript])
    ok = report_gdb_isa_results('gdb-client.log')
    if not ok:
        sys.exit(1)


def report_gdb_isa_results(logfile):
    current = None
    failed = []
    total = 0
    for line in open(logfile):
        if line.startswith('Loading ./testing/scripts/../../riscv-tests/isa'):
            current = line.rstrip().rsplit('/', 1)[-1]
        elif line.startswith('PASS') or line.startswith('FAIL'):
            if line.startswith('FAIL'):
                failed.append(current)
            current = None
            total += 1
    
    print('Ran {} ISA tests with {} failures.'.format(total, len(failed)))
    if failed:
        print('FAILED: ' + ', '.join(failed))
    
    ok = not failed and total > 0
    return ok


def freertos_test(ethernet=False, flash=False):
    pass


def linux_test(ethernet=False, flash=False):
    pass


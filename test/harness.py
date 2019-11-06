#! /usr/bin/env python3

from pexpect import spawn, which, TIMEOUT, EOF


class GdbError(Exception):
    pass


class GdbSession(object):
    '''Wraps a pseudo-terminal interface to GDB on the FPGA via OpenOCD.'''

    def __init__(self, gdb='riscv64-unknown-elf-gdb', openocd='openocd',
        openocd_config_filename='openocd.cfg', timeout=60, xlen=32):
        if not which(gdb):
            raise GdbError('Executable {} not found'.format(gdb))
        if not which(openocd):
            raise GdbError('Executable {} not found'.format(openocd))

        logfile = open('gdb.tmp.log', 'w')
        self.pty = spawn(gdb, encoding='utf-8', logfile=logfile, timeout=timeout)
        for command in [
            'set confirm off',
            'set width 0',
            'set height 0',
            'set print entry-values no',
            'set remotetimeout {}'.format(timeout),
            'set architecture riscv:rv{}'.format(xlen),
            'target remote | {} -c "gdb_port pipe; log_output openocd.tmp.log" -f {}'.format(
                openocd, openocd_config_filename)
        ]:
            self.pty.sendline(command)

    def __del__(self):
        self.pty.close()

    def wait(self):
        '''Wait for prompt.'''
        self.pty.expect(r'\(gdb\)')

    def cmd(self, gdb_command_string):
        try:
            self.pty.sendline(gdb_command_string)
            self.pty.expect('\n')
            self.wait()
        except TIMEOUT as exc:
            self.pty.close()
            raise GdbError('Timeout expired') from exc
        except EOF as exc:
            self.pty.close()
            raise GdbError('Read end of file') from exc
        return self.pty.before.strip()


# temporary smoketest; feed it a compiled ISA test
if __name__ == '__main__':
    from sys import argv
    print('Starting session...')
    gdb = GdbSession()
    print('Sending commands...')
    gdb.cmd('file {}'.format(argv[1]))
    gdb.cmd('load')
    gdb.cmd('b write_tohost')
    gdb.cmd('c')
    print('Deleting session...')
    del gdb
    print('finished!')

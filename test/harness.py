#! /usr/bin/env python3

import re
from subprocess import run, TimeoutExpired
from time import sleep

from pexpect import spawn, which, TIMEOUT, EOF
from pexpect.replwrap import REPLWrapper
import serial
import serial.tools.list_ports


class GdbError(Exception):
    pass


class GdbSession(object):
    '''Wraps a pseudo-terminal interface to GDB on the FPGA via OpenOCD.'''

    def __init__(self, gdb='riscv64-unknown-elf-gdb', openocd='openocd',
        openocd_config_filename='openocd.cfg', timeout=60):
        if not which(gdb):
            raise GdbError('Executable {} not found'.format(gdb))
        if not which(openocd):
            raise GdbError('Executable {} not found'.format(openocd))

        try:
            run([openocd, '-f', openocd_config_filename], timeout=0.5, capture_output=True)
        except TimeoutExpired as exc:
            log = str(exc.stderr, encoding='utf-8')
            match = re.search('XLEN=(32|64)', log)
            if match:
                xlen = int(match.group(1))
            else:
                raise GdbError('XLEN not found by OpenOCD')

        init_cmds = '\n'.join([
            'set confirm off',
            'set pagination off'
            'set width 0',
            'set height 0',
            'set print entry-values no',
            'set remotetimeout {}'.format(timeout),
            'set arch riscv:rv{}'.format(xlen),
            'target remote | {} -c "gdb_port pipe; log_output openocd.tmp.log" -f {}'.format(
                openocd, openocd_config_filename)
        ])

        logfile = open('gdb.tmp.log', 'w')
        self.pty = spawn(gdb, encoding='utf-8', logfile=logfile, timeout=timeout)
        self.repl = REPLWrapper(self.pty, '(gdb) ', None, extra_init_cmd=init_cmds)


    def __del__(self):
        self.pty.close()

    def cmd(self, gdb_command_string, timeout=-1):
        if not self.pty.isalive():
            raise GdbError('Dead process')
        try:
            reply = self.repl.run_command(gdb_command_string, timeout=timeout)
        except TIMEOUT as exc:
            self.pty.close()
            raise GdbError('Timeout expired') from exc
        except EOF as exc:
            self.pty.close()
            raise GdbError('Read end of file') from exc
        return reply

    def interrupt(self):
        # send ctrl-c and wait for prompt
        return self.cmd('\003')

    def c(self, timeout):
        try:
            self.cmd('c', timeout=timeout)
        except GdbError:
            self.interrupt()

    def x(self, address, size='w'):
        output = self.cmd("x/{} {:#x}".format(size, address))
        print('Read raw output: {}'.format(output))
        if ':' in output:
            value = int(output.split(':')[1], base=0)
        else:
            raise GdbError('Failed to read from address {:#x}'.format(address))
        return value

    def read32(self, address, debug_text=None):
        value = self.x(address=address, size="1w")
        if debug_text is not None:
            print("{} Read: {:#x} from {:#x}".format(
                debug_text, value, address))
        return value



class UartError(Exception):
    pass

# TODO: exercise and debug this with peripheral and OS tests
class UartSession(object):
    '''Wraps a serial interface to the UART on the FPGA.'''

    def __init__(self, port=None,
        search_vid=0x10C4, search_pid=0xEA70, timeout=None,
        baud=9600, parity="ODD", stopbits=2, bytesize=8):

        if port in (None, 'auto'):
            # Get a list of all serial ports with the desired VID/PID
            ports = [p for p in serial.tools.list_ports.comports()
                     if p.vid == search_vid and p.pid == search_pid]

            # Silabs chip on VCU118 has two ports;
            # locate port 1 from the hardware description
            for p in ports:
                if re.search('LOCATION=.*:1.1', p.hwid):
                    print("Located UART device at {} with serial number {}".format(
                        p.device, p.serial_number))
                    port = p.device

        if port in (None, 'auto'):
            raise UartError("Could not find a UART port with VID={:X}, PID={:X}".format(
                search_vid, search_pid))

        # Validate inputs and translate into serial settings
        def select(choice, options):
            valid_choice = options.get(choice)
            if valid_choice is None:
                raise ValueError('Invalid argument {}; use one of {}'.format(
                    choice, list(options.keys())))
            return valid_choice

        valid_parity = select(parity.lower(), {
            "odd": serial.PARITY_ODD,
            "even": serial.PARITY_EVEN,
            "none": serial.PARITY_NONE,
            None: serial.PARITY_NONE,
        })

        valid_stopbits = select(stopbits, {
            1: serial.STOPBITS_ONE,
            2: serial.STOPBITS_TWO,
        })

        valid_bytesize = select(bytesize, {
            5: serial.FIVEBITS,
            6: serial.SIXBITS,
            7: serial.SEVENBITS,
            8: serial.EIGHTBITS,
        })

        # Configure the serial connections 
        self.uart = serial.Serial(
            timeout=timeout,
            port=port,
            baudrate=baud,
            parity=valid_parity,
            stopbits=valid_stopbits,
            bytesize=valid_bytesize,
        )

        if not self.uart.is_open:
            self.uart.open()

    def send(self, data):
        if isinstance(data, str):
            data = data.encode('utf-8')
        try:
            num_bytes_written = self.uart.write(data)
        except serial.SerialException as exc:
            raise UartError('Timed out before write finished') from exc
        return num_bytes_written

    def read(self, timeout, decode=True):
        # Local timeout (in seconds) should be less than global timeout
        # passed to the Serial constructor, if any.
        rx = b''
        start_time = time.time()
        while time.time() < start_time + timeout:
            pending = self.uart.in_waiting
            if pending:
                    rx += self.uart.read(pending)
        if pending:
            raise UartError('Read timed out with {} bytes still pending'.format(
                pending))
        if decode:
            rx = str(rx, encoding='utf-8')
        return rx


# TODO: turn this into a 'test_isa.py' pytest suite with configurable test selection;
#       see gfe/verilator_simulators/run/Run_regression.py for arch string parsing?
def isa_tester(gdb, isa_exe_filename):
    # gdb script adapted from gfe/testing/scripts/gen-test-all
    soft_reset_cmd = 'set *((int *) 0x6FFF0000) = 1'
 
    if '-p-' in isa_exe_filename:
        breakpoint = 'write_tohost'
        tohost_var = '$gp'
    elif '-v-' in isa_exe_filename:
        breakpoint = 'terminate'
        tohost_var = '$a0'
    else:
        raise ValueError('Malformed ISA test filename')

    setup_cmds = [
        'dont-repeat',
        soft_reset_cmd,
        'monitor reset halt',
        'delete',
        'file ' + isa_exe_filename,
        'load',
        'break ' + breakpoint,
        'continue'
    ]
    print('Loading and running {} ...'.format(isa_exe_filename))
    for c in setup_cmds:
        gdb.cmd(c)

    raw_tohost = gdb.cmd(r'printf "%x\n", ' + tohost_var)
    tohost = int(raw_tohost.split('\r', 1)[0], 16)
    if tohost == 1:
        print('PASS')
    else:
        print('FAIL (tohost={:#x})'.format(tohost))


if __name__ == '__main__':
    from sys import argv
    print('Starting GDB session...')
    gdb = GdbSession()
    for filename in argv[1:]:
        isa_tester(gdb, filename)
    print('Deleting GDB session...')
    del gdb
    print('Finished!')

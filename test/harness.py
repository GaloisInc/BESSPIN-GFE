#! /usr/bin/env python3

from pexpect import spawn, which, TIMEOUT, EOF
import serial
import serial.tools.list_ports


class GdbError(Exception):
    pass


class GdbSession(object):
    '''Wraps a pseudo-terminal interface to GDB on the FPGA via OpenOCD.'''

    def __init__(self, gdb='riscv64-unknown-elf-gdb', openocd='openocd',
        openocd_config_filename='openocd.cfg', timeout=60, xlen='auto'):
        if not which(gdb):
            raise GdbError('Executable {} not found'.format(gdb))
        if not which(openocd):
            raise GdbError('Executable {} not found'.format(openocd))
        if xlen not in [32, 64, 'auto', None]:
            raise ValueError('Invalid xlen')

        logfile = open('gdb.tmp.log', 'w')
        self.pty = spawn(gdb, encoding='utf-8', logfile=logfile, timeout=timeout)
        for command in [
            'set confirm off',
            'set width 0',
            'set height 0',
            'set print entry-values no',
            'set remotetimeout {}'.format(timeout),
            'target remote | {} -c "gdb_port pipe; log_output openocd.tmp.log" -f {}'.format(
                openocd, openocd_config_filename)
        ]:
            self.pty.sendline(command)
        if xlen in ['auto', None]:
            # parse value from openocd.tmp.log
        self.pty.sendline('set architecture riscv:rv{}'.format(xlen))

    def __del__(self):
        self.pty.close()

    def wait_for_prompt(self):
        self.pty.expect_exact('(gdb) ')

    def cmd(self, gdb_command_string):
        if not self.pty.is_alive():
            raise GdbError('Dead process')
        try:
            self.pty.sendline(gdb_command_string)
            # self.pty.expect('\n')
            self.wait_for_prompt()
        except TIMEOUT as exc:
            self.pty.close()
            raise GdbError('Timeout expired') from exc
        except EOF as exc:
            self.pty.close()
            raise GdbError('Read end of file') from exc
        return self.pty.before.strip()


class UartError(Exception):
    pass


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
                m = re.search('LOCATION=.*:1.(\d)', p.hwid)
                if m:
                    if m.group(1) == '1':
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

        valid_parity = select(parity, {
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

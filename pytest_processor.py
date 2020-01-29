#! /usr/bin/env python3.7
import re
from subprocess import run, TimeoutExpired, CalledProcessError
import time
import os

from pexpect import spawn, which, TIMEOUT, EOF
from pexpect.replwrap import REPLWrapper
import serial
import serial.tools.list_ports

import argparse
import logging

import gfeconfig 

class GdbError(Exception):
    pass

class GdbSession(object):
    '''Wraps a pseudo-terminal interface to GDB on the FPGA via OpenOCD.'''

    def __init__(self, gdb='riscv64-unknown-elf-gdb', openocd='openocd',
        openocd_config_filename='./testing/targets/ssith_gfe.cfg', timeout=60):
        print_and_log("Starting GDB session...")
        if not which(gdb):
            raise GdbError('Executable {} not found'.format(gdb))
        if not which(openocd):
            raise GdbError('Executable {} not found'.format(openocd))
        xlen=32 # Default
        try:
            run_and_log("Starting openocd", run([openocd, '-f', openocd_config_filename], timeout=0.5, capture_output=True))
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
        print_and_log("Closing GDB session...")
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

    def cont(self):
        if not self.pty.isalive():
            raise GdbError('Dead process')
        self.pty.send("continue\n")

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
        print_and_log('Read raw output: {}'.format(output))
        if ':' in output:
            value = int(output.split(':')[1], base=0)
        else:
            raise GdbError('Failed to read from address {:#x}'.format(address))
        return value

    def read32(self, address, debug_text=None):
        value = self.x(address=address, size="1w")
        if debug_text is not None:
            print_and_log("{} Read: {:#x} from {:#x}".format(
                debug_text, value, address))
        return value

class UartError(Exception):
    pass

class UartSession(object):
    '''Wraps a serial interface to the UART on the FPGA.'''

    def __init__(self, port=None,
        search_vid=0x10C4, search_pid=0xEA70, timeout=1,
        baud=115200, parity="NONE", stopbits=2, bytesize=8):
        print_and_log("Starting UART session...")

        if port in (None, 'auto'):
            # Get a list of all serial ports with the desired VID/PID
            ports = [p for p in serial.tools.list_ports.comports()
                     if p.vid == search_vid and p.pid == search_pid]

            # Silabs chip on VCU118 has two ports;
            # locate port 1 from the hardware description
            for p in ports:
                if re.search('LOCATION=.*:1.1', p.hwid):
                    print_and_log("Located UART device at {} with serial number {}".format(
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

    def __del__(self):
        print_and_log("Closing UART session...")

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
        pending = None
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

    def read_and_check(self, timeout, expected_contents, absent_contents=None, decode=True):
        # Local timeout (in seconds) should be less than global timeout
        # passed to the Serial constructor, if any.
        rx = b''
        start_time = time.time()
        pending = None
        contains_expected_contents = False
        while time.time() < start_time + timeout:
            pending = self.uart.in_waiting
            if pending:
                new_data = self.uart.read(pending)
                rx += new_data
                res = [ (bytes(text, encoding='utf-8') in rx) for text in expected_contents]
                if all(res):
                    print_and_log("Early exit!")
                    contains_expected_contents = True
                    break
        if decode:
            rx = str(rx, encoding='utf-8')
        if contains_expected_contents:
            logging.debug(rx)
            if absent_contents:
                if absent_contents not in rx:
                    print_and_log("Absent contents not present")
                    return True, rx
                else:
                    print_and_log(rx)
                    print_and_log("Absent contents present!")
                    return False, rx
            print_and_log("All expected contents found")
            return True, rx
        else:
            print_and_log(rx)
            print_and_log("Expected contents NOT found!")
            return False, rx 

# ISA test code
def isa_tester(gdb, isa_exe_filename):
    print_and_log('Starting ISA test of ' + isa_exe_filename)
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
    print_and_log('Loading and running {} ...'.format(isa_exe_filename))
    for c in setup_cmds:
        gdb.cmd(c)

    raw_tohost = gdb.cmd(r'printf "%x\n", ' + tohost_var)
    tohost = int(raw_tohost.split('\r', 1)[0], 16)
    if tohost == 1:
        print_and_log('PASS')
        return True
    else:
        # check s-break instruction test
        if "sbreak" in isa_exe_filename and "do_break" in gdb.cmd("frame"):
            print_and_log('PASS')
            return True
        else:
            print_and_log('FAIL (tohost={:#x})'.format(tohost))
            return False

# Common FreeRTOS test code
def test_freertos_common(gdb, uart, config, prog_name):
    if config.compiler == "clang":
        use_clang="yes"
    else:
        use_clang="no"

    print_and_log("\nTesting: " + prog_name)
    run_and_log("Cleaning FreeRTOS program directory",
        run(['make','clean'],cwd=config.freertos_folder,
        env=dict(os.environ, USE_CLANG=use_clang, PROG=prog_name, XLEN=config.xlen), capture_output=True))
    run_and_log("Compiling: " + prog_name,
        run(['make'],cwd=config.freertos_folder,
        env=dict(os.environ, C_INCLUDE_PATH=config.freertos_c_include_path, USE_CLANG=use_clang,
        PROG=prog_name, XLEN=config.xlen), capture_output=True))
    filename = config.freertos_folder + '/' + prog_name + '.elf'
    res, rx =  freertos_tester(gdb, uart, filename,
        timeout=config.freertos_timeouts[prog_name],
        expected_contents=config.freertos_expected_contents[prog_name],
        absent_contents=config.freertos_absent_contents[prog_name])
    return res, rx

# Simple wrapper to test non-networking FreeRTOS programs
def test_freertos_single_test(uart, config, prog_name):
    gdb = GdbSession(openocd_config_filename=config.openocd_config_filename)
    res, _rx = test_freertos_common(gdb, uart, config, prog_name)
    del gdb
    return res

# Similar to `test_freertos` except after checking for expected contents it pings
# the FPGA
def test_freertos_network(uart, config, prog_name):
    import socket
    import select
    gdb = GdbSession(openocd_config_filename=config.openocd_config_filename)
    res, rx = test_freertos_common(gdb, uart, config, prog_name)

    # early exit
    if not res:
        del gdb
        return False

    # Get FPGA IP address
    riscv_ip = 0
    rx_list = rx.split('\n')
    for line in rx_list:
        index = line.find('IP Address:')
        if index != -1:
            ip_str = line.split()
            riscv_ip = ip_str[2]

    # Ping FPGA
    print("RISCV IP address is: " + riscv_ip)
    if (riscv_ip == 0) or (riscv_ip == "0.0.0.0"):
        raise Exception("Could not get RISCV IP Address. Check that it was assigned in the UART output.")
    print_and_log("Ping FPGA")
    ping_result = run(['ping','-c','10',riscv_ip], capture_output=True)
    print_and_log(str(ping_result.stdout,'utf-8'))
    if ping_result.returncode != 0:
        print_and_log("Ping FPGA failed")
        del gdb
        return False
    else:
        print_and_log("Ping OK")

    if prog_name == "main_udp":
        # Send UDP packet
        print_and_log("\n Sending to RISC-V's UDP echo server")
        # Create a UDP socket at client side
        UDPClientSocket = socket.socket(family=socket.AF_INET, type=socket.SOCK_DGRAM)
        msgFromClient       = "Hello UDP Server"
        bytesToSend         = msgFromClient.encode('utf-8')
        serverAddressPort   = (riscv_ip, 5006)
        bufferSize          = 1024

        # Send to server using created UDP socket
        UDPClientSocket.setblocking(0)
        UDPClientSocket.sendto(bytesToSend, serverAddressPort)
        ready = select.select([UDPClientSocket], [], [], 10)

        if ready[0]:
            msgFromServer = str((UDPClientSocket.recvfrom(bufferSize))[0],'utf-8')
            if msgFromClient != msgFromServer:
                print_and_log(prog_name + ": " + msgFromClient + " is not equal to " + msgFromServer)
                res = False
            else:
                print_and_log("UDP message received")
        else:
            print_and_log("UDP server timeout")
            res = False
    elif prog_name == "main_tcp":
        # Run TCP echo client
        print_and_log("\n Sending to RISC-V's TCP echo server")
        # Create a TCP/IP socket
        sock = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
        # Connect the socket to the port where the server is listening
        server_address = (riscv_ip, 7)
        print_and_log('connecting to %s port %s' % server_address)
        sock.connect(server_address)
        sock.setblocking(0)
        try:
            # Send data
            message = 'This is the message.  It will be repeated.'
            print_and_log('sending "%s"' % message)
            sock.sendall(message.encode('utf-8'))

            # Look for the response
            amount_received = 0
            amount_expected = len(message)

            while amount_received < amount_expected:
                ready = select.select([sock], [], [], 10)
                if ready[0]:
                    data = str(sock.recv(128),'utf-8')
                    amount_received += len(data)
                    print_and_log('received "%s"' % data)
                    if message != data:
                        print_and_log(prog_name + ": " + message + " is not equal to " + data)
                        res = False
                else:
                    print_and_log("TCP socket timeout")
                    res = False
                    break
        finally:
            print_and_log('closing socket')
            sock.close()
    else:
        print_and_log("Unknown FreeRTOS network test, doing nothing after pinging")

    del gdb
    return res

# FreeRTOS: load executable and check UART output
def freertos_tester(gdb, uart, exe_filename, timeout, expected_contents, absent_contents=None):
    print_and_log('Starting FreeRTOS test of ' + exe_filename)
    soft_reset_cmd = 'set *((int *) 0x6FFF0000) = 1'

    setup_cmds = [
        'dont-repeat',
        soft_reset_cmd,
        soft_reset_cmd, # reset twice to make sure we did reset
        'monitor reset halt',
        'delete',
        'file ' + exe_filename,
        'load',
    ]
    print_and_log('Loading and running {} ...'.format(exe_filename))
    for c in setup_cmds:
        gdb.cmd(c)
    print_and_log("Continuing")
    gdb.cont()

    res, rx = uart.read_and_check(timeout, expected_contents, absent_contents)
    if res:
        print_and_log('PASS')
        return True, rx
    else:
        print_and_log('FAIL')
        return False, rx

# Busybox basic tester - boots and waits if you see the console
def busybox_basic_tester(gdb, uart, exe_filename, timeout):
    print_and_log('Starting basic Busybox test using ' + exe_filename)
    soft_reset_cmd = 'set *((int *) 0x6FFF0000) = 1'
    expected_contents=["Please press Enter to activate this console"]
    absent_contents=None

    gdb.interrupt()
    setup_cmds = [
        'dont-repeat',
        soft_reset_cmd,
        'monitor reset halt',
        'delete',
        'file ' + exe_filename,
        'set $a0 = 0',
        'set $a1 = 0x70000020',
        'load',
    ]
    print_and_log('Loading and running {} ...'.format(exe_filename))
    for c in setup_cmds:
        gdb.cmd(c)

    print_and_log("Continuing")
    gdb.cont()

    res, rx = uart.read_and_check(timeout, expected_contents, absent_contents)
    if res:
        print_and_log('PASS')
        return True, rx
    else:
        print_and_log('FAIL')
        return False, rx

# Simple wrapper that prints as well as logs the message
def print_and_log(msg):
    print(msg)
    logging.debug(msg)

# Run command and log it
# Raise a runtime exception if it fails
def run_and_log(cmd, res, expected_contents=None):
    print_and_log(cmd)
    res_stdout = str(res.stdout,'utf-8')
    logging.debug(res_stdout)
    if expected_contents:
        if expected_contents in res_stdout:
            res.returncode = 0
        else:
            res.returncode = 1
    if res.returncode != 0:
        logging.debug(str(res.stderr,'utf-8'))
        msg = str("Running command failed: " + cmd + " Check test_processor.log for more details.")
        raise RuntimeError(msg)
    return res_stdout

# Run simulator tests and exit
def test_simulator(config):
    print_and_log("Run Verilator tests")
    run_and_log("Compiling ISA tests",
        run(['make'], cwd="./riscv-tests/isa", capture_output=True))

    run_and_log("Building Verilator simulator for " + config.proc_name,
        run(['make','simulator'],cwd="./verilator_simulators",
        env=dict(os.environ, PROC=config.proc_name), capture_output=True))

    run_and_log("Testing " + config.proc_name,
        run(['make','isa_tests'],cwd="./verilator_simulators/run",check=True,
        env=dict(os.environ, PROC=config.proc_name), capture_output=True))
    print_and_log("Verilator tests OK, exiting...")
    exit(0)    

# Program bitstream
def test_program_bitstream(config):
    if config.proc_name == 'bluespec_p1':
        run_and_log("Programming flash",
            run(['tcl/program_flash','datafile','./bootmem/small.bin'], capture_output=True),
            "Program/Verify Operation successful.")
    run_and_log("Programming bitstream",
        run(['./pyprogram_fpga.py', config.proc_name], capture_output=True))

# Assembly tests
def test_asm(config):
    print("ASM tests not implemented yet!")
    exit(1)
    run_and_log("Run ASM tests",
        run(['make','XLEN=' + config.xlen], cwd="./riscv-tests", capture_output=True))
    # TODO
    gdb = GdbSession(openocd_config_filename=config.openocd_config_filename)
    # ...
    del gdb

# Initialize processor test, set logging etc
def test_init():
    parser = argparse.ArgumentParser()
    parser.add_argument("proc_name", help="processor to test [chisel_p1|chisel_p2|chisel_p3|bluespec_p1|bluespec_p2|bluespec_p3]")
    parser.add_argument("--asm", help="run ASSEMBLY tests",action="store_true")
    parser.add_argument("--isa", help="run ISA tests",action="store_true")
    parser.add_argument("--busybox", help="run Busybox OS",action="store_true")
    parser.add_argument("--linux", help="run Debian OS",action="store_true")
    parser.add_argument("--freertos", help="run FreeRTOS OS",action="store_true")
    parser.add_argument("--network", help="run network tests",action="store_true")
    parser.add_argument("--io", help="run IO tests (P1 only)",action="store_true")
    parser.add_argument("--flash", help="run flash tests",action="store_true")
    parser.add_argument("--pcie", help="run PCIe tests (P2/P3 only)",action="store_true")
    parser.add_argument("--no-pcie", help="build without PCIe support (P2/P3 only)",action="store_true")
    parser.add_argument("--no-bitstream",help="do not upload bitstream",action="store_true")
    parser.add_argument("--compiler", help="select compiler to use [gcc|clang]",default="gcc")
    parser.add_argument("--simulator", help="run in verilator",action="store_true")
    args = parser.parse_args()

    gfeconfig.check_environment()

    run(['rm','-rf','test_processor.log'])
    logging.basicConfig(filename='test_processor.log',level=logging.DEBUG,format='%(asctime)s %(message)s', datefmt='%m/%d/%Y %I:%M:%S %p')
    print_and_log("Test processor starting.")

    return args

# ISA tests
def test_isa(config):
    print_and_log("Run ISA tests")
    gdb = GdbSession(openocd_config_filename=config.openocd_config_filename)
    
    run_and_log("Compiling ISA tests",
        run(['./configure','--target=riscv64-unknown-elf',
        '--with-xlen=' + config.xlen],cwd="./riscv-tests",
        env=dict(os.environ, CC="riscv64-unknown-elf-gcc"), capture_output=True))
    run_and_log("", run(['make'], cwd="./riscv-tests", capture_output=True))

    res = run_and_log("Generating a list of available ISA tests",
        run(['./testing/scripts/gen-test-all',config.xarch], capture_output=True))
    files = res.split("\n")

    isa_failed = []  
    
    for filename in files:
        if filename:
            if not isa_tester(gdb, filename):
                isa_failed.append(filename)

    del gdb
    if isa_failed:
        raise RuntimeError("ISA tests failed: " + str(isa_failed))
    print_and_log("ISA test passed")

# FreeRTOS tests
def test_freertos(config, args):
    print_and_log("Run FreeRTOS tests")
    uart = UartSession()
    freertos_failed = []

    if not args.io and not args.network:
        for prog in config.freertos_basic_tests:
            if not test_freertos_single_test(uart, config, prog):
                freertos_failed.append(prog)

    if args.io:
        print_and_log("IO tests")
        for prog in config.freertos_io_tests:
            if not test_freertos_single_test(uart, config, prog):
                freertos_failed.append(prog)
        
    if args.network:
        print_and_log("Network tests")
        for prog in config.freertos_network_tests:
            if config.xlen=='64' and prog == "main_tcp":
                print_and_log("TCP test not a part of 64-bit FreeRTOS, skipping")
                continue
            if not test_freertos_network(uart, config, prog):
                freertos_failed.append(prog)
                print_and_log(prog + " FAILED")
            else:
                print_and_log(prog + " PASSED")
            print_and_log("sleeping for 10 seconds between network tests")
            time.sleep(10)

    del uart
    if freertos_failed:
        raise RuntimeError("FreeRTOS IO tests failed: " + str(freertos_failed))
    print_and_log("FreeRTOS tests passed")

# Busybox tests
def test_busybox(config, args):
    print_and_log("Running busybox tests")
    if config.compiler == "clang":
        raise RuntimeError("Clang compiler is not supported for building Busybox tests yet")

    pwd = run(['pwd'], capture_output=True)
    pwd = str(pwd.stdout,'utf-8').rstrip()
    if args.no_pcie:
        linux_config_path = pwd + '/' + config.busybox_linux_config_path_no_pcie
    else:
        linux_config_path = pwd + '/' + config.busybox_linux_config_path

    build_busybox(config, linux_config_path)

    uart = UartSession()

    print_and_log("Busybox basic test")
    gdb = GdbSession(openocd_config_filename=config.openocd_config_filename)
    res, _val = busybox_basic_tester(gdb, uart, config.busybox_filename_bbl, config.busybox_timeouts['boot'])
    if res == True:
        print_and_log("Busybox basic test passed")
    else:
        raise RuntimeError("Busybox basic test failed")

    if args.network:
        print_and_log("Busybox network test")
    
        # Send "Enter" to activate console
        uart.send(b'\r')
        time.sleep(1)

        # Get the name of ethernet interface
        cmd = b'ip a | grep "eth.:" -o \r'
        print_and_log(cmd)
        uart.send(cmd)
        rx = uart.read(3)
        print_and_log(rx)
        if "eth1" in rx:
            cmd1 = b'ip addr add 10.88.88.2/24 broadcast 10.88.88.255 dev eth1\r'
            cmd2 = b'ip link set eth1 up\r'
        else:
            cmd1 = b'ip addr add 10.88.88.2/24 broadcast 10.88.88.255 dev eth0\r'
            cmd2 = b'ip link set eth0 up\r'
        print_and_log(cmd1)
        uart.send(cmd1)
        print_and_log(cmd2)
        uart.send(cmd2)
        cmd3 = b'ip a\r'
        print_and_log(cmd3)
        uart.send(cmd3)

        expected_contents=["xilinx_axienet 62100000.ethernet","Link is Up - 1Gbps/Full - flow control rx/tx"]
        if not uart.read_and_check(10, expected_contents):
            raise RuntimeError("Busybox network test failed: cannot bring up eth interface")

        print_and_log("Ping FPGA")
        riscv_ip = "10.88.88.2"
        ping_result = run(['ping','-c','10',riscv_ip], capture_output=True)
        print_and_log(str(ping_result.stdout,'utf-8'))
        if ping_result.returncode != 0:
            raise RuntimeError("Busybox network test failed: cannot ping the FPGA")
        else:
            print_and_log("Ping OK")

    del gdb
    del uart

    

# Common busybox test parts
def build_busybox(config, linux_config_path):
    run_and_log("Cleaning bootmem program directory",
        run(['make','clean'],cwd=config.busybox_folder,
        env=dict(os.environ, LINUX_CONFIG=linux_config_path), capture_output=True))
    run_and_log("Compiling busybox, this might take a while",
        run(['make'],cwd=config.busybox_folder,
        env=dict(os.environ, LINUX_CONFIG=linux_config_path), capture_output=True))

if __name__ == '__main__':
    args = test_init()
    config = gfeconfig.Config(args)

    if args.simulator:
        test_simulator(config)
    
    if not args.no_bitstream:
        test_program_bitstream(config)
    else:
        print_and_log("Skiping bitstream programming")

    if args.asm:
        test_asm(config)

    if args.isa:
        test_isa(config)

    if args.freertos:
        test_freertos(config, args)

    if args.busybox:
        test_busybox(config, args)

    print_and_log('Finished!')


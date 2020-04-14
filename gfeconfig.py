#! /usr/bin/env python3
#
# General config for running tests etc.
#
from subprocess import run, PIPE

# Processor config
proc_list = ['chisel_p1', 'chisel_p2', 'chisel_p2_pcie', 'chisel_p3', \
            'bluespec_p1', 'bluespec_p2', 'bluespec_p2_pcie','bluespec_p3']

# Environment config
env_requried = ['openocd','riscv64-unknown-elf-gcc','riscv64-unknown-linux-gnu-gcc']

# Check if the processor is in the list of supported processors
def proc_picker(proc):
    if proc not in proc_list:
        raise RuntimeError("Processor " + proc + " not recognized")
    return proc

# Returns either vivado or vivado_lab (depending which one is installed)
def check_vivado():
    program_list = ['vivado_lab','vivado']
    for program in program_list:
        res = run(['which',program],stdout=PIPE, stderr=PIPE)
        if res.returncode == 0:
            return program
    raise RuntimeError("Neither vivado nor vivado_lab found")

# Check for all environmental dependencies
def check_environment():
    print("Checking environment")
    for program in env_requried:
        run(['which',program], stdout=PIPE, stderr=PIPE,check=True)
    return True

# Run command and log it
# Raise a runtime exception if it fails
def run_and_check(cmd, res, expected_contents=None):
    print(cmd)
    res_stdout = str(res.stdout,'utf-8')
    print(res_stdout)
    if expected_contents:
        if expected_contents in res_stdout:
            res.returncode = 0
        else:
            res.returncode = 1
    if res.returncode != 0:
        print(str(res.stderr,'utf-8'))
        msg = str("Running command failed: " + cmd + " Check test_processor.log for more details.")
        raise RuntimeError(msg)
    return res_stdout

class Config(object):
    # General test config
    xlen = None
    xarch = None
    compiler = None
    openocd_config_filename='./testing/targets/ssith_gfe.cfg'

    bootmem_folder = 'bootmem'
    bootmem_binary  = 'bootmem.bin'
    bootmem_path = bootmem_folder + '/' + bootmem_binary

    flash_prog_name = 'main_blinky'

    # Netboot config
    netboot_folder = '/srv/tftp/'
    netboor_server_ip = '10.88.88.1'

    # FreeRTOS config
    freertos_basic_tests = ['main_blinky']
    freertos_io_tests = ['main_uart','main_rtc','main_gpio','main_sd']
    freertos_network_tests = ['main_udp','main_tcp']
    freertos_expected_contents = None
    freertos_absent_contents = None
    freertos_timeouts = None
    freertos_folder='./FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1'
    freertos_sysroot_path='/opt/riscv-llvm/'

    # Busybox config
    busybox_expected_contents = None
    busybox_absent_contents = None
    busybox_timeouts = None
    busybox_folder = 'bootmem'
    busybox_linux_config_path = 'bootmem/linux.config'
    busybox_linux_config_path_no_pcie = 'bootmem/linux-no-pcie.config'
    busybox_filename_bbl = 'bootmem/build-busybox-bbl/bbl'

    # Debian config
    debian_expected_contents = None
    debian_absent_contents = None
    debian_timeouts = None
    debian_folder = 'bootmem'
    debian_linux_config_path = 'bootmem/debian-linux.config'
    debian_linux_config_path_no_pcie = 'bootmem/debian-linux-no-pcie.config'
    debian_filename_bbl = 'bootmem/build-debian-bbl/bbl'
    debian_username = b'root\r'
    debian_password = b'riscv\r'

    # FreeBSD config
    freebsd_expected_contents = None
    freebsd_absent_contents = None
    freebsd_timeouts = None
    freebsd_folder = 'freebsd'
    freebsd_filename_bbl = 'freebsd/freebsd.bbl'

    def __init__(self, args):
        if args.proc_name not in proc_list:
            raise ValueError('Unknown processor ' + args.proc_name)
        else:
            self.proc_name = args.proc_name
        
        if 'p1' in self.proc_name:
            self.xlen = '32'
            self.xarch = 'rv32imacu'
            self.cpu_freq = '50000000'
        elif 'p2' in self.proc_name:
            self.xlen = '64'
            self.xarch = 'rv64gcsu'
            self.cpu_freq = '100000000'
        elif 'p3' in self.proc_name:
            self.xlen = '64'
            self.xarch = 'rv64gcsu'
            self.cpu_freq = '25000000'
        else:
            # this should never happen
            raise ValueError('Unknown processor ' + args.proc_name)
        
        if args.compiler == "clang":
            self.use_clang="yes"
        else:
            self.use_clang="no"

        self.get_freertos_config()
        self.get_busybox_config()
        self.get_debian_config()
        self.get_freebsd_config()
        self.compiler = args.compiler

    def get_freebsd_config(self):
        expected_contents = {'boot': ["FreeBSD/riscv","login:"]}

        absent_contents = {'boot': []}

        timeouts = {'boot': 2000} # large timeout to account for loading the binary over JTAG

        self.freebsd_expected_contents = expected_contents
        self.freebsd_absent_contents = absent_contents
        self.freebsd_timeouts = timeouts


    def get_busybox_config(self):
        expected_contents = {'boot': ["Please press Enter to activate this console"],
                            'ping': ["xilinx_axienet 62100000.ethernet","Link is Up"]}

        absent_contents = {'boot': [],
                            'ping': []}

        timeouts = {'boot': 300, # large timeout to account for loading the binary over JTAG
                    'ping': 60}

        self.busybox_expected_contents = expected_contents
        self.busybox_absent_contents = absent_contents
        self.busybox_timeouts = timeouts


    def get_debian_config(self):
        expected_contents = {'boot': ["login:"],
                            'ping': ["xilinx_axienet 62100000.ethernet","Link is Up"]}

        absent_contents = {'boot': [],
                            'ping': []}

        timeouts = {'boot': 3000, # large timeout to account for loading the binary over JTAG
                    'ping': 60}

        self.debian_expected_contents = expected_contents
        self.debian_absent_contents = absent_contents
        self.debian_timeouts = timeouts

    def get_freertos_config(self):
        main_blinky = [
            "Blink",
            "RX: received value",
            "TX: sent",
            "Hello from RX",
            "Hello from TX",
        ]

        main_full = ["Pass", ".", ".","."]
        main_full_absent=["ERROR"]

        main_uart = ["UART1 RX: Hello from UART1"]
        main_gpio = ["#2 changed: 0 -> 1","#3 changed: 0 -> 1"]
        main_rtc = ["Current time: "]
        main_sd = ["Root opened"]
        main_udp = ["IP Address:"]
        main_tcp = ["IP Address:"]
        main_netboot = [">"]
        main_netboot_absent = ["Error"]

        expected_contents = {'main_blinky': main_blinky,
                            'main_full': main_full,
                            'main_uart': main_uart,
                            'main_gpio': main_gpio,
                            'main_rtc': main_rtc,
                            'main_sd': main_sd,
                            'main_udp': main_udp,
                            'main_tcp': main_tcp,
                            'main_netboot': main_netboot}

        absent_contents = {'main_blinky': [],
                            'main_full': main_full_absent,
                            'main_uart': [],
                            'main_gpio': [],
                            'main_rtc': [],
                            'main_sd': [],
                            'main_udp': [],
                            'main_tcp': [],
                            'main_netboot': main_netboot_absent}

        timeouts = {'main_blinky': 10,
                    'main_full': 10,
                    'main_uart': 10,
                    'main_gpio': 10,
                    'main_rtc': 10,
                    'main_sd': 10,
                    'main_udp': 30,
                    'main_tcp': 30,
                    'main_netboot': 30}

        self.freertos_expected_contents = expected_contents
        self.freertos_absent_contents = absent_contents
        self.freertos_timeouts = timeouts

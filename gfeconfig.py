#! /usr/bin/env python3.7
#
# General config for running tests etc.
#
from subprocess import run

# Processor config
proc_list = ['chisel_p1', 'chisel_p2', 'chisel_p3', 'bluespec_p1', 'bluespec_p2', 'bluespec_p3']

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
        res = run(['which',program],capture_output=True)
        if res.returncode == 0:
            return program
    raise RuntimeError("Neither vivado nor vivado_lab found")

# Check for all environmental dependencies
def check_environment():
    print("Checking environment")
    for program in env_requried:
        run(['which',program], capture_output=True,check=True)
    return True


class Config(object):
    # General test config
    xlen = None
    xarch = None
    compiler = None
    openocd_config_filename='./testing/targets/ssith_gfe.cfg'

    # FreeRTOS config
    freertos_basic_tests = ['main_blinky']
    freertos_io_tests = ['main_uart','main_rtc','main_gpio','main_sd']
    freertos_network_tests = ['main_udp','main_tcp']
    freertos_expected_contents = None
    freertos_absent_contents = None
    freertos_timeouts = None
    freertos_folder='./FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1'
    freertos_c_include_path='/opt/riscv/riscv64-unknown-elf/include'

    # Busybox config
    busybox_basic_tests = ['boot']
    busybox_network_tests = ['ping']
    busybox_expected_contents = None
    busybox_absent_contents = None
    busybox_timeouts = None
    busybox_folder = 'bootmem'
    busybox_linux_config_path = 'bootmem/linux.config'
    busybox_linux_config_path_no_pcie = 'bootmem/linux-no-pcie.config'
    busybox_filename_bbl = 'bootmem/build-busybox-bbl/bbl'

    def __init__(self, args):
        if args.proc_name not in proc_list:
            raise ValueError('Unknown processor ' + args.proc_name)
        else:
            self.proc_name = args.proc_name
        
        if 'p1' in self.proc_name:
            self.xlen = '32'
            self.xarch = 'rv32imacu'
        else:
            self.xlen = '64'
            self.xarch = 'rv64gcsu'
        
        self.get_freertos_config()
        self.get_busybox_config()
        self.compiler = args.compiler
    
    def get_busybox_config(self):
        expected_contents = {'boot': ["Please press Enter to activate this console"],
                            'ping': ["Please press Enter to activate this console"]}

        absent_contents = {'boot': None,
                            'ping': None}

        timeouts = {'boot': 300, # large timeout to account for loading the binary over JTAG
                    'ping': 60}

        self.busybox_expected_contents = expected_contents
        self.busybox_absent_contents = absent_contents
        self.busybox_timeouts = timeouts

    def get_freertos_config(self):
        main_blinky = [
            "Blink",
            "RX: received value",
            "TX: sent",
            "Hello from RX",
            "Hello from TX",
        ]

        main_full = ["Pass", ".", ".","."]
        main_full_absent="ERROR"

        main_uart = ["UART1 RX: Hello from UART1"]
        main_gpio = ["#2 changed: 0 -> 1","#3 changed: 0 -> 1"]
        main_rtc = ["Current time: "]
        main_sd = ["Root opened"]
        main_udp = ["IP Address:"]
        main_tcp = ["IP Address:"]

        expected_contents = {'main_blinky': main_blinky,
                            'main_full': main_full,
                            'main_uart': main_uart,
                            'main_gpio': main_gpio,
                            'main_rtc': main_rtc,
                            'main_sd': main_sd,
                            'main_udp': main_udp,
                            'main_tcp': main_tcp}

        absent_contents = {'main_blinky': None,
                            'main_full': main_full_absent,
                            'main_uart': None,
                            'main_gpio': None,
                            'main_rtc': None,
                            'main_sd': None,
                            'main_udp': None,
                            'main_tcp': None}

        timeouts = {'main_blinky': 3,
                    'main_full': 10,
                    'main_uart': 10,
                    'main_gpio': 10,
                    'main_rtc': 10,
                    'main_sd': 10,
                    'main_udp': 30,
                    'main_tcp': 30}

        self.freertos_expected_contents = expected_contents
        self.freertos_absent_contents = absent_contents
        self.freertos_timeouts = timeouts
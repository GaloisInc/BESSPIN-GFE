#!/usr/bin/env python
"""This script is used by ../../runOnLinux
- It can be used for debugging by running a terminal-like interface with the FPGA
- And it can be used for running a program (or more) above linux on FPGA
"""

import threading
import warnings
import re
from test_gfe_unittest import *

class BaseGfeForLinux(BaseGfeTest):

    def read_uart_out_until_stop (self,run_event,stop_event):
        while (not stop_event.is_set()):
            run_event.wait()
            pending = self.gfe.uart_session.in_waiting
            if pending:
                data = self.gfe.uart_session.read(pending)
                sys.stdout.write(data)
            time.sleep(1)
        return

    def flush_uart_out (self,timeout=1):
        while (True):
            time.sleep (timeout)
            pending = self.gfe.uart_session.in_waiting
            if (not pending):
                return
            dump = self.gfe.uart_session.read(pending)
    
    def interpreter_sput (self, sourceFilePath, destFilePath, riscv_ip):
        ###check sourceFileExist
        sourceFilePath = os.path.expanduser(sourceFilePath)
        if (not os.path.isfile(sourceFilePath)):
            warnings.warn("%s: Cannot open or file does not exist. Press Enter to continue..." % (sourceFilePath), RuntimeWarning)
            return

        portNum = 1234 #arbitrarily chosen
        self.gfe.uart_session.write('nc -lp {0} > {1}\r'.format(portNum, destFilePath)) #use tcp
        time.sleep (1)
        try:
            subprocess.Popen('busybox nc {0} {1} <{2}'.format(riscv_ip,portNum,sourceFilePath),shell=True) #use Popen to be non-blocking
        except:
            warnings.warn("%s: Sending failed. Please use --ctrlc if terminal not responding." % (sourceFilePath), RuntimeWarning)
            return
        
        fileSize = os.path.getsize(sourceFilePath)
        if (fileSize > 400e6):
            warnings.warn("%s: File size is too big; this might cause a crash." % (sourceFilePath), RuntimeWarning)
        #The busybox netcat does not end the connection automatically, so we have to interrupt it
        #The ethernet theoretical speed is 1Gbps (=125MB/s), but the actual speed sometime is way slower than that
        #So we'll wait 10X (1 sec for each 100MB) (seems reasonable)
        MBtoWaitPerSec = 100
        timeToWait = 10 * (((fileSize-1) // (MBtoWaitPerSec*1e6)) + 1) #ceil division
        time.sleep (timeToWait)
        #This Ctrl+C is enough to cut the connection and kill the Popen process called above
        self.gfe.uart_session.write(b'\x03\r')
        print ("\nSending successful!")
        return

    def interactive_terminal (self,riscv_ip):
        print ("\nStarting interactive terminal...")
        stopReading = threading.Event() #event to stop the reading process in the end
        runReading = threading.Event() #event to run/pause the reading process
        readThread = threading.Thread(target=self.read_uart_out_until_stop, args=(runReading,stopReading))
        stopReading.clear()
        runReading.set()
        readThread.start() #start the reading
        warnings.simplefilter ("always")
        formatwarning_orig = warnings.formatwarning
        warnings.formatwarning = lambda message, category, filename, lineno, line=None: \
                            formatwarning_orig(message, category, filename, lineno, line='')
        exitTerminal = False
        while (not exitTerminal):
            instruction = raw_input ("")
            if (len(instruction)>2 and instruction[0:2]=='--'): #instruction to the interpreter
                if (instruction[2:6] == 'exit'): #exit terminal and end test
                    exitTerminal = True
                elif (instruction[2:6] == 'sput'): #copy a file from local to linux
                    sputMatch = re.match(r'--sput (?P<sourceFilePath>[\w/.~-]+) (?P<destFilePath>[\w/.~-]+)\s*',instruction)
                    if (sputMatch != None):
                        self.interpreter_sput(sputMatch.group('sourceFilePath'), sputMatch.group('destFilePath'), riscv_ip)
                    else:
                        warnings.warn("Please use \"--sput sourceFilePath destFilePath\". Press Enter to continue...", SyntaxWarning)
                elif (instruction[2:7] == 'ctrlc'): #ctrlC
                    self.gfe.uart_session.write(b'\x03\r')
                else:
                    warnings.warn("Interpreter command not found. Press Enter to continue...", SyntaxWarning)
            else:
                self.gfe.uart_session.write(instruction + '\r')
                time.sleep(1)
            
        stopReading.set()
        return

class RunOnLinux (TestLinux, BaseGfeForLinux):

    def test_busybox_terminal (self):
        # Boot busybox
        self.boot_linux()
        linux_boot_timeout=60

        print("Running elf with a timeout of {}s".format(linux_boot_timeout))
        # Check that busybox reached activation screen
        self.check_uart_out(
            timeout=linux_boot_timeout,
            expected_contents=["Please press Enter to activate this console"])

        #self.gfe.uart_session.write(b'stty -echo\r')
        self.gfe.uart_session.write(b'\r')
        time.sleep(1)

        # Run DHCP client
        self.gfe.uart_session.write(b'ifconfig eth0 up\r')
        self.check_uart_out(
            timeout=10,
            expected_contents=["xilinx_axienet 62100000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx"])

        self.gfe.uart_session.write(b'udhcpc -i eth0\r')
         # Store and print all UART output while the elf is running
        timeout = 10
        print("Printing all UART output from the GFE...")
        rx_buf = []
        start_time = time.time()
        while time.time() < (start_time + timeout):
            pending = self.gfe.uart_session.in_waiting
            if pending:
                data = self.gfe.uart_session.read(pending)
                rx_buf.append(data) # Append read chunks to the list.
                sys.stdout.write(data)
        print("Timeout reached")

        # Get FPGA IP address
        riscv_ip = 0
        rx_buf_str = ''.join(rx_buf)
        rx_buf_list = rx_buf_str.split('\n')
        for line in rx_buf_list:
            index = line.find('Setting IP address')
            if index != -1:
                ip_str = line.split()
                riscv_ip = ip_str[3]
                print("RISCV IP address is: " + riscv_ip)
                # break # keep reading till the end to get the latest IP asignemnt

        # Ping FPGA
        if riscv_ip == 0:
            raise Exception("Could not get RISCV IP Address. Check that it was assigned in the UART output.")
        ping_response = os.system("ping -c 1 " + riscv_ip)
        self.assertEqual(ping_response, 0,
                        "Cannot ping FPGA.")

        #start interactive terminal
        self.interactive_terminal(riscv_ip)
        time.sleep(2)
        return
    
    def test_debian_terminal(self):
        # Boot Debian
        self.boot_linux()
        linux_boot_timeout=800
        print("Running elf with a timeout of {}s".format(linux_boot_timeout))
        
        # Check that Debian booted
        self.check_uart_out(
                timeout=linux_boot_timeout,
                expected_contents=[ "Debian GNU/Linux 10",
                                    "login:"
                                    ])

        # Login to Debian
        self.gfe.uart_session.write(b'root\r')
        # Check for password prompt and enter password
        self.check_uart_out(timeout=5, expected_contents=["Password"])
        self.gfe.uart_session.write(b'riscv\r')
    
        # Check for command line prompt
        self.check_uart_out(
                timeout=15,
                expected_contents=["The programs included with the Debian GNU/Linux system are free software;",
                                    ":~#"
                                    ])

        time.sleep(1)
        self.interactive_terminal(0)
        time.sleep(2)

        return

if __name__ == '__main__':
    unittest.main()
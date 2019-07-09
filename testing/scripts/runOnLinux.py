#!/usr/bin/env python
"""This script is used by ../../runOnLinux
- It can be used for debugging by running a terminal-like interface with the FPGA
- And it can be used for running a program (or more) above linux on FPGA
"""

import threading
from test_gfe_unittest import *

class BaseGfeForLinux(BaseGfeTest):

    def read_uart_out_until_stop (self,stop_event):
        while (not stop_event.is_set()):
            pending = self.gfe.uart_session.in_waiting
            if pending:
                data = self.gfe.uart_session.read(pending)
                sys.stdout.write(data)
            time.sleep(1)
    
    def interactive_terminal (self):
        print ("\nStarting interactive terminal...")
        stopReading = threading.Event()
        readThread = threading.Thread(target=self.read_uart_out_until_stop, args=(stopReading,))
        readThread.start()
        instruction = raw_input ("")
        while (instruction != "Exit"):
            self.gfe.uart_session.write(instruction + '\r')
            time.sleep(1)
            instruction = raw_input ("")
        stopReading.set()
    


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

        # Send "Enter" to activate console
        self.gfe.uart_session.write(b'\r')
        time.sleep(1)

        self.interactive_terminal()
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
        self.interactive_terminal()
        time.sleep(2)

        return

if __name__ == '__main__':
    unittest.main()
#!/usr/bin/env python3

import subprocess
import sys
import time

try:
    retval = subprocess.check_output(
        ["../../tcl/program_flash", "datafile", "../../bootmem/bootmem.bin"],
            stderr=subprocess.STDOUT)
except subprocess.CalledProcessError as e:
    # exception happened
    retval = e.output
    print("TestFlashUpload: Script returned 1, checking output...")
else:
    # script ended as expected
    print("TestFlashUpload: Script returned 0, checking output...")

print(retval)
time.sleep(10)
if "Program/Verify Operation successful." in retval:
    # success
    print("TestFlashUpload: Successfull")
    sys.exit(0)
else:
    # script failed
    print("TestFlashUpload: Failer")
    sys.exit(1)

#!/usr/bin/python3
import gfeconfig
from gfeconfig import run_and_check
import argparse
import os.path
from subprocess import run, PIPE

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("proc_name",
        help="processor to test [chisel_p1|chisel_p2|chisel_p2_pcie|chisel_p3|bluespec_p1|bluespec_p2_pcie|bluespec_p2|bluespec_p3]")
    parser.add_argument("--bitstream", help="specify a path to a custom bitstream, otherwise use processor name")
    parser.add_argument("--flash-binary", help="Program specified binary into flash")
    parser.add_argument("--flash-bitstream", help="Program specified bitstream into flash",action="store_true")
    parser.add_argument("--erase", help="Erase flasg contents",action="store_true")
    parser.add_argument("--compiler", help="select compiler to use [gcc|clang]",default="gcc")
    args = parser.parse_args()

    gfeconfig.check_environment()
    vivado = gfeconfig.check_vivado()
    config = gfeconfig.Config(args)

    if args.erase:
        print("Erasing flash")
        run(['tcl/erase_flash'], check=True)
        print("Erasing flash done!")
    elif args.flash_binary:
        run_and_check("Programming persistent memory with binary: " + args.flash_binary,
            run(['tcl/program_flash','datafile',args.flash_binary], stdout=PIPE, stderr=PIPE),
            "Program/Verify Operation successful.")
        print("Programming persistent memory with binary done!")
    else:
        # Program bitfile either to the persisent or non-persistent memory
        proc_name = gfeconfig.proc_picker(args.proc_name)

        bitfile='./bitstreams/soc_' + proc_name + '.bit'
        probfile='./bitstreams/soc_' + proc_name + '.ltx'
        if args.bitstream:
            print("Using custom bitstream, path: " + args.bitstream)
        
        if not os.path.isfile(bitfile):
            msg = "Could not locate bitstream at " + bitfile
            raise RuntimeError(msg)

        if not os.path.isfile(probfile):
            msg = "Could not locate probe file at " + probfile
            raise RuntimeError(msg)

        if args.flash_bitstream:
            run_and_check("Programming persistent memory with bitstream: " + bitfile,
                run(['tcl/program_flash','bitfile',bitfile], stdout=PIPE, stderr=PIPE),
                "Program/Verify Operation successful.")
            print("Programming persistent memory with bitstream done!")
        else:
            print("Programming non-persistent memory with bitstream")
            run([vivado,'-nojournal','-notrace','-nolog','-source','./tcl/prog_bit.tcl',
                '-mode','batch','-tclargs',bitfile, probfile], check=True)
            print("Programming non-persistent memory with bitstream done!")

            run(['rm','-rf','webtalk.log'],check=True,stdout=PIPE,stderr=PIPE)
            run(['rm','-rf','webtalk.jou'],check=True,stdout=PIPE,stderr=PIPE)

    print("Finished!")

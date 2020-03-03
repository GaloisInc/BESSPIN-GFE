#!/usr/bin/python3
import gfeconfig
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

    if config.compiler == "clang":
        use_clang="yes"
    else:
        use_clang="no"

    if args.erase:
        print("Erasing flash")
        run(['tcl/erase_flash'], check=True)
        print("Erasing flash done!")
    elif args.flash_binary:
        print("Programming persistent memory with binary...")
        prog_name = os.path.basename(args.flash_binary)
        run(['make','-f','Makefile.flash','clean'],cwd=config.bootmem_folder,
            env=dict(os.environ, USE_CLANG=use_clang, PROG=prog_name, XLEN=config.xlen),
            stdout=PIPE, stderr=PIPE, check=True)
        run(['cp',args.flash_binary,config.bootmem_folder], check=True)
        run(['make','-f','Makefile.flash'],cwd=config.bootmem_folder,
            env=dict(os.environ, USE_CLANG=use_clang, PROG=prog_name, XLEN=config.xlen),
            stdout=PIPE, stderr=PIPE, check=True)
        run(['tcl/program_flash','datafile','bootmem/bootmem.bin'], check=True)
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
            print("Programming persistent memory with bitstream...")
            run(['tcl/program_flash','bitfile',bitfile], check=True)
            print("Programming persistent memory with bitstream done!")
        else:
            print("Programming non-persistent memory with bitstream")
            run([vivado,'-nojournal','-notrace','-nolog','-source','./tcl/prog_bit.tcl',
                '-mode','batch','-tclargs',bitfile, probfile], check=True)
            print("Programming non-persistent memory with bitstream done!")

            run(['rm','-rf','webtalk.log'],check=True,stdout=PIPE,stderr=PIPE)
            run(['rm','-rf','webtalk.jou'],check=True,stdout=PIPE,stderr=PIPE)

    print("Finished!")

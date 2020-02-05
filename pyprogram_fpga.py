#!/usr/bin/python3
import gfeconfig
import argparse
import os.path
from subprocess import run, PIPE

if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("proc_name", 
        help="processor to test [chisel_p1|chisel_p2|chisel_p3|bluespec_p1|bluespec_p2|bluespec_p3]")
    parser.add_argument("--bitstream", help="specify bitstream")
    args = parser.parse_args()

    gfeconfig.check_environment()
    vivado = gfeconfig.check_vivado()
    proc_name = gfeconfig.proc_picker(args.proc_name)

    bitfile='./bitstreams/soc_' + proc_name + '.bit'
    probfile='./bitstreams/soc_' + proc_name + '.ltx'

    if args.bitstream:
        print("Using custom bitstream, path: " + args.bitstream)
        bitfile=args.bitstream

    if not os.path.isfile(bitfile):
        print("Could not locate bitstream at ", bitfile)
        exit(1)

    if not os.path.isfile(probfile):
        print("Could not locate probe file at ", probfile) 
        exit(1)

    print("Programming flash")
    run([vivado,'-nojournal','-notrace','-nolog','-source','./tcl/prog_bit.tcl',
        '-mode','batch','-tclargs',bitfile, probfile], check=True)
    print("Programming flash OK")

    run(['rm','-rf','webtalk.log'],check=True,stdout=PIPE,stderr=PIPE)
    run(['rm','-rf','webtalk.jou'],check=True,stdout=PIPE,stderr=PIPE)
    
    print("Finished!")

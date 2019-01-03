# Government Furnished Equipment (GFE) #

Source files and build scripts for generating the GFE for SSITH.


## Overview ##

This repository contains source code and build scripts for generating SoC bitstreams
for the Xilinx VCU118. The resulting systems contain either Chisel or Bluespec 
versions of P1, P2, and P3 connected by an AXI interconnect to variety of
peripherals. The AXI interconnect and corresponding peripherals are part of the
gfe subsystem, which is wrapped into a single hierarchy shown in the top level block diagram. This is designed to limit coupling
between the processors and surrounding SoC. TA1 performers can
modify or replace the reference processors with their own secure versions. They can also modify the gfe subsystem, but may not be supported if those modifications break the reference system or software.

## How to Build the SoC ##

Prebuilt images are available in the bitstreams folder.

To build your own bitstream, make sure Vivado 2017.4 is on your path and run the following commands to set up the reference
project in Vivado 2017.4. This will open up the Vivado GUI after generating the project, so enable X11 forwarding (or an equivalent solution) to view the project after it is generated.

```bash
git submodule update --init xilinx_chisel_processors
./setup_soc_project.sh
```

Then follow the usual Vivado gui build steps to generate a bitstream.
To save changes to the block diagram in git, please run `write_bd_tcl -force ../tcl/X_bd.tcl`
where `X` is the current SoC you are developing. Additionally, update `tcl/X_soc.tcl` to add any new IP repositories or project settings. `setup_soc_project.sh` should be run once. The Vivado project will be generated in the vivado folder of the repository and can be re-opened there.


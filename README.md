# Government Furnished Equipment (GFE) #

Source files and build scripts for generating the GFE for SSITH.


## Overview ##

This repository contains source code and build scripts for generating SoC bitstreams
for the Xilinx VCU118. The resulting systems contain either Chisel or Bluespec 
versions of P1, P2, and P3 connected by an AXI interconnect to variety of
peripherals. The AXI interconnect and corresponding peripherals are part of the
gfe subsystem, which is wrapped into a single Xilinx IP block to limit coupling
between the processors and surrounding SoC. TA1 performers can
modify or replace the reference processors with their own secure versions.
If modifications go beyond the processor and into the SoC, we have included
the source and instructions for opening and modifying the GFE subsystem.

## How to Build the SoC ##

Prebuilt images are available in the bitstreams folder.

To build your own bitstream, run the following to open up the reference
project in Vivado.

`git submodule update --init xilinx_chisel_processors`
`./edit_soc.sh`

Then follow the usual Vivado gui build steps to generate a bitstream.
To save changes to the block diagram in git, please run `write_bd_tcl -force ../tcl/X_bd.tcl`
where `X` is the current SoC you are developing. Additionally, update `tcl/X_soc.tcl` to add any new IP repositories or project settings.

## Modifying the GFE Subsystem ##

The GFE subsystem was developed in Vivado IP integrator and 
contains the AXI interconnect, DDR, UART, and other peripherals. To modify 
this subsystem, run `./edit_gfe_sub.sh`. This opens up
a Vivado project used to generate the gfe_subsystem IP block. When finished 
with your modifications, run 
`source ../gfe-xilinx-subsystem/save_gfe_subsystem.tcl` within Vivado 
to save the changes. This will re-package the IP and place it in the 
gfe-xilinx-subsystem/xilinx_ip folder. These steps can also be completed
within the Vivado gui.

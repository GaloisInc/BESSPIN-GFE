# Government Furnished Equipment (GFE) #

Source files and build scripts for generating and testing the GFE for SSITH.


## Overview ##

This repository contains source code and build scripts for generating SoC bitstreams
for the Xilinx VCU118. The resulting systems contain either Chisel or Bluespec 
versions of P1, P2, and P3 connected by an AXI interconnect to variety of
peripherals. The AXI interconnect and corresponding peripherals are part of the
gfe subsystem, which is wrapped into a single hierarchy shown in the top level block diagram. This is designed to limit coupling
between the processors and surrounding SoC. TA1 performers can
modify or replace the reference processors with their own secure versions. They can also modify the gfe subsystem, but may not be supported if those modifications break the reference system or software.

## Getting Started ##

Prebuilt images are available in the bitstreams folder. Use these, if you want to quickly get started. This documentation walks through the process of building a bitstream and testing the output. It suggests how to modify the GFE with your own processor.

### Setup OS (Debian Buster) ###

Please perform a clean install of Debian Buster on the development and testing hosts. This is the supported OS for building and testing the GFE. At the time of release 1 (Feb 1), Debian Buster Alpha 4 is the latest version, but we expect to upgrade Buster versions as it becomes stable (sometime soon). Please install the latest version of Debian Buster (Debian 10.X).

### Building the Bitstream ###

Download and install Vivado 2017.4. 

To build your own bitstream, make sure Vivado 2017.4 is on your path (`$ which vivado`) and run the following commands

```bash
cd $GFE_REPO
./setup_soc_project.sh bluespec # generate vivado/p1_bluespec_soc/p1_bluespec_soc.xpr
./build.sh bluespec # generate bitstreams/p1_bluespec_soc.bit
```

where GFE_REPO is the top level directory for the gfe repo. To view the project in the Vivado gui, run the following:

```bash
cd $GFE_REPO/vivado
vivado p1_bluespec_soc/p1_bluespec_soc.xpr
```

`setup_soc_project.sh` should be run once. The Vivado project will be generated in the `$GFE_REPO/vivado` folder of the repository and can be re-opened there. Note that all the same commands can be run with the argument `chisel` to generate the chisel P1 bitstream and corresponding Vivado project (i.e. `./setup_soc_project.sh chisel`).

### Testing ###

Physical setup:

1. Connect micro USB cables to JTAG and UART on the the VCU118. This enables programming, debugging, and UART communication.
2. Make sure the VCU118 is powered on (fan should be running) 
3. Program the FPGA with the bit file using the Vivado hardware manager.
4. Run `./rel_1_test.sh` from the top level of the gfe repo

A passing test will not display any error messages. All failing tests will report errors. Some of the GFE tests use the python unittesting framework which

TODO: Insert example of passing test

### Simulation ###

Click `Run Simulation` in Vivado.

### Adding in your processor ###

To swap your P1 processor into the GFE, we recommend using the Vivado IP integrator flow already used by the GFE. This involves wrapping your processor in a Xilinx IP block and adding that repository to the p1_soc.tcl Vivado project script. 

Fortunately, we have provided two examples of wrapped processors, one for the chisel P1 processor and another for the bluespec processor, and we have provided a common top level Verilog file for P1 processors to limit user effort in wrapping their processor.

All that is required (and therefore tracked by git) to create a Xilinx IP block is a component.xml file. This file points to top level verilog module and all the source required to simulate and synthesize the IP block.

The steps to add in your own processor are as follows:

1. Create your top level verilog to match mkCore_P1.v
2. 

### Modifying the GFE ###

To save changes to the block diagram in git (everything outside the P1 IP block), please open the block diagram in Vivado and run `write_bd_tcl -force ../tcl/X_bd.tcl`
where `X` is the current SoC you are developing. Additionally, update `tcl/X_soc.tcl` to add any new IP repositories or project settings.


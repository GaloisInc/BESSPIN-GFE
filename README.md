# Government Furnished Equipment (GFE) #

Source files and build scripts for generating and testing the GFE for SSITH.


## Overview ##

This repository contains source code and build scripts for generating SoC bitstreams
for the Xilinx VCU118. The resulting systems contain either Chisel or Bluespec 
versions of P1 connected by an AXI interconnect to UART, DDR, and Bootrom. For more details on the contents of the GFE, see TODO: ADD REFERENCE TO SYSTEM DOCUMENTATION

## Getting Started ##

Prebuilt images are available in the bitstreams folder. Use these, if you want to quickly get started. This documentation walks through the process of building a bitstream and testing the output. It suggests how to modify the GFE with your own processor.

### Setup OS (Debian Buster) ###

Please perform a clean install of Debian Buster on the development and testing hosts. This is the supported OS for building and testing the GFE. At the time of release 1 (Feb 1), Debian Buster Alpha 4 is the latest version, but we expect to upgrade Buster versions as it becomes stable (sometime soon). Please install the latest version of Debian Buster (Debian 10.X).

### Install RISCV Tools ###

This GFE has been tested with a particular fork of riscv-tools that includes an upstream change to riscv-openocd that allows for JTAG debugging over the  same Xilinx JTAG connection used to program the VCU118.
Please use the version of riscv-tools submoduled in this repo under `$GFE_REPO/riscv-tools.`

To install, first set the RISCV path with `export RISCV=$GFE_REPO/riscv-tools` and initialize the riscv-tools and other submodules with `cd $GFE_REPO && ./init_submodules.sh`.
This will place the riscv binaries in the proper location for the testing scripts.
Next, install the 32-bit RISCV toolchain using the directions in `$GFE_REPO/riscv-tools/README.md`

### Install Vivado ###

Download and install Vivado 2017.4. A license key for the tool is included on a piece of paper in the box containing the VCU118. See Vivado [UG973](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug973-vivado-release-notes-install-license.pdf) for download and installation instructions. We only need the Vivado tool, not the SDK, so download the `Vivado Design Suite - HLx 2017.4 ` from the [Vivado Download Page](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2017-4.html). One must make an account with Vivado in order to register the tool and install the license.

If using separate development and testing machines, only the development machine needs a license. We recommend installing Vivado Lab on the testing machine, because it does not require a license and can be used to program the FPGA.

### Building the Bitstream ###

To build your own bitstream, make sure Vivado 2017.4 is on your path (`$ which vivado`) and run the following commands

```bash
cd $GFE_REPO
./setup_soc_project.sh bluespec # generate vivado/p1_soc_bluespec/p1_soc_bluespec.xpr
./build.sh bluespec # generate bitstreams/p1_soc_bluespec.bit
```

where GFE_REPO is the top level directory for the gfe repo. To view the project in the Vivado gui, run the following:

```bash
cd $GFE_REPO/vivado
vivado p1_soc_bluespec/p1_soc_bluespec.xpr
```

`setup_soc_project.sh` should only be run once. We also recommend running `build.sh` for the initial build then performing future builds using the Vivado GUI to take advantage of convenient error reporting and visibility into the build process. The Vivado project will be generated in the `$GFE_REPO/vivado/p1_soc_$p1_name` folder of the repository and can be re-opened there. Note that all the same commands can be run with the argument `chisel` to generate the chisel P1 bitstream and corresponding Vivado project (i.e. `./setup_soc_project.sh chisel`).

### Testing ###

1. Install the following python packages: `pexpect, pyserial`. 
These are required for running python unittests on the GFE.
2. Connect micro USB cables to JTAG and UART on the the VCU118. This enables programming, debugging, and UART communication.
2. Make sure the VCU118 is powered on (fan should be running) 
3. Program the FPGA with the bit file (i.e. [bitstreams/p1_soc_chisel.bit](bitstreams/p1_soc_chisel.bit)) using the Vivado hardware manager.
4. Run `./rel_1_test.sh` from the top level of the gfe repo

A passing test will not display any error messages. All failing tests will report errors such as .

TODO: Insert example of failing tests and passing tests.

The python unit testing infrastructure reuses scripts from riscv-tests to help automate GDB and OpenOCD scripting. The primary python unittests are stored in [test_gfe_unittest.py](testing/scripts/test_gfe_unittest.py). These unit tests rely on a convenience class for interacting with the gfe defined in [gfetester.py](testing/scripts/gfetester.py)

#### Running FreeRTOS ####

To run FreeRTOS on the GFE, you'll need to run OpenOCD, connect to gdb, and view the UART output in minicom. First, install minicom and build the FreeRTOS demo. Also, source `setup_env.sh` to make sure the proper OpenOCD and GDB versions are on your path.

```bash
sudo apt-get install minicom

cd $GFE_REPO/FreeRTOS-RISCV/Demo/p1-besspin/
make

source $GFE_REPO/setup_env.sh
```

Follow these steps to run freeRTOS with an interactive GDB session:

1. Reset the SoC by pressing the CPU_RESET button (SW5) on the VCU118 before running FreeRTOS.
2. Run OpenOCD to connect to the riscv core `openocd -f $GFE_REPO/testing/targets/p1_hs2.cfg`.
3. In a new terminal, run minicom with `minicom -D /dev/ttyUSB1 -b 9600`. `ttyUSB1` should be replaced with whichever USB port is connected to the VCU118's USB-to-UART bridge.
Settings can be configured by running `minicom -s` and selecting `Serial Port Setup` and then `Bps/Par/Bits`. 
The UART is configured to have 8 data bits, 2 stop bits, no parity bits, and a baud rate of 9600.
4. In a new terminal, run gdb with `riscv32-unknown-elf-gdb $GFE_REPO/FreeRTOS-RISCV/Demo/p1-besspin/main.elf`.
5. Once gdb is open, type `target remote localhost:3333` to connect to OpenOCD. OpenOCD should give a message that it has accepted a gdb connection.
Load the FreeRTOS elf file onto the processor with `load`. To run, type `c` or `continue`.
6. When you've finished running FreeRTOS, make sure to reset the SoC before running other tests or programs.

### Simulation ###

Click `Run Simulation` in the Vivado GUI and refer to the Vivado documentation for using XSIM in a project flow, such as [UG937](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug937-vivado-design-suite-simulation-tutorial.pdf). If necessary, create a testbench around the top level project to generate stimulus for components outside the GFE (i.e. DDR memories, UART, JTAG).

### Adding in Your Processor ###

We recommend using the Vivado IP integrator flow to add a new processor into the GFE. This should require minimal effort to integrate the processor and this flow is already demonstrated for the Chisel and Bluespec P1 processors. Using the integrator flow requires wrapping the processor in a Xilinx User IP block and updating the necessary IP search paths to find the new IP. The Chisel and Bluespec Vivado projects are created by sourcing the same tcl for the block diagram (`p1_soc_bd.tcl`). The only difference is the location from which it pulls in the mkP1_Core_v1_0 IP block.

The steps to add in a new processor are as follows:

1. Duplicate the top level verilog file `mkCore_P1.v` from the Chisel or Bluespec designs and modify it to instantiate the new processor. See `$GFE_REPO/chisel_processors/xilinx_ip/hdl/mkP1_Core.v` and `$GFE_REPO/bluespec-processors/P1/Piccolo/src_SSITH_P1/xilinx_ip/hdl/mkP1_Core.v` for examples.
2. Copy the component.xml file from one of the two processors and modify it to include all the paths to the RTL files for your design. See `$GFE_REPO/bluespec-processors/P1/Piccolo/src_SSITH_P1/xilinx_ip/component.xml` and `$GFE_REPO/chisel_processors/xilinx_ip/component.xml`. This is the most clunky part of the process, but is relatively straight forward.
    *  Copy a reference component.xml file to a new folder (i.e. `cp $GFE_REPO/chisel_processors/xilinx_ip/component.xml new_processor/`)
    *  Replace references to old verilog files within component.xml. Replace `spirit:file` entries such as 
    ```xml
    <spirit:file>
        <spirit:name>hdl/galois.system.P1FPGAConfig.behav_srams.v</spirit:name>
        <spirit:fileType>verilogSource</spirit:fileType>
    </spirit:file>
    ```
   with paths to the hdl for the new processor such as: 
    ```xml
    <spirit:file>
        <spirit:name>hdl/new_processor.v</spirit:name>
        <spirit:fileType>verilogSource</spirit:fileType>
    </spirit:file>
    ```
    The paths in component.xml are relative to its parent directory (i.e. `$GFE_REPO/chisel_processors/xilinx_ip/`).
    * Note that the component.xml file contains a set of files used for simulation (xilinx_anylanguagebehavioralsimulation_view_fileset) and another set used for synthesis. Make sure to replace or remove file entries as necessary in each of these sections.
    * Vivado discovers user IP by searching all it's IP repository paths looking for component.xml files. This is the reason for the specific name. This file fully describes the new processor's IP block and can be modified through a gui if desired using the IP packager flow. It is easier to start with an example component.xml file to ensure the port naming and external interfaces match those used by the block diagram.

3. Add your processor to `$GFE_REPO/tcl/p1_mapping.tcl`. Add a line here to include the mapping between your processor name and directory containing the component.xml file. This mapping is used by the `p1_soc.tcl` build script.
    ```bash
    vim tcl/p1_mapping.tcl
    # Add line if component.xml lives at ../new_processor/component.xml
    + dict set p1_mapping new_processor "../new_processor"
    ```
   The mapping path is relative to the `$GFE_REPO/tcl` path
4. Create a new Vivado project with your new processor by running the following:
    ```bash
    cd $GFE_REPO
    ./setup_soc_project.sh new_processor
    ```
   new_processor is the name specified in the `$GFE_REPO/tcl/p1_mapping.tcl` file.

5. Synthesize and build the design using the normal flow. Note that users will have to update the User IP as prompted in the gui after each modification to the component.xml file or reference Verilog files.

Fortunately, we have provided two examples of wrapped processors, one for the Chisel P1 processor and another for the Bluespec processor, and we have provided a common top level Verilog file for P1 processors to limit user effort in wrapping their processor.

All that is required (and therefore tracked by git) to create a Xilinx User IP block is a component.xml file and the corresponding verilog source files.

### Modifying the GFE ###

To save changes to the block diagram in git (everything outside the P1 IP block), please open the block diagram in Vivado and run `write_bd_tcl -force ../tcl/p1_soc_bd.tcl`. Additionally, update `tcl/p1_soc.tcl` to add any project settings.

### Rebuilding the Chisel and Bluespec Processors ###

The compiled verilog from the latest Chisel and Bluespec build is stored in git to enable building the FPGA bitstream right away. To rebuild the bluespec processor, follow the directions in `bluespec-processors/P1/Piccolo/README.md`. To rebuild the Chisel processor for the GFE, run the following commands
```bash
cd chisel_processors/P1
./build.sh
```


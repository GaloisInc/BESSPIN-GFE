# Government Furnished Equipment (GFE) #

Source files and build scripts for generating and testing the GFE for SSITH.


## Overview ##

This repository contains source code and build scripts for generating SoC bitstreams
for the Xilinx VCU118. The resulting systems contain either Chisel or Bluespec 
versions of P1 connected by an AXI interconnect to UART, DDR, and Bootrom. 

## Getting Started ##

Prebuilt images are available in the bitstreams folder. Use these, if you want to quickly get started. This documentation walks through the process of building a bitstream and testing the output. It suggests how to modify the GFE with your own processor.

### Setup OS (Debian Buster) ###

Please perform a clean install of Debian Buster on the development and testing hosts. This is the supported OS for building and testing the GFE. At the time of release 1 (Feb 1), Debian Buster Alpha 4 is the latest version, but we expect to upgrade Buster versions as it becomes stable (sometime soon). Please install the latest version of Debian Buster (Debian 10.X).

### Clone this REPO ###

Once the OS is installed, you will need to add your ssh key to Gitlab in order to clone this repo. Checkout these [instructions](https://docs.gitlab.com/ee/ssh/#adding-an-ssh-key-to-your-gitlab-account) for more details.

After setting up an ssh key, clone this repo by running

```bash
git clone git@gitlab-ext.galois.com:ssith/gfe.git
```

### Install RISCV Toolchain ###

Install the standard RISCV toolchain for compiling Linux and other tests for the SSITH processors.
```bash
git clone https://github.com/riscv/riscv-gnu-toolchain.git
cd riscv-gnu-toolchain
git submodule update --init --recursive
./configure --prefix=$RISCV_INSTALL --with-arch=rv32gc --with-abi=ilp32
make       # Install the 32 bit newlib toolchain for testing the P1
./configure --prefix=$RISCV_INSTALL
make       # Install the 64 bit newlib toochain for testing the P2
make linux # Install the 64 bit linux toolchain
```
Follow the instructions [here](https://github.com/riscv/riscv-gnu-toolchain) for more information.

### Install RISCV Tools ###

This GFE has been tested with a particular fork of riscv-tools that includes an upstream change to riscv-openocd that allows for JTAG debugging over the  same Xilinx JTAG connection used to program the VCU118.
It also submodules Galois forks of riscv-tests and riscv-pk customized for the reference processors.
Please use the version of OpenOCD included in riscv-tools submoduled in this repo under `$GFE_REPO/riscv-tools.`

A convenient way to install this custom version of OpenOCD is to build the riscv toolchain from riscv-tools.
To install, first set the RISCV path with `export RISCV=$GFE_REPO/riscv-tools` and initialize riscv-tools and other submodules with `cd $GFE_REPO && ./init_submodules.sh`.
This will place the openocd binary in `$GFE_REPO/riscv-tools/bin` where the testing scripts expect it.
Next, install the RISCV toolchain using the directions in `$GFE_REPO/riscv-tools/README.md` (i.e. run `build.sh`).
After installing openocd, be sure to set the RISCV variable back to point to your standard riscv-gnu-toolchain installation by running `export RISCV=$RISCV_INSTALL`.

### Install Vivado ###

Download and install Vivado 2017.4. A license key for the tool is included on a piece of paper in the box containing the VCU118. See Vivado [UG973](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug973-vivado-release-notes-install-license.pdf) for download and installation instructions. We only need the Vivado tool, not the SDK, so download the `Vivado Design Suite - HLx 2017.4 ` from the [Vivado Download Page](https://www.xilinx.com/support/download/index.html/content/xilinx/en/downloadNav/vivado-design-tools/2017-4.html). One must make an account with Vivado in order to register the tool and install the license. After installing Vivado, you must also install libtinfo5 for Debian to run the tool. Install this dependency by running `sudo apt-get install libtinfo5`.

If using separate development and testing machines, only the development machine needs a license. We recommend installing Vivado Lab on the testing machine, because it does not require a license and can be used to program the FPGA.

### Building the Bitstream ###

To build your own bitstream, make sure Vivado 2017.4 is on your path (`$ which vivado`) and run the following commands

```bash
cd $GFE_REPO
./setup_soc_project.sh chisel_p1 # generate vivado/soc_chisel_p1/soc_chisel_p1.xpr
./build.sh chisel_p1 # generate bitstreams/soc_chisel_p1.bit
```

where GFE_REPO is the top level directory for the gfe repo. To view the project in the Vivado gui, run the following:

```bash
cd $GFE_REPO/vivado
vivado soc_chisel_p1/soc_chisel_p1.xpr
```

`setup_soc_project.sh` should only be run once. We also recommend running `build.sh` for the initial build then performing future builds using the Vivado GUI to take advantage of convenient error reporting and visibility into the build process. The Vivado project will be generated in the `$GFE_REPO/vivado/soc_$proc_name` folder of the repository and can be re-opened there. Note that all the same commands can be run with the argument `bluespec_p1` to generate the bluespec P1 bitstream and corresponding Vivado project (i.e. `./setup_soc_project.sh bluespec`).

### Storing a Bitstream in Flash ###

See [flash-scripts/README](flash-scripts/README) for directions on how to write a bitstream to flash on the VCU118. 
This allows the FPGA to be programmed from flash on power-up.

### Testing ###

1. Install the following python packages: `pexpect, pyserial`. 
These are required for running python unittests on the GFE.
2. Give the current user access to the serial devices.
```bash
sudo usermod -aG dialout $USER
sudo reboot
```
3. Connect micro USB cables to JTAG and UART on the the VCU118. This enables programming, debugging, and UART communication.
4. Make sure the VCU118 is powered on (fan should be running) 
5. Add Vivado or Vivado Lab to your path (i.e. `source source /opt/Xilinx/Vivado_Lab/2017.4/settings64.sh`).
6. Run `./test_processor.sh chisel_p1` from the top level of the gfe repo. Replace `chisel_p1` with your processor of choice. This command will program the FPGA and run the appropriate tests for that processor.

A passing test will not display any error messages. All failing tests will report errors and stop early.

The python unit testing infrastructure reuses scripts from riscv-tests to help automate GDB and OpenOCD scripting. The primary python unittests are stored in [test_gfe_unittest.py](testing/scripts/test_gfe_unittest.py). These unit tests rely on a convenience class for interacting with the gfe defined in [gfetester.py](testing/scripts/gfetester.py)

## Running FreeRTOS ##

To run FreeRTOS on the GFE, you'll need to run OpenOCD, connect to gdb, and view the UART output in minicom. First, install minicom and build the FreeRTOS demo. Also, source `setup_env.sh` to make sure the proper OpenOCD and GDB versions are on your path.

```bash
sudo apt-get install minicom

cd $GFE_REPO/FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1

# for simple blinky demo
make clean; PROG=main_blinky make

# for full demo
make clean; PROG=main_full make

source $GFE_REPO/setup_env.sh
```

We expect to see warnings about memory alignment and timer demo functions when compiling.

Follow these steps to run freeRTOS with an interactive GDB session:

1. Reset the SoC by pressing the CPU_RESET button (SW5) on the VCU118 before running FreeRTOS.
2. Run OpenOCD to connect to the riscv core `openocd -f $GFE_REPO/testing/targets/ssith_gfe.cfg`.
3. In a new terminal, run minicom with `minicom -D /dev/ttyUSB1 -b 9600`. `ttyUSB1` should be replaced with whichever USB port is connected to the VCU118's USB-to-UART bridge.
Settings can be configured by running `minicom -s` and selecting `Serial Port Setup` and then `Bps/Par/Bits`. 
The UART is configured to have 8 data bits, 2 stop bits, no parity bits, and a baud rate of 9600.
4. In a new terminal, run gdb with `riscv32-unknown-elf-gdb $GFE_REPO/FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1/main_blinky.elf`, where `main_blinky` should be the name of the demo you have compiled and want to run.
5. Once gdb is open, type `target remote localhost:3333` to connect to OpenOCD. OpenOCD should give a message that it has accepted a gdb connection.
Load the FreeRTOS elf file onto the processor with `load`. To run, type `c` or `continue`.
6. When you've finished running FreeRTOS, make sure to reset the SoC before running other tests or programs.

The expected output from simple blinky test is:
```
[0]: Hello from RX
[0]: Hello from TX
[1] TX: awoken
[1] RX: received value
Blink !!!
[1]: Hello from RX
[1] TX: sent
[1]: Hello from TX
[2] TX: awoken
[2] RX: received value
Blink !!!
[2]: Hello from RX
[2] TX: sent
[2]: Hello from TX
[3] TX: awoken
[3] RX: received value
Blink !!!
...
```

The expected output from full test is:
```
Starting main_full
Pass....
```

If you see error messages, then something went wrong.

To run any `.elf` file on the GFE, you can use the `run_elf.py` script in `$GFE_REPO/testing/scripts/`. It can be run using `python run_elf.py path_to_elf/file.elf`. By default the program waits 0.5 seconds before printing what it has received from UART, but this can be changed by using the `--runtime X` argument where X is the number of seconds to wait.

### Running FreeRTOS + TCP/IP stack ###
Details about the FreeRTOS TCP/IP stack can be found [here](https://www.freertos.org/FreeRTOS-Plus/FreeRTOS_Plus_TCP/index.html). We provide a small example, demonstrating 
the DHCP, ICMP (ping), UDP and TCP functionality. The setup is little bit involved, hence it is not automated yet. The demo can also be modified to better suit your use-case.

Our setup is below:
```
----------------------------------                                 ---------------------------------------
|    HOST COMPUTER               |                                 |      FPGA Board                     |
|    DHCP server                 |              Ethernet cable     |      DHCP On                        |
|    IP: 10.88.88.2              |<===============================>|      IP: assumed to be 10.88.88.3   |
|    Netmask: 255.255.255.0      |                                 |      MAC: 00:0A:35:04:DB:77         |
----------------------------------                                 ---------------------------------------
```

If you want to replicate our setup you should:
1) Install and start a DHCP server on your host machine (make sure you configure it to service the interface that is connected to the FPGA).
A howto guide is for example [here](https://www.tecmint.com/install-dhcp-server-in-ubuntu-debian/)
2) If you have only one FPGA on the network, then you can leave the MAC address as is,
otherwise [change it](https://github.com/GaloisInc/FreeRTOS-mirror/blob/p1_release/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h#L325) 
to the MAC address of the particular board (there is a sticker).
3) If you change the host IP, reflect the changes accordingly in [FreeRTOSIPConfig](https://github.com/GaloisInc/FreeRTOS-mirror/blob/p1_release/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h#L315)

**Scenario 1: DHCP**

Follow the steps below:

1) Program your FPGA with a P1 bitstream: `./program_fpga.sh chisel_p1` **NOTE:** If you have already programmed the FPGA, at least restart it before continuing to make sure it is in a good state. 
2) Start openocd with `openocd -f $GFE_REPO/testing/targets/ssith_gfe.cfg`
3) Connect the FPGA Ethernet port into a router/switch that provides a DHCP server. Our router has an adress/netmask of 10.88.88.1/255.255.255.0
4) Connect your host computer to the same router.
5) Go to the demo directory: `cd FreeRTOS-mirror/FreeRTOS/Demo/RISC-V_Galois_P1`
6) Generate `main_tcp.elf` binary: `export PROG=main_tcp; make clean; make`
7) Start GDB: `riscv32-unknown-elf-gdb main_tcp.elf`
8) in your GDB session type: `target remote localhost:3333`
9) in your GDB session type: `load`
10) start minicom: `minicom -D /dev/ttyUSB1 -b 115200` **NOTE:** The default baud rate for TCP example is 115200 baud.
11) in your GDB session type: `continue`
12) In minicom, you will see a bunch of debug prints. The interesting piece is when you get:
```
IP Address: 10.88.88.3
Subnet Mask: 255.255.255.0
Gateway Address: 10.88.88.1
DNS Server Address: 10.88.88.1
```
which means the FreeRTOS got assigned an IP address and is ready to communicate.

13) Open a new terminal, and type `ping 10.88.88.3` (or whatever is the FPGA's IP address) - you should see something like this:
```
$ ping 10.88.88.3
PING 10.88.88.3 (10.88.88.3) 56(84) bytes of data.
64 bytes from 10.88.88.3: icmp_seq=1 ttl=64 time=14.1 ms
64 bytes from 10.88.88.3: icmp_seq=2 ttl=64 time=9.22 ms
64 bytes from 10.88.88.3: icmp_seq=3 ttl=64 time=8.85 ms
64 bytes from 10.88.88.3: icmp_seq=4 ttl=64 time=8.84 ms
64 bytes from 10.88.88.3: icmp_seq=5 ttl=64 time=8.85 ms
64 bytes from 10.88.88.3: icmp_seq=6 ttl=64 time=8.83 ms
64 bytes from 10.88.88.3: icmp_seq=7 ttl=64 time=8.83 ms
^C
--- 10.88.88.3 ping statistics ---
7 packets transmitted, 7 received, 0% packet loss, time 6007ms
rtt min/avg/max/mdev = 8.838/9.663/14.183/1.851 ms
```
That means ping is working and your FPGA is responding.

14) Now open another terminal and run TCP Echo server at port 9999: `ncat -l 9999 --keep-open --exec "/bin/cat" -v`
Note that this will work only if your TCP Echo server is at 10.88.88.2 (or you [updated the config file](https://github.com/GaloisInc/FreeRTOS-mirror/blob/p1_release/FreeRTOS/Demo/RISC-V_Galois_P1/FreeRTOSIPConfig.h#L315)
). After a few seconds, you will see something like this:
```
$ ncat -l 9999 --keep-open --exec "/bin/cat" -v
Ncat: Version 7.60 ( https://nmap.org/ncat )
Ncat: Generating a temporary 1024-bit RSA key. Use --ssl-key and --ssl-cert to use a permanent one.
Ncat: SHA-1 fingerprint: 2EDF 34C4 1F16 FF89 0AE1 6B1B F236 D933 A4DD 030E
Ncat: Listening on :::9999
Ncat: Listening on 0.0.0.0:9999
Ncat: Connection from 10.88.88.3.
Ncat: Connection from 10.88.88.3:25816.
Ncat: Connection from 10.88.88.3.
Ncat: Connection from 10.88.88.3:2334.
Ncat: Connection from 10.88.88.3.
Ncat: Connection from 10.88.88.3:14588.
```


15) [Optional] start `wireshark` and inspect the interface that is at the same network as the FPGA. You sould clearly see the ICMP ping requests and responses, as well as the TCP packets
to and from the echo server.
16) [Optional] Send a UDP packet with `socat stdio udp4-connect:10.88.88.3:5006 <<< "Hello there"`. In the minicom output, you should see `prvSimpleZeroCopyServerTask: received $N bytes` depending 
on how much data you send. **Hint:** instead of minicom, you can use `cat /dev/ttyUSB1 > log.txt` to redirect the serial output into a log file for later inspection.


**Troubleshooting**

If something doesn't work, then:
1) check that your connection is correct (e.g. if you have a DHCP server, it is enabled in the FreeRTOS config, or that your static IP is correct)
2) sometimes restarting the FPGA with `CPU_RESET` button (or typing `reset` in GDB) will help
3) Check out our [Issue](https://gitlab-ext.galois.com/ssith/gfe/issues) - maybe you have a problem we already know about.

## Running Linux - Debian or Busybox ##
#### Creating Debian Image ####
Before starting, there are several necessary packages to install. Run:
``` 
apt-get install libssl-dev debian-ports-archive-keyring binfmt-support qemu-user-static mmdebstrap
```
The RISCV toolchain `riscv-gnu-toolchain` should also be installed, built, and added to your path. Instructions for this are at the top of this README.

Finally, add the following lines to your `/etc/apt/sources.list` for access to the Debian-Ports respository:
``` bash
deb http://deb.debian.org/debian-ports/ sid main
deb http://deb.debian.org/debian-ports/ unreleased main
deb-src http://deb.debian.org/debian-ports/ sid main
```

The debian directory includes several scripts for creating a Debian image. From that directory:

``` bash
# Create chroot and compress cpio archive
sudo ./create_chroot.sh

# Build kernel and bbl
./create_debian_image.sh  
```
To decrease the size of the image, some language man pages, documentation, and locale files are removed.
This results in warnings about locale settings and man files that are expected.

If you want to install more packages than what is included, run `sudo ./create_chroot.sh package1 package2` and subsitute `package1` and `package2` with all the packages you want to install. 
If you want to install or remove packages manually or change anything else inside the chroot, do the following:
``` bash
# Enter chroot
sudo chroot riscv64-chroot/

# Use apt-get to install whatever you want

# Remove apt-cache and list files
./clean_chroot.sh

exit

sudo ./create_cpio_archive.sh
```
Then the bbl image can be created with `./create_debian_image.sh`.

The bbl image is located at `$GFE_REO/riscv-tools/riscv-pk/build/bbl` can be loaded and run using gdb.

#### Creating Busybox Image ####

The following instructions describe how to boot Linux with Busybox.

### Build the memory image ###

```bash
cd $GFE_REPO/bootmem/
make
```

### Load and run the memory image ###

Follow these steps to run Linux and Busybox with an interactive GDB session:

1. Reset the SoC by pressing the CPU_RESET button (SW5) on the VCU118 before running Linux.
2. Run OpenOCD to connect to the riscv core `openocd -f $GFE_REPO/testing/targets/ssith_gfe.cfg`.
3. In a new terminal, run minicom with `minicom -D /dev/ttyUSB1 -b 115200`. `ttyUSB1` should be replaced with whichever USB port is connected to the VCU118's USB-to-UART bridge. Settings can be configured by running `minicom -s` and selecting `Serial Port Setup` and then `Bps/Par/Bits`. 
The UART is configured to have 8 data bits, 2 stop bits, no parity bits, and a baud rate of 115200. In the minicom settings, make sure hardware flow control is turned off. Otherwise, the Linux terminal may not be responsive.
4. In a new terminal, run gdb with `riscv64-unknown-elf-gdb $GFE_REPO/bootmem/build-bbl/bbl`.
5. Once gdb is open, type `target remote localhost:3333` to connect to OpenOCD. OpenOCD should give a message that it has accepted a gdb connection.
6. On Bluespec processors, run `continue` then interrupt the processor with `Ctl-C`. The Bluespec processors start in a halted state, and need to run the first few bootrom instructions to setup a0 and a1 before booting Linux. See #40 for more details.
7. Load the Linux image onto the processor with `load`. To run, type `c` or `continue`.
8. When you've finished running Linux, make sure to reset the SoC before running other tests or programs.

In the serial terminal you should expect to see Linux boot messages.  The final message says ```Please press Enter to activate this console.```.  If you do as instructed (press enter), you will be presented with a shell running on the GFE system.

### Using Ethernet on Linux ###

The GFE-configured Linux kernel includes the Xilinx AXI Ethernet driver. You should see the following messages in the boot log:
```
[    4.320000] xilinx_axienet 62100000.ethernet: assigned reserved memory node ethernet@62100000
[    4.330000] xilinx_axienet 62100000.ethernet: TX_CSUM 2
[    4.330000] xilinx_axienet 62100000.ethernet: RX_CSUM 2
[    4.340000] xilinx_axienet 62100000.ethernet: enabling VCU118-specific quirk fixes
[    4.350000] libphy: Xilinx Axi Ethernet MDIO: probed
```

The Debian image provided has the iproute2 package already installed.

**DHCP IP Example**

If the VCU118 is connected to a network that has a DHCP server, the eth0 interface should automatically connect to the DHCP server.
To test this, you can run `ping 4.2.2.1`. The expected output of this is: 
you can configure networking using the following commands:
```
PING 4.2.2.1 (4.2.2.1): 56 data bytes
64 bytes from 4.2.2.1: seq=0 ttl=57 time=22.107 ms
64 bytes from 4.2.2.1: seq=1 ttl=57 time=20.754 ms
64 bytes from 4.2.2.1: seq=2 ttl=57 time=20.908 ms
64 bytes from 4.2.2.1: seq=3 ttl=57 time=20.778 ms
^C
--- 4.2.2.1 ping statistics ---
4 packets transmitted, 4 packets received, 0% packet loss
round-trip min/avg/max = 20.754/21.136/22.107 ms
/ # 
```

**Static IP Example**

Use the commands below to enable networking when a DHCP server is not available. Replace the IP and router addresses as necessary for your setup (have not tested this):
```
/ # ip addr add 10.0.0.3 dev eth0
...
xilinx_axienet 62100000.ethernet eth0: Link is Up - 1Gbps/Full - flow control rx/tx
...
/ # ip route add 10.0.0.0/24 dev eth0
/ # ip route add 0.0.0.0 via 10.0.0.2
/ # ip route add default via 10.0.0.2 
/ # ping 4.2.2.1
PING 4.2.2.1 (4.2.2.1): 56 data bytes
64 bytes from 4.2.2.1: seq=0 ttl=57 time=23.320 ms
64 bytes from 4.2.2.1: seq=1 ttl=57 time=20.738 ms
...
^C
--- 4.2.2.1 ping statistics ---
20 packets transmitted, 20 packets received, 0% packet loss
round-trip min/avg/max = 20.536/20.913/23.320 ms

/ # 
```

### Storing a boot image in Flash ###

1. Prepare the image with Linux and Busybox as described above.
2. Write to flash memory on the board with the command `tcl/program_flash datafile bootmem/bootmem.bin`.
3. If a suitable bitfile is also stored in flash, upon board power up or reset, the device will automatically boot into Linux and Busybox.

## Simulation ##

Click `Run Simulation` in the Vivado GUI and refer to the Vivado documentation for using XSIM in a project flow, such as [UG937](https://www.xilinx.com/support/documentation/sw_manuals/xilinx2017_4/ug937-vivado-design-suite-simulation-tutorial.pdf). If necessary, create a testbench around the top level project to generate stimulus for components outside the GFE (i.e. DDR memories, UART, JTAG).

## Adding in Your Processor ##

We recommend using the Vivado IP integrator flow to add a new processor into the GFE. This should require minimal effort to integrate the processor and this flow is already demonstrated for the Chisel and Bluespec processors. Using the integrator flow requires wrapping the processor in a Xilinx User IP block and updating the necessary IP search paths to find the new IP. The Chisel and Bluespec Vivado projects are created by sourcing the same tcl for the block diagram (`soc_bd.tcl`). The only difference is the location from which it pulls in the ssith_processor IP block.

The steps to add in a new processor are as follows:

1. Duplicate the top level verilog file `mkCore_P1.v` from the Chisel or Bluespec designs and modify it to instantiate the new processor. See `$GFE_REPO/chisel_processors/P1/xilinx_ip/hdl/mkP1_Core.v` and `$GFE_REPO/bluespec-processors/P1/Piccolo/src_SSITH_P1/xilinx_ip/hdl/mkP1_Core.v` for examples.
2. Copy the component.xml file from one of the two processors and modify it to include all the paths to the RTL files for your design. See `$GFE_REPO/bluespec-processors/P1/Piccolo/src_SSITH_P1/xilinx_ip/component.xml` and `$GFE_REPO/chisel_processors/P1/xilinx_ip/component.xml`. This is the most clunky part of the process, but is relatively straight forward.
    *  Copy a reference component.xml file to a new folder (i.e. `cp $GFE_REPO/chisel_processors/P1/xilinx_ip/component.xml new_processor/`)
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
    The paths in component.xml are relative to its parent directory (i.e. `$GFE_REPO/chisel_processors/P1/xilinx_ip/`).
    * Note that the component.xml file contains a set of files used for simulation (xilinx_anylanguagebehavioralsimulation_view_fileset) and another set used for synthesis. Make sure to replace or remove file entries as necessary in each of these sections.
    * Vivado discovers user IP by searching all it's IP repository paths looking for component.xml files. This is the reason for the specific name. This file fully describes the new processor's IP block and can be modified through a gui if desired using the IP packager flow. It is easier to start with an example component.xml file to ensure the port naming and external interfaces match those used by the block diagram.

3. Add your processor to `$GFE_REPO/tcl/proc_mapping.tcl`. Add a line here to include the mapping between your processor name and directory containing the component.xml file. This mapping is used by the `soc.tcl` build script.
    ```bash
    vim tcl/proc_mapping.tcl
    # Add line if component.xml lives at ../new_processor/component.xml
    + dict set proc_mapping new_processor "../new_processor"
    ```
   The mapping path is relative to the `$GFE_REPO/tcl` path
4. Create a new Vivado project with your new processor by running the following:
    ```bash
    cd $GFE_REPO
    ./setup_soc_project.sh new_processor
    ```
   new_processor is the name specified in the `$GFE_REPO/tcl/proc_mapping.tcl` file.

5. Synthesize and build the design using the normal flow. Note that users will have to update the User IP as prompted in the gui after each modification to the component.xml file or reference Verilog files.

All that is required (and therefore tracked by git) to create a Xilinx User IP block is a component.xml file and the corresponding verilog source files.
If using the Vivado GUI IP packager, the additional project collateral does not need to be tracked by git.

### Modifying the GFE ###

To save changes to the block diagram in git (everything outside the SSITH Processor IP block), please open the block diagram in Vivado and run `write_bd_tcl -force ../tcl/soc_bd.tcl`. Additionally, update `tcl/soc.tcl` to add any project settings.

### Rebuilding the Chisel and Bluespec Processors ###

The compiled verilog from the latest Chisel and Bluespec build is stored in git to enable building the FPGA bitstream right away. To rebuild the bluespec processor, follow the directions in `bluespec-processors/P1/Piccolo/README.md`. To rebuild the Chisel processor for the GFE, run the following commands
```bash
cd chisel_processors/P1
./build.sh
```

## Tandem Verification ##

Below are instructions for running Tandem verification on the GFE. For more information on the trace collected by Tandem Verification see [trace-protocol.pdf](trace-protocol.pdf).

### Establishing the PCIe Link ###

Begin by compiling the provided version of the bluenoc executable and kernel module:

```bash
$ # Install Kernel Headers
$ sudo apt-get install linux-headers-$(uname -r)
$ cd bluenoc/drivers
$ make
$ sudo make install
$ cd ../bluenoc
$ make
```

Next, program the FPGA with a tandem-verification enabled bitstream: `./program_fpga.sh bluespec_p2`

**Note: This process is motherboard-dependent.**

If using the prescribed MSI motherboard in your host machine, you will need to 
power the VCU118 externally using the supplied power brick. You must be able to 
fully shut down the computer while maintaining power to the FPGA. Turn off your
host machine and then turn it back on.

On computers with Asus motherboards (and potentially others), a warm rebooot may be
all that is necessary.

After the cold or warm reboot, run the bluenoc utility to determine if the PCIe link has been established:
```bash
$ cd bluenoc/bluenoc
$ ./bluenoc
Found BlueNoC device at /dev/bluenoc_1
  Board number:     1
  Board:            Xilinx VCU118 (A118)
  BlueNoC revision: 1.0
  Build number:     34908
  Timestamp:        Wed Dec 21 13:41:31 2016
  SceMi Clock:      41.67 MHz
  Network width:    4 bytes per beat
  Content ID:       5ce000600080000
  Debug level:      OFF
  Profiling:        OFF
  PCIe Link:        ENABLED
  BlueNoC Link:     ENABLED
  BlueNoC I/F:      READY
  Memory Sub-Sys:   ENABLED
```

After the link has been established, you may reprogram the FPGA with other TV-enabled bitstreams and re-establish the PCIe link with just a warm reboot.
If you program a bitstream that does not include the tandem verification hardware, you will need to follow the cold reboot procedure to re-establish the link later on.

### Installing Bluespec ###
A full Bluespec installation is required for the current version of the write_tvtrace program. It has been tested with Bluespec-2017.07.A. The following paths should to be set:

```bash
$ export BLUESPECDIR=/opt/Bluespec-2017.07.A/lib
$ export PATH=$BLUESPECDIR/../bin:$PATH
```

### Licensing ###
For the license to work, Debian must be reconfigured to use old-style naming of the Ethernet devices.

Open `/etc/default/grub` and modify:

```
GRUB_CMDLINE_LINUX=""
```

to contain:

```
GRUB_CMDLINE_LINUX="net.ifnames=0 biosdevname=0"
```

Rebuild the grub configuration:

```
sudo grub-mkconfig -o /boot/grub/grub.cfg
```

After a reboot, check that there is now a `eth0` networking device:

```bash
$ ip link
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN mode DEFAULT group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast state UP mode DEFAULT group default qlen 1000
    link/ether 30:9c:23:a5:f2:40 brd ff:ff:ff:ff:ff:ff
```

If you have more than one network device, be sure the MAC address for eth0 is used to request a license, even if it is not your active connection.

Send the MAC address to support@bluespec.com to request a license if you do not already have one.

Once the license is obtained, set the following variable (replacing the path with the proper location):

```bash
$ export LM_LICENSE_FILE=/opt/Bluespec.lic
```

### Capturing a Trace ###
Use the `exe_write_tvtrace_RV64` program to capture a trace:

```bash
$ cd $GFE_DIR/TV-hostside
$ ./exe_write_tvtrace_RV64
----------------------------------------------------------------
Bluespec SSITH Support, TV Trace Dumper v1.0
Copyright (c) 2016-2019 Bluespec, Inc. All Rights Reserved.
----------------------------------------------------------------

---------------- debug start
Starting verifier thread
Writing trace to 'trace_data.dat'
Receiving traces ...
^C
```

Use `Ctrl-C` to stop capturing trace data after your program has finished executing.

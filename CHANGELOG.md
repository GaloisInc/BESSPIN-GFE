# Changelog

## v5.0.3 (2020-01-29)
* Refactored and improved test scripts (use now `pytest_processor.py` and `pyprogram_fpga.sh`)
* CI changes and improvements to support BESSPIN CI pipeline


## v5.0 (2020-01-02)
* Parallelized build processes for Busybox and Debian using qemu, improving performance on multicore host machines (!44)
* Resolved a PCIe packet loss issue for Chisel P2 processors (#130)
* Added Coremark benchmarks for P1 and P2 processors (!51)
* Updated P3 processors

## v4.3 (2019-11-26)
* Microarchitecture improvements to P2 Flute processors
* Performance enhancements to PCIe root complex for P1 and P2 processors

## v4.2 (2019-10-22)
* The GFE SoC is updated with the PCIe root complex. FPGA builds include the PCIe root complex, but installing the PCIe FMC card, cable and expansion chassis is not required to operate the GFE. The SVF is not in Release 4.2 but will be added back in release 4.3. P1 processors run at 50 MHz and P2 at 100 MHz. P3 processors are not supported in Release 4.2. 
* Nix is no longer required. Software dependencies can be installed directly on the Debian host system.
* Testing scripts have been converted from Python 2 to Python 3.

## v4.1
* Increased P2 frequency to 100 MHz
* Released new OpenOCD binary for faster load speeds and compatibility with "soft reset" 

## v4.0
* Increased P2 frequency to 68 MHz
* Released P1 and P2 Verilator simulations

## v3.0
* Added Flash hardware and scripts to program VCU118 with linux boot images
* P3 processors: added Chisel processor fpga emulation and Bluespec processor simulation capabilities

## v2.2
* SVF hardware added to the reference SoC
* Introduced host software to connect to the GFE over PCIE and record SVF traces

## v2.1
* Ethernet and DMA hardware added to reference SoC
* Included:
    * Ethernet drivers and documentation for FreeRTOS on P1 processors
    * Ethernet drivers and documentation for Linux on P2 processors
    
## v2.0
This release enables building and testing a Bluespec or Chisel P2 reference SoC implemented on the VCU118
* Introduced 64-bit P2 processors in Chisel and Bluespec languages
* Added ability to copy the bitstream to on-board flash and program the FPGA from Flash
* Included Linux Kernel (4.20) and Linux boot environment based on Busybox
* Improved testing suites for both the P1 and P2 processors
* Updated SoC memory map

## v1.2
* Upgraded to upstream FreeRTOS
* Matched clint base address and tick rate across Chisel and Bluespec builds

## v1.1
* Fixed a timing constraint on the Bluespec P1 JTAG module, enabling JTAG debugging for the Bluespec P1 system
* Added working bitstreams for Chisel and Bluespec builds
* Added system level documentation
* Fixed assembly architecture in baremetal tests
* Minor improvements to the build flow

## v1.0
* Enabled building and testing a Bluespec or Chisel P1 reference SoC implemented on the VCU118. This SoC includes UART, bootrom, DDR, and JTAG peripherals.

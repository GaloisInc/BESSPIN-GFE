# ----- UART Pins ------
set_property IOSTANDARD LVCMOS18 [get_ports rs232_uart_rxd]
set_property PACKAGE_PIN AW25 [get_ports rs232_uart_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports rs232_uart_txd]
set_property PACKAGE_PIN BB21 [get_ports rs232_uart_txd]
set_property DRIVE 12 [get_ports rs232_uart_txd]
set_property SLEW SLOW [get_ports rs232_uart_txd]
set_property IOSTANDARD LVCMOS18 [get_ports rs232_uart_cts]
set_property PACKAGE_PIN BB22 [get_ports rs232_uart_cts]
set_property IOSTANDARD LVCMOS18 [get_ports rs232_uart_rts]
set_property PACKAGE_PIN AY25 [get_ports rs232_uart_rts]
set_property DRIVE 12 [get_ports rs232_uart_rts]
set_property SLEW SLOW [get_ports rs232_uart_rts]

# ----- PCIe Pins ------

set_false_path -from [get_ports pcie_perstn]




# ----- JTAG TAP constraints ------

create_clock -period 40.000 -name tck -waveform {0.000 20.000} [get_pins xilinx_jtag_0/tck]

set_clock_groups -asynchronous -group tck -group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1}
set_clock_groups -asynchronous -group tck_internal -group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1 tck}

# ----- Bitstream Constraints -----

set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

##-----------------------------------------------------------------------------
##
## (c) Copyright 2012-2012 Xilinx, Inc. All rights reserved.
##
## This file contains confidential and proprietary information
## of Xilinx, Inc. and is protected under U.S. and
## international copyright and other intellectual property
## laws.
##
## DISCLAIMER
## This disclaimer is not a license and does not grant any
## rights to the materials distributed herewith. Except as
## otherwise provided in a valid license issued to you by
## Xilinx, and to the maximum extent permitted by applicable
## law: (1) THESE MATERIALS ARE MADE AVAILABLE "AS IS" AND
## WITH ALL FAULTS, AND XILINX HEREBY DISCLAIMS ALL WARRANTIES
## AND CONDITIONS, EXPRESS, IMPLIED, OR STATUTORY, INCLUDING
## BUT NOT LIMITED TO WARRANTIES OF MERCHANTABILITY, NON-
## INFRINGEMENT, OR FITNESS FOR ANY PARTICULAR PURPOSE; and
## (2) Xilinx shall not be liable (whether in contract or tort,
## including negligence, or under any other theory of
## liability) for any loss or damage of any kind or nature
## related to, arising under or in connection with these
## materials, including for any direct, or any indirect,
## special, incidental, or consequential loss or damage
## (including loss of data, profits, goodwill, or any type of
## loss or damage suffered as a result of any action brought
## by a third party) even if such damage or loss was
## reasonably foreseeable or Xilinx had been advised of the
## possibility of the same.
##
## CRITICAL APPLICATIONS
## Xilinx products are not designed or intended to be fail-
## safe, or for use in any application requiring fail-safe
## performance, such as life-support or safety devices or
## systems, Class III medical devices, nuclear facilities,
## applications related to the deployment of airbags, or any
## other applications that could lead to death, personal
## injury, or severe property or environmental damage
## (individually and collectively, "Critical
## Applications"). Customer assumes the sole risk and
## liability of any use of Xilinx products in Critical
## Applications, subject only to applicable laws and
## regulations governing limitations on product liability.
##
## THIS COPYRIGHT NOTICE AND DISCLAIMER MUST BE RETAINED AS
## PART OF THIS FILE AT ALL TIMES.
##
##-----------------------------------------------------------------------------
##
## Project    : UltraScale+ FPGA PCI Express v4.0 Integrated Block
## File       : xilinx_pcie4_uscale_plus_x1y2.xdc
## Version    : 1.3
##-----------------------------------------------------------------------------
#
###############################################################################
# Vivado - PCIe GUI / User Configuration
###############################################################################
#
# Link Speed   - Gen1 - Gb/s
# Link Width   - X8
# AXIST Width  - 64-bit
# AXIST Frequ  - 250 MHz = User Clock
# Core Clock   - 250 MHz
# Pipe Clock   - 125 MHz (Gen1) / 250 MHz (Gen2/Gen3/Gen4)
#
# Family       - virtexuplus
# Part         - xcvu9p
# Package      - flga2104
# Speed grade  - -2L
# PCIe Block   - X1Y2
# Xilinx Reference Board is VCU118
#
#
# PLL TYPE     - CPLL
#
###############################################################################
# User Time Names / User Time Groups / Time Specs
###############################################################################
create_clock -period 10.000 -name pcie_refclk_clk [get_ports pcie_refclk_clk_p]
#
set_false_path -from [get_ports pcie_perstn]
set_property PULLUP true [get_ports pcie_perstn]
set_property IOSTANDARD LVCMOS18 [get_ports pcie_perstn]
set_property PACKAGE_PIN AM17 [get_ports pcie_perstn]
#
set_property PACKAGE_PIN AC8 [get_ports pcie_refclk_clk_n]
set_property PACKAGE_PIN AC9 [get_ports pcie_refclk_clk_p]
#
# LEDs for VCU118
set_property PACKAGE_PIN AT32 [get_ports led_0]
# user_link_up
set_property PACKAGE_PIN AV34 [get_ports led_1]
# Clock Up/Heart Beat(HB)
set_property PACKAGE_PIN AY30 [get_ports led_2]
# cfg_current_speed[0] => 00: Gen1; 01: Gen2; 10:Gen3; 11:Gen4
set_property PACKAGE_PIN BB32 [get_ports led_3]
# cfg_current_speed[1]
set_property PACKAGE_PIN BF32 [get_ports led_4]
# cfg_negotiated_width[0] => 000: x1; 001: x2; 010: x4; 011: x8; 100: x16
set_property PACKAGE_PIN AU37 [get_ports led_5]
# cfg_negotiated_width[1]
set_property PACKAGE_PIN AV36 [get_ports led_6]
# cfg_negotiated_width[2]
set_property PACKAGE_PIN BA37 [get_ports led_7]
#
set_property IOSTANDARD LVCMOS12 [get_ports led_0]
set_property IOSTANDARD LVCMOS12 [get_ports led_1]
set_property IOSTANDARD LVCMOS12 [get_ports led_2]
set_property IOSTANDARD LVCMOS12 [get_ports led_3]
set_property IOSTANDARD LVCMOS12 [get_ports led_4]
set_property IOSTANDARD LVCMOS12 [get_ports led_5]
set_property IOSTANDARD LVCMOS12 [get_ports led_6]
set_property IOSTANDARD LVCMOS12 [get_ports led_7]
#
set_property DRIVE 8 [get_ports led_0]
set_property DRIVE 8 [get_ports led_1]
set_property DRIVE 8 [get_ports led_2]
set_property DRIVE 8 [get_ports led_3]
set_property DRIVE 8 [get_ports led_4]
set_property DRIVE 8 [get_ports led_5]
set_property DRIVE 8 [get_ports led_6]
set_property DRIVE 8 [get_ports led_7]
#
set_false_path -to [get_ports -filter NAME=~led_*]
#
# Clock for the 300 MHz clock is already created in the Clock Wizard IP.
# 300 MHz clock pin constraints.
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk_300MHz_p]
set_property IOSTANDARD DIFF_SSTL12 [get_ports clk_300MHz_n]
set_property PACKAGE_PIN G31 [get_ports clk_300MHz_p]
set_property PACKAGE_PIN F31 [get_ports clk_300MHz_n]
#
#
# CLOCK_ROOT LOCKing to Reduce CLOCK SKEW
# Add/Edit  Clock Routing Option to improve clock path skew
#set_property USER_CLOCK_ROOT X5Y6 [get_nets -of_objects [get_pins pcie4_uscale_plus_0_i/inst//bufg_gt_sysclk/O]]
#
# BITFILE/BITSTREAM compress options (see above)
# Flash type constraints. These should be modified to match the target board.
#set_property BITSTREAM.CONFIG.EXTMASTERCCLK_EN div-1 [current_design]
#set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
#set_property CONFIG_MODE SPIx8 [current_design]
#set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]
#set_property BITSTREAM.CONFIG.UNUSEDPIN Pulldown [current_design]
#
#
#
#
# pcie_refclk_clk vs TXOUTCLK
set_clock_groups -name async18 -asynchronous -group [get_clocks pcie_refclk_clk] -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -name async19 -asynchronous -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks pcie_refclk_clk]
#
# clk_300MHz vs TXOUTCLK
set_clock_groups -name async22 -asynchronous -group [get_clocks -of_objects [get_ports clk_300MHz_p]] -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]]
set_clock_groups -name async23 -asynchronous -group [get_clocks -of_objects [get_pins -hierarchical -filter {NAME =~ *gen_channel_container[*].*gen_gtye4_channel_inst[*].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}]] -group [get_clocks -of_objects [get_ports clk_300MHz_p]]
#
#
#
set_clock_groups -name asynco -asynchronous -group [get_clocks -of_objects [get_pins mem_clk_inst/clk_out1]] -group [get_clocks {pcie_refclk_clk}]
set_clock_groups -name asyncp -asynchronous -group [get_clocks {pcie_refclk_clk}] -group [get_clocks -of_objects [get_pins mem_clk_inst/clk_out1]]
#
#
#
# ASYNC CLOCK GROUPINGS
# pcie_refclk_clk vs pclk
set_clock_groups -name async1 -asynchronous -group [get_clocks {pcie_refclk_clk}] -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]]
set_clock_groups -name async2 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_pclk/O]] -group [get_clocks {pcie_refclk_clk}]
#
#
#
#
# Timing improvement
# Add/Edit Pblock slice constraints for init_ctr module to improve timing
#create_pblock init_ctr_rst; add_cells_to_pblock [get_pblocks init_ctr_rst] [get_cells pcie4_uscale_plus_0_i/inst/pcie_4_0_pipe_inst/pcie_4_0_init_ctrl_inst]
# Keep This Logic Left/Right Side Of The PCIe Block (Whichever is near to the FPGA Boundary)
#resize_pblock [get_pblocks init_ctr_rst] -add {SLICE_X157Y300:SLICE_X168Y372}
#
set_clock_groups -name async24 -asynchronous -group [get_clocks -of_objects [get_pins pcie4_uscale_plus_0_i/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/phy_clk_i/bufg_gt_intclk/O]] -group [get_clocks {pcie_refclk_clk}]

set_clock_groups -name async30 -asynchronous -group [get_clocks pcie_refclk_clk] -group [get_clocks mmcm_clkout5]

set_clock_groups -name async31 -asynchronous -group [get_clocks {svf_pcie_bridge/pcie4_uscale_plus_0/inst/gt_top_i/diablo_gt.diablo_gt_phy_wrapper/gt_wizard.gtwizard_top_i/design_1_pcie4_uscale_plus_0_0_gt_i/inst/gen_gtwizard_gtye4_top.design_1_pcie4_uscale_plus_0_0_gt_gtwizard_gtye4_inst/gen_gtwizard_gtye4.gen_channel_container[31].gen_enabled_channel.gtye4_channel_wrapper_inst/channel_inst/gtye4_channel_gen.gen_gtye4_channel_inst[0].GTYE4_CHANNEL_PRIM_INST/TXOUTCLK}] -group [get_clocks mmcm_clkout5]


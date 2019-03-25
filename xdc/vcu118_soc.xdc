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

# ----- JTAG TAP constraints ------

create_clock -period 40.000 -name tck -waveform {0.000 20.000} [get_pins xilinx_jtag_0/tck]

set_clock_groups -asynchronous -group tck -group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1}

# ----- Bitstream Constraints -----

set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

# ----- External JTAG Port (TODO: Remove this) ------

# ----- PMOD0 Pins (J52 on VCU118) ------

# External JTAG
# -- PMOD0_0_LS
set_property PACKAGE_PIN AY14 [get_ports jtag_TMS]
# -- PMOD0_0_LS
set_property IOSTANDARD LVCMOS18 [get_ports jtag_TMS]
# -- PMOD0_1_LS
set_property PACKAGE_PIN AY15 [get_ports jtag_TDI]
# -- PMOD0_1_LS
set_property IOSTANDARD LVCMOS18 [get_ports jtag_TDI]
# -- PMOD0_2_LS
set_property PACKAGE_PIN AW15 [get_ports jtag_TDO]
# -- PMOD0_2_LS
set_property IOSTANDARD LVCMOS18 [get_ports jtag_TDO]
# -- PMOD0_3_LS
set_property PACKAGE_PIN AV15 [get_ports jtag_TCK]
# -- PMOD0_3_LS
set_property IOSTANDARD LVCMOS18 [get_ports jtag_TCK]

# Timing constraints
set_property CLOCK_DEDICATED_ROUTE FALSE [get_nets jtag_TCK]


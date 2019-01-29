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

set_clock_groups -asynchronous \
-group {tck} \
-group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1}


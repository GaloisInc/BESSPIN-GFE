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

# ----- PMOD1 Pins (J53 on VCU118) -----
# ----- IIC -----
set_property IOSTANDARD LVCMOS12 [get_ports iic_sda]
set_property PACKAGE_PIN N28 [get_ports iic_sda]; # PMOD_1_0
set_property DRIVE 8 [get_ports iic_sda]
set_property IOSTANDARD LVCMOS12 [get_ports iic_scl]
set_property PACKAGE_PIN M30 [get_ports iic_scl]; #PMOD_1_1
set_property DRIVE 8 [get_ports iic_scl]

# ----- SPI -----
set_property IOSTANDARD LVCMOS12 [get_ports spi_ss]
set_property PACKAGE_PIN P29 [get_ports spi_ss]; # PMOD_1_4
set_property DRIVE 8 [get_ports spi_ss]
set_property IOSTANDARD LVCMOS12 [get_ports spi_mosi]
set_property PACKAGE_PIN L31 [get_ports spi_mosi]; # PMOD_1_5
set_property DRIVE 8 [get_ports spi_mosi]
set_property IOSTANDARD LVCMOS12 [get_ports spi_miso]
set_property PACKAGE_PIN M31 [get_ports spi_miso]; # PMOD_1_6
set_property DRIVE 8 [get_ports spi_miso]
set_property IOSTANDARD LVCMOS12 [get_ports spi_sck]
set_property PACKAGE_PIN R29 [get_ports spi_sck]; # PMOD_1_7
set_property DRIVE 8 [get_ports spi_sck]

# ----- JTAG TAP constraints ------

create_clock -period 40.000 -name tck -waveform {0.000 20.000} [get_pins xilinx_jtag_0/tck]

set_clock_groups -asynchronous \
-group {tck} \
-group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1}


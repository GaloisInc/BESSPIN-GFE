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

# ----- PMOD0 Pins (J52 on VCU118) -----
# ----- UART1 -----
set_property IOSTANDARD LVCMOS12 [get_ports uart1_tx]
set_property PACKAGE_PIN AV16 [get_ports uart1_tx]; # PMOD_0_4
set_property IOSTANDARD LVCMOS12 [get_ports uart1_rx]
set_property PACKAGE_PIN AU16 [get_ports uart1_rx]; # PMOD_0_5

# ----- GPIO (output for motors) -----
set_property IOSTANDARD LVCMOS12 [get_ports gpio_out[0]]
set_property PACKAGE_PIN AY14 [get_ports gpio_out[0]]; # PMOD_0_0
set_property IOSTANDARD LVCMOS12 [get_ports gpio_out[1]]
set_property PACKAGE_PIN AY15 [get_ports gpio_out[1]]; # PMOD_0_1
set_property IOSTANDARD LVCMOS12 [get_ports gpio_out[2]]
set_property PACKAGE_PIN AW15 [get_ports gpio_out[2]]; # PMOD_0_2
set_property IOSTANDARD LVCMOS12 [get_ports gpio_out[3]]
set_property PACKAGE_PIN AV14 [get_ports gpio_out[3]]; # PMOD_0_3

# ----- PMOD1 Pins (J53 on VCU118) -----
# ----- IIC0 -----
set_property IOSTANDARD LVCMOS12 [get_ports iic0_sda]
set_property PACKAGE_PIN N28 [get_ports iic0_sda]; # PMOD_1_0
set_property DRIVE 8 [get_ports iic0_sda]
set_property IOSTANDARD LVCMOS12 [get_ports iic0_scl]
set_property PACKAGE_PIN M30 [get_ports iic0_scl]; #PMOD_1_1
set_property DRIVE 8 [get_ports iic0_scl]

# ----- IIC1 -----
set_property IOSTANDARD LVCMOS12 [get_ports iic1_sda]
set_property PACKAGE_PIN N30 [get_ports iic1_sda]; # PMOD_1_2
set_property DRIVE 8 [get_ports iic1_sda]
set_property IOSTANDARD LVCMOS12 [get_ports iic1_scl]
set_property PACKAGE_PIN P30 [get_ports iic1_scl]; #PMOD_1_3
set_property DRIVE 8 [get_ports iic1_scl]

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

# ----- User GPIO LEDs -----
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[7]]
set_property PACKAGE_PIN BA37 [get_ports gpio_led[7]]; # GPIO_LED_7
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[6]]
set_property PACKAGE_PIN AV36 [get_ports gpio_led[6]]; # GPIO_LED_6
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[5]]
set_property PACKAGE_PIN AU37 [get_ports gpio_led[5]]; # GPIO_LED_5
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[4]]
set_property PACKAGE_PIN BF32 [get_ports gpio_led[4]]; # GPIO_LED_4
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[3]]
set_property PACKAGE_PIN BB32 [get_ports gpio_led[3]]; # GPIO_LED_3
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[2]]
set_property PACKAGE_PIN AY30 [get_ports gpio_led[2]]; # GPIO_LED_2
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[1]]
set_property PACKAGE_PIN AV34 [get_ports gpio_led[1]]; # GPIO_LED_1
set_property IOSTANDARD LVCMOS12 [get_ports gpio_led[0]]
set_property PACKAGE_PIN AT32 [get_ports gpio_led[0]]; # GPIO_LED_0

# ----- JTAG TAP constraints ------

create_clock -period 40.000 -name tck -waveform {0.000 20.000} [get_pins xilinx_jtag_0/tck]

set_clock_groups -asynchronous -group tck -group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1}

# ----- Bitstream Constraints -----

set_property CONFIG_MODE SPIx8 [current_design]
set_property BITSTREAM.CONFIG.SPI_BUSWIDTH 8 [current_design]
set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]

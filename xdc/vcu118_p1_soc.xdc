# ----- UART Pins ------
set_property IOSTANDARD LVCMOS18 [get_ports rs232_uart_rxd]
set_property PACKAGE_PIN AW25 [get_ports rs232_uart_rxd]
set_property IOSTANDARD LVCMOS18 [get_ports rs232_uart_txd]
set_property PACKAGE_PIN BB21 [get_ports rs232_uart_txd]
set_property DRIVE 12 [get_ports rs232_uart_txd]
set_property SLEW SLOW [get_ports rs232_uart_txd]


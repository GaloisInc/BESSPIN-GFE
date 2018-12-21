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

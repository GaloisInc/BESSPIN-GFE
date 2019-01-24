# ----- JTAG TAP constraints ------

create_clock -period 40.000 -name tck -waveform {0.000 20.000} [get_pins xilinx_jtag_0/tck]

set_false_path -from [get_clocks tck] -to [get_clocks [get_clocks -of_objects [get_pins gfe_subsystem/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT1]]]

set_false_path -from [get_clocks [get_clocks -of_objects [get_pins gfe_subsystem/ddr4_0/inst/u_ddr4_infrastructure/gen_mmcme4.u_mmcme_adv_inst/CLKOUT0]]] -to [get_clocks tck]


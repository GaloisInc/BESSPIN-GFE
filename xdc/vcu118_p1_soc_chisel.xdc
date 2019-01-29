# ----- JTAG TAP constraints ------

create_clock -period 40.000 -name tck -waveform {0.000 20.000} [get_pins xilinx_jtag_0/tck]

set_clock_groups -asynchronous \
-group {tck} \
-group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1}

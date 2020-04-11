set_clock_groups -asynchronous -group tck_internal -group {default_250mhz_clk1_clk_p mmcm_clkout0 mmcm_clkout1 tck}

# This is currently used for all processors except bluespec_p3:
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells ssith_processor_0]

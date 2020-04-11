

# This is currently used for all processors except bluespec_p3:
set_property USER_SLR_ASSIGNMENT SLR0 [get_cells ssith_processor_0]

current_instance gfe_subsystem/ddr4_0/inst
set_property LOC MMCM_X1Y13 [get_cells -hier -filter {NAME =~ */u_ddr4_infrastructure/gen_mmcme*.u_mmcme_adv_inst}]
set_property CLOCK_DEDICATED_ROUTE BACKBONE [get_pins -hier -filter {NAME =~ */u_ddr4_infrastructure/gen_mmcme*.u_mmcme_adv_inst/CLKIN1}]
current_instance -quiet
set_property INTERNAL_VREF 0.84 [get_iobanks 73]
set_property INTERNAL_VREF 0.84 [get_iobanks 72]
set_property INTERNAL_VREF 0.84 [get_iobanks 71]
set_property C_CLK_INPUT_FREQ_HZ 300000000 [get_debug_cores dbg_hub]
set_property C_ENABLE_CLK_DIVIDER false [get_debug_cores dbg_hub]
set_property C_USER_SCAN_CHAIN 1 [get_debug_cores dbg_hub]
connect_debug_port dbg_hub/clk [get_nets clk]

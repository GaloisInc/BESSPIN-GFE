exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/xdma_0/S_AXI_LITE/CTL0] -target_address_space [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi]
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/xdma_0/S_AXI_B/BAR0] -target_address_space [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi]
assign_bd_address [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] -target_address_space /gfe_subsystem/xdma_0/M_AXI_B

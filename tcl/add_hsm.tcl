# Instantiate the HSM
startgroup
create_bd_cell -type ip -vlnv ssith:user:SSITHHSM:1.0 gfe_subsystem/SSITHHSM_0
endgroup

# Hook it up to already existing ports
connect_bd_net [get_bd_pins gfe_subsystem/SSITHHSM_0/interrupts] [get_bd_pins gfe_subsystem/xlconcat_0/In11]
connect_bd_intf_net -boundary_type upper [get_bd_intf_pins gfe_subsystem/axi_interconnect_0/M06_AXI] [get_bd_intf_pins gfe_subsystem/SSITHHSM_0/config_axi]
connect_bd_intf_net [get_bd_intf_pins gfe_subsystem/SSITHHSM_0/master_axi] -boundary_type upper [get_bd_intf_pins gfe_subsystem/axi_interconnect_0/S06_AXI]
connect_bd_net [get_bd_pins gfe_subsystem/SSITHHSM_0/clock] [get_bd_pins gfe_subsystem/ddr4_0/addn_ui_clkout1]
connect_bd_net [get_bd_pins gfe_subsystem/SSITHHSM_0/resetn] [get_bd_pins gfe_subsystem/proc_sys_reset_0/peripheral_aresetn]
connect_bd_net [get_bd_pins gfe_subsystem/SSITHHSM_0/divClock] [get_bd_pins gfe_subsystem/ddr4_0/addn_ui_clkout3]

# Memory map changes
create_bd_addr_seg -range 0x01000000 -offset 0x63000000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] SEG_SSITHHSM_0_reg0
create_bd_addr_seg -range 0x01000000 -offset 0x63000000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] SEG_SSITHHSM_0_reg0
create_bd_addr_seg -range 0x00010000 -offset 0x70000000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
create_bd_addr_seg -range 0x10000000 -offset 0x40000000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_quad_spi_0/aximm/MEM0] SEG_axi_quad_spi_0_MEM0
create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK
create_bd_addr_seg -range 0x01000000 -offset 0x63000000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] SEG_SSITHHSM_0_reg0
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_SSITHHSM_0_reg0]
create_bd_addr_seg -range 0x00010000 -offset 0x62200000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_dma_0/S_AXI_LITE/Reg] SEG_axi_dma_0_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_dma_0_Reg]
create_bd_addr_seg -range 0x00040000 -offset 0x62100000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_ethernet_0/s_axi/Reg0] SEG_axi_ethernet_0_Reg0
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_ethernet_0_Reg0]
create_bd_addr_seg -range 0x00010000 -offset 0x6FFF0000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_gpio_0_Reg]
create_bd_addr_seg -range 0x00001000 -offset 0x62330000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_gpio1/axi_gpio_1/S_AXI/Reg] SEG_axi_gpio_1_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_gpio_1_Reg]
create_bd_addr_seg -range 0x00001000 -offset 0x62310000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_iic0/axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_iic_0_Reg]
create_bd_addr_seg -range 0x00001000 -offset 0x62400000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_quad_spi_0/AXI_LITE/Reg] SEG_axi_quad_spi_0_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_quad_spi_0_Reg]
create_bd_addr_seg -range 0x00001000 -offset 0x62320000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_quad_spi1/axi_quad_spi_1/AXI_LITE/Reg] SEG_axi_quad_spi_1_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_quad_spi_1_Reg]
create_bd_addr_seg -range 0x00001000 -offset 0x62300000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_uart16550_0/S_AXI/Reg] SEG_axi_uart16550_0_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_uart16550_0_Reg]
create_bd_addr_seg -range 0x00001000 -offset 0x62340000 [get_bd_addr_spaces gfe_subsystem/SSITHHSM_0/master_axi] [get_bd_addr_segs gfe_subsystem/axi_uart16550_1/S_AXI/Reg] SEG_axi_uart16550_1_Reg
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/master_axi/SEG_axi_uart16550_1_Reg]
create_bd_addr_seg -range 0x01000000 -offset 0x63000000 [get_bd_addr_spaces gfe_subsystem/axi_dma_0/Data_MM2S] [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] SEG_SSITHHSM_0_reg0
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/axi_dma_0/Data_MM2S/SEG_SSITHHSM_0_reg0]
create_bd_addr_seg -range 0x01000000 -offset 0x63000000 [get_bd_addr_spaces gfe_subsystem/axi_dma_0/Data_S2MM] [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] SEG_SSITHHSM_0_reg0
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/axi_dma_0/Data_S2MM/SEG_SSITHHSM_0_reg0]
create_bd_addr_seg -range 0x01000000 -offset 0x63000000 [get_bd_addr_spaces gfe_subsystem/axi_dma_0/Data_SG] [get_bd_addr_segs gfe_subsystem/SSITHHSM_0/config_axi/reg0] SEG_SSITHHSM_0_reg0
exclude_bd_addr_seg [get_bd_addr_segs gfe_subsystem/axi_dma_0/Data_SG/SEG_SSITHHSM_0_reg0]

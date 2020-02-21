####################################################################################
# PCIe endpoint PBlock constraints
####################################################################################

create_pblock pblock_svf_bridge
add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list rc_gearbox_elem0_status_0_reg]]
add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_rc_tlp_in_fifo]]
#add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_rc_tlp_in_fifo/data0_reg_reg[*]]]
#add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_rc_tlp_in_fifo/data1_reg_reg[*]]]

resize_pblock [get_pblocks pblock_svf_bridge] -add {SLICE_X100Y300:SLICE_X105Y321}

add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list cq_gearbox_elem0_status_1_reg]]
add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_cq_tlp_in_fifo]]
#add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_cq_tlp_in_fifo/cq_gearbox_elem0_status_1]]
#add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_cq_tlp_in_fifo/data0_reg[*]]]
#add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_cq_tlp_in_fifo/data0_reg_reg[*]]]
#add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list bridge/pbb_dispatcher_cq_tlp_in_fifo/data1_reg_reg[*]]]

add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list cc_gearbox_elem1_status_1_reg]]
add_cells_to_pblock [get_pblocks pblock_svf_bridge] [get_cells -quiet [list cc_gearbox_block1_reg]]

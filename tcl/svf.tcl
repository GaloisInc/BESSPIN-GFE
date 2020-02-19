#-----------------------------------------------------------
# Vivado v2019.1 (64-bit)
# SW Build 2552052 on Fri May 24 14:47:09 MDT 2019
# IP Build 2548770 on Fri May 24 18:01:18 MDT 2019
# Start of session at: Thu Jan  9 17:57:45 2020
# Process ID: 2167
# Current directory: /home/chauck/stoy_gfe-83rebase/vivado
# Command line: vivado soc_bluespec_p2/soc_bluespec_p2.xpr
# Log file: /home/chauck/stoy_gfe-83rebase/vivado/vivado.log
# Journal file: /home/chauck/stoy_gfe-83rebase/vivado/vivado.jou
#-----------------------------------------------------------
#start_gui
#open_project soc_bluespec_p2/soc_bluespec_p2.xpr
#open_bd_design {soc_bluespec_p2/soc_bluespec_p2.srcs/sources_1/bd/design_1/design_1.bd}
# (comment out above three lines eventually)

delete_bd_objs [get_bd_nets gfe_subsystem/util_ds_buf_0_IBUF_OUT] [get_bd_nets gfe_subsystem/xdma_0_pci_exp_txp] [get_bd_nets gfe_subsystem/pci_exp_rxp_0_1] [get_bd_nets gfe_subsystem/xdma_0_interrupt_out] [get_bd_nets gfe_subsystem/xdma_0_interrupt_out_msi_vec32to63] [get_bd_nets gfe_subsystem/util_ds_buf_0_IBUF_DS_ODIV2] [get_bd_nets gfe_subsystem/xdma_0_pci_exp_txn] [get_bd_nets gfe_subsystem/pci_exp_rxn_0_1] [get_bd_nets gfe_subsystem/xdma_0_axi_ctl_aresetn] [get_bd_nets gfe_subsystem/xdma_0_interrupt_out_msi_vec0to31] [get_bd_intf_nets gfe_subsystem/axi_interconnect_0_M03_AXI] [get_bd_intf_nets gfe_subsystem/S05_AXI_1] [get_bd_intf_nets gfe_subsystem/axi_interconnect_0_M04_AXI] [get_bd_cells gfe_subsystem/xdma_0]
delete_bd_objs [get_bd_nets gfe_subsystem/IBUF_DS_P_0_1] [get_bd_nets gfe_subsystem/IBUF_DS_N_0_1] [get_bd_cells gfe_subsystem/util_ds_buf_0]
delete_bd_objs [get_bd_nets IBUF_DS_N_0_1] [get_bd_pins gfe_subsystem/fmc_pcie_clk_n]
delete_bd_objs [get_bd_nets IBUF_DS_P_0_1] [get_bd_pins gfe_subsystem/fmc_pcie_clk_p]
delete_bd_objs [get_bd_nets pci_exp_rxp_0_1] [get_bd_pins gfe_subsystem/fmc_pcie_rxp]
delete_bd_objs [get_bd_nets pci_exp_rxn_0_1] [get_bd_pins gfe_subsystem/fmc_pcie_rxn]
delete_bd_objs [get_bd_nets gfe_subsystem_pci_exp_txn_0] [get_bd_pins gfe_subsystem/fmc_pcie_txn]
delete_bd_objs [get_bd_nets gfe_subsystem_pci_exp_txp_0] [get_bd_pins gfe_subsystem/fmc_pcie_txp]
#write_bd_tcl -force del_xdma.tcl
delete_bd_objs [get_bd_ports fmc_pcie_clk_p] [get_bd_ports fmc_pcie_rxn] [get_bd_ports fmc_pcie_clk_n] [get_bd_ports fmc_pcie_rxp]
delete_bd_objs [get_bd_ports fmc_pcie_txn] [get_bd_ports fmc_pcie_txp]
#write_bd_tcl -force del_xdma.tcl
#reset_run design_1_s04_regslice_0_synth_1
#reset_run design_1_m01_regslice_4_synth_1
#save_bd_design
#reset_run synth_1
#launch_runs synth_1 -jobs 4
connect_bd_net [get_bd_pins gfe_subsystem/xlconstant_0/dout] [get_bd_pins gfe_subsystem/axi_interconnect_0/M03_ACLK]
connect_bd_net [get_bd_pins gfe_subsystem/axi_interconnect_0/M04_ARESETN] [get_bd_pins gfe_subsystem/axi_interconnect_0/M03_ARESETN] -boundary_type upper
connect_bd_net [get_bd_pins gfe_subsystem/axi_interconnect_0/M04_ARESETN] [get_bd_pins gfe_subsystem/xlconstant_0/dout]
#save_bd_design
#launch_runs synth_1 -jobs 4

proc create_hier_cell_svf_pcie_bridge { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_svf_pcie_bridge() - Empty argument(s)!"}
     return
  }

  # Get object for parentCell
  set parentObj [get_bd_cells $parentCell]
  if { $parentObj == "" } {
     catch {common::send_msg_id "BD_TCL-100" "ERROR" "Unable to find parent cell <$parentCell>!"}
     return
  }

  # Make sure parentObj is hier blk
  set parentType [get_property TYPE $parentObj]
  if { $parentType ne "hier" } {
     catch {common::send_msg_id "BD_TCL-101" "ERROR" "Parent <$parentObj> has TYPE = <$parentType>. Expected to be <hier>."}
     return
  }

  # Save current instance; Restore later
  set oldCurInst [current_bd_instance .]

  # Set parent object as current
  current_bd_instance $parentObj

  # Create cell and set as current instance
  set hier_obj [create_bd_cell -type hier $nameHier]
  current_bd_instance $hier_obj

  # Create interface pins
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:axis_rtl:1.0 axi_in

  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie4_mgt_0

  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk


  # Create pins
  create_bd_pin -dir I -type clk CLK
  create_bd_pin -dir I -type rst RST_N
  create_bd_pin -dir I -type rst pcie_perstn
  create_bd_pin -dir I -from 1 -to 0 tvswitch_0

  # Create instance: clk_wiz_1, and set properties
  set clk_wiz_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:clk_wiz:6.0 clk_wiz_1 ]
  set_property -dict [ list \
   CONFIG.CLKIN1_JITTER_PS {40.0} \
   CONFIG.CLKOUT1_JITTER {106.624} \
   CONFIG.CLKOUT1_PHASE_ERROR {85.285} \
   CONFIG.CLKOUT1_REQUESTED_OUT_FREQ {125.000} \
   CONFIG.CLKOUT2_JITTER {98.122} \
   CONFIG.CLKOUT2_PHASE_ERROR {79.008} \
   CONFIG.CLKOUT2_REQUESTED_OUT_FREQ {100.000} \
   CONFIG.CLKOUT2_USED {false} \
   CONFIG.MMCM_CLKFBOUT_MULT_F {9.625} \
   CONFIG.MMCM_CLKIN1_PERIOD {4.000} \
   CONFIG.MMCM_CLKIN2_PERIOD {10.0} \
   CONFIG.MMCM_CLKOUT0_DIVIDE_F {9.625} \
   CONFIG.MMCM_CLKOUT1_DIVIDE {1} \
   CONFIG.MMCM_DIVCLK_DIVIDE {2} \
   CONFIG.NUM_OUT_CLKS {1} \
   CONFIG.PRIM_IN_FREQ {250.000} \
   CONFIG.USE_LOCKED {false} \
   CONFIG.USE_RESET {false} \
 ] $clk_wiz_1

  # Create instance: ibufds_gte4_0, and set properties
  set ibufds_gte4_0 [ create_bd_cell -type ip -vlnv bluespec:user:ibufds_gte4:1.0 ibufds_gte4_0 ]

  # Create instance: mkSVF_Bridge_0, and set properties
  set mkSVF_Bridge_0 [ create_bd_cell -type ip -vlnv bluespec:user:mkSVF_Bridge:1.0 mkSVF_Bridge_0 ]

  # Create instance: pcie4_uscale_plus_0, and set properties
  set pcie4_uscale_plus_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:pcie4_uscale_plus:1.3 pcie4_uscale_plus_0 ]
  set_property -dict [ list \
   CONFIG.MSI_X_OPTIONS {MSI-X_External} \
   CONFIG.PCIE_BOARD_INTERFACE {Custom} \
   CONFIG.PF0_CLASS_CODE {070000} \
   CONFIG.PF0_DEVICE_ID {B100} \
   CONFIG.PF0_LINK_STATUS_SLOT_CLOCK_CONFIG {false} \
   CONFIG.PF0_MSIX_CAP_PBA_OFFSET {00005000} \
   CONFIG.PF0_MSIX_CAP_TABLE_OFFSET {00004000} \
   CONFIG.PF0_MSIX_CAP_TABLE_SIZE {004} \
   CONFIG.PF0_SUBSYSTEM_ID {A118} \
   CONFIG.PF0_SUBSYSTEM_VENDOR_ID {1BE7} \
   CONFIG.PF0_Use_Class_Code_Lookup_Assistant {false} \
   CONFIG.PF2_DEVICE_ID {9018} \
   CONFIG.PF3_DEVICE_ID {9018} \
   CONFIG.PL_LINK_CAP_MAX_LINK_WIDTH {X8} \
   CONFIG.REF_CLK_FREQ {100_MHz} \
   CONFIG.RX_PPM_OFFSET {600} \
   CONFIG.SYS_RST_N_BOARD_INTERFACE {pcie_perstn} \
   CONFIG.axisten_freq {250} \
   CONFIG.axisten_if_enable_client_tag {true} \
   CONFIG.extended_tag_field {false} \
   CONFIG.mode_selection {Advanced} \
   CONFIG.pf0_bar0_size {32} \
   CONFIG.pf0_base_class_menu {Simple_communication_controllers} \
   CONFIG.pf0_class_code_base {07} \
   CONFIG.pf0_class_code_sub {00} \
   CONFIG.pf0_dev_cap_max_payload {512_bytes} \
   CONFIG.pf0_msi_enabled {false} \
   CONFIG.pf0_msix_enabled {true} \
   CONFIG.pf0_sub_class_interface_menu {Generic_XT_compatible_serial_controller} \
   CONFIG.pf1_bar0_size {32} \
   CONFIG.pf1_vendor_id {1BE7} \
   CONFIG.pf2_bar0_size {32} \
   CONFIG.pf2_vendor_id {1BE7} \
   CONFIG.pf3_bar0_size {32} \
   CONFIG.pf3_vendor_id {1BE7} \
   CONFIG.vendor_id {1BE7} \
 ] $pcie4_uscale_plus_0

  # Create interface connections
  connect_bd_intf_net -intf_net Conn1 [get_bd_intf_pins pcie4_mgt_0] [get_bd_intf_pins pcie4_uscale_plus_0/pcie4_mgt]
  connect_bd_intf_net -intf_net mkSVF_Bridge_0_m_axis_cc [get_bd_intf_pins mkSVF_Bridge_0/m_axis_cc] [get_bd_intf_pins pcie4_uscale_plus_0/s_axis_cc]
  connect_bd_intf_net -intf_net mkSVF_Bridge_0_m_axis_rq [get_bd_intf_pins mkSVF_Bridge_0/m_axis_rq] [get_bd_intf_pins pcie4_uscale_plus_0/s_axis_rq]
  connect_bd_intf_net -intf_net pcie4_uscale_plus_0_m_axis_cq [get_bd_intf_pins mkSVF_Bridge_0/s_axis_cq] [get_bd_intf_pins pcie4_uscale_plus_0/m_axis_cq]
  connect_bd_intf_net -intf_net pcie4_uscale_plus_0_m_axis_rc [get_bd_intf_pins mkSVF_Bridge_0/s_axis_rc] [get_bd_intf_pins pcie4_uscale_plus_0/m_axis_rc]
  connect_bd_intf_net -intf_net pcie4_uscale_plus_0_pcie4_cfg_fc [get_bd_intf_pins mkSVF_Bridge_0/cfg_fc] [get_bd_intf_pins pcie4_uscale_plus_0/pcie4_cfg_fc]
  connect_bd_intf_net -intf_net pcie4_uscale_plus_0_pcie4_cfg_mesg_rcvd [get_bd_intf_pins mkSVF_Bridge_0/cfg_mesg_rcvd] [get_bd_intf_pins pcie4_uscale_plus_0/pcie4_cfg_mesg_rcvd]
  connect_bd_intf_net -intf_net pcie4_uscale_plus_0_pcie4_cfg_mesg_tx [get_bd_intf_pins mkSVF_Bridge_0/cfg_mesg_tx] [get_bd_intf_pins pcie4_uscale_plus_0/pcie4_cfg_mesg_tx]
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_pins pcie_refclk] [get_bd_intf_pins ibufds_gte4_0/ref_clk]
  connect_bd_intf_net -intf_net ssith_processor_0_tv_verifier_info_tx [get_bd_intf_pins axi_in] [get_bd_intf_pins mkSVF_Bridge_0/axi_in]

  # Create port connections
  connect_bd_net -net CLK_1 [get_bd_pins CLK] [get_bd_pins mkSVF_Bridge_0/CLK_aclk]
  connect_bd_net -net clk_wiz_1_clk_out1 [get_bd_pins clk_wiz_1/clk_out1] [get_bd_pins mkSVF_Bridge_0/CLK_user_clk_half]
  connect_bd_net -net ibufds_gte4_0_o [get_bd_pins ibufds_gte4_0/o] [get_bd_pins pcie4_uscale_plus_0/sys_clk_gt]
  connect_bd_net -net ibufds_gte4_0_odiv2 [get_bd_pins ibufds_gte4_0/odiv2] [get_bd_pins pcie4_uscale_plus_0/sys_clk]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_config_space_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_config_space_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_config_space_enable]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_ds_bus_number [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_ds_bus_number] [get_bd_pins pcie4_uscale_plus_0/cfg_ds_bus_number]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_ds_device_number [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_ds_device_number] [get_bd_pins pcie4_uscale_plus_0/cfg_ds_device_number]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_ds_port_number [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_ds_port_number] [get_bd_pins pcie4_uscale_plus_0/cfg_ds_port_number]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_dsn [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_dsn] [get_bd_pins pcie4_uscale_plus_0/cfg_dsn]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_err_cor_in [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_err_cor_in] [get_bd_pins pcie4_uscale_plus_0/cfg_err_cor_in]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_err_uncor_in [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_err_uncor_in] [get_bd_pins pcie4_uscale_plus_0/cfg_err_uncor_in]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_flr_done [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_flr_done] [get_bd_pins pcie4_uscale_plus_0/cfg_flr_done]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_hot_reset_in [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_hot_reset_in] [get_bd_pins pcie4_uscale_plus_0/cfg_hot_reset_in]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_link_training_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_link_training_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_link_training_enable]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_power_state_change_ack [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_power_state_change_ack] [get_bd_pins pcie4_uscale_plus_0/cfg_power_state_change_ack]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_control_req_pm_transition_l23_ready [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_req_pm_transition_l23_ready] [get_bd_pins pcie4_uscale_plus_0/cfg_req_pm_transition_l23_ready]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_external_msix_msi_function_number [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msi_function_number] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msi_function_number]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_external_msix_msix_address [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_address] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_address]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_external_msix_msix_data [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_data] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_data]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_external_msix_msix_intrpt [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_intrpt] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_int]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_external_msix_msix_vec_pending [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_vec_pending] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_vec_pending]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_interrupt_intrpt [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_interrupt_intrpt] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_int]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_interrupt_pending [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_interrupt_pending] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_pending]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_addr [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_addr] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_addr]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_byte_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_byte_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_byte_enable]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_debug_access [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_debug_access] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_debug_access]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_function_number [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_function_number] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_function_number]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_read [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_read] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_read]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_write [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_write] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_write]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_mgmt_write_data [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_write_data] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_write_data]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_pm_aspm_l1_entry_reject [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_pm_aspm_l1_entry_reject] [get_bd_pins pcie4_uscale_plus_0/cfg_pm_aspm_l1_entry_reject]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_pm_aspm_tx_10s_entry_disable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_pm_aspm_tx_10s_entry_disable] [get_bd_pins pcie4_uscale_plus_0/cfg_pm_aspm_tx_l0s_entry_disable]
  connect_bd_net -net mkSVF_Bridge_0_pcie4_cfg_status_pcie_cq_np_req [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_pcie_cq_np_req] [get_bd_pins pcie4_uscale_plus_0/pcie_cq_np_req]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_bus_number [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_bus_number] [get_bd_pins pcie4_uscale_plus_0/cfg_bus_number]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_current_speed [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_current_speed] [get_bd_pins pcie4_uscale_plus_0/cfg_current_speed]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_err_cor_out [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_err_cor_out] [get_bd_pins pcie4_uscale_plus_0/cfg_err_cor_out]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_err_fatal_out [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_err_fatal_out] [get_bd_pins pcie4_uscale_plus_0/cfg_err_fatal_out]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_err_nonfatal_out [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_err_nonfatal_out] [get_bd_pins pcie4_uscale_plus_0/cfg_err_nonfatal_out]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_flr_in_process [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_flr_in_process] [get_bd_pins pcie4_uscale_plus_0/cfg_flr_in_process]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_function_power_state [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_funstion_power_state] [get_bd_pins pcie4_uscale_plus_0/cfg_function_power_state]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_function_status [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_function_status] [get_bd_pins pcie4_uscale_plus_0/cfg_function_status]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_hot_reset_out [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_hot_reset_out] [get_bd_pins pcie4_uscale_plus_0/cfg_hot_reset_out]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_msi_fail [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msi_fail] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msi_fail]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_msix_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_msix_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_enable]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_msix_mask [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_msix_mask] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_mask]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_msix_vec_pending_status [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_vec_pending_status] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_vec_pending_status]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_msix_vf_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_vf_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_vf_enable]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_msix_vf_mask [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_external_msix_msix_vf_mask] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_msix_vf_mask]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_interrupt_sent [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_interrupt_sent] [get_bd_pins pcie4_uscale_plus_0/cfg_interrupt_sent]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_link_power_state [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_link_power_state] [get_bd_pins pcie4_uscale_plus_0/cfg_link_power_state]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_local_error_out [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_local_error_out] [get_bd_pins pcie4_uscale_plus_0/cfg_local_error_out]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_local_error_valid [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_local_error_valid] [get_bd_pins pcie4_uscale_plus_0/cfg_local_error_valid]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_ltssm_state [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_ltssm_state] [get_bd_pins pcie4_uscale_plus_0/cfg_ltssm_state]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_max_payload [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_max_payload] [get_bd_pins pcie4_uscale_plus_0/cfg_max_payload]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_max_read_req [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_max_read_req] [get_bd_pins pcie4_uscale_plus_0/cfg_max_read_req]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_mgmt_read_data [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_read_data] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_read_data]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_mgmt_read_write_done [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_mgmt_read_write_done] [get_bd_pins pcie4_uscale_plus_0/cfg_mgmt_read_write_done]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_negotiated_width [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_negotiated_width] [get_bd_pins pcie4_uscale_plus_0/cfg_negotiated_width]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_obff_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_obff_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_obff_enable]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_phy_link_down [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_phy_link_down] [get_bd_pins pcie4_uscale_plus_0/cfg_phy_link_down]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_phy_link_status [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_phy_link_status] [get_bd_pins pcie4_uscale_plus_0/cfg_phy_link_status]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_pl_status_change [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_pl_status_change] [get_bd_pins pcie4_uscale_plus_0/cfg_pl_status_change]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_power_state_change_interrupt [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_power_state_change_interrupt] [get_bd_pins pcie4_uscale_plus_0/cfg_power_state_change_interrupt]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_rcb_status [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rcb_status] [get_bd_pins pcie4_uscale_plus_0/cfg_rcb_status]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_rx_pm_state [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rx_pm_state] [get_bd_pins pcie4_uscale_plus_0/cfg_rx_pm_state]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_tph_requester_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_tph_requester_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_tph_requester_enable]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_tph_st_mode [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_tph_st_mode] [get_bd_pins pcie4_uscale_plus_0/cfg_tph_st_mode]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_tx_pm_state [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_tx_pm_state] [get_bd_pins pcie4_uscale_plus_0/cfg_tx_pm_state]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_vf_flr_in_process [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_control_vf_flr_in_process] [get_bd_pins pcie4_uscale_plus_0/cfg_vf_flr_in_process]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_vf_power_state [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_vf_power_state] [get_bd_pins pcie4_uscale_plus_0/cfg_vf_power_state]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_vf_status [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_vf_status] [get_bd_pins pcie4_uscale_plus_0/cfg_vf_status]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_vf_tph_requester_enable [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_vf_tph_requester_enable] [get_bd_pins pcie4_uscale_plus_0/cfg_vf_tph_requester_enable]
  connect_bd_net -net pcie4_uscale_plus_0_cfg_vf_tph_st_mode [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_vf_tph_st_mode] [get_bd_pins pcie4_uscale_plus_0/cfg_vf_tph_st_mode]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_cq_np_req_count [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_pcie_cq_np_req_count] [get_bd_pins pcie4_uscale_plus_0/pcie_cq_np_req_count]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_seq_num0 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_seq_num0] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_seq_num0]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_seq_num1 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_seq_num1] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_seq_num1]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_seq_num_vld0 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_seq_num_vld0] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_seq_num_vld0]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_seq_num_vld1 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_seq_num_vld1] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_seq_num_vld1]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_tag0 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_tag0] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_tag0]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_tag1 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_tag1] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_tag1]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_tag_av [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_tag_av] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_tag_av]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_tag_vld0 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_tag_vld0] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_tag_vld0]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_rq_tag_vld1 [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_rq_tag_vld1] [get_bd_pins pcie4_uscale_plus_0/pcie_rq_tag_vld1]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_tfc_npd_av [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_tfc_npd_av] [get_bd_pins pcie4_uscale_plus_0/pcie_tfc_npd_av]
  connect_bd_net -net pcie4_uscale_plus_0_pcie_tfc_nph_av [get_bd_pins mkSVF_Bridge_0/pcie4_cfg_status_tfc_nph_av] [get_bd_pins pcie4_uscale_plus_0/pcie_tfc_nph_av]
  connect_bd_net -net pcie4_uscale_plus_0_phy_rdy_out [get_bd_pins mkSVF_Bridge_0/pcie4_phy_rdy_out] [get_bd_pins pcie4_uscale_plus_0/phy_rdy_out]
  connect_bd_net -net pcie4_uscale_plus_0_user_clk [get_bd_pins clk_wiz_1/clk_in1] [get_bd_pins mkSVF_Bridge_0/CLK_user_clk] [get_bd_pins pcie4_uscale_plus_0/user_clk]
  connect_bd_net -net pcie4_uscale_plus_0_user_lnk_up [get_bd_pins mkSVF_Bridge_0/pcie4_user_link_up] [get_bd_pins pcie4_uscale_plus_0/user_lnk_up]
  connect_bd_net -net pcie4_uscale_plus_0_user_reset [get_bd_pins mkSVF_Bridge_0/RST_N_user_reset] [get_bd_pins pcie4_uscale_plus_0/user_reset]
  connect_bd_net -net pcie_perstn_1 [get_bd_pins pcie_perstn] [get_bd_pins pcie4_uscale_plus_0/sys_reset]
  connect_bd_net -net tvswitch_0_1 [get_bd_pins tvswitch_0] [get_bd_pins mkSVF_Bridge_0/tvswitch]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins RST_N] [get_bd_pins mkSVF_Bridge_0/RST_N_aresetn]

  # Restore current instance
  current_bd_instance $oldCurInst
}

set pcie4_mgt_0 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:pcie_7x_mgt_rtl:1.0 pcie4_mgt_0 ]
set pcie_refclk [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 pcie_refclk ]
set_property -dict [ list \
   CONFIG.FREQ_HZ {100000000} \
   ] $pcie_refclk
set pcie_perstn [ create_bd_port -dir I -type rst pcie_perstn ]
set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_LOW} \
 ] $pcie_perstn
# Create instance: svf_pcie_bridge
create_hier_cell_svf_pcie_bridge [current_bd_instance .] svf_pcie_bridge
  connect_bd_intf_net -intf_net pcie_refclk_1 [get_bd_intf_ports pcie_refclk] [get_bd_intf_pins svf_pcie_bridge/pcie_refclk]
connect_bd_intf_net -intf_net ssith_processor_0_tv_verifier_info_tx [get_bd_intf_pins ssith_processor_0/tv_verifier_info_tx] [get_bd_intf_pins svf_pcie_bridge/axi_in]
connect_bd_intf_net -intf_net svf_pcie_bridge_pcie4_mgt_0 [get_bd_intf_ports pcie4_mgt_0] [get_bd_intf_pins svf_pcie_bridge/pcie4_mgt_0]
connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins gfe_subsystem/ACLK] [get_bd_pins ssith_processor_0/CLK] [get_bd_pins svf_pcie_bridge/CLK] [get_bd_pins xilinx_jtag_0/clk]
connect_bd_net -net gfe_subsystem_tvswitch [get_bd_pins gfe_subsystem/tvswitch] [get_bd_pins svf_pcie_bridge/tvswitch_0]
connect_bd_net -net pcie_perstn_1 [get_bd_ports pcie_perstn] [get_bd_pins svf_pcie_bridge/pcie_perstn]
connect_bd_net -net util_vector_logic_0_Res [get_bd_pins gfe_subsystem/ARESETN] [get_bd_pins ssith_processor_0/RST_N] [get_bd_pins svf_pcie_bridge/RST_N] [get_bd_pins xilinx_jtag_0/rst_n]

create_bd_cell -type ip -vlnv xilinx.com:ip:xlslice:1.0 gfe_subsystem/xlslice_1
set_property -dict [list CONFIG.DIN_TO {8} CONFIG.DIN_FROM {9} CONFIG.DIN_FROM {9} CONFIG.DOUT_WIDTH {2}] [get_bd_cells gfe_subsystem/xlslice_1]
connect_bd_net [get_bd_pins gfe_subsystem/xlslice_1/Din] [get_bd_pins gfe_subsystem/axi_gpio_0/gpio_io_o]
make_bd_pins_external  [get_bd_pins gfe_subsystem/xlslice_1/Dout]
set_property name tvswitch [get_bd_pins gfe_subsystem/Dout_0]
delete_bd_objs [get_bd_nets gfe_subsystem_Dout_0] [get_bd_ports Dout_0]
connect_bd_net [get_bd_pins gfe_subsystem/tvswitch] [get_bd_pins svf_pcie_bridge/tvswitch_0] -boundary_type upper

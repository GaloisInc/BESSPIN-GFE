
################################################################
# This is a generated script based on design: design_1
#
# Though there are limitations about the generated script,
# the main purpose of this utility is to make learning
# IP Integrator Tcl commands easier.
################################################################

namespace eval _tcl {
proc get_script_folder {} {
   set script_path [file normalize [info script]]
   set script_folder [file dirname $script_path]
   return $script_folder
}
}
variable script_folder
set script_folder [_tcl::get_script_folder]

################################################################
# Check if script is running in correct Vivado version.
################################################################
set scripts_vivado_version 2017.4
set current_vivado_version [version -short]

if { [string first $scripts_vivado_version $current_vivado_version] == -1 } {
   puts ""
   catch {common::send_msg_id "BD_TCL-109" "ERROR" "This script was generated using Vivado <$scripts_vivado_version> and is being run in <$current_vivado_version> of Vivado. Please run the script in Vivado <$scripts_vivado_version> then open the design in Vivado <$current_vivado_version>. Upgrade the design by running \"Tools => Report => Report IP Status...\", then run write_bd_tcl to create an updated script."}

   return 1
}

################################################################
# START
################################################################

# To test this script, run the following commands from Vivado Tcl console:
# source design_1_script.tcl

# If there is no project opened, this script will create a
# project, but make sure you do not have an existing project
# <./myproj/project_1.xpr> in the current working folder.

set list_projs [get_projects -quiet]
if { $list_projs eq "" } {
   create_project project_1 myproj -part xcvu9p-flga2104-2L-e
   set_property BOARD_PART xilinx.com:vcu118:part0:2.0 [current_project]
}


# CHANGE DESIGN NAME HERE
variable design_name
set design_name design_1

# If you do not already have an existing IP Integrator design open,
# you can create a design using the following command:
#    create_bd_design $design_name

# Creating design if needed
set errMsg ""
set nRet 0

set cur_design [current_bd_design -quiet]
set list_cells [get_bd_cells -quiet]

if { ${design_name} eq "" } {
   # USE CASES:
   #    1) Design_name not set

   set errMsg "Please set the variable <design_name> to a non-empty value."
   set nRet 1

} elseif { ${cur_design} ne "" && ${list_cells} eq "" } {
   # USE CASES:
   #    2): Current design opened AND is empty AND names same.
   #    3): Current design opened AND is empty AND names diff; design_name NOT in project.
   #    4): Current design opened AND is empty AND names diff; design_name exists in project.

   if { $cur_design ne $design_name } {
      common::send_msg_id "BD_TCL-001" "INFO" "Changing value of <design_name> from <$design_name> to <$cur_design> since current design is empty."
      set design_name [get_property NAME $cur_design]
   }
   common::send_msg_id "BD_TCL-002" "INFO" "Constructing design in IPI design <$cur_design>..."

} elseif { ${cur_design} ne "" && $list_cells ne "" && $cur_design eq $design_name } {
   # USE CASES:
   #    5) Current design opened AND has components AND same names.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 1
} elseif { [get_files -quiet ${design_name}.bd] ne "" } {
   # USE CASES: 
   #    6) Current opened design, has components, but diff names, design_name exists in project.
   #    7) No opened design, design_name exists in project.

   set errMsg "Design <$design_name> already exists in your project, please set the variable <design_name> to another value."
   set nRet 2

} else {
   # USE CASES:
   #    8) No opened design, design_name not in project.
   #    9) Current opened design, has components, but diff names, design_name not in project.

   common::send_msg_id "BD_TCL-003" "INFO" "Currently there is no design <$design_name> in project, so creating one..."

   create_bd_design $design_name

   common::send_msg_id "BD_TCL-004" "INFO" "Making design <$design_name> as current_bd_design."
   current_bd_design $design_name

}

common::send_msg_id "BD_TCL-005" "INFO" "Currently the variable <design_name> is equal to \"$design_name\"."

if { $nRet != 0 } {
   catch {common::send_msg_id "BD_TCL-114" "ERROR" $errMsg}
   return $nRet
}

set bCheckIPsPassed 1
##################################################################
# CHECK IPs
##################################################################
set bCheckIPs 1
if { $bCheckIPs == 1 } {
   set list_check_ips "\ 
user.org:user:gfe_subsystem:1.0\
xilinx.com:ip:util_vector_logic:2.0\
user.org:user:p1_normal_jtag:1.0\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
"

   set list_ips_missing ""
   common::send_msg_id "BD_TCL-006" "INFO" "Checking if the following IPs exist in the project's IP catalog: $list_check_ips ."

   foreach ip_vlnv $list_check_ips {
      set ip_obj [get_ipdefs -all $ip_vlnv]
      if { $ip_obj eq "" } {
         lappend list_ips_missing $ip_vlnv
      }
   }

   if { $list_ips_missing ne "" } {
      catch {common::send_msg_id "BD_TCL-115" "ERROR" "The following IPs are not found in the IP Catalog:\n  $list_ips_missing\n\nResolution: Please add the repository containing the IP(s) to the project." }
      set bCheckIPsPassed 0
   }

}

if { $bCheckIPsPassed != 1 } {
  common::send_msg_id "BD_TCL-1003" "WARNING" "Will not continue with creation of design due to the error(s) above."
  return 3
}

##################################################################
# DESIGN PROCs
##################################################################


# Hierarchical cell: p1_chisel
proc create_hier_cell_p1_chisel { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_p1_chisel() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MEM_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:aximm_rtl:1.0 MMIO_AXI

  # Create pins
  create_bd_pin -dir I -type clk clock
  create_bd_pin -dir I -from 0 -to 0 interrupt
  create_bd_pin -dir I jtag_TCK
  create_bd_pin -dir I jtag_TDI
  create_bd_pin -dir O jtag_TDO
  create_bd_pin -dir I jtag_TMS
  create_bd_pin -dir I -type rst reset

  # Create instance: p1_normal_jtag_0, and set properties
  set p1_normal_jtag_0 [ create_bd_cell -type ip -vlnv user.org:user:p1_normal_jtag:1.0 p1_normal_jtag_0 ]
  set_property -dict [ list \
   CONFIG.C_MEM_AXI_ID_WIDTH {4} \
   CONFIG.C_MEM_AXI_TARGET_SLAVE_BASE_ADDR {0x40000000} \
   CONFIG.C_MMIO_AXI_ID_WIDTH {4} \
   CONFIG.C_MMIO_AXI_TARGET_SLAVE_BASE_ADDR {0x60000000} \
 ] $p1_normal_jtag_0

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create interface connections
  connect_bd_intf_net -intf_net p1_normal_jtag_0_MEM_AXI [get_bd_intf_pins MEM_AXI] [get_bd_intf_pins p1_normal_jtag_0/MEM_AXI]
  connect_bd_intf_net -intf_net p1_normal_jtag_0_MMIO_AXI [get_bd_intf_pins MMIO_AXI] [get_bd_intf_pins p1_normal_jtag_0/MMIO_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins p1_normal_jtag_0/mem_axi_aresetn] [get_bd_pins p1_normal_jtag_0/mmio_axi_aresetn] [get_bd_pins util_vector_logic_0/Res]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins clock] [get_bd_pins p1_normal_jtag_0/clock] [get_bd_pins p1_normal_jtag_0/mem_axi_aclk] [get_bd_pins p1_normal_jtag_0/mmio_axi_aclk]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins reset] [get_bd_pins p1_normal_jtag_0/debug_systemjtag_reset] [get_bd_pins p1_normal_jtag_0/reset] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net gfe_subsystem_0_ip2intc_irpt_0 [get_bd_pins interrupt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net jtag_TCK_1 [get_bd_pins jtag_TCK] [get_bd_pins p1_normal_jtag_0/debug_systemjtag_jtag_TCK]
  connect_bd_net -net jtag_TDI_1 [get_bd_pins jtag_TDI] [get_bd_pins p1_normal_jtag_0/debug_systemjtag_jtag_TDI]
  connect_bd_net -net jtag_TMS_1 [get_bd_pins jtag_TMS] [get_bd_pins p1_normal_jtag_0/debug_systemjtag_jtag_TMS]
  connect_bd_net -net p1_normal_jtag_0_debug_systemjtag_jtag_TDO_data [get_bd_pins jtag_TDO] [get_bd_pins p1_normal_jtag_0/debug_systemjtag_jtag_TDO_data]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins p1_normal_jtag_0/interrupts] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins p1_normal_jtag_0/mem_axi_init_axi_txn] [get_bd_pins p1_normal_jtag_0/mmio_axi_init_axi_txn] [get_bd_pins xlconcat_0/In1] [get_bd_pins xlconstant_0/dout]

  # Restore current instance
  current_bd_instance $oldCurInst
}


# Procedure to create entire design; Provide argument to make
# procedure reusable. If parentCell is "", will use root.
proc create_root_design { parentCell } {

  variable script_folder
  variable design_name

  if { $parentCell eq "" } {
     set parentCell [get_bd_cells /]
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


  # Create interface ports
  set ddr4_sdram_c1 [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_sdram_c1 ]
  set default_250mhz_clk1 [ create_bd_intf_port -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 default_250mhz_clk1 ]
  set_property -dict [ list \
   CONFIG.FREQ_HZ {250000000} \
   ] $default_250mhz_clk1
  set rs232_uart [ create_bd_intf_port -mode Master -vlnv xilinx.com:interface:uart_rtl:1.0 rs232_uart ]

  # Create ports
  set jtag_TCK [ create_bd_port -dir I jtag_TCK ]
  set jtag_TDI [ create_bd_port -dir I jtag_TDI ]
  set jtag_TDO [ create_bd_port -dir O jtag_TDO ]
  set jtag_TMS [ create_bd_port -dir I jtag_TMS ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset

  # Create instance: gfe_subsystem_0, and set properties
  set gfe_subsystem_0 [ create_bd_cell -type ip -vlnv user.org:user:gfe_subsystem:1.0 gfe_subsystem_0 ]

  # Create instance: p1_chisel
  create_hier_cell_p1_chisel [current_bd_instance .] p1_chisel

  # Create instance: util_vector_logic_0, and set properties
  set util_vector_logic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:util_vector_logic:2.0 util_vector_logic_0 ]
  set_property -dict [ list \
   CONFIG.C_OPERATION {not} \
   CONFIG.C_SIZE {1} \
   CONFIG.LOGO_FILE {data/sym_notgate.png} \
 ] $util_vector_logic_0

  # Create interface connections
  connect_bd_intf_net -intf_net default_250mhz_clk1_0_1 [get_bd_intf_ports default_250mhz_clk1] [get_bd_intf_pins gfe_subsystem_0/default_250mhz_clk1]
  connect_bd_intf_net -intf_net gfe_subsystem_0_ddr4_sdram_c1 [get_bd_intf_ports ddr4_sdram_c1] [get_bd_intf_pins gfe_subsystem_0/ddr4_sdram_c1]
  connect_bd_intf_net -intf_net gfe_subsystem_0_rs232_uart [get_bd_intf_ports rs232_uart] [get_bd_intf_pins gfe_subsystem_0/rs232_uart]
  connect_bd_intf_net -intf_net p1_chisel_MEM_AXI [get_bd_intf_pins gfe_subsystem_0/S00_AXI] [get_bd_intf_pins p1_chisel/MEM_AXI]
  connect_bd_intf_net -intf_net p1_normal_jtag_0_MMIO_AXI [get_bd_intf_pins gfe_subsystem_0/S01_AXI] [get_bd_intf_pins p1_chisel/MMIO_AXI]

  # Create port connections
  connect_bd_net -net gfe_subsystem_0_gfe_axi_aclk [get_bd_pins gfe_subsystem_0/S00_ACLK] [get_bd_pins gfe_subsystem_0/S01_ACLK] [get_bd_pins gfe_subsystem_0/gfe_axi_aclk] [get_bd_pins p1_chisel/clock]
  connect_bd_net -net gfe_subsystem_0_gfe_sync_resetn [get_bd_pins gfe_subsystem_0/S00_ARESETN] [get_bd_pins gfe_subsystem_0/S01_ARESETN] [get_bd_pins gfe_subsystem_0/gfe_sync_resetn] [get_bd_pins util_vector_logic_0/Op1]
  connect_bd_net -net gfe_subsystem_0_ip2intc_irpt_0 [get_bd_pins gfe_subsystem_0/ip2intc_irpt_0] [get_bd_pins p1_chisel/interrupt]
  connect_bd_net -net jtag_TCK_1 [get_bd_ports jtag_TCK] [get_bd_pins p1_chisel/jtag_TCK]
  connect_bd_net -net jtag_TDI_1 [get_bd_ports jtag_TDI] [get_bd_pins p1_chisel/jtag_TDI]
  connect_bd_net -net jtag_TMS_1 [get_bd_ports jtag_TMS] [get_bd_pins p1_chisel/jtag_TMS]
  connect_bd_net -net p1_normal_jtag_0_debug_systemjtag_jtag_TDO_data [get_bd_ports jtag_TDO] [get_bd_pins p1_chisel/jtag_TDO]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins gfe_subsystem_0/gfe_reset]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins p1_chisel/reset] [get_bd_pins util_vector_logic_0/Res]

  # Create address segments
  create_bd_addr_seg -range 0x80000000 -offset 0x80000000 [get_bd_addr_spaces p1_chisel/p1_normal_jtag_0/MMIO_AXI] [get_bd_addr_segs gfe_subsystem_0/S01_AXI/Mem0] SEG_gfe_subsystem_0_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x60000000 [get_bd_addr_spaces p1_chisel/p1_normal_jtag_0/MMIO_AXI] [get_bd_addr_segs gfe_subsystem_0/S01_AXI/Reg0] SEG_gfe_subsystem_0_Reg0


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""


common::send_msg_id "BD_TCL-1000" "WARNING" "This Tcl script was generated from a block design that has not been validated. It is possible that design <$design_name> may result in errors during validation."


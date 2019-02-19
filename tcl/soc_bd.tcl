
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
ssith:user:ssith_processor:1.0\
ssith:user:xilinx_jtag:1.0\
xilinx.com:ip:axi_bram_ctrl:4.0\
xilinx.com:ip:axi_clock_converter:2.1\
xilinx.com:ip:axi_gpio:2.0\
xilinx.com:ip:axi_uart16550:2.0\
xilinx.com:ip:blk_mem_gen:8.4\
xilinx.com:ip:ddr4:2.2\
xilinx.com:ip:xlconcat:2.1\
xilinx.com:ip:xlconstant:1.1\
xilinx.com:ip:axi_iic:2.0\
user.org:user:iobuf:1.0\
xilinx.com:ip:proc_sys_reset:5.0\
xilinx.com:ip:axi_quad_spi:3.2\
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


# Hierarchical cell: spi
proc create_hier_cell_spi { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_spi() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 AXI_LITE

  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir O -type intr ip2intc_irpt
  create_bd_pin -dir IO spi_miso
  create_bd_pin -dir IO spi_mosi
  create_bd_pin -dir IO spi_sck
  create_bd_pin -dir IO spi_ss

  # Create instance: axi_quad_spi_0, and set properties
  set axi_quad_spi_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_quad_spi:3.2 axi_quad_spi_0 ]

  # Create instance: iobuf_2, and set properties
  set iobuf_2 [ create_bd_cell -type ip -vlnv user.org:user:iobuf:1.0 iobuf_2 ]

  # Create instance: iobuf_3, and set properties
  set iobuf_3 [ create_bd_cell -type ip -vlnv user.org:user:iobuf:1.0 iobuf_3 ]

  # Create instance: iobuf_4, and set properties
  set iobuf_4 [ create_bd_cell -type ip -vlnv user.org:user:iobuf:1.0 iobuf_4 ]

  # Create instance: iobuf_5, and set properties
  set iobuf_5 [ create_bd_cell -type ip -vlnv user.org:user:iobuf:1.0 iobuf_5 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins AXI_LITE] [get_bd_intf_pins axi_quad_spi_0/AXI_LITE]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins axi_quad_spi_0/s_axi_aresetn]
  connect_bd_net -net Net3 [get_bd_pins spi_mosi] [get_bd_pins iobuf_2/IO]
  connect_bd_net -net Net4 [get_bd_pins spi_miso] [get_bd_pins iobuf_3/IO]
  connect_bd_net -net Net5 [get_bd_pins spi_sck] [get_bd_pins iobuf_4/IO]
  connect_bd_net -net Net6 [get_bd_pins spi_ss] [get_bd_pins iobuf_5/IO]
  connect_bd_net -net axi_quad_spi_0_io0_o [get_bd_pins axi_quad_spi_0/io0_o] [get_bd_pins iobuf_2/I]
  connect_bd_net -net axi_quad_spi_0_io0_t [get_bd_pins axi_quad_spi_0/io0_t] [get_bd_pins iobuf_2/T]
  connect_bd_net -net axi_quad_spi_0_io1_o [get_bd_pins axi_quad_spi_0/io1_o] [get_bd_pins iobuf_3/I]
  connect_bd_net -net axi_quad_spi_0_io1_t [get_bd_pins axi_quad_spi_0/io1_t] [get_bd_pins iobuf_3/T]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt [get_bd_pins ip2intc_irpt] [get_bd_pins axi_quad_spi_0/ip2intc_irpt]
  connect_bd_net -net axi_quad_spi_0_sck_o [get_bd_pins axi_quad_spi_0/sck_o] [get_bd_pins iobuf_4/I]
  connect_bd_net -net axi_quad_spi_0_sck_t [get_bd_pins axi_quad_spi_0/sck_t] [get_bd_pins iobuf_4/T]
  connect_bd_net -net axi_quad_spi_0_ss_o [get_bd_pins axi_quad_spi_0/ss_o] [get_bd_pins iobuf_5/I]
  connect_bd_net -net axi_quad_spi_0_ss_t [get_bd_pins axi_quad_spi_0/ss_t] [get_bd_pins iobuf_5/T]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins ACLK] [get_bd_pins axi_quad_spi_0/ext_spi_clk] [get_bd_pins axi_quad_spi_0/s_axi_aclk]
  connect_bd_net -net iobuf_2_O [get_bd_pins axi_quad_spi_0/io0_i] [get_bd_pins iobuf_2/O]
  connect_bd_net -net iobuf_3_O [get_bd_pins axi_quad_spi_0/io1_i] [get_bd_pins iobuf_3/O]
  connect_bd_net -net iobuf_4_O [get_bd_pins axi_quad_spi_0/sck_i] [get_bd_pins iobuf_4/O]
  connect_bd_net -net iobuf_5_O [get_bd_pins axi_quad_spi_0/ss_i] [get_bd_pins iobuf_5/O]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: reset_system
proc create_hier_cell_reset_system { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_reset_system() - Empty argument(s)!"}
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

  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir O -from 0 -to 0 -type rst ARESETN
  create_bd_pin -dir I dcm_locked
  create_bd_pin -dir O -from 0 -to 0 -type rst interconnect_aresetn
  create_bd_pin -dir I -type rst mb_debug_sys_rst
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir I -type clk slowest_sync_clk

  # Create instance: proc_sys_reset_0, and set properties
  set proc_sys_reset_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_0 ]

  # Create instance: proc_sys_reset_1, and set properties
  set proc_sys_reset_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:proc_sys_reset:5.0 proc_sys_reset_1 ]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins proc_sys_reset_0/peripheral_aresetn]
  connect_bd_net -net Net [get_bd_pins interconnect_aresetn] [get_bd_pins proc_sys_reset_1/interconnect_aresetn]
  connect_bd_net -net S00_ACLK_1 [get_bd_pins slowest_sync_clk] [get_bd_pins proc_sys_reset_1/slowest_sync_clk]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins ACLK] [get_bd_pins proc_sys_reset_0/slowest_sync_clk]
  connect_bd_net -net proc_sys_reset_0_peripheral_reset [get_bd_pins proc_sys_reset_0/mb_reset] [get_bd_pins proc_sys_reset_1/aux_reset_in] [get_bd_pins proc_sys_reset_1/ext_reset_in]
  connect_bd_net -net reset_1 [get_bd_pins reset] [get_bd_pins proc_sys_reset_0/aux_reset_in] [get_bd_pins proc_sys_reset_0/ext_reset_in]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins mb_debug_sys_rst] [get_bd_pins proc_sys_reset_0/mb_debug_sys_rst] [get_bd_pins proc_sys_reset_1/mb_debug_sys_rst]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins dcm_locked] [get_bd_pins proc_sys_reset_0/dcm_locked] [get_bd_pins proc_sys_reset_1/dcm_locked]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: i2c
proc create_hier_cell_i2c { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_i2c() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S_AXI

  # Create pins
  create_bd_pin -dir I -type clk ACLK
  create_bd_pin -dir I -type rst ARESETN
  create_bd_pin -dir O -type intr iic2intc_irpt
  create_bd_pin -dir IO iic_scl
  create_bd_pin -dir IO iic_sda

  # Create instance: axi_iic_0, and set properties
  set axi_iic_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_iic:2.0 axi_iic_0 ]

  # Create instance: iobuf_0, and set properties
  set iobuf_0 [ create_bd_cell -type ip -vlnv user.org:user:iobuf:1.0 iobuf_0 ]

  # Create instance: iobuf_1, and set properties
  set iobuf_1 [ create_bd_cell -type ip -vlnv user.org:user:iobuf:1.0 iobuf_1 ]

  # Create interface connections
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins S_AXI] [get_bd_intf_pins axi_iic_0/S_AXI]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins axi_iic_0/s_axi_aresetn]
  connect_bd_net -net Net1 [get_bd_pins iic_scl] [get_bd_pins iobuf_0/IO]
  connect_bd_net -net Net2 [get_bd_pins iic_sda] [get_bd_pins iobuf_1/IO]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins iic2intc_irpt] [get_bd_pins axi_iic_0/iic2intc_irpt]
  connect_bd_net -net axi_iic_0_scl_o [get_bd_pins axi_iic_0/scl_o] [get_bd_pins iobuf_0/I]
  connect_bd_net -net axi_iic_0_scl_t [get_bd_pins axi_iic_0/scl_t] [get_bd_pins iobuf_0/T]
  connect_bd_net -net axi_iic_0_sda_o [get_bd_pins axi_iic_0/sda_o] [get_bd_pins iobuf_1/I]
  connect_bd_net -net axi_iic_0_sda_t [get_bd_pins axi_iic_0/sda_t] [get_bd_pins iobuf_1/T]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins ACLK] [get_bd_pins axi_iic_0/s_axi_aclk]
  connect_bd_net -net iobuf_0_O [get_bd_pins axi_iic_0/scl_i] [get_bd_pins iobuf_0/O]
  connect_bd_net -net iobuf_1_O [get_bd_pins axi_iic_0/sda_i] [get_bd_pins iobuf_1/O]

  # Restore current instance
  current_bd_instance $oldCurInst
}

# Hierarchical cell: gfe_subsystem
proc create_hier_cell_gfe_subsystem { parentCell nameHier } {

  variable script_folder

  if { $parentCell eq "" || $nameHier eq "" } {
     catch {common::send_msg_id "BD_TCL-102" "ERROR" "create_hier_cell_gfe_subsystem() - Empty argument(s)!"}
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
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S00_AXI
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:aximm_rtl:1.0 S01_AXI
  create_bd_intf_pin -mode Master -vlnv xilinx.com:interface:ddr4_rtl:1.0 ddr4_sdram_c1
  create_bd_intf_pin -mode Slave -vlnv xilinx.com:interface:diff_clock_rtl:1.0 default_250mhz_clk1

  # Create pins
  create_bd_pin -dir O -type clk ACLK
  create_bd_pin -dir O -from 0 -to 0 -type rst ARESETN
  create_bd_pin -dir O -type rst c0_ddr4_ui_clk_sync_rst
  create_bd_pin -dir O -from 7 -to 0 gpio_led
  create_bd_pin -dir O -from 1 -to 0 gpio_out
  create_bd_pin -dir IO iic_scl
  create_bd_pin -dir IO iic_sda
  create_bd_pin -dir O -from 15 -to 0 interrupts
  create_bd_pin -dir I -type rst reset
  create_bd_pin -dir I rs232_uart_cts
  create_bd_pin -dir O rs232_uart_rts
  create_bd_pin -dir I rs232_uart_rxd
  create_bd_pin -dir O rs232_uart_txd
  create_bd_pin -dir IO spi_miso
  create_bd_pin -dir IO spi_mosi
  create_bd_pin -dir IO spi_sck
  create_bd_pin -dir IO spi_ss
  create_bd_pin -dir I uart1_rx
  create_bd_pin -dir O uart1_txd

  # Create instance: axi_bram_ctrl_0, and set properties
  set axi_bram_ctrl_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_bram_ctrl:4.0 axi_bram_ctrl_0 ]
  set_property -dict [ list \
   CONFIG.SINGLE_PORT_BRAM {1} \
 ] $axi_bram_ctrl_0

  # Create instance: axi_clock_converter_0, and set properties
  set axi_clock_converter_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_clock_converter:2.1 axi_clock_converter_0 ]
  set_property USER_COMMENTS.comment_0 "This CDC forces an asynchronous CDC between
the interconnect and DDR. Depending on the design, the
interconnect would not place an asynchronous CDC
here on its own." [get_bd_cells /gfe_subsystem/axi_clock_converter_0]
  set_property -dict [ list \
   CONFIG.ACLK_ASYNC {1} \
 ] $axi_clock_converter_0

  # Create instance: axi_gpio_0, and set properties
  set axi_gpio_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_gpio:2.0 axi_gpio_0 ]
  set_property -dict [ list \
   CONFIG.C_ALL_OUTPUTS {1} \
   CONFIG.C_ALL_OUTPUTS_2 {1} \
   CONFIG.C_GPIO2_WIDTH {8} \
   CONFIG.C_GPIO_WIDTH {2} \
   CONFIG.C_IS_DUAL {1} \
   CONFIG.GPIO2_BOARD_INTERFACE {led_8bits} \
   CONFIG.GPIO_BOARD_INTERFACE {Custom} \
 ] $axi_gpio_0

  # Create instance: axi_interconnect_0, and set properties
  set axi_interconnect_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_interconnect:2.1 axi_interconnect_0 ]
  set_property -dict [ list \
   CONFIG.ENABLE_ADVANCED_OPTIONS {1} \
   CONFIG.M00_HAS_REGSLICE {4} \
   CONFIG.M01_HAS_REGSLICE {4} \
   CONFIG.M02_HAS_REGSLICE {4} \
   CONFIG.M03_HAS_REGSLICE {4} \
   CONFIG.M04_HAS_REGSLICE {4} \
   CONFIG.M05_HAS_REGSLICE {4} \
   CONFIG.M06_HAS_REGSLICE {4} \
   CONFIG.NUM_MI {7} \
   CONFIG.NUM_SI {2} \
   CONFIG.S00_HAS_REGSLICE {4} \
   CONFIG.S01_HAS_REGSLICE {4} \
 ] $axi_interconnect_0

  # Create instance: axi_uart16550_0, and set properties
  set axi_uart16550_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_0 ]

  # Create instance: axi_uart16550_1, and set properties
  set axi_uart16550_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:axi_uart16550:2.0 axi_uart16550_1 ]

  # Create instance: blk_mem_gen_0, and set properties
  set blk_mem_gen_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:blk_mem_gen:8.4 blk_mem_gen_0 ]
  set_property -dict [ list \
   CONFIG.Coe_File {../../../../../../../../bootrom/bootrom.coe} \
   CONFIG.Load_Init_File {true} \
   CONFIG.Memory_Type {Single_Port_ROM} \
   CONFIG.Port_A_Write_Rate {0} \
   CONFIG.Use_Byte_Write_Enable {false} \
 ] $blk_mem_gen_0

  # Create instance: ddr4_0, and set properties
  set ddr4_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:ddr4:2.2 ddr4_0 ]
  set_property -dict [ list \
   CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ {83} \
   CONFIG.C0_CLOCK_BOARD_INTERFACE {default_250mhz_clk1} \
   CONFIG.C0_DDR4_BOARD_INTERFACE {ddr4_sdram_c1} \
   CONFIG.RESET_BOARD_INTERFACE {reset} \
 ] $ddr4_0

  # Create instance: i2c
  create_hier_cell_i2c $hier_obj i2c

  # Create instance: reset_system
  create_hier_cell_reset_system $hier_obj reset_system

  # Create instance: spi
  create_hier_cell_spi $hier_obj spi

  # Create instance: xlconcat_0, and set properties
  set xlconcat_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconcat:2.1 xlconcat_0 ]
  set_property -dict [ list \
   CONFIG.NUM_PORTS {5} \
 ] $xlconcat_0

  # Create instance: xlconstant_0, and set properties
  set xlconstant_0 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_0 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
 ] $xlconstant_0

  # Create instance: xlconstant_1, and set properties
  set xlconstant_1 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_1 ]

  # Create instance: xlconstant_2, and set properties
  set xlconstant_2 [ create_bd_cell -type ip -vlnv xilinx.com:ip:xlconstant:1.1 xlconstant_2 ]
  set_property -dict [ list \
   CONFIG.CONST_VAL {0} \
   CONFIG.CONST_WIDTH {12} \
 ] $xlconstant_2

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins S00_AXI] [get_bd_intf_pins axi_interconnect_0/S00_AXI]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins S01_AXI] [get_bd_intf_pins axi_interconnect_0/S01_AXI]
  connect_bd_intf_net -intf_net axi_bram_ctrl_0_BRAM_PORTA [get_bd_intf_pins axi_bram_ctrl_0/BRAM_PORTA] [get_bd_intf_pins blk_mem_gen_0/BRAM_PORTA]
  connect_bd_intf_net -intf_net axi_clock_converter_0_M_AXI [get_bd_intf_pins axi_clock_converter_0/M_AXI] [get_bd_intf_pins ddr4_0/C0_DDR4_S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M00_AXI [get_bd_intf_pins axi_clock_converter_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M00_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M01_AXI [get_bd_intf_pins axi_interconnect_0/M01_AXI] [get_bd_intf_pins axi_uart16550_0/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M02_AXI [get_bd_intf_pins axi_bram_ctrl_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M02_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M03_AXI [get_bd_intf_pins axi_interconnect_0/M03_AXI] [get_bd_intf_pins i2c/S_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M04_AXI [get_bd_intf_pins axi_interconnect_0/M04_AXI] [get_bd_intf_pins spi/AXI_LITE]
  connect_bd_intf_net -intf_net axi_interconnect_0_M05_AXI [get_bd_intf_pins axi_gpio_0/S_AXI] [get_bd_intf_pins axi_interconnect_0/M05_AXI]
  connect_bd_intf_net -intf_net axi_interconnect_0_M06_AXI [get_bd_intf_pins axi_interconnect_0/M06_AXI] [get_bd_intf_pins axi_uart16550_1/S_AXI]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_pins ddr4_sdram_c1] [get_bd_intf_pins ddr4_0/C0_DDR4]
  connect_bd_intf_net -intf_net default_250mhz_clk1_1 [get_bd_intf_pins default_250mhz_clk1] [get_bd_intf_pins ddr4_0/C0_SYS_CLK]

  # Create port connections
  connect_bd_net -net ARESETN_1 [get_bd_pins ARESETN] [get_bd_pins axi_bram_ctrl_0/s_axi_aresetn] [get_bd_pins axi_clock_converter_0/s_axi_aresetn] [get_bd_pins axi_gpio_0/s_axi_aresetn] [get_bd_pins axi_interconnect_0/ARESETN] [get_bd_pins axi_interconnect_0/M00_ARESETN] [get_bd_pins axi_interconnect_0/M01_ARESETN] [get_bd_pins axi_interconnect_0/M02_ARESETN] [get_bd_pins axi_interconnect_0/M03_ARESETN] [get_bd_pins axi_interconnect_0/M04_ARESETN] [get_bd_pins axi_interconnect_0/M05_ARESETN] [get_bd_pins axi_interconnect_0/M06_ARESETN] [get_bd_pins axi_interconnect_0/S00_ARESETN] [get_bd_pins axi_interconnect_0/S01_ARESETN] [get_bd_pins axi_uart16550_0/s_axi_aresetn] [get_bd_pins axi_uart16550_1/s_axi_aresetn] [get_bd_pins i2c/ARESETN] [get_bd_pins reset_system/ARESETN] [get_bd_pins spi/ARESETN]
  connect_bd_net -net Net [get_bd_pins axi_clock_converter_0/m_axi_aresetn] [get_bd_pins ddr4_0/c0_ddr4_aresetn] [get_bd_pins reset_system/interconnect_aresetn]
  connect_bd_net -net Net1 [get_bd_pins iic_scl] [get_bd_pins i2c/iic_scl]
  connect_bd_net -net Net2 [get_bd_pins iic_sda] [get_bd_pins i2c/iic_sda]
  connect_bd_net -net Net3 [get_bd_pins spi_mosi] [get_bd_pins spi/spi_mosi]
  connect_bd_net -net Net4 [get_bd_pins spi_miso] [get_bd_pins spi/spi_miso]
  connect_bd_net -net Net5 [get_bd_pins spi_sck] [get_bd_pins spi/spi_sck]
  connect_bd_net -net Net6 [get_bd_pins spi_ss] [get_bd_pins spi/spi_ss]
  connect_bd_net -net S00_ACLK_1 [get_bd_pins axi_clock_converter_0/m_axi_aclk] [get_bd_pins ddr4_0/c0_ddr4_ui_clk] [get_bd_pins reset_system/slowest_sync_clk]
  connect_bd_net -net axi_gpio_0_gpio2_io_o [get_bd_pins gpio_led] [get_bd_pins axi_gpio_0/gpio2_io_o]
  connect_bd_net -net axi_gpio_0_gpio_io_o [get_bd_pins gpio_out] [get_bd_pins axi_gpio_0/gpio_io_o]
  connect_bd_net -net axi_iic_0_iic2intc_irpt [get_bd_pins i2c/iic2intc_irpt] [get_bd_pins xlconcat_0/In2]
  connect_bd_net -net axi_quad_spi_0_ip2intc_irpt [get_bd_pins spi/ip2intc_irpt] [get_bd_pins xlconcat_0/In3]
  connect_bd_net -net axi_uart16550_0_ip2intc_irpt [get_bd_pins axi_uart16550_0/ip2intc_irpt] [get_bd_pins xlconcat_0/In0]
  connect_bd_net -net axi_uart16550_0_rtsn [get_bd_pins rs232_uart_rts] [get_bd_pins axi_uart16550_0/rtsn]
  connect_bd_net -net axi_uart16550_0_sout [get_bd_pins rs232_uart_txd] [get_bd_pins axi_uart16550_0/sout]
  connect_bd_net -net axi_uart16550_1_ip2intc_irpt [get_bd_pins axi_uart16550_1/ip2intc_irpt] [get_bd_pins xlconcat_0/In1]
  connect_bd_net -net axi_uart16550_1_sout [get_bd_pins uart1_txd] [get_bd_pins axi_uart16550_1/sout]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins ACLK] [get_bd_pins axi_bram_ctrl_0/s_axi_aclk] [get_bd_pins axi_clock_converter_0/s_axi_aclk] [get_bd_pins axi_gpio_0/s_axi_aclk] [get_bd_pins axi_interconnect_0/ACLK] [get_bd_pins axi_interconnect_0/M00_ACLK] [get_bd_pins axi_interconnect_0/M01_ACLK] [get_bd_pins axi_interconnect_0/M02_ACLK] [get_bd_pins axi_interconnect_0/M03_ACLK] [get_bd_pins axi_interconnect_0/M04_ACLK] [get_bd_pins axi_interconnect_0/M05_ACLK] [get_bd_pins axi_interconnect_0/M06_ACLK] [get_bd_pins axi_interconnect_0/S00_ACLK] [get_bd_pins axi_interconnect_0/S01_ACLK] [get_bd_pins axi_uart16550_0/s_axi_aclk] [get_bd_pins axi_uart16550_1/s_axi_aclk] [get_bd_pins ddr4_0/addn_ui_clkout1] [get_bd_pins i2c/ACLK] [get_bd_pins reset_system/ACLK] [get_bd_pins spi/ACLK]
  connect_bd_net -net ddr4_0_c0_ddr4_ui_clk_sync_rst [get_bd_pins c0_ddr4_ui_clk_sync_rst] [get_bd_pins ddr4_0/c0_ddr4_ui_clk_sync_rst]
  connect_bd_net -net reset_1 [get_bd_pins reset] [get_bd_pins ddr4_0/sys_rst] [get_bd_pins reset_system/reset]
  connect_bd_net -net rs232_uart_cts_1 [get_bd_pins rs232_uart_cts] [get_bd_pins axi_uart16550_0/ctsn]
  connect_bd_net -net rs232_uart_rxd_1 [get_bd_pins rs232_uart_rxd] [get_bd_pins axi_uart16550_0/sin]
  connect_bd_net -net uart1_rx_1 [get_bd_pins uart1_rx] [get_bd_pins axi_uart16550_1/sin]
  connect_bd_net -net xlconcat_0_dout [get_bd_pins interrupts] [get_bd_pins xlconcat_0/dout]
  connect_bd_net -net xlconstant_0_dout [get_bd_pins axi_uart16550_0/freeze] [get_bd_pins reset_system/mb_debug_sys_rst] [get_bd_pins xlconstant_0/dout]
  connect_bd_net -net xlconstant_1_dout [get_bd_pins reset_system/dcm_locked] [get_bd_pins xlconstant_1/dout]
  connect_bd_net -net xlconstant_2_dout [get_bd_pins xlconcat_0/In4] [get_bd_pins xlconstant_2/dout]

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

  # Create ports
  set gpio_led [ create_bd_port -dir O -from 7 -to 0 gpio_led ]
  set gpio_out [ create_bd_port -dir O -from 1 -to 0 gpio_out ]
  set iic_scl [ create_bd_port -dir IO iic_scl ]
  set iic_sda [ create_bd_port -dir IO iic_sda ]
  set reset [ create_bd_port -dir I -type rst reset ]
  set_property -dict [ list \
   CONFIG.POLARITY {ACTIVE_HIGH} \
 ] $reset
  set rs232_uart_cts [ create_bd_port -dir I rs232_uart_cts ]
  set rs232_uart_rts [ create_bd_port -dir O rs232_uart_rts ]
  set rs232_uart_rxd [ create_bd_port -dir I rs232_uart_rxd ]
  set rs232_uart_txd [ create_bd_port -dir O rs232_uart_txd ]
  set spi_miso [ create_bd_port -dir IO spi_miso ]
  set spi_mosi [ create_bd_port -dir IO spi_mosi ]
  set spi_sck [ create_bd_port -dir IO spi_sck ]
  set spi_ss [ create_bd_port -dir IO spi_ss ]
  set uart1_rx [ create_bd_port -dir I uart1_rx ]
  set uart1_tx [ create_bd_port -dir O uart1_tx ]

  # Create instance: gfe_subsystem
  create_hier_cell_gfe_subsystem [current_bd_instance .] gfe_subsystem

  # Create instance: ssith_processor_0, and set properties
  set ssith_processor_0 [ create_bd_cell -type ip -vlnv ssith:user:ssith_processor:1.0 ssith_processor_0 ]

  # Create instance: xilinx_jtag_0, and set properties
  set xilinx_jtag_0 [ create_bd_cell -type ip -vlnv ssith:user:xilinx_jtag:1.0 xilinx_jtag_0 ]

  # Create interface connections
  connect_bd_intf_net -intf_net S00_AXI_1 [get_bd_intf_pins gfe_subsystem/S00_AXI] [get_bd_intf_pins ssith_processor_0/master0]
  connect_bd_intf_net -intf_net S01_AXI_1 [get_bd_intf_pins gfe_subsystem/S01_AXI] [get_bd_intf_pins ssith_processor_0/master1]
  connect_bd_intf_net -intf_net ddr4_0_C0_DDR4 [get_bd_intf_ports ddr4_sdram_c1] [get_bd_intf_pins gfe_subsystem/ddr4_sdram_c1]
  connect_bd_intf_net -intf_net default_250mhz_clk1_1 [get_bd_intf_ports default_250mhz_clk1] [get_bd_intf_pins gfe_subsystem/default_250mhz_clk1]

  # Create port connections
  connect_bd_net -net Net [get_bd_ports iic_scl] [get_bd_pins gfe_subsystem/iic_scl]
  connect_bd_net -net Net1 [get_bd_ports iic_sda] [get_bd_pins gfe_subsystem/iic_sda]
  connect_bd_net -net Net2 [get_bd_ports spi_mosi] [get_bd_pins gfe_subsystem/spi_mosi]
  connect_bd_net -net Net3 [get_bd_ports spi_miso] [get_bd_pins gfe_subsystem/spi_miso]
  connect_bd_net -net Net4 [get_bd_ports spi_sck] [get_bd_pins gfe_subsystem/spi_sck]
  connect_bd_net -net Net5 [get_bd_ports spi_ss] [get_bd_pins gfe_subsystem/spi_ss]
  connect_bd_net -net ddr4_0_addn_ui_clkout1 [get_bd_pins gfe_subsystem/ACLK] [get_bd_pins ssith_processor_0/CLK] [get_bd_pins xilinx_jtag_0/clk]
  connect_bd_net -net gfe_subsystem_dout [get_bd_pins gfe_subsystem/interrupts] [get_bd_pins ssith_processor_0/cpu_external_interrupt_req]
  connect_bd_net -net gfe_subsystem_gpio_led [get_bd_ports gpio_led] [get_bd_pins gfe_subsystem/gpio_led]
  connect_bd_net -net gfe_subsystem_gpio_out [get_bd_ports gpio_out] [get_bd_pins gfe_subsystem/gpio_out]
  connect_bd_net -net gfe_subsystem_rs232_uart_rts [get_bd_ports rs232_uart_rts] [get_bd_pins gfe_subsystem/rs232_uart_rts]
  connect_bd_net -net gfe_subsystem_rs232_uart_txd [get_bd_ports rs232_uart_txd] [get_bd_pins gfe_subsystem/rs232_uart_txd]
  connect_bd_net -net gfe_subsystem_uart1_txd [get_bd_ports uart1_tx] [get_bd_pins gfe_subsystem/uart1_txd]
  connect_bd_net -net reset_1 [get_bd_ports reset] [get_bd_pins gfe_subsystem/reset]
  connect_bd_net -net rs232_uart_cts_1 [get_bd_ports rs232_uart_cts] [get_bd_pins gfe_subsystem/rs232_uart_cts]
  connect_bd_net -net rs232_uart_rxd_1 [get_bd_ports rs232_uart_rxd] [get_bd_pins gfe_subsystem/rs232_uart_rxd]
  connect_bd_net -net ssith_processor_0_jtag_tdo [get_bd_pins ssith_processor_0/jtag_tdo] [get_bd_pins xilinx_jtag_0/tdo]
  connect_bd_net -net uart1_rx_1 [get_bd_ports uart1_rx] [get_bd_pins gfe_subsystem/uart1_rx]
  connect_bd_net -net util_vector_logic_0_Res [get_bd_pins gfe_subsystem/ARESETN] [get_bd_pins ssith_processor_0/RST_N] [get_bd_pins xilinx_jtag_0/rst_n]
  connect_bd_net -net xilinx_jtag_0_tck [get_bd_pins ssith_processor_0/jtag_tclk] [get_bd_pins xilinx_jtag_0/tck]
  connect_bd_net -net xilinx_jtag_0_tdi [get_bd_pins ssith_processor_0/jtag_tdi] [get_bd_pins xilinx_jtag_0/tdi]
  connect_bd_net -net xilinx_jtag_0_tms [get_bd_pins ssith_processor_0/jtag_tms] [get_bd_pins xilinx_jtag_0/tms]

  # Create address segments
  create_bd_addr_seg -range 0x00001000 -offset 0x70000000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x70000000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/axi_bram_ctrl_0/S_AXI/Mem0] SEG_axi_bram_ctrl_0_Mem0
  create_bd_addr_seg -range 0x00001000 -offset 0x62330000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00010000 -offset 0x62330000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/axi_gpio_0/S_AXI/Reg] SEG_axi_gpio_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62310000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/i2c/axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62310000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/i2c/axi_iic_0/S_AXI/Reg] SEG_axi_iic_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62320000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/spi/axi_quad_spi_0/AXI_LITE/Reg] SEG_axi_quad_spi_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62320000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/spi/axi_quad_spi_0/AXI_LITE/Reg] SEG_axi_quad_spi_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62300000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/axi_uart16550_0/S_AXI/Reg] SEG_axi_uart16550_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62300000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/axi_uart16550_0/S_AXI/Reg] SEG_axi_uart16550_0_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62340000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/axi_uart16550_1/S_AXI/Reg] SEG_axi_uart16550_1_Reg
  create_bd_addr_seg -range 0x00001000 -offset 0x62340000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/axi_uart16550_1/S_AXI/Reg] SEG_axi_uart16550_1_Reg
  create_bd_addr_seg -range 0x40000000 -offset 0x80000000 [get_bd_addr_spaces ssith_processor_0/master0] [get_bd_addr_segs gfe_subsystem/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK
  create_bd_addr_seg -range 0x40000000 -offset 0x80000000 [get_bd_addr_spaces ssith_processor_0/master1] [get_bd_addr_segs gfe_subsystem/ddr4_0/C0_DDR4_MEMORY_MAP/C0_DDR4_ADDRESS_BLOCK] SEG_ddr4_0_C0_DDR4_ADDRESS_BLOCK


  # Restore current instance
  current_bd_instance $oldCurInst

  save_bd_design
}
# End of create_root_design()


##################################################################
# MAIN FLOW
##################################################################

create_root_design ""



#*****************************************************************************************
# Vivado (TM) v2017.4 (64-bit)
#
# project.tcl: Tcl script for re-creating project 'soc'
#
# Generated by Vivado on Thu Dec 20 15:33:58 PST 2018
# IP Build 2085800 on Fri Dec 15 22:25:07 MST 2017
#
# This file contains the Vivado Tcl commands for re-creating the project to the state*
# when this script was generated. In order to re-create the project, please source this
# file in the Vivado Tcl Shell.
#
# * Note that the runs in the created project will be configured the same way as the
#   original project, however they will not be launched automatically. To regenerate the
#   run results please launch the synthesis/implementation runs as needed.
#
#*****************************************************************************************

# Set the reference directory for source file relative paths (by default the value is script directory path)
set origin_dir "."

# Use origin directory path location variable, if specified in the tcl shell
if { [info exists ::origin_dir_loc] } {
  set origin_dir $::origin_dir_loc
}

# Set the project name
set project_name ""
set proc_name ""
set proc_path ""
# Set default clock frequency (MHz) for the GFE subsystem and processor
set clock_freq_mhz 83

variable script_file
set script_file "soc.tcl"

# Help information for this script
proc help {} {
  variable script_file
  puts "\nDescription:"
  puts "Recreate a Vivado project from this script. The created project will be"
  puts "functionally equivalent to the original project for which this script was"
  puts "generated. The script contains commands for creating a project, filesets,"
  puts "runs, adding/importing sources and setting properties on various objects.\n"
  puts "Syntax:"
  puts "$script_file"
  puts "$script_file -tclargs \[--origin_dir <path>\]"
  puts "$script_file -tclargs \[--project_name <name>\]"
  puts "$script_file -tclargs \[--proc_name <name>\]"
  puts "$script_file -tclargs \[--proc_path <path>\]"
  puts "$script_file -tclargs \[--clock_freq_mhz <freq>\]"
  puts "$script_file -tclargs \[--help\]\n"
  puts "Usage:"
  puts "Name                   Description"
  puts "-------------------------------------------------------------------------"
  puts "\[--origin_dir <path>\]  Determine source file paths wrt this path. Default"
  puts "                       origin_dir path value is \".\", otherwise, the value"
  puts "                       that was set with the \"-paths_relative_to\" switch"
  puts "                       when this script was generated.\n"
  puts "\[--project_name <name>\] Create project with the specified name. Default"
  puts "                       name is the name of the project from where this"
  puts "                       script was generated.\n"
  puts "\[--proc_name <name>\] Identifier for the processor, used in naming files"
  puts "                     specific to this IP."
  puts "\[--proc_path <path>\] Path to the IP directory containing the processor."
  puts "                     This path is relative to origin_dir, and the directory."
  puts "                     should contain the component.xml.\n"
  puts "\[--clock_freq_mhz <freq>\] Set the clock frequency (in MHz) used for "
  puts "                             the processor and gfe gfe_subsystem"
  puts "\[--help\]               Print help information for this script"
  puts "-------------------------------------------------------------------------\n"
  exit 0
}

if { $::argc > 0 } {
  for {set i 0} {$i < [llength $::argv]} {incr i} {
    set option [string trim [lindex $::argv $i]]
    switch -regexp -- $option {
      "--origin_dir"   { incr i; set origin_dir [lindex $::argv $i] }
      "--project_name" { incr i; set project_name [lindex $::argv $i] }
      "--proc_name" { incr i; set proc_name [lindex $::argv $i] }
      "--proc_path" { incr i; set proc_path [lindex $::argv $i] }
      "--clock_freq_mhz" { incr i; set clock_freq_mhz [lindex $::argv $i] }
      "--no_xdma" { incr i; set no_xdma [lindex $::argv $i] }
      "--help"         { help }
      default {
        if { [regexp {^-} $option] } {
          puts "ERROR: Unknown option '$option' specified, please type '$script_file -tclargs --help' for usage info.\n"
          return 1
        }
      }
    }
  }
}

puts "proc_name: $proc_name, proc_path: $proc_path"

# Set proc_name if not specified
# default to bluespec
if { [string equal $proc_name ""] } {
  set proc_name "bluespec_p1"
}

# Set the proc_path if not specified
source $origin_dir/proc_mapping.tcl
puts "$proc_mapping"

if { [string equal $proc_path ""] } {
  if {[dict exists $proc_mapping $proc_name]} {
    set proc_path [dict get $proc_mapping $proc_name]
  } else {
    puts "Please define proc_path mapping for $proc_name current mapping is:"
    dict for {name saved_path} $proc_mapping {
      puts "$name -> $saved_path"
    }
    exit 1
  }
}

# Set the project name if not specified
if { [string equal $project_name ""] } {
  set project_name "soc_$proc_name"
}

puts "proc_name: $proc_name, proc_path: $proc_path, project_name: $project_name"

# Create project
create_project ${project_name} ./${project_name} -part xcvu9p-flga2104-2L-e

# Set the directory path for the new project
set proj_dir [get_property directory [current_project]]

# Reconstruct message rules
set_msg_config  -ruleid {7}  -id {[BD 41-1306]}  -suppress  -source 2
set_msg_config  -ruleid {8}  -id {[BD 41-1271]}  -suppress  -source 2


# Set project properties
set obj [current_project]
set_property -name "board_part" -value "xilinx.com:vcu118:part0:2.3" -objects $obj
set_property -name "default_lib" -value "xil_defaultlib" -objects $obj
set_property -name "dsa.num_compute_units" -value "60" -objects $obj
set_property -name "ip_cache_permissions" -value "read write" -objects $obj
set_property -name "ip_output_repo" -value "$proj_dir/${project_name}.cache/ip" -objects $obj
set_property -name "sim.ip.auto_export_scripts" -value "1" -objects $obj
set_property -name "simulator_language" -value "Mixed" -objects $obj
set_property -name "source_mgmt_mode" -value "DisplayOnly" -objects $obj
set_property -name "xpm_libraries" -value "XPM_CDC XPM_MEMORY" -objects $obj

# Create 'sources_1' fileset (if not found)
if {[string equal [get_filesets -quiet sources_1] ""]} {
  create_fileset -srcset sources_1
}

# Set IP repository paths
set obj [get_filesets sources_1]
set_property "ip_repo_paths" [list \
 "[file normalize "$proc_path"]" \
 "[file normalize "../jtag"]" \
 "[file normalize "../iobuf"]" \
 "[file normalize "../param_iobuf"]" \
 "[file normalize "../svf"]" \
 "[file normalize "../gte4"]" \
 ] $obj

# Generate block diagram
source $origin_dir/soc_bd.tcl

if {$no_xdma == 1} {
    puts "Building with svf instead of xdma"
    source $origin_dir/svf.tcl
}

# Configure the clock frequency
puts "Setting clock fequency to $clock_freq_mhz MHz"
set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ $clock_freq_mhz] [get_bd_cells gfe_subsystem/ddr4_0]
save_bd_design

# Rebuild user ip_repo's index before adding any source files
update_ip_catalog -rebuild

# Set 'sources_1' fileset properties and the top level module
set obj [get_filesets sources_1]
set_property -name "top" -value "design_1" -objects $obj

# Create 'constrs_1' fileset (if not found)
if {[string equal [get_filesets -quiet constrs_1] ""]} {
  create_fileset -constrset constrs_1
}

# Set 'constrs_1' fileset object
set obj [get_filesets constrs_1]

# Add/Import constrs file and set constrs file properties
# Add shared constraint files
add_files -fileset constrs_1 [ glob $origin_dir/../xdc/vcu118_soc.xdc ]
# Add any processor specific constraint files
add_files -fileset constrs_1 [ glob $origin_dir/../xdc/vcu118_soc_${proc_name}.xdc ]

# Set 'constrs_1' fileset properties
set obj [get_filesets constrs_1]

# Create 'sim_1' fileset (if not found)
if {[string equal [get_filesets -quiet sim_1] ""]} {
  create_fileset -simset sim_1
}

# Set 'sim_1' fileset properties
set obj [get_filesets sim_1]
set_property -name "top" -value "design_1" -objects $obj
set_property -name "verilog_define" -value "RANDOMIZE_GARBAGE_ASSIGN RANDOMIZE_INVALID_ASSIGN RANDOMIZE_REG_INIT RANDOMIZE_MEM_INIT RANDOMIZE_DELAY=0" -objects $obj

# Create 'synth_1' run (if not found)
if {[string equal [get_runs -quiet synth_1] ""]} {
    create_run -name synth_1 -part xcvu9p-flga2104-2L-e -flow {Vivado Synthesis 2017} -strategy {Vivado Synthesis Defaults} -report_strategy {No Reports} -constrset constrs_1
} else {
  set_property strategy {Vivado Synthesis Defaults} [get_runs synth_1]
  set_property flow "Vivado Synthesis 2017" [get_runs synth_1]
}

# set the current synth run
current_run -synthesis [get_runs synth_1]

# Create 'impl_1' run (if not found)
if {[string equal [get_runs -quiet impl_1] ""]} {
    create_run -name impl_1 -part xcvu9p-flga2104-2L-e -flow {Vivado Implementation 2017} -strategy {Vivado Implementation Defaults} -report_strategy {No Reports} -constrset constrs_1 -parent_run synth_1
} else {
  set_property strategy {Vivado Implementation Defaults} [get_runs impl_1]
  set_property flow "Vivado Implementation 2017" [get_runs impl_1]
}

# Special case: more aggressive strategy for bluespec_p2
if { [string equal $proc_name "bluespec_p2"] } {
#    set_property strategy {Flow_PerfOptimized_high} [get_runs synth_1]
#    set_property flow "Vivado Synthesis 2019" [get_runs synth_1]

    set_property strategy {Performance_ExplorePostRoutePhysOpt} [get_runs impl_1]
    set_property flow "Vivado Implementation 2019" [get_runs impl_1]
}

set obj [get_runs impl_1]
set_property -name "steps.write_bitstream.args.readback_file" -value "0" -objects $obj
set_property -name "steps.write_bitstream.args.verbose" -value "0" -objects $obj

# set the current impl run
current_run -implementation [get_runs impl_1]

puts "INFO: Project created:$project_name"

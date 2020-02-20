
proc after_project {} {

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

    # Configure the clock frequency
    puts "Setting clock fequency to $clock_freq_mhz MHz"
    set_property -dict [list CONFIG.ADDN_UI_CLKOUT1_FREQ_HZ $clock_freq_mhz] [get_bd_cells gfe_subsystem/ddr4_0]
    save_bd_design

    # Rebuild user ip_repo's index before adding any source files
    update_ip_catalog -rebuild


}


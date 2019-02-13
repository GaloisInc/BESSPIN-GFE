open_hw
connect_hw_server
open_hw_target
current_hw_device [get_hw_devices xcvu9p_0]
# refresh_hw_device -update_hw_probes false [lindex [get_hw_devices xcvu9p_0] 0]
set_property PROBES.FILE {./bitstreams/p1_soc_chisel.ltx} [get_hw_devices xcvu9p_0]
set_property FULL_PROBES.FILE {./bitstreams/p1_soc_chisel.ltx} [get_hw_devices xcvu9p_0]
set_property PROGRAM.FILE {./bitstreams/p1_chisel_feb12.bit} [get_hw_devices xcvu9p_0]
program_hw_devices [get_hw_devices xcvu9p_0]
close_hw_target
disconnect_hw_server
close_hw

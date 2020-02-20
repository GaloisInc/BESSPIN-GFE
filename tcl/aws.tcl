
# Checking if HDK_SHELL_DIR env variable exists
if { [info exists ::env(HDK_SHELL_DIR)] } {
        set HDK_SHELL_DIR $::env(HDK_SHELL_DIR)
        puts "INFO: Using Shell directory $HDK_SHELL_DIR";
} else {
        puts "ERROR: HDK_SHELL_DIR environment variable not defined ! ";
        puts "Run the hdk_setup.sh script from the root directory of aws-fpga";
        exit 2
}

# Set the Device Type
source $HDK_SHELL_DIR/build/scripts/device_type.tcl

set fpga_platform "awsf1"
set fpga_part [DEVICE_TYPE]


set_msg_config -id {Chipscope 16-3} -suppress
set_msg_config -string {AXI_QUAD_SPI} -suppress

set uram_option 2
set clock_recipe_a A0
set clock_recipe_b B0
set clock_recipe_c C0

# Suppress Warnings
# These are to avoid warning messages that may not be real issues. A developer
# may comment them out if they wish to see more information from warning
# messages.
set_msg_config -id {Common 17-55}        -suppress
set_msg_config -id {Vivado 12-4739}      -suppress
set_msg_config -id {Constraints 18-4866} -suppress
set_msg_config -id {IP_Flow 19-2162}     -suppress
set_msg_config -id {Route 35-328}        -suppress
set_msg_config -id {Vivado 12-1008}      -suppress
set_msg_config -id {Vivado 12-508}       -suppress
set_msg_config -id {filemgmt 56-12}      -suppress
set_msg_config -id {DRC CKLD-1}          -suppress
set_msg_config -id {DRC CKLD-2}          -suppress
set_msg_config -id {IP_Flow 19-2248}     -suppress
set_msg_config -id {Vivado 12-1580}      -suppress
set_msg_config -id {Constraints 18-550}  -suppress
set_msg_config -id {Synth 8-3295}        -suppress
set_msg_config -id {Synth 8-3321}        -suppress
set_msg_config -id {Synth 8-3331}        -suppress
set_msg_config -id {Synth 8-3332}        -suppress
set_msg_config -id {Synth 8-6014}        -suppress
set_msg_config -id {Timing 38-436}       -suppress
set_msg_config -id {DRC REQP-1853}       -suppress
set_msg_config -id {Synth 8-350}         -suppress
set_msg_config -id {Synth 8-3848}        -suppress
set_msg_config -id {Synth 8-3917}        -suppress
set_msg_config -id {Opt 31-430}          -suppress

source $HDK_SHELL_DIR/build/scripts/strategy_DEFAULT.tcl

# Encrypt source code
source encrypt.tcl

# Procedure for running various implementation steps (impl_step)
source $HDK_SHELL_DIR/build/scripts/step_user.tcl -notrace

#################################################################
#### Do not remove this setting. Need to workaround bug 
##################################################################
set_param hd.clockRoutingWireReduction false


proc after_project {} {

}

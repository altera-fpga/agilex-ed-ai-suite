package require -exact qsys 19.2
package require altera_terp

set_module_property NAME altera_ai_ip
set_module_property VERSION 0.6
set_module_property ICON_PATH logo.jpg
set_module_property EDITABLE false
set_module_property AUTHOR "Altera Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false

add_fileset synthesis_files QUARTUS_SYNTH my_generate

set_fileset_property synthesis_files TOP_LEVEL altera_ai_ip
proc render_top_level {} {
  # get template
  set template_path "./verilog/altera_ai_ip.sv.terp"
  set template_fd [open $template_path]
  set template   [read $template_fd]
  close $template_fd
  set existing_arch [glob -directory "./verilog/" -tails -type d *]
  # Filter out unwanted directories
  set ignore_list {sequential_ip spatial_ip}
  set filtered_arch {}
  foreach arch $existing_arch {
    if {[lsearch $ignore_list $arch] == -1} {
        lappend filtered_arch $arch
    }
  }
  set params(archs) $filtered_arch
  set contents [altera_terp $template params]
  return $contents
}
add_fileset_file altera_ai_ip/altera_ai_ip.sv SYSTEM_VERILOG TEXT [render_top_level]

source ./static_files.tcl

proc my_generate { entity } {
  set architecture [get_parameter_value ARCH_OPTION]
  source ./verilog/$architecture/generated_files.tcl
}

#DLA ARCHITECTURE
set existing_arch [glob -directory "./verilog/" -tails -type d *]
# Filter out unwanted directories
set ignore_list {sequential_ip spatial_ip}
set filtered_arch {}
foreach arch $existing_arch {
    if {[lsearch $ignore_list $arch] == -1} {
        lappend filtered_arch $arch
    }
}
add_display_item "" "AI IP Core Architecture" GROUP tab
set arch_option_param ARCH_OPTION
add_parameter           $arch_option_param  STRING [lindex $filtered_arch 0]
set_parameter_property  $arch_option_param  ALLOWED_RANGES  $filtered_arch
set_parameter_property  $arch_option_param  DISPLAY_NAME    "Architecture"
set_parameter_property  $arch_option_param  DESCRIPTION     "Architecture"
set_parameter_property  $arch_option_param  AFFECTS_GENERATION true
set_parameter_property  $arch_option_param  HDL_PARAMETER   true
add_display_item "AI IP Core Architecture" $arch_option_param  parameter

set_module_property DESCRIPTION "The FPGA AI Suite is an AI Engine."
set_module_property DISPLAY_NAME "FPGA AI Suite"

source ./dla_helper.tcl

add_clk                dla_clk
add_clk                ddr_clk
add_clk                irq_clk
# the reset must be associated to a clock
add_rstn               dla_resetn   dla_clk

# CSR Parameters
add_display_item "" "CSR Parameters" GROUP tab

set param C_CSR_AXI_ADDR_WIDTH
add_parameter           $param  INTEGER         0
set_parameter_property  $param  DISPLAY_NAME    "Address Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI4-Lite Address Width."
set_parameter_property  $param  VISIBLE         true
set_parameter_property  $param  DERIVED         true
add_display_item "CSR Parameters" $param  parameter

set param C_CSR_AXI_DATA_WIDTH
add_parameter           $param  INTEGER         0
set_parameter_property  $param  DISPLAY_NAME    "Data Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI4-Lite Data Width."
set_parameter_property  $param  VISIBLE         true
set_parameter_property  $param  DERIVED         true
add_display_item "CSR Parameters" $param  parameter

# DDR Parameters

# get the default values of DDR params from the arch file annotated
# in default_param_values.tcl as ARCH_<param> variables
source ./verilog/[lindex $filtered_arch 0]/default_param_values.tcl

add_display_item "" "DDR Parameters" GROUP tab

set param C_DDR_AXI_ADDR_WIDTH
add_parameter           $param  INTEGER         $ARCH_C_DDR_AXI_ADDR_WIDTH
set_parameter_property  $param  DISPLAY_NAME    "Address Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  ALLOWED_RANGES  {1:32}
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI4 Address Width."
set_parameter_property  $param  VISIBLE         true
add_display_item "DDR Parameters" $param  parameter

set param C_DDR_AXI_DATA_WIDTH
add_parameter           $param  INTEGER         $ARCH_C_DDR_AXI_DATA_WIDTH
set_parameter_property  $param  DISPLAY_NAME    "Data Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  ALLOWED_RANGES  {8 16 64 128 256 512 1024}
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI4 Data Width."
set_parameter_property  $param  VISIBLE         true
add_display_item "DDR Parameters" $param  parameter

set param C_DDR_AXI_BURST_WIDTH
# Warning: omni_add_axi4_interface uses a constant of 2, but the rtl's default value is 4.
add_parameter           $param  INTEGER         0
set_parameter_property  $param  DISPLAY_NAME    "Burst Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   false
set_parameter_property  $param  DESCRIPTION     "AXI4 Burst Width. Length = 2**Width."
set_parameter_property  $param  VISIBLE         true
set_parameter_property  $param  DERIVED         true
add_display_item "DDR Parameters" $param  parameter

set param C_DDR_AXI_READ_ID_WIDTH
add_parameter           $param  INTEGER         $ARCH_C_DDR_AXI_READ_ID_WIDTH
set_parameter_property  $param  DISPLAY_NAME    "AXI4 Read ID Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI4 Read ID Width. Must be 2."
set_parameter_property  $param  VISIBLE         true
add_display_item "DDR Parameters" $param  parameter

set param C_DDR_AXI_WRITE_ID_WIDTH
add_parameter           $param  INTEGER         $ARCH_C_DDR_AXI_WRITE_ID_WIDTH
set_parameter_property  $param  DISPLAY_NAME    "AXI4 Write ID Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI4 Write ID Width. The AI IP uses varying Write IDs on successive writes, allowing the memory controller to reorder writes for better performance."
# Hide the parameter for now since PD expects the DDR AXI4's ID width to be the same across all channels. Use ARID for all channels.
set_parameter_property  $param  VISIBLE         false
add_display_item "DDR Parameters" $param  parameter

# Streaming Parameters

add_display_item "" "Streaming Parameters" GROUP tab

set param STREAMING_INPUT_ENABLED
add_parameter $param Integer 0                  "AXI Input Streaming Enabled"
set_parameter_property $param DISPLAY_NAME      "Input Streaming Enabled"
set_parameter_property $param DISPLAY_HINT      boolean
set_parameter_property $param DERIVED           true
set_parameter_property $param HDL_PARAMETER     false
set_parameter_property $param GROUP "Streaming Parameters"

set param AXI_ISTREAM_DATA_WIDTH
add_parameter           $param  INTEGER         128
set_parameter_property  $param  DISPLAY_NAME    "Input Streaming Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI Input Streaming Data Width."
set_parameter_property  $param  VISIBLE         true
set_parameter_property  $param  DERIVED         true
add_display_item "Streaming Parameters" $param  parameter

set param STREAMING_OUTPUT_ENABLED
add_parameter $param Integer 0                  "AXI Output Streaming Enabled"
set_parameter_property $param DISPLAY_NAME      "Output Streaming Enabled"
set_parameter_property $param DISPLAY_HINT      boolean
set_parameter_property $param DERIVED           true
set_parameter_property $param HDL_PARAMETER     false
set_parameter_property $param GROUP "Streaming Parameters"

set param AXI_OSTREAM_DATA_WIDTH
add_parameter           $param  INTEGER         128
set_parameter_property  $param  DISPLAY_NAME    "Output Streaming Width"
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "AXI Output Streaming Data Width."
set_parameter_property  $param  VISIBLE         true
set_parameter_property  $param  DERIVED         true
add_display_item "Streaming Parameters" $param  parameter


# DLA Parameters
# todo: either enable this or remove it before release
add_display_item "" "DLA Parameters" GROUP tab
set_display_item_property "DLA Parameters" VISIBLE false
# the parameters need to be defined first, and modified in elaboration
set param C_CONFIG_READER_DATA_BYTES
add_parameter           $param  INTEGER         8
set_parameter_property  $param  DISPLAY_NAME    "Config Input Width"
set_parameter_property  $param  DISPLAY_UNITS   "bytes"
set_parameter_property  $param  DESCRIPTION     "Config network input port width"
set_parameter_property  $param  VISIBLE         false
set_parameter_property  $param  DERIVED         true
add_display_item "DLA Parameters" $param  parameter

omni_add_capability 949 1 2048 0 0

add_validation_callback check_ddr_params
add_elab_callback my_elab
add_validation_callback check_family
# check if an INI is set to display capability tab
add_validation_callback check_ocs_ini

# Add simulation files information
add_display_item "" "Simulation Environment" GROUP tab
add_display_item "Simulation Environment" sim_info TEXT "<html>Simulation script files can be found in the ./sim directory of your IP instance.<br>
The environment can be started off with a single Python command.<br>
<br>
Some sample commands to run simulations are the following:<br>
<br>
<b>1. Simulation AGX7_Performance.arch with Questa and a Graph of your choice</b><br>
&nbsp;&nbsp;&nbsp;./dla_sim.py<br>
&nbsp;&nbsp;&nbsp; &nbsp; --model &lt;path_to_graph.xml&gt;<br>
&nbsp;&nbsp;&nbsp; &nbsp; --arch &lt;\$COREDLA_ROOT/example_architectures/AGX7_Performance.arch&gt;<br>
&nbsp;&nbsp;&nbsp; &nbsp; --simulation_tool questa<br>
&nbsp;&nbsp;&nbsp; &nbsp; --inputs &lt;path_to_input_folder&gt;<br>
&nbsp;&nbsp;&nbsp; &nbsp; --quiet</html>"


proc check_ddr_params {} {
  set architecture [get_parameter_value ARCH_OPTION]
  # ToDo: check for a mismatch with .arch file values before issuing the warning
  send_message WARNING "If any DDR Parameters were modified using the Platform Designer Parameter Editor, they may now be out of sync with the values in the .arch file ($architecture)."

  set supported_ddr_axi_id_width 2
  set axi_id_width [get_parameter_value C_DDR_AXI_READ_ID_WIDTH]
  if { $axi_id_width ne $supported_ddr_axi_id_width  } {
    send_message ERROR "Currently the IP only supports a Read ID Width of $supported_ddr_axi_id_width bits"
  }
}

proc my_elab {} {
  set architecture [get_parameter_value ARCH_OPTION]
  source ./verilog/$architecture/interface_param.tcl

  dla_add_axi4lite_slave_interface        csr_axi       ddr_clk     dla_resetn
  dla_add_axi4_master_interface           ddr_axi       ddr_clk     dla_resetn

  set streaming_input_enabled [get_parameter_value STREAMING_INPUT_ENABLED]
  set streaming_output_enabled [get_parameter_value STREAMING_OUTPUT_ENABLED]

  if { $streaming_input_enabled || $streaming_output_enabled } {
    add_clk axi_clk
  }

  if { $streaming_input_enabled } {
    dla_add_axi4streaming_slave_interface axi_istream axi_clk dla_resetn
  }

  if { $streaming_output_enabled } {
    dla_add_axi4streaming_master_interface axi_ostream axi_clk dla_resetn
  }
  omni_add_interrupt_port           irq_level     irq_clk     csr_axi output
}

# return the family string used by quartus
proc get_arch_family { arch_name } {
  set splitted_name [split $arch_name "_"]
  set family [lindex $splitted_name end]
  if { $family eq "A10" } {
    return "Arria 10"
  } elseif { $family eq "C10"} {
    return "Cyclone 10 GX"
  } elseif { $family eq "S10"} {
    return "Stratix 10"
  } elseif { $family eq "AGX7"} {
    return "Agilex 7"
  } elseif { $family eq "AGX9"} {
    return "Agilex 9"
  } elseif { $family eq "AGX5"} {
    return "Agilex 5"
  } elseif { $family eq "AGX3"} {
    return "Agilex 3"
  } else {
    send_message ERROR "Invalid Family: $family"
    return "Unknown Family"
  }
}

proc check_family {} {
  set family [get_parameter_value device_family]
  set architecture [get_parameter_value ARCH_OPTION]

  set arch_family [get_arch_family $architecture]

  if { $family ne $arch_family } {
    send_message ERROR "Design uses $family but architecture is built for $arch_family"
  }
}

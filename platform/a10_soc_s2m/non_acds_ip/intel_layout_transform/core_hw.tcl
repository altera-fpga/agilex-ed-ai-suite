package require -exact qsys 19.3

set_module_property NAME intel_layout_transform
set_module_property VERSION 0.1
set_module_property EDITABLE false
set_module_property AUTHOR "Intel Corporation"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property INTERNAL false

source ilt_helper.tcl

add_fileset QUARTUS_SYNTH QUARTUS_SYNTH my_generate ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL intel_layout_transform

proc my_generate { entity } {
}


add_fileset_file verilog/intel_layout_transform_shim.sv SYSTEM_VERILOG PATH verilog/intel_layout_transform_shim.sv
add_fileset_file verilog/intel_layout_transform_csr.sv  SYSTEM_VERILOG PATH verilog/intel_layout_transform_csr.sv
add_fileset_file verilog/intel_layout_transform_dsp.sv  SYSTEM_VERILOG PATH verilog/intel_layout_transform_dsp.sv
add_fileset_file verilog/intel_layout_transform_core.sv SYSTEM_VERILOG PATH verilog/intel_layout_transform_core.sv
add_fileset_file verilog/intel_layout_transform.sv      SYSTEM_VERILOG PATH verilog/intel_layout_transform.sv


set_module_property DESCRIPTION "FPGA AI Suite - Input Layout Transform"
set_module_property DISPLAY_NAME "FPGA AI Suite - Input Layout Transform"

# Declare Standard Interfaces
ilt_add_clk                clk
ilt_add_rst    rst         clk



ilt_add_axi4lite_interface config  clk rst 8 slave 32
ilt_add_avlst_interface stream_in  clk rst slave  IN_AXIS_WIDTH
ilt_add_avlst_interface stream_out clk rst master OUT_AXIS_WIDTH

add_parameter           FAMILY         string          ""
set_parameter_property  FAMILY         SYSTEM_INFO     {DEVICE_FAMILY}
set_parameter_property  FAMILY         HDL_PARAMETER   true
set_parameter_property  FAMILY	       VISIBLE	       false

# ILT Parameters
set param IN_AXIS_WIDTH
add_parameter           $param  INTEGER         32
set_parameter_property  $param  DISPLAY_NAME    "Data Width"
set_parameter_property  $param  ALLOWED_RANGES  {1:64}
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "Avalon-Stream Data Width."
add_display_item "Input Stream Parameters" $param  parameter

set param IN_SAMPLE_PLANES
add_parameter           $param  INTEGER         3
set_parameter_property  $param  DISPLAY_NAME    "Planes Per Sample"
set_parameter_property  $param  ALLOWED_RANGES  {1:16}
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "How many planes are there in an individual data sample"
add_display_item "Input Stream Parameters" $param  parameter

set param IN_SAMPLE_PLANE_BITS
add_parameter           $param  INTEGER         8
set_parameter_property  $param  DISPLAY_NAME    "Bits Per Plane"
set_parameter_property  $param  ALLOWED_RANGES  {8}
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "How many bits comprise a single plane"
add_display_item "Input Stream Parameters" $param  parameter

set param OUT_AXIS_WIDTH
add_parameter           $param  INTEGER         64
set_parameter_property  $param  DISPLAY_NAME    "Data Width"
set_parameter_property  $param  ALLOWED_RANGES  {16,32,64}
set_parameter_property  $param  DISPLAY_UNITS   "bits"
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "Avalon-Stream Data Width."
add_display_item "Output Stream Parameters" $param  parameter

set param BIG_ENDIAN
add_parameter           $param  INTEGER         1
set_parameter_property  $param  DISPLAY_NAME    "Big Endian Data"
set_parameter_property  $param  ALLOWED_RANGES  {0,1}
set_parameter_property  $param  HDL_PARAMETER   true
set_parameter_property  $param  DESCRIPTION     "Data Byte Packing"
add_display_item "Output Stream Parameters" $param  parameter

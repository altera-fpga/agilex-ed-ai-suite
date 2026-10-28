# spatial_inference_timer_hw.tcl

#
# request TCL package from ACDS 26.3
#
package require -exact qsys 26.3

#
# module spatial_inference_timer
#
set_module_property DESCRIPTION ""
set_module_property NAME spatial_inference_timer
set_module_property VERSION 1.0
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property BSP_CPU false
set_module_property GROUP ""
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME "spatial_inference_timer"
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property LOAD_ELABORATION_LIMIT 0
set_module_property PRE_COMP_MODULE_ENABLED false
set_module_property DISPLAY_ICON ""

#
# file sets
#
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL spatial_inference_timer
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file spatial_inference_timer.v VERILOG PATH spatial_inference_timer.v TOP_LEVEL_FILE

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL spatial_inference_timer
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file spatial_inference_timer.v VERILOG PATH spatial_inference_timer.v

#
# parameters
#
add_parameter INPUT_DATA_WIDTH INTEGER 32 "Input Data Width"
set_parameter_property INPUT_DATA_WIDTH DISPLAY_NAME "Input Data Width"
set_parameter_property INPUT_DATA_WIDTH UNITS Bits
set_parameter_property INPUT_DATA_WIDTH ALLOWED_RANGES {8 16 32 64 128 256 512 1024}
set_parameter_property INPUT_DATA_WIDTH HDL_PARAMETER true
set_parameter_property INPUT_DATA_WIDTH DESCRIPTION "Width of the stream carrying the model input"

add_parameter INPUT_TOTAL_BEATS INTEGER 1 "Input Total Beats"
set_parameter_property INPUT_TOTAL_BEATS DISPLAY_NAME "Input Total Beats"
set_parameter_property INPUT_TOTAL_BEATS ALLOWED_RANGES {1:2147483647}
set_parameter_property INPUT_TOTAL_BEATS HDL_PARAMETER true
set_parameter_property INPUT_TOTAL_BEATS DESCRIPTION "Beats in one input tensor"

add_parameter OUTPUT_DATA_WIDTH INTEGER 32 "Output Data Width"
set_parameter_property OUTPUT_DATA_WIDTH DISPLAY_NAME "Output Data Width"
set_parameter_property OUTPUT_DATA_WIDTH UNITS Bits
set_parameter_property OUTPUT_DATA_WIDTH ALLOWED_RANGES {8 16 32 64 128 256 512 1024}
set_parameter_property OUTPUT_DATA_WIDTH HDL_PARAMETER true
set_parameter_property OUTPUT_DATA_WIDTH DESCRIPTION "Width of the stream carrying the model output"

add_parameter OUTPUT_TOTAL_BEATS INTEGER 1 "Output Total Beats"
set_parameter_property OUTPUT_TOTAL_BEATS DISPLAY_NAME "Output Total Beats"
set_parameter_property OUTPUT_TOTAL_BEATS ALLOWED_RANGES {1:2147483647}
set_parameter_property OUTPUT_TOTAL_BEATS HDL_PARAMETER true
set_parameter_property OUTPUT_TOTAL_BEATS DESCRIPTION "Beats in one output tensor"

#
# connection point clock
#
add_interface clock clock end
set_interface_property clock ENABLED true
add_interface_port clock clk clk Input 1

#
# connection point reset
#
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
add_interface_port reset reset reset Input 1

#
# connection points for the model input tensor
#
add_interface input_sink avalon_streaming end
set_interface_property input_sink associatedClock clock
set_interface_property input_sink associatedReset reset
set_interface_property input_sink dataBitsPerSymbol 8
set_interface_property input_sink errorDescriptor ""
set_interface_property input_sink firstSymbolInHighOrderBits true
set_interface_property input_sink maxChannel 0
set_interface_property input_sink readyAllowance 0
set_interface_property input_sink readyLatency 0
set_interface_property input_sink ENABLED true

add_interface_port input_sink input_sink_data data Input INPUT_DATA_WIDTH
add_interface_port input_sink input_sink_valid valid Input 1
add_interface_port input_sink input_sink_ready ready Output 1

add_interface input_source avalon_streaming start
set_interface_property input_source associatedClock clock
set_interface_property input_source associatedReset reset
set_interface_property input_source dataBitsPerSymbol 8
set_interface_property input_source errorDescriptor ""
set_interface_property input_source firstSymbolInHighOrderBits true
set_interface_property input_source maxChannel 0
set_interface_property input_source readyAllowance 0
set_interface_property input_source readyLatency 0
set_interface_property input_source ENABLED true

add_interface_port input_source input_source_data data Output INPUT_DATA_WIDTH
add_interface_port input_source input_source_valid valid Output 1
add_interface_port input_source input_source_ready ready Input 1

#
# connection points for the model output tensor
#
add_interface output_sink avalon_streaming end
set_interface_property output_sink associatedClock clock
set_interface_property output_sink associatedReset reset
set_interface_property output_sink dataBitsPerSymbol 8
set_interface_property output_sink errorDescriptor ""
set_interface_property output_sink firstSymbolInHighOrderBits true
set_interface_property output_sink maxChannel 0
set_interface_property output_sink readyAllowance 0
set_interface_property output_sink readyLatency 0
set_interface_property output_sink ENABLED true

add_interface_port output_sink output_sink_data data Input OUTPUT_DATA_WIDTH
add_interface_port output_sink output_sink_valid valid Input 1
add_interface_port output_sink output_sink_ready ready Output 1

add_interface output_source avalon_streaming start
set_interface_property output_source associatedClock clock
set_interface_property output_source associatedReset reset
set_interface_property output_source dataBitsPerSymbol 8
set_interface_property output_source errorDescriptor ""
set_interface_property output_source firstSymbolInHighOrderBits true
set_interface_property output_source maxChannel 0
set_interface_property output_source readyAllowance 0
set_interface_property output_source readyLatency 0
set_interface_property output_source ENABLED true

add_interface_port output_source output_source_data data Output OUTPUT_DATA_WIDTH
add_interface_port output_source output_source_valid valid Output 1
add_interface_port output_source output_source_ready ready Input 1

#
# connection point avalon_slave
#
add_interface avalon_slave avalon end
set_interface_property avalon_slave addressUnits WORDS
set_interface_property avalon_slave associatedClock clock
set_interface_property avalon_slave associatedReset reset
set_interface_property avalon_slave bitsPerSymbol 8
set_interface_property avalon_slave readLatency 1
set_interface_property avalon_slave ENABLED true

add_interface_port avalon_slave avs_address address Input 2
add_interface_port avalon_slave avs_read read Input 1
add_interface_port avalon_slave avs_readdata readdata Output 32
add_interface_port avalon_slave avs_waitrequest waitrequest Output 1

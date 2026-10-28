#
# SPDX-FileCopyrightText: Copyright (C) 2023-2025 Altera Corporation
# SPDX-License-Identifier: MIT-0
#

package require -exact qsys 25.3


#
# module msgdma2axi4
#
set_module_property DESCRIPTION ""
set_module_property NAME msgdma2axi4
set_module_property VERSION 1.2
set_module_property INTERNAL false
set_module_property OPAQUE_ADDRESS_MAP true
set_module_property AUTHOR ""
set_module_property DISPLAY_NAME msgdma2axi4
set_module_property INSTANTIATE_IN_SYSTEM_MODULE true
set_module_property EDITABLE true
set_module_property REPORT_TO_TALKBACK false
set_module_property ALLOW_GREYBOX_GENERATION false
set_module_property REPORT_HIERARCHY false
set_module_property LOAD_ELABORATION_LIMIT 0
set_module_property PRE_COMP_MODULE_ENABLED false
set_module_property ELABORATION_CALLBACK elaborate
set_module_property VALIDATION_CALLBACK validate

#
# file sets
#
add_fileset QUARTUS_SYNTH QUARTUS_SYNTH "" ""
set_fileset_property QUARTUS_SYNTH TOP_LEVEL msgdma2axi4
set_fileset_property QUARTUS_SYNTH ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property QUARTUS_SYNTH ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file msgdma2axi4.v VERILOG PATH msgdma2axi4.v TOP_LEVEL_FILE

add_fileset SIM_VERILOG SIM_VERILOG "" ""
set_fileset_property SIM_VERILOG TOP_LEVEL msgdma2axi4
set_fileset_property SIM_VERILOG ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VERILOG ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file msgdma2axi4.v VERILOG PATH msgdma2axi4.v

add_fileset SIM_VHDL SIM_VHDL "" ""
set_fileset_property SIM_VHDL TOP_LEVEL msgdma2axi4
set_fileset_property SIM_VHDL ENABLE_RELATIVE_INCLUDE_PATHS false
set_fileset_property SIM_VHDL ENABLE_FILE_OVERWRITE_MODE false
add_fileset_file msgdma2axi4.v VERILOG PATH msgdma2axi4.v


#
# parameters
#

# Data width: 64/128/256/512 bits
add_parameter DATA_WIDTH INTEGER 256
set_parameter_property DATA_WIDTH DEFAULT_VALUE 256
set_parameter_property DATA_WIDTH DISPLAY_NAME "Data width"
set_parameter_property DATA_WIDTH UNITS Bits
set_parameter_property DATA_WIDTH HDL_PARAMETER true
set_parameter_property DATA_WIDTH AFFECTS_GENERATION false
# Restrict to 64/128/256/512
set_parameter_property DATA_WIDTH ALLOWED_RANGES {64 128 256 512}

# Address width: 20..40 bits (1 MB .. 1 TB)
add_parameter ADDR_WIDTH INTEGER 37
set_parameter_property ADDR_WIDTH DEFAULT_VALUE 37
set_parameter_property ADDR_WIDTH DISPLAY_NAME "Interface Address Width"
set_parameter_property ADDR_WIDTH UNITS Bits
set_parameter_property ADDR_WIDTH HDL_PARAMETER true
set_parameter_property ADDR_WIDTH AFFECTS_GENERATION false
set_parameter_property ADDR_WIDTH ALLOWED_RANGES {20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40}

# Maximum burst count, matching mSGDMA-style power-of-2 selections.
# Note: AXI4 ARLEN/AWLEN supports at most 256 beats in a single burst,
# so values above 256 require burst splitting logic and are rejected by validation.
add_parameter MAX_BURST_COUNT INTEGER 16
set_parameter_property MAX_BURST_COUNT DEFAULT_VALUE 16
set_parameter_property MAX_BURST_COUNT DISPLAY_NAME "Maximum Burst Count"
set_parameter_property MAX_BURST_COUNT HDL_PARAMETER true
set_parameter_property MAX_BURST_COUNT AFFECTS_GENERATION false
set_parameter_property MAX_BURST_COUNT ALLOWED_RANGES {2 4 8 16 32 64 128 256}

add_parameter BURST_COUNT_WIDTH INTEGER 1
set_parameter_property BURST_COUNT_WIDTH DERIVED true
set_parameter_property BURST_COUNT_WIDTH VISIBLE false

# Enable / disable interfaces
add_parameter ENABLE_S0_READ INTEGER 1
set_parameter_property ENABLE_S0_READ DEFAULT_VALUE 1
set_parameter_property ENABLE_S0_READ DISPLAY_NAME "Enable Slave s0 read"
set_parameter_property ENABLE_S0_READ DISPLAY_HINT boolean
set_parameter_property ENABLE_S0_READ ALLOWED_RANGES 0:1
set_parameter_property ENABLE_S0_READ HDL_PARAMETER true
set_parameter_property ENABLE_S0_READ AFFECTS_GENERATION false
set_parameter_property ENABLE_S0_READ AFFECTS_ELABORATION true

add_parameter ENABLE_S1_WRITE INTEGER 1
set_parameter_property ENABLE_S1_WRITE DEFAULT_VALUE 1
set_parameter_property ENABLE_S1_WRITE DISPLAY_NAME "Enable Slave s1 write"
set_parameter_property ENABLE_S1_WRITE DISPLAY_HINT boolean
set_parameter_property ENABLE_S1_WRITE ALLOWED_RANGES 0:1
set_parameter_property ENABLE_S1_WRITE HDL_PARAMETER true
set_parameter_property ENABLE_S1_WRITE AFFECTS_GENERATION false
set_parameter_property ENABLE_S1_WRITE AFFECTS_ELABORATION true

# ---------------------------------------------------------------------------
# Validation callback to prevent both interfaces from being disabled
# ---------------------------------------------------------------------------
proc validate {} {
   set enable_s0 [get_parameter_value ENABLE_S0_READ]
   set enable_s1 [get_parameter_value ENABLE_S1_WRITE]
   set max_burst_count [get_parameter_value MAX_BURST_COUNT]

   if {($enable_s0 == 0) && ($enable_s1 == 0)} {
      send_message error "At least one interface must be enabled. Enable Slave s0 read and/or Enable Slave s1 write must be set to 1."
   }

   if {$max_burst_count > 256} {
      send_message error "MAX_BURST_COUNT=$max_burst_count is not supported by this adapter. AXI4 AWLEN/ARLEN allows at most 256 beats per burst. Values above 256 require burst splitting logic."
   }
}

# ---------------------------------------------------------------------------
# Elaborate callback to handle parameterized port widths and interface enablement
# ---------------------------------------------------------------------------
proc elaborate {} {
   set enable_s0 [get_parameter_value ENABLE_S0_READ]
   set enable_s1 [get_parameter_value ENABLE_S1_WRITE]
   set max_burst_count [get_parameter_value MAX_BURST_COUNT]
   # log2ceil + 1
   set burst_width [expr {int(ceil(log($max_burst_count) / log(2))) + 1}]
   set_parameter_value BURST_COUNT_WIDTH $burst_width

   # Enable / disable Avalon-MM slave interfaces in Platform Designer
   set_interface_property s0 ENABLED $enable_s0
   set_interface_property s1 ENABLED $enable_s1

   # Interface properties derived from Maximum Burst Count

   # Address width parameterized ports
   set_port_property s0_read_address WIDTH_EXPR "ADDR_WIDTH"
   set_port_property s1_write_address WIDTH_EXPR "ADDR_WIDTH"
   set_port_property m0_araddr WIDTH_EXPR "ADDR_WIDTH"
   set_port_property m0_awaddr WIDTH_EXPR "ADDR_WIDTH"

   # Data width parameterized ports
   set_port_property s0_read_readdata WIDTH_EXPR "DATA_WIDTH"
   set_port_property s1_write_writedata WIDTH_EXPR "DATA_WIDTH"
   set_port_property s0_read_byteenable WIDTH_EXPR "(DATA_WIDTH/8)"
   set_port_property s1_write_byteenable WIDTH_EXPR "(DATA_WIDTH/8)"
   set_port_property m0_rdata WIDTH_EXPR "DATA_WIDTH"
   set_port_property m0_wdata WIDTH_EXPR "DATA_WIDTH"
   set_port_property m0_wstrb WIDTH_EXPR "(DATA_WIDTH/8)"

   # Burstcount width derived from Maximum Burst Count, matching Avalon convention.
   # Example: max burst 8 -> width 4, max burst 128 -> width 8.
   set_port_property s0_read_burstcount WIDTH_EXPR "BURST_COUNT_WIDTH"
   set_port_property s1_write_burstcount WIDTH_EXPR "BURST_COUNT_WIDTH"
}

#
# display items
#
add_display_item "DMA Settings" DATA_WIDTH PARAMETER ""
add_display_item "DMA Settings" ADDR_WIDTH PARAMETER ""
add_display_item "DMA Settings" ENABLE_S0_READ PARAMETER ""
add_display_item "DMA Settings" ENABLE_S1_WRITE PARAMETER ""
add_display_item "DMA Settings" MAX_BURST_COUNT PARAMETER ""

#
# connection point clock
#
add_interface clock clock end
set_interface_property clock ENABLED true
set_interface_property clock EXPORT_OF ""
set_interface_property clock PORT_NAME_MAP ""
set_interface_property clock CMSIS_SVD_VARIABLES ""
set_interface_property clock SVD_ADDRESS_GROUP ""
set_interface_property clock IPXACT_REGISTER_MAP_VARIABLES ""
set_interface_property clock SV_INTERFACE_TYPE ""
set_interface_property clock SV_INTERFACE_MODPORT_TYPE ""

add_interface_port clock clk clk Input 1


#
# connection point reset
#
add_interface reset reset end
set_interface_property reset associatedClock clock
set_interface_property reset synchronousEdges DEASSERT
set_interface_property reset ENABLED true
set_interface_property reset EXPORT_OF ""
set_interface_property reset PORT_NAME_MAP ""
set_interface_property reset CMSIS_SVD_VARIABLES ""
set_interface_property reset SVD_ADDRESS_GROUP ""
set_interface_property reset IPXACT_REGISTER_MAP_VARIABLES ""
set_interface_property reset SV_INTERFACE_TYPE ""
set_interface_property reset SV_INTERFACE_MODPORT_TYPE ""

add_interface_port reset reset reset Input 1


#
# connection point s0 - Avalon-MM read slave
#
add_interface s0 avalon end
set_interface_property s0 addressGroup 0
set_interface_property s0 addressUnits SYMBOLS
set_interface_property s0 associatedClock clock
set_interface_property s0 associatedReset reset
set_interface_property s0 bitsPerSymbol 8
set_interface_property s0 bridgedAddressOffset ""
set_interface_property s0 bridgesToMaster ""
set_interface_property s0 burstOnBurstBoundariesOnly false
set_interface_property s0 burstcountUnits WORDS
set_interface_property s0 explicitAddressSpan 0
set_interface_property s0 holdTime 0
set_interface_property s0 linewrapBursts false
set_interface_property s0 maximumPendingReadTransactions 16
set_interface_property s0 maximumPendingWriteTransactions 0
set_interface_property s0 minimumResponseLatency 1
set_interface_property s0 readLatency 0
set_interface_property s0 readWaitTime 1
set_interface_property s0 setupTime 0
set_interface_property s0 timingUnits Cycles
set_interface_property s0 transparentBridge false
set_interface_property s0 waitrequestAllowance 0
set_interface_property s0 writeWaitTime 0
set_interface_property s0 ENABLED true
set_interface_property s0 EXPORT_OF ""
set_interface_property s0 PORT_NAME_MAP ""
set_interface_property s0 CMSIS_SVD_VARIABLES ""
set_interface_property s0 SVD_ADDRESS_GROUP ""
set_interface_property s0 IPXACT_REGISTER_MAP_VARIABLES ""
set_interface_property s0 SV_INTERFACE_TYPE ""
set_interface_property s0 SV_INTERFACE_MODPORT_TYPE ""

add_interface_port s0 s0_read_address       address        Input  1
add_interface_port s0 s0_read_read          read           Input  1
add_interface_port s0 s0_read_byteenable    byteenable     Input  1
add_interface_port s0 s0_read_readdata      readdata       Output 1
add_interface_port s0 s0_read_waitrequest   waitrequest    Output 1
add_interface_port s0 s0_read_readdatavalid readdatavalid  Output 1
add_interface_port s0 s0_read_burstcount    burstcount     Input  1
set_interface_assignment s0 embeddedsw.configuration.isFlash 0
set_interface_assignment s0 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s0 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s0 embeddedsw.configuration.isPrintableDevice 0


#
# connection point s1 - Avalon-MM write slave
#
add_interface s1 avalon end
set_interface_property s1 addressGroup 0
set_interface_property s1 addressUnits SYMBOLS
set_interface_property s1 associatedClock clock
set_interface_property s1 associatedReset reset
set_interface_property s1 bitsPerSymbol 8
set_interface_property s1 bridgedAddressOffset ""
set_interface_property s1 bridgesToMaster ""
set_interface_property s1 burstOnBurstBoundariesOnly false
set_interface_property s1 burstcountUnits WORDS
set_interface_property s1 explicitAddressSpan 0
set_interface_property s1 holdTime 0
set_interface_property s1 linewrapBursts false
set_interface_property s1 maximumPendingReadTransactions 0
set_interface_property s1 maximumPendingWriteTransactions 0
set_interface_property s1 minimumResponseLatency 1
set_interface_property s1 readLatency 0
set_interface_property s1 readWaitTime 1
set_interface_property s1 setupTime 0
set_interface_property s1 timingUnits Cycles
set_interface_property s1 transparentBridge false
set_interface_property s1 waitrequestAllowance 0
set_interface_property s1 writeWaitTime 0
set_interface_property s1 ENABLED true
set_interface_property s1 EXPORT_OF ""
set_interface_property s1 PORT_NAME_MAP ""
set_interface_property s1 CMSIS_SVD_VARIABLES ""
set_interface_property s1 SVD_ADDRESS_GROUP ""
set_interface_property s1 IPXACT_REGISTER_MAP_VARIABLES ""
set_interface_property s1 SV_INTERFACE_TYPE ""
set_interface_property s1 SV_INTERFACE_MODPORT_TYPE ""

add_interface_port s1 s1_write_address     address      Input  1
add_interface_port s1 s1_write_write       write        Input  1
add_interface_port s1 s1_write_byteenable  byteenable   Input  1
add_interface_port s1 s1_write_writedata   writedata    Input  1
add_interface_port s1 s1_write_waitrequest waitrequest  Output 1
add_interface_port s1 s1_write_burstcount  burstcount   Input  1
set_interface_assignment s1 embeddedsw.configuration.isFlash 0
set_interface_assignment s1 embeddedsw.configuration.isMemoryDevice 0
set_interface_assignment s1 embeddedsw.configuration.isNonVolatileStorage 0
set_interface_assignment s1 embeddedsw.configuration.isPrintableDevice 0


#
# connection point m0 - AXI4 manager
#
add_interface m0 axi4 start
set_interface_property m0 associatedClock clock
set_interface_property m0 associatedReset reset
set_interface_property m0 readIssuingCapability 16
set_interface_property m0 writeIssuingCapability 16
set_interface_property m0 combinedIssuingCapability 32
set_interface_property m0 issuesINCRBursts true
set_interface_property m0 issuesWRAPBursts false
set_interface_property m0 issuesFIXEDBursts false
set_interface_property m0 ENABLED true
set_interface_property m0 EXPORT_OF ""
set_interface_property m0 PORT_NAME_MAP ""
set_interface_property m0 CMSIS_SVD_VARIABLES ""
set_interface_property m0 SVD_ADDRESS_GROUP ""
set_interface_property m0 IPXACT_REGISTER_MAP_VARIABLES ""
set_interface_property m0 SV_INTERFACE_TYPE ""
set_interface_property m0 SV_INTERFACE_MODPORT_TYPE ""

add_interface_port m0 m0_araddr   araddr   Output 1
add_interface_port m0 m0_arburst  arburst  Output 2
add_interface_port m0 m0_arcache  arcache  Output 4
add_interface_port m0 m0_arid     arid     Output 1
add_interface_port m0 m0_arlen    arlen    Output 8
add_interface_port m0 m0_arlock   arlock   Output 1
add_interface_port m0 m0_arprot   arprot   Output 3
add_interface_port m0 m0_arready  arready  Input  1
add_interface_port m0 m0_arsize   arsize   Output 3
add_interface_port m0 m0_arvalid  arvalid  Output 1
add_interface_port m0 m0_awaddr   awaddr   Output 1
add_interface_port m0 m0_awburst  awburst  Output 2
add_interface_port m0 m0_awcache  awcache  Output 4
add_interface_port m0 m0_awid     awid     Output 1
add_interface_port m0 m0_awlen    awlen    Output 8
add_interface_port m0 m0_awlock   awlock   Output 1
add_interface_port m0 m0_awprot   awprot   Output 3
add_interface_port m0 m0_awready  awready  Input  1
add_interface_port m0 m0_awsize   awsize   Output 3
add_interface_port m0 m0_awvalid  awvalid  Output 1
add_interface_port m0 m0_bid      bid      Input  1
add_interface_port m0 m0_bready   bready   Output 1
add_interface_port m0 m0_bresp    bresp    Input  2
add_interface_port m0 m0_bvalid   bvalid   Input  1
add_interface_port m0 m0_rdata    rdata    Input  1
add_interface_port m0 m0_rid      rid      Input  1
add_interface_port m0 m0_rlast    rlast    Input  1
add_interface_port m0 m0_rready   rready   Output 1
add_interface_port m0 m0_rresp    rresp    Input  2
add_interface_port m0 m0_rvalid   rvalid   Input  1
add_interface_port m0 m0_wdata    wdata    Output 1
add_interface_port m0 m0_wlast    wlast    Output 1
add_interface_port m0 m0_wready   wready   Input  1
add_interface_port m0 m0_wstrb    wstrb    Output 1
add_interface_port m0 m0_wvalid   wvalid   Output 1

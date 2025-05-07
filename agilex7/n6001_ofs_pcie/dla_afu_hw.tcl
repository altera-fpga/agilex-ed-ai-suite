package require -exact qsys 17.0

# module properties
set_module_property NAME {dla_afu}
set_module_property DISPLAY_NAME {DLA OFS AFU wrapper}
set_module_property VERSION {24.1}
set_module_property GROUP {DLA System Components}
set_module_property DESCRIPTION {Interface logic for wrapping the DLA IP into the OFS AFU infrastructure}
set_module_property AUTHOR {DLA}
set_module_property COMPOSITION_CALLBACK compose

# +-----------------------------------
# | parameters
# |
source parameters.tcl

add_parameter NUMBER_OF_MEMORY_BANKS INTEGER $p_NUMBER_OF_MEMORY_BANKS
set_parameter_property NUMBER_OF_MEMORY_BANKS DEFAULT_VALUE $p_NUMBER_OF_MEMORY_BANKS
set_parameter_property NUMBER_OF_MEMORY_BANKS DISPLAY_NAME "Number of Memory Banks"
set_parameter_property NUMBER_OF_MEMORY_BANKS AFFECTS_ELABORATION true

add_parameter MEMORY_BANK_ADDRESS_WIDTH INTEGER $p_MEMORY_BANK_ADDRESS_WIDTH
set_parameter_property MEMORY_BANK_ADDRESS_WIDTH DEFAULT_VALUE $p_MEMORY_BANK_ADDRESS_WIDTH
set_parameter_property MEMORY_BANK_ADDRESS_WIDTH DISPLAY_NAME "Memory Bank Address Width"
set_parameter_property MEMORY_BANK_ADDRESS_WIDTH AFFECTS_ELABORATION true

add_parameter MEMORY_BANK_DATA_WIDTH INTEGER $p_MEMORY_BANK_DATA_WIDTH
set_parameter_property MEMORY_BANK_DATA_WIDTH DEFAULT_VALUE $p_MEMORY_BANK_DATA_WIDTH
set_parameter_property MEMORY_BANK_DATA_WIDTH DISPLAY_NAME "Memory Bank Data Width"
set_parameter_property MEMORY_BANK_DATA_WIDTH AFFECTS_ELABORATION true

add_parameter MMIO_ADDRESS_WIDTH INTEGER $p_MMIO_ADDRESS_WIDTH
set_parameter_property MMIO_ADDRESS_WIDTH DEFAULT_VALUE $p_MMIO_ADDRESS_WIDTH
set_parameter_property MMIO_ADDRESS_WIDTH DISPLAY_NAME "MMIO Address Width"
set_parameter_property MMIO_ADDRESS_WIDTH AFFECTS_ELABORATION true

add_parameter MMIO_DATA_WIDTH INTEGER $p_MMIO_DATA_WIDTH
set_parameter_property MMIO_DATA_WIDTH DEFAULT_VALUE $p_MMIO_DATA_WIDTH
set_parameter_property MMIO_DATA_WIDTH DISPLAY_NAME "MMIO Data Width"
set_parameter_property MMIO_DATA_WIDTH AFFECTS_ELABORATION true
# | 
# +-----------------------------------

proc compose { } {
  # Get parameters
  set number_of_memory_banks    [ get_parameter_value NUMBER_OF_MEMORY_BANKS ]
  set memory_bank_address_width [ get_parameter_value MEMORY_BANK_ADDRESS_WIDTH ]
  set memory_bank_data_width    [ get_parameter_value MEMORY_BANK_DATA_WIDTH ]
  set mmio_address_width        [ get_parameter_value MMIO_ADDRESS_WIDTH ]
  set mmio_data_width           [ get_parameter_value MMIO_DATA_WIDTH ]

  # Instances and instance parameters
  add_instance pcie_clk_in altera_clock_bridge 19.2.0
  set_instance_parameter_value pcie_clk_in {EXPLICIT_CLOCK_RATE} {0.0}
  set_instance_parameter_value pcie_clk_in {NUM_CLOCK_OUTPUTS} {1}

  add_instance dla_clk_in altera_clock_bridge 19.2.0
  set_instance_parameter_value dla_clk_in {EXPLICIT_CLOCK_RATE} {0.0}
  set_instance_parameter_value dla_clk_in {NUM_CLOCK_OUTPUTS} {1}

  add_instance reset_in altera_reset_bridge 19.2.0
  set_instance_parameter_value reset_in {ACTIVE_LOW_RESET} {1}
  set_instance_parameter_value reset_in {SYNCHRONOUS_EDGES} {deassert}
  set_instance_parameter_value reset_in {NUM_RESET_OUTPUTS} {6} 
  set_instance_parameter_value reset_in {SYNC_RESET} {1}
  set_instance_parameter_value reset_in {USE_RESET_REQUEST} {0}

  add_instance dla_reset_in altera_reset_bridge 19.2.0
  set_instance_parameter_value dla_reset_in {ACTIVE_LOW_RESET} {1}
  set_instance_parameter_value dla_reset_in {SYNCHRONOUS_EDGES} {deassert}
  set_instance_parameter_value dla_reset_in {NUM_RESET_OUTPUTS} {1} 
  set_instance_parameter_value dla_reset_in {SYNC_RESET} {1}
  set_instance_parameter_value dla_reset_in {USE_RESET_REQUEST} {0}

  add_instance mmio_control altera_axi_bridge 19.4.0
  set_instance_parameter_value mmio_control {ACE_LITE_SUPPORT} {0}
  set_instance_parameter_value mmio_control {ADDR_WIDTH} $mmio_address_width
  set_instance_parameter_value mmio_control {AXI_VERSION} {AXI4}
  set_instance_parameter_value mmio_control {BACKPRESSURE_DURING_RESET} {0}
  set_instance_parameter_value mmio_control {COMBINED_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value mmio_control {COMBINED_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value mmio_control {DATA_WIDTH} $mmio_data_width
  set_instance_parameter_value mmio_control {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
  set_instance_parameter_value mmio_control {ENABLE_OOO} {0}
  set_instance_parameter_value mmio_control {M0_ID_WIDTH} {16}
  set_instance_parameter_value mmio_control {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
  set_instance_parameter_value mmio_control {READ_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value mmio_control {READ_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value mmio_control {READ_DATA_REORDERING_DEPTH} {1}
  set_instance_parameter_value mmio_control {READ_DATA_USER_WIDTH} {1}
  set_instance_parameter_value mmio_control {READ_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value mmio_control {S0_ID_WIDTH} {16}
  set_instance_parameter_value mmio_control {SYNC_RESET} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARBURST} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARCACHE} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARID} {1}
  set_instance_parameter_value mmio_control {USE_M0_ARLEN} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARLOCK} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARQOS} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARREGION} {0}
  set_instance_parameter_value mmio_control {USE_M0_ARSIZE} {1}
  set_instance_parameter_value mmio_control {USE_M0_ARUSER} {1}
  set_instance_parameter_value mmio_control {USE_M0_AWBURST} {0}
  set_instance_parameter_value mmio_control {USE_M0_AWCACHE} {0}
  set_instance_parameter_value mmio_control {USE_M0_AWID} {1}
  set_instance_parameter_value mmio_control {USE_M0_AWLEN} {0}
  set_instance_parameter_value mmio_control {USE_M0_AWLOCK} {0}
  set_instance_parameter_value mmio_control {USE_M0_AWQOS} {0}
  set_instance_parameter_value mmio_control {USE_M0_AWREGION} {0}
  set_instance_parameter_value mmio_control {USE_M0_AWSIZE} {1}
  set_instance_parameter_value mmio_control {USE_M0_AWUSER} {1}
  set_instance_parameter_value mmio_control {USE_M0_BID} {1}
  set_instance_parameter_value mmio_control {USE_M0_BRESP} {0}
  set_instance_parameter_value mmio_control {USE_M0_BUSER} {1}
  set_instance_parameter_value mmio_control {USE_M0_RID} {1}
  set_instance_parameter_value mmio_control {USE_M0_RLAST} {0}
  set_instance_parameter_value mmio_control {USE_M0_RRESP} {1}
  set_instance_parameter_value mmio_control {USE_M0_RUSER} {1}
  set_instance_parameter_value mmio_control {USE_M0_WSTRB} {1}
  set_instance_parameter_value mmio_control {USE_M0_WUSER} {1}
  set_instance_parameter_value mmio_control {USE_PIPELINE} {1}
  set_instance_parameter_value mmio_control {USE_S0_ARCACHE} {0}
  set_instance_parameter_value mmio_control {USE_S0_ARLOCK} {0}
  set_instance_parameter_value mmio_control {USE_S0_ARPROT} {0}
  set_instance_parameter_value mmio_control {USE_S0_ARQOS} {0}
  set_instance_parameter_value mmio_control {USE_S0_ARREGION} {0}
  set_instance_parameter_value mmio_control {USE_S0_ARUSER} {1}
  set_instance_parameter_value mmio_control {USE_S0_AWCACHE} {0}
  set_instance_parameter_value mmio_control {USE_S0_AWLOCK} {0}
  set_instance_parameter_value mmio_control {USE_S0_AWPROT} {0}
  set_instance_parameter_value mmio_control {USE_S0_AWQOS} {0}
  set_instance_parameter_value mmio_control {USE_S0_AWREGION} {0}
  set_instance_parameter_value mmio_control {USE_S0_AWUSER} {1}
  set_instance_parameter_value mmio_control {USE_S0_BRESP} {1}
  set_instance_parameter_value mmio_control {USE_S0_BUSER} {1}
  set_instance_parameter_value mmio_control {USE_S0_RRESP} {1}
  set_instance_parameter_value mmio_control {USE_S0_RUSER} {1}
  set_instance_parameter_value mmio_control {USE_S0_WLAST} {0}
  set_instance_parameter_value mmio_control {USE_S0_WUSER} {1}
  set_instance_parameter_value mmio_control {WRITE_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value mmio_control {WRITE_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value mmio_control {WRITE_DATA_USER_WIDTH} {1}
  set_instance_parameter_value mmio_control {WRITE_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value mmio_control {WRITE_RESP_USER_WIDTH} {1}

  add_instance sw_reset sw_reset 10.0
  set_instance_parameter_value sw_reset {WIDTH} {64}
  set_instance_parameter_value sw_reset {LOG2_RESET_CYCLES} {8}

  add_instance dma_csr altera_axi_bridge 19.4.0
  set_instance_parameter_value dma_csr {ACE_LITE_SUPPORT} {0}
  set_instance_parameter_value dma_csr {ADDR_WIDTH} {16}
  set_instance_parameter_value dma_csr {AXI_VERSION} {AXI4}
  set_instance_parameter_value dma_csr {BACKPRESSURE_DURING_RESET} {0}
  set_instance_parameter_value dma_csr {COMBINED_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value dma_csr {COMBINED_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value dma_csr {DATA_WIDTH} $mmio_data_width
  set_instance_parameter_value dma_csr {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
  set_instance_parameter_value dma_csr {ENABLE_OOO} {0}
  set_instance_parameter_value dma_csr {M0_ID_WIDTH} {18}
  set_instance_parameter_value dma_csr {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
  set_instance_parameter_value dma_csr {READ_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value dma_csr {READ_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value dma_csr {READ_DATA_REORDERING_DEPTH} {1}
  set_instance_parameter_value dma_csr {READ_DATA_USER_WIDTH} {1}
  set_instance_parameter_value dma_csr {READ_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value dma_csr {S0_ID_WIDTH} {18}
  set_instance_parameter_value dma_csr {SYNC_RESET} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARBURST} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARCACHE} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARID} {1}
  set_instance_parameter_value dma_csr {USE_M0_ARLEN} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARLOCK} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARQOS} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARREGION} {0}
  set_instance_parameter_value dma_csr {USE_M0_ARSIZE} {1}
  set_instance_parameter_value dma_csr {USE_M0_ARUSER} {1}
  set_instance_parameter_value dma_csr {USE_M0_AWBURST} {0}
  set_instance_parameter_value dma_csr {USE_M0_AWCACHE} {0}
  set_instance_parameter_value dma_csr {USE_M0_AWID} {1}
  set_instance_parameter_value dma_csr {USE_M0_AWLEN} {0}
  set_instance_parameter_value dma_csr {USE_M0_AWLOCK} {0}
  set_instance_parameter_value dma_csr {USE_M0_AWQOS} {0}
  set_instance_parameter_value dma_csr {USE_M0_AWREGION} {0}
  set_instance_parameter_value dma_csr {USE_M0_AWSIZE} {1}
  set_instance_parameter_value dma_csr {USE_M0_AWUSER} {1}
  set_instance_parameter_value dma_csr {USE_M0_BID} {1}
  set_instance_parameter_value dma_csr {USE_M0_BRESP} {0}
  set_instance_parameter_value dma_csr {USE_M0_BUSER} {1}
  set_instance_parameter_value dma_csr {USE_M0_RID} {1}
  set_instance_parameter_value dma_csr {USE_M0_RLAST} {0}
  set_instance_parameter_value dma_csr {USE_M0_RRESP} {1}
  set_instance_parameter_value dma_csr {USE_M0_RUSER} {1}
  set_instance_parameter_value dma_csr {USE_M0_WSTRB} {1}
  set_instance_parameter_value dma_csr {USE_M0_WUSER} {1}
  set_instance_parameter_value dma_csr {USE_PIPELINE} {1}
  set_instance_parameter_value dma_csr {USE_S0_ARCACHE} {0}
  set_instance_parameter_value dma_csr {USE_S0_ARLOCK} {0}
  set_instance_parameter_value dma_csr {USE_S0_ARPROT} {0}
  set_instance_parameter_value dma_csr {USE_S0_ARQOS} {0}
  set_instance_parameter_value dma_csr {USE_S0_ARREGION} {0}
  set_instance_parameter_value dma_csr {USE_S0_ARUSER} {1}
  set_instance_parameter_value dma_csr {USE_S0_AWCACHE} {0}
  set_instance_parameter_value dma_csr {USE_S0_AWLOCK} {0}
  set_instance_parameter_value dma_csr {USE_S0_AWPROT} {0}
  set_instance_parameter_value dma_csr {USE_S0_AWQOS} {0}
  set_instance_parameter_value dma_csr {USE_S0_AWREGION} {0}
  set_instance_parameter_value dma_csr {USE_S0_AWUSER} {1}
  set_instance_parameter_value dma_csr {USE_S0_BRESP} {0}
  set_instance_parameter_value dma_csr {USE_S0_BUSER} {1}
  set_instance_parameter_value dma_csr {USE_S0_RRESP} {1}
  set_instance_parameter_value dma_csr {USE_S0_RUSER} {1}
  set_instance_parameter_value dma_csr {USE_S0_WLAST} {0}
  set_instance_parameter_value dma_csr {USE_S0_WUSER} {1}
  set_instance_parameter_value dma_csr {WRITE_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value dma_csr {WRITE_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value dma_csr {WRITE_DATA_USER_WIDTH} {1}
  set_instance_parameter_value dma_csr {WRITE_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value dma_csr {WRITE_RESP_USER_WIDTH} {1}

  add_instance ase ase 24.1

  add_instance ase_pipe_all altera_axi_bridge 19.4.0
  set_instance_parameter_value ase_pipe_all {ACE_LITE_SUPPORT} {0}
  set_instance_parameter_value ase_pipe_all {ADDR_WIDTH} {35}
  set_instance_parameter_value ase_pipe_all {AXI_VERSION} {AXI4}
  set_instance_parameter_value ase_pipe_all {BACKPRESSURE_DURING_RESET} {0}
  set_instance_parameter_value ase_pipe_all {COMBINED_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value ase_pipe_all {COMBINED_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value ase_pipe_all {DATA_WIDTH} $memory_bank_data_width
  set_instance_parameter_value ase_pipe_all {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
  set_instance_parameter_value ase_pipe_all {ENABLE_OOO} {0}
  set_instance_parameter_value ase_pipe_all {M0_ID_WIDTH} {16}
  set_instance_parameter_value ase_pipe_all {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
  set_instance_parameter_value ase_pipe_all {READ_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value ase_pipe_all {READ_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value ase_pipe_all {READ_DATA_REORDERING_DEPTH} {1}
  set_instance_parameter_value ase_pipe_all {READ_DATA_USER_WIDTH} {1}
  set_instance_parameter_value ase_pipe_all {READ_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value ase_pipe_all {S0_ID_WIDTH} {16}
  set_instance_parameter_value ase_pipe_all {SYNC_RESET} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARBURST} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARCACHE} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARID} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARLEN} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARLOCK} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARQOS} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARREGION} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARSIZE} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_ARUSER} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWBURST} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWCACHE} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWID} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWLEN} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWLOCK} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWQOS} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWREGION} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWSIZE} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_AWUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_BID} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_BRESP} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_BUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_RID} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_RLAST} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_RRESP} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_RUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_M0_WSTRB} {1}
  set_instance_parameter_value ase_pipe_all {USE_M0_WUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_PIPELINE} {1}
  set_instance_parameter_value ase_pipe_all {USE_S0_ARCACHE} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_ARLOCK} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_ARPROT} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_ARQOS} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_ARREGION} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_ARUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_AWCACHE} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_AWLOCK} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_AWPROT} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_AWQOS} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_AWREGION} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_AWUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_BRESP} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_BUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_RRESP} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_RUSER} {0}
  set_instance_parameter_value ase_pipe_all {USE_S0_WLAST} {1}
  set_instance_parameter_value ase_pipe_all {USE_S0_WUSER} {0}
  set_instance_parameter_value ase_pipe_all {WRITE_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value ase_pipe_all {WRITE_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value ase_pipe_all {WRITE_DATA_USER_WIDTH} {1}
  set_instance_parameter_value ase_pipe_all {WRITE_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value ase_pipe_all {WRITE_RESP_USER_WIDTH} {1}

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_instance ase_pipe_ddr$i altera_axi_bridge 19.4.0
    set_instance_parameter_value ase_pipe_ddr$i {ACE_LITE_SUPPORT} {0}
    set_instance_parameter_value ase_pipe_ddr$i {ADDR_WIDTH} $memory_bank_address_width
    set_instance_parameter_value ase_pipe_ddr$i {AXI_VERSION} {AXI4}
    set_instance_parameter_value ase_pipe_ddr$i {BACKPRESSURE_DURING_RESET} {0}
    set_instance_parameter_value ase_pipe_ddr$i {COMBINED_ACCEPTANCE_CAPABILITY} {1}
    set_instance_parameter_value ase_pipe_ddr$i {COMBINED_ISSUING_CAPABILITY} {1}
    set_instance_parameter_value ase_pipe_ddr$i {DATA_WIDTH} $memory_bank_data_width
    set_instance_parameter_value ase_pipe_ddr$i {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
    set_instance_parameter_value ase_pipe_ddr$i {ENABLE_OOO} {0}
    set_instance_parameter_value ase_pipe_ddr$i {M0_ID_WIDTH} {16}
    set_instance_parameter_value ase_pipe_ddr$i {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
    set_instance_parameter_value ase_pipe_ddr$i {READ_ACCEPTANCE_CAPABILITY} {1}
    set_instance_parameter_value ase_pipe_ddr$i {READ_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value ase_pipe_ddr$i {READ_DATA_REORDERING_DEPTH} {1}
    set_instance_parameter_value ase_pipe_ddr$i {READ_DATA_USER_WIDTH} {2}
    set_instance_parameter_value ase_pipe_ddr$i {READ_ISSUING_CAPABILITY} {1}
    set_instance_parameter_value ase_pipe_ddr$i {S0_ID_WIDTH} {16}
    set_instance_parameter_value ase_pipe_ddr$i {SYNC_RESET} {0}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARBURST} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARCACHE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARID} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARLEN} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARLOCK} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARQOS} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARREGION} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARSIZE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_ARUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWBURST} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWCACHE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWID} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWLEN} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWLOCK} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWQOS} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWREGION} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWSIZE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_AWUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_BID} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_BRESP} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_BUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_RID} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_RLAST} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_RRESP} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_RUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_WSTRB} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_M0_WUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_PIPELINE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_ARCACHE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_ARLOCK} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_ARPROT} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_ARQOS} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_ARREGION} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_ARUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_AWCACHE} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_AWLOCK} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_AWPROT} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_AWQOS} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_AWREGION} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_AWUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_BRESP} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_BUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_RRESP} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_RUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_WLAST} {1}
    set_instance_parameter_value ase_pipe_ddr$i {USE_S0_WUSER} {1}
    set_instance_parameter_value ase_pipe_ddr$i {WRITE_ACCEPTANCE_CAPABILITY} {1}
    set_instance_parameter_value ase_pipe_ddr$i {WRITE_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value ase_pipe_ddr$i {WRITE_DATA_USER_WIDTH} {2}
    set_instance_parameter_value ase_pipe_ddr$i {WRITE_ISSUING_CAPABILITY} {1}
    set_instance_parameter_value ase_pipe_ddr$i {WRITE_RESP_USER_WIDTH} {2}
  }

  add_instance dla_csr_pipe_all altera_axi_bridge 19.4.0
  set_instance_parameter_value dla_csr_pipe_all {ACE_LITE_SUPPORT} {0}
  set_instance_parameter_value dla_csr_pipe_all {ADDR_WIDTH} {16}
  set_instance_parameter_value dla_csr_pipe_all {AXI_VERSION} {AXI4}
  set_instance_parameter_value dla_csr_pipe_all {BACKPRESSURE_DURING_RESET} {0}
  set_instance_parameter_value dla_csr_pipe_all {COMBINED_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value dla_csr_pipe_all {COMBINED_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value dla_csr_pipe_all {DATA_WIDTH} $mmio_data_width
  set_instance_parameter_value dla_csr_pipe_all {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
  set_instance_parameter_value dla_csr_pipe_all {ENABLE_OOO} {0}
  set_instance_parameter_value dla_csr_pipe_all {M0_ID_WIDTH} {18}
  set_instance_parameter_value dla_csr_pipe_all {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
  set_instance_parameter_value dla_csr_pipe_all {READ_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value dla_csr_pipe_all {READ_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value dla_csr_pipe_all {READ_DATA_REORDERING_DEPTH} {1}
  set_instance_parameter_value dla_csr_pipe_all {READ_DATA_USER_WIDTH} {1}
  set_instance_parameter_value dla_csr_pipe_all {READ_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value dla_csr_pipe_all {S0_ID_WIDTH} {18}
  set_instance_parameter_value dla_csr_pipe_all {SYNC_RESET} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARBURST} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARCACHE} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARID} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARLEN} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARLOCK} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARQOS} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARREGION} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARSIZE} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_ARUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWBURST} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWCACHE} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWID} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWLEN} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWLOCK} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWQOS} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWREGION} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWSIZE} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_AWUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_BID} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_BRESP} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_BUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_RID} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_RLAST} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_RRESP} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_RUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_WSTRB} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_M0_WUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_PIPELINE} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_ARCACHE} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_ARLOCK} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_ARPROT} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_ARQOS} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_ARREGION} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_ARUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_AWCACHE} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_AWLOCK} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_AWPROT} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_AWQOS} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_AWREGION} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_AWUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_BRESP} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_BUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_RRESP} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_RUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_WLAST} {0}
  set_instance_parameter_value dla_csr_pipe_all {USE_S0_WUSER} {1}
  set_instance_parameter_value dla_csr_pipe_all {WRITE_ACCEPTANCE_CAPABILITY} {1}
  set_instance_parameter_value dla_csr_pipe_all {WRITE_ADDR_USER_WIDTH} {1}
  set_instance_parameter_value dla_csr_pipe_all {WRITE_DATA_USER_WIDTH} {1}
  set_instance_parameter_value dla_csr_pipe_all {WRITE_ISSUING_CAPABILITY} {1}
  set_instance_parameter_value dla_csr_pipe_all {WRITE_RESP_USER_WIDTH} {1}

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_instance dla_csr$i altera_axi_bridge 19.4.0
    set_instance_parameter_value dla_csr$i {ACE_LITE_SUPPORT} {0}
    set_instance_parameter_value dla_csr$i {ADDR_WIDTH} {11}
    set_instance_parameter_value dla_csr$i {AXI_VERSION} {AXI4-Lite}
    set_instance_parameter_value dla_csr$i {BACKPRESSURE_DURING_RESET} {0}
    set_instance_parameter_value dla_csr$i {COMBINED_ACCEPTANCE_CAPABILITY} {1}
    set_instance_parameter_value dla_csr$i {COMBINED_ISSUING_CAPABILITY} {1}
    set_instance_parameter_value dla_csr$i {DATA_WIDTH} 32
    set_instance_parameter_value dla_csr$i {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
    set_instance_parameter_value dla_csr$i {ENABLE_OOO} {0}
    set_instance_parameter_value dla_csr$i {M0_ID_WIDTH} {18}
    set_instance_parameter_value dla_csr$i {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
    set_instance_parameter_value dla_csr$i {READ_ACCEPTANCE_CAPABILITY} {1}
    set_instance_parameter_value dla_csr$i {READ_ADDR_USER_WIDTH} {1}
    set_instance_parameter_value dla_csr$i {READ_DATA_REORDERING_DEPTH} {1}
    set_instance_parameter_value dla_csr$i {READ_DATA_USER_WIDTH} {1}
    set_instance_parameter_value dla_csr$i {READ_ISSUING_CAPABILITY} {1}
    set_instance_parameter_value dla_csr$i {S0_ID_WIDTH} {18}
    set_instance_parameter_value dla_csr$i {SYNC_RESET} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARBURST} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARCACHE} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARID} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARLEN} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARLOCK} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARQOS} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARREGION} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARSIZE} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_ARUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWBURST} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWCACHE} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWID} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWLEN} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWLOCK} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWQOS} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWREGION} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWSIZE} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_AWUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_BID} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_BRESP} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_BUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_RID} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_RLAST} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_RRESP} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_RUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_WSTRB} {0}
    set_instance_parameter_value dla_csr$i {USE_M0_WUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_PIPELINE} {1}
    set_instance_parameter_value dla_csr$i {USE_S0_ARCACHE} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_ARLOCK} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_ARPROT} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_ARQOS} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_ARREGION} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_ARUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_AWCACHE} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_AWLOCK} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_AWPROT} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_AWQOS} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_AWREGION} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_AWUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_BRESP} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_BUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_RRESP} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_RUSER} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_WLAST} {0}
    set_instance_parameter_value dla_csr$i {USE_S0_WUSER} {0}
    set_instance_parameter_value dla_csr$i {WRITE_ACCEPTANCE_CAPABILITY} {1}
    set_instance_parameter_value dla_csr$i {WRITE_ADDR_USER_WIDTH} {1}
    set_instance_parameter_value dla_csr$i {WRITE_DATA_USER_WIDTH} {1}
    set_instance_parameter_value dla_csr$i {WRITE_ISSUING_CAPABILITY} {1}
    set_instance_parameter_value dla_csr$i {WRITE_RESP_USER_WIDTH} {1}
  }

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_instance dla_ddr_in$i altera_axi_bridge 19.4.0
    set_instance_parameter_value dla_ddr_in$i {ACE_LITE_SUPPORT} {0}
    set_instance_parameter_value dla_ddr_in$i {ADDR_WIDTH} $memory_bank_address_width
    set_instance_parameter_value dla_ddr_in$i {AXI_VERSION} {AXI4}
    set_instance_parameter_value dla_ddr_in$i {BACKPRESSURE_DURING_RESET} {0}
    set_instance_parameter_value dla_ddr_in$i {COMBINED_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value dla_ddr_in$i {COMBINED_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value dla_ddr_in$i {DATA_WIDTH} $memory_bank_data_width
    set_instance_parameter_value dla_ddr_in$i {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
    set_instance_parameter_value dla_ddr_in$i {ENABLE_OOO} {0}
    set_instance_parameter_value dla_ddr_in$i {M0_ID_WIDTH} {16}
    set_instance_parameter_value dla_ddr_in$i {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
    set_instance_parameter_value dla_ddr_in$i {READ_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value dla_ddr_in$i {READ_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value dla_ddr_in$i {READ_DATA_REORDERING_DEPTH} {1}
    set_instance_parameter_value dla_ddr_in$i {READ_DATA_USER_WIDTH} {2}
    set_instance_parameter_value dla_ddr_in$i {READ_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value dla_ddr_in$i {S0_ID_WIDTH} {16}
    set_instance_parameter_value dla_ddr_in$i {SYNC_RESET} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARBURST} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARCACHE} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARID} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARLEN} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARLOCK} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARQOS} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARREGION} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARSIZE} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_ARUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWBURST} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWCACHE} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWID} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWLEN} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWLOCK} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWQOS} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWREGION} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWSIZE} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_AWUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_BID} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_BRESP} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_BUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_RID} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_RLAST} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_RRESP} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_RUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_WSTRB} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_M0_WUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_PIPELINE} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_ARCACHE} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_ARLOCK} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_ARPROT} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_ARQOS} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_ARREGION} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_ARUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_AWCACHE} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_AWLOCK} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_AWPROT} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_AWQOS} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_AWREGION} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_AWUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_BRESP} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_BUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_RRESP} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_RUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_WLAST} {1}
    set_instance_parameter_value dla_ddr_in$i {USE_S0_WUSER} {0}
    set_instance_parameter_value dla_ddr_in$i {WRITE_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value dla_ddr_in$i {WRITE_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value dla_ddr_in$i {WRITE_DATA_USER_WIDTH} {2}
    set_instance_parameter_value dla_ddr_in$i {WRITE_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value dla_ddr_in$i {WRITE_RESP_USER_WIDTH} {2}
  }

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_instance dma_ddr_in$i altera_axi_bridge 19.4.0
    set_instance_parameter_value dma_ddr_in$i {ACE_LITE_SUPPORT} {0}
    set_instance_parameter_value dma_ddr_in$i {ADDR_WIDTH} $memory_bank_address_width
    set_instance_parameter_value dma_ddr_in$i {AXI_VERSION} {AXI4}
    set_instance_parameter_value dma_ddr_in$i {BACKPRESSURE_DURING_RESET} {0}
    set_instance_parameter_value dma_ddr_in$i {COMBINED_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value dma_ddr_in$i {COMBINED_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value dma_ddr_in$i {DATA_WIDTH} $memory_bank_data_width
    set_instance_parameter_value dma_ddr_in$i {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
    set_instance_parameter_value dma_ddr_in$i {ENABLE_OOO} {0}
    set_instance_parameter_value dma_ddr_in$i {M0_ID_WIDTH} {16}
    set_instance_parameter_value dma_ddr_in$i {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
    set_instance_parameter_value dma_ddr_in$i {READ_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value dma_ddr_in$i {READ_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value dma_ddr_in$i {READ_DATA_REORDERING_DEPTH} {1}
    set_instance_parameter_value dma_ddr_in$i {READ_DATA_USER_WIDTH} {2}
    set_instance_parameter_value dma_ddr_in$i {READ_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value dma_ddr_in$i {S0_ID_WIDTH} {16}
    set_instance_parameter_value dma_ddr_in$i {SYNC_RESET} {0}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARBURST} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARCACHE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARID} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARLEN} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARLOCK} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARQOS} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARREGION} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARSIZE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_ARUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWBURST} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWCACHE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWID} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWLEN} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWLOCK} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWQOS} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWREGION} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWSIZE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_AWUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_BID} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_BRESP} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_BUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_RID} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_RLAST} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_RRESP} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_RUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_WSTRB} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_M0_WUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_PIPELINE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_ARCACHE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_ARLOCK} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_ARPROT} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_ARQOS} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_ARREGION} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_ARUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_AWCACHE} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_AWLOCK} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_AWPROT} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_AWQOS} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_AWREGION} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_AWUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_BRESP} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_BUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_RRESP} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_RUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_WLAST} {1}
    set_instance_parameter_value dma_ddr_in$i {USE_S0_WUSER} {1}
    set_instance_parameter_value dma_ddr_in$i {WRITE_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value dma_ddr_in$i {WRITE_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value dma_ddr_in$i {WRITE_DATA_USER_WIDTH} {2}
    set_instance_parameter_value dma_ddr_in$i {WRITE_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value dma_ddr_in$i {WRITE_RESP_USER_WIDTH} {2}
  }

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_instance mux_ddr_out$i altera_axi_bridge 19.4.0
    set_instance_parameter_value mux_ddr_out$i {ACE_LITE_SUPPORT} {0}
    set_instance_parameter_value mux_ddr_out$i {ADDR_WIDTH} $memory_bank_address_width
    set_instance_parameter_value mux_ddr_out$i {AXI_VERSION} {AXI4}
    set_instance_parameter_value mux_ddr_out$i {BACKPRESSURE_DURING_RESET} {0}
    set_instance_parameter_value mux_ddr_out$i {COMBINED_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value mux_ddr_out$i {COMBINED_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value mux_ddr_out$i {DATA_WIDTH} $memory_bank_data_width
    set_instance_parameter_value mux_ddr_out$i {ENABLE_CONCURRENT_SUBORDINATE_ACCESS} {0}
    set_instance_parameter_value mux_ddr_out$i {ENABLE_OOO} {0}
    set_instance_parameter_value mux_ddr_out$i {M0_ID_WIDTH} {18}
    set_instance_parameter_value mux_ddr_out$i {NO_REPEATED_IDS_BETWEEN_SUBORDINATES} {0}
    set_instance_parameter_value mux_ddr_out$i {READ_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value mux_ddr_out$i {READ_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value mux_ddr_out$i {READ_DATA_REORDERING_DEPTH} {1}
    set_instance_parameter_value mux_ddr_out$i {READ_DATA_USER_WIDTH} {2}
    set_instance_parameter_value mux_ddr_out$i {READ_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value mux_ddr_out$i {S0_ID_WIDTH} {18}
    set_instance_parameter_value mux_ddr_out$i {SYNC_RESET} {0}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARBURST} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARCACHE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARID} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARLEN} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARLOCK} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARQOS} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARREGION} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARSIZE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_ARUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWBURST} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWCACHE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWID} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWLEN} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWLOCK} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWQOS} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWREGION} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWSIZE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_AWUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_BID} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_BRESP} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_BUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_RID} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_RLAST} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_RRESP} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_RUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_WSTRB} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_M0_WUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_PIPELINE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_ARCACHE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_ARLOCK} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_ARPROT} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_ARQOS} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_ARREGION} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_ARUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_AWCACHE} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_AWLOCK} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_AWPROT} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_AWQOS} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_AWREGION} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_AWUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_BRESP} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_BUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_RRESP} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_RUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_WLAST} {1}
    set_instance_parameter_value mux_ddr_out$i {USE_S0_WUSER} {1}
    set_instance_parameter_value mux_ddr_out$i {WRITE_ACCEPTANCE_CAPABILITY} {64}
    set_instance_parameter_value mux_ddr_out$i {WRITE_ADDR_USER_WIDTH} {2}
    set_instance_parameter_value mux_ddr_out$i {WRITE_DATA_USER_WIDTH} {2}
    set_instance_parameter_value mux_ddr_out$i {WRITE_ISSUING_CAPABILITY} {64}
    set_instance_parameter_value mux_ddr_out$i {WRITE_RESP_USER_WIDTH} {2}
  }

  add_instance dla_hw_timer_wrapper altera_avalon_mm_bridge 20.1.0
  set_instance_parameter_value dla_hw_timer_wrapper {DATA_WIDTH} {32}
  set_instance_parameter_value dla_hw_timer_wrapper {SYMBOL_WIDTH} {8}
  set_instance_parameter_value dla_hw_timer_wrapper {ADDRESS_WIDTH} {11}
  set_instance_parameter_value dla_hw_timer_wrapper {ADDRESS_UNITS} {SYMBOLS}
  set_instance_parameter_value dla_hw_timer_wrapper {MAX_BURST_SIZE} {1}
  set_instance_parameter_value dla_hw_timer_wrapper {MAX_PENDING_RESPONSES} {1}
  set_instance_parameter_value dla_hw_timer_wrapper {LINEWRAPBURSTS} {0}
  set_instance_parameter_value dla_hw_timer_wrapper {PIPELINE_COMMAND} {1}
  set_instance_parameter_value dla_hw_timer_wrapper {PIPELINE_RESPONSE} {1}
  set_instance_parameter_value dla_hw_timer_wrapper {SYNC_RESET} {0}

  add_instance dla_hw_timer mm_ccb 19.2.1
  set_instance_parameter_value dla_hw_timer {ADDRESS_UNITS} {SYMBOLS}
  set_instance_parameter_value dla_hw_timer {ADDRESS_WIDTH} {11}
  set_instance_parameter_value dla_hw_timer {COMMAND_FIFO_DEPTH} {32}
  set_instance_parameter_value dla_hw_timer {DATA_WIDTH} {32}
  set_instance_parameter_value dla_hw_timer {MASTER_SYNC_DEPTH} {2}
  set_instance_parameter_value dla_hw_timer {MAX_BURST_SIZE} {1}
  set_instance_parameter_value dla_hw_timer {RESPONSE_FIFO_DEPTH} {32}
  set_instance_parameter_value dla_hw_timer {SLAVE_SYNC_DEPTH} {2}
  set_instance_parameter_value dla_hw_timer {SYMBOL_WIDTH} {8}
  set_instance_parameter_value dla_hw_timer {SYNC_RESET} {0}
  set_instance_parameter_value dla_hw_timer {USE_AUTO_ADDRESS_WIDTH} {0}

  # Connections and connection parameters
  # Clocks
  add_connection pcie_clk_in.out_clk reset_in.clk clock
  add_connection pcie_clk_in.out_clk mmio_control.clk clock
  add_connection pcie_clk_in.out_clk dma_csr.clk clock
  add_connection pcie_clk_in.out_clk dla_csr_pipe_all.clk clock
  add_connection pcie_clk_in.out_clk ase.clk clock
  add_connection pcie_clk_in.out_clk ase_pipe_all.clk clock
  add_connection pcie_clk_in.out_clk dla_hw_timer_wrapper.clk clock
  add_connection pcie_clk_in.out_clk dla_hw_timer.s0_clk clock
  add_connection pcie_clk_in.out_clk sw_reset.clk clock
  add_connection dla_clk_in.out_clk dla_reset_in.clk clock
  add_connection dla_clk_in.out_clk dla_hw_timer.m0_clk clock

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_connection pcie_clk_in.out_clk dla_csr$i.clk clock
    add_connection pcie_clk_in.out_clk ase_pipe_ddr$i.clk clock
    add_connection pcie_clk_in.out_clk dla_ddr_in$i.clk clock
    add_connection pcie_clk_in.out_clk dma_ddr_in$i.clk clock
    add_connection pcie_clk_in.out_clk mux_ddr_out$i.clk clock
  }

  # Resets
  add_connection reset_in.out_reset mmio_control.clk_reset reset
  add_connection reset_in.out_reset dma_csr.clk_reset reset
  add_connection reset_in.out_reset dla_csr_pipe_all.clk_reset reset
  add_connection reset_in.out_reset ase.reset reset
  add_connection reset_in.out_reset ase_pipe_all.clk_reset reset
  add_connection reset_in.out_reset dla_hw_timer_wrapper.reset reset
  add_connection reset_in.out_reset dla_hw_timer.s0_reset reset
  add_connection reset_in.out_reset sw_reset.clk_reset reset
  add_connection dla_reset_in.out_reset dla_hw_timer.m0_reset reset

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_connection reset_in.out_reset_1 dla_csr$i.clk_reset reset
    add_connection reset_in.out_reset_2 ase_pipe_ddr$i.clk_reset reset
    add_connection reset_in.out_reset_3 dla_ddr_in$i.clk_reset reset
    add_connection reset_in.out_reset_4 dma_ddr_in$i.clk_reset reset
    add_connection reset_in.out_reset_5 mux_ddr_out$i.clk_reset reset
  }

  # Data
  add_connection mmio_control.m0/dma_csr.s0 
  set_connection_parameter_value mmio_control.m0/dma_csr.s0 arbitrationPriority {1}
  set_connection_parameter_value mmio_control.m0/dma_csr.s0 baseAddress {0x0}
  set_connection_parameter_value mmio_control.m0/dma_csr.s0 defaultConnection {0}

  add_connection mmio_control.m0/dla_csr_pipe_all.s0 
  set_connection_parameter_value mmio_control.m0/dla_csr_pipe_all.s0 arbitrationPriority {1}
  set_connection_parameter_value mmio_control.m0/dla_csr_pipe_all.s0 baseAddress {0x10000}
  set_connection_parameter_value mmio_control.m0/dla_csr_pipe_all.s0 defaultConnection {0}

  add_connection mmio_control.m0/ase.avmm_pipe_slave 
  set_connection_parameter_value mmio_control.m0/ase.avmm_pipe_slave arbitrationPriority {1}
  set_connection_parameter_value mmio_control.m0/ase.avmm_pipe_slave baseAddress {0x20000}
  set_connection_parameter_value mmio_control.m0/ase.avmm_pipe_slave defaultConnection {0}

  add_connection mmio_control.m0/dla_hw_timer_wrapper.s0 
  set_connection_parameter_value mmio_control.m0/dla_hw_timer_wrapper.s0 arbitrationPriority {1}
  set_connection_parameter_value mmio_control.m0/dla_hw_timer_wrapper.s0 baseAddress {0x37000}
  set_connection_parameter_value mmio_control.m0/dla_hw_timer_wrapper.s0 defaultConnection {0}

  add_connection mmio_control.m0/sw_reset.s
  set_connection_parameter_value mmio_control.m0/sw_reset.s arbitrationPriority {1}
  set_connection_parameter_value mmio_control.m0/sw_reset.s baseAddress {0x40000}
  set_connection_parameter_value mmio_control.m0/sw_reset.s defaultConnection {0}

  add_connection dla_hw_timer_wrapper.m0/dla_hw_timer.s0 
  set_connection_parameter_value dla_hw_timer_wrapper.m0/dla_hw_timer.s0 arbitrationPriority {1}
  set_connection_parameter_value dla_hw_timer_wrapper.m0/dla_hw_timer.s0 baseAddress {0x0}
  set_connection_parameter_value dla_hw_timer_wrapper.m0/dla_hw_timer.s0 defaultConnection {0}

  add_connection dla_csr_pipe_all.m0/dla_csr0.s0 
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr0.s0 arbitrationPriority {1}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr0.s0 baseAddress {0x0}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr0.s0 defaultConnection {0}

  add_connection dla_csr_pipe_all.m0/dla_csr1.s0 
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr1.s0 arbitrationPriority {1}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr1.s0 baseAddress {0x800}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr1.s0 defaultConnection {0}

  add_connection dla_csr_pipe_all.m0/dla_csr2.s0 
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr2.s0 arbitrationPriority {1}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr2.s0 baseAddress {0x1000}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr2.s0 defaultConnection {0}

  add_connection dla_csr_pipe_all.m0/dla_csr3.s0 
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr3.s0 arbitrationPriority {1}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr3.s0 baseAddress {0x1800}
  set_connection_parameter_value dla_csr_pipe_all.m0/dla_csr3.s0 defaultConnection {0}

  add_connection ase.expanded_master/ase_pipe_all.s0
  set_connection_parameter_value ase.expanded_master/ase_pipe_all.s0 arbitrationPriority {1}
  set_connection_parameter_value ase.expanded_master/ase_pipe_all.s0 baseAddress {0x0}
  set_connection_parameter_value ase.expanded_master/ase_pipe_all.s0 defaultConnection {0}

  add_connection ase_pipe_all.m0/ase_pipe_ddr0.s0
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr0.s0 arbitrationPriority {1}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr0.s0 baseAddress {0x0}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr0.s0 defaultConnection {0}

  add_connection ase_pipe_all.m0/ase_pipe_ddr1.s0
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr1.s0 arbitrationPriority {1}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr1.s0 baseAddress {0x200000000}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr1.s0 defaultConnection {0}

  add_connection ase_pipe_all.m0/ase_pipe_ddr2.s0
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr2.s0 arbitrationPriority {1}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr2.s0 baseAddress {0x400000000}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr2.s0 defaultConnection {0}

  add_connection ase_pipe_all.m0/ase_pipe_ddr3.s0
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr3.s0 arbitrationPriority {1}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr3.s0 baseAddress {0x600000000}
  set_connection_parameter_value ase_pipe_all.m0/ase_pipe_ddr3.s0 defaultConnection {0}

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_connection dla_ddr_in$i.m0/mux_ddr_out$i.s0
    set_connection_parameter_value dla_ddr_in$i.m0/mux_ddr_out$i.s0 arbitrationPriority {1}
    set_connection_parameter_value dla_ddr_in$i.m0/mux_ddr_out$i.s0 baseAddress {0x0}
    set_connection_parameter_value dla_ddr_in$i.m0/mux_ddr_out$i.s0 defaultConnection {0}

    add_connection dma_ddr_in$i.m0/mux_ddr_out$i.s0
    set_connection_parameter_value dma_ddr_in$i.m0/mux_ddr_out$i.s0 arbitrationPriority {1}
    set_connection_parameter_value dma_ddr_in$i.m0/mux_ddr_out$i.s0 baseAddress {0x0}
    set_connection_parameter_value dma_ddr_in$i.m0/mux_ddr_out$i.s0 defaultConnection {0}

    add_connection ase_pipe_ddr$i.m0/mux_ddr_out$i.s0
    set_connection_parameter_value ase_pipe_ddr$i.m0/mux_ddr_out$i.s0 arbitrationPriority {1}
    set_connection_parameter_value ase_pipe_ddr$i.m0/mux_ddr_out$i.s0 baseAddress {0x0}
    set_connection_parameter_value ase_pipe_ddr$i.m0/mux_ddr_out$i.s0 defaultConnection {0}
  }

  # Exported interfaces
  # Clocks
  add_interface clk clock sink
  set_interface_property clk EXPORT_OF pcie_clk_in.in_clk

  add_interface dla_clk clock sink
  set_interface_property dla_clk EXPORT_OF dla_clk_in.in_clk

  # Resets
  add_interface reset reset sink
  set_interface_property reset EXPORT_OF reset_in.in_reset

  add_interface dla_reset reset sink
  set_interface_property dla_reset EXPORT_OF dla_reset_in.in_reset

  add_interface sw_reset reset source
  set_interface_property sw_reset EXPORT_OF sw_reset.sw_reset 

  # Data
  add_interface mmio_control axi4 slave
  set_interface_property mmio_control EXPORT_OF mmio_control.s0
  add_interface dma_csr axi4 master
  set_interface_property dma_csr EXPORT_OF dma_csr.m0
  add_interface dla_hw_timer avalon master
  set_interface_property dla_hw_timer EXPORT_OF dla_hw_timer.m0

  for { set i 0} { $i < $number_of_memory_banks} {incr i} {
    add_interface dla_csr$i axi4lite master
    set_interface_property dla_csr$i EXPORT_OF dla_csr$i.m0

    add_interface dma_ddr_in$i axi4 slave
    set_interface_property dma_ddr_in$i EXPORT_OF dma_ddr_in$i.s0

    add_interface dla_ddr_in$i axi4 slave
    set_interface_property dla_ddr_in$i EXPORT_OF dla_ddr_in$i.s0

    add_interface mux_ddr_out$i axi4 master
    set_interface_property mux_ddr_out$i EXPORT_OF mux_ddr_out$i.m0
  }

  # Interconnect requirements
  set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {FIFO}
  set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {2}
}


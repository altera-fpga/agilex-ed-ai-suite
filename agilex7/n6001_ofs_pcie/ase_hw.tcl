package require -exact qsys 17.0

# module properties
set_module_property NAME {ase}
set_module_property DISPLAY_NAME {DLA Address Span Extender System}
set_module_property VERSION {24.1}
set_module_property GROUP {DLA System Components}
set_module_property DESCRIPTION {Address span extender system for windowed access to the FPGA DDR address space}
set_module_property AUTHOR {DLA}
set_module_property COMPOSITION_CALLBACK compose

proc compose { } {
  # Instances and instance parameters
  add_instance clock_in altera_clock_bridge 19.2.0
  set_instance_parameter_value clock_in {EXPLICIT_CLOCK_RATE} {0.0}
  set_instance_parameter_value clock_in {NUM_CLOCK_OUTPUTS} {1}

  add_instance reset_in altera_reset_bridge 19.2.0
  set_instance_parameter_value reset_in {ACTIVE_LOW_RESET} {0}
  set_instance_parameter_value reset_in {SYNCHRONOUS_EDGES} {deassert}
  set_instance_parameter_value reset_in {NUM_RESET_OUTPUTS} {1} 
  set_instance_parameter_value reset_in {SYNC_RESET} {0}
  set_instance_parameter_value reset_in {USE_RESET_REQUEST} {0}

  add_instance ase_avmm_pipe altera_avalon_mm_bridge 20.1.0
  set_instance_parameter_value ase_avmm_pipe {ADDRESS_UNITS} {SYMBOLS}
  set_instance_parameter_value ase_avmm_pipe {ADDRESS_WIDTH} {18}
  set_instance_parameter_value ase_avmm_pipe {DATA_WIDTH} {64}
  set_instance_parameter_value ase_avmm_pipe {LINEWRAPBURSTS} {0}
  set_instance_parameter_value ase_avmm_pipe {M0_WAITREQUEST_ALLOWANCE} {0}
  set_instance_parameter_value ase_avmm_pipe {MAX_BURST_SIZE} {1}
  set_instance_parameter_value ase_avmm_pipe {MAX_PENDING_RESPONSES} {1}
  set_instance_parameter_value ase_avmm_pipe {MAX_PENDING_WRITES} {0}
  set_instance_parameter_value ase_avmm_pipe {PIPELINE_COMMAND} {1}
  set_instance_parameter_value ase_avmm_pipe {PIPELINE_RESPONSE} {1}
  set_instance_parameter_value ase_avmm_pipe {S0_WAITREQUEST_ALLOWANCE} {0}
  set_instance_parameter_value ase_avmm_pipe {SYMBOL_WIDTH} {8}
  set_instance_parameter_value ase_avmm_pipe {SYNC_RESET} {0}
  set_instance_parameter_value ase_avmm_pipe {USE_AUTO_ADDRESS_WIDTH} {1}
  set_instance_parameter_value ase_avmm_pipe {USE_RESPONSE} {0}
  set_instance_parameter_value ase_avmm_pipe {USE_WRITERESPONSE} {0}

  add_instance afu_id_avmm_slave afu_id_avmm_slave 1.0
  set_instance_parameter_value afu_id_avmm_slave {AFU_ID_H} {8229331300211835173}
  set_instance_parameter_value afu_id_avmm_slave {AFU_ID_L} {4911816603464716388}
  set_instance_parameter_value afu_id_avmm_slave {CREATE_SCRATCH_REG} {0}
  set_instance_parameter_value afu_id_avmm_slave {DFH_AFU_MAJOR_REV} {0}
  set_instance_parameter_value afu_id_avmm_slave {DFH_AFU_MINOR_REV} {0}
  set_instance_parameter_value afu_id_avmm_slave {DFH_END_OF_LIST} {0}
  set_instance_parameter_value afu_id_avmm_slave {DFH_FEATURE_ID} {0}
  set_instance_parameter_value afu_id_avmm_slave {DFH_FEATURE_TYPE} {2}
  set_instance_parameter_value afu_id_avmm_slave {DFH_NEXT_OFFSET} {65536}
  set_instance_parameter_value afu_id_avmm_slave {NEXT_AFU_OFFSET} {0}

  add_instance address_span_extender altera_address_span_extender 19.2.0
  set_instance_parameter_value address_span_extender {BURSTCOUNT_WIDTH} {4}
  set_instance_parameter_value address_span_extender {DATA_WIDTH} {512}
  set_instance_parameter_value address_span_extender {ENABLE_SLAVE_PORT} {1}
  set_instance_parameter_value address_span_extender {MASTER_ADDRESS_DEF} {0}
  set_instance_parameter_value address_span_extender {MASTER_ADDRESS_WIDTH} {48}
  set_instance_parameter_value address_span_extender {MAX_PENDING_READS} {16}
  set_instance_parameter_value address_span_extender {SLAVE_ADDRESS_WIDTH} {6}
  set_instance_parameter_value address_span_extender {SUB_WINDOW_COUNT} {1}
  set_instance_parameter_value address_span_extender {SYNC_RESET} {0}

  # Connections and connection parameters
  # Clocks
  add_connection clock_in.out_clk reset_in.clk clock
  add_connection clock_in.out_clk ase_avmm_pipe.clk clock
  add_connection clock_in.out_clk afu_id_avmm_slave.clock clock
  add_connection clock_in.out_clk address_span_extender.clock clock

  # Resets
  add_connection reset_in.out_reset ase_avmm_pipe.reset reset
  add_connection reset_in.out_reset afu_id_avmm_slave.reset reset
  add_connection reset_in.out_reset address_span_extender.reset reset

  # Data
  add_connection ase_avmm_pipe.m0/afu_id_avmm_slave.afu_cfg_slave
  set_connection_parameter_value ase_avmm_pipe.m0/afu_id_avmm_slave.afu_cfg_slave arbitrationPriority {1}
  set_connection_parameter_value ase_avmm_pipe.m0/afu_id_avmm_slave.afu_cfg_slave baseAddress {0x0}
  set_connection_parameter_value ase_avmm_pipe.m0/afu_id_avmm_slave.afu_cfg_slave defaultConnection {0}

  add_connection ase_avmm_pipe.m0/address_span_extender.cntl
  set_connection_parameter_value ase_avmm_pipe.m0/address_span_extender.cntl arbitrationPriority {1}
  set_connection_parameter_value ase_avmm_pipe.m0/address_span_extender.cntl baseAddress {0x200}
  set_connection_parameter_value ase_avmm_pipe.m0/address_span_extender.cntl defaultConnection {0}

  add_connection ase_avmm_pipe.m0/address_span_extender.windowed_slave
  set_connection_parameter_value ase_avmm_pipe.m0/address_span_extender.windowed_slave arbitrationPriority {1}
  set_connection_parameter_value ase_avmm_pipe.m0/address_span_extender.windowed_slave baseAddress {0x1000}
  set_connection_parameter_value ase_avmm_pipe.m0/address_span_extender.windowed_slave defaultConnection {0} 

  # Exported interfaces
  # Clocks
  add_interface clk clock sink
  set_interface_property clk EXPORT_OF clock_in.in_clk

  # Resets
  add_interface reset reset sink
  set_interface_property reset EXPORT_OF reset_in.in_reset
 
  # Data
  add_interface avmm_pipe_slave avalon slave
  set_interface_property avmm_pipe_slave EXPORT_OF ase_avmm_pipe.s0

  add_interface expanded_master avalon master
  set_interface_property expanded_master EXPORT_OF address_span_extender.expanded_master

  # Interconnect requirements
  set_interconnect_requirement {$system} {qsys_mm.clockCrossingAdapter} {HANDSHAKE}
  set_interconnect_requirement {$system} {qsys_mm.maxAdditionalLatency} {0}
}


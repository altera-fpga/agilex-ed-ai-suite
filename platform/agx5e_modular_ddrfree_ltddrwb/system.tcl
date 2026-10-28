# Hybrid VDS systems for agx5e_modular_ddrfree_ltddrwb:
#   - board  (from agx5e_modular_ddrfree system.tcl / smoke board export)
#   - emif   (from smoke vds_emif_design_export.tcl)
# setup_project.sh patches st_adapter outDataWidth {INPUT_DATA_WIDTH}.
load_package vds
# project_new top
# 
# Info: Current script was exported with Quartus Prime Pro Release 26.3.0 Build 86
# 
regexp {[\.0-9]+} $quartus(version) import_release
if {$import_release != "26.3.0"} {
	post_message -type error "Cannot import script exported from Quartus Prime Pro version \"26.3.0 Build 86\" into current release \"$import_release\".\n\tOpen, upgrade, and validate the original system in VDS to ensure design correctness."
	return
}
proc get_current_hier {} {
set current_hier [vds::get_current_hier]
if {$current_hier == "|"} {
	set current_hier ""
}
return $current_hier
}

set proj_dir [get_project_directory]
vds::create_system board -force
vds::create_cell -properties { parameters:ADDRESS_WIDTH {11} parameters:MAX_PENDING_RESPONSES {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: board_hw_timer
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {600000000}  } -vlnv altera.com:ip:altera_clock_bridge: board_kernel_clk
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: board_sys_clk
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: clock_in
vds::create_cell dla_csr_bridge_0 -type ip -files $proj_dir/src/ip/dla_csr_axi_bridge.ip
vds::create_cell dla_csr_bridge_1 -type ip -files $proj_dir/src/ip/dla_csr_axi_bridge.ip
vds::create_cell dla_csr_bridge_2 -type ip -files $proj_dir/src/ip/dla_csr_axi_bridge.ip
vds::create_cell dla_csr_bridge_3 -type ip -files $proj_dir/src/ip/dla_csr_axi_bridge.ip
vds::create_cell -properties { parameters:DATA_FIFO_DEPTH {128} parameters:DATA_WIDTH {128} parameters:DESCRIPTOR_FIFO_DEPTH {32} parameters:MAX_BYTE {131072} parameters:MODE {2} parameters:TRANSFER_TYPE {Full Word Accesses Only}  } -vlnv altera.com:ip:altera_msgdma: egress_msgdma
vds::create_cell -properties { parameters:dualPort {1} parameters:memorySize {131072}  } -vlnv altera.com:ip:intel_onchip_memory: egress_onchip_memory
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: global_reset_in
vds::create_cell -properties { parameters:ADDRESS_WIDTH {11} parameters:MAX_PENDING_RESPONSES {1}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: hw_timer_addr_decode
vds::create_cell -properties { parameters:DATA_FIFO_DEPTH {128} parameters:DATA_WIDTH {128} parameters:DESCRIPTOR_FIFO_DEPTH {32} parameters:MAX_BYTE {524288} parameters:MODE {1} parameters:TRANSFER_TYPE {Full Word Accesses Only}  } -vlnv altera.com:ip:altera_msgdma: ingress_msgdma
vds::create_cell -properties { parameters:dataWidth {128} parameters:dualPort {1} parameters:memorySize {524288}  } -vlnv altera.com:ip:intel_onchip_memory: ingress_onchip_memory
vds::create_cell -vlnv altera.com:ip:altera_jtag_avalon_master: jtag_to_avalon
# IOPLL MIF GUI params match ddrfree_common/board.tcl (gui_enable_mif_dps is 0;
# the ~/pll.mif paths are unused placeholders, same as PD).
vds::create_cell -properties { parameters:gui_enable_mif_dps {0} parameters:gui_existing_mif_file_path {~/pll.mif} parameters:gui_frac_multiply_factor {1} parameters:gui_fractional_cout {32} parameters:gui_mif_config_name {unnamed} parameters:gui_mif_gen_options {Generate New MIF File} parameters:gui_new_mif_file_path {~/pll.mif} parameters:gui_output_clock_frequency0 {600.0} parameters:gui_output_clock_frequency_ps0 {1666.667} parameters:gui_pll_bandwidth_preset {High} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:gui_use_coreclk {true} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: kernel_pll
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: pll_resetn_in
vds::create_cell -vlnv altera.com:ip:altera_s10_user_rst_clkgate: reset_release_inst
vds::create_cell -properties { parameters:inChannelWidth {0} parameters:inDataWidth {128} parameters:inErrorWidth {0} parameters:inMaxChannel {1} parameters:outChannelWidth {0} parameters:outDataWidth {INPUT_DATA_WIDTH} parameters:outErrorWidth {0} parameters:outMaxChannel {1}  } -vlnv altera.com:ip:altera_avalon_st_adapter: st_adapter_0
vds::create_cell -properties { parameters:gui_divide_factor_c0 {1} parameters:gui_enable_mif_dps {0} parameters:gui_existing_mif_file_path {~/pll.mif} parameters:gui_frac_multiply_factor {1} parameters:gui_fractional_cout {32} parameters:gui_mif_config_name {unnamed} parameters:gui_mif_gen_options {Generate New MIF File} parameters:gui_multiply_factor {14} parameters:gui_new_mif_file_path {~/pll.mif} parameters:gui_use_coreclk {true} parameters:gui_vco_frequency {1400.0} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: system_clk_iopll
vds::create_cell -properties { parameters:probe_width {0}  } -vlnv altera.com:ip:altera_in_system_sources_probes: system_source
vds::connect_interface_net -dest board_hw_timer|s0 -src hw_timer_addr_decode|m0
vds::assign_base_address -connection hw_timer_addr_decode.m0/board_hw_timer.s0 0x0000
vds::connect_interface_net -dest dla_csr_bridge_0|s0 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/dla_csr_bridge_0.s0 0x00038000
vds::connect_interface_net -dest dla_csr_bridge_1|s0 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/dla_csr_bridge_1.s0 0x00039000
vds::connect_interface_net -dest dla_csr_bridge_2|s0 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/dla_csr_bridge_2.s0 0x0003a000
vds::connect_interface_net -dest dla_csr_bridge_3|s0 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/dla_csr_bridge_3.s0 0x0003b000
vds::connect_interface_net -dest egress_onchip_memory|s2 -src egress_msgdma|mm_write
vds::assign_base_address -connection egress_msgdma.mm_write/egress_onchip_memory.s2 0x00280000
vds::connect_interface_net -dest egress_msgdma|descriptor_slave -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/egress_msgdma.descriptor_slave 0x00030060
vds::connect_interface_net -dest egress_msgdma|csr -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/egress_msgdma.csr 0x00030040
vds::connect_interface_net -dest egress_onchip_memory|s1 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/egress_onchip_memory.s1 0x00280000
vds::connect_interface_net -dest hw_timer_addr_decode|s0 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/hw_timer_addr_decode.s0 0x00037000
vds::connect_interface_net -dest st_adapter_0|in_0 -src ingress_msgdma|st_source
vds::connect_interface_net -dest ingress_onchip_memory|s2 -src ingress_msgdma|mm_read
vds::assign_base_address -connection ingress_msgdma.mm_read/ingress_onchip_memory.s2 0x00200000
vds::connect_interface_net -dest ingress_msgdma|descriptor_slave -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/ingress_msgdma.descriptor_slave 0x00030020
vds::connect_interface_net -dest ingress_msgdma|csr -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/ingress_msgdma.csr 0x00030000
vds::connect_interface_net -dest ingress_onchip_memory|s1 -src jtag_to_avalon|master
vds::assign_base_address -connection jtag_to_avalon.master/ingress_onchip_memory.s1 0x00200000
vds::export_interface_pin st_adapter_0|out_0 ingress_st
vds::export_interface_pin egress_msgdma|st_sink egress_st
vds::export_interface_pin board_hw_timer|m0 dla_hw_timer
vds::export_interface_pin dla_csr_bridge_3|m0 csr_axi_bridge_3_m0
vds::export_interface_pin dla_csr_bridge_2|m0 csr_axi_bridge_2_m0
vds::export_interface_pin dla_csr_bridge_1|m0 csr_axi_bridge_1_m0
vds::export_interface_pin dla_csr_bridge_0|m0 csr_axi_bridge_0_m0
vds::export_pin board_kernel_clk|out_clk kernel_clk
vds::export_pin board_sys_clk|out_clk sys_pll_clk
vds::export_pin clock_in|in_clk clk
vds::connect_net -src clock_in|out_clk -dest global_reset_in|clk
vds::connect_net -src clock_in|out_clk -dest kernel_pll|refclk
vds::connect_net -src clock_in|out_clk -dest system_clk_iopll|refclk
vds::connect_net -src global_reset_in|out_reset -dest kernel_pll|reset
vds::connect_net -src global_reset_in|out_reset -dest system_clk_iopll|reset
vds::export_pin kernel_pll|locked iopll_locked
vds::connect_net -src kernel_pll|outclk0 -dest board_hw_timer|clk
vds::connect_net -src kernel_pll|outclk0 -dest board_kernel_clk|in_clk
vds::export_pin pll_resetn_in|in_reset pll_resetn_in
vds::connect_net -src pll_resetn_in|out_reset -dest dla_csr_bridge_0|clk_reset
vds::connect_net -src pll_resetn_in|out_reset -dest dla_csr_bridge_1|clk_reset
vds::connect_net -src pll_resetn_in|out_reset -dest dla_csr_bridge_2|clk_reset
vds::connect_net -src pll_resetn_in|out_reset -dest dla_csr_bridge_3|clk_reset
vds::connect_net -src pll_resetn_in|out_reset -dest jtag_to_avalon|clk_reset
vds::connect_net -src pll_resetn_in|out_reset -dest st_adapter_0|in_rst_0
vds::connect_net -src pll_resetn_in|out_reset -dest board_hw_timer|reset
vds::connect_net -src pll_resetn_in|out_reset -dest hw_timer_addr_decode|reset
vds::connect_net -src pll_resetn_in|out_reset -dest egress_onchip_memory|reset1
vds::connect_net -src pll_resetn_in|out_reset -dest ingress_onchip_memory|reset1
vds::connect_net -src pll_resetn_in|out_reset -dest egress_msgdma|reset_n
vds::connect_net -src pll_resetn_in|out_reset -dest ingress_msgdma|reset_n
vds::export_pin reset_release_inst|ninit_done done_resetn
vds::export_pin global_reset_in|in_reset resetn
vds::connect_net -src system_clk_iopll|outclk0 -dest dla_csr_bridge_0|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest dla_csr_bridge_1|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest dla_csr_bridge_2|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest dla_csr_bridge_3|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest hw_timer_addr_decode|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest jtag_to_avalon|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest pll_resetn_in|clk
vds::connect_net -src system_clk_iopll|outclk0 -dest egress_onchip_memory|clk1
vds::connect_net -src system_clk_iopll|outclk0 -dest ingress_onchip_memory|clk1
vds::connect_net -src system_clk_iopll|outclk0 -dest egress_msgdma|clock
vds::connect_net -src system_clk_iopll|outclk0 -dest ingress_msgdma|clock
vds::connect_net -src system_clk_iopll|outclk0 -dest board_sys_clk|in_clk
vds::connect_net -src system_clk_iopll|outclk0 -dest st_adapter_0|in_clk_0
vds::export_pin system_source|sources source
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } egress_msgdma.mm_write
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } hw_timer_addr_decode.m0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } ingress_msgdma.mm_read
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } jtag_to_avalon.master
vds::validate_system
vds::save_system board
vds::close_system board

vds::create_system emif -force
vds::create_cell -vlnv :ip:emif_ph2_axil_driver: axil_driver_ddr4a
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: clock_bridge_ddr4a
vds::create_cell -properties { parameters:ADV_CAL_ENABLE_REQ {true} parameters:ADV_CAL_ENABLE_WEQ {true} parameters:CTRL_DM_EN {true} parameters:CTRL_ECC_AUTOCORRECT_EN {false} parameters:CTRL_ECC_WRITEBACK_EN {false} parameters:EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ {110.0} parameters:MEM_OPERATING_FREQ_MHZ {1200} parameters:MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {false} parameters:MEM_CL_CYC {17.0} parameters:MEM_CWL_CYC {12.0} parameters:MEM_DIE_DENSITY_GBITS {16} parameters:MEM_DIE_DQ_WIDTH {8} parameters:MEM_DQ_VREF {35} parameters:MEM_FINE_GRANULARITY_REFRESH_MODE {1.0} parameters:MEM_ODT_DQ_X_IDLE {off} parameters:MEM_ODT_DQ_X_NON_TGT_RD {off} parameters:MEM_ODT_DQ_X_NON_TGT_WR {off} parameters:MEM_ODT_DQ_X_RON {7} parameters:MEM_ODT_DQ_X_TGT_WR {4} parameters:MEM_ODT_NOM {off} parameters:MEM_ODT_PARK {4} parameters:MEM_ODT_WR {off} parameters:MEM_PAGE_SIZE {1024.0} parameters:MEM_RD_PREAMBLE_MODE {1.0} parameters:MEM_SPEEDBIN {3200AA} parameters:MEM_TCCD_L_NS {5.0} parameters:MEM_TCCD_S_NS {3.33333} parameters:MEM_TCKESR_CYC {7.0} parameters:MEM_TCKE_NS {5.0} parameters:MEM_TCKSRE_NS {10.0} parameters:MEM_TCKSRX_NS {10.0} parameters:MEM_TCK_CL_CWL_MAX_NS {0.937} parameters:MEM_TCK_CL_CWL_MIN_NS {0.833} parameters:MEM_TCPDED_NS {3.33333} parameters:MEM_TDQSCK_MAX_MIN_NS {0.16} parameters:MEM_TFAW_NS {21.0} parameters:MEM_TMOD_NS {20.0} parameters:MEM_TMPRR_NS {0.83333} parameters:MEM_TMRD_NS {6.66667} parameters:MEM_TRAS_MAX_NS {70200.0} parameters:MEM_TRAS_MIN_NS {32.0} parameters:MEM_TRAS_NS {32.0} parameters:MEM_TRCD_NS {13.75} parameters:MEM_TRC_NS {45.75} parameters:MEM_TREFI_NS {7800.0} parameters:MEM_TRFC_NS {350.0} parameters:MEM_TRP_NS {13.75} parameters:MEM_TRRD_L_NS {4.9} parameters:MEM_TRRD_S_NS {3.33333} parameters:MEM_TRTP_NS {7.5} parameters:MEM_TWR_CRC_DM_NS {4.16667} parameters:MEM_TWR_NS {15.0} parameters:MEM_TWTR_L_CRC_DM_NS {4.16667} parameters:MEM_TWTR_L_NS {7.5} parameters:MEM_TWTR_S_CRC_DM_NS {4.16667} parameters:MEM_TWTR_S_NS {2.5} parameters:MEM_TXP_NS {6.0} parameters:MEM_TXS_DLL_NS {853.33333} parameters:MEM_TXS_NS {360.0} parameters:MEM_TZQCS_NS {106.66667} parameters:MEM_TZQINIT_CYC {1024.0} parameters:MEM_TZQOPER_CYC {512.0} parameters:MEM_VREF_DQ_X_VALUE {67.75} parameters:MEM_WR_PREAMBLE_MODE {1.0} parameters:PHY_AC_TX_EQUALIZATION {OFF} parameters:PHY_CK_TX_EQUALIZATION {OFF} parameters:PHY_CS_TX_EQUALIZATION {OFF} parameters:PHY_DQ_TX_EQUALIZATION {OFF} parameters:PHY_MAINBAND_ACCESS_MODE {ASYNC} parameters:PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {false} parameters:PHY_REFCLK_FREQ_MHZ {150.0} parameters:PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {false} parameters:PHY_SIDEBAND_ACCESS_MODE {FABRIC} parameters:PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,X,X,X,0,2,3,X; PIN_SWIZZLE_CH0_DQS0=7,5,1,3,4,2,0,6; PIN_SWIZZLE_CH0_DQS1=9,15,13,11,14,12,8,10; PIN_SWIZZLE_CH0_DQS2=19,23,21,17,16,18,20,22; PIN_SWIZZLE_CH0_DQS3=31,29,27,25,26,30,24,28; } parameters:PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {SSTL} parameters:PHY_TERM_X_AC_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_SSTL} parameters:PHY_TERM_X_CK_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {SSTL} parameters:PHY_TERM_X_CS_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD} parameters:PHY_TERM_X_DQ_IO_STD_TYPE {POD} parameters:PHY_TERM_X_DQ_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQ_VREF {68.3} parameters:PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS} parameters:PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF} parameters:PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL} parameters:PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF} parameters:PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF} } -vlnv altera.com:ip:emif_io96b_ddr4comp: ddr4a
vds::create_cell -properties { parameters:gui_cascade_outclk_index {5} parameters:gui_frac_multiply_factor {1} parameters:gui_fractional_cout {32} parameters:gui_output_clock_frequency0 {50.0} parameters:gui_output_clock_frequency1 {50.0} parameters:gui_output_clock_frequency_ps0 {20000.0} parameters:gui_output_clock_frequency_ps1 {20000.0} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: iopll
vds::create_cell -properties { parameters:CONDUIT_TYPE_0 {export} parameters:NUM_CONDUITS {1} parameters:SYNC_TO_CLK {true}  } -vlnv :ip:mem_reset_handler: reset_handler
vds::create_cell -properties { parameters:outputType {Reset Interface}  } -vlnv altera.com:ip:altera_s10_user_rst_clkgate: rrip
vds::connect_interface_net -dest ddr4a|s0_axi4lite -src axil_driver_ddr4a|axil_driver_axi4_lite
vds::assign_base_address -connection axil_driver_ddr4a.axil_driver_axi4_lite/ddr4a.s0_axi4lite 0x0000
vds::export_interface_pin ddr4a|mem_ck_0 mem_ddr4_ck
vds::export_interface_pin ddr4a|mem_0 mem_ddr4
vds::export_interface_pin ddr4a|s0_axi4 local_mem
vds::export_pin axil_driver_ddr4a|cal_done_rst_n mem_ddr4_cal_done_rst_n
vds::connect_net -src clock_bridge_ddr4a|out_clk -dest ddr4a|s0_axi4_clock_in
vds::export_pin ddr4a|mem_reset_n mem_ddr4_reset_n
vds::export_pin ddr4a|s0_axi4_ctrl_ready local_mem_ctrl_ready
vds::connect_net -src iopll|outclk0 -dest axil_driver_ddr4a|axil_driver_clk
vds::connect_net -src iopll|outclk0 -dest reset_handler|clk
vds::connect_net -src iopll|outclk0 -dest ddr4a|s0_axi4lite_clock
vds::export_pin iopll|refclk iopll_0_refclk
vds::export_pin clock_bridge_ddr4a|in_clk local_mem_clock_in
vds::export_pin ddr4a|oct_0 mem_ddr4_mem_oct
vds::export_pin ddr4a|ref_clk mem_ddr4_mem_ref
vds::connect_net -src reset_handler|conduit_0 -dest iopll|locked
vds::connect_net -src reset_handler|reset_n_out -dest axil_driver_ddr4a|axil_driver_rst_n
vds::connect_net -src reset_handler|reset_n_out -dest ddr4a|s0_axi4lite_reset_n
vds::connect_net -src rrip|ninit_done -dest ddr4a|core_init_n
vds::connect_net -src rrip|ninit_done -dest iopll|reset
vds::connect_net -src rrip|ninit_done -dest reset_handler|reset_n_0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } axil_driver_ddr4a.axil_driver_axi4_lite
vds::validate_system
vds::save_system emif
vds::close_system emif

post_message "Script completed successfully."

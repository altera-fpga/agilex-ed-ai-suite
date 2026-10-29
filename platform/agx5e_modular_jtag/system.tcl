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

vds::create_system shell -force
vds::create_cell -properties { parameters:AXI_VERSION {AXI4-Lite} parameters:COMBINED_ACCEPTANCE_CAPABILITY {32} parameters:COMBINED_ISSUING_CAPABILITY {32} parameters:M0_ID_WIDTH {1} parameters:READ_ACCEPTANCE_CAPABILITY {32} parameters:READ_DATA_USER_WIDTH {64} parameters:READ_ISSUING_CAPABILITY {32} parameters:S0_ID_WIDTH {1} parameters:SYNC_RESET {1} parameters:USE_M0_ARBURST {0} parameters:USE_M0_ARCACHE {0} parameters:USE_M0_ARID {0} parameters:USE_M0_ARLEN {0} parameters:USE_M0_ARLOCK {0} parameters:USE_M0_ARSIZE {0} parameters:USE_M0_ARSNOOP {0} parameters:USE_M0_AWBURST {0} parameters:USE_M0_AWCACHE {0} parameters:USE_M0_AWID {0} parameters:USE_M0_AWLEN {0} parameters:USE_M0_AWLOCK {0} parameters:USE_M0_AWSIZE {0} parameters:USE_M0_AWSNOOP {0} parameters:USE_M0_AWUNIQUE {0} parameters:USE_M0_BID {0} parameters:USE_M0_RID {0} parameters:USE_M0_RLAST {0} parameters:USE_S0_ARCACHE {0} parameters:USE_S0_ARLOCK {0} parameters:USE_S0_ARSIZE {0} parameters:USE_S0_AWCACHE {0} parameters:USE_S0_AWLOCK {0} parameters:USE_S0_AWSIZE {0} parameters:USE_S0_BID {0} parameters:USE_S0_RID {0} parameters:USE_S0_RRESP {0} parameters:USE_S0_WLAST {0} parameters:WRITE_ACCEPTANCE_CAPABILITY {32} parameters:WRITE_DATA_USER_WIDTH {64} parameters:WRITE_ISSUING_CAPABILITY {1} parameters:WRITE_RESP_USER_WIDTH {64}  } -vlnv altera.com:ip:altera_axi_bridge: csr_data_bridge_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: dla_clk_bridge_0
# IOPLL MIF GUI params match agx5e_modular_jtag_pd/qsys/ed_zero.tcl (gui_enable_mif_dps is 0;
# the ~/...mif paths are unused placeholders, same as PD).
vds::create_cell -properties { parameters:gui_enable_mif_dps {0} parameters:gui_existing_mif_file_path {~/dla_pll.mif} parameters:gui_fractional_cout {32} parameters:gui_location_type {Fabric-Feeding} parameters:gui_mif_config_name {unnamed} parameters:gui_mif_gen_options {Generate New MIF File} parameters:gui_new_mif_file_path {~/dla_pll.mif} parameters:gui_output_clock_frequency0 {600.0} parameters:gui_pll_bandwidth_preset {Medium} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:gui_use_coreclk {true} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: dla_pll_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {8}  } -vlnv altera.com:ip:mm_ccb: ed_zero_hw_timer_bridge
# AE4S @ 1200 MHz only allows ASYNC mainband (SYNC is out of range). Soft fabric
# must supply s0_axi4_clock_in (~300 MHz, same as agx5_soc_m2m_prq to_ddr_clk).
vds::create_cell -properties { parameters:CTRL_DM_EN {false} parameters:ADV_CAL_ENABLE_WEQ {true} parameters:ADV_CAL_ENABLE_REQ {true} parameters:CTRL_ECC_AUTOCORRECT_EN {false} parameters:CTRL_ECC_WRITEBACK_EN {false} parameters:EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ {290.0} parameters:EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ_AUTOSET_EN {true} parameters:JEDEC_OVERRIDE_TABLE_PARAM_NAME {{MEM_CL_CYC} {MEM_TRFC_NS}} parameters:MEM_OPERATING_FREQ_MHZ {1200} parameters:MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {false} parameters:MEM_SPEEDBIN {3200AA} parameters:MEM_WR_PREAMBLE_MODE {1.0} parameters:MEM_CL_CYC {17.0} parameters:MEM_CWL_CYC {12.0} parameters:MEM_DIE_DENSITY_GBITS {16} parameters:MEM_DIE_DQ_WIDTH {8} parameters:MEM_DQ_VREF {35} parameters:MEM_FINE_GRANULARITY_REFRESH_MODE {1.0} parameters:MEM_ODT_DQ_X_IDLE {off} parameters:MEM_ODT_DQ_X_NON_TGT_RD {off} parameters:MEM_ODT_DQ_X_NON_TGT_WR {off} parameters:MEM_ODT_DQ_X_RON {7} parameters:MEM_ODT_DQ_X_TGT_WR {4} parameters:MEM_ODT_NOM {off} parameters:MEM_ODT_PARK {4} parameters:MEM_ODT_WR {off} parameters:MEM_PAGE_SIZE {1024.0} parameters:MEM_RD_PREAMBLE_MODE {1.0} parameters:MEM_TCCD_L_NS {5.0} parameters:MEM_TCCD_S_NS {3.33333} parameters:MEM_TCKESR_CYC {7.0} parameters:MEM_TCKE_NS {5.0} parameters:MEM_TCKSRE_NS {10.0} parameters:MEM_TCKSRX_NS {10.0} parameters:MEM_TCK_CL_CWL_MAX_NS {0.937} parameters:MEM_TCK_CL_CWL_MIN_NS {0.833} parameters:MEM_TCPDED_NS {3.33333} parameters:MEM_TDQSCK_MAX_MIN_NS {0.16} parameters:MEM_TFAW_NS {21.0} parameters:MEM_TMOD_NS {20.0} parameters:MEM_TMPRR_NS {0.83333} parameters:MEM_TMRD_NS {6.66667} parameters:MEM_TRAS_MAX_NS {70200.0} parameters:MEM_TRAS_MIN_NS {32.0} parameters:MEM_TRAS_NS {32.0} parameters:MEM_TRCD_NS {13.75} parameters:MEM_TRC_NS {45.75} parameters:MEM_TREFI_NS {7800.0} parameters:MEM_TRFC_NS {350.0} parameters:MEM_TRP_NS {13.75} parameters:MEM_TRRD_L_NS {4.9} parameters:MEM_TRRD_S_NS {3.33333} parameters:MEM_TRTP_NS {7.5} parameters:MEM_TWR_CRC_DM_NS {4.16667} parameters:MEM_TWR_NS {15.0} parameters:MEM_TWTR_L_CRC_DM_NS {4.16667} parameters:MEM_TWTR_L_NS {7.5} parameters:MEM_TWTR_S_CRC_DM_NS {4.16667} parameters:MEM_TWTR_S_NS {2.5} parameters:MEM_TXP_NS {6.0} parameters:MEM_TXS_DLL_NS {853.33333} parameters:MEM_TXS_NS {360.0} parameters:MEM_TZQCS_NS {106.66667} parameters:MEM_TZQINIT_CYC {1024.0} parameters:MEM_TZQOPER_CYC {512.0} parameters:MEM_VREF_DQ_X_VALUE {67.75} parameters:PHY_AC_TX_EQUALIZATION {OFF} parameters:PHY_CK_TX_EQUALIZATION {OFF} parameters:PHY_CS_TX_EQUALIZATION {OFF} parameters:PHY_DQ_TX_EQUALIZATION {OFF} parameters:PHY_MAINBAND_ACCESS_MODE {ASYNC} parameters:PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {false} parameters:PHY_REFCLK_FREQ_MHZ {150.0} parameters:PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {false} parameters:PHY_SIDEBAND_ACCESS_MODE {FABRIC} parameters:PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,X,X,X,0,2,3,X; PIN_SWIZZLE_CH0_DQS0=7,5,1,3,4,2,0,6; PIN_SWIZZLE_CH0_DQS1=9,15,13,11,14,12,8,10; PIN_SWIZZLE_CH0_DQS2=19,23,21,17,16,18,20,22; PIN_SWIZZLE_CH0_DQS3=31,29,27,25,26,30,24,28; } parameters:PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {SSTL} parameters:PHY_TERM_X_AC_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_SSTL} parameters:PHY_TERM_X_CK_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {SSTL} parameters:PHY_TERM_X_CS_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD} parameters:PHY_TERM_X_DQ_IO_STD_TYPE {POD} parameters:PHY_TERM_X_DQ_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQ_VREF {68.3} parameters:PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS} parameters:PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF} parameters:PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL} parameters:PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF} parameters:PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF} } -vlnv altera.com:ip:emif_io96b_ddr4comp: emif_0
# Dedicated EMIF user-clock PLL (not dla_pll_0 — dla_adjust_pll retargets both outclk0/1).
vds::create_cell -properties { parameters:gui_enable_mif_dps {0} parameters:gui_existing_mif_file_path {~/emif_usr_pll.mif} parameters:gui_fractional_cout {32} parameters:gui_location_type {Fabric-Feeding} parameters:gui_mif_config_name {unnamed} parameters:gui_mif_gen_options {Generate New MIF File} parameters:gui_new_mif_file_path {~/emif_usr_pll.mif} parameters:gui_output_clock_frequency0 {300.0} parameters:gui_pll_bandwidth_preset {Medium} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:gui_use_coreclk {true} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: emif_usr_pll_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: emif_clk_bridge_0
# Import the EMIF AXI data bridge as a standalone .ip (same pattern as SoC EMIF
# imports). Inline create_cell -properties silently drops USE_S0_WLAST back to 0,
# which removes emif_data_bridge_0_s0_wlast from shell and breaks top.sv.
set proj_dir [get_project_directory]
vds::create_cell emif_data_bridge_0 -type ip -files $proj_dir/src/ip/ed_zero_axi_bridge_0.ip
vds::create_cell -vlnv :ip:emif_ph2_axil_driver: emif_sideband_driver_0
vds::create_cell -properties { parameters:ENABLE_SLAVE_PORT {false} parameters:MASTER_ADDRESS_WIDTH {33} parameters:SLAVE_ADDRESS_WIDTH {29}  } -vlnv altera.com:ip:altera_address_span_extender: jtag_address_span_extender
vds::create_cell -vlnv altera.com:ip:altera_jtag_avalon_master: jtag_master_0
vds::create_cell -properties { parameters:gui_enable_mif_dps {0} parameters:gui_existing_mif_file_path {~/jtag_pll.mif} parameters:gui_fractional_cout {32} parameters:gui_location_type {Fabric-Feeding} parameters:gui_mif_config_name {unnamed} parameters:gui_mif_gen_options {Generate New MIF File} parameters:gui_new_mif_file_path {~/pll.mif} parameters:gui_pll_bandwidth_preset {Medium} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:gui_use_coreclk {true} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: jtag_pll_0
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: reset_bridge_0
vds::create_cell -properties { parameters:CONDUIT_TYPE_0 {export} parameters:CONDUIT_TYPE_1 {export} parameters:CONDUIT_TYPE_2 {export} parameters:NUM_CONDUITS {3} parameters:NUM_RESETS {2} parameters:SYNC_TO_CLK {true}  } -vlnv :ip:mem_reset_handler: reset_handler_0
vds::create_cell -properties { parameters:outputType {Reset Interface}  } -vlnv altera.com:ip:altera_s10_user_rst_clkgate: rrip_0
vds::connect_interface_net -dest csr_data_bridge_0|s0 -src jtag_master_0|master
vds::assign_base_address -connection jtag_master_0.master/csr_data_bridge_0.s0 0x80000000
vds::connect_interface_net -dest ed_zero_hw_timer_bridge|s0 -src jtag_master_0|master
vds::assign_base_address -connection jtag_master_0.master/ed_zero_hw_timer_bridge.s0 0x80000800
vds::connect_interface_net -dest emif_0|s0_axi4lite -src emif_sideband_driver_0|axil_driver_axi4_lite
vds::assign_base_address -connection emif_sideband_driver_0.axil_driver_axi4_lite/emif_0.s0_axi4lite 0x0000
vds::connect_interface_net -dest emif_0|s0_axi4 -src jtag_address_span_extender|expanded_master
vds::assign_base_address -connection jtag_address_span_extender.expanded_master/emif_0.s0_axi4 0x0000
vds::connect_interface_net -dest emif_0|s0_axi4 -src emif_data_bridge_0|m0
vds::assign_base_address -connection emif_data_bridge_0.m0/emif_0.s0_axi4 0x0000
vds::connect_interface_net -dest jtag_address_span_extender|windowed_slave -src jtag_master_0|master
vds::assign_base_address -connection jtag_master_0.master/jtag_address_span_extender.windowed_slave 0x0000
vds::export_interface_pin emif_data_bridge_0|s0 emif_data_bridge_0_s0
vds::export_interface_pin emif_0|mem_ck_0 emif_0_mem_0_ck
vds::export_interface_pin emif_0|mem_0 emif_0_mem_0
vds::export_interface_pin ed_zero_hw_timer_bridge|m0 ed_zero_hw_timer_bridge_m0
vds::export_interface_pin csr_data_bridge_0|m0 csr_data_bridge_0_m0
vds::export_pin dla_clk_bridge_0|out_clk dla_clk_bridge_0_out_clk
vds::connect_net -src dla_pll_0|locked -dest reset_handler_0|conduit_0
vds::connect_net -src dla_pll_0|outclk0 -dest reset_bridge_0|clk
vds::connect_net -src dla_pll_0|outclk0 -dest reset_handler_0|clk
vds::connect_net -src dla_pll_0|outclk0 -dest dla_clk_bridge_0|in_clk
vds::export_pin dla_pll_0|refclk dla_pll_0_refclk
vds::export_pin ed_zero_hw_timer_bridge|m0_clk ed_zero_hw_timer_bridge_m0_clk
vds::export_pin ed_zero_hw_timer_bridge|m0_reset ed_zero_hw_timer_bridge_m0_reset
vds::export_pin emif_0|mem_reset_n emif_0_mem_0_reset_n
# ASYNC: fabric user clock into EMIF + AXI fabric (replaces SYNC s0_axi4_clock_out).
vds::connect_net -src emif_usr_pll_0|outclk0 -dest emif_0|s0_axi4_clock_in
vds::connect_net -src emif_usr_pll_0|outclk0 -dest csr_data_bridge_0|clk
vds::connect_net -src emif_usr_pll_0|outclk0 -dest emif_data_bridge_0|clk
vds::connect_net -src emif_usr_pll_0|outclk0 -dest jtag_address_span_extender|clock
vds::connect_net -src emif_usr_pll_0|outclk0 -dest emif_clk_bridge_0|in_clk
vds::export_pin emif_0|oct_0 emif_0_oct_0
vds::export_pin emif_0|ref_clk emif_0_ref_clk_0
vds::export_pin emif_clk_bridge_0|out_clk emif_clk_bridge_0_out_clk
vds::export_pin emif_usr_pll_0|refclk emif_usr_pll_0_refclk
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest csr_data_bridge_0|clk_reset
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest emif_data_bridge_0|clk_reset
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest reset_bridge_0|in_reset
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest jtag_address_span_extender|reset
vds::connect_net -src jtag_pll_0|locked -dest reset_handler_0|conduit_1
vds::connect_net -src emif_usr_pll_0|locked -dest reset_handler_0|conduit_2
vds::connect_net -src jtag_pll_0|outclk0 -dest emif_sideband_driver_0|axil_driver_clk
vds::connect_net -src jtag_pll_0|outclk0 -dest jtag_master_0|clk
vds::connect_net -src jtag_pll_0|outclk0 -dest emif_0|s0_axi4lite_clock
vds::connect_net -src jtag_pll_0|outclk0 -dest ed_zero_hw_timer_bridge|s0_clk
vds::export_pin jtag_pll_0|refclk jtag_pll_0_refclk
vds::export_pin reset_bridge_0|out_reset reset_bridge_0_out_reset
vds::connect_net -src reset_handler_0|reset_n_out -dest emif_sideband_driver_0|axil_driver_rst_n
vds::connect_net -src reset_handler_0|reset_n_out -dest jtag_master_0|clk_reset
vds::connect_net -src reset_handler_0|reset_n_out -dest emif_0|core_init_n
vds::connect_net -src reset_handler_0|reset_n_out -dest emif_0|s0_axi4lite_reset_n
vds::connect_net -src reset_handler_0|reset_n_out -dest ed_zero_hw_timer_bridge|s0_reset
vds::export_pin reset_handler_0|reset_n_1 reset_handler_reset_n_1
vds::connect_net -src rrip_0|ninit_done -dest dla_pll_0|reset
vds::connect_net -src rrip_0|ninit_done -dest jtag_pll_0|reset
vds::connect_net -src rrip_0|ninit_done -dest emif_usr_pll_0|reset
vds::connect_net -src rrip_0|ninit_done -dest reset_handler_0|reset_n_0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } emif_sideband_driver_0.axil_driver_axi4_lite
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } jtag_address_span_extender.expanded_master
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } jtag_master_0.master
vds::validate_system
vds::save_system shell

post_message "Script completed successfully."

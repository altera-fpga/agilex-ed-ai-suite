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
# IOPLL MIF GUI params match agx3c_jtag_pd/qsys/ed_zero.tcl (gui_enable_mif_dps is 0;
# the ~/...mif paths are unused placeholders, same as PD).
vds::create_cell -properties { parameters:gui_enable_mif_dps {0} parameters:gui_existing_mif_file_path {~/dla_pll.mif} parameters:gui_fractional_cout {32} parameters:gui_location_type {Fabric-Feeding} parameters:gui_mif_config_name {unnamed} parameters:gui_mif_gen_options {Generate New MIF File} parameters:gui_new_mif_file_path {~/dla_pll.mif} parameters:gui_output_clock_frequency0 {600.0} parameters:gui_pll_bandwidth_preset {Medium} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:gui_use_coreclk {true} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: dla_pll_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {8}  } -vlnv altera.com:ip:mm_ccb: ed_zero_hw_timer_bridge
vds::create_cell -properties { parameters:ADV_CAL_ENABLE_REQ {true} parameters:ADV_CAL_ENABLE_WEQ {true} parameters:CTRL_ECC_AUTOCORRECT_EN {false} parameters:CTRL_ECC_WRITEBACK_EN {false} parameters:EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ {150.0} parameters:JEDEC_OVERRIDE_TABLE_PARAM_NAME {{MEM_TREFI_NS} {MEM_TMRR_NS}} parameters:MEM_CA_VREF {13} parameters:MEM_CHANNEL_DATA_DQ_WIDTH {32} parameters:MEM_CL_CYC {20} parameters:MEM_CWL_CYC {18} parameters:MEM_DIE_DENSITY_GBITS {8} parameters:MEM_DQ_VREF {20} parameters:MEM_MINNUMREFSREQ {8192.0} parameters:MEM_NUM_CHANNELS {1} parameters:MEM_ODT_CA_X_CA_COMM {3} parameters:MEM_ODT_CA_X_CA_ENABLE {true} parameters:MEM_ODT_CA_X_CK_ENABLE {true} parameters:MEM_ODT_CA_X_CS_ENABLE {true} parameters:MEM_ODT_DQ_X_IDLE {off} parameters:MEM_ODT_DQ_X_RON {6} parameters:MEM_ODT_DQ_X_TGT_WR {5} parameters:MEM_OPERATING_FREQ_MHZ {1066.667} parameters:MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {false} parameters:MEM_PER_BANK_REF_EN {1} parameters:MEM_TCCD_NS {7.5} parameters:MEM_TCKCKEH_NS {2.8125} parameters:MEM_TCKCKEL_NS {5.0} parameters:MEM_TCKEHCMD_NS {7.5} parameters:MEM_TCKELCK_NS {5.0} parameters:MEM_TCKELCMD_NS {5.0} parameters:MEM_TCKE_NS {7.5} parameters:MEM_TCMDCKE_NS {2.8125} parameters:MEM_TCSCKEH_NS {1.75} parameters:MEM_TCSCKE_NS {1.75} parameters:MEM_TDQSCK_MAX_NS {3.5} parameters:MEM_TDQSCK_MIN_NS {1.5} parameters:MEM_TESCKE_NS {2.8125} parameters:MEM_TFAW_NS {40.0} parameters:MEM_TMRD_NS {14.0} parameters:MEM_TMRR_NS {8.0} parameters:MEM_TMRWCKEL_NS {14.0} parameters:MEM_TMRW_NS {10.0} parameters:MEM_TPPD_CYC {4.0} parameters:MEM_TRAS_NS {42.0} parameters:MEM_TRCD_NS {18.0} parameters:MEM_TRC_NS {63.0} parameters:MEM_TREFI_NS {3906.0} parameters:MEM_TREFW_NS {3.2E7} parameters:MEM_TRFCAB_NS {280.0} parameters:MEM_TRFCPB_NS {140.0} parameters:MEM_TRPAB_NS {21.0} parameters:MEM_TRPPB_NS {18.0} parameters:MEM_TRRD_NS {10.0} parameters:MEM_TRTP_NS {7.5} parameters:MEM_TSR_NS {15.0} parameters:MEM_TWR_NS {18.0} parameters:MEM_TWTR_NS {10.0} parameters:MEM_TXP_NS {7.5} parameters:MEM_TXSR_NS {287.5} parameters:MEM_TZQCAL_NS {1000.0} parameters:MEM_TZQCKE_NS {2.8125} parameters:MEM_TZQLAT_NS {30.0} parameters:MEM_VREF_CA_X_CA_VALUE {27.2} parameters:MEM_VREF_DQ_X_VALUE {18.0} parameters:MEM_WLS {1.0} parameters:PHY_AC_TX_EQUALIZATION {OFF} parameters:PHY_CK_TX_EQUALIZATION {OFF} parameters:PHY_CS_TX_EQUALIZATION {OFF} parameters:PHY_DQ_TX_EQUALIZATION {OFF} parameters:PHY_MAINBAND_ACCESS_MODE {SYNC} parameters:PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {false} parameters:PHY_REFCLK_ADVANCED_SELECT_EN {true} parameters:PHY_REFCLK_FREQ_MHZ {166.6667} parameters:PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {false} parameters:PHY_SIDEBAND_ACCESS_MODE {FABRIC} parameters:PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,0,X,X,X,X,2,3;  PIN_SWIZZLE_CH0_DQS0=0,1,3,2,6,7,4,5;  PIN_SWIZZLE_CH0_DQS1=15,14,13,12,9,11,8,10;  PIN_SWIZZLE_CH0_DQS2=19,20,21,18,17,16,23,22;  PIN_SWIZZLE_CH0_DQS3=25,30,24,31,27,26,28,29; } parameters:PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_AC_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_LVSTL} parameters:PHY_TERM_X_CK_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_CS_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQS_IO_STD_TYPE {DF_LVSTL} parameters:PHY_TERM_X_DQ_IO_STD_TYPE {LVSTL} parameters:PHY_TERM_X_DQ_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQ_VREF {17.5} parameters:PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS} parameters:PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF} parameters:PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_40_OHM_CAL} parameters:PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL} parameters:PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF} parameters:PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}  } -vlnv altera.com:ip:emif_io96b_lpddr4: emif_0
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
vds::create_cell -properties { parameters:CONDUIT_TYPE_0 {export} parameters:CONDUIT_TYPE_1 {export} parameters:NUM_CONDUITS {2} parameters:NUM_RESETS {2} parameters:SYNC_TO_CLK {true}  } -vlnv :ip:mem_reset_handler: reset_handler_0
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
vds::connect_net -src emif_0|s0_axi4_clock_out -dest csr_data_bridge_0|clk
vds::connect_net -src emif_0|s0_axi4_clock_out -dest emif_data_bridge_0|clk
vds::connect_net -src emif_0|s0_axi4_clock_out -dest jtag_address_span_extender|clock
vds::connect_net -src emif_0|s0_axi4_clock_out -dest emif_clk_bridge_0|in_clk
vds::export_pin emif_0|oct_0 emif_0_oct_0
vds::export_pin emif_0|ref_clk emif_0_ref_clk_0
vds::export_pin emif_clk_bridge_0|out_clk emif_clk_bridge_0_out_clk
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest csr_data_bridge_0|clk_reset
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest emif_data_bridge_0|clk_reset
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest reset_bridge_0|in_reset
vds::connect_net -src emif_sideband_driver_0|cal_done_rst_n -dest jtag_address_span_extender|reset
vds::connect_net -src jtag_pll_0|locked -dest reset_handler_0|conduit_1
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
vds::connect_net -src rrip_0|ninit_done -dest reset_handler_0|reset_n_0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } emif_sideband_driver_0.axil_driver_axi4_lite
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } jtag_address_span_extender.expanded_master
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } jtag_master_0.master
vds::validate_system
vds::save_system shell

post_message "Script completed successfully."

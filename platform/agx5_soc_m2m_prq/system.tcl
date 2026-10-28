load_package vds
# project_new top
# 
# Info: Current script was exported with Quartus Prime Pro Release 26.3.0 Build 74
# 
regexp {[\.0-9]+} $quartus(version) import_release
if {$import_release != "26.3.0"} {
	post_message -type error "Cannot import script exported from Quartus Prime Pro version \"26.3.0 Build 74\" into current release \"$import_release\".\n\tOpen, upgrade, and validate the original system in VDS to ensure design correctness."
	return
}
proc get_current_hier {} {
set current_hier [vds::get_current_hier]
if {$current_hier == "|"} {
	set current_hier ""
}
return $current_hier
}

proc create_dla {} {
vds::create_system dla -force
vds::create_cell -properties { parameters:C_DDR_AXI_WRITE_ID_WIDTH {2}  } -vlnv altera.com:ip:altera_ai_ip: altera_ai_ip_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {16} parameters:MAX_BURST_SIZE {8}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: csr_bridge_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: csr_clk_0
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge: csr_rst_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {32} parameters:DATA_WIDTH {256} parameters:MAX_BURST_SIZE {64} parameters:MAX_PENDING_RESPONSES {16}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: ddr_bridge_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: ddr_clk_0
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge: ddr_rst_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: dla_clk_0
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: dla_rst_0
vds::connect_interface_net -dest ddr_bridge_0|s0 -src altera_ai_ip_0|ddr_axi
vds::assign_base_address -connection altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 0x0000
vds::connect_interface_net -dest altera_ai_ip_0|csr_axi -src csr_bridge_0|m0
vds::assign_base_address -connection csr_bridge_0.m0/altera_ai_ip_0.csr_axi 0x4000
vds::export_interface_pin ddr_bridge_0|m0 dla_to_ddr
vds::export_interface_pin altera_ai_ip_0|irq_level dla_irq
vds::export_interface_pin csr_bridge_0|s0 csr_bridge
vds::export_pin csr_clk_0|in_clk csr_clk
vds::connect_net -src csr_clk_0|out_clk -dest csr_bridge_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest csr_rst_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest dla_rst_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest altera_ai_ip_0|irq_clk
vds::export_pin csr_rst_0|in_reset csr_rst
vds::connect_net -src csr_rst_0|out_reset -dest csr_bridge_0|reset
vds::export_pin ddr_clk_0|in_clk ddr_clk
vds::connect_net -src ddr_clk_0|out_clk -dest ddr_bridge_0|clk
vds::connect_net -src ddr_clk_0|out_clk -dest ddr_rst_0|clk
vds::connect_net -src ddr_clk_0|out_clk -dest altera_ai_ip_0|ddr_clk
vds::export_pin ddr_rst_0|in_reset ddr_rst
vds::connect_net -src ddr_rst_0|out_reset -dest ddr_bridge_0|reset
vds::export_pin dla_clk_0|in_clk dla_clk
vds::connect_net -src dla_clk_0|out_clk -dest altera_ai_ip_0|dla_clk
vds::export_pin dla_rst_0|in_reset dla_resetn
vds::connect_net -src dla_rst_0|out_reset -dest altera_ai_ip_0|dla_resetn
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets FALSE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } altera_ai_ip_0.ddr_axi
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets FALSE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } csr_bridge_0.m0
vds::validate_system
vds::save_system dla
vds::close_system dla
}
proc create_emif {} {
vds::create_system emif -force
vds::create_cell -properties { parameters:AXIL_DRIVER_ADDRESS_WIDTH {27}  } -vlnv :ip:emif_ph2_axil_driver: axil_driver

# MEM_CL_CYC, MEM_CWL_CYC and MEM_TRFC_NS are left to the IP's JEDEC tables
# instead of being listed as overrides, because VDS zeroes an inline JEDEC
# override whose value matches the one the IP computes.
vds::create_cell -properties { parameters:ADV_CAL_ENABLE_REQ {true} parameters:ADV_CAL_ENABLE_WEQ {true} parameters:CTRL_DM_EN {true} parameters:CTRL_ECC_AUTOCORRECT_EN {false} parameters:CTRL_ECC_WRITEBACK_EN {false} parameters:JEDEC_OVERRIDE_TABLE_PARAM_NAME {} parameters:MEM_DIE_DENSITY_GBITS {16} parameters:MEM_DIE_DQ_WIDTH {8} parameters:MEM_DQ_VREF {35} parameters:MEM_FINE_GRANULARITY_REFRESH_MODE {1.0} parameters:MEM_ODT_DQ_X_IDLE {off} parameters:MEM_ODT_DQ_X_NON_TGT_RD {off} parameters:MEM_ODT_DQ_X_NON_TGT_WR {off} parameters:MEM_ODT_DQ_X_RON {7} parameters:MEM_ODT_DQ_X_TGT_WR {4} parameters:MEM_ODT_NOM {off} parameters:MEM_ODT_PARK {4} parameters:MEM_ODT_WR {off} parameters:MEM_OPERATING_FREQ_MHZ {1200} parameters:MEM_PAGE_SIZE {1024.0} parameters:MEM_RD_PREAMBLE_MODE {1.0} parameters:MEM_SPEEDBIN {3200AA} parameters:MEM_TCCD_L_NS {5.0} parameters:MEM_TCCD_S_NS {3.33333} parameters:MEM_TCKESR_CYC {7.0} parameters:MEM_TCKE_NS {5.0} parameters:MEM_TCKSRE_NS {10.0} parameters:MEM_TCKSRX_NS {10.0} parameters:MEM_TCK_CL_CWL_MAX_NS {0.937} parameters:MEM_TCK_CL_CWL_MIN_NS {0.833} parameters:MEM_TCPDED_NS {3.33333} parameters:MEM_TDQSCK_MAX_MIN_NS {0.16} parameters:MEM_TFAW_NS {21.0} parameters:MEM_TMOD_NS {20.0} parameters:MEM_TMPRR_NS {0.83333} parameters:MEM_TMRD_NS {6.66667} parameters:MEM_TRAS_MAX_NS {70200.0} parameters:MEM_TRAS_MIN_NS {32.0} parameters:MEM_TRAS_NS {32.0} parameters:MEM_TRCD_NS {13.75} parameters:MEM_TRC_NS {45.75} parameters:MEM_TREFI_NS {7800.0} parameters:MEM_TRP_NS {13.75} parameters:MEM_TRRD_L_NS {4.9} parameters:MEM_TRRD_S_NS {3.33333} parameters:MEM_TRTP_NS {7.5} parameters:MEM_TWR_CRC_DM_NS {4.16667} parameters:MEM_TWR_NS {15.0} parameters:MEM_TWTR_L_CRC_DM_NS {4.16667} parameters:MEM_TWTR_L_NS {7.5} parameters:MEM_TWTR_S_CRC_DM_NS {4.16667} parameters:MEM_TWTR_S_NS {2.5} parameters:MEM_TXP_NS {6.0} parameters:MEM_TXS_DLL_NS {853.33333} parameters:MEM_TZQCS_NS {106.66667} parameters:MEM_TZQINIT_CYC {1024.0} parameters:MEM_TZQOPER_CYC {512.0} parameters:MEM_VREF_DQ_X_VALUE {67.75} parameters:MEM_WR_PREAMBLE_MODE {1.0} parameters:PHY_AC_TX_EQUALIZATION {OFF} parameters:PHY_CK_TX_EQUALIZATION {OFF} parameters:PHY_CS_TX_EQUALIZATION {OFF} parameters:PHY_DQ_TX_EQUALIZATION {OFF} parameters:PHY_MAINBAND_ACCESS_MODE {ASYNC} parameters:PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {false} parameters:PHY_REFCLK_FREQ_MHZ {150.0} parameters:PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {false} parameters:PHY_SIDEBAND_ACCESS_MODE {FABRIC} parameters:PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,X,X,X,0,2,3,X; PIN_SWIZZLE_CH0_DQS0=7,5,1,3,4,2,0,6; PIN_SWIZZLE_CH0_DQS1=9,15,13,11,14,12,8,10; PIN_SWIZZLE_CH0_DQS2=19,23,21,17,16,18,20,22; PIN_SWIZZLE_CH0_DQS3=31,29,27,25,26,30,24,28; } parameters:PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {SSTL} parameters:PHY_TERM_X_AC_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_SSTL} parameters:PHY_TERM_X_CK_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {SSTL} parameters:PHY_TERM_X_CS_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD} parameters:PHY_TERM_X_DQ_IO_STD_TYPE {POD} parameters:PHY_TERM_X_DQ_SLEW_RATE {FASTEST} parameters:PHY_TERM_X_DQ_VREF {68.3} parameters:PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS} parameters:PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF} parameters:PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL} parameters:PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL} parameters:PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF} parameters:PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF} parameters:MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {false}  } -vlnv altera.com:ip:emif_io96b_ddr4comp: emif

vds::create_cell -properties { parameters:CONDUIT_TYPE_0 {export} parameters:NUM_CONDUITS {1} parameters:SYNC_TO_CLK {true}  } -vlnv :ip:mem_reset_handler: reset_handler
vds::create_cell -properties { parameters:outputType {Reset Interface}  } -vlnv altera.com:ip:altera_s10_user_rst_clkgate: rrip
vds::create_cell -properties { parameters:gui_cascade_outclk_index {5} parameters:gui_frac_multiply_factor {1} parameters:gui_fractional_cout {32} parameters:gui_output_clock_frequency0 {150.0} parameters:gui_output_clock_frequency1 {110.0} parameters:gui_output_clock_frequency_ps0 {6666.667} parameters:gui_output_clock_frequency_ps1 {9090.909} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: user_pll
vds::connect_interface_net -dest emif|s0_axi4lite -src axil_driver|axil_driver_axi4_lite
vds::assign_base_address -connection axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite 0x0000
vds::export_interface_pin emif|s0_axi4 to_ddr
vds::export_interface_pin emif|mem_ck_0 mem_ck_0
vds::export_interface_pin emif|mem_0 mem_0
vds::export_pin user_pll|refclk clk_100
vds::export_pin emif|mem_reset_n mem_reset_n
vds::export_pin emif|s0_axi4_ctrl_ready emif_s0_axi4_ctrl_ready
vds::export_pin emif|oct_0 oct_0
vds::export_pin emif|ref_clk ref_clk
vds::connect_net -src reset_handler|conduit_0 -dest user_pll|locked
vds::connect_net -src reset_handler|reset_n_out -dest axil_driver|axil_driver_rst_n
vds::connect_net -src reset_handler|reset_n_out -dest emif|s0_axi4lite_reset_n
vds::connect_net -src rrip|ninit_done -dest emif|core_init_n
vds::connect_net -src rrip|ninit_done -dest user_pll|reset
vds::connect_net -src rrip|ninit_done -dest reset_handler|reset_n_0
vds::export_pin emif|s0_axi4_clock_in to_ddr_clk
vds::connect_net -src user_pll|outclk0 -dest axil_driver|axil_driver_clk
vds::connect_net -src user_pll|outclk0 -dest reset_handler|clk
vds::connect_net -src user_pll|outclk0 -dest emif|s0_axi4lite_clock
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } axil_driver.axil_driver_axi4_lite
vds::validate_system
vds::save_system emif
vds::close_system emif
}
proc create_hps {proj_dir} {
vds::create_system hps -force
vds::create_cell -properties { parameters:EMAC2_Mode {RGMII_with_MDIO} parameters:EMAC2_PinMuxing {IO} parameters:EMIF_AXI_Enable {true} parameters:EMIF_Topology {1} parameters:F2H_IRQ_Enable {true} parameters:H2F_Address_Width {33} parameters:H2F_Width {32} parameters:HPS_IO_Enable {{GPIO0:IO0} {NONE} {UART0:TX} {UART0:RX} {EMAC2:PPS2} {EMAC2:PPSTRIG2} {MDIO2:MDIO} {MDIO2:MDC} {I2C_EMAC1:SDA} {I2C_EMAC1:SCL} {GPIO0:IO10} {HCLK:HPS_OSC_CLK} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {NONE} {SDMMC:DATA0} {SDMMC:DATA1} {SDMMC:CCLK} {GPIO1:IO3} {GPIO1:IO4} {SDMMC:DATA2} {SDMMC:DATA3} {SDMMC:CMD} {JTAG:TCK} {JTAG:TMS} {JTAG:TDO} {JTAG:TDI} {EMAC2:TX_CLK} {EMAC2:TX_CTL} {EMAC2:RX_CLK} {EMAC2:RX_CTL} {EMAC2:TXD0} {EMAC2:TXD1} {EMAC2:RXD0} {EMAC2:RXD1} {EMAC2:TXD2} {EMAC2:TXD3} {EMAC2:RXD2} {EMAC2:RXD3}} parameters:I2CEMAC1_Mode {default} parameters:I2CEMAC1_PinMuxing {IO} parameters:IO_INPUT_DELAY38 {15} parameters:IO_OUTPUT_DELAY36 {15} parameters:LWH2F_Address_Width {21} parameters:MPLL_C0_Override_mhz {800.0} parameters:MPLL_C2_Override_mhz {533.33} parameters:MPLL_Override {true} parameters:MPU_Events_Enable {false} parameters:MPU_clk_freq_override_mhz {533.33} parameters:MPU_clk_override {true} parameters:MPU_core01_freq_override_mhz {800.0} parameters:MPU_core2_freq_override_mhz {800.0} parameters:MPU_core3_freq_override_mhz {800.0} parameters:PPLL_C0_Override_mhz {600.0} parameters:PPLL_C1_Override_mhz {600.0} parameters:PPLL_C2_Override_mhz {24.0} parameters:PPLL_C3_Override_mhz {500.0} parameters:PPLL_Override {true} parameters:PPLL_VCO_Override_mhz {3000.0} parameters:Pwr_mpu_l3_cache_size {2} parameters:SDMMC_Mode {4-bit} parameters:SDMMC_PinMuxing {IO} parameters:UART0_Mode {No_flow_control} parameters:UART0_PinMuxing {IO} parameters:f2s_address_width {37} parameters:f2s_data_width {0} parameters:f2sdram_address_width {37}  } -vlnv altera.com:ip:intel_agilex_5_soc: agx5_hps

# The HPS EMIF has to be imported as a standalone .ip file because its settings
# cannot be expressed inline at all: "-properties" only carries top-level
# "parameters:" values, and this IP keeps almost nothing there. The PD flow sets
# 5 top-level parameters on it (EMIF_PROTOCOL, EMIF_TOPOLOGY and three sharing
# flags) and another 927 on its per-protocol sub-modules - emif_0_lpddr4,
# emif_0_ddr4comp, emif_0_ddr5comp and so on - which "-properties" has no syntax
# for. VDS exports the cell this way itself.
vds::create_cell agx5_hps_emif -type ip -files $proj_dir/src/ip/hps_emif_io96b_hps_0.ip

vds::create_cell -properties { parameters:ADDRESS_WIDTH {16} parameters:MAX_BURST_SIZE {8} parameters:MAX_PENDING_RESPONSES {8}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: csr_bridge
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: csr_clk
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: csr_rst
vds::create_cell -vlnv :ip:f2sdram_adapter: f2sdram_adapter_256
vds::create_cell -properties { parameters:MAX_BURST_COUNT {128}  } -vlnv :ip:msgdma2axi4: msgdma2axi4_256_f
vds::create_cell -properties { parameters:BURST_ENABLE {1} parameters:DATA_FIFO_DEPTH {128} parameters:DATA_WIDTH {256} parameters:ENHANCED_FEATURES {1} parameters:FIX_ADDRESS_WIDTH {38} parameters:MAX_BURST_COUNT {16} parameters:MAX_BYTE {2147483647} parameters:TRANSFER_TYPE {Full Word Accesses Only} parameters:USE_FIX_ADDRESS_WIDTH {1} parameters:WRITE_RESPONSE_ENABLE {1}  } -vlnv altera.com:ip:altera_msgdma: msgdma_256
vds::create_cell -properties { parameters:create_source_clock {true} parameters:probe_width {0} parameters:source_initial_value {1}  } -vlnv altera.com:ip:altera_in_system_sources_probes: src_prb_rst
vds::connect_interface_net -dest agx5_hps_emif|io96b0_to_hps -src agx5_hps|io96b0_to_hps
vds::connect_interface_net -dest agx5_hps|f2sdram -src f2sdram_adapter_256|axi4_man
vds::assign_base_address -connection f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram 0x0000
vds::connect_interface_net -dest msgdma_256|csr_irq -src agx5_hps|fpga2hps_interrupt_irq0
vds::set_interrupt_irq -connection agx5_hps.fpga2hps_interrupt_irq0/msgdma_256.csr_irq 0
vds::connect_interface_net -dest msgdma_256|csr -src agx5_hps|lwhps2fpga
vds::assign_base_address -connection agx5_hps.lwhps2fpga/msgdma_256.csr 0x0000
vds::connect_interface_net -dest msgdma_256|descriptor_slave -src agx5_hps|lwhps2fpga
vds::assign_base_address -connection agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave 0x0020
vds::connect_interface_net -dest csr_bridge|s0 -src agx5_hps|lwhps2fpga
vds::assign_base_address -connection agx5_hps.lwhps2fpga/csr_bridge.s0 0x00010000
vds::connect_interface_net -dest f2sdram_adapter_256|axi4_sub -src msgdma_256|mm_read
vds::assign_base_address -connection msgdma_256.mm_read/f2sdram_adapter_256.axi4_sub 0x0000
vds::connect_interface_net -dest f2sdram_adapter_256|axi4_sub -src msgdma_256|mm_write
vds::assign_base_address -connection msgdma_256.mm_write/f2sdram_adapter_256.axi4_sub 0x0000
vds::connect_interface_net -dest msgdma2axi4_256_f|s1 -src msgdma_256|mm_write
vds::assign_base_address -connection msgdma_256.mm_write/msgdma2axi4_256_f.s1 0x0000002000000000
vds::connect_interface_net -dest msgdma2axi4_256_f|s0 -src msgdma_256|mm_read
vds::assign_base_address -connection msgdma_256.mm_read/msgdma2axi4_256_f.s0 0x0000002000000000
vds::export_interface_pin agx5_hps|hps2fpga hps_to_ddr
vds::export_interface_pin csr_bridge|m0 hps_to_csr
vds::export_interface_pin agx5_hps|hps_io hps_io
vds::export_interface_pin agx5_hps_emif|mem_ck_0 emif_hps_mem_ck_0
vds::export_interface_pin agx5_hps_emif|mem_0 emif_hps_mem_0
vds::export_interface_pin msgdma2axi4_256_f|m0 dma_to_ddr
vds::export_interface_pin agx5_hps|fpga2hps_interrupt_irq1 dla_irq
vds::export_interface_pin agx5_hps|h2f_warm_reset_handshake agx5_hps_h2f_warm_reset_handshake
vds::export_pin agx5_hps|h2f_reset agx5_hps_h2f_reset
vds::export_pin agx5_hps_emif|mem_reset_n emif_hps_mem_reset_n
vds::export_pin csr_clk|in_clk clk_100_in_clk
vds::connect_net -src csr_clk|out_clk -dest csr_bridge|clk
vds::connect_net -src csr_clk|out_clk -dest csr_rst|clk
vds::connect_net -src csr_clk|out_clk -dest f2sdram_adapter_256|clock
vds::connect_net -src csr_clk|out_clk -dest msgdma2axi4_256_f|clock
vds::connect_net -src csr_clk|out_clk -dest msgdma_256|clock
vds::connect_net -src csr_clk|out_clk -dest agx5_hps|f2sdram_axi_clock
vds::connect_net -src csr_clk|out_clk -dest agx5_hps|hps2fpga_axi_clock
vds::connect_net -src csr_clk|out_clk -dest agx5_hps|lwhps2fpga_axi_clock
vds::connect_net -src csr_clk|out_clk -dest src_prb_rst|source_clk
vds::connect_net -src csr_rst|out_reset -dest agx5_hps|f2sdram_axi_reset
vds::connect_net -src csr_rst|out_reset -dest agx5_hps|hps2fpga_axi_reset
vds::connect_net -src csr_rst|out_reset -dest agx5_hps|lwhps2fpga_axi_reset
vds::connect_net -src csr_rst|out_reset -dest csr_bridge|reset
vds::connect_net -src csr_rst|out_reset -dest f2sdram_adapter_256|reset
vds::connect_net -src csr_rst|out_reset -dest msgdma2axi4_256_f|reset
vds::connect_net -src csr_rst|out_reset -dest msgdma_256|reset_n
vds::export_pin csr_rst|in_reset csr_rst_in
vds::export_pin agx5_hps_emif|oct_0 emif_hps_oct_0
vds::export_pin agx5_hps_emif|ref_clk emif_hps_ref_clk
vds::export_pin src_prb_rst|sources src_prb_rst_sources
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } agx5_hps.lwhps2fpga
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } f2sdram_adapter_256.axi4_man
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } msgdma_256.mm_read
vds::validate_system
vds::save_system hps
vds::close_system hps
}
set proj_dir [get_project_directory]
create_hps $proj_dir
create_emif
create_dla
vds::create_system system -force
vds::create_cell -properties { parameters:DATA_WIDTH {256} parameters:ENABLE_SUBORDINATE_PORT {0} parameters:ID_WIDTH {2} parameters:MANAGER_ADDRESS_WIDTH {33} parameters:MAX_PENDING_COMBINE {64} parameters:MAX_PENDING_READS {32} parameters:MAX_PENDING_WRITES {32} parameters:SUBORDINATE_ADDRESS_WIDTH {32} parameters:USE_ARCACHE {1} parameters:USE_ARLOCK {1} parameters:USE_AWCACHE {1} parameters:USE_AWLOCK {1} parameters:USE_BRESP {1} parameters:USE_RRESP {1}  } -vlnv altera.com:ip:axi_address_span_extender: axi_address_span_extender_256
vds::create_cell -properties { parameters:ADDR_WIDTH {33} parameters:AXI_VERSION {AXI4} parameters:COMBINED_ACCEPTANCE_CAPABILITY {64} parameters:COMBINED_ISSUING_CAPABILITY {64} parameters:DATA_WIDTH {256} parameters:M0_ID_WIDTH {6} parameters:READ_ACCEPTANCE_CAPABILITY {32} parameters:READ_ADDR_USER_WIDTH {1} parameters:READ_DATA_USER_WIDTH {1} parameters:READ_ISSUING_CAPABILITY {32} parameters:S0_ID_WIDTH {6} parameters:USE_M0_ARSNOOP {0} parameters:USE_M0_AWSNOOP {0} parameters:USE_M0_AWUNIQUE {0} parameters:USE_S0_ARSIZE {0} parameters:USE_S0_AWSIZE {0} parameters:USE_S0_BID {0} parameters:USE_S0_RID {0} parameters:WRITE_ACCEPTANCE_CAPABILITY {32} parameters:WRITE_ADDR_USER_WIDTH {1} parameters:WRITE_DATA_USER_WIDTH {1} parameters:WRITE_ISSUING_CAPABILITY {32} parameters:WRITE_RESP_USER_WIDTH {1}  } -vlnv altera.com:ip:altera_axi_bridge: axi_bridge_256
vds::create_cell -properties { parameters:ADDR_WIDTH {33} parameters:AXI_VERSION {AXI4} parameters:COMBINED_ACCEPTANCE_CAPABILITY {64} parameters:COMBINED_ISSUING_CAPABILITY {64} parameters:DATA_WIDTH {256} parameters:ENABLE_OOO {1} parameters:M0_ID_WIDTH {7} parameters:READ_ACCEPTANCE_CAPABILITY {32} parameters:READ_ADDR_USER_WIDTH {1} parameters:READ_DATA_REORDERING_DEPTH {16} parameters:READ_DATA_USER_WIDTH {1} parameters:READ_ISSUING_CAPABILITY {32} parameters:S0_ID_WIDTH {7} parameters:USE_M0_ARSNOOP {0} parameters:USE_M0_AWSNOOP {0} parameters:USE_M0_AWUNIQUE {0} parameters:USE_S0_ARSIZE {0} parameters:USE_S0_AWSIZE {0} parameters:USE_S0_BID {0} parameters:USE_S0_RID {0} parameters:WRITE_ACCEPTANCE_CAPABILITY {32} parameters:WRITE_ADDR_USER_WIDTH {1} parameters:WRITE_DATA_USER_WIDTH {1} parameters:WRITE_ISSUING_CAPABILITY {32} parameters:WRITE_RESP_USER_WIDTH {1}  } -vlnv altera.com:ip:altera_axi_bridge: axi_bridge_256_emif
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: clk_100
vds::create_cell -properties { parameters:gui_cascade_outclk_index {5} parameters:gui_clock_name_string0 {clk_dla} parameters:gui_frac_multiply_factor {1} parameters:gui_fractional_cout {32} parameters:gui_location_type {Fabric-Feeding} parameters:gui_number_of_clocks {3} parameters:gui_output_clock_frequency0 {300.0} parameters:gui_output_clock_frequency1 {200.0} parameters:gui_output_clock_frequency_ps0 {3333.333} parameters:gui_output_clock_frequency_ps1 {5000.0} parameters:gui_pll_auto_reset {true} parameters:gui_pll_bandwidth_preset {Medium} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: dla_pll
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: emif_rst_export
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1} parameters:SYNCHRONOUS_EDGES {none}  } -vlnv altera.com:ip:altera_reset_bridge: rst_in
vds::create_cell -vlnv altera.com:ip:intel_user_rst_clkgate: user_rst_clkgate
vds::create_cell dla -type system -ref dla
vds::create_cell emif -type system -ref emif
vds::create_cell hps -type system -ref hps
vds::connect_interface_net -dest axi_bridge_256_emif|s0 -src axi_address_span_extender_256|m_axi4
vds::assign_base_address -connection axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 0x0000
vds::connect_interface_net -dest axi_address_span_extender_256|s_axi4 -src dla|dla_to_ddr
vds::assign_base_address -connection dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 0x0000
vds::connect_interface_net -dest axi_bridge_256_emif|s0 -src axi_bridge_256|m0
vds::assign_base_address -connection axi_bridge_256.m0/axi_bridge_256_emif.s0 0x0000
vds::connect_interface_net -dest axi_bridge_256|s0 -src hps|dma_to_ddr
vds::assign_base_address -connection hps.dma_to_ddr/axi_bridge_256.s0 0x0000
vds::connect_interface_net -dest axi_bridge_256|s0 -src hps|hps_to_ddr
vds::assign_base_address -connection hps.hps_to_ddr/axi_bridge_256.s0 0x0000
vds::connect_interface_net -dest emif|to_ddr -src axi_bridge_256_emif|m0
vds::assign_base_address -connection axi_bridge_256_emif.m0/emif.to_ddr 0x0000
vds::connect_interface_net -dest dla|dla_irq -src hps|dla_irq
vds::set_interrupt_irq -connection hps.dla_irq/dla.dla_irq 0
vds::connect_interface_net -dest dla|csr_bridge -src hps|hps_to_csr
vds::assign_base_address -connection hps.hps_to_csr/dla.csr_bridge 0x0000
vds::export_interface_pin hps|hps_io hps_io
vds::export_interface_pin hps|emif_hps_mem_ck_0 hps_emif_mem_ck_0
vds::export_interface_pin hps|emif_hps_mem_0 hps_emif_mem_0
vds::export_interface_pin hps|agx5_hps_h2f_warm_reset_handshake h2f_warm_reset_handshake
vds::export_interface_pin emif|mem_ck_0 fpga_emif_mem_ck_0
vds::export_interface_pin emif|mem_0 fpga_emif_mem_0
vds::export_pin clk_100|in_clk clk_100
vds::connect_net -src clk_100|out_clk -dest emif_rst_export|clk
vds::connect_net -src clk_100|out_clk -dest emif|clk_100
vds::connect_net -src clk_100|out_clk -dest dla_pll|refclk
vds::export_pin dla_pll|locked dla_pll_locked
vds::connect_net -src dla_pll|outclk0 -dest dla|dla_clk
vds::connect_net -src dla_pll|outclk1 -dest axi_address_span_extender_256|clk
vds::connect_net -src dla_pll|outclk1 -dest axi_bridge_256_emif|clk
vds::connect_net -src dla_pll|outclk1 -dest dla|ddr_clk
vds::connect_net -src dla_pll|outclk1 -dest emif|to_ddr_clk
vds::connect_net -src dla_pll|outclk2 -dest axi_bridge_256|clk
vds::connect_net -src dla_pll|outclk2 -dest hps|clk_100_in_clk
vds::connect_net -src dla_pll|outclk2 -dest dla|csr_clk
vds::connect_net -src emif|emif_s0_axi4_ctrl_ready -dest emif_rst_export|in_reset
vds::export_pin emif|mem_reset_n fpga_emif_mem_reset_n
vds::export_pin emif_rst_export|out_reset ddr4_emif_usr_reset_n
vds::export_pin emif|oct_0 fpga_emif_oct_0
vds::export_pin emif|ref_clk fpga_emif_ref_clk
vds::export_pin hps|agx5_hps_h2f_reset h2f_reset
vds::export_pin hps|emif_hps_mem_reset_n hps_emif_mem_reset_n
vds::export_pin hps|src_prb_rst_sources src_prb_rst_sources
vds::export_pin hps|emif_hps_oct_0 hps_emif_oct_0
vds::export_pin hps|emif_hps_ref_clk hps_emif_pll_ref_clk
vds::export_pin rst_in|in_reset reset
vds::connect_net -src rst_in|out_reset -dest axi_bridge_256|clk_reset
vds::connect_net -src rst_in|out_reset -dest axi_bridge_256_emif|clk_reset
vds::connect_net -src rst_in|out_reset -dest dla|csr_rst
vds::connect_net -src rst_in|out_reset -dest hps|csr_rst_in
vds::connect_net -src rst_in|out_reset -dest dla|ddr_rst
vds::connect_net -src rst_in|out_reset -dest dla|dla_resetn
vds::connect_net -src rst_in|out_reset -dest axi_address_span_extender_256|reset
vds::connect_net -src rst_in|out_reset -dest dla_pll|reset
vds::export_pin user_rst_clkgate|ninit_done ninit_done
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter FIFO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } axi_bridge_256.m0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter FIFO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } axi_bridge_256_emif.m0
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } dla.dla_to_ddr
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter FIFO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } hps.dma_to_ddr
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter FIFO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } hps.hps_to_csr
vds::set_pipelines {mm_interconnect_0|addr_extend_0_windowed_slave_burst_adapter.source0/addr_extend_0_windowed_slave_agent.cp 1 mm_interconnect_0|addr_extend_0_windowed_slave_cmd_width_adapter.src/addr_extend_0_windowed_slave_burst_adapter.sink0 1 mm_interconnect_0|dla_0_dla_to_ddr_agent.cp/router.sink 1 }
vds::validate_system
vds::save_system system

post_message "Script completed successfully."

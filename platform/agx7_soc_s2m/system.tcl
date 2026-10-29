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
vds::create_cell -vlnv altera.com:ip:altera_ai_ip: altera_ai_ip_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {16}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: csr_bridge_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: csr_clk_0
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge: csr_rst_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {31} parameters:DATA_WIDTH {512} parameters:MAX_BURST_SIZE {64} parameters:MAX_PENDING_RESPONSES {16}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: ddr_bridge_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: ddr_clk_0
vds::create_cell -vlnv altera.com:ip:altera_reset_bridge: ddr_rst_0
vds::create_cell -vlnv altera.com:ip:altera_clock_bridge: dla_clk_0
vds::create_cell -properties { parameters:BURST_ENABLE {1} parameters:DATA_FIFO_DEPTH {4096} parameters:DATA_WIDTH {512} parameters:ENHANCED_FEATURES {1} parameters:MAX_BURST_COUNT {4} parameters:MAX_BYTE {1073741824} parameters:MODE {2}  } -vlnv altera.com:ip:altera_msgdma: dla_msgdma_0
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: dla_rst_0
vds::create_cell -vlnv altera.com:ip:altera_avalon_jtag_uart: jtag_uart_0
vds::create_cell -vlnv altera.com:ip:intel_onchip_memory: mailbox_ram_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {31} parameters:COMMAND_FIFO_DEPTH {8} parameters:DATA_WIDTH {512} parameters:MASTER_SYNC_DEPTH {3} parameters:RESPONSE_FIFO_DEPTH {8} parameters:SLAVE_SYNC_DEPTH {3}  } -vlnv altera.com:ip:mm_ccb: mm_ccb_0
vds::create_cell -vlnv altera.com:ip:intel_niosv_m: niosv_0
vds::create_cell -properties { parameters:initializationFileName {stream_controller.hex} parameters:memorySize {131072} parameters:useNonDefaultInitFile {true}  } -vlnv altera.com:ip:intel_onchip_memory: niosv_ram_0
vds::connect_interface_net -dest ddr_bridge_0|s0 -src altera_ai_ip_0|ddr_axi
vds::assign_base_address -connection altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 0x0000
vds::connect_interface_net -dest altera_ai_ip_0|csr_axi -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/altera_ai_ip_0.csr_axi 0x00030000
vds::connect_interface_net -dest altera_ai_ip_0|csr_axi -src csr_bridge_0|m0
vds::assign_base_address -connection csr_bridge_0.m0/altera_ai_ip_0.csr_axi 0x4000
vds::connect_interface_net -dest mailbox_ram_0|s1 -src csr_bridge_0|m0
vds::assign_base_address -connection csr_bridge_0.m0/mailbox_ram_0.s1 0x0000
vds::connect_interface_net -dest ddr_bridge_0|s0 -src mm_ccb_0|m0
vds::assign_base_address -connection mm_ccb_0.m0/ddr_bridge_0.s0 0x0000
vds::connect_interface_net -dest mm_ccb_0|s0 -src dla_msgdma_0|mm_write
vds::assign_base_address -connection dla_msgdma_0.mm_write/mm_ccb_0.s0 0x0000
vds::connect_interface_net -dest dla_msgdma_0|csr_irq -src niosv_0|platform_irq_rx
vds::set_interrupt_irq -connection niosv_0.platform_irq_rx/dla_msgdma_0.csr_irq 0
vds::connect_interface_net -dest dla_msgdma_0|descriptor_slave -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/dla_msgdma_0.descriptor_slave 0x00050020
vds::connect_interface_net -dest dla_msgdma_0|csr -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/dla_msgdma_0.csr 0x00050000
vds::connect_interface_net -dest jtag_uart_0|irq -src niosv_0|platform_irq_rx
vds::set_interrupt_irq -connection niosv_0.platform_irq_rx/jtag_uart_0.irq 1
vds::connect_interface_net -dest jtag_uart_0|avalon_jtag_slave -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave 0x00080000
vds::connect_interface_net -dest mailbox_ram_0|s1 -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/mailbox_ram_0.s1 0x00040000
vds::connect_interface_net -dest niosv_0|dm_agent -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/niosv_0.dm_agent 0x00070000
vds::connect_interface_net -dest niosv_0|dm_agent -src niosv_0|instruction_manager
vds::assign_base_address -connection niosv_0.instruction_manager/niosv_0.dm_agent 0x00070000
vds::connect_interface_net -dest niosv_0|timer_sw_agent -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/niosv_0.timer_sw_agent 0x00020000
vds::connect_interface_net -dest niosv_ram_0|s1 -src niosv_0|data_manager
vds::assign_base_address -connection niosv_0.data_manager/niosv_ram_0.s1 0x0000
vds::connect_interface_net -dest niosv_ram_0|s1 -src niosv_0|instruction_manager
vds::assign_base_address -connection niosv_0.instruction_manager/niosv_ram_0.s1 0x0000
vds::export_interface_pin dla_msgdma_0|st_sink streaming_in
vds::export_interface_pin ddr_bridge_0|m0 dla_to_ddr
vds::export_interface_pin altera_ai_ip_0|irq_level dla_irq
vds::export_interface_pin csr_bridge_0|s0 csr_bridge
vds::export_pin csr_clk_0|in_clk csr_clk
vds::connect_net -src csr_clk_0|out_clk -dest csr_bridge_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest csr_rst_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest dla_rst_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest jtag_uart_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest niosv_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest mailbox_ram_0|clk1
vds::connect_net -src csr_clk_0|out_clk -dest niosv_ram_0|clk1
vds::connect_net -src csr_clk_0|out_clk -dest dla_msgdma_0|clock
vds::connect_net -src csr_clk_0|out_clk -dest altera_ai_ip_0|irq_clk
vds::connect_net -src csr_clk_0|out_clk -dest mm_ccb_0|s0_clk
vds::export_pin csr_rst_0|in_reset csr_rst
vds::connect_net -src csr_rst_0|out_reset -dest csr_bridge_0|reset
vds::connect_net -src csr_rst_0|out_reset -dest jtag_uart_0|reset
vds::connect_net -src csr_rst_0|out_reset -dest niosv_0|reset
vds::connect_net -src csr_rst_0|out_reset -dest mailbox_ram_0|reset1
vds::connect_net -src csr_rst_0|out_reset -dest niosv_ram_0|reset1
vds::connect_net -src csr_rst_0|out_reset -dest dla_msgdma_0|reset_n
vds::connect_net -src csr_rst_0|out_reset -dest mm_ccb_0|s0_reset
vds::export_pin ddr_clk_0|in_clk ddr_clk
vds::connect_net -src ddr_clk_0|out_clk -dest ddr_bridge_0|clk
vds::connect_net -src ddr_clk_0|out_clk -dest ddr_rst_0|clk
vds::connect_net -src ddr_clk_0|out_clk -dest altera_ai_ip_0|ddr_clk
vds::connect_net -src ddr_clk_0|out_clk -dest mm_ccb_0|m0_clk
vds::export_pin ddr_rst_0|in_reset ddr_rst
vds::connect_net -src ddr_rst_0|out_reset -dest mm_ccb_0|m0_reset
vds::connect_net -src ddr_rst_0|out_reset -dest ddr_bridge_0|reset
vds::export_pin dla_clk_0|in_clk dla_clk
vds::connect_net -src dla_clk_0|out_clk -dest altera_ai_ip_0|dla_clk
vds::export_pin dla_rst_0|in_reset dla_resetn
vds::connect_net -src dla_rst_0|out_reset -dest altera_ai_ip_0|dla_resetn
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets FALSE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } altera_ai_ip_0.ddr_axi
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } dla_msgdma_0.mm_write
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets FALSE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } niosv_0.data_manager
vds::validate_system
vds::save_system dla
vds::close_system dla
}
proc create_emif {} {
vds::create_system emif -force
vds::create_cell -properties { parameters:BOARD_DDR4_IS_SKEW_WITHIN_DQS_DESKEWED {true} parameters:CTRL_DDR4_ECC_EN {true} parameters:CTRL_DDR4_POST_REFRESH_EN {true} parameters:DIAG_DDR4_EX_DESIGN_ISSP_EN {false} parameters:DIAG_EXPORT_PLL_LOCKED {true} parameters:MEM_DDR4_ALERT_N_PLACEMENT_ENUM {DDR4_ALERT_N_PLACEMENT_FM_LANE3} parameters:MEM_DDR4_FORMAT_ENUM {MEM_FORMAT_RDIMM} parameters:MEM_DDR4_READ_DBI {false} parameters:MEM_DDR4_ROW_ADDR_WIDTH {17} parameters:MEM_DDR4_SPEEDBIN_ENUM {DDR4_SPEEDBIN_3200} parameters:MEM_DDR4_TCCD_L_CYC {7} parameters:MEM_DDR4_TCL {20} parameters:MEM_DDR4_TDIVW_TOTAL_UI {0.23} parameters:MEM_DDR4_TDQSCK_PS {160} parameters:MEM_DDR4_TDQSQ_UI {0.2} parameters:MEM_DDR4_TFAW_NS {12.0} parameters:MEM_DDR4_TIH_DC_MV {65} parameters:MEM_DDR4_TIH_PS {65} parameters:MEM_DDR4_TIS_AC_MV {90} parameters:MEM_DDR4_TIS_PS {40} parameters:MEM_DDR4_TQH_UI {0.7} parameters:MEM_DDR4_TQSH_CYC {0.4} parameters:MEM_DDR4_TRCD_NS {13.75} parameters:MEM_DDR4_TRFC_NS {350.0} parameters:MEM_DDR4_TRP_NS {13.75} parameters:MEM_DDR4_TRRD_L_CYC {7} parameters:MEM_DDR4_TWTR_L_CYC {10} parameters:MEM_DDR4_TWTR_S_CYC {4} parameters:MEM_DDR4_VDIVW_TOTAL {110} parameters:MEM_DDR4_WTCL {18} parameters:PHY_DDR4_DEFAULT_REF_CLK_FREQ {false} parameters:PHY_DDR4_MEM_CLK_FREQ_MHZ {1333.33} parameters:PHY_DDR4_USER_REF_CLK_FREQ_MHZ {166.666}  } -vlnv altera.com:ip:altera_emif_fm: emif_agx_0
vds::create_cell -vlnv altera.com:ip:altera_emif_cal: emif_cal_0
vds::connect_interface_net -dest emif_cal_0|emif_calbus_0 -src emif_agx_0|emif_calbus
vds::export_interface_pin emif_agx_0|ctrl_amm_0 to_ddr
vds::export_interface_pin emif_agx_0|status emif_agx_0_status
vds::export_interface_pin emif_agx_0|mem emif_agx_0_mem
vds::export_pin emif_agx_0|emif_usr_clk emif_agx_0_emif_usr_clk
vds::export_pin emif_agx_0|emif_usr_reset_n emif_agx_0_emif_usr_reset_n
vds::export_pin emif_agx_0|local_reset_status emif_agx_0_local_reset_status
vds::export_pin emif_agx_0|pll_locked emif_agx_0_pll_locked
vds::export_pin emif_agx_0|local_reset_req emif_agx_0_local_reset_req
vds::export_pin emif_agx_0|oct emif_agx_0_oct
vds::export_pin emif_agx_0|pll_ref_clk emif_agx_0_pll_ref_clk
vds::connect_net -src emif_cal_0|emif_calbus_clk -dest emif_agx_0|emif_calbus_clk
vds::validate_system
vds::save_system emif
vds::close_system emif
}
proc create_hps {} {
vds::create_system hps -force
vds::create_cell -properties { parameters:EMAC0_Mode {RGMII_with_MDIO} parameters:EMAC0_PinMuxing {IO} parameters:EMIF_DDR_WIDTH {64} parameters:F2SINTERRUPT_Enable {true} parameters:F2S_ADDRESS_WIDTH {37} parameters:F2S_Route_config {0} parameters:F2S_Width {5} parameters:HPS_IO_Enable {{USB0:CLK} {USB0:STP} {USB0:DIR} {USB0:DATA0} {USB0:DATA1} {USB0:NXT} {USB0:DATA2} {USB0:DATA3} {USB0:DATA4} {USB0:DATA5} {USB0:DATA6} {USB0:DATA7} {EMAC0:TX_CLK} {EMAC0:TX_CTL} {EMAC0:RX_CLK} {EMAC0:RX_CTL} {EMAC0:TXD0} {EMAC0:TXD1} {EMAC0:RXD0} {EMAC0:RXD1} {EMAC0:TXD2} {EMAC0:TXD3} {EMAC0:RXD2} {EMAC0:RXD3} {GPIO} {GPIO} {UART0:TX} {UART0:RX} {GPIO} {GPIO} {I2C1:SDA} {I2C1:SCL} {JTAG:TCK} {JTAG:TMS} {JTAG:TDO} {JTAG:TDI} {SDMMC:D0} {SDMMC:CMD} {SDMMC:CCLK} {SDMMC:D1} {SDMMC:D2} {SDMMC:D3} {HPS_OSC_CLK} {GPIO} {GPIO} {GPIO} {MDIO0:MDIO} {MDIO0:MDC}} parameters:I2C1_Mode {default} parameters:I2C1_PinMuxing {IO} parameters:MPU_EVENTS_Enable {false} parameters:S2F_ADDRESS_WIDTH {30} parameters:S2F_Width {1} parameters:SDMMC_Mode {4-bit} parameters:SDMMC_PinMuxing {IO} parameters:STM_Enable {true} parameters:UART0_Mode {No_flow_control} parameters:UART0_PinMuxing {IO} parameters:USB0_Mode {default} parameters:USB0_PinMuxing {IO} parameters:watchdog_reset {true}  } -vlnv altera.com:ip:intel_agilex_hps: agx_hps
vds::create_cell -properties { parameters:ADDRESS_WIDTH {16} parameters:MAX_BURST_SIZE {8} parameters:MAX_PENDING_RESPONSES {8}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: csr_bridge_0
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: csr_clk_0
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1} parameters:SYNCHRONOUS_EDGES {none}  } -vlnv altera.com:ip:altera_reset_bridge: csr_rst_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {37} parameters:DATA_WIDTH {512} parameters:MAX_BURST_SIZE {8} parameters:MAX_PENDING_RESPONSES {8}  } -vlnv altera.com:ip:altera_avalon_mm_bridge: dma_bridge_0
vds::create_cell -vlnv altera.com:ip:altera_emif_cal: emif_cal_0
vds::create_cell -properties { parameters:BOARD_DDR4_IS_SKEW_WITHIN_DQS_DESKEWED {true} parameters:CTRL_DDR4_ECC_AUTO_CORRECTION_EN {true} parameters:CTRL_DDR4_ECC_EN {true} parameters:MEM_DDR4_BANK_GROUP_WIDTH {1} parameters:MEM_DDR4_DQ_WIDTH {72} parameters:MEM_DDR4_FORMAT_ENUM {MEM_FORMAT_DISCRETE} parameters:MEM_DDR4_ROW_ADDR_WIDTH {17} parameters:MEM_DDR4_SPEEDBIN_ENUM {DDR4_SPEEDBIN_3200} parameters:MEM_DDR4_TCCD_L_CYC {7} parameters:MEM_DDR4_TCL {23} parameters:MEM_DDR4_TDIVW_TOTAL_UI {0.23} parameters:MEM_DDR4_TDQSCK_PS {160} parameters:MEM_DDR4_TDQSQ_UI {0.2} parameters:MEM_DDR4_TFAW_NS {30.0} parameters:MEM_DDR4_TIH_DC_MV {65} parameters:MEM_DDR4_TIH_PS {65} parameters:MEM_DDR4_TIS_AC_MV {90} parameters:MEM_DDR4_TIS_PS {40} parameters:MEM_DDR4_TQH_UI {0.7} parameters:MEM_DDR4_TQSH_CYC {0.4} parameters:MEM_DDR4_TRCD_NS {13.75} parameters:MEM_DDR4_TRFC_NS {350.0} parameters:MEM_DDR4_TRP_NS {13.75} parameters:MEM_DDR4_TRRD_L_CYC {9} parameters:MEM_DDR4_TRRD_S_CYC {8} parameters:MEM_DDR4_TWTR_L_CYC {10} parameters:MEM_DDR4_TWTR_S_CYC {4} parameters:MEM_DDR4_VDIVW_TOTAL {110} parameters:MEM_DDR4_WTCL {18} parameters:PHY_DDR4_DEFAULT_IO {false} parameters:PHY_DDR4_DEFAULT_REF_CLK_FREQ {false} parameters:PHY_DDR4_MEM_CLK_FREQ_MHZ {1333.33} parameters:PHY_DDR4_USER_AC_DEEMPHASIS_ENUM {DEEMPHASIS_MODE_OFF} parameters:PHY_DDR4_USER_AC_IO_STD_ENUM {IO_STD_SSTL_12} parameters:PHY_DDR4_USER_AC_MODE_ENUM {OUT_OCT_40_CAL} parameters:PHY_DDR4_USER_CK_DEEMPHASIS_ENUM {DEEMPHASIS_MODE_OFF} parameters:PHY_DDR4_USER_CK_IO_STD_ENUM {IO_STD_SSTL_12} parameters:PHY_DDR4_USER_CK_MODE_ENUM {OUT_OCT_40_CAL} parameters:PHY_DDR4_USER_DATA_IN_MODE_ENUM {IN_OCT_60_CAL} parameters:PHY_DDR4_USER_DATA_IO_STD_ENUM {IO_STD_POD_12} parameters:PHY_DDR4_USER_DATA_OUT_DEEMPHASIS_ENUM {DEEMPHASIS_MODE_HIGH} parameters:PHY_DDR4_USER_DATA_OUT_MODE_ENUM {OUT_OCT_34_CAL} parameters:PHY_DDR4_USER_PLL_REF_CLK_IO_STD_ENUM {IO_STD_TRUE_DIFF_SIGNALING} parameters:PHY_DDR4_USER_REF_CLK_FREQ_MHZ {166.666} parameters:PHY_DDR4_USER_RZQ_IO_STD_ENUM {IO_STD_CMOS_12}  } -vlnv altera.com:ip:altera_emif_fm_hps: emif_hps
vds::create_cell -properties { parameters:BURST_ENABLE {1} parameters:DATA_WIDTH {512} parameters:ENHANCED_FEATURES {1} parameters:FIX_ADDRESS_WIDTH {38} parameters:MAX_BURST_COUNT {4} parameters:MAX_BYTE {2147483647} parameters:USE_FIX_ADDRESS_WIDTH {1} parameters:WRITE_RESPONSE_ENABLE {1}  } -vlnv altera.com:ip:altera_msgdma: msgdma_0
vds::create_cell -properties { parameters:BURST_ENABLE {1} parameters:DATA_FIFO_DEPTH {1024} parameters:DATA_WIDTH {512} parameters:ENHANCED_FEATURES {1} parameters:FIX_ADDRESS_WIDTH {38} parameters:MAX_BURST_COUNT {4} parameters:MAX_BYTE {1073741824} parameters:MODE {1} parameters:USE_FIX_ADDRESS_WIDTH {1}  } -vlnv altera.com:ip:altera_msgdma: msgdma_1
vds::create_cell -properties { parameters:create_source_clock {true} parameters:probe_width {0} parameters:source_initial_value {1}  } -vlnv altera.com:ip:altera_in_system_sources_probes: src_prb_rst
vds::create_cell -vlnv altera.com:ip:altera_s10_user_rst_clkgate: user_rst_clkgate_0
vds::connect_interface_net -dest msgdma_0|csr_irq -src agx_hps|f2h_irq0
vds::set_interrupt_irq -connection agx_hps.f2h_irq0/msgdma_0.csr_irq 0
vds::connect_interface_net -dest msgdma_1|csr_irq -src agx_hps|f2h_irq0
vds::set_interrupt_irq -connection agx_hps.f2h_irq0/msgdma_1.csr_irq 1
vds::connect_interface_net -dest agx_hps|f2h_axi_slave -src msgdma_0|mm_read
vds::assign_base_address -connection msgdma_0.mm_read/agx_hps.f2h_axi_slave 0x0000
vds::connect_interface_net -dest agx_hps|f2h_axi_slave -src msgdma_1|mm_read
vds::assign_base_address -connection msgdma_1.mm_read/agx_hps.f2h_axi_slave 0x0000
vds::connect_interface_net -dest agx_hps|f2h_axi_slave -src msgdma_0|mm_write
vds::assign_base_address -connection msgdma_0.mm_write/agx_hps.f2h_axi_slave 0x0000
vds::connect_interface_net -dest msgdma_0|csr -src agx_hps|h2f_lw_axi_master
vds::assign_base_address -connection agx_hps.h2f_lw_axi_master/msgdma_0.csr 0x0000
vds::connect_interface_net -dest msgdma_1|csr -src agx_hps|h2f_lw_axi_master
vds::assign_base_address -connection agx_hps.h2f_lw_axi_master/msgdma_1.csr 0x1000
vds::connect_interface_net -dest msgdma_0|descriptor_slave -src agx_hps|h2f_lw_axi_master
vds::assign_base_address -connection agx_hps.h2f_lw_axi_master/msgdma_0.descriptor_slave 0x0020
vds::connect_interface_net -dest msgdma_1|descriptor_slave -src agx_hps|h2f_lw_axi_master
vds::assign_base_address -connection agx_hps.h2f_lw_axi_master/msgdma_1.descriptor_slave 0x1020
vds::connect_interface_net -dest csr_bridge_0|s0 -src agx_hps|h2f_lw_axi_master
vds::assign_base_address -connection agx_hps.h2f_lw_axi_master/csr_bridge_0.s0 0x00010000
vds::connect_interface_net -dest agx_hps|hps_emif -src emif_hps|hps_emif
vds::connect_interface_net -dest dma_bridge_0|s0 -src msgdma_0|mm_read
vds::assign_base_address -connection msgdma_0.mm_read/dma_bridge_0.s0 0x0000002000000000
vds::connect_interface_net -dest dma_bridge_0|s0 -src msgdma_0|mm_write
vds::assign_base_address -connection msgdma_0.mm_write/dma_bridge_0.s0 0x0000002000000000
vds::connect_interface_net -dest emif_hps|emif_calbus -src emif_cal_0|emif_calbus_0
vds::export_interface_pin msgdma_1|st_source streaming_out
vds::export_interface_pin agx_hps|h2f_axi_master hps_to_ddr
vds::export_interface_pin csr_bridge_0|m0 hps_to_csr
vds::export_interface_pin emif_hps|mem emif_hps_mem
vds::export_interface_pin dma_bridge_0|m0 dma_to_ddr
vds::export_interface_pin agx_hps|f2h_irq1 dla_irq
vds::export_interface_pin agx_hps|hps_io agx_hps_hps_io
vds::export_pin agx_hps|h2f_reset agx_hps_h2f_reset
vds::export_pin agx_hps|h2f_watchdog_rst agx_hps_h2f_watchdog_rst
vds::export_pin agx_hps|f2h_stm_hw_events agx_hps_f2h_stm_hw_events
vds::export_pin csr_clk_0|in_clk clk_100_in_clk
vds::connect_net -src csr_clk_0|out_clk -dest csr_bridge_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest dma_bridge_0|clk
vds::connect_net -src csr_clk_0|out_clk -dest msgdma_0|clock
vds::connect_net -src csr_clk_0|out_clk -dest msgdma_1|clock
vds::connect_net -src csr_clk_0|out_clk -dest agx_hps|f2h_axi_clock
vds::connect_net -src csr_clk_0|out_clk -dest agx_hps|h2f_axi_clock
vds::connect_net -src csr_clk_0|out_clk -dest agx_hps|h2f_lw_axi_clock
vds::connect_net -src csr_clk_0|out_clk -dest src_prb_rst|source_clk
vds::connect_net -src csr_rst_0|out_reset -dest agx_hps|f2h_axi_reset
vds::connect_net -src csr_rst_0|out_reset -dest agx_hps|h2f_axi_reset
vds::connect_net -src csr_rst_0|out_reset -dest agx_hps|h2f_lw_axi_reset
vds::connect_net -src csr_rst_0|out_reset -dest csr_bridge_0|reset
vds::connect_net -src csr_rst_0|out_reset -dest dma_bridge_0|reset
vds::connect_net -src csr_rst_0|out_reset -dest msgdma_0|reset_n
vds::connect_net -src csr_rst_0|out_reset -dest msgdma_1|reset_n
vds::connect_net -src emif_cal_0|emif_calbus_clk -dest emif_hps|emif_calbus_clk
vds::export_pin emif_hps|oct emif_hps_oct
vds::export_pin emif_hps|pll_ref_clk emif_hps_pll_ref_clk
vds::export_pin csr_rst_0|in_reset rst_in_in_reset
vds::export_pin src_prb_rst|sources src_prb_rst_sources
vds::export_pin user_rst_clkgate_0|ninit_done user_rst_clkgate_0_ninit_done
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } agx_hps.h2f_lw_axi_master
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } msgdma_0.mm_read
vds::validate_system
vds::save_system hps
vds::close_system hps
}
create_hps
create_emif
create_dla
vds::create_system system -force
vds::create_cell -properties { parameters:BURSTCOUNT_WIDTH {7} parameters:DATA_WIDTH {512} parameters:ENABLE_SLAVE_PORT {false} parameters:MASTER_ADDRESS_WIDTH {34} parameters:MAX_PENDING_READS {16} parameters:SLAVE_ADDRESS_WIDTH {24}  } -vlnv altera.com:ip:altera_address_span_extender: addr_extend_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {30} parameters:DATA_WIDTH {512} parameters:SYNC_RESET {0}  } -vlnv altera.com:ip:axi_mm_ccb: axi_mm_ccb_0
vds::create_cell -properties { parameters:ADDR_WIDTH {30}  } -vlnv :ip:axi_no_burst_rmw_width_adapter: axi_no_burst_rmw_width_adapter_0
vds::create_cell -properties { parameters:EXPLICIT_CLOCK_RATE {100000000}  } -vlnv altera.com:ip:altera_clock_bridge: clk_100_0
vds::create_cell -properties { parameters:gui_clock_name_string0 {clk_dla} parameters:gui_frac_multiply_factor {1} parameters:gui_fractional_cout {32} parameters:gui_location_type {Fabric-Feeding} parameters:gui_output_clock_frequency0 {400.0} parameters:gui_output_clock_frequency_ps0 {2500.0} parameters:gui_pll_auto_reset {true} parameters:gui_pll_bandwidth_preset {Medium} parameters:gui_pll_type {S10_Simple} parameters:gui_simulation_type {false} parameters:hp_qsys_scripting_mode {false}  } -vlnv altera.com:ip:altera_iopll: dla_pll_0
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: emif_rst_export_0
vds::create_cell -properties { parameters:ADDRESS_WIDTH {37} parameters:DATA_WIDTH {512} parameters:MAX_BURST_SIZE {16} parameters:RESPONSE_FIFO_DEPTH {64}  } -vlnv altera.com:ip:mm_ccb: mm_ccb_0
vds::create_cell -properties { parameters:ACTIVE_LOW_RESET {1}  } -vlnv altera.com:ip:altera_reset_bridge: rst_100_0
vds::create_cell dla_0 -type system -ref dla
vds::create_cell emif_0 -type system -ref emif
vds::create_cell hps_0 -type system -ref hps
vds::connect_interface_net -dest emif_0|to_ddr -src addr_extend_0|expanded_master
vds::assign_base_address -connection addr_extend_0.expanded_master/emif_0.to_ddr 0x0000
vds::connect_interface_net -dest addr_extend_0|windowed_slave -src dla_0|dla_to_ddr
vds::assign_base_address -connection dla_0.dla_to_ddr/addr_extend_0.windowed_slave 0x0000
vds::connect_interface_net -dest addr_extend_0|windowed_slave -src axi_mm_ccb_0|m_axi4
vds::assign_base_address -connection axi_mm_ccb_0.m_axi4/addr_extend_0.windowed_slave 0x0000
vds::connect_interface_net -dest axi_mm_ccb_0|s_axi4 -src axi_no_burst_rmw_width_adapter_0|altera_axi4_master
vds::assign_base_address -connection axi_no_burst_rmw_width_adapter_0.altera_axi4_master/axi_mm_ccb_0.s_axi4 0x0000
vds::connect_interface_net -dest axi_no_burst_rmw_width_adapter_0|altera_axi4_slave -src hps_0|hps_to_ddr
vds::assign_base_address -connection hps_0.hps_to_ddr/axi_no_burst_rmw_width_adapter_0.altera_axi4_slave 0x0000
vds::connect_interface_net -dest emif_0|to_ddr -src mm_ccb_0|m0
vds::assign_base_address -connection mm_ccb_0.m0/emif_0.to_ddr 0x0000
vds::connect_interface_net -dest mm_ccb_0|s0 -src hps_0|dma_to_ddr
vds::assign_base_address -connection hps_0.dma_to_ddr/mm_ccb_0.s0 0x0000
vds::connect_interface_net -dest dla_0|streaming_in -src hps_0|streaming_out
vds::connect_interface_net -dest dla_0|dla_irq -src hps_0|dla_irq
vds::set_interrupt_irq -connection hps_0.dla_irq/dla_0.dla_irq 0
vds::connect_interface_net -dest dla_0|csr_bridge -src hps_0|hps_to_csr
vds::assign_base_address -connection hps_0.hps_to_csr/dla_0.csr_bridge 0x0000
vds::export_interface_pin hps_0|agx_hps_hps_io hps_io
vds::export_interface_pin hps_0|emif_hps_mem emif_hps_mem
vds::export_interface_pin emif_0|emif_agx_0_status emif_0_emif_agx_0_status
vds::export_interface_pin emif_0|emif_agx_0_mem emif_0_emif_agx_0_mem
vds::export_pin hps_0|agx_hps_f2h_stm_hw_events agx_hps_f2h_stm_hw_events
vds::export_pin clk_100_0|in_clk clk_100
vds::connect_net -src clk_100_0|out_clk -dest emif_rst_export_0|clk
vds::connect_net -src clk_100_0|out_clk -dest rst_100_0|clk
vds::connect_net -src clk_100_0|out_clk -dest hps_0|clk_100_in_clk
vds::connect_net -src clk_100_0|out_clk -dest axi_no_burst_rmw_width_adapter_0|clock_sink
vds::connect_net -src clk_100_0|out_clk -dest dla_0|csr_clk
vds::connect_net -src clk_100_0|out_clk -dest dla_pll_0|refclk
vds::connect_net -src clk_100_0|out_clk -dest mm_ccb_0|s0_clk
vds::connect_net -src clk_100_0|out_clk -dest axi_mm_ccb_0|s_axi4_clk
vds::export_pin dla_0|dla_resetn dla_0_dla_resetn
vds::export_pin dla_pll_0|locked dla_pll_locked
vds::connect_net -src dla_pll_0|outclk0 -dest dla_0|dla_clk
vds::connect_net -src emif_0|emif_agx_0_emif_usr_clk -dest addr_extend_0|clock
vds::connect_net -src emif_0|emif_agx_0_emif_usr_clk -dest dla_0|ddr_clk
vds::connect_net -src emif_0|emif_agx_0_emif_usr_clk -dest mm_ccb_0|m0_clk
vds::connect_net -src emif_0|emif_agx_0_emif_usr_clk -dest axi_mm_ccb_0|m_axi4_clk
vds::connect_net -src emif_0|emif_agx_0_emif_usr_reset_n -dest dla_0|ddr_rst
vds::connect_net -src emif_0|emif_agx_0_emif_usr_reset_n -dest emif_rst_export_0|in_reset
vds::connect_net -src emif_0|emif_agx_0_emif_usr_reset_n -dest mm_ccb_0|m0_reset
vds::connect_net -src emif_0|emif_agx_0_emif_usr_reset_n -dest axi_mm_ccb_0|m_axi4_reset
vds::connect_net -src emif_0|emif_agx_0_emif_usr_reset_n -dest addr_extend_0|reset
vds::export_pin emif_0|emif_agx_0_pll_locked emif_0_emif_agx_0_pll_locked
vds::export_pin emif_0|emif_agx_0_local_reset_req emif_0_emif_agx_0_local_reset_req
vds::export_pin emif_0|emif_agx_0_oct emif_0_emif_agx_0_oct
vds::export_pin emif_0|emif_agx_0_pll_ref_clk emif_0_emif_agx_0_pll_ref_clk
vds::export_pin hps_0|emif_hps_oct emif_hps_oct
vds::export_pin hps_0|emif_hps_pll_ref_clk emif_hps_pll_ref_clk
vds::export_pin emif_rst_export_0|out_reset ddr4_emif_usr_reset_n
vds::export_pin hps_0|agx_hps_h2f_reset h2f_reset
vds::export_pin hps_0|agx_hps_h2f_watchdog_rst wd_reset
vds::export_pin hps_0|src_prb_rst_sources src_prb_rst_sources
vds::export_pin hps_0|user_rst_clkgate_0_ninit_done ninit_done
vds::export_pin rst_100_0|in_reset reset
vds::connect_net -src rst_100_0|out_reset -dest dla_0|csr_rst
vds::connect_net -src rst_100_0|out_reset -dest dla_pll_0|reset
vds::connect_net -src rst_100_0|out_reset -dest axi_no_burst_rmw_width_adapter_0|reset_sink
vds::connect_net -src rst_100_0|out_reset -dest hps_0|rst_in_in_reset
vds::connect_net -src rst_100_0|out_reset -dest mm_ccb_0|s0_reset
vds::connect_net -src rst_100_0|out_reset -dest axi_mm_ccb_0|s_axi4_reset
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } addr_extend_0.expanded_master
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } axi_no_burst_rmw_width_adapter_0.altera_axi4_master
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } dla_0.dla_to_ddr
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } hps_0.dma_to_ddr
vds::set_domain_properties {qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER qsys_mm.clockCrossingAdapter HANDSHAKE qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 3 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } hps_0.hps_to_csr
vds::set_domain_properties {qsys_mm.burstAdapterImplementation GENERIC_CONVERTER qsys_mm.clockCrossingAdapter AUTO qsys_mm.enableAllPipelines FALSE qsys_mm.enableEccProtection FALSE qsys_mm.enableInstrumentation FALSE qsys_mm.enableOutOfOrderSupport FALSE qsys_mm.fifoDepth 8 qsys_mm.insertDefaultSlave FALSE qsys_mm.interconnectResetSource DEFAULT qsys_mm.maxAdditionalLatency 1 qsys_mm.optimizeRdFifoSize FALSE qsys_mm.piplineType PIPELINE_STAGE qsys_mm.responseFifoType REGISTER_BASED qsys_mm.splitCommandsFor4KBoundary FALSE qsys_mm.syncResets TRUE qsys_mm.widthAdapterImplementation GENERIC_CONVERTER } hps_0.hps_to_ddr
vds::set_pipelines {mm_interconnect_0|addr_extend_0_windowed_slave_burst_adapter.source0/addr_extend_0_windowed_slave_agent.cp 1 mm_interconnect_0|addr_extend_0_windowed_slave_cmd_width_adapter.src/addr_extend_0_windowed_slave_burst_adapter.sink0 1 mm_interconnect_0|dla_0_dla_to_ddr_agent.cp/router.sink 1 }
vds::validate_system
vds::save_system system

post_message "Script completed successfully."

package require -exact qsys 24.3

proc do_create_system {} {
	# system name
	upvar system_name system_name
	# Optionally create pmon
	upvar enable_pmon enable_pmon
    # create the system
	create_system ${system_name}
	set_project_property BOARD {default}
	set_project_property DEVICE {A5ED065BB32AE6SR0}
	set_project_property DEVICE_FAMILY {Agilex 5}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}
	set_module_property FILE ${system_name}.qsys
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME ${system_name}
	
    # Name of components
	set jtag_address_span_extender_inst "jtag_address_span_extender"
	set emif_address_span_extender_inst "emif_address_span_extender"
	set emif_sideband_driver "emif_sideband_driver_0"
	set csr_data_bridge "csr_data_bridge_0"
	set emif_data_bridge "emif_data_bridge_0"
	set emif_clk_bridge "emif_clk_bridge_0"
	set shell_usr_clk_bridge "dla_clk_bridge_0"
	set jtag_master "jtag_master_0"
	set pmon_inst "performance_monitor_0"
	set reset_bridge "reset_bridge_0"
	set reset_handler "reset_handler_0"
	set rrip "rrip_0"
	set dla_pll "dla_pll_0"
	set jtag_pll "jtag_pll_0"
	set emif  "emif_0"
	set coredla "coredla_0"
	set hw_timer_bridge "ed_zero_hw_timer_bridge"

	# Component sepcific variables
	upvar emif_data_width emif_data_width
	upvar emif_addr_width emif_addr_width
	upvar emif_ddr4_phy_freq_mhz emif_ddr4_phy_freq_mhz
	# upvar emif_ddr4_preset_file_name  emif_ddr4_preset_file_name
	upvar emif_ddr4_ref_clk_frequency_mhz emif_ddr4_ref_clk_frequency_mhz
	upvar user_ref_clk_freq_mhz user_ref_clk_freq_mhz
	upvar dla_freq_mhz dla_freq_mhz

	# Instantiate and parametrize the components
	puts "Instantiating components"
	instantiate_jtag_address_span_extender
	instantiate_emif_sideband_driver
	instantiate_csr_bridge
	instantiate_emif_bridge
	instantiate_emif_clk_bridge
	instantiate_shell_usr_clk_bridge
	instantiate_jtag_master
	if {$enable_pmon == 1} {
		instantiate_pmon
	}
	instantiate_reset_bridge
	instantiate_reset_handler
	instantiate_hw_timer_bridge
	instantiate_rrip
	instantiate_dla_pll
	instantiate_jtag_pll
	instantiate_emif

	# Datapath connections
	puts "Adding connections"
	add_connection ${jtag_address_span_extender_inst}.expanded_master/${emif}.s0_axi4
	set_connection_parameter_value ${jtag_address_span_extender_inst}.expanded_master/${emif}.s0_axi4 baseAddress {0x0000}
	add_connection ${emif_sideband_driver}.axil_driver_axi4_lite/${emif}.s0_axi4lite
	set_connection_parameter_value ${emif_sideband_driver}.axil_driver_axi4_lite/${emif}.s0_axi4lite baseAddress {0x0000}
	add_connection ${jtag_master}.master/${jtag_address_span_extender_inst}.windowed_slave
	set_connection_parameter_value ${jtag_master}.master/${jtag_address_span_extender_inst}.windowed_slave baseAddress {0x0000}
	add_connection ${jtag_master}.master/${csr_data_bridge}.s0
	set_connection_parameter_value ${jtag_master}.master/${csr_data_bridge}.s0 baseAddress {0x80000000}
	add_connection ${jtag_master}.master/${hw_timer_bridge}.s0
	set_connection_parameter_value ${jtag_master}.master/${hw_timer_bridge}.s0 baseAddress {0x80000800}
	if {$enable_pmon == 1} {
		add_connection ${pmon_inst}.src_axi4/${emif}.s0_axi4
		set_connection_parameter_value ${pmon_inst}.src_axi4/${emif}.s0_axi4 baseAddress {0x0000}
		add_connection ${emif_data_bridge}.m0/${pmon_inst}.sink_axi4
		set_connection_parameter_value ${emif_data_bridge}.m0/${pmon_inst}.sink_axi4 baseAddress {0x0000}
	} else {
		add_connection ${emif_data_bridge}.m0/${emif}.s0_axi4
		set_connection_parameter_value ${emif_data_bridge}.m0/${emif}.s0_axi4 baseAddress {0x0000}
	}


	# Clock connections
	# CSR clock has to be EMIF clock
	add_connection ${emif}.s0_axi4_clock_out/${csr_data_bridge}.clk
	add_connection ${emif}.s0_axi4_clock_out/${emif_data_bridge}.clk
	add_connection ${emif}.s0_axi4_clock_out/${jtag_address_span_extender_inst}.clock
	add_connection ${emif}.s0_axi4_clock_out/${emif_clk_bridge}.in_clk
	add_connection ${jtag_pll}.outclk0/${jtag_master}.clk
	add_connection ${jtag_pll}.outclk0/${emif_sideband_driver}.axil_driver_clk
	add_connection ${jtag_pll}.outclk0/${hw_timer_bridge}.s0_clk
	add_connection ${dla_pll}.outclk0/${shell_usr_clk_bridge}.in_clk
	add_connection ${jtag_pll}.outclk0/${emif}.s0_axi4lite_clock
	add_connection ${dla_pll}.outclk0/${reset_bridge}.clk
	add_connection ${dla_pll}.outclk0/${reset_handler}.clk
	if {$enable_pmon == 1} {
		add_connection ${emif}.s0_axi4_clock_ou/${pmon_inst}.clk
		add_connection ${jtag_pll}.outclk0/${pmon_inst}.csr_clk
	}

	# Reset connections
	add_connection ${emif_sideband_driver}.cal_done_rst_n/${jtag_address_span_extender_inst}.reset
	add_connection ${emif_sideband_driver}.cal_done_rst_n/${csr_data_bridge}.clk_reset
	add_connection ${emif_sideband_driver}.cal_done_rst_n/${emif_data_bridge}.clk_reset
	add_connection ${emif_sideband_driver}.cal_done_rst_n/${reset_bridge}.in_reset
	add_connection ${reset_handler}.reset_n_out/${jtag_master}.clk_reset
	add_connection ${reset_handler}.reset_n_out/${emif_sideband_driver}.axil_driver_rst_n
	add_connection ${reset_handler}.reset_n_out/${emif}.core_init_n
	add_connection ${reset_handler}.reset_n_out/${emif}.s0_axi4lite_reset_n
	add_connection ${reset_handler}.reset_n_out/${hw_timer_bridge}.s0_reset
	add_connection ${rrip}.ninit_done/${reset_handler}.reset_n_0
	add_connection ${rrip}.ninit_done/${dla_pll}.reset
	add_connection ${rrip}.ninit_done/${jtag_pll}.reset
	add_connection ${dla_pll}.locked/${reset_handler}.conduit_0
	add_connection ${jtag_pll}.locked/${reset_handler}.conduit_1
	if {$enable_pmon == 1} {
		add_connection ${emif}.s0_axi4_ctrl_ready/${pmon_inst}.reset_n
		add_connection ${reset_handler}.reset_n_out/${pmon_inst}.csr_reset_n
	}

	# Export unconnected ports
	set_interface_property ${emif}_ref_clk_0 EXPORT_OF ${emif}.ref_clk
	set_interface_property ${emif}_mem_0 EXPORT_OF ${emif}.mem_0
	set_interface_property ${emif}_oct_0 EXPORT_OF ${emif}.oct_0
	set_interface_property ${emif}_mem_0_ck EXPORT_OF ${emif}.mem_ck_0
	set_interface_property ${emif}_mem_0_reset_n EXPORT_OF ${emif}.mem_reset_n
	set_interface_property reset_handler_reset_n_1 EXPORT_OF ${reset_handler}.reset_n_1
	set_interface_property ${dla_pll}_refclk EXPORT_OF ${dla_pll}.refclk
	set_interface_property ${jtag_pll}_refclk EXPORT_OF ${jtag_pll}.refclk
	set_interface_property ${csr_data_bridge}_m0 EXPORT_OF ${csr_data_bridge}.m0 
	set_interface_property ${emif_data_bridge}_s0 EXPORT_OF ${emif_data_bridge}.s0
	set_interface_property ${emif_clk_bridge}_out_clk EXPORT_OF ${emif_clk_bridge}.out_clk
	set_interface_property ${shell_usr_clk_bridge}_out_clk EXPORT_OF ${shell_usr_clk_bridge}.out_clk
	set_interface_property ${reset_bridge}_out_reset EXPORT_OF ${reset_bridge}.out_reset
	set_interface_property ${hw_timer_bridge}_m0_clk EXPORT_OF ${hw_timer_bridge}.m0_clk
	set_interface_property ${hw_timer_bridge}_m0_reset EXPORT_OF ${hw_timer_bridge}.m0_reset
	set_interface_property ${hw_timer_bridge}_m0 EXPORT_OF ${hw_timer_bridge}.m0
}

proc instantiate_jtag_address_span_extender {} {
	upvar jtag_address_span_extender_inst jtag_address_span_extender_inst
	upvar emif_addr_width emif_addr_width
	add_component $jtag_address_span_extender_inst ip/ed_zero/ed_zero_jtag_address_span_extender_0.ip altera_address_span_extender address_span_extender_0 19.2.0
	load_component $jtag_address_span_extender_inst
	set data_width 32
	set_component_parameter_value BURSTCOUNT_WIDTH {1}
	set_component_parameter_value DATA_WIDTH ${data_width}
	set_component_parameter_value ENABLE_SLAVE_PORT {0}
	set_component_parameter_value MASTER_ADDRESS_DEF {0}
	set_component_parameter_value MASTER_ADDRESS_WIDTH $emif_addr_width
	set_component_parameter_value MAX_PENDING_READS {1}
	# allocate 31 out of the 32 address bits coming out of the JTAG master for DDR access
	set_component_parameter_value SLAVE_ADDRESS_WIDTH [expr {32 - 1 - int(log($data_width)/log(2)) + 3}]
	set_component_parameter_value SUB_WINDOW_COUNT {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	#### End of address span extender ########
}


proc instantiate_emif_sideband_driver {} {
	upvar emif_sideband_driver emif_sideband_driver
	#### EMIF sideband driver ###########
	# Query if EMIF calibration is done, and release the user reset accordingly
	add_component $emif_sideband_driver ip/ed_zero/ed_zero_axil_driver_0.ip emif_ph2_axil_driver emif_ph2_axil_driver_inst 1.0.0
	load_component $emif_sideband_driver
	set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH {32}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	##### End of EMIF sideband driver ########
}

proc instantiate_csr_bridge {} {
	upvar csr_data_bridge csr_data_bridge
	##### CSR Bridge #######################
	add_component $csr_data_bridge ip/ed_zero/ed_zero_axi_bridge_1.ip altera_axi_bridge axi_bridge_1 19.9.3
	load_component $csr_data_bridge
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {11}
	set_component_parameter_value AXI_VERSION {AXI4-Lite}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	# Increase capability to mitigate back-pressure
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {32}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {1}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value READ_ADDR_USER_WIDTH {64}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {64}
	set_component_parameter_value READ_ISSUING_CAPABILITY {32}
	set_component_parameter_value S0_ID_WIDTH {1}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SYNC_RESET {1}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {0}
	set_component_parameter_value USE_M0_ARCACHE {0}
	set_component_parameter_value USE_M0_ARID {0}
	set_component_parameter_value USE_M0_ARLEN {0}
	set_component_parameter_value USE_M0_ARLOCK {0}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWBURST {0}
	set_component_parameter_value USE_M0_AWCACHE {0}
	set_component_parameter_value USE_M0_AWID {0}
	set_component_parameter_value USE_M0_AWLEN {0}
	set_component_parameter_value USE_M0_AWLOCK {0}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {0}
	set_component_parameter_value USE_M0_AWUSER {0}
	set_component_parameter_value USE_M0_BID {0}
	set_component_parameter_value USE_M0_BRESP {1}
	set_component_parameter_value USE_M0_BUSER {0}
	set_component_parameter_value USE_M0_DATACHK {0}
	set_component_parameter_value USE_M0_POISON {0}
	set_component_parameter_value USE_M0_RID {0}
	set_component_parameter_value USE_M0_RLAST {0}
	set_component_parameter_value USE_M0_RRESP {1}
	set_component_parameter_value USE_M0_RUSER {0}
	set_component_parameter_value USE_M0_SAI {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {0}
	set_component_parameter_value USE_S0_ARLOCK {0}
	set_component_parameter_value USE_S0_ARPROT {1}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWCACHE {0}
	set_component_parameter_value USE_S0_AWLOCK {0}
	set_component_parameter_value USE_S0_AWPROT {1}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BRESP {1}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RRESP {0}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_WLAST {0}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {64}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {64}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {1}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {64}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_emif_bridge {} {
	upvar emif_data_bridge emif_data_bridge
	upvar emif_data_width emif_data_width
	upvar emif_addr_width emif_addr_width
	add_component $emif_data_bridge ip/ed_zero/ed_zero_axi_bridge_0.ip altera_axi_bridge axi_bridge_0 19.9.3
	load_component $emif_data_bridge
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	# CoreDLA address width is only 32-bit
	# Setting the address width of the bridge to match EMIF's width
	# In the top-level RTL, need to prepend DLA address bits with zeros
	set_component_parameter_value ADDR_WIDTH ${emif_addr_width}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {64}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {64}
	set_component_parameter_value DATA_WIDTH $emif_data_width
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {2}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {64}
	set_component_parameter_value READ_ADDR_USER_WIDTH {2}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {2}
	set_component_parameter_value READ_ISSUING_CAPABILITY {64}
	set_component_parameter_value S0_ID_WIDTH {2}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {1}
	set_component_parameter_value USE_M0_ARCACHE {1}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {1}
	set_component_parameter_value USE_M0_ARLOCK {1}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {1}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWBURST {1}
	set_component_parameter_value USE_M0_AWCACHE {1}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {1}
	set_component_parameter_value USE_M0_AWLOCK {1}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {1}
	set_component_parameter_value USE_M0_AWUSER {0}
	set_component_parameter_value USE_M0_BID {1}
	set_component_parameter_value USE_M0_BRESP {1}
	set_component_parameter_value USE_M0_BUSER {0}
	set_component_parameter_value USE_M0_DATACHK {0}
	set_component_parameter_value USE_M0_POISON {0}
	set_component_parameter_value USE_M0_RID {1}
	set_component_parameter_value USE_M0_RLAST {1}
	set_component_parameter_value USE_M0_RRESP {1}
	set_component_parameter_value USE_M0_RUSER {0}
	set_component_parameter_value USE_M0_SAI {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {0}
	set_component_parameter_value USE_S0_ARLOCK {0}
	set_component_parameter_value USE_S0_ARPROT {0}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWCACHE {0}
	set_component_parameter_value USE_S0_AWLOCK {0}
	set_component_parameter_value USE_S0_AWPROT {0}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BRESP {0}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RRESP {0}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_WLAST {1}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {64}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {2}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {2}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {64}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {2}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
} 

proc instantiate_emif {} {
	# Instantiate a x32 DDR4 interface 
	# DDR4 interface is physical bank 2B
	upvar emif emif
	upvar emif_ddr4_phy_freq_mhz emif_ddr4_phy_freq_mhz
	upvar emif_ddr4_ref_clk_frequency_mhz emif_ddr4_ref_clk_frequency_mhz

	add_component ${emif} ip/ed_zero/ed_zero_emif_ddr4_0.ip emif_io96b_ddr4comp emif_io96b_ddr4comp_0 3.0.0
	load_component ${emif}
	set_component_parameter_value ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_parameter_value CTRL_AUTO_PRECHARGE_EN {0}
	# Disable DM/DBI since CoreDLA can't take advantage of these.
	set_component_parameter_value CTRL_DM_EN {0}
	set_component_parameter_value CTRL_ECC_AUTOCORRECT_EN {0}
	set_component_parameter_value CTRL_PERFORMANCE_PROFILE {default}
	set_component_parameter_value CTRL_RD_DBI_EN {0}
	set_component_parameter_value CTRL_SCRAMBLER_EN {0}
	set_component_parameter_value CTRL_WR_DBI_EN {0}
	set_component_parameter_value DEBUG_TOOLS_EN {0}
	set_component_parameter_value DIAG_EXTRA_PARAMETERS {}
	set_component_parameter_value DIAG_HMC_ADDR_SWAP_EN {0}
	set_component_parameter_value EMIF_INST_NAME {}
	set_component_parameter_value EX_DESIGN_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_HDL_FORMAT {VERILOG}
	set_component_parameter_value EX_DESIGN_NOC_PLL_REFCLK_FREQ_MHZ {100}
	set_component_parameter_value EX_DESIGN_PMON_CH0_EN {0}
	set_component_parameter_value EX_DESIGN_PMON_INTERNAL_JAMB_EN {1}
	set_component_parameter_value EX_DESIGN_TG_CSR_ACCESS_MODE {JTAG}
	set_component_parameter_value EX_DESIGN_TG_PROGRAM {MEDIUM}
	set_component_parameter_value EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ {200.0}
	set_component_parameter_value EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ_AUTOSET_EN {1}
	set_component_parameter_value EX_DESIGN_USER_PLL_REFCLK_FREQ_MHZ {100.0}
	set_component_parameter_value INSTANCE_ID {0}
	set_component_parameter_value IS_HPS {0}
	set_component_parameter_value JEDEC_OVERRIDE_TABLE_PARAM_NAME {MEM_CL_CYC MEM_CWL_CYC MEM_TRFC_NS MEM_TRFC_DLR_NS MEM_TRRD_DLR_NS MEM_TFAW_DLR_NS MEM_TCCD_DLR_NS}
	set_component_parameter_value MEM_AC_MIRRORING_EN {0}
	set_component_parameter_value MEM_AC_PARITY_EN {0}
	set_component_parameter_value MEM_AC_PARITY_LATENCY_MODE {0.0}
	set_component_parameter_value MEM_AL_CYC {0.0}
	set_component_parameter_value MEM_CHANNEL_CS_WIDTH {1}
	set_component_parameter_value MEM_CHANNEL_DATA_DQ_WIDTH {32}
	set_component_parameter_value MEM_CHANNEL_ECC_DQ_WIDTH {0}
	set_component_parameter_value MEM_CLAMSHELL_EN {0}
	set_component_parameter_value MEM_CL_CYC {12.0}
	set_component_parameter_value MEM_CWL_CYC {11.0}
	set_component_parameter_value MEM_DIE_DENSITY_GBITS {16}
	set_component_parameter_value MEM_DIE_DQ_WIDTH {8}
	set_component_parameter_value MEM_DQ_VREF {35}
	set_component_parameter_value MEM_FINE_GRANULARITY_REFRESH_MODE {1.0}
	set_component_parameter_value MEM_ODT_DQ_X_IDLE {off}
	set_component_parameter_value MEM_ODT_DQ_X_NON_TGT_RD {off}
	set_component_parameter_value MEM_ODT_DQ_X_NON_TGT_WR {off}
	set_component_parameter_value MEM_ODT_DQ_X_RON {7}
	set_component_parameter_value MEM_ODT_DQ_X_TGT_WR {4}
	set_component_parameter_value MEM_ODT_NOM {off}
	set_component_parameter_value MEM_ODT_PARK {4}
	set_component_parameter_value MEM_ODT_WR {off}
	set_component_parameter_value MEM_OPERATING_FREQ_MHZ ${emif_ddr4_phy_freq_mhz}
	set_component_parameter_value MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {0}
	set_component_parameter_value MEM_PAGE_SIZE {1024.0}
	set_component_parameter_value MEM_RANKS_SHARE_CK_EN {0}
	set_component_parameter_value MEM_RD_PREAMBLE_MODE {1.0}
	set_component_parameter_value MEM_SPEEDBIN {3200AA}
	set_component_parameter_value MEM_TCCD_DLR_NS {5.0}
	set_component_parameter_value MEM_TCCD_L_NS {6.25}
	set_component_parameter_value MEM_TCCD_S_NS {5.0}
	set_component_parameter_value MEM_TCKESR_CYC {5.0}
	set_component_parameter_value MEM_TCKE_NS {5.0}
	set_component_parameter_value MEM_TCKSRE_NS {10.0}
	set_component_parameter_value MEM_TCKSRX_NS {10.0}
	set_component_parameter_value MEM_TCK_CL_CWL_MAX_NS {1.5}
	set_component_parameter_value MEM_TCK_CL_CWL_MIN_NS {1.25}
	set_component_parameter_value MEM_TCPDED_NS {5.0}
	set_component_parameter_value MEM_TDQSCK_MAX_MIN_NS {0.16}
	set_component_parameter_value MEM_TDQSCK_NS {0.0}
	set_component_parameter_value MEM_TDQSS_CYC {0.0}
	set_component_parameter_value MEM_TDSH_NS {0.225}
	set_component_parameter_value MEM_TDSS_NS {0.225}
	set_component_parameter_value MEM_TFAW_DLR_NS {20.0}
	set_component_parameter_value MEM_TFAW_NS {25.0}
	set_component_parameter_value MEM_TIH_NS {65000.0}
	set_component_parameter_value MEM_TIS_NS {40000.0}
	set_component_parameter_value MEM_TMOD_NS {30.0}
	set_component_parameter_value MEM_TMPRR_NS {1.25}
	set_component_parameter_value MEM_TMRD_NS {10.0}
	set_component_parameter_value MEM_TQSH_NS {0.5}
	set_component_parameter_value MEM_TRAS_MAX_NS {70200.0}
	set_component_parameter_value MEM_TRAS_MIN_NS {32.0}
	set_component_parameter_value MEM_TRAS_NS {32.0}
	set_component_parameter_value MEM_TRCD_NS {13.75}
	set_component_parameter_value MEM_TRC_NS {45.75}
	set_component_parameter_value MEM_TREFI_NS {7800.0}
	set_component_parameter_value MEM_TRFC_DLR_NS {190.0}
	set_component_parameter_value MEM_TRFC_NS {350.0}
	set_component_parameter_value MEM_TRP_NS {13.75}
	set_component_parameter_value MEM_TRRD_DLR_NS {5.0}
	set_component_parameter_value MEM_TRRD_L_NS {5.0}
	set_component_parameter_value MEM_TRRD_S_NS {5.0}
	set_component_parameter_value MEM_TRTP_NS {7.5}
	set_component_parameter_value MEM_TWLH_NS {0.1625}
	set_component_parameter_value MEM_TWLS_NS {0.1625}
	set_component_parameter_value MEM_TWR_CRC_DM_NS {6.25}
	set_component_parameter_value MEM_TWR_NS {15.0}
	set_component_parameter_value MEM_TWTR_L_CRC_DM_NS {6.25}
	set_component_parameter_value MEM_TWTR_L_NS {7.5}
	set_component_parameter_value MEM_TWTR_S_CRC_DM_NS {6.25}
	set_component_parameter_value MEM_TWTR_S_NS {2.5}
	set_component_parameter_value MEM_TXP_NS {6.0}
	set_component_parameter_value MEM_TXS_DLL_NS {1280.0}
	set_component_parameter_value MEM_TXS_NS {360.0}
	set_component_parameter_value MEM_TZQCS_NS {160.0}
	set_component_parameter_value MEM_TZQINIT_CYC {1024.0}
	set_component_parameter_value MEM_TZQOPER_CYC {512.0}
	set_component_parameter_value MEM_VREF_DQ_X_RANGE {2}
	set_component_parameter_value MEM_VREF_DQ_X_VALUE {67.75}
	set_component_parameter_value MEM_WR_CRC_EN {0.0}
	set_component_parameter_value MEM_WR_PREAMBLE_MODE {1.0}
	set_component_parameter_value PHY_AC_PLACEMENT {BOT}
	set_component_parameter_value PHY_ALERT_N_PLACEMENT {AC2}
	set_component_parameter_value PHY_FORCE_MIN_4_AC_LANES_EN {0}
	set_component_parameter_value PHY_MAINBAND_ACCESS_MODE {SYNC}
	set_component_parameter_value PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {0}
	set_component_parameter_value PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_parameter_value PHY_REFCLK_FREQ_MHZ ${emif_ddr4_ref_clk_frequency_mhz}
	set_component_parameter_value PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {0}
	set_component_parameter_value PHY_SIDEBAND_ACCESS_MODE {FABRIC}
	set_component_parameter_value PHY_SIDEBAND_ACCESS_MODE_AUTOSET_EN {1}
	set_component_parameter_value PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,X,X,X,0,2,3,X;  PIN_SWIZZLE_CH0_DQS0=7,5,1,3,4,2,0,6;  PIN_SWIZZLE_CH0_DQS1=9,15,13,11,14,12,8,10;  PIN_SWIZZLE_CH0_DQS2=19,23,21,17,16,18,20,22;  PIN_SWIZZLE_CH0_DQS3=31,29,27,25,26,30,24,28; }
	set_component_parameter_value PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {SSTL}
	set_component_parameter_value PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_SSTL}
	set_component_parameter_value PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {SSTL}
	set_component_parameter_value PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD}
	set_component_parameter_value PHY_TERM_X_DQ_IO_STD_TYPE {POD}
	set_component_parameter_value PHY_TERM_X_DQ_SLEW_RATE {FASTEST}
	set_component_parameter_value PHY_TERM_X_DQ_VREF {68.3}
	set_component_parameter_value PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS}
	set_component_parameter_value PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF}
	set_component_parameter_value PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_parameter_value PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_parameter_value PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_parameter_value PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_parameter_value PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL}
	set_component_parameter_value PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF}
	set_component_parameter_value PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}
	set_component_parameter_value TURNAROUND_R2R_DIFFCS_CYC {0}
	set_component_parameter_value TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_parameter_value TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_parameter_value TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_parameter_value TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_parameter_value TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ${emif}
	set_instantiation_interface_parameter_value s0_axi4 combinedAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s0_axi4 readAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s0_axi4 writeAcceptanceCapability {64} 
	save_instantiation
}

proc instantiate_emif_clk_bridge {} {
	upvar emif_clk_bridge emif_clk_bridge
	add_component $emif_clk_bridge ip/ed_zero/ddr_usr_clk_bridge.ip altera_clock_bridge ddr_usr_clk_bridge 19.2.0
	load_component $emif_clk_bridge
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_shell_usr_clk_bridge {} {
	upvar shell_usr_clk_bridge	shell_usr_clk_bridge
	add_component $shell_usr_clk_bridge ip/ed_zero/ed_zero_usr_clock_bridge_0.ip altera_clock_bridge ed_zero_usr_clock_bridge_0 19.2.0
	load_component $shell_usr_clk_bridge
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_hw_timer_bridge {} {
	upvar hw_timer_bridge hw_timer_bridge
	add_component ${hw_timer_bridge} ip/ed_zero/ed_zero_hw_timer_bridge.ip mm_ccb ed_zero_hw_timer_bridge 19.3.0
	load_component ${hw_timer_bridge}
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {8}
	set_component_parameter_value COMMAND_FIFO_DEPTH {4}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value ENABLE_RESPONSE {0}
	set_component_parameter_value MASTER_SYNC_DEPTH {2}
	set_component_parameter_value MAX_BURST_SIZE {1}
	set_component_parameter_value RESPONSE_FIFO_DEPTH {4}
	set_component_parameter_value SLAVE_SYNC_DEPTH {2}
	set_component_parameter_value SYMBOL_WIDTH {8}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_AUTO_ADDRESS_WIDTH {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_jtag_master {} {
	upvar jtag_master jtag_master
	add_component $jtag_master ip/ed_zero/ed_zero_master_0.ip altera_jtag_avalon_master master_0 19.1
	load_component ${jtag_master}
	set_component_parameter_value FAST_VER {0}
	set_component_parameter_value FIFO_DEPTHS {2}
	set_component_parameter_value PLI_PORT {50000}
	set_component_parameter_value USE_PLI {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation $jtag_master
	set_instantiation_assignment_value debug.hostConnection {type jtag id 110:132}
	save_instantiation
}

proc instantiate_pmon {} {
	upvar pmon_inst pmon_inst
	upvar emif_addr_width emif_addr_width
	upvar emif_data_width emif_data_width
	add_component $pmon_inst ip/ed_zero/ed_zero_pmon_0.ip pmon pmon_0 1.1.0
	load_component $pmon_inst
	set_component_parameter_value ALWAYS_RUN_FULL_COMPOSITION {0}
	set_component_parameter_value EXPORT_JTAG {1}
	set_component_parameter_value INTERMEDIATE_LOG {0}
	set_component_parameter_value LOG_PRINT_ALL {0}
	set_component_parameter_value MONITOR_0_ADVANCED_LAT {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_ARADDR_WIDTH ${emif_addr_width}
	set_component_parameter_value MONITOR_0_MEM_AXI4_ARID_WIDTH {2}
	set_component_parameter_value MONITOR_0_MEM_AXI4_ARUSER_WIDTH {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_AWADDR_WIDTH ${emif_addr_width}
	set_component_parameter_value MONITOR_0_MEM_AXI4_AWID_WIDTH {2}
	set_component_parameter_value MONITOR_0_MEM_AXI4_AWUSER_WIDTH {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_BUSER_WIDTH {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_RDATA_WIDTH ${emif_data_width}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_ARCACHE {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_ARLOCK {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_ARQOS {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_ARREGION {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_ARUSER {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_AWCACHE {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_AWLOCK {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_AWQOS {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_AWREGION {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_AWUSER {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_USE_BUSER {0}
	set_component_parameter_value MONITOR_0_MEM_AXI4_WDATA_WIDTH ${emif_data_width}
	set_component_parameter_value MONITOR_0_RDLAT_FIFO_DEPTH {64}
	set_component_parameter_value MONITOR_0_UNIT_ID {0}
	set_component_parameter_value MONITOR_0_WRLAT_FIFO_DEPTH {64}
	set_component_parameter_value MONITOR_INDEX {0}
	set_component_parameter_value NUM_UNIT_MONITORS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation $pmon_inst
	set_instantiation_interface_parameter_value src_axi4 combinedIssuingCapability {32}
	set_instantiation_interface_parameter_value src_axi4 readIssuingCapability {32}
	set_instantiation_interface_parameter_value src_axi4 writeIssuingCapability {32} 
	set_instantiation_interface_parameter_value sink_axi4 combinedAcceptanceCapability {32}
	set_instantiation_interface_parameter_value sink_axi4 readAcceptanceCapability {32}
	set_instantiation_interface_parameter_value sink_axi4 writeAcceptanceCapability {32} 
	save_instantiation
}

proc instantiate_reset_bridge {} {
	upvar reset_bridge  reset_bridge
	add_component $reset_bridge ip/ed_zero/ed_zero_reset_bridge_0.ip altera_reset_bridge reset_bridge_0 19.2.0
	load_component $reset_bridge
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_reset_handler {} {
	upvar reset_handler reset_handler
	add_component $reset_handler ip/ed_zero/ed_zero_reset_handler.ip mem_reset_handler mem_reset_handler_inst 1.0.0
	load_component $reset_handler
	set_component_parameter_value CONDUIT_INVERT_0 {0}
	set_component_parameter_value CONDUIT_INVERT_1 {0}
	set_component_parameter_value CONDUIT_INVERT_10 {0}
	set_component_parameter_value CONDUIT_INVERT_11 {0}
	set_component_parameter_value CONDUIT_INVERT_12 {0}
	set_component_parameter_value CONDUIT_INVERT_13 {0}
	set_component_parameter_value CONDUIT_INVERT_14 {0}
	set_component_parameter_value CONDUIT_INVERT_15 {0}
	set_component_parameter_value CONDUIT_INVERT_2 {0}
	set_component_parameter_value CONDUIT_INVERT_3 {0}
	set_component_parameter_value CONDUIT_INVERT_4 {0}
	set_component_parameter_value CONDUIT_INVERT_5 {0}
	set_component_parameter_value CONDUIT_INVERT_6 {0}
	set_component_parameter_value CONDUIT_INVERT_7 {0}
	set_component_parameter_value CONDUIT_INVERT_8 {0}
	set_component_parameter_value CONDUIT_INVERT_9 {0}
	set_component_parameter_value CONDUIT_TYPE_0 {export}
	set_component_parameter_value CONDUIT_TYPE_1 {export}
	set_component_parameter_value CONDUIT_TYPE_10 {}
	set_component_parameter_value CONDUIT_TYPE_11 {}
	set_component_parameter_value CONDUIT_TYPE_12 {}
	set_component_parameter_value CONDUIT_TYPE_13 {}
	set_component_parameter_value CONDUIT_TYPE_14 {}
	set_component_parameter_value CONDUIT_TYPE_15 {}
	set_component_parameter_value CONDUIT_TYPE_2 {}
	set_component_parameter_value CONDUIT_TYPE_3 {}
	set_component_parameter_value CONDUIT_TYPE_4 {}
	set_component_parameter_value CONDUIT_TYPE_5 {}
	set_component_parameter_value CONDUIT_TYPE_6 {}
	set_component_parameter_value CONDUIT_TYPE_7 {}
	set_component_parameter_value CONDUIT_TYPE_8 {}
	set_component_parameter_value CONDUIT_TYPE_9 {}
	set_component_parameter_value NUM_CONDUITS {2}
	set_component_parameter_value NUM_RESETS {2}
	set_component_parameter_value SYNC_TO_CLK {1}
	set_component_parameter_value USE_AND_GATE {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_rrip {} {
	upvar rrip rrip
	add_component $rrip ip/ed_zero/ed_zero_rrip.ip altera_s10_user_rst_clkgate altera_s10_user_rst_clkgate_inst 19.4.8
	load_component $rrip
	set_component_parameter_value outputType {Reset Interface}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_dla_pll {} {
	upvar dla_pll dla_pll
	upvar user_ref_clk_freq_mhz user_ref_clk_freq_mhz
	upvar dla_freq_mhz dla_freq_mhz
	add_component $dla_pll ip/ed_zero/ed_zero_dla_pll.ip altera_iopll altera_iopll_inst 20.0.0
	load_component ${dla_pll}
	set_component_parameter_value gui_active_clk {0}
	set_component_parameter_value gui_c_cnt_in_src0 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src1 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src2 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src3 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src4 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src5 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src6 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src7 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src8 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_cal_code_hex_file {iossm.hex}
	set_component_parameter_value gui_cal_converge {0}
	set_component_parameter_value gui_cal_error {cal_clean}
	set_component_parameter_value gui_cascade_counter0 {0}
	set_component_parameter_value gui_cascade_counter1 {0}
	set_component_parameter_value gui_cascade_counter10 {0}
	set_component_parameter_value gui_cascade_counter11 {0}
	set_component_parameter_value gui_cascade_counter12 {0}
	set_component_parameter_value gui_cascade_counter13 {0}
	set_component_parameter_value gui_cascade_counter14 {0}
	set_component_parameter_value gui_cascade_counter15 {0}
	set_component_parameter_value gui_cascade_counter16 {0}
	set_component_parameter_value gui_cascade_counter17 {0}
	set_component_parameter_value gui_cascade_counter2 {0}
	set_component_parameter_value gui_cascade_counter3 {0}
	set_component_parameter_value gui_cascade_counter4 {0}
	set_component_parameter_value gui_cascade_counter5 {0}
	set_component_parameter_value gui_cascade_counter6 {0}
	set_component_parameter_value gui_cascade_counter7 {0}
	set_component_parameter_value gui_cascade_counter8 {0}
	set_component_parameter_value gui_cascade_counter9 {0}
	set_component_parameter_value gui_cascade_outclk_index {0}
	set_component_parameter_value gui_clk_bad {0}
	set_component_parameter_value gui_clock_name_global {0}
	set_component_parameter_value gui_clock_name_string0 {outclk0}
	set_component_parameter_value gui_clock_name_string1 {outclk1}
	set_component_parameter_value gui_clock_name_string10 {outclk10}
	set_component_parameter_value gui_clock_name_string11 {outclk11}
	set_component_parameter_value gui_clock_name_string12 {outclk12}
	set_component_parameter_value gui_clock_name_string13 {outclk13}
	set_component_parameter_value gui_clock_name_string14 {outclk14}
	set_component_parameter_value gui_clock_name_string15 {outclk15}
	set_component_parameter_value gui_clock_name_string16 {outclk16}
	set_component_parameter_value gui_clock_name_string17 {outclk17}
	set_component_parameter_value gui_clock_name_string2 {outclk2}
	set_component_parameter_value gui_clock_name_string3 {outclk3}
	set_component_parameter_value gui_clock_name_string4 {outclk4}
	set_component_parameter_value gui_clock_name_string5 {outclk5}
	set_component_parameter_value gui_clock_name_string6 {outclk6}
	set_component_parameter_value gui_clock_name_string7 {outclk7}
	set_component_parameter_value gui_clock_name_string8 {outclk8}
	set_component_parameter_value gui_clock_name_string9 {outclk9}
	set_component_parameter_value gui_clock_to_compensate {0}
	set_component_parameter_value gui_debug_mode {0}
	set_component_parameter_value gui_dps_cntr {C0}
	set_component_parameter_value gui_dps_dir {Positive}
	set_component_parameter_value gui_dps_num {1}
	set_component_parameter_value gui_dsm_out_sel {1st_order}
	set_component_parameter_value gui_duty_cycle0 {50.0}
	set_component_parameter_value gui_duty_cycle1 {50.0}
	set_component_parameter_value gui_duty_cycle10 {50.0}
	set_component_parameter_value gui_duty_cycle11 {50.0}
	set_component_parameter_value gui_duty_cycle12 {50.0}
	set_component_parameter_value gui_duty_cycle13 {50.0}
	set_component_parameter_value gui_duty_cycle14 {50.0}
	set_component_parameter_value gui_duty_cycle15 {50.0}
	set_component_parameter_value gui_duty_cycle16 {50.0}
	set_component_parameter_value gui_duty_cycle17 {50.0}
	set_component_parameter_value gui_duty_cycle2 {50.0}
	set_component_parameter_value gui_duty_cycle3 {50.0}
	set_component_parameter_value gui_duty_cycle4 {50.0}
	set_component_parameter_value gui_duty_cycle5 {50.0}
	set_component_parameter_value gui_duty_cycle6 {50.0}
	set_component_parameter_value gui_duty_cycle7 {50.0}
	set_component_parameter_value gui_duty_cycle8 {50.0}
	set_component_parameter_value gui_duty_cycle9 {50.0}
	set_component_parameter_value gui_en_adv_params {0}
	set_component_parameter_value gui_en_dps_ports {0}
	set_component_parameter_value gui_en_extclkout_ports {0}
	set_component_parameter_value gui_en_iossm_reconf {0}
	set_component_parameter_value gui_en_lvds_ports {Disabled}
	set_component_parameter_value gui_en_periphery_ports {0}
	set_component_parameter_value gui_en_phout_ports {0}
	set_component_parameter_value gui_en_reconf {0}
	set_component_parameter_value gui_enable_cascade_in {0}
	set_component_parameter_value gui_enable_cascade_out {0}
	set_component_parameter_value gui_enable_mif_dps {0}
	set_component_parameter_value gui_enable_output_counter_cascading {0}
	set_component_parameter_value gui_enable_permit_cal {0}
	set_component_parameter_value gui_enable_upstream_out_clk {0}
	set_component_parameter_value gui_existing_mif_file_path {~/dla_pll.mif}
	set_component_parameter_value gui_extclkout_0_source {C0}
	set_component_parameter_value gui_extclkout_1_source {C0}
	set_component_parameter_value gui_extclkout_source {C0}
	set_component_parameter_value gui_feedback_clock {Global Clock}
	set_component_parameter_value gui_fix_vco_frequency {0}
	set_component_parameter_value gui_fractional_cout {32}
	set_component_parameter_value gui_include_iossm {0}
	set_component_parameter_value gui_location_type {Fabric-Feeding}
	set_component_parameter_value gui_lock_setting {Low Lock Time}
	set_component_parameter_value gui_mif_config_name {unnamed}
	set_component_parameter_value gui_mif_gen_options {Generate New MIF File}
	set_component_parameter_value gui_new_mif_file_path {~/dla_pll.mif}
	set_component_parameter_value gui_number_of_clocks {1}
	set_component_parameter_value gui_operation_mode {direct}
	# set DLA frequency
	set_component_parameter_value gui_output_clock_frequency0 ${dla_freq_mhz}
	# Keep JTAG clock at 100 MHz
	set_component_parameter_value gui_output_clock_frequency1 {100.0}
	set_component_parameter_value gui_output_clock_frequency10 {100.0}
	set_component_parameter_value gui_output_clock_frequency11 {100.0}
	set_component_parameter_value gui_output_clock_frequency12 {100.0}
	set_component_parameter_value gui_output_clock_frequency13 {100.0}
	set_component_parameter_value gui_output_clock_frequency14 {100.0}
	set_component_parameter_value gui_output_clock_frequency15 {100.0}
	set_component_parameter_value gui_output_clock_frequency16 {100.0}
	set_component_parameter_value gui_output_clock_frequency17 {100.0}
	set_component_parameter_value gui_output_clock_frequency2 {100.0}
	set_component_parameter_value gui_output_clock_frequency3 {100.0}
	set_component_parameter_value gui_output_clock_frequency4 {100.0}
	set_component_parameter_value gui_output_clock_frequency5 {100.0}
	set_component_parameter_value gui_output_clock_frequency6 {100.0}
	set_component_parameter_value gui_output_clock_frequency7 {100.0}
	set_component_parameter_value gui_output_clock_frequency8 {100.0}
	set_component_parameter_value gui_output_clock_frequency9 {100.0}
	set_component_parameter_value gui_parameter_table_hex_file {seq_params_sim.hex}
	set_component_parameter_value gui_phase_shift0 {0.0}
	set_component_parameter_value gui_phase_shift1 {0.0}
	set_component_parameter_value gui_phase_shift10 {0.0}
	set_component_parameter_value gui_phase_shift11 {0.0}
	set_component_parameter_value gui_phase_shift12 {0.0}
	set_component_parameter_value gui_phase_shift13 {0.0}
	set_component_parameter_value gui_phase_shift14 {0.0}
	set_component_parameter_value gui_phase_shift15 {0.0}
	set_component_parameter_value gui_phase_shift16 {0.0}
	set_component_parameter_value gui_phase_shift17 {0.0}
	set_component_parameter_value gui_phase_shift2 {0.0}
	set_component_parameter_value gui_phase_shift3 {0.0}
	set_component_parameter_value gui_phase_shift4 {0.0}
	set_component_parameter_value gui_phase_shift5 {0.0}
	set_component_parameter_value gui_phase_shift6 {0.0}
	set_component_parameter_value gui_phase_shift7 {0.0}
	set_component_parameter_value gui_phase_shift8 {0.0}
	set_component_parameter_value gui_phase_shift9 {0.0}
	set_component_parameter_value gui_phase_shift_deg0 {0.0}
	set_component_parameter_value gui_phase_shift_deg1 {0.0}
	set_component_parameter_value gui_phase_shift_deg10 {0.0}
	set_component_parameter_value gui_phase_shift_deg11 {0.0}
	set_component_parameter_value gui_phase_shift_deg12 {0.0}
	set_component_parameter_value gui_phase_shift_deg13 {0.0}
	set_component_parameter_value gui_phase_shift_deg14 {0.0}
	set_component_parameter_value gui_phase_shift_deg15 {0.0}
	set_component_parameter_value gui_phase_shift_deg16 {0.0}
	set_component_parameter_value gui_phase_shift_deg17 {0.0}
	set_component_parameter_value gui_phase_shift_deg2 {0.0}
	set_component_parameter_value gui_phase_shift_deg3 {0.0}
	set_component_parameter_value gui_phase_shift_deg4 {0.0}
	set_component_parameter_value gui_phase_shift_deg5 {0.0}
	set_component_parameter_value gui_phase_shift_deg6 {0.0}
	set_component_parameter_value gui_phase_shift_deg7 {0.0}
	set_component_parameter_value gui_phase_shift_deg8 {0.0}
	set_component_parameter_value gui_phase_shift_deg9 {0.0}
	set_component_parameter_value gui_phout_division {1}
	set_component_parameter_value gui_pll_auto_reset {0}
	set_component_parameter_value gui_pll_bandwidth_preset {Medium}
	set_component_parameter_value gui_pll_cal_done {0}
	set_component_parameter_value gui_pll_cascading_mode {adjpllin}
	set_component_parameter_value gui_pll_freqcal_en {1}
	set_component_parameter_value gui_pll_freqcal_req_flag {1}
	set_component_parameter_value gui_pll_m_cnt_in_src {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_pll_mode {Integer-N PLL}
	set_component_parameter_value gui_pll_tclk_mux_en {0}
	set_component_parameter_value gui_pll_tclk_sel {pll_tclk_m_src}
	set_component_parameter_value gui_pll_type {S10_Simple}
	set_component_parameter_value gui_pll_vco_freq_band_0 {pll_freq_clk0_band18}
	set_component_parameter_value gui_pll_vco_freq_band_1 {pll_freq_clk1_band18}
	set_component_parameter_value gui_prot_mode {UNUSED}
	set_component_parameter_value gui_ps_units0 {ps}
	set_component_parameter_value gui_ps_units1 {ps}
	set_component_parameter_value gui_ps_units10 {ps}
	set_component_parameter_value gui_ps_units11 {ps}
	set_component_parameter_value gui_ps_units12 {ps}
	set_component_parameter_value gui_ps_units13 {ps}
	set_component_parameter_value gui_ps_units14 {ps}
	set_component_parameter_value gui_ps_units15 {ps}
	set_component_parameter_value gui_ps_units16 {ps}
	set_component_parameter_value gui_ps_units17 {ps}
	set_component_parameter_value gui_ps_units2 {ps}
	set_component_parameter_value gui_ps_units3 {ps}
	set_component_parameter_value gui_ps_units4 {ps}
	set_component_parameter_value gui_ps_units5 {ps}
	set_component_parameter_value gui_ps_units6 {ps}
	set_component_parameter_value gui_ps_units7 {ps}
	set_component_parameter_value gui_ps_units8 {ps}
	set_component_parameter_value gui_ps_units9 {ps}
	set_component_parameter_value gui_refclk1_frequency $user_ref_clk_freq_mhz
	set_component_parameter_value gui_refclk_might_change {0}
	set_component_parameter_value gui_refclk_switch {0}
	set_component_parameter_value gui_reference_clock_frequency $user_ref_clk_freq_mhz
	set_component_parameter_value gui_reference_clock_frequency_ps [expr {1000000 / $user_ref_clk_freq_mhz}]
	set_component_parameter_value gui_simulation_type {0}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {1}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {600.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

proc instantiate_jtag_pll {} {
	upvar jtag_pll jtag_pll
	upvar user_ref_clk_freq_mhz user_ref_clk_freq_mhz
	add_component ${jtag_pll} ip/ed_zero/ed_zero_jtag_pll.ip altera_iopll altera_iopll_inst 20.0.0
	load_component ${jtag_pll}
	set_component_parameter_value gui_active_clk {0}
	set_component_parameter_value gui_c_cnt_in_src0 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src1 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src2 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src3 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src4 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src5 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src6 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src7 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_c_cnt_in_src8 {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_cal_code_hex_file {iossm.hex}
	set_component_parameter_value gui_cal_converge {0}
	set_component_parameter_value gui_cal_error {cal_clean}
	set_component_parameter_value gui_cascade_counter0 {0}
	set_component_parameter_value gui_cascade_counter1 {0}
	set_component_parameter_value gui_cascade_counter10 {0}
	set_component_parameter_value gui_cascade_counter11 {0}
	set_component_parameter_value gui_cascade_counter12 {0}
	set_component_parameter_value gui_cascade_counter13 {0}
	set_component_parameter_value gui_cascade_counter14 {0}
	set_component_parameter_value gui_cascade_counter15 {0}
	set_component_parameter_value gui_cascade_counter16 {0}
	set_component_parameter_value gui_cascade_counter17 {0}
	set_component_parameter_value gui_cascade_counter2 {0}
	set_component_parameter_value gui_cascade_counter3 {0}
	set_component_parameter_value gui_cascade_counter4 {0}
	set_component_parameter_value gui_cascade_counter5 {0}
	set_component_parameter_value gui_cascade_counter6 {0}
	set_component_parameter_value gui_cascade_counter7 {0}
	set_component_parameter_value gui_cascade_counter8 {0}
	set_component_parameter_value gui_cascade_counter9 {0}
	set_component_parameter_value gui_cascade_outclk_index {0}
	set_component_parameter_value gui_clk_bad {0}
	set_component_parameter_value gui_clock_name_global {0}
	set_component_parameter_value gui_clock_name_string0 {outclk0}
	set_component_parameter_value gui_clock_name_string1 {outclk1}
	set_component_parameter_value gui_clock_name_string10 {outclk10}
	set_component_parameter_value gui_clock_name_string11 {outclk11}
	set_component_parameter_value gui_clock_name_string12 {outclk12}
	set_component_parameter_value gui_clock_name_string13 {outclk13}
	set_component_parameter_value gui_clock_name_string14 {outclk14}
	set_component_parameter_value gui_clock_name_string15 {outclk15}
	set_component_parameter_value gui_clock_name_string16 {outclk16}
	set_component_parameter_value gui_clock_name_string17 {outclk17}
	set_component_parameter_value gui_clock_name_string2 {outclk2}
	set_component_parameter_value gui_clock_name_string3 {outclk3}
	set_component_parameter_value gui_clock_name_string4 {outclk4}
	set_component_parameter_value gui_clock_name_string5 {outclk5}
	set_component_parameter_value gui_clock_name_string6 {outclk6}
	set_component_parameter_value gui_clock_name_string7 {outclk7}
	set_component_parameter_value gui_clock_name_string8 {outclk8}
	set_component_parameter_value gui_clock_name_string9 {outclk9}
	set_component_parameter_value gui_clock_to_compensate {0}
	set_component_parameter_value gui_debug_mode {0}
	set_component_parameter_value gui_dps_cntr {C0}
	set_component_parameter_value gui_dps_dir {Positive}
	set_component_parameter_value gui_dps_num {1}
	set_component_parameter_value gui_dsm_out_sel {1st_order}
	set_component_parameter_value gui_duty_cycle0 {50.0}
	set_component_parameter_value gui_duty_cycle1 {50.0}
	set_component_parameter_value gui_duty_cycle10 {50.0}
	set_component_parameter_value gui_duty_cycle11 {50.0}
	set_component_parameter_value gui_duty_cycle12 {50.0}
	set_component_parameter_value gui_duty_cycle13 {50.0}
	set_component_parameter_value gui_duty_cycle14 {50.0}
	set_component_parameter_value gui_duty_cycle15 {50.0}
	set_component_parameter_value gui_duty_cycle16 {50.0}
	set_component_parameter_value gui_duty_cycle17 {50.0}
	set_component_parameter_value gui_duty_cycle2 {50.0}
	set_component_parameter_value gui_duty_cycle3 {50.0}
	set_component_parameter_value gui_duty_cycle4 {50.0}
	set_component_parameter_value gui_duty_cycle5 {50.0}
	set_component_parameter_value gui_duty_cycle6 {50.0}
	set_component_parameter_value gui_duty_cycle7 {50.0}
	set_component_parameter_value gui_duty_cycle8 {50.0}
	set_component_parameter_value gui_duty_cycle9 {50.0}
	set_component_parameter_value gui_en_adv_params {0}
	set_component_parameter_value gui_en_dps_ports {0}
	set_component_parameter_value gui_en_extclkout_ports {0}
	set_component_parameter_value gui_en_iossm_reconf {0}
	set_component_parameter_value gui_en_lvds_ports {Disabled}
	set_component_parameter_value gui_en_periphery_ports {0}
	set_component_parameter_value gui_en_phout_ports {0}
	set_component_parameter_value gui_en_reconf {0}
	set_component_parameter_value gui_enable_cascade_in {0}
	set_component_parameter_value gui_enable_cascade_out {0}
	set_component_parameter_value gui_enable_mif_dps {0}
	set_component_parameter_value gui_enable_output_counter_cascading {0}
	set_component_parameter_value gui_enable_permit_cal {0}
	set_component_parameter_value gui_enable_upstream_out_clk {0}
	set_component_parameter_value gui_existing_mif_file_path {~/jtag_pll.mif}
	set_component_parameter_value gui_extclkout_0_source {C0}
	set_component_parameter_value gui_extclkout_1_source {C0}
	set_component_parameter_value gui_extclkout_source {C0}
	set_component_parameter_value gui_feedback_clock {Global Clock}
	set_component_parameter_value gui_fix_vco_frequency {0}
	set_component_parameter_value gui_fractional_cout {32}
	set_component_parameter_value gui_include_iossm {0}
	set_component_parameter_value gui_location_type {Fabric-Feeding}
	set_component_parameter_value gui_lock_setting {Low Lock Time}
	set_component_parameter_value gui_mif_config_name {unnamed}
	set_component_parameter_value gui_mif_gen_options {Generate New MIF File}
	set_component_parameter_value gui_new_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_number_of_clocks {1}
	set_component_parameter_value gui_operation_mode {direct}
	# Keep JTAG clock at 100 MHz
	set_component_parameter_value gui_output_clock_frequency0 {100.0}
	set_component_parameter_value gui_parameter_table_hex_file {seq_params_sim.hex}
	set_component_parameter_value gui_phase_shift0 {0.0}
	set_component_parameter_value gui_phase_shift_deg0 {0.0}
	set_component_parameter_value gui_phout_division {1}
	set_component_parameter_value gui_pll_auto_reset {0}
	set_component_parameter_value gui_pll_bandwidth_preset {Medium}
	set_component_parameter_value gui_pll_cal_done {0}
	set_component_parameter_value gui_pll_cascading_mode {adjpllin}
	set_component_parameter_value gui_pll_freqcal_en {1}
	set_component_parameter_value gui_pll_freqcal_req_flag {1}
	set_component_parameter_value gui_pll_m_cnt_in_src {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_pll_mode {Integer-N PLL}
	set_component_parameter_value gui_pll_tclk_mux_en {0}
	set_component_parameter_value gui_pll_tclk_sel {pll_tclk_m_src}
	set_component_parameter_value gui_pll_type {S10_Simple}
	set_component_parameter_value gui_pll_vco_freq_band_0 {pll_freq_clk0_band18}
	set_component_parameter_value gui_pll_vco_freq_band_1 {pll_freq_clk1_band18}
	set_component_parameter_value gui_prot_mode {UNUSED}
	set_component_parameter_value gui_ps_units0 {ps}
	set_component_parameter_value gui_ps_units1 {ps}
	set_component_parameter_value gui_ps_units10 {ps}
	set_component_parameter_value gui_ps_units11 {ps}
	set_component_parameter_value gui_ps_units12 {ps}
	set_component_parameter_value gui_ps_units13 {ps}
	set_component_parameter_value gui_ps_units14 {ps}
	set_component_parameter_value gui_ps_units15 {ps}
	set_component_parameter_value gui_ps_units16 {ps}
	set_component_parameter_value gui_ps_units17 {ps}
	set_component_parameter_value gui_ps_units2 {ps}
	set_component_parameter_value gui_ps_units3 {ps}
	set_component_parameter_value gui_ps_units4 {ps}
	set_component_parameter_value gui_ps_units5 {ps}
	set_component_parameter_value gui_ps_units6 {ps}
	set_component_parameter_value gui_ps_units7 {ps}
	set_component_parameter_value gui_ps_units8 {ps}
	set_component_parameter_value gui_ps_units9 {ps}
	set_component_parameter_value gui_refclk1_frequency $user_ref_clk_freq_mhz
	set_component_parameter_value gui_refclk_might_change {0}
	set_component_parameter_value gui_refclk_switch {0}
	set_component_parameter_value gui_reference_clock_frequency $user_ref_clk_freq_mhz
	set_component_parameter_value gui_reference_clock_frequency_ps [expr {1000000 / $user_ref_clk_freq_mhz}]
	set_component_parameter_value gui_simulation_type {0}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {1}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
}

# create the system "ed_zero"

# Component sepcific variables
set emif_data_width 256
set emif_addr_width 33
# Reference clock frequencies are determined from Dev Kit Schematic diagram
# PIN_BR49, IOBANK_2B_B
# Must include one decimal place to satisfy EMIF
set emif_ddr4_ref_clk_frequency_mhz 150.0
# PIN PIN_BK31, IOBANK_6A
set user_ref_clk_freq_mhz 100

if {![info exists emif_ddr4_phy_freq_mhz]} {
	set emif_ddr4_phy_freq_mhz 800
}

if {![info exists system_name]} {
	set system_name "ed_zero"
}

if {![info exists dla_freq_mhz]} {
	set dla_freq_mhz 600.0
}

# Disable PMON by default
if {![info exists enable_pmon]} {
	set enable_pmon 0
}

# create all the systems, from bottom up
do_create_system

# print validation messages for earlier error detection
set val_msg [validate_system]
foreach msg $val_msg {
	puts $msg
}

# save the system
sync_sysinfo_parameters
save_system ${system_name}
package require -exact qsys 26.3

# create the system "system"
proc do_create_system {} {
	# create the system
	create_system system
	set_project_property BOARD {Agilex 5 FPGA E-Series 065B Modular Development Kit MK-A5E065BB32AES1}
	set_project_property DEVICE {A5ED065BB32AE6SR0}
	set_project_property DEVICE_FAMILY {Agilex 5}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component axi_address_span_extender_256 ip/system/axi_address_span_extender_256.ip axi_address_span_extender axi_address_span_extender_256
	load_component axi_address_span_extender_256
	set_component_parameter_value ARUSER_WIDTH {4}
	set_component_parameter_value AWUSER_WIDTH {4}
	set_component_parameter_value AXI4LITE_CSR_DATA_WIDTH {32}
	set_component_parameter_value BITSPERBYTE {1}
	set_component_parameter_value BUSER_WIDTH {4}
	set_component_parameter_value CNTL_DATA_WIDTH {64}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value ENABLE_SUBORDINATE_PORT {0}
	set_component_parameter_value ID_WIDTH {2}
	set_component_parameter_value MANAGER_ADDRESS_DEF {0}
	set_component_parameter_value MANAGER_ADDRESS_WIDTH {33}
	set_component_parameter_value MAX_PENDING_COMBINE {64}
	set_component_parameter_value MAX_PENDING_READS {32}
	set_component_parameter_value MAX_PENDING_WRITES {32}
	set_component_parameter_value RUSER_WIDTH {4}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SUBORDINATE_ADDRESS_WIDTH {32}
	set_component_parameter_value SUB_WINDOW_COUNT {1}
	set_component_parameter_value USE_ADDRCHK {0}
	set_component_parameter_value USE_ARCACHE {1}
	set_component_parameter_value USE_ARLOCK {1}
	set_component_parameter_value USE_ARQOS {0}
	set_component_parameter_value USE_ARREGION {0}
	set_component_parameter_value USE_ARUSER {0}
	set_component_parameter_value USE_AWCACHE {1}
	set_component_parameter_value USE_AWLOCK {1}
	set_component_parameter_value USE_AWQOS {0}
	set_component_parameter_value USE_AWREGION {0}
	set_component_parameter_value USE_AWUSER {0}
	set_component_parameter_value USE_BRESP {1}
	set_component_parameter_value USE_BUSER {0}
	set_component_parameter_value USE_DATACHK {0}
	set_component_parameter_value USE_POISON {0}
	set_component_parameter_value USE_RRESP {1}
	set_component_parameter_value USE_RUSER {0}
	set_component_parameter_value USE_SAI {0}
	set_component_parameter_value USE_USER_DATA {0}
	set_component_parameter_value USE_WUSER {0}
	set_component_parameter_value WUSER_WIDTH {4}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation axi_address_span_extender_256
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.CNTL_ADDRESS_WIDTH {3}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {256}
	set_instantiation_assignment_value embeddedsw.CMacro.MANAGER_ADDRESS_WIDTH {33}
	set_instantiation_assignment_value embeddedsw.CMacro.STROBE_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.SUBORDINATE_ADDRESS_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.SUB_WINDOW_COUNT {1}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface s_axi4 axi4 INPUT
	set_instantiation_interface_parameter_value s_axi4 addressCheck {false}
	set_instantiation_interface_parameter_value s_axi4 associatedClock {clk}
	set_instantiation_interface_parameter_value s_axi4 associatedReset {reset}
	set_instantiation_interface_parameter_value s_axi4 bridgesToMaster {}
	set_instantiation_interface_parameter_value s_axi4 combinedAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s_axi4 dataCheck {false}
	set_instantiation_interface_parameter_value s_axi4 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s_axi4 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s_axi4 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s_axi4 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s_axi4 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s_axi4 dfhGroupId {0}
	set_instantiation_interface_parameter_value s_axi4 dfhParameterData {}
	set_instantiation_interface_parameter_value s_axi4 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s_axi4 dfhParameterId {}
	set_instantiation_interface_parameter_value s_axi4 dfhParameterName {}
	set_instantiation_interface_parameter_value s_axi4 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s_axi4 isTranslator {false}
	set_instantiation_interface_parameter_value s_axi4 maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value s_axi4 maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value s_axi4 maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value s_axi4 noNarrowTransfer {false}
	set_instantiation_interface_parameter_value s_axi4 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s_axi4 poison {false}
	set_instantiation_interface_parameter_value s_axi4 readAcceptanceCapability {32}
	set_instantiation_interface_parameter_value s_axi4 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s_axi4 securityAttribute {false}
	set_instantiation_interface_parameter_value s_axi4 traceSignals {false}
	set_instantiation_interface_parameter_value s_axi4 trustzoneAware {true}
	set_instantiation_interface_parameter_value s_axi4 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s_axi4 userData {false}
	set_instantiation_interface_parameter_value s_axi4 wakeupSignals {false}
	set_instantiation_interface_parameter_value s_axi4 writeAcceptanceCapability {32}
	set_instantiation_interface_sysinfo_parameter_value s_axi4 address_map {<address-map><slave name='s_axi4' start='0x0' end='0x100000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s_axi4 address_width {32}
	set_instantiation_interface_sysinfo_parameter_value s_axi4 max_slave_data_width {256}
	add_instantiation_interface_port s_axi4 s_axi4_awid awid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awaddr awaddr 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awlock awlock 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awcache awcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s_axi4 s_axi4_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s_axi4 s_axi4_wdata wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_wstrb wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_wlast wlast 1 STD_LOGIC Input
	add_instantiation_interface_port s_axi4 s_axi4_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s_axi4 s_axi4_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s_axi4 s_axi4_bid bid 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s_axi4 s_axi4_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s_axi4 s_axi4_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s_axi4 s_axi4_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s_axi4 s_axi4_arid arid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_araddr araddr 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arlock arlock 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arcache arcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s_axi4 s_axi4_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s_axi4 s_axi4_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s_axi4 s_axi4_rid rid 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s_axi4 s_axi4_rdata rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s_axi4 s_axi4_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s_axi4 s_axi4_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s_axi4 s_axi4_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s_axi4 s_axi4_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m_axi4 axi4 OUTPUT
	set_instantiation_interface_parameter_value m_axi4 addressCheck {false}
	set_instantiation_interface_parameter_value m_axi4 associatedClock {clk}
	set_instantiation_interface_parameter_value m_axi4 associatedReset {reset}
	set_instantiation_interface_parameter_value m_axi4 combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value m_axi4 dataCheck {false}
	set_instantiation_interface_parameter_value m_axi4 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m_axi4 isTranslator {false}
	set_instantiation_interface_parameter_value m_axi4 issuesFIXEDBursts {false}
	set_instantiation_interface_parameter_value m_axi4 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m_axi4 issuesWRAPBursts {false}
	set_instantiation_interface_parameter_value m_axi4 maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value m_axi4 maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value m_axi4 maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value m_axi4 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m_axi4 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m_axi4 poison {false}
	set_instantiation_interface_parameter_value m_axi4 readIssuingCapability {32}
	set_instantiation_interface_parameter_value m_axi4 securityAttribute {false}
	set_instantiation_interface_parameter_value m_axi4 traceSignals {false}
	set_instantiation_interface_parameter_value m_axi4 trustzoneAware {true}
	set_instantiation_interface_parameter_value m_axi4 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m_axi4 userData {false}
	set_instantiation_interface_parameter_value m_axi4 wakeupSignals {false}
	set_instantiation_interface_parameter_value m_axi4 writeIssuingCapability {32}
	add_instantiation_interface_port m_axi4 m_axi4_awid awid 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awaddr awaddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awlock awlock 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m_axi4 m_axi4_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m_axi4 m_axi4_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m_axi4 m_axi4_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m_axi4 m_axi4_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m_axi4 m_axi4_bid bid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m_axi4 m_axi4_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m_axi4 m_axi4_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m_axi4 m_axi4_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m_axi4 m_axi4_arid arid 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_araddr araddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arlock arlock 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m_axi4 m_axi4_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m_axi4 m_axi4_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m_axi4 m_axi4_rid rid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m_axi4 m_axi4_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m_axi4 m_axi4_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m_axi4 m_axi4_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port m_axi4 m_axi4_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m_axi4 m_axi4_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component axi_bridge_256 ip/system/system_axi_bridge_0.ip altera_axi_bridge axi_bridge_256
	load_component axi_bridge_256
	set_component_parameter_value ACE5_LITE_SUPPORT {0}
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {33}
	set_component_parameter_value ATOMIC_TXN {0}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value CACHESTASHING_TXN {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {64}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {64}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value ENABLE_AXI4_READ_ONLY_INTERFACE {1}
	set_component_parameter_value ENABLE_AXI4_WRITE_ONLY_INTERFACE {1}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {6}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value READ_ADDR_USER_WIDTH {1}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {1}
	set_component_parameter_value READ_ISSUING_CAPABILITY {32}
	set_component_parameter_value S0_ID_WIDTH {6}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SID_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value UNTRANSLATED_TXN {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {1}
	set_component_parameter_value USE_M0_ARCACHE {1}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {1}
	set_component_parameter_value USE_M0_ARLOCK {1}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {1}
	set_component_parameter_value USE_M0_ARSNOOP {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWAKEUP {0}
	set_component_parameter_value USE_M0_AWBURST {1}
	set_component_parameter_value USE_M0_AWCACHE {1}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {1}
	set_component_parameter_value USE_M0_AWLOCK {1}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {1}
	set_component_parameter_value USE_M0_AWSNOOP {0}
	set_component_parameter_value USE_M0_AWUNIQUE {0}
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
	set_component_parameter_value USE_M0_TRACE {0}
	set_component_parameter_value USE_M0_USER_DATA {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {1}
	set_component_parameter_value USE_S0_ARLOCK {1}
	set_component_parameter_value USE_S0_ARPROT {1}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARSIZE {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWAKEUP {0}
	set_component_parameter_value USE_S0_AWCACHE {1}
	set_component_parameter_value USE_S0_AWLOCK {1}
	set_component_parameter_value USE_S0_AWPROT {1}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWSIZE {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BID {0}
	set_component_parameter_value USE_S0_BRESP {1}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RID {0}
	set_component_parameter_value USE_S0_RRESP {1}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_TRACE {0}
	set_component_parameter_value USE_S0_USER_DATA {0}
	set_component_parameter_value USE_S0_WLAST {1}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {1}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {1}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {32}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation axi_bridge_256
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.compatible {simple-bus}
	set_instantiation_assignment_value embeddedsw.dts.group {bridge}
	set_instantiation_assignment_value embeddedsw.dts.name {bridge}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk aclk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {clk}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port clk_reset aresetn reset_n 1 STD_LOGIC Input
	add_instantiation_interface s0 axi4 INPUT
	set_instantiation_interface_parameter_value s0 addressCheck {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clk}
	set_instantiation_interface_parameter_value s0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {m0}
	set_instantiation_interface_parameter_value s0 combinedAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s0 dataCheck {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 isTranslator {false}
	set_instantiation_interface_parameter_value s0 maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value s0 maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value s0 maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value s0 noNarrowTransfer {false}
	set_instantiation_interface_parameter_value s0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0 poison {false}
	set_instantiation_interface_parameter_value s0 readAcceptanceCapability {32}
	set_instantiation_interface_parameter_value s0 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0 securityAttribute {false}
	set_instantiation_interface_parameter_value s0 traceSignals {false}
	set_instantiation_interface_parameter_value s0 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0 userData {false}
	set_instantiation_interface_parameter_value s0 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0 writeAcceptanceCapability {32}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_awid awid 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awaddr awaddr 33 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlock awlock 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awcache awcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_wdata wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wstrb wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wlast wlast 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bid bid 6 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arid arid 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_araddr araddr 33 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlock arlock 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arcache arcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rid rid 6 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rdata rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {32}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {32}
	add_instantiation_interface_port m0 m0_awid awid 6 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awlock awlock 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bid bid 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arid arid 6 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_araddr araddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arlock arlock 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rid rid 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component axi_bridge_256_emif ip/system/system_axi_bridge_1.ip altera_axi_bridge axi_bridge_256_emif
	load_component axi_bridge_256_emif
	set_component_parameter_value ACE5_LITE_SUPPORT {0}
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {33}
	set_component_parameter_value ATOMIC_TXN {0}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value CACHESTASHING_TXN {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {64}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {64}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value ENABLE_AXI4_READ_ONLY_INTERFACE {1}
	set_component_parameter_value ENABLE_AXI4_WRITE_ONLY_INTERFACE {1}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {1}
	set_component_parameter_value M0_ID_WIDTH {7}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value READ_ADDR_USER_WIDTH {1}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {16}
	set_component_parameter_value READ_DATA_USER_WIDTH {1}
	set_component_parameter_value READ_ISSUING_CAPABILITY {32}
	set_component_parameter_value S0_ID_WIDTH {7}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SID_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value UNTRANSLATED_TXN {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {1}
	set_component_parameter_value USE_M0_ARCACHE {1}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {1}
	set_component_parameter_value USE_M0_ARLOCK {1}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {1}
	set_component_parameter_value USE_M0_ARSNOOP {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWAKEUP {0}
	set_component_parameter_value USE_M0_AWBURST {1}
	set_component_parameter_value USE_M0_AWCACHE {1}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {1}
	set_component_parameter_value USE_M0_AWLOCK {1}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {1}
	set_component_parameter_value USE_M0_AWSNOOP {0}
	set_component_parameter_value USE_M0_AWUNIQUE {0}
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
	set_component_parameter_value USE_M0_TRACE {0}
	set_component_parameter_value USE_M0_USER_DATA {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {1}
	set_component_parameter_value USE_S0_ARLOCK {1}
	set_component_parameter_value USE_S0_ARPROT {1}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARSIZE {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWAKEUP {0}
	set_component_parameter_value USE_S0_AWCACHE {1}
	set_component_parameter_value USE_S0_AWLOCK {1}
	set_component_parameter_value USE_S0_AWPROT {1}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWSIZE {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BID {0}
	set_component_parameter_value USE_S0_BRESP {1}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RID {0}
	set_component_parameter_value USE_S0_RRESP {1}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_TRACE {0}
	set_component_parameter_value USE_S0_USER_DATA {0}
	set_component_parameter_value USE_S0_WLAST {1}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {32}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {1}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {1}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {32}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation axi_bridge_256_emif
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.compatible {simple-bus}
	set_instantiation_assignment_value embeddedsw.dts.group {bridge}
	set_instantiation_assignment_value embeddedsw.dts.name {bridge}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk aclk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {clk}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port clk_reset aresetn reset_n 1 STD_LOGIC Input
	add_instantiation_interface s0 axi4 INPUT
	set_instantiation_interface_parameter_value s0 addressCheck {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clk}
	set_instantiation_interface_parameter_value s0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {m0}
	set_instantiation_interface_parameter_value s0 combinedAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s0 dataCheck {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 isTranslator {false}
	set_instantiation_interface_parameter_value s0 maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value s0 maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value s0 maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value s0 noNarrowTransfer {false}
	set_instantiation_interface_parameter_value s0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0 poison {false}
	set_instantiation_interface_parameter_value s0 readAcceptanceCapability {32}
	set_instantiation_interface_parameter_value s0 readDataReorderingDepth {16}
	set_instantiation_interface_parameter_value s0 securityAttribute {false}
	set_instantiation_interface_parameter_value s0 traceSignals {false}
	set_instantiation_interface_parameter_value s0 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0 userData {false}
	set_instantiation_interface_parameter_value s0 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0 writeAcceptanceCapability {32}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_awid awid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awaddr awaddr 33 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlock awlock 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awcache awcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_wdata wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wstrb wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wlast wlast 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bid bid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arid arid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_araddr araddr 33 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlock arlock 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arcache arcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rid rid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rdata rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {32}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {32}
	add_instantiation_interface_port m0 m0_awid awid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awlock awlock 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bid bid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arid arid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_araddr araddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arlock arlock 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rid rid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component clk_100 ip/system/system_clk_100_0.ip altera_clock_bridge clk_100
	load_component clk_100
	set_component_parameter_value EXPLICIT_CLOCK_RATE {100000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation clk_100
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {100000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {100000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_instance dla dla
	add_component dla_pll ip/system/system_iopll_0.ip altera_iopll dla_pll
	load_component dla_pll
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
	set_component_parameter_value gui_cascade_outclk_index {5}
	set_component_parameter_value gui_clk_bad {0}
	set_component_parameter_value gui_clock_name_global {0}
	set_component_parameter_value gui_clock_name_instantiation {0}
	set_component_parameter_value gui_clock_name_string0 {clk_dla}
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
	set_component_parameter_value gui_divide_factor_c0 {6}
	set_component_parameter_value gui_divide_factor_c1 {6}
	set_component_parameter_value gui_divide_factor_c10 {6}
	set_component_parameter_value gui_divide_factor_c11 {6}
	set_component_parameter_value gui_divide_factor_c12 {6}
	set_component_parameter_value gui_divide_factor_c13 {6}
	set_component_parameter_value gui_divide_factor_c14 {6}
	set_component_parameter_value gui_divide_factor_c15 {6}
	set_component_parameter_value gui_divide_factor_c16 {6}
	set_component_parameter_value gui_divide_factor_c17 {6}
	set_component_parameter_value gui_divide_factor_c2 {6}
	set_component_parameter_value gui_divide_factor_c3 {6}
	set_component_parameter_value gui_divide_factor_c4 {6}
	set_component_parameter_value gui_divide_factor_c5 {6}
	set_component_parameter_value gui_divide_factor_c6 {6}
	set_component_parameter_value gui_divide_factor_c7 {6}
	set_component_parameter_value gui_divide_factor_c8 {6}
	set_component_parameter_value gui_divide_factor_c9 {6}
	set_component_parameter_value gui_divide_factor_n {1}
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
	set_component_parameter_value gui_en_hvio_reconf {0}
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
	set_component_parameter_value gui_existing_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_extclkout_0_source {C0}
	set_component_parameter_value gui_extclkout_1_source {C0}
	set_component_parameter_value gui_extclkout_source {C0}
	set_component_parameter_value gui_feedback_clock {Global Clock}
	set_component_parameter_value gui_fix_vco_frequency {0}
	set_component_parameter_value gui_fixed_vco_frequency {600.0}
	set_component_parameter_value gui_fixed_vco_frequency_ps {1667.0}
	set_component_parameter_value gui_frac_multiply_factor {1.0}
	set_component_parameter_value gui_fractional_cout {32}
	set_component_parameter_value gui_include_iossm {0}
	set_component_parameter_value gui_location_type {Fabric-Feeding}
	set_component_parameter_value gui_lock_setting {Low Lock Time}
	set_component_parameter_value gui_mif_config_name {unnamed}
	set_component_parameter_value gui_mif_gen_options {Generate New MIF File}
	set_component_parameter_value gui_multiply_factor {6}
	set_component_parameter_value gui_multiply_fraction {0}
	set_component_parameter_value gui_new_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_number_of_clocks {3}
	set_component_parameter_value gui_operation_mode {direct}
	set_component_parameter_value gui_output_clock_frequency0 {300.0}
	set_component_parameter_value gui_output_clock_frequency1 {200.0}
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
	set_component_parameter_value gui_output_clock_frequency_ps0 {3333.333}
	set_component_parameter_value gui_output_clock_frequency_ps1 {5000.0}
	set_component_parameter_value gui_output_clock_frequency_ps10 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps11 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps12 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps13 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps14 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps15 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps16 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps17 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps2 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps3 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps4 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps5 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps6 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps7 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps8 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps9 {10000.0}
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
	set_component_parameter_value gui_pll_auto_reset {1}
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
	set_component_parameter_value gui_refclk1_frequency {100.0}
	set_component_parameter_value gui_refclk_might_change {0}
	set_component_parameter_value gui_refclk_switch {0}
	set_component_parameter_value gui_reference_clock_frequency {100.0}
	set_component_parameter_value gui_reference_clock_frequency_ps {10000.0}
	set_component_parameter_value gui_set_locked_as_reset {0}
	set_component_parameter_value gui_simulation_type {0}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {0}
	set_component_parameter_value gui_use_fractional_division {0}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_use_slvs_refclk {0}
	set_component_parameter_value gui_use_slvs_refclk1 {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {600.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_pll
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,pll}
	set_instantiation_assignment_value embeddedsw.dts.group {clock}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface refclk clock INPUT
	set_instantiation_interface_parameter_value refclk clockRate {100000000}
	set_instantiation_interface_parameter_value refclk externallyDriven {false}
	set_instantiation_interface_parameter_value refclk ptfSchematicName {}
	set_instantiation_interface_assignment_value refclk ui.blockdiagram.direction {input}
	add_instantiation_interface_port refclk refclk clk 1 STD_LOGIC Input
	add_instantiation_interface locked conduit INPUT
	set_instantiation_interface_parameter_value locked associatedClock {}
	set_instantiation_interface_parameter_value locked associatedReset {}
	set_instantiation_interface_parameter_value locked prSafe {false}
	set_instantiation_interface_assignment_value locked ui.blockdiagram.direction {output}
	add_instantiation_interface_port locked locked export 1 STD_LOGIC Output
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {}
	set_instantiation_interface_parameter_value reset synchronousEdges {NONE}
	set_instantiation_interface_assignment_value reset ui.blockdiagram.direction {input}
	add_instantiation_interface_port reset rst reset 1 STD_LOGIC Input
	add_instantiation_interface outclk0 clock OUTPUT
	set_instantiation_interface_parameter_value outclk0 associatedDirectClock {}
	set_instantiation_interface_parameter_value outclk0 clockRate {300000000}
	set_instantiation_interface_parameter_value outclk0 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk0 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk0 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk0 clock_rate {300000000}
	add_instantiation_interface_port outclk0 outclk_0 clk 1 STD_LOGIC Output
	add_instantiation_interface outclk1 clock OUTPUT
	set_instantiation_interface_parameter_value outclk1 associatedDirectClock {}
	set_instantiation_interface_parameter_value outclk1 clockRate {200000000}
	set_instantiation_interface_parameter_value outclk1 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk1 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk1 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk1 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk1 clock_rate {200000000}
	add_instantiation_interface_port outclk1 outclk_1 clk 1 STD_LOGIC Output
	add_instantiation_interface outclk2 clock OUTPUT
	set_instantiation_interface_parameter_value outclk2 associatedDirectClock {}
	set_instantiation_interface_parameter_value outclk2 clockRate {100000000}
	set_instantiation_interface_parameter_value outclk2 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk2 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk2 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk2 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk2 clock_rate {100000000}
	add_instantiation_interface_port outclk2 outclk_2 clk 1 STD_LOGIC Output
	save_instantiation
	add_instance emif emif
	add_component emif_rst_export ip/system/rst_100_1.ip altera_reset_bridge emif_rst_export
	load_component emif_rst_export
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation emif_rst_export
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
	save_instantiation
	add_instance hps hps
	add_component rst_in ip/system/system_rst_100_0.ip altera_reset_bridge rst_in
	load_component rst_in
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {none}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rst_in
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {NONE}
	add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {NONE}
	add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
	save_instantiation
	add_component user_rst_clkgate ip/system/system_intel_user_rst_clkgate_0.ip intel_user_rst_clkgate user_rst_clkgate
	load_component user_rst_clkgate
	set_component_parameter_value outputType {Conduit Interface}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation user_rst_clkgate
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface ninit_done conduit INPUT
	set_instantiation_interface_parameter_value ninit_done associatedClock {}
	set_instantiation_interface_parameter_value ninit_done associatedReset {}
	set_instantiation_interface_parameter_value ninit_done prSafe {false}
	add_instantiation_interface_port ninit_done ninit_done ninit_done 1 STD_LOGIC Output
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 addressMapSysInfo {<address-map><slave name='emif.emif.s0_axi4' start='0x0' end='0x200000000' datawidth='256' /></address-map>}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 addressWidthSysInfo {33}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 arbitrationPriority {1}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 baseAddress {0x0000}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 defaultConnection {0}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 domainAlias {}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.clockCrossingAdapter {FIFO}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axi_address_span_extender_256.m_axi4/axi_bridge_256_emif.s0 slaveDataWidthSysInfo {-1}
	add_connection axi_bridge_256.m0/axi_bridge_256_emif.s0
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 addressMapSysInfo {<address-map><slave name='emif.emif.s0_axi4' start='0x0' end='0x200000000' datawidth='256' /></address-map>}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 addressWidthSysInfo {33}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 arbitrationPriority {1}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 baseAddress {0x0000}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 defaultConnection {0}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 domainAlias {}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.clockCrossingAdapter {FIFO}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axi_bridge_256.m0/axi_bridge_256_emif.s0 slaveDataWidthSysInfo {-1}
	add_connection axi_bridge_256_emif.m0/emif.to_ddr
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr addressMapSysInfo {<address-map><slave name='emif.emif.s0_axi4' start='0x0' end='0x200000000' datawidth='256' /></address-map>}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr addressWidthSysInfo {33}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr arbitrationPriority {1}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr baseAddress {0x0000}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr cpuInfoIdSysInfo {}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr defaultConnection {0}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr domainAlias {}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.clockCrossingAdapter {FIFO}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.fifoDepth {8}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.syncResets {TRUE}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axi_bridge_256_emif.m0/emif.to_ddr slaveDataWidthSysInfo {-1}
	add_connection clk_100.out_clk/dla_pll.refclk
	set_connection_parameter_value clk_100.out_clk/dla_pll.refclk clockDomainSysInfo {1}
	set_connection_parameter_value clk_100.out_clk/dla_pll.refclk clockRateSysInfo {100000000.0}
	set_connection_parameter_value clk_100.out_clk/dla_pll.refclk clockResetSysInfo {}
	set_connection_parameter_value clk_100.out_clk/dla_pll.refclk resetDomainSysInfo {1}
	add_connection clk_100.out_clk/emif.clk_100
	set_connection_parameter_value clk_100.out_clk/emif.clk_100 clockDomainSysInfo {1}
	set_connection_parameter_value clk_100.out_clk/emif.clk_100 clockRateSysInfo {100000000.0}
	set_connection_parameter_value clk_100.out_clk/emif.clk_100 clockResetSysInfo {}
	set_connection_parameter_value clk_100.out_clk/emif.clk_100 resetDomainSysInfo {1}
	add_connection clk_100.out_clk/emif_rst_export.clk
	set_connection_parameter_value clk_100.out_clk/emif_rst_export.clk clockDomainSysInfo {1}
	set_connection_parameter_value clk_100.out_clk/emif_rst_export.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value clk_100.out_clk/emif_rst_export.clk clockResetSysInfo {}
	set_connection_parameter_value clk_100.out_clk/emif_rst_export.clk resetDomainSysInfo {1}
	add_connection dla.dla_to_ddr/axi_address_span_extender_256.s_axi4
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 addressMapSysInfo {<address-map><slave name='axi_address_span_extender_256.s_axi4' start='0x0' end='0x100000000' datawidth='256' /></address-map>}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 addressWidthSysInfo {32}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 arbitrationPriority {1}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 baseAddress {0x0000}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 cpuInfoIdSysInfo {}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 defaultConnection {0}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 domainAlias {}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.clockCrossingAdapter {AUTO}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.fifoDepth {8}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla.dla_to_ddr/axi_address_span_extender_256.s_axi4 slaveDataWidthSysInfo {-1}
	add_connection dla_pll.outclk0/dla.dla_clk
	set_connection_parameter_value dla_pll.outclk0/dla.dla_clk clockDomainSysInfo {2}
	set_connection_parameter_value dla_pll.outclk0/dla.dla_clk clockRateSysInfo {300000000.0}
	set_connection_parameter_value dla_pll.outclk0/dla.dla_clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk0/dla.dla_clk resetDomainSysInfo {2}
	add_connection dla_pll.outclk1/axi_address_span_extender_256.clk
	set_connection_parameter_value dla_pll.outclk1/axi_address_span_extender_256.clk clockDomainSysInfo {3}
	set_connection_parameter_value dla_pll.outclk1/axi_address_span_extender_256.clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value dla_pll.outclk1/axi_address_span_extender_256.clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk1/axi_address_span_extender_256.clk resetDomainSysInfo {3}
	add_connection dla_pll.outclk1/axi_bridge_256_emif.clk
	set_connection_parameter_value dla_pll.outclk1/axi_bridge_256_emif.clk clockDomainSysInfo {3}
	set_connection_parameter_value dla_pll.outclk1/axi_bridge_256_emif.clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value dla_pll.outclk1/axi_bridge_256_emif.clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk1/axi_bridge_256_emif.clk resetDomainSysInfo {3}
	add_connection dla_pll.outclk1/dla.ddr_clk
	set_connection_parameter_value dla_pll.outclk1/dla.ddr_clk clockDomainSysInfo {3}
	set_connection_parameter_value dla_pll.outclk1/dla.ddr_clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value dla_pll.outclk1/dla.ddr_clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk1/dla.ddr_clk resetDomainSysInfo {3}
	add_connection dla_pll.outclk1/emif.to_ddr_clk
	set_connection_parameter_value dla_pll.outclk1/emif.to_ddr_clk clockDomainSysInfo {3}
	set_connection_parameter_value dla_pll.outclk1/emif.to_ddr_clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value dla_pll.outclk1/emif.to_ddr_clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk1/emif.to_ddr_clk resetDomainSysInfo {3}
	add_connection dla_pll.outclk2/axi_bridge_256.clk
	set_connection_parameter_value dla_pll.outclk2/axi_bridge_256.clk clockDomainSysInfo {4}
	set_connection_parameter_value dla_pll.outclk2/axi_bridge_256.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_pll.outclk2/axi_bridge_256.clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk2/axi_bridge_256.clk resetDomainSysInfo {4}
	add_connection dla_pll.outclk2/dla.csr_clk
	set_connection_parameter_value dla_pll.outclk2/dla.csr_clk clockDomainSysInfo {4}
	set_connection_parameter_value dla_pll.outclk2/dla.csr_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_pll.outclk2/dla.csr_clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk2/dla.csr_clk resetDomainSysInfo {4}
	add_connection dla_pll.outclk2/hps.clk_100_in_clk
	set_connection_parameter_value dla_pll.outclk2/hps.clk_100_in_clk clockDomainSysInfo {4}
	set_connection_parameter_value dla_pll.outclk2/hps.clk_100_in_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_pll.outclk2/hps.clk_100_in_clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll.outclk2/hps.clk_100_in_clk resetDomainSysInfo {4}
	add_connection emif.emif_s0_axi4_ctrl_ready/emif_rst_export.in_reset
	set_connection_parameter_value emif.emif_s0_axi4_ctrl_ready/emif_rst_export.in_reset clockDomainSysInfo {5}
	set_connection_parameter_value emif.emif_s0_axi4_ctrl_ready/emif_rst_export.in_reset clockResetSysInfo {<info><reset name="in_reset" domain="5" /></info>}
	set_connection_parameter_value emif.emif_s0_axi4_ctrl_ready/emif_rst_export.in_reset resetDomainSysInfo {5}
	add_connection hps.dla_irq/dla.dla_irq
	set_connection_parameter_value hps.dla_irq/dla.dla_irq interruptsUsedSysInfo {1}
	set_connection_parameter_value hps.dla_irq/dla.dla_irq irqNumber {0}
	add_connection hps.dma_to_ddr/axi_bridge_256.s0
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 addressMapSysInfo {<address-map><slave name='emif.emif.s0_axi4' start='0x0' end='0x200000000' datawidth='256' /></address-map>}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 addressWidthSysInfo {33}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 arbitrationPriority {1}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 baseAddress {0x0000}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 defaultConnection {0}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 domainAlias {}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.clockCrossingAdapter {FIFO}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.dma_to_ddr/axi_bridge_256.s0 slaveDataWidthSysInfo {-1}
	add_connection hps.hps_to_csr/dla.csr_bridge
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge addressMapSysInfo {<address-map><slave name='dla.mailbox_ram_0.s1' start='0x0' end='0x1000' datawidth='32' /><slave name='dla/altera_ai_ip_0.csr_axi' start='0x4000' end='0x4800' datawidth='32' /></address-map>}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge addressWidthSysInfo {16}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge arbitrationPriority {1}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge baseAddress {0x0000}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge cpuInfoIdSysInfo {}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge defaultConnection {0}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge domainAlias {}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.clockCrossingAdapter {FIFO}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.fifoDepth {8}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.syncResets {TRUE}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.hps_to_csr/dla.csr_bridge slaveDataWidthSysInfo {32}
	add_connection hps.hps_to_ddr/axi_bridge_256.s0
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 addressMapSysInfo {<address-map><slave name='emif.emif.s0_axi4' start='0x0' end='0x200000000' datawidth='256' /></address-map>}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 addressWidthSysInfo {33}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 arbitrationPriority {1}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 baseAddress {0x0000}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 defaultConnection {0}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 domainAlias {}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.clockCrossingAdapter {FIFO}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.hps_to_ddr/axi_bridge_256.s0 slaveDataWidthSysInfo {-1}
	add_connection hps.streaming_out/dla.streaming_in
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.fifoDepth {8}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps.streaming_out/dla.streaming_in qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	add_connection rst_in.out_reset/axi_address_span_extender_256.reset
	set_connection_parameter_value rst_in.out_reset/axi_address_span_extender_256.reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/axi_address_span_extender_256.reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/axi_address_span_extender_256.reset resetDomainSysInfo {6}
	add_connection rst_in.out_reset/axi_bridge_256.clk_reset
	set_connection_parameter_value rst_in.out_reset/axi_bridge_256.clk_reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/axi_bridge_256.clk_reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/axi_bridge_256.clk_reset resetDomainSysInfo {6}
	add_connection rst_in.out_reset/axi_bridge_256_emif.clk_reset
	set_connection_parameter_value rst_in.out_reset/axi_bridge_256_emif.clk_reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/axi_bridge_256_emif.clk_reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/axi_bridge_256_emif.clk_reset resetDomainSysInfo {6}
	add_connection rst_in.out_reset/dla.csr_rst
	set_connection_parameter_value rst_in.out_reset/dla.csr_rst clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/dla.csr_rst clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/dla.csr_rst resetDomainSysInfo {6}
	add_connection rst_in.out_reset/dla.ddr_rst
	set_connection_parameter_value rst_in.out_reset/dla.ddr_rst clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/dla.ddr_rst clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/dla.ddr_rst resetDomainSysInfo {6}
	add_connection rst_in.out_reset/dla.dla_resetn
	set_connection_parameter_value rst_in.out_reset/dla.dla_resetn clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/dla.dla_resetn clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/dla.dla_resetn resetDomainSysInfo {6}
	add_connection rst_in.out_reset/dla_pll.reset
	set_connection_parameter_value rst_in.out_reset/dla_pll.reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/dla_pll.reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/dla_pll.reset resetDomainSysInfo {6}
	add_connection rst_in.out_reset/hps.csr_rst_in
	set_connection_parameter_value rst_in.out_reset/hps.csr_rst_in clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/hps.csr_rst_in clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/hps.csr_rst_in resetDomainSysInfo {6}

	# add the exports
	set_interface_property clk_100 EXPORT_OF clk_100.in_clk
	set_interface_property dla_pll_locked EXPORT_OF dla_pll.locked
	set_interface_property ddr4_emif_usr_reset_n EXPORT_OF emif_rst_export.out_reset
	set_interface_property reset EXPORT_OF rst_in.in_reset
	set_interface_property ninit_done EXPORT_OF user_rst_clkgate.ninit_done
	set_interface_property fpga_emif_mem_0 EXPORT_OF emif.mem_0
	set_interface_property fpga_emif_mem_ck_0 EXPORT_OF emif.mem_ck_0
	set_interface_property fpga_emif_mem_reset_n EXPORT_OF emif.mem_reset_n
	set_interface_property fpga_emif_oct_0 EXPORT_OF emif.oct_0
	set_interface_property fpga_emif_ref_clk EXPORT_OF emif.ref_clk
	set_interface_property h2f_reset EXPORT_OF hps.agx5_hps_h2f_reset
	set_interface_property h2f_warm_reset_handshake EXPORT_OF hps.agx5_hps_h2f_warm_reset_handshake
	set_interface_property hps_io EXPORT_OF hps.hps_io
	set_interface_property hps_emif_mem_0 EXPORT_OF hps.emif_hps_mem_0
	set_interface_property hps_emif_mem_ck_0 EXPORT_OF hps.emif_hps_mem_ck_0
	set_interface_property hps_emif_mem_reset_n EXPORT_OF hps.emif_hps_mem_reset_n
	set_interface_property hps_emif_oct_0 EXPORT_OF hps.emif_hps_oct_0
	set_interface_property hps_emif_pll_ref_clk EXPORT_OF hps.emif_hps_ref_clk
	set_interface_property src_prb_rst_sources EXPORT_OF hps.src_prb_rst_sources

	# set values for exposed HDL parameters
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.clockCrossingAdapter FIFO
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.enableAllPipelines FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.enableEccProtection FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.enableInstrumentation FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.fifoDepth 8
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.interconnectType STANDARD
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.maxAdditionalLatency 1
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.syncResets TRUE
	set_domain_assignment axi_address_span_extender_256.m_axi4 qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.clockCrossingAdapter FIFO
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.enableAllPipelines FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.enableEccProtection FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.enableInstrumentation FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.fifoDepth 8
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.interconnectType STANDARD
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.maxAdditionalLatency 1
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.syncResets TRUE
	set_domain_assignment axi_bridge_256_emif.m0 qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment dla.dla_to_ddr qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment dla.dla_to_ddr qsys_mm.clockCrossingAdapter AUTO
	set_domain_assignment dla.dla_to_ddr qsys_mm.enableAllPipelines FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.enableEccProtection FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.enableInstrumentation FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.fifoDepth 8
	set_domain_assignment dla.dla_to_ddr qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment dla.dla_to_ddr qsys_mm.interconnectType STANDARD
	set_domain_assignment dla.dla_to_ddr qsys_mm.maxAdditionalLatency 1
	set_domain_assignment dla.dla_to_ddr qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment dla.dla_to_ddr qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment dla.dla_to_ddr qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment dla.dla_to_ddr qsys_mm.syncResets TRUE
	set_domain_assignment dla.dla_to_ddr qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps.dma_to_ddr qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps.dma_to_ddr qsys_mm.clockCrossingAdapter FIFO
	set_domain_assignment hps.dma_to_ddr qsys_mm.enableAllPipelines FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.enableEccProtection FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.enableInstrumentation FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.fifoDepth 8
	set_domain_assignment hps.dma_to_ddr qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment hps.dma_to_ddr qsys_mm.interconnectType STANDARD
	set_domain_assignment hps.dma_to_ddr qsys_mm.maxAdditionalLatency 1
	set_domain_assignment hps.dma_to_ddr qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment hps.dma_to_ddr qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment hps.dma_to_ddr qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment hps.dma_to_ddr qsys_mm.syncResets TRUE
	set_domain_assignment hps.dma_to_ddr qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps.hps_to_csr qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps.hps_to_csr qsys_mm.clockCrossingAdapter FIFO
	set_domain_assignment hps.hps_to_csr qsys_mm.enableAllPipelines FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.enableEccProtection FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.enableInstrumentation FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.fifoDepth 8
	set_domain_assignment hps.hps_to_csr qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment hps.hps_to_csr qsys_mm.interconnectType STANDARD
	set_domain_assignment hps.hps_to_csr qsys_mm.maxAdditionalLatency 1
	set_domain_assignment hps.hps_to_csr qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment hps.hps_to_csr qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment hps.hps_to_csr qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment hps.hps_to_csr qsys_mm.syncResets TRUE
	set_domain_assignment hps.hps_to_csr qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_postadaptation_assignment mm_interconnect_0|addr_extend_0_windowed_slave_burst_adapter.source0/addr_extend_0_windowed_slave_agent.cp qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|addr_extend_0_windowed_slave_cmd_width_adapter.src/addr_extend_0_windowed_slave_burst_adapter.sink0 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|dla_0_dla_to_ddr_agent.cp/router.sink qsys_mm.postTransform.pipelineCount 1

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="axi_address_span_extender_256">
  <datum __value="_sortIndex" value="9" type="int" />
 </element>
 <element __value="axi_bridge_256">
  <datum __value="_sortIndex" value="7" type="int" />
 </element>
 <element __value="axi_bridge_256_emif">
  <datum __value="_sortIndex" value="6" type="int" />
 </element>
 <element __value="clk_100">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="dla">
  <datum __value="_sortIndex" value="8" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="dla_pll">
  <datum __value="_sortIndex" value="10" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="emif">
  <datum __value="_sortIndex" value="5" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="emif_rst_export">
  <datum __value="_sortIndex" value="2" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="hps">
  <datum __value="_sortIndex" value="4" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="hps_1">
  <datum __value="_sortIndex" value="8" type="int" />
 </element>
 <element __value="rst_in">
  <datum __value="_sortIndex" value="1" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="user_rst_clkgate">
  <datum __value="_sortIndex" value="3" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {system.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {system}

	# save the system
	sync_sysinfo_parameters
	save_system system
}

# create the system "dla"
proc do_create_dla {} {
	# create the system
	create_system dla
	set_project_property BOARD {Agilex 5 FPGA E-Series 065B Modular Development Kit MK-A5E065BB32AES1}
	set_project_property DEVICE {A5ED065BB32AE6SR0}
	set_project_property DEVICE_FAMILY {Agilex 5}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component altera_ai_ip_0 ip/dla/dla_altera_ai_ip_2.ip altera_ai_ip altera_ai_ip_0
	load_component altera_ai_ip_0
	set_component_parameter_value ARCH_OPTION {AGX5_Performance_AGX5}
	set_component_parameter_value C_DDR_AXI_ADDR_WIDTH {32}
	set_component_parameter_value C_DDR_AXI_DATA_WIDTH {256}
	set_component_parameter_value C_DDR_AXI_READ_ID_WIDTH {2}
	# Even though the DLA design for Agilex 5 can use AXI Write ID up to 8 bits for pure performance, we truncate to 2 here.
	set_component_parameter_value C_DDR_AXI_WRITE_ID_WIDTH {2}
	set_component_parameter_value C_OMNI_CAP_ID_ASSOCIATED {0}
	set_component_parameter_value C_OMNI_CAP_ID_COMPONENT {0}
	set_component_parameter_value C_OMNI_CAP_IRQ {255}
	set_component_parameter_value C_OMNI_CAP_IRQ_ENABLE {0}
	set_component_parameter_value C_OMNI_CAP_IRQ_ENABLE_EN {0}
	set_component_parameter_value C_OMNI_CAP_IRQ_STATUS {0}
	set_component_parameter_value C_OMNI_CAP_IRQ_STATUS_EN {0}
	set_component_parameter_value C_OMNI_CAP_SIZE {2048}
	set_component_parameter_value C_OMNI_CAP_TAG {0}
	set_component_parameter_value C_OMNI_CAP_TYPE {949}
	set_component_parameter_value C_OMNI_CAP_VERSION {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation altera_ai_ip_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface dla_clk clock INPUT
	set_instantiation_interface_parameter_value dla_clk clockRate {0}
	set_instantiation_interface_parameter_value dla_clk externallyDriven {false}
	set_instantiation_interface_parameter_value dla_clk ptfSchematicName {}
	add_instantiation_interface_port dla_clk dla_clk clk 1 STD_LOGIC Input
	add_instantiation_interface ddr_clk clock INPUT
	set_instantiation_interface_parameter_value ddr_clk clockRate {0}
	set_instantiation_interface_parameter_value ddr_clk externallyDriven {false}
	set_instantiation_interface_parameter_value ddr_clk ptfSchematicName {}
	add_instantiation_interface_port ddr_clk ddr_clk clk 1 STD_LOGIC Input
	add_instantiation_interface irq_clk clock INPUT
	set_instantiation_interface_parameter_value irq_clk clockRate {0}
	set_instantiation_interface_parameter_value irq_clk externallyDriven {false}
	set_instantiation_interface_parameter_value irq_clk ptfSchematicName {}
	add_instantiation_interface_port irq_clk irq_clk clk 1 STD_LOGIC Input
	add_instantiation_interface dla_resetn reset INPUT
	set_instantiation_interface_parameter_value dla_resetn associatedClock {dla_clk}
	set_instantiation_interface_parameter_value dla_resetn synchronousEdges {DEASSERT}
	add_instantiation_interface_port dla_resetn dla_resetn reset_n 1 STD_LOGIC Input
	add_instantiation_interface csr_axi axi4lite INPUT
	set_instantiation_interface_parameter_value csr_axi addressCheck {false}
	set_instantiation_interface_parameter_value csr_axi associatedClock {ddr_clk}
	set_instantiation_interface_parameter_value csr_axi associatedReset {dla_resetn}
	set_instantiation_interface_parameter_value csr_axi bridgesToMaster {}
	set_instantiation_interface_parameter_value csr_axi combinedAcceptanceCapability {1}
	set_instantiation_interface_parameter_value csr_axi dataCheck {false}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureId {35}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureType {3}
	set_instantiation_interface_parameter_value csr_axi dfhGroupId {0}
	set_instantiation_interface_parameter_value csr_axi dfhParameterData {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterDataLength {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterId {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterName {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterVersion {}
	set_instantiation_interface_parameter_value csr_axi isTranslator {false}
	set_instantiation_interface_parameter_value csr_axi maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value csr_axi maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value csr_axi maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value csr_axi optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value csr_axi poison {false}
	set_instantiation_interface_parameter_value csr_axi readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value csr_axi readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value csr_axi securityAttribute {false}
	set_instantiation_interface_parameter_value csr_axi traceSignals {false}
	set_instantiation_interface_parameter_value csr_axi trustzoneAware {true}
	set_instantiation_interface_parameter_value csr_axi uniqueIdSupport {false}
	set_instantiation_interface_parameter_value csr_axi userData {false}
	set_instantiation_interface_parameter_value csr_axi wakeupSignals {false}
	set_instantiation_interface_parameter_value csr_axi writeAcceptanceCapability {1}
	add_instantiation_interface_port csr_axi csr_axi_awaddr awaddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr_axi csr_axi_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port csr_axi csr_axi_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port csr_axi csr_axi_wdata wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr_axi csr_axi_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port csr_axi csr_axi_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port csr_axi csr_axi_wstrb wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr_axi csr_axi_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr_axi csr_axi_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port csr_axi csr_axi_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port csr_axi csr_axi_rdata rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr_axi csr_axi_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr_axi csr_axi_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port csr_axi csr_axi_rready rready 1 STD_LOGIC Input
	add_instantiation_interface_port csr_axi csr_axi_araddr araddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr_axi csr_axi_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port csr_axi csr_axi_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port csr_axi csr_axi_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr_axi csr_axi_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface ddr_axi axi4 OUTPUT
	set_instantiation_interface_parameter_value ddr_axi addressCheck {false}
	set_instantiation_interface_parameter_value ddr_axi associatedClock {ddr_clk}
	set_instantiation_interface_parameter_value ddr_axi associatedReset {dla_resetn}
	set_instantiation_interface_parameter_value ddr_axi combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value ddr_axi dataCheck {false}
	set_instantiation_interface_parameter_value ddr_axi enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value ddr_axi isTranslator {false}
	set_instantiation_interface_parameter_value ddr_axi issuesFIXEDBursts {false}
	set_instantiation_interface_parameter_value ddr_axi issuesINCRBursts {true}
	set_instantiation_interface_parameter_value ddr_axi issuesWRAPBursts {false}
	set_instantiation_interface_parameter_value ddr_axi maximumOutstandingReads {16}
	set_instantiation_interface_parameter_value ddr_axi maximumOutstandingTransactions {16}
	set_instantiation_interface_parameter_value ddr_axi maximumOutstandingWrites {16}
	set_instantiation_interface_parameter_value ddr_axi noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value ddr_axi optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value ddr_axi poison {false}
	set_instantiation_interface_parameter_value ddr_axi readIssuingCapability {32}
	set_instantiation_interface_parameter_value ddr_axi securityAttribute {false}
	set_instantiation_interface_parameter_value ddr_axi traceSignals {false}
	set_instantiation_interface_parameter_value ddr_axi trustzoneAware {true}
	set_instantiation_interface_parameter_value ddr_axi uniqueIdSupport {false}
	set_instantiation_interface_parameter_value ddr_axi userData {false}
	set_instantiation_interface_parameter_value ddr_axi wakeupSignals {false}
	set_instantiation_interface_parameter_value ddr_axi writeIssuingCapability {32}
	add_instantiation_interface_port ddr_axi ddr_axi_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port ddr_axi ddr_axi_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port ddr_axi ddr_axi_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port ddr_axi ddr_axi_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port ddr_axi ddr_axi_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port ddr_axi ddr_axi_rready rready 1 STD_LOGIC Output
	add_instantiation_interface_port ddr_axi ddr_axi_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port ddr_axi ddr_axi_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port ddr_axi ddr_axi_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port ddr_axi ddr_axi_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port ddr_axi ddr_axi_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port ddr_axi ddr_axi_awaddr awaddr 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_awid awid 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_araddr araddr 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_arid arid 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ddr_axi ddr_axi_rid rid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ddr_axi ddr_axi_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_bid bid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface irq_level interrupt INPUT
	set_instantiation_interface_parameter_value irq_level associatedAddressablePoint {csr_axi}
	set_instantiation_interface_parameter_value irq_level associatedClock {irq_clk}
	set_instantiation_interface_parameter_value irq_level associatedReset {}
	set_instantiation_interface_parameter_value irq_level bridgedReceiverOffset {0}
	set_instantiation_interface_parameter_value irq_level bridgesToReceiver {}
	set_instantiation_interface_parameter_value irq_level irqScheme {INDIVIDUAL_REQUESTS}
	add_instantiation_interface_port irq_level irq_level irq 1 STD_LOGIC Output
	save_instantiation
	add_component csr_bridge_0 ip/dla/dla_csr_bridge_0.ip altera_avalon_mm_bridge csr_bridge_0
	load_component csr_bridge_0
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {16}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {8}
	set_component_parameter_value MAX_PENDING_RESPONSES {4}
	set_component_parameter_value MAX_PENDING_WRITES {0}
	set_component_parameter_value PIPELINE_COMMAND {1}
	set_component_parameter_value PIPELINE_RESPONSE {1}
	set_component_parameter_value S0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value SYMBOL_WIDTH {8}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_AUTO_ADDRESS_WIDTH {0}
	set_component_parameter_value USE_RESPONSE {0}
	set_component_parameter_value USE_WRITERESPONSE {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation csr_bridge_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface s0 avalon INPUT
	set_instantiation_interface_parameter_value s0 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s0 addressGroup {0}
	set_instantiation_interface_parameter_value s0 addressSpan {65536}
	set_instantiation_interface_parameter_value s0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clk}
	set_instantiation_interface_parameter_value s0 associatedReset {reset}
	set_instantiation_interface_parameter_value s0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s0 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {m0}
	set_instantiation_interface_parameter_value s0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s0 holdTime {0}
	set_instantiation_interface_parameter_value s0 interleaveBursts {false}
	set_instantiation_interface_parameter_value s0 isBigEndian {false}
	set_instantiation_interface_parameter_value s0 isFlash {false}
	set_instantiation_interface_parameter_value s0 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s0 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s0 linewrapBursts {false}
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {4}
	set_instantiation_interface_parameter_value s0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s0 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s0 prSafe {false}
	set_instantiation_interface_parameter_value s0 printableDevice {false}
	set_instantiation_interface_parameter_value s0 readLatency {0}
	set_instantiation_interface_parameter_value s0 readWaitStates {0}
	set_instantiation_interface_parameter_value s0 readWaitTime {0}
	set_instantiation_interface_parameter_value s0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s0 setupTime {0}
	set_instantiation_interface_parameter_value s0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s0 transparentBridge {false}
	set_instantiation_interface_parameter_value s0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s0 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s0 writeLatency {0}
	set_instantiation_interface_parameter_value s0 writeWaitStates {0}
	set_instantiation_interface_parameter_value s0 writeWaitTime {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_burstcount burstcount 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_address address 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_write write 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_read read 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_debugaccess debugaccess 1 STD_LOGIC Input
	add_instantiation_interface m0 avalon OUTPUT
	set_instantiation_interface_parameter_value m0 adaptsTo {}
	set_instantiation_interface_parameter_value m0 addressGroup {0}
	set_instantiation_interface_parameter_value m0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value m0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {reset}
	set_instantiation_interface_parameter_value m0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value m0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value m0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value m0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value m0 dBSBigEndian {false}
	set_instantiation_interface_parameter_value m0 doStreamReads {false}
	set_instantiation_interface_parameter_value m0 doStreamWrites {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 holdTime {0}
	set_instantiation_interface_parameter_value m0 interleaveBursts {false}
	set_instantiation_interface_parameter_value m0 isAsynchronous {false}
	set_instantiation_interface_parameter_value m0 isBigEndian {false}
	set_instantiation_interface_parameter_value m0 isReadable {false}
	set_instantiation_interface_parameter_value m0 isWriteable {false}
	set_instantiation_interface_parameter_value m0 linewrapBursts {false}
	set_instantiation_interface_parameter_value m0 maxAddressWidth {32}
	set_instantiation_interface_parameter_value m0 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value m0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value m0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value m0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value m0 optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value m0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value m0 writeWaitTime {0}
	add_instantiation_interface_port m0 m0_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_readdata readdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_burstcount burstcount 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component csr_clk_0 ip/dla/dla_csr_clk_0.ip altera_clock_bridge csr_clk_0
	load_component csr_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation csr_clk_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {100000000}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {100000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {100000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component csr_rst_0 ip/dla/dla_csr_rst_0.ip altera_reset_bridge csr_rst_0
	load_component csr_rst_0
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation csr_rst_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset reset 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset reset 1 STD_LOGIC Output
	save_instantiation
	add_component ddr_bridge_0 ip/dla/dla_ddr_bridge_0.ip altera_avalon_mm_bridge ddr_bridge_0
	load_component ddr_bridge_0
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {32}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {64}
	set_component_parameter_value MAX_PENDING_RESPONSES {16}
	set_component_parameter_value MAX_PENDING_WRITES {0}
	set_component_parameter_value PIPELINE_COMMAND {1}
	set_component_parameter_value PIPELINE_RESPONSE {1}
	set_component_parameter_value S0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value SYMBOL_WIDTH {8}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_AUTO_ADDRESS_WIDTH {0}
	set_component_parameter_value USE_RESPONSE {0}
	set_component_parameter_value USE_WRITERESPONSE {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ddr_bridge_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface s0 avalon INPUT
	set_instantiation_interface_parameter_value s0 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s0 addressGroup {0}
	set_instantiation_interface_parameter_value s0 addressSpan {4294967296}
	set_instantiation_interface_parameter_value s0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clk}
	set_instantiation_interface_parameter_value s0 associatedReset {reset}
	set_instantiation_interface_parameter_value s0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s0 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {m0}
	set_instantiation_interface_parameter_value s0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s0 holdTime {0}
	set_instantiation_interface_parameter_value s0 interleaveBursts {false}
	set_instantiation_interface_parameter_value s0 isBigEndian {false}
	set_instantiation_interface_parameter_value s0 isFlash {false}
	set_instantiation_interface_parameter_value s0 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s0 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s0 linewrapBursts {false}
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {16}
	set_instantiation_interface_parameter_value s0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s0 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s0 prSafe {false}
	set_instantiation_interface_parameter_value s0 printableDevice {false}
	set_instantiation_interface_parameter_value s0 readLatency {0}
	set_instantiation_interface_parameter_value s0 readWaitStates {0}
	set_instantiation_interface_parameter_value s0 readWaitTime {0}
	set_instantiation_interface_parameter_value s0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s0 setupTime {0}
	set_instantiation_interface_parameter_value s0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s0 transparentBridge {false}
	set_instantiation_interface_parameter_value s0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s0 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s0 writeLatency {0}
	set_instantiation_interface_parameter_value s0 writeWaitStates {0}
	set_instantiation_interface_parameter_value s0 writeWaitTime {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_readdata readdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_burstcount burstcount 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_writedata writedata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_address address 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_write write 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_read read 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_debugaccess debugaccess 1 STD_LOGIC Input
	add_instantiation_interface m0 avalon OUTPUT
	set_instantiation_interface_parameter_value m0 adaptsTo {}
	set_instantiation_interface_parameter_value m0 addressGroup {0}
	set_instantiation_interface_parameter_value m0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value m0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {reset}
	set_instantiation_interface_parameter_value m0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value m0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value m0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value m0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value m0 dBSBigEndian {false}
	set_instantiation_interface_parameter_value m0 doStreamReads {false}
	set_instantiation_interface_parameter_value m0 doStreamWrites {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 holdTime {0}
	set_instantiation_interface_parameter_value m0 interleaveBursts {false}
	set_instantiation_interface_parameter_value m0 isAsynchronous {false}
	set_instantiation_interface_parameter_value m0 isBigEndian {false}
	set_instantiation_interface_parameter_value m0 isReadable {false}
	set_instantiation_interface_parameter_value m0 isWriteable {false}
	set_instantiation_interface_parameter_value m0 linewrapBursts {false}
	set_instantiation_interface_parameter_value m0 maxAddressWidth {32}
	set_instantiation_interface_parameter_value m0 maximumPendingReadTransactions {16}
	set_instantiation_interface_parameter_value m0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value m0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value m0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value m0 optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value m0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value m0 writeWaitTime {0}
	add_instantiation_interface_port m0 m0_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_readdata readdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_burstcount burstcount 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component ddr_clk_0 ip/dla/dla_ddr_clk_0.ip altera_clock_bridge ddr_clk_0
	load_component ddr_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ddr_clk_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {200000000}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {200000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {200000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component ddr_rst_0 ip/dla/dla_ddr_rst_0.ip altera_reset_bridge ddr_rst_0
	load_component ddr_rst_0
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ddr_rst_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset reset 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset reset 1 STD_LOGIC Output
	save_instantiation
	add_component dla_clk_0 ip/dla/dla_clock_bridge_0.ip altera_clock_bridge dla_clk_0
	load_component dla_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_clk_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {300000000}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {300000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {300000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component dla_msgdma_0 ip/dla/dla_msgdma_0.ip altera_msgdma dla_msgdma_0
	load_component dla_msgdma_0
	set_component_parameter_value BURST_ENABLE {1}
	set_component_parameter_value BURST_WRAPPING_SUPPORT {0}
	set_component_parameter_value CHANNEL_ENABLE {0}
	set_component_parameter_value CHANNEL_WIDTH {8}
	set_component_parameter_value DATA_FIFO_DEPTH {4096}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value DESCRIPTOR_FIFO_DEPTH {128}
	set_component_parameter_value ENHANCED_FEATURES {1}
	set_component_parameter_value ERROR_ENABLE {0}
	set_component_parameter_value ERROR_WIDTH {8}
	set_component_parameter_value EXPOSE_ST_PORT {0}
	set_component_parameter_value FIX_ADDRESS_WIDTH {32}
	set_component_parameter_value MAX_BURST_COUNT {8}
	set_component_parameter_value MAX_BYTE {1073741824}
	set_component_parameter_value MAX_STRIDE {1}
	set_component_parameter_value MODE {2}
	set_component_parameter_value NO_BYTEENABLES {0}
	set_component_parameter_value PACKET_ENABLE {0}
	set_component_parameter_value PREFETCHER_DATA_WIDTH {32}
	set_component_parameter_value PREFETCHER_ENABLE {0}
	set_component_parameter_value PREFETCHER_MAX_READ_BURST_COUNT {2}
	set_component_parameter_value PREFETCHER_READ_BURST_ENABLE {0}
	set_component_parameter_value PROGRAMMABLE_BURST_ENABLE {0}
	set_component_parameter_value RESPONSE_PORT {2}
	set_component_parameter_value SIDEBAND_ENABLE {0}
	set_component_parameter_value STRIDE_ENABLE {0}
	set_component_parameter_value TRANSFER_TYPE {Aligned Accesses}
	set_component_parameter_value USE_FIX_ADDRESS_WIDTH {0}
	set_component_parameter_value WRITE_RESPONSE_ENABLE {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_msgdma_0
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_ENABLE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_WRAPPING_SUPPORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_FIFO_DEPTH {4096}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {256}
	set_instantiation_assignment_value embeddedsw.CMacro.DESCRIPTOR_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DMA_MODE {2}
	set_instantiation_assignment_value embeddedsw.CMacro.ENHANCED_FEATURES {1}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BURST_COUNT {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BYTE {1073741824}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_STRIDE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PREFETCHER_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PROGRAMMABLE_BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.RESPONSE_PORT {2}
	set_instantiation_assignment_value embeddedsw.CMacro.SIDEBAND_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.STRIDE_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.STRIDE_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.TRANSFER_TYPE {Aligned Accesses}
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,msgdma-1.0}
	set_instantiation_assignment_value embeddedsw.dts.group {msgdma}
	set_instantiation_assignment_value embeddedsw.dts.name {msgdma}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clock_clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset_n reset INPUT
	set_instantiation_interface_parameter_value reset_n associatedClock {clock}
	set_instantiation_interface_parameter_value reset_n synchronousEdges {BOTH}
	add_instantiation_interface_port reset_n reset_n_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface csr avalon INPUT
	set_instantiation_interface_parameter_value csr addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value csr addressGroup {0}
	set_instantiation_interface_parameter_value csr addressSpan {32}
	set_instantiation_interface_parameter_value csr addressUnits {WORDS}
	set_instantiation_interface_parameter_value csr alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value csr associatedClock {clock}
	set_instantiation_interface_parameter_value csr associatedReset {reset_n}
	set_instantiation_interface_parameter_value csr bitsPerSymbol {8}
	set_instantiation_interface_parameter_value csr bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value csr bridgesToMaster {}
	set_instantiation_interface_parameter_value csr burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value csr burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value csr constantBurstBehavior {false}
	set_instantiation_interface_parameter_value csr dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value csr dfhFeatureId {35}
	set_instantiation_interface_parameter_value csr dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value csr dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value csr dfhFeatureType {3}
	set_instantiation_interface_parameter_value csr dfhGroupId {0}
	set_instantiation_interface_parameter_value csr dfhParameterData {}
	set_instantiation_interface_parameter_value csr dfhParameterDataLength {}
	set_instantiation_interface_parameter_value csr dfhParameterId {}
	set_instantiation_interface_parameter_value csr dfhParameterName {}
	set_instantiation_interface_parameter_value csr dfhParameterVersion {}
	set_instantiation_interface_parameter_value csr explicitAddressSpan {0}
	set_instantiation_interface_parameter_value csr holdTime {0}
	set_instantiation_interface_parameter_value csr interleaveBursts {false}
	set_instantiation_interface_parameter_value csr isBigEndian {false}
	set_instantiation_interface_parameter_value csr isFlash {false}
	set_instantiation_interface_parameter_value csr isMemoryDevice {false}
	set_instantiation_interface_parameter_value csr isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value csr linewrapBursts {false}
	set_instantiation_interface_parameter_value csr maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value csr maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value csr minimumReadLatency {1}
	set_instantiation_interface_parameter_value csr minimumResponseLatency {1}
	set_instantiation_interface_parameter_value csr minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value csr prSafe {false}
	set_instantiation_interface_parameter_value csr printableDevice {false}
	set_instantiation_interface_parameter_value csr readLatency {1}
	set_instantiation_interface_parameter_value csr readWaitStates {1}
	set_instantiation_interface_parameter_value csr readWaitTime {1}
	set_instantiation_interface_parameter_value csr registerIncomingSignals {false}
	set_instantiation_interface_parameter_value csr registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value csr setupTime {0}
	set_instantiation_interface_parameter_value csr timingUnits {Cycles}
	set_instantiation_interface_parameter_value csr transparentBridge {false}
	set_instantiation_interface_parameter_value csr waitrequestAllowance {0}
	set_instantiation_interface_parameter_value csr waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value csr wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value csr writeLatency {0}
	set_instantiation_interface_parameter_value csr writeWaitStates {0}
	set_instantiation_interface_parameter_value csr writeWaitTime {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value csr address_map {<address-map><slave name='csr' start='0x0' end='0x20' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value csr address_width {5}
	set_instantiation_interface_sysinfo_parameter_value csr max_slave_data_width {32}
	add_instantiation_interface_port csr csr_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_write write 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr csr_read read 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_address address 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface descriptor_slave avalon INPUT
	set_instantiation_interface_parameter_value descriptor_slave addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value descriptor_slave addressGroup {0}
	set_instantiation_interface_parameter_value descriptor_slave addressSpan {32}
	set_instantiation_interface_parameter_value descriptor_slave addressUnits {WORDS}
	set_instantiation_interface_parameter_value descriptor_slave alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value descriptor_slave associatedClock {clock}
	set_instantiation_interface_parameter_value descriptor_slave associatedReset {reset_n}
	set_instantiation_interface_parameter_value descriptor_slave bitsPerSymbol {8}
	set_instantiation_interface_parameter_value descriptor_slave bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value descriptor_slave bridgesToMaster {}
	set_instantiation_interface_parameter_value descriptor_slave burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value descriptor_slave burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value descriptor_slave constantBurstBehavior {false}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureId {35}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureType {3}
	set_instantiation_interface_parameter_value descriptor_slave dfhGroupId {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterData {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterDataLength {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterId {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterName {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterVersion {}
	set_instantiation_interface_parameter_value descriptor_slave explicitAddressSpan {0}
	set_instantiation_interface_parameter_value descriptor_slave holdTime {0}
	set_instantiation_interface_parameter_value descriptor_slave interleaveBursts {false}
	set_instantiation_interface_parameter_value descriptor_slave isBigEndian {false}
	set_instantiation_interface_parameter_value descriptor_slave isFlash {false}
	set_instantiation_interface_parameter_value descriptor_slave isMemoryDevice {false}
	set_instantiation_interface_parameter_value descriptor_slave isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value descriptor_slave linewrapBursts {false}
	set_instantiation_interface_parameter_value descriptor_slave maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value descriptor_slave maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value descriptor_slave minimumReadLatency {1}
	set_instantiation_interface_parameter_value descriptor_slave minimumResponseLatency {1}
	set_instantiation_interface_parameter_value descriptor_slave minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value descriptor_slave prSafe {false}
	set_instantiation_interface_parameter_value descriptor_slave printableDevice {false}
	set_instantiation_interface_parameter_value descriptor_slave readLatency {0}
	set_instantiation_interface_parameter_value descriptor_slave readWaitStates {1}
	set_instantiation_interface_parameter_value descriptor_slave readWaitTime {1}
	set_instantiation_interface_parameter_value descriptor_slave registerIncomingSignals {false}
	set_instantiation_interface_parameter_value descriptor_slave registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value descriptor_slave setupTime {0}
	set_instantiation_interface_parameter_value descriptor_slave timingUnits {Cycles}
	set_instantiation_interface_parameter_value descriptor_slave transparentBridge {false}
	set_instantiation_interface_parameter_value descriptor_slave waitrequestAllowance {0}
	set_instantiation_interface_parameter_value descriptor_slave waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value descriptor_slave wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value descriptor_slave writeLatency {0}
	set_instantiation_interface_parameter_value descriptor_slave writeWaitStates {0}
	set_instantiation_interface_parameter_value descriptor_slave writeWaitTime {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_map {<address-map><slave name='descriptor_slave' start='0x0' end='0x20' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_width {5}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave max_slave_data_width {256}
	add_instantiation_interface_port descriptor_slave descriptor_slave_write write 1 STD_LOGIC Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port descriptor_slave descriptor_slave_writedata writedata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface csr_irq interrupt INPUT
	set_instantiation_interface_parameter_value csr_irq associatedAddressablePoint {csr}
	set_instantiation_interface_parameter_value csr_irq associatedClock {clock}
	set_instantiation_interface_parameter_value csr_irq associatedReset {reset_n}
	set_instantiation_interface_parameter_value csr_irq bridgedReceiverOffset {0}
	set_instantiation_interface_parameter_value csr_irq bridgesToReceiver {}
	set_instantiation_interface_parameter_value csr_irq irqScheme {NONE}
	add_instantiation_interface_port csr_irq csr_irq_irq irq 1 STD_LOGIC Output
	add_instantiation_interface mm_write avalon OUTPUT
	set_instantiation_interface_parameter_value mm_write adaptsTo {}
	set_instantiation_interface_parameter_value mm_write addressGroup {0}
	set_instantiation_interface_parameter_value mm_write addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value mm_write alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value mm_write associatedClock {clock}
	set_instantiation_interface_parameter_value mm_write associatedReset {reset_n}
	set_instantiation_interface_parameter_value mm_write bitsPerSymbol {8}
	set_instantiation_interface_parameter_value mm_write burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value mm_write burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value mm_write constantBurstBehavior {false}
	set_instantiation_interface_parameter_value mm_write dBSBigEndian {false}
	set_instantiation_interface_parameter_value mm_write doStreamReads {false}
	set_instantiation_interface_parameter_value mm_write doStreamWrites {false}
	set_instantiation_interface_parameter_value mm_write enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value mm_write holdTime {0}
	set_instantiation_interface_parameter_value mm_write interleaveBursts {false}
	set_instantiation_interface_parameter_value mm_write isAsynchronous {false}
	set_instantiation_interface_parameter_value mm_write isBigEndian {false}
	set_instantiation_interface_parameter_value mm_write isReadable {false}
	set_instantiation_interface_parameter_value mm_write isWriteable {false}
	set_instantiation_interface_parameter_value mm_write linewrapBursts {false}
	set_instantiation_interface_parameter_value mm_write maxAddressWidth {32}
	set_instantiation_interface_parameter_value mm_write maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value mm_write maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value mm_write minimumReadLatency {1}
	set_instantiation_interface_parameter_value mm_write minimumResponseLatency {1}
	set_instantiation_interface_parameter_value mm_write optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value mm_write prSafe {false}
	set_instantiation_interface_parameter_value mm_write readLatency {0}
	set_instantiation_interface_parameter_value mm_write readWaitTime {1}
	set_instantiation_interface_parameter_value mm_write registerIncomingSignals {false}
	set_instantiation_interface_parameter_value mm_write registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value mm_write setupTime {0}
	set_instantiation_interface_parameter_value mm_write timingUnits {Cycles}
	set_instantiation_interface_parameter_value mm_write waitrequestAllowance {0}
	set_instantiation_interface_parameter_value mm_write waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value mm_write writeWaitTime {0}
	add_instantiation_interface_port mm_write mm_write_address address 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_write write 1 STD_LOGIC Output
	add_instantiation_interface_port mm_write mm_write_byteenable byteenable 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_writedata writedata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_write mm_write_burstcount burstcount 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface st_sink avalon_streaming INPUT
	set_instantiation_interface_parameter_value st_sink associatedClock {clock}
	set_instantiation_interface_parameter_value st_sink associatedReset {reset_n}
	set_instantiation_interface_parameter_value st_sink beatsPerCycle {1}
	set_instantiation_interface_parameter_value st_sink dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value st_sink emptyWithinPacket {false}
	set_instantiation_interface_parameter_value st_sink errorDescriptor {}
	set_instantiation_interface_parameter_value st_sink firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value st_sink highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value st_sink maxChannel {0}
	set_instantiation_interface_parameter_value st_sink packetDescription {}
	set_instantiation_interface_parameter_value st_sink prSafe {false}
	set_instantiation_interface_parameter_value st_sink readyAllowance {0}
	set_instantiation_interface_parameter_value st_sink readyLatency {0}
	set_instantiation_interface_parameter_value st_sink symbolsPerBeat {32}
	add_instantiation_interface_port st_sink st_sink_data data 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port st_sink st_sink_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port st_sink st_sink_ready ready 1 STD_LOGIC Output
	save_instantiation
	add_component dla_rst_0 ip/dla/dla_reset_bridge_0.ip altera_reset_bridge dla_rst_0
	load_component dla_rst_0
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_rst_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
	save_instantiation
	add_component jtag_uart_0 ip/dla/dla_jtag_uart_0.ip altera_avalon_jtag_uart jtag_uart_0
	load_component jtag_uart_0
	set_component_parameter_value allowMultipleConnections {0}
	set_component_parameter_value hubInstanceID {0}
	set_component_parameter_value printingMethod {0}
	set_component_parameter_value readBufferDepth {64}
	set_component_parameter_value readIRQThreshold {8}
	set_component_parameter_value simInputCharacterStream {}
	set_component_parameter_value simInteractiveOptions {NO_INTERACTIVE_WINDOWS}
	set_component_parameter_value useRegistersForReadBuffer {0}
	set_component_parameter_value useRegistersForWriteBuffer {0}
	set_component_parameter_value useRelativePathForSimFile {0}
	set_component_parameter_value writeBufferDepth {64}
	set_component_parameter_value writeIRQThreshold {8}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation jtag_uart_0
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.READ_DEPTH {64}
	set_instantiation_assignment_value embeddedsw.CMacro.READ_THRESHOLD {8}
	set_instantiation_assignment_value embeddedsw.CMacro.WRITE_DEPTH {64}
	set_instantiation_assignment_value embeddedsw.CMacro.WRITE_THRESHOLD {8}
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,juart-1.0}
	set_instantiation_assignment_value embeddedsw.dts.group {serial}
	set_instantiation_assignment_value embeddedsw.dts.name {juart}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset rst_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface avalon_jtag_slave avalon INPUT
	set_instantiation_interface_parameter_value avalon_jtag_slave addressAlignment {NATIVE}
	set_instantiation_interface_parameter_value avalon_jtag_slave addressGroup {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave addressSpan {2}
	set_instantiation_interface_parameter_value avalon_jtag_slave addressUnits {WORDS}
	set_instantiation_interface_parameter_value avalon_jtag_slave alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave associatedClock {clk}
	set_instantiation_interface_parameter_value avalon_jtag_slave associatedReset {reset}
	set_instantiation_interface_parameter_value avalon_jtag_slave bitsPerSymbol {8}
	set_instantiation_interface_parameter_value avalon_jtag_slave bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave bridgesToMaster {}
	set_instantiation_interface_parameter_value avalon_jtag_slave burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value avalon_jtag_slave constantBurstBehavior {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhFeatureId {35}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhFeatureType {3}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhGroupId {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhParameterData {}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhParameterDataLength {}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhParameterId {}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhParameterName {}
	set_instantiation_interface_parameter_value avalon_jtag_slave dfhParameterVersion {}
	set_instantiation_interface_parameter_value avalon_jtag_slave explicitAddressSpan {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave holdTime {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave interleaveBursts {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave isBigEndian {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave isFlash {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave isMemoryDevice {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave linewrapBursts {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave minimumReadLatency {1}
	set_instantiation_interface_parameter_value avalon_jtag_slave minimumResponseLatency {1}
	set_instantiation_interface_parameter_value avalon_jtag_slave minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value avalon_jtag_slave prSafe {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave printableDevice {true}
	set_instantiation_interface_parameter_value avalon_jtag_slave readLatency {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave readWaitStates {1}
	set_instantiation_interface_parameter_value avalon_jtag_slave readWaitTime {1}
	set_instantiation_interface_parameter_value avalon_jtag_slave registerIncomingSignals {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave setupTime {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave timingUnits {Cycles}
	set_instantiation_interface_parameter_value avalon_jtag_slave transparentBridge {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave waitrequestAllowance {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value avalon_jtag_slave wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value avalon_jtag_slave writeLatency {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave writeWaitStates {0}
	set_instantiation_interface_parameter_value avalon_jtag_slave writeWaitTime {0}
	set_instantiation_interface_assignment_value avalon_jtag_slave embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value avalon_jtag_slave embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value avalon_jtag_slave embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value avalon_jtag_slave embeddedsw.configuration.isPrintableDevice {1}
	set_instantiation_interface_sysinfo_parameter_value avalon_jtag_slave address_map {<address-map><slave name='avalon_jtag_slave' start='0x0' end='0x8' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value avalon_jtag_slave address_width {3}
	set_instantiation_interface_sysinfo_parameter_value avalon_jtag_slave max_slave_data_width {32}
	add_instantiation_interface_port avalon_jtag_slave av_chipselect chipselect 1 STD_LOGIC Input
	add_instantiation_interface_port avalon_jtag_slave av_address address 1 STD_LOGIC Input
	add_instantiation_interface_port avalon_jtag_slave av_read_n read_n 1 STD_LOGIC Input
	add_instantiation_interface_port avalon_jtag_slave av_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port avalon_jtag_slave av_write_n write_n 1 STD_LOGIC Input
	add_instantiation_interface_port avalon_jtag_slave av_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port avalon_jtag_slave av_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface irq interrupt INPUT
	set_instantiation_interface_parameter_value irq associatedAddressablePoint {avalon_jtag_slave}
	set_instantiation_interface_parameter_value irq associatedClock {clk}
	set_instantiation_interface_parameter_value irq associatedReset {reset}
	set_instantiation_interface_parameter_value irq bridgedReceiverOffset {0}
	set_instantiation_interface_parameter_value irq bridgesToReceiver {}
	set_instantiation_interface_parameter_value irq irqScheme {NONE}
	add_instantiation_interface_port irq av_irq irq 1 STD_LOGIC Output
	save_instantiation
	add_component mailbox_ram_0 ip/dla/dla_mailbox_ram_0.ip intel_onchip_memory mailbox_ram_0
	load_component mailbox_ram_0
	set_component_parameter_value AXI_interface {1}
	set_component_parameter_value allowInSystemMemoryContentEditor {0}
	set_component_parameter_value blockType {AUTO}
	set_component_parameter_value clockEnable {0}
	set_component_parameter_value copyInitFile {0}
	set_component_parameter_value dataWidth {32}
	set_component_parameter_value dataWidth2 {32}
	set_component_parameter_value dualPort {0}
	set_component_parameter_value ecc_check {0}
	set_component_parameter_value ecc_encoder_bypass {0}
	set_component_parameter_value ecc_pipeline_reg {0}
	set_component_parameter_value enPRInitMode {0}
	set_component_parameter_value enableDiffWidth {0}
	set_component_parameter_value gui_debugaccess {0}
	set_component_parameter_value idWidth {1}
	set_component_parameter_value initMemContent {1}
	set_component_parameter_value initializationFileName {onchip_mem.hex}
	set_component_parameter_value instanceID {NONE}
	set_component_parameter_value interfaceType {0}
	set_component_parameter_value lvl1OutputRegA {0}
	set_component_parameter_value lvl1OutputRegB {0}
	set_component_parameter_value lvl2OutputRegA {0}
	set_component_parameter_value lvl2OutputRegB {0}
	set_component_parameter_value memorySize {4096.0}
	set_component_parameter_value poison_enable {0}
	set_component_parameter_value readDuringWriteMode_Mixed {DONT_CARE}
	set_component_parameter_value resetrequest_enabled {1}
	set_component_parameter_value singleClockOperation {0}
	set_component_parameter_value tightly_coupled_ecc {0}
	set_component_parameter_value useNonDefaultInitFile {0}
	set_component_parameter_value writable {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation mailbox_ram_0
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CONTENTS_INFO {""}
	set_instantiation_assignment_value embeddedsw.CMacro.DUAL_PORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.GUI_RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_CONTENTS_FILE {dla_mailbox_ram_0_mailbox_ram_0}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_MEM_CONTENT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.INSTANCE_ID {NONE}
	set_instantiation_assignment_value embeddedsw.CMacro.NON_DEFAULT_INIT_FILE_ENABLED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.READ_DURING_WRITE_MODE {DONT_CARE}
	set_instantiation_assignment_value embeddedsw.CMacro.SINGLE_CLOCK_OP {0}
	set_instantiation_assignment_value embeddedsw.CMacro.SIZE_MULTIPLE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.SIZE_VALUE {4096}
	set_instantiation_assignment_value embeddedsw.CMacro.WRITABLE {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR {SIM_DIR}
	set_instantiation_assignment_value embeddedsw.memoryInfo.GENERATE_DAT_SYM {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.GENERATE_HEX {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.HAS_BYTE_LANE {0}
	set_instantiation_assignment_value embeddedsw.memoryInfo.HEX_INSTALL_DIR {QPF_DIR}
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_FILENAME {dla_mailbox_ram_0_mailbox_ram_0}
	set_instantiation_assignment_value postgeneration.simulation.init_file.param_name {INIT_FILE}
	set_instantiation_assignment_value postgeneration.simulation.init_file.type {MEM_INIT}
	add_instantiation_interface clk1 clock INPUT
	set_instantiation_interface_parameter_value clk1 clockRate {0}
	set_instantiation_interface_parameter_value clk1 externallyDriven {false}
	set_instantiation_interface_parameter_value clk1 ptfSchematicName {}
	add_instantiation_interface_port clk1 clk clk 1 STD_LOGIC Input
	add_instantiation_interface s1 avalon INPUT
	set_instantiation_interface_parameter_value s1 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s1 addressGroup {0}
	set_instantiation_interface_parameter_value s1 addressSpan {4096}
	set_instantiation_interface_parameter_value s1 addressUnits {WORDS}
	set_instantiation_interface_parameter_value s1 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s1 associatedClock {clk1}
	set_instantiation_interface_parameter_value s1 associatedReset {reset1}
	set_instantiation_interface_parameter_value s1 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s1 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s1 bridgesToMaster {}
	set_instantiation_interface_parameter_value s1 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s1 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s1 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s1 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s1 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s1 dfhGroupId {0}
	set_instantiation_interface_parameter_value s1 dfhParameterData {}
	set_instantiation_interface_parameter_value s1 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s1 dfhParameterId {}
	set_instantiation_interface_parameter_value s1 dfhParameterName {}
	set_instantiation_interface_parameter_value s1 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s1 explicitAddressSpan {4096}
	set_instantiation_interface_parameter_value s1 holdTime {0}
	set_instantiation_interface_parameter_value s1 interleaveBursts {false}
	set_instantiation_interface_parameter_value s1 isBigEndian {false}
	set_instantiation_interface_parameter_value s1 isFlash {false}
	set_instantiation_interface_parameter_value s1 isMemoryDevice {true}
	set_instantiation_interface_parameter_value s1 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s1 linewrapBursts {false}
	set_instantiation_interface_parameter_value s1 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value s1 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s1 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s1 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s1 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s1 prSafe {false}
	set_instantiation_interface_parameter_value s1 printableDevice {false}
	set_instantiation_interface_parameter_value s1 readLatency {1}
	set_instantiation_interface_parameter_value s1 readWaitStates {0}
	set_instantiation_interface_parameter_value s1 readWaitTime {0}
	set_instantiation_interface_parameter_value s1 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s1 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s1 setupTime {0}
	set_instantiation_interface_parameter_value s1 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s1 transparentBridge {false}
	set_instantiation_interface_parameter_value s1 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s1 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s1 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s1 writeLatency {0}
	set_instantiation_interface_parameter_value s1 writeWaitStates {0}
	set_instantiation_interface_parameter_value s1 writeWaitTime {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isMemoryDevice {1}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s1 address_map {<address-map><slave name='s1' start='0x0' end='0x1000' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s1 address_width {12}
	set_instantiation_interface_sysinfo_parameter_value s1 max_slave_data_width {32}
	add_instantiation_interface_port s1 address address 10 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 read read 1 STD_LOGIC Input
	add_instantiation_interface_port s1 readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s1 byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 write write 1 STD_LOGIC Input
	add_instantiation_interface_port s1 writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface reset1 reset INPUT
	set_instantiation_interface_parameter_value reset1 associatedClock {clk1}
	set_instantiation_interface_parameter_value reset1 synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset1 reset reset 1 STD_LOGIC Input
	add_instantiation_interface_port reset1 reset_req reset_req 1 STD_LOGIC Input
	save_instantiation
	add_component niosv_0 ip/dla/dla_niosv_0.ip intel_niosv_m intel_niosv_m_0
	load_component niosv_0
	set_component_parameter_value enableAvalonInterface {0}
	set_component_parameter_value enableDebug {1}
	set_component_parameter_value enableDebugReset {0}
	set_component_parameter_value enableECCFull {0}
	set_component_parameter_value enableECCLite {0}
	set_component_parameter_value hartId {0}
	set_component_parameter_value interruptMode {0}
	set_component_parameter_value numGpr {32}
	set_component_parameter_value pipelineArch {1}
	set_component_parameter_value resetOffset {0}
	set_component_parameter_value resetSlave {Absolute}
	set_component_parameter_value useResetReq {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation niosv_0
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.CPU_FREQ {100000000u}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_ADDR_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.DCACHE_LINE_SIZE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.DCACHE_LINE_SIZE_LOG2 {0}
	set_instantiation_assignment_value embeddedsw.CMacro.DCACHE_SIZE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.HAS_CSR_SUPPORT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.HAS_DEBUG_STUB {}
	set_instantiation_assignment_value embeddedsw.CMacro.ICACHE_LINE_SIZE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ICACHE_LINE_SIZE_LOG2 {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ICACHE_SIZE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.INST_ADDR_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.INT_MODE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.MTIME_OFFSET {0x00020000}
	set_instantiation_assignment_value embeddedsw.CMacro.NIOSV_CORE_VARIANT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.NUM_GPR {32}
	set_instantiation_assignment_value embeddedsw.CMacro.RESET_ADDR {0x00000000}
	set_instantiation_assignment_value embeddedsw.CMacro.TICKS_PER_SEC {no_quote(NIOSV_INTERNAL_TIMER_TICKS_PER_SECOND)}
	set_instantiation_assignment_value embeddedsw.CMacro.TIMER_DEVICE_TYPE {2}
	set_instantiation_assignment_value embeddedsw.configuration.HDLSimCachesCleared {1}
	set_instantiation_assignment_value embeddedsw.configuration.cpuArchitecture {Abbotts Lake}
	set_instantiation_assignment_value embeddedsw.configuration.fpuEnabled {0}
	set_instantiation_assignment_value embeddedsw.configuration.fsqrtFdivDisabled {0}
	set_instantiation_assignment_value embeddedsw.configuration.interruptMode {0}
	set_instantiation_assignment_value embeddedsw.configuration.isTimerDevice {1}
	set_instantiation_assignment_value embeddedsw.configuration.numGpr {32}
	set_instantiation_assignment_value embeddedsw.configuration.resetOffset {0}
	set_instantiation_assignment_value embeddedsw.configuration.resetSlave {Absolute}
	set_instantiation_assignment_value embeddedsw.dts.params.altr,reset-addr {0x00000000}
	set_instantiation_assignment_value embeddedsw.dts.params.clock-frequency {100000000u}
	set_instantiation_assignment_value embeddedsw.dts.params.dcache-line-size {0}
	set_instantiation_assignment_value embeddedsw.dts.params.dcache-size {0}
	set_instantiation_assignment_value embeddedsw.dts.params.icache-line-size {0}
	set_instantiation_assignment_value embeddedsw.dts.params.icache-size {0}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset_reset reset 1 STD_LOGIC Input
	add_instantiation_interface platform_irq_rx interrupt OUTPUT
	set_instantiation_interface_parameter_value platform_irq_rx associatedAddressablePoint {}
	set_instantiation_interface_parameter_value platform_irq_rx associatedClock {clk}
	set_instantiation_interface_parameter_value platform_irq_rx associatedReset {reset}
	set_instantiation_interface_parameter_value platform_irq_rx irqMap {}
	set_instantiation_interface_parameter_value platform_irq_rx irqScheme {INDIVIDUAL_REQUESTS}
	add_instantiation_interface_port platform_irq_rx platform_irq_rx_irq irq 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface instruction_manager axi4lite OUTPUT
	set_instantiation_interface_parameter_value instruction_manager addressCheck {false}
	set_instantiation_interface_parameter_value instruction_manager associatedClock {clk}
	set_instantiation_interface_parameter_value instruction_manager associatedReset {reset}
	set_instantiation_interface_parameter_value instruction_manager combinedIssuingCapability {8}
	set_instantiation_interface_parameter_value instruction_manager dataCheck {false}
	set_instantiation_interface_parameter_value instruction_manager enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value instruction_manager isTranslator {false}
	set_instantiation_interface_parameter_value instruction_manager maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value instruction_manager maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value instruction_manager maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value instruction_manager noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value instruction_manager optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value instruction_manager poison {false}
	set_instantiation_interface_parameter_value instruction_manager readIssuingCapability {8}
	set_instantiation_interface_parameter_value instruction_manager securityAttribute {false}
	set_instantiation_interface_parameter_value instruction_manager traceSignals {false}
	set_instantiation_interface_parameter_value instruction_manager trustzoneAware {true}
	set_instantiation_interface_parameter_value instruction_manager uniqueIdSupport {false}
	set_instantiation_interface_parameter_value instruction_manager userData {false}
	set_instantiation_interface_parameter_value instruction_manager wakeupSignals {false}
	set_instantiation_interface_parameter_value instruction_manager writeIssuingCapability {1}
	add_instantiation_interface_port instruction_manager instruction_manager_awaddr awaddr 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port instruction_manager instruction_manager_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port instruction_manager instruction_manager_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port instruction_manager instruction_manager_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port instruction_manager instruction_manager_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port instruction_manager instruction_manager_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port instruction_manager instruction_manager_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port instruction_manager instruction_manager_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port instruction_manager instruction_manager_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port instruction_manager instruction_manager_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port instruction_manager instruction_manager_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port instruction_manager instruction_manager_araddr araddr 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port instruction_manager instruction_manager_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port instruction_manager instruction_manager_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port instruction_manager instruction_manager_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port instruction_manager instruction_manager_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port instruction_manager instruction_manager_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port instruction_manager instruction_manager_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port instruction_manager instruction_manager_rready rready 1 STD_LOGIC Output
	add_instantiation_interface data_manager axi4lite OUTPUT
	set_instantiation_interface_parameter_value data_manager addressCheck {false}
	set_instantiation_interface_parameter_value data_manager associatedClock {clk}
	set_instantiation_interface_parameter_value data_manager associatedReset {reset}
	set_instantiation_interface_parameter_value data_manager combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value data_manager dataCheck {false}
	set_instantiation_interface_parameter_value data_manager enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value data_manager isTranslator {false}
	set_instantiation_interface_parameter_value data_manager maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value data_manager maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value data_manager maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value data_manager noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value data_manager optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value data_manager poison {false}
	set_instantiation_interface_parameter_value data_manager readIssuingCapability {1}
	set_instantiation_interface_parameter_value data_manager securityAttribute {false}
	set_instantiation_interface_parameter_value data_manager traceSignals {false}
	set_instantiation_interface_parameter_value data_manager trustzoneAware {true}
	set_instantiation_interface_parameter_value data_manager uniqueIdSupport {false}
	set_instantiation_interface_parameter_value data_manager userData {false}
	set_instantiation_interface_parameter_value data_manager wakeupSignals {false}
	set_instantiation_interface_parameter_value data_manager writeIssuingCapability {1}
	add_instantiation_interface_port data_manager data_manager_awaddr awaddr 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port data_manager data_manager_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port data_manager data_manager_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port data_manager data_manager_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port data_manager data_manager_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port data_manager data_manager_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port data_manager data_manager_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port data_manager data_manager_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port data_manager data_manager_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port data_manager data_manager_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port data_manager data_manager_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port data_manager data_manager_araddr araddr 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port data_manager data_manager_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port data_manager data_manager_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port data_manager data_manager_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port data_manager data_manager_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port data_manager data_manager_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port data_manager data_manager_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port data_manager data_manager_rready rready 1 STD_LOGIC Output
	add_instantiation_interface timer_sw_agent avalon INPUT
	set_instantiation_interface_parameter_value timer_sw_agent addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value timer_sw_agent addressGroup {0}
	set_instantiation_interface_parameter_value timer_sw_agent addressSpan {64}
	set_instantiation_interface_parameter_value timer_sw_agent addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value timer_sw_agent alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value timer_sw_agent associatedClock {clk}
	set_instantiation_interface_parameter_value timer_sw_agent associatedReset {reset}
	set_instantiation_interface_parameter_value timer_sw_agent bitsPerSymbol {8}
	set_instantiation_interface_parameter_value timer_sw_agent bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value timer_sw_agent bridgesToMaster {}
	set_instantiation_interface_parameter_value timer_sw_agent burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value timer_sw_agent burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value timer_sw_agent constantBurstBehavior {false}
	set_instantiation_interface_parameter_value timer_sw_agent dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value timer_sw_agent dfhFeatureId {35}
	set_instantiation_interface_parameter_value timer_sw_agent dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value timer_sw_agent dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value timer_sw_agent dfhFeatureType {3}
	set_instantiation_interface_parameter_value timer_sw_agent dfhGroupId {0}
	set_instantiation_interface_parameter_value timer_sw_agent dfhParameterData {}
	set_instantiation_interface_parameter_value timer_sw_agent dfhParameterDataLength {}
	set_instantiation_interface_parameter_value timer_sw_agent dfhParameterId {}
	set_instantiation_interface_parameter_value timer_sw_agent dfhParameterName {}
	set_instantiation_interface_parameter_value timer_sw_agent dfhParameterVersion {}
	set_instantiation_interface_parameter_value timer_sw_agent explicitAddressSpan {0}
	set_instantiation_interface_parameter_value timer_sw_agent holdTime {0}
	set_instantiation_interface_parameter_value timer_sw_agent interleaveBursts {false}
	set_instantiation_interface_parameter_value timer_sw_agent isBigEndian {false}
	set_instantiation_interface_parameter_value timer_sw_agent isFlash {false}
	set_instantiation_interface_parameter_value timer_sw_agent isMemoryDevice {false}
	set_instantiation_interface_parameter_value timer_sw_agent isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value timer_sw_agent linewrapBursts {false}
	set_instantiation_interface_parameter_value timer_sw_agent maximumPendingReadTransactions {2}
	set_instantiation_interface_parameter_value timer_sw_agent maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value timer_sw_agent minimumReadLatency {1}
	set_instantiation_interface_parameter_value timer_sw_agent minimumResponseLatency {1}
	set_instantiation_interface_parameter_value timer_sw_agent minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value timer_sw_agent prSafe {false}
	set_instantiation_interface_parameter_value timer_sw_agent printableDevice {false}
	set_instantiation_interface_parameter_value timer_sw_agent readLatency {0}
	set_instantiation_interface_parameter_value timer_sw_agent readWaitStates {1}
	set_instantiation_interface_parameter_value timer_sw_agent readWaitTime {1}
	set_instantiation_interface_parameter_value timer_sw_agent registerIncomingSignals {false}
	set_instantiation_interface_parameter_value timer_sw_agent registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value timer_sw_agent setupTime {0}
	set_instantiation_interface_parameter_value timer_sw_agent timingUnits {Cycles}
	set_instantiation_interface_parameter_value timer_sw_agent transparentBridge {false}
	set_instantiation_interface_parameter_value timer_sw_agent waitrequestAllowance {0}
	set_instantiation_interface_parameter_value timer_sw_agent waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value timer_sw_agent wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value timer_sw_agent writeLatency {0}
	set_instantiation_interface_parameter_value timer_sw_agent writeWaitStates {0}
	set_instantiation_interface_parameter_value timer_sw_agent writeWaitTime {0}
	set_instantiation_interface_assignment_value timer_sw_agent embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value timer_sw_agent embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value timer_sw_agent embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value timer_sw_agent embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_assignment_value timer_sw_agent qsys.ui.connect {data_manager}
	set_instantiation_interface_sysinfo_parameter_value timer_sw_agent address_map {<address-map><slave name='timer_sw_agent' start='0x0' end='0x40' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value timer_sw_agent address_width {6}
	set_instantiation_interface_sysinfo_parameter_value timer_sw_agent max_slave_data_width {32}
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_write write 1 STD_LOGIC Input
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_address address 6 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_read read 1 STD_LOGIC Input
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port timer_sw_agent timer_sw_agent_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface dm_agent avalon INPUT
	set_instantiation_interface_parameter_value dm_agent addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value dm_agent addressGroup {0}
	set_instantiation_interface_parameter_value dm_agent addressSpan {65536}
	set_instantiation_interface_parameter_value dm_agent addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value dm_agent alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value dm_agent associatedClock {clk}
	set_instantiation_interface_parameter_value dm_agent associatedReset {reset}
	set_instantiation_interface_parameter_value dm_agent bitsPerSymbol {8}
	set_instantiation_interface_parameter_value dm_agent bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value dm_agent bridgesToMaster {}
	set_instantiation_interface_parameter_value dm_agent burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value dm_agent burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value dm_agent constantBurstBehavior {false}
	set_instantiation_interface_parameter_value dm_agent dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value dm_agent dfhFeatureId {35}
	set_instantiation_interface_parameter_value dm_agent dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value dm_agent dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value dm_agent dfhFeatureType {3}
	set_instantiation_interface_parameter_value dm_agent dfhGroupId {0}
	set_instantiation_interface_parameter_value dm_agent dfhParameterData {}
	set_instantiation_interface_parameter_value dm_agent dfhParameterDataLength {}
	set_instantiation_interface_parameter_value dm_agent dfhParameterId {}
	set_instantiation_interface_parameter_value dm_agent dfhParameterName {}
	set_instantiation_interface_parameter_value dm_agent dfhParameterVersion {}
	set_instantiation_interface_parameter_value dm_agent explicitAddressSpan {0}
	set_instantiation_interface_parameter_value dm_agent holdTime {0}
	set_instantiation_interface_parameter_value dm_agent interleaveBursts {false}
	set_instantiation_interface_parameter_value dm_agent isBigEndian {false}
	set_instantiation_interface_parameter_value dm_agent isFlash {false}
	set_instantiation_interface_parameter_value dm_agent isMemoryDevice {false}
	set_instantiation_interface_parameter_value dm_agent isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value dm_agent linewrapBursts {false}
	set_instantiation_interface_parameter_value dm_agent maximumPendingReadTransactions {2}
	set_instantiation_interface_parameter_value dm_agent maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value dm_agent minimumReadLatency {1}
	set_instantiation_interface_parameter_value dm_agent minimumResponseLatency {1}
	set_instantiation_interface_parameter_value dm_agent minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value dm_agent prSafe {false}
	set_instantiation_interface_parameter_value dm_agent printableDevice {false}
	set_instantiation_interface_parameter_value dm_agent readLatency {0}
	set_instantiation_interface_parameter_value dm_agent readWaitStates {1}
	set_instantiation_interface_parameter_value dm_agent readWaitTime {1}
	set_instantiation_interface_parameter_value dm_agent registerIncomingSignals {false}
	set_instantiation_interface_parameter_value dm_agent registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value dm_agent setupTime {0}
	set_instantiation_interface_parameter_value dm_agent timingUnits {Cycles}
	set_instantiation_interface_parameter_value dm_agent transparentBridge {false}
	set_instantiation_interface_parameter_value dm_agent waitrequestAllowance {0}
	set_instantiation_interface_parameter_value dm_agent waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value dm_agent wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value dm_agent writeLatency {0}
	set_instantiation_interface_parameter_value dm_agent writeWaitStates {0}
	set_instantiation_interface_parameter_value dm_agent writeWaitTime {0}
	set_instantiation_interface_assignment_value dm_agent embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value dm_agent embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value dm_agent embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value dm_agent embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_assignment_value dm_agent qsys.ui.connect {instruction_manager,data_manager}
	set_instantiation_interface_sysinfo_parameter_value dm_agent address_map {<address-map><slave name='dm_agent' start='0x0' end='0x10000' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value dm_agent address_width {16}
	set_instantiation_interface_sysinfo_parameter_value dm_agent max_slave_data_width {32}
	add_instantiation_interface_port dm_agent dm_agent_write write 1 STD_LOGIC Input
	add_instantiation_interface_port dm_agent dm_agent_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port dm_agent dm_agent_address address 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port dm_agent dm_agent_read read 1 STD_LOGIC Input
	add_instantiation_interface_port dm_agent dm_agent_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port dm_agent dm_agent_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port dm_agent dm_agent_waitrequest waitrequest 1 STD_LOGIC Output
	save_instantiation
	add_component niosv_ram_0 ip/dla/dla_niosv_ram_0.ip intel_onchip_memory niosv_ram_0
	load_component niosv_ram_0
	set_component_parameter_value AXI_interface {1}
	set_component_parameter_value allowInSystemMemoryContentEditor {0}
	set_component_parameter_value blockType {AUTO}
	set_component_parameter_value clockEnable {0}
	set_component_parameter_value copyInitFile {0}
	set_component_parameter_value dataWidth {32}
	set_component_parameter_value dataWidth2 {32}
	set_component_parameter_value dualPort {0}
	set_component_parameter_value ecc_check {0}
	set_component_parameter_value ecc_encoder_bypass {0}
	set_component_parameter_value ecc_pipeline_reg {0}
	set_component_parameter_value enPRInitMode {0}
	set_component_parameter_value enableDiffWidth {0}
	set_component_parameter_value gui_debugaccess {0}
	set_component_parameter_value idWidth {1}
	set_component_parameter_value initMemContent {1}
	set_component_parameter_value initializationFileName {stream_controller.hex}
	set_component_parameter_value instanceID {NONE}
	set_component_parameter_value interfaceType {0}
	set_component_parameter_value lvl1OutputRegA {0}
	set_component_parameter_value lvl1OutputRegB {0}
	set_component_parameter_value lvl2OutputRegA {0}
	set_component_parameter_value lvl2OutputRegB {0}
	set_component_parameter_value memorySize {131072.0}
	set_component_parameter_value poison_enable {0}
	set_component_parameter_value readDuringWriteMode_Mixed {DONT_CARE}
	set_component_parameter_value resetrequest_enabled {1}
	set_component_parameter_value singleClockOperation {0}
	set_component_parameter_value tightly_coupled_ecc {0}
	set_component_parameter_value useNonDefaultInitFile {1}
	set_component_parameter_value writable {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation niosv_ram_0
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CONTENTS_INFO {""}
	set_instantiation_assignment_value embeddedsw.CMacro.DUAL_PORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.GUI_RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_CONTENTS_FILE {stream_controller}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_MEM_CONTENT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.INSTANCE_ID {NONE}
	set_instantiation_assignment_value embeddedsw.CMacro.NON_DEFAULT_INIT_FILE_ENABLED {1}
	set_instantiation_assignment_value embeddedsw.CMacro.RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.READ_DURING_WRITE_MODE {DONT_CARE}
	set_instantiation_assignment_value embeddedsw.CMacro.SINGLE_CLOCK_OP {0}
	set_instantiation_assignment_value embeddedsw.CMacro.SIZE_MULTIPLE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.SIZE_VALUE {131072}
	set_instantiation_assignment_value embeddedsw.CMacro.WRITABLE {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR {SIM_DIR}
	set_instantiation_assignment_value embeddedsw.memoryInfo.GENERATE_DAT_SYM {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.GENERATE_HEX {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.HAS_BYTE_LANE {0}
	set_instantiation_assignment_value embeddedsw.memoryInfo.HEX_INSTALL_DIR {QPF_DIR}
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_FILENAME {stream_controller}
	set_instantiation_assignment_value postgeneration.simulation.init_file.param_name {INIT_FILE}
	set_instantiation_assignment_value postgeneration.simulation.init_file.type {MEM_INIT}
	add_instantiation_interface clk1 clock INPUT
	set_instantiation_interface_parameter_value clk1 clockRate {0}
	set_instantiation_interface_parameter_value clk1 externallyDriven {false}
	set_instantiation_interface_parameter_value clk1 ptfSchematicName {}
	add_instantiation_interface_port clk1 clk clk 1 STD_LOGIC Input
	add_instantiation_interface s1 avalon INPUT
	set_instantiation_interface_parameter_value s1 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s1 addressGroup {0}
	set_instantiation_interface_parameter_value s1 addressSpan {131072}
	set_instantiation_interface_parameter_value s1 addressUnits {WORDS}
	set_instantiation_interface_parameter_value s1 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s1 associatedClock {clk1}
	set_instantiation_interface_parameter_value s1 associatedReset {reset1}
	set_instantiation_interface_parameter_value s1 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s1 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s1 bridgesToMaster {}
	set_instantiation_interface_parameter_value s1 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s1 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s1 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s1 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s1 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s1 dfhGroupId {0}
	set_instantiation_interface_parameter_value s1 dfhParameterData {}
	set_instantiation_interface_parameter_value s1 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s1 dfhParameterId {}
	set_instantiation_interface_parameter_value s1 dfhParameterName {}
	set_instantiation_interface_parameter_value s1 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s1 explicitAddressSpan {131072}
	set_instantiation_interface_parameter_value s1 holdTime {0}
	set_instantiation_interface_parameter_value s1 interleaveBursts {false}
	set_instantiation_interface_parameter_value s1 isBigEndian {false}
	set_instantiation_interface_parameter_value s1 isFlash {false}
	set_instantiation_interface_parameter_value s1 isMemoryDevice {true}
	set_instantiation_interface_parameter_value s1 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s1 linewrapBursts {false}
	set_instantiation_interface_parameter_value s1 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value s1 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s1 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s1 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s1 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s1 prSafe {false}
	set_instantiation_interface_parameter_value s1 printableDevice {false}
	set_instantiation_interface_parameter_value s1 readLatency {1}
	set_instantiation_interface_parameter_value s1 readWaitStates {0}
	set_instantiation_interface_parameter_value s1 readWaitTime {0}
	set_instantiation_interface_parameter_value s1 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s1 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s1 setupTime {0}
	set_instantiation_interface_parameter_value s1 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s1 transparentBridge {false}
	set_instantiation_interface_parameter_value s1 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s1 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s1 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s1 writeLatency {0}
	set_instantiation_interface_parameter_value s1 writeWaitStates {0}
	set_instantiation_interface_parameter_value s1 writeWaitTime {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isMemoryDevice {1}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s1 address_map {<address-map><slave name='s1' start='0x0' end='0x20000' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s1 address_width {17}
	set_instantiation_interface_sysinfo_parameter_value s1 max_slave_data_width {32}
	add_instantiation_interface_port s1 address address 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 read read 1 STD_LOGIC Input
	add_instantiation_interface_port s1 readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s1 byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 write write 1 STD_LOGIC Input
	add_instantiation_interface_port s1 writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface reset1 reset INPUT
	set_instantiation_interface_parameter_value reset1 associatedClock {clk1}
	set_instantiation_interface_parameter_value reset1 synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset1 reset reset 1 STD_LOGIC Input
	add_instantiation_interface_port reset1 reset_req reset_req 1 STD_LOGIC Input
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 addressMapSysInfo {<address-map><slave name='ddr_bridge_0.s0' start='0x0' end='0x100000000' datawidth='256' /></address-map>}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 addressWidthSysInfo {32}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 baseAddress {0x0000}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 domainAlias {}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value altera_ai_ip_0.ddr_axi/ddr_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection csr_bridge_0.m0/altera_ai_ip_0.csr_axi
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi addressMapSysInfo {<address-map><slave name='mailbox_ram_0.s1' start='0x0' end='0x1000' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x4000' end='0x4800' datawidth='32' /></address-map>}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi addressWidthSysInfo {15}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi arbitrationPriority {1}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi baseAddress {0x4000}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi cpuInfoIdSysInfo {}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi defaultConnection {0}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi domainAlias {}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.fifoDepth {8}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.syncResets {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value csr_bridge_0.m0/altera_ai_ip_0.csr_axi slaveDataWidthSysInfo {-1}
	add_connection csr_bridge_0.m0/mailbox_ram_0.s1
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 addressMapSysInfo {<address-map><slave name='mailbox_ram_0.s1' start='0x0' end='0x1000' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x4000' end='0x4800' datawidth='32' /></address-map>}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 addressWidthSysInfo {15}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 arbitrationPriority {1}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 baseAddress {0x0000}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 defaultConnection {0}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 domainAlias {}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.fifoDepth {8}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value csr_bridge_0.m0/mailbox_ram_0.s1 slaveDataWidthSysInfo {-1}
	add_connection csr_clk_0.out_clk/altera_ai_ip_0.irq_clk
	set_connection_parameter_value csr_clk_0.out_clk/altera_ai_ip_0.irq_clk clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/altera_ai_ip_0.irq_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/altera_ai_ip_0.irq_clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/altera_ai_ip_0.irq_clk resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/csr_bridge_0.clk
	set_connection_parameter_value csr_clk_0.out_clk/csr_bridge_0.clk clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/csr_bridge_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/csr_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/csr_bridge_0.clk resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/csr_rst_0.clk
	set_connection_parameter_value csr_clk_0.out_clk/csr_rst_0.clk clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/csr_rst_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/csr_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/csr_rst_0.clk resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/dla_msgdma_0.clock
	set_connection_parameter_value csr_clk_0.out_clk/dla_msgdma_0.clock clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/dla_msgdma_0.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/dla_msgdma_0.clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/dla_msgdma_0.clock resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/dla_rst_0.clk
	set_connection_parameter_value csr_clk_0.out_clk/dla_rst_0.clk clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/dla_rst_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/dla_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/dla_rst_0.clk resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/jtag_uart_0.clk
	set_connection_parameter_value csr_clk_0.out_clk/jtag_uart_0.clk clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/jtag_uart_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/jtag_uart_0.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/jtag_uart_0.clk resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/mailbox_ram_0.clk1
	set_connection_parameter_value csr_clk_0.out_clk/mailbox_ram_0.clk1 clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/mailbox_ram_0.clk1 clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/mailbox_ram_0.clk1 clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/mailbox_ram_0.clk1 resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/niosv_0.clk
	set_connection_parameter_value csr_clk_0.out_clk/niosv_0.clk clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/niosv_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/niosv_0.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/niosv_0.clk resetDomainSysInfo {1}
	add_connection csr_clk_0.out_clk/niosv_ram_0.clk1
	set_connection_parameter_value csr_clk_0.out_clk/niosv_ram_0.clk1 clockDomainSysInfo {1}
	set_connection_parameter_value csr_clk_0.out_clk/niosv_ram_0.clk1 clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk_0.out_clk/niosv_ram_0.clk1 clockResetSysInfo {}
	set_connection_parameter_value csr_clk_0.out_clk/niosv_ram_0.clk1 resetDomainSysInfo {1}
	add_connection csr_rst_0.out_reset/csr_bridge_0.reset
	set_connection_parameter_value csr_rst_0.out_reset/csr_bridge_0.reset clockDomainSysInfo {2}
	set_connection_parameter_value csr_rst_0.out_reset/csr_bridge_0.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst_0.out_reset/csr_bridge_0.reset resetDomainSysInfo {2}
	add_connection csr_rst_0.out_reset/dla_msgdma_0.reset_n
	set_connection_parameter_value csr_rst_0.out_reset/dla_msgdma_0.reset_n clockDomainSysInfo {2}
	set_connection_parameter_value csr_rst_0.out_reset/dla_msgdma_0.reset_n clockResetSysInfo {}
	set_connection_parameter_value csr_rst_0.out_reset/dla_msgdma_0.reset_n resetDomainSysInfo {2}
	add_connection csr_rst_0.out_reset/jtag_uart_0.reset
	set_connection_parameter_value csr_rst_0.out_reset/jtag_uart_0.reset clockDomainSysInfo {2}
	set_connection_parameter_value csr_rst_0.out_reset/jtag_uart_0.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst_0.out_reset/jtag_uart_0.reset resetDomainSysInfo {2}
	add_connection csr_rst_0.out_reset/mailbox_ram_0.reset1
	set_connection_parameter_value csr_rst_0.out_reset/mailbox_ram_0.reset1 clockDomainSysInfo {2}
	set_connection_parameter_value csr_rst_0.out_reset/mailbox_ram_0.reset1 clockResetSysInfo {}
	set_connection_parameter_value csr_rst_0.out_reset/mailbox_ram_0.reset1 resetDomainSysInfo {2}
	add_connection csr_rst_0.out_reset/niosv_0.reset
	set_connection_parameter_value csr_rst_0.out_reset/niosv_0.reset clockDomainSysInfo {2}
	set_connection_parameter_value csr_rst_0.out_reset/niosv_0.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst_0.out_reset/niosv_0.reset resetDomainSysInfo {2}
	add_connection csr_rst_0.out_reset/niosv_ram_0.reset1
	set_connection_parameter_value csr_rst_0.out_reset/niosv_ram_0.reset1 clockDomainSysInfo {2}
	set_connection_parameter_value csr_rst_0.out_reset/niosv_ram_0.reset1 clockResetSysInfo {}
	set_connection_parameter_value csr_rst_0.out_reset/niosv_ram_0.reset1 resetDomainSysInfo {2}
	add_connection ddr_clk_0.out_clk/altera_ai_ip_0.ddr_clk
	set_connection_parameter_value ddr_clk_0.out_clk/altera_ai_ip_0.ddr_clk clockDomainSysInfo {3}
	set_connection_parameter_value ddr_clk_0.out_clk/altera_ai_ip_0.ddr_clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value ddr_clk_0.out_clk/altera_ai_ip_0.ddr_clk clockResetSysInfo {}
	set_connection_parameter_value ddr_clk_0.out_clk/altera_ai_ip_0.ddr_clk resetDomainSysInfo {3}
	add_connection ddr_clk_0.out_clk/ddr_bridge_0.clk
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_bridge_0.clk clockDomainSysInfo {3}
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_bridge_0.clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_bridge_0.clk resetDomainSysInfo {3}
	add_connection ddr_clk_0.out_clk/ddr_rst_0.clk
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_rst_0.clk clockDomainSysInfo {3}
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_rst_0.clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value ddr_clk_0.out_clk/ddr_rst_0.clk resetDomainSysInfo {3}
	add_connection ddr_rst_0.out_reset/ddr_bridge_0.reset
	set_connection_parameter_value ddr_rst_0.out_reset/ddr_bridge_0.reset clockDomainSysInfo {4}
	set_connection_parameter_value ddr_rst_0.out_reset/ddr_bridge_0.reset clockResetSysInfo {}
	set_connection_parameter_value ddr_rst_0.out_reset/ddr_bridge_0.reset resetDomainSysInfo {4}
	add_connection dla_clk_0.out_clk/altera_ai_ip_0.dla_clk
	set_connection_parameter_value dla_clk_0.out_clk/altera_ai_ip_0.dla_clk clockDomainSysInfo {5}
	set_connection_parameter_value dla_clk_0.out_clk/altera_ai_ip_0.dla_clk clockRateSysInfo {300000000.0}
	set_connection_parameter_value dla_clk_0.out_clk/altera_ai_ip_0.dla_clk clockResetSysInfo {}
	set_connection_parameter_value dla_clk_0.out_clk/altera_ai_ip_0.dla_clk resetDomainSysInfo {5}
	add_connection dla_msgdma_0.mm_write/ddr_bridge_0.s0
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 addressMapSysInfo {<address-map><slave name='ddr_bridge_0.s0' start='0x0' end='0x100000000' datawidth='256' /></address-map>}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 addressWidthSysInfo {32}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 baseAddress {0x0000}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 domainAlias {}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla_msgdma_0.mm_write/ddr_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection dla_rst_0.out_reset/altera_ai_ip_0.dla_resetn
	set_connection_parameter_value dla_rst_0.out_reset/altera_ai_ip_0.dla_resetn clockDomainSysInfo {6}
	set_connection_parameter_value dla_rst_0.out_reset/altera_ai_ip_0.dla_resetn clockResetSysInfo {}
	set_connection_parameter_value dla_rst_0.out_reset/altera_ai_ip_0.dla_resetn resetDomainSysInfo {6}
	add_connection niosv_0.data_manager/altera_ai_ip_0.csr_axi
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi baseAddress {0x00030000}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/altera_ai_ip_0.csr_axi slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/dla_msgdma_0.csr
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr baseAddress {0x00050000}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.csr slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/dla_msgdma_0.descriptor_slave
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave baseAddress {0x00050020}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/dla_msgdma_0.descriptor_slave slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave baseAddress {0x00080000}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/jtag_uart_0.avalon_jtag_slave slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/mailbox_ram_0.s1
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 baseAddress {0x00040000}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/mailbox_ram_0.s1 slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/niosv_0.dm_agent
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent baseAddress {0x00070000}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.dm_agent slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/niosv_0.timer_sw_agent
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent baseAddress {0x00020000}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/niosv_0.timer_sw_agent slaveDataWidthSysInfo {-1}
	add_connection niosv_0.data_manager/niosv_ram_0.s1
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.timer_sw_agent' start='0x20000' end='0x20040' datawidth='32' /><slave name='altera_ai_ip_0.csr_axi' start='0x30000' end='0x30800' datawidth='32' /><slave name='mailbox_ram_0.s1' start='0x40000' end='0x41000' datawidth='32' /><slave name='dla_msgdma_0.csr' start='0x50000' end='0x50020' datawidth='32' /><slave name='dla_msgdma_0.descriptor_slave' start='0x50020' end='0x50040' datawidth='256' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /><slave name='jtag_uart_0.avalon_jtag_slave' start='0x80000' end='0x80008' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 addressWidthSysInfo {20}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 arbitrationPriority {1}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 baseAddress {0x0000}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 defaultConnection {0}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 domainAlias {}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.data_manager/niosv_ram_0.s1 slaveDataWidthSysInfo {-1}
	add_connection niosv_0.instruction_manager/niosv_0.dm_agent
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent addressWidthSysInfo {19}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent arbitrationPriority {1}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent baseAddress {0x00070000}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent defaultConnection {0}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent domainAlias {}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_0.dm_agent slaveDataWidthSysInfo {-1}
	add_connection niosv_0.instruction_manager/niosv_ram_0.s1
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 addressMapSysInfo {<address-map><slave name='niosv_ram_0.s1' start='0x0' end='0x20000' datawidth='32' /><slave name='niosv_0.dm_agent' start='0x70000' end='0x80000' datawidth='32' /></address-map>}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 addressWidthSysInfo {19}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 arbitrationPriority {1}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 baseAddress {0x0000}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 defaultConnection {0}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 domainAlias {}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.fifoDepth {8}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value niosv_0.instruction_manager/niosv_ram_0.s1 slaveDataWidthSysInfo {-1}
	add_connection niosv_0.platform_irq_rx/dla_msgdma_0.csr_irq
	set_connection_parameter_value niosv_0.platform_irq_rx/dla_msgdma_0.csr_irq interruptsUsedSysInfo {3}
	set_connection_parameter_value niosv_0.platform_irq_rx/dla_msgdma_0.csr_irq irqNumber {0}
	add_connection niosv_0.platform_irq_rx/jtag_uart_0.irq
	set_connection_parameter_value niosv_0.platform_irq_rx/jtag_uart_0.irq interruptsUsedSysInfo {3}
	set_connection_parameter_value niosv_0.platform_irq_rx/jtag_uart_0.irq irqNumber {1}

	# add the exports
	set_interface_property dla_irq EXPORT_OF altera_ai_ip_0.irq_level
	set_interface_property csr_bridge EXPORT_OF csr_bridge_0.s0
	set_interface_property csr_clk EXPORT_OF csr_clk_0.in_clk
	set_interface_property csr_rst EXPORT_OF csr_rst_0.in_reset
	set_interface_property dla_to_ddr EXPORT_OF ddr_bridge_0.m0
	set_interface_property ddr_clk EXPORT_OF ddr_clk_0.in_clk
	set_interface_property ddr_rst EXPORT_OF ddr_rst_0.in_reset
	set_interface_property dla_clk EXPORT_OF dla_clk_0.in_clk
	set_interface_property streaming_in EXPORT_OF dla_msgdma_0.st_sink
	set_interface_property dla_resetn EXPORT_OF dla_rst_0.in_reset

	# set values for exposed HDL parameters
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.enableAllPipelines FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.enableEccProtection FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.enableInstrumentation FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.fifoDepth 8
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.interconnectType STANDARD
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.maxAdditionalLatency 3
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.syncResets FALSE
	set_domain_assignment altera_ai_ip_0.ddr_axi qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment csr_bridge_0.m0 qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment csr_bridge_0.m0 qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.enableAllPipelines FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.enableEccProtection FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.enableInstrumentation FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.fifoDepth 8
	set_domain_assignment csr_bridge_0.m0 qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment csr_bridge_0.m0 qsys_mm.interconnectType STANDARD
	set_domain_assignment csr_bridge_0.m0 qsys_mm.maxAdditionalLatency 1
	set_domain_assignment csr_bridge_0.m0 qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment csr_bridge_0.m0 qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.syncResets FALSE
	set_domain_assignment csr_bridge_0.m0 qsys_mm.widthAdapterImplementation GENERIC_CONVERTER

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="altera_ai_ip_0">
  <datum __value="_sortIndex" value="4" type="int" />
 </element>
 <element __value="altera_ai_ip_0.csr_axi">
  <datum __value="_lockedAddress" value="0" type="boolean" />
  <datum __value="baseAddress" value="16384" type="String" />
 </element>
 <element __value="csr_bridge_0">
  <datum __value="_sortIndex" value="6" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="csr_clk_0">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="csr_rst_0">
  <datum __value="_sortIndex" value="1" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="ddr_bridge_0">
  <datum __value="_sortIndex" value="7" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="ddr_bridge_0.s0">
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="ddr_clk_0">
  <datum __value="_sortIndex" value="2" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="ddr_rst_0">
  <datum __value="_sortIndex" value="3" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="dla_clk_0">
  <datum __value="_sortIndex" value="13" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="dla_msgdma_0">
  <datum __value="_sortIndex" value="11" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="dla_msgdma_0.csr">
  <datum __value="baseAddress" value="131136" type="String" />
 </element>
 <element __value="dla_msgdma_0.descriptor_slave">
  <datum __value="baseAddress" value="131184" type="String" />
 </element>
 <element __value="dla_rst_0">
  <datum __value="_sortIndex" value="5" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="jtag_uart_0">
  <datum __value="_sortIndex" value="12" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="jtag_uart_0.avalon_jtag_slave">
  <datum __value="_lockedAddress" value="0" type="boolean" />
  <datum __value="baseAddress" value="524288" type="String" />
 </element>
 <element __value="mailbox_ram_0">
  <datum __value="_sortIndex" value="10" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="mailbox_ram_0.s1">
  <datum __value="_lockedAddress" value="0" type="boolean" />
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="niosv_0">
  <datum __value="_sortIndex" value="8" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="niosv_0.dm_agent">
  <datum __value="_lockedAddress" value="0" type="boolean" />
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="niosv_0.timer_sw_agent">
  <datum __value="_lockedAddress" value="0" type="boolean" />
  <datum __value="baseAddress" value="18432" type="String" />
 </element>
 <element __value="niosv_ram_0">
  <datum __value="_sortIndex" value="9" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="niosv_ram_0.s1">
  <datum __value="_lockedAddress" value="0" type="boolean" />
  <datum __value="baseAddress" value="65536" type="String" />
 </element>
</bonusData>
}
	set_module_property FILE {dla.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {dla}

	# save the system
	sync_sysinfo_parameters
	save_system dla
}

# create the system "emif"
proc do_create_emif {} {
	# create the system
	create_system emif
	set_project_property BOARD {Agilex 5 FPGA E-Series 065B Modular Development Kit MK-A5E065BB32AES1}
	set_project_property DEVICE {A5ED065BB32AE6SR0}
	set_project_property DEVICE_FAMILY {Agilex 5}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component axil_driver ../ip/ed_synth_axil_driver_0.ip emif_ph2_axil_driver axil_driver
	load_component axil_driver
	set_component_parameter_value AXIL_DRIVER_ADDRESS_WIDTH {27}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation axil_driver
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface axil_driver_clk clock INPUT
	set_instantiation_interface_parameter_value axil_driver_clk clockRate {0}
	set_instantiation_interface_parameter_value axil_driver_clk externallyDriven {false}
	set_instantiation_interface_parameter_value axil_driver_clk ptfSchematicName {}
	add_instantiation_interface_port axil_driver_clk axil_driver_clk clk 1 STD_LOGIC Input
	add_instantiation_interface axil_driver_rst_n reset INPUT
	set_instantiation_interface_parameter_value axil_driver_rst_n associatedClock {axil_driver_clk}
	set_instantiation_interface_parameter_value axil_driver_rst_n synchronousEdges {DEASSERT}
	add_instantiation_interface_port axil_driver_rst_n axil_driver_rst_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface axil_driver_axi4_lite axi4lite OUTPUT
	set_instantiation_interface_parameter_value axil_driver_axi4_lite addressCheck {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite associatedClock {axil_driver_clk}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite associatedReset {axil_driver_rst_n}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite dataCheck {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite isTranslator {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite poison {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite readIssuingCapability {1}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite securityAttribute {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite traceSignals {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite trustzoneAware {true}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite uniqueIdSupport {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite userData {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite wakeupSignals {false}
	set_instantiation_interface_parameter_value axil_driver_axi4_lite writeIssuingCapability {1}
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_awaddr awaddr 27 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_araddr araddr 27 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_rready rready 1 STD_LOGIC Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axil_driver_axi4_lite axil_driver_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface cal_done_rst_n reset OUTPUT
	set_instantiation_interface_parameter_value cal_done_rst_n associatedClock {axil_driver_clk}
	set_instantiation_interface_parameter_value cal_done_rst_n associatedDirectReset {}
	set_instantiation_interface_parameter_value cal_done_rst_n associatedResetSinks {none}
	set_instantiation_interface_parameter_value cal_done_rst_n synchronousEdges {DEASSERT}
	add_instantiation_interface_port cal_done_rst_n cal_done_rst_n reset_n 1 STD_LOGIC Output
	save_instantiation
	add_component emif ip/emif/emif_emif_io96b_ddr4comp_0.ip emif_io96b_ddr4comp emif
	load_component emif
	set_component_parameter_value ADV_CAL_ENABLE_MARGIN {0}
	set_component_parameter_value ADV_CAL_ENABLE_REQ {1}
	set_component_parameter_value ADV_CAL_ENABLE_WEQ {1}
	set_component_parameter_value ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_parameter_value CTRL_ALL_STRB_EN {0}
	set_component_parameter_value CTRL_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_BG_ROTATE_EN {1}
	set_component_parameter_value CTRL_DM_EN {1}
	set_component_parameter_value CTRL_ECC_AUTOCORRECT_EN {0}
	set_component_parameter_value CTRL_FIXED_PRIORITY_EN {0}
	set_component_parameter_value CTRL_FIXED_R_PRIORITY {0}
	set_component_parameter_value CTRL_FIXED_W_PRIORITY {0}
	set_component_parameter_value CTRL_PERFORMANCE_PROFILE {SEQ}
	set_component_parameter_value CTRL_PLACEMENT_EN {1}
	set_component_parameter_value CTRL_RD_DBI_EN {0}
	set_component_parameter_value CTRL_SCRAMBLER_EN {0}
	set_component_parameter_value CTRL_WR_DBI_EN {0}
	set_component_parameter_value DEBUG_PRINT_LEVEL {0}
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
	set_component_parameter_value EX_DESIGN_TG_WIDE_IF {0}
	set_component_parameter_value EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ {110.0}
	set_component_parameter_value EX_DESIGN_USER_PLL_OUTPUT_FREQ_MHZ_AUTOSET_EN {1}
	set_component_parameter_value EX_DESIGN_USER_PLL_REFCLK_FREQ_MHZ {100.0}
	set_component_parameter_value HPS_EMIF_RZQ_SHARING {0}
	set_component_parameter_value INSTANCE_ID {0}
	set_component_parameter_value IS_HPS {0}
	set_component_parameter_value JEDEC_OVERRIDE_TABLE_PARAM_NAME {MEM_CL_CYC MEM_CWL_CYC MEM_TRFC_NS}
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
	set_component_parameter_value MEM_OPERATING_FREQ_MHZ {800}
	set_component_parameter_value MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_parameter_value MEM_PAGE_SIZE {1024.0}
	set_component_parameter_value MEM_RANKS_SHARE_CK_EN {0}
	set_component_parameter_value MEM_RD_PREAMBLE_MODE {1.0}
	set_component_parameter_value MEM_SPEEDBIN {3200AA}
	set_component_parameter_value MEM_TCCD_DLR_NS {0.0}
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
	set_component_parameter_value MEM_TFAW_DLR_NS {0.0}
	set_component_parameter_value MEM_TFAW_NS {25.0}
	set_component_parameter_value MEM_TMOD_NS {30.0}
	set_component_parameter_value MEM_TMPRR_NS {1.25}
	set_component_parameter_value MEM_TMRD_NS {10.0}
	set_component_parameter_value MEM_TRAS_MAX_NS {70200.0}
	set_component_parameter_value MEM_TRAS_MIN_NS {32.0}
	set_component_parameter_value MEM_TRAS_NS {32.0}
	set_component_parameter_value MEM_TRCD_NS {13.75}
	set_component_parameter_value MEM_TRC_NS {45.75}
	set_component_parameter_value MEM_TREFI_NS {7800.0}
	set_component_parameter_value MEM_TRFC_DLR_NS {0.0}
	set_component_parameter_value MEM_TRFC_NS {350.0}
	set_component_parameter_value MEM_TRP_NS {13.75}
	set_component_parameter_value MEM_TRRD_DLR_NS {0.0}
	set_component_parameter_value MEM_TRRD_L_NS {5.0}
	set_component_parameter_value MEM_TRRD_S_NS {5.0}
	set_component_parameter_value MEM_TRTP_NS {7.5}
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
	set_component_parameter_value PHY_AC_TX_EQUALIZATION {OFF}
	set_component_parameter_value PHY_ALERT_N_PLACEMENT {AC2}
	set_component_parameter_value PHY_CK_TX_EQUALIZATION {OFF}
	set_component_parameter_value PHY_CS_TX_EQUALIZATION {OFF}
	set_component_parameter_value PHY_DQ_TX_EQUALIZATION {OFF}
	set_component_parameter_value PHY_FORCE_MIN_4_AC_LANES_EN {0}
	set_component_parameter_value PHY_MAINBAND_ACCESS_MODE {ASYNC}
	set_component_parameter_value PHY_MAINBAND_ACCESS_MODE_AUTOSET_EN {0}
	set_component_parameter_value PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_parameter_value PHY_REFCLK_FREQ_MHZ {150.0}
	set_component_parameter_value PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {0}
	set_component_parameter_value PHY_SIDEBAND_ACCESS_MODE {FABRIC}
	set_component_parameter_value PHY_SIDEBAND_ACCESS_MODE_AUTOSET_EN {1}
	set_component_parameter_value PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=1,X,X,X,0,2,3,X; PIN_SWIZZLE_CH0_DQS0=7,5,1,3,4,2,0,6; PIN_SWIZZLE_CH0_DQS1=9,15,13,11,14,12,8,10; PIN_SWIZZLE_CH0_DQS2=19,23,21,17,16,18,20,22; PIN_SWIZZLE_CH0_DQS3=31,29,27,25,26,30,24,28; }
	set_component_parameter_value PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {SSTL}
	set_component_parameter_value PHY_TERM_X_AC_SLEW_RATE {FASTEST}
	set_component_parameter_value PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_SSTL}
	set_component_parameter_value PHY_TERM_X_CK_SLEW_RATE {FASTEST}
	set_component_parameter_value PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {SSTL}
	set_component_parameter_value PHY_TERM_X_CS_SLEW_RATE {FASTEST}
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
	set_component_parameter_value TURNAROUND_R2R_SAMECS_CYC {0}
	set_component_parameter_value TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_parameter_value TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_parameter_value TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_parameter_value TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_parameter_value TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_parameter_value TURNAROUND_W2W_SAMECS_CYC {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation emif
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface s0_axi4_clock_in clock INPUT
	set_instantiation_interface_parameter_value s0_axi4_clock_in clockRate {0}
	set_instantiation_interface_parameter_value s0_axi4_clock_in externallyDriven {false}
	set_instantiation_interface_parameter_value s0_axi4_clock_in ptfSchematicName {}
	add_instantiation_interface_port s0_axi4_clock_in s0_axi4_clock_in clk 1 STD_LOGIC Input
	add_instantiation_interface s0_axi4_ctrl_ready reset OUTPUT
	set_instantiation_interface_parameter_value s0_axi4_ctrl_ready associatedClock {}
	set_instantiation_interface_parameter_value s0_axi4_ctrl_ready associatedDirectReset {}
	set_instantiation_interface_parameter_value s0_axi4_ctrl_ready associatedResetSinks {none}
	set_instantiation_interface_parameter_value s0_axi4_ctrl_ready synchronousEdges {NONE}
	add_instantiation_interface_port s0_axi4_ctrl_ready s0_axi4_reset_n reset_n 1 STD_LOGIC Output
	add_instantiation_interface core_init_n reset INPUT
	set_instantiation_interface_parameter_value core_init_n associatedClock {}
	set_instantiation_interface_parameter_value core_init_n synchronousEdges {NONE}
	add_instantiation_interface_port core_init_n core_init_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface s0_axi4 axi4 INPUT
	set_instantiation_interface_parameter_value s0_axi4 addressCheck {false}
	set_instantiation_interface_parameter_value s0_axi4 associatedClock {s0_axi4_clock_in}
	set_instantiation_interface_parameter_value s0_axi4 associatedReset {s0_axi4_ctrl_ready}
	set_instantiation_interface_parameter_value s0_axi4 bridgesToMaster {}
	set_instantiation_interface_parameter_value s0_axi4 combinedAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s0_axi4 dataCheck {false}
	set_instantiation_interface_parameter_value s0_axi4 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0_axi4 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0_axi4 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0_axi4 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0_axi4 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0_axi4 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0_axi4 dfhParameterData {}
	set_instantiation_interface_parameter_value s0_axi4 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0_axi4 dfhParameterId {}
	set_instantiation_interface_parameter_value s0_axi4 dfhParameterName {}
	set_instantiation_interface_parameter_value s0_axi4 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0_axi4 isTranslator {false}
	set_instantiation_interface_parameter_value s0_axi4 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value s0_axi4 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value s0_axi4 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value s0_axi4 noNarrowTransfer {false}
	set_instantiation_interface_parameter_value s0_axi4 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0_axi4 poison {false}
	set_instantiation_interface_parameter_value s0_axi4 readAcceptanceCapability {64}
	set_instantiation_interface_parameter_value s0_axi4 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0_axi4 securityAttribute {false}
	set_instantiation_interface_parameter_value s0_axi4 traceSignals {false}
	set_instantiation_interface_parameter_value s0_axi4 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0_axi4 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0_axi4 userData {false}
	set_instantiation_interface_parameter_value s0_axi4 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0_axi4 writeAcceptanceCapability {64}
	set_instantiation_interface_assignment_value s0_axi4 mem_capacity_gbits {64}
	set_instantiation_interface_sysinfo_parameter_value s0_axi4 address_map {<address-map><slave name='s0_axi4' start='0x0' end='0x200000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s0_axi4 address_width {33}
	set_instantiation_interface_sysinfo_parameter_value s0_axi4 max_slave_data_width {256}
	add_instantiation_interface_port s0_axi4 s0_axi4_awaddr awaddr 33 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awid awid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awlock awlock 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awqos awqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awuser awuser 14 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4 s0_axi4_araddr araddr 33 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arid arid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arlock arlock 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arqos arqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_aruser aruser 14 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4 s0_axi4_wdata wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_wstrb wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4 s0_axi4_wlast wlast 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4 s0_axi4_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_bid bid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4 s0_axi4_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4 s0_axi4_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4 s0_axi4_rready rready 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4 s0_axi4_rdata rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4 s0_axi4_rid rid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4 s0_axi4_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4 s0_axi4_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4 s0_axi4_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface s0_axi4lite_clock clock INPUT
	set_instantiation_interface_parameter_value s0_axi4lite_clock clockRate {0}
	set_instantiation_interface_parameter_value s0_axi4lite_clock externallyDriven {false}
	set_instantiation_interface_parameter_value s0_axi4lite_clock ptfSchematicName {}
	add_instantiation_interface_port s0_axi4lite_clock s0_axi4lite_clock clk 1 STD_LOGIC Input
	add_instantiation_interface s0_axi4lite_reset_n reset INPUT
	set_instantiation_interface_parameter_value s0_axi4lite_reset_n associatedClock {s0_axi4lite_clock}
	set_instantiation_interface_parameter_value s0_axi4lite_reset_n synchronousEdges {DEASSERT}
	add_instantiation_interface_port s0_axi4lite_reset_n s0_axi4lite_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface s0_axi4lite axi4lite INPUT
	set_instantiation_interface_parameter_value s0_axi4lite addressCheck {false}
	set_instantiation_interface_parameter_value s0_axi4lite associatedClock {s0_axi4lite_clock}
	set_instantiation_interface_parameter_value s0_axi4lite associatedReset {s0_axi4lite_reset_n}
	set_instantiation_interface_parameter_value s0_axi4lite bridgesToMaster {}
	set_instantiation_interface_parameter_value s0_axi4lite combinedAcceptanceCapability {1}
	set_instantiation_interface_parameter_value s0_axi4lite dataCheck {false}
	set_instantiation_interface_parameter_value s0_axi4lite dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0_axi4lite dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0_axi4lite dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0_axi4lite dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0_axi4lite dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0_axi4lite dfhGroupId {0}
	set_instantiation_interface_parameter_value s0_axi4lite dfhParameterData {}
	set_instantiation_interface_parameter_value s0_axi4lite dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0_axi4lite dfhParameterId {}
	set_instantiation_interface_parameter_value s0_axi4lite dfhParameterName {}
	set_instantiation_interface_parameter_value s0_axi4lite dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0_axi4lite isTranslator {false}
	set_instantiation_interface_parameter_value s0_axi4lite maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value s0_axi4lite maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value s0_axi4lite maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value s0_axi4lite optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0_axi4lite poison {false}
	set_instantiation_interface_parameter_value s0_axi4lite readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value s0_axi4lite readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0_axi4lite securityAttribute {false}
	set_instantiation_interface_parameter_value s0_axi4lite traceSignals {false}
	set_instantiation_interface_parameter_value s0_axi4lite trustzoneAware {true}
	set_instantiation_interface_parameter_value s0_axi4lite uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0_axi4lite userData {false}
	set_instantiation_interface_parameter_value s0_axi4lite wakeupSignals {false}
	set_instantiation_interface_parameter_value s0_axi4lite writeAcceptanceCapability {1}
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_awaddr awaddr 27 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_araddr araddr 27 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_wdata wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_wstrb wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_rready rready 1 STD_LOGIC Input
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_rdata rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0_axi4lite s0_axi4lite_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface mem_0 conduit INPUT
	set_instantiation_interface_parameter_value mem_0 associatedClock {}
	set_instantiation_interface_parameter_value mem_0 associatedReset {}
	set_instantiation_interface_parameter_value mem_0 prSafe {false}
	add_instantiation_interface_port mem_0 mem_0_cke mem_cke 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_odt mem_odt 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_cs_n mem_cs_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_a mem_a 17 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_ba mem_ba 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_bg mem_bg 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_act_n mem_act_n 1 STD_LOGIC Output
	add_instantiation_interface_port mem_0 mem_0_par mem_par 1 STD_LOGIC Output
	add_instantiation_interface_port mem_0 mem_0_dq mem_dq 32 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_0 mem_0_dqs_t mem_dqs_t 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_0 mem_0_dqs_c mem_dqs_c 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_0 mem_0_alert_n mem_alert_n 1 STD_LOGIC Input
	add_instantiation_interface_port mem_0 mem_0_dbi_n mem_dbi_n 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface mem_ck_0 conduit INPUT
	set_instantiation_interface_parameter_value mem_ck_0 associatedClock {}
	set_instantiation_interface_parameter_value mem_ck_0 associatedReset {}
	set_instantiation_interface_parameter_value mem_ck_0 prSafe {false}
	add_instantiation_interface_port mem_ck_0 mem_0_ck_t mem_ck_t 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_ck_0 mem_0_ck_c mem_ck_c 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface mem_reset_n conduit INPUT
	set_instantiation_interface_parameter_value mem_reset_n associatedClock {}
	set_instantiation_interface_parameter_value mem_reset_n associatedReset {}
	set_instantiation_interface_parameter_value mem_reset_n prSafe {false}
	add_instantiation_interface_port mem_reset_n mem_0_reset_n mem_reset_n 1 STD_LOGIC Output
	add_instantiation_interface oct_0 conduit INPUT
	set_instantiation_interface_parameter_value oct_0 associatedClock {}
	set_instantiation_interface_parameter_value oct_0 associatedReset {}
	set_instantiation_interface_parameter_value oct_0 prSafe {false}
	add_instantiation_interface_port oct_0 oct_rzqin_0 oct_rzqin 1 STD_LOGIC Input
	add_instantiation_interface ref_clk clock INPUT
	set_instantiation_interface_parameter_value ref_clk clockRate {0}
	set_instantiation_interface_parameter_value ref_clk externallyDriven {false}
	set_instantiation_interface_parameter_value ref_clk ptfSchematicName {}
	add_instantiation_interface_port ref_clk ref_clk clk 1 STD_LOGIC Input
	save_instantiation
	add_component reset_handler ../ip/ed_synth_reset_handler.ip mem_reset_handler reset_handler
	load_component reset_handler
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
	set_component_parameter_value CONDUIT_TYPE_1 {}
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
	set_component_parameter_value NUM_CONDUITS {1}
	set_component_parameter_value NUM_RESETS {1}
	set_component_parameter_value SYNC_TO_CLK {1}
	set_component_parameter_value USE_AND_GATE {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation reset_handler
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface reset_n_0 reset INPUT
	set_instantiation_interface_parameter_value reset_n_0 associatedClock {}
	set_instantiation_interface_parameter_value reset_n_0 synchronousEdges {NONE}
	add_instantiation_interface_port reset_n_0 reset_n_0 reset_n 1 STD_LOGIC Input
	add_instantiation_interface conduit_0 conduit INPUT
	set_instantiation_interface_parameter_value conduit_0 associatedClock {}
	set_instantiation_interface_parameter_value conduit_0 associatedReset {}
	set_instantiation_interface_parameter_value conduit_0 prSafe {false}
	add_instantiation_interface_port conduit_0 conduit_0 export 1 STD_LOGIC Input
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset_n_out reset OUTPUT
	set_instantiation_interface_parameter_value reset_n_out associatedClock {clk}
	set_instantiation_interface_parameter_value reset_n_out associatedDirectReset {}
	set_instantiation_interface_parameter_value reset_n_out associatedResetSinks {reset_n_0}
	set_instantiation_interface_parameter_value reset_n_out synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset_n_out reset_out_n reset_n 1 STD_LOGIC Output
	save_instantiation
	add_component rrip ip/emif/emif_s10_user_rst_clkgate_0.ip altera_s10_user_rst_clkgate rrip
	load_component rrip
	set_component_parameter_value outputType {Reset Interface}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rrip
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface ninit_done reset OUTPUT
	set_instantiation_interface_parameter_value ninit_done associatedClock {}
	set_instantiation_interface_parameter_value ninit_done associatedDirectReset {}
	set_instantiation_interface_parameter_value ninit_done associatedResetSinks {none}
	set_instantiation_interface_parameter_value ninit_done synchronousEdges {NONE}
	add_instantiation_interface_port ninit_done ninit_done reset 1 STD_LOGIC Output
	save_instantiation
	add_component user_pll ip/emif/emif_iopll_0.ip altera_iopll user_pll
	load_component user_pll
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
	set_component_parameter_value gui_cascade_outclk_index {5}
	set_component_parameter_value gui_clk_bad {0}
	set_component_parameter_value gui_clock_name_global {0}
	set_component_parameter_value gui_clock_name_instantiation {0}
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
	set_component_parameter_value gui_divide_factor_c0 {6}
	set_component_parameter_value gui_divide_factor_c1 {6}
	set_component_parameter_value gui_divide_factor_c10 {6}
	set_component_parameter_value gui_divide_factor_c11 {6}
	set_component_parameter_value gui_divide_factor_c12 {6}
	set_component_parameter_value gui_divide_factor_c13 {6}
	set_component_parameter_value gui_divide_factor_c14 {6}
	set_component_parameter_value gui_divide_factor_c15 {6}
	set_component_parameter_value gui_divide_factor_c16 {6}
	set_component_parameter_value gui_divide_factor_c17 {6}
	set_component_parameter_value gui_divide_factor_c2 {6}
	set_component_parameter_value gui_divide_factor_c3 {6}
	set_component_parameter_value gui_divide_factor_c4 {6}
	set_component_parameter_value gui_divide_factor_c5 {6}
	set_component_parameter_value gui_divide_factor_c6 {6}
	set_component_parameter_value gui_divide_factor_c7 {6}
	set_component_parameter_value gui_divide_factor_c8 {6}
	set_component_parameter_value gui_divide_factor_c9 {6}
	set_component_parameter_value gui_divide_factor_n {1}
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
	set_component_parameter_value gui_en_hvio_reconf {0}
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
	set_component_parameter_value gui_existing_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_extclkout_0_source {C0}
	set_component_parameter_value gui_extclkout_1_source {C0}
	set_component_parameter_value gui_extclkout_source {C0}
	set_component_parameter_value gui_feedback_clock {Global Clock}
	set_component_parameter_value gui_fix_vco_frequency {0}
	set_component_parameter_value gui_fixed_vco_frequency {600.0}
	set_component_parameter_value gui_fixed_vco_frequency_ps {1667.0}
	set_component_parameter_value gui_frac_multiply_factor {1.0}
	set_component_parameter_value gui_fractional_cout {32}
	set_component_parameter_value gui_include_iossm {0}
	set_component_parameter_value gui_location_type {I/O Bank}
	set_component_parameter_value gui_lock_setting {Low Lock Time}
	set_component_parameter_value gui_mif_config_name {unnamed}
	set_component_parameter_value gui_mif_gen_options {Generate New MIF File}
	set_component_parameter_value gui_multiply_factor {6}
	set_component_parameter_value gui_multiply_fraction {0}
	set_component_parameter_value gui_new_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_number_of_clocks {1}
	set_component_parameter_value gui_operation_mode {direct}
	set_component_parameter_value gui_output_clock_frequency0 {150.0}
	set_component_parameter_value gui_output_clock_frequency1 {110.0}
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
	set_component_parameter_value gui_output_clock_frequency_ps0 {6666.667}
	set_component_parameter_value gui_output_clock_frequency_ps1 {9090.909}
	set_component_parameter_value gui_output_clock_frequency_ps10 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps11 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps12 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps13 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps14 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps15 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps16 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps17 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps2 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps3 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps4 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps5 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps6 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps7 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps8 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps9 {10000.0}
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
	set_component_parameter_value gui_pll_bandwidth_preset {Low}
	set_component_parameter_value gui_pll_cal_done {0}
	set_component_parameter_value gui_pll_cascading_mode {adjpllin}
	set_component_parameter_value gui_pll_freqcal_en {1}
	set_component_parameter_value gui_pll_freqcal_req_flag {1}
	set_component_parameter_value gui_pll_m_cnt_in_src {c_m_cnt_in_src_ph_mux_clk}
	set_component_parameter_value gui_pll_mode {Integer-N PLL}
	set_component_parameter_value gui_pll_tclk_mux_en {0}
	set_component_parameter_value gui_pll_tclk_sel {pll_tclk_m_src}
	set_component_parameter_value gui_pll_type {S10_Physical}
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
	set_component_parameter_value gui_refclk1_frequency {100.0}
	set_component_parameter_value gui_refclk_might_change {0}
	set_component_parameter_value gui_refclk_switch {0}
	set_component_parameter_value gui_reference_clock_frequency {100.0}
	set_component_parameter_value gui_reference_clock_frequency_ps {10000.0}
	set_component_parameter_value gui_set_locked_as_reset {0}
	set_component_parameter_value gui_simulation_type {1}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {0}
	set_component_parameter_value gui_use_fractional_division {0}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_use_slvs_refclk {0}
	set_component_parameter_value gui_use_slvs_refclk1 {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {600.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation user_pll
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,pll}
	set_instantiation_assignment_value embeddedsw.dts.group {clock}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface refclk clock INPUT
	set_instantiation_interface_parameter_value refclk clockRate {100000000}
	set_instantiation_interface_parameter_value refclk externallyDriven {false}
	set_instantiation_interface_parameter_value refclk ptfSchematicName {}
	set_instantiation_interface_assignment_value refclk ui.blockdiagram.direction {input}
	add_instantiation_interface_port refclk refclk clk 1 STD_LOGIC Input
	add_instantiation_interface locked conduit INPUT
	set_instantiation_interface_parameter_value locked associatedClock {}
	set_instantiation_interface_parameter_value locked associatedReset {}
	set_instantiation_interface_parameter_value locked prSafe {false}
	set_instantiation_interface_assignment_value locked ui.blockdiagram.direction {output}
	add_instantiation_interface_port locked locked export 1 STD_LOGIC Output
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {}
	set_instantiation_interface_parameter_value reset synchronousEdges {NONE}
	set_instantiation_interface_assignment_value reset ui.blockdiagram.direction {input}
	add_instantiation_interface_port reset rst reset 1 STD_LOGIC Input
	add_instantiation_interface outclk0 clock OUTPUT
	set_instantiation_interface_parameter_value outclk0 associatedDirectClock {}
	set_instantiation_interface_parameter_value outclk0 clockRate {150000000}
	set_instantiation_interface_parameter_value outclk0 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk0 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk0 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk0 clock_rate {150000000}
	add_instantiation_interface_port outclk0 outclk_0 clk 1 STD_LOGIC Output
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite addressMapSysInfo {}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite addressWidthSysInfo {}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite arbitrationPriority {1}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite baseAddress {0x0000}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite cpuInfoIdSysInfo {}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite defaultConnection {0}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite domainAlias {}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.fifoDepth {8}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.syncResets {TRUE}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value axil_driver.axil_driver_axi4_lite/emif.s0_axi4lite slaveDataWidthSysInfo {-1}
	add_connection reset_handler.conduit_0/user_pll.locked
	set_connection_parameter_value reset_handler.conduit_0/user_pll.locked endPort {}
	set_connection_parameter_value reset_handler.conduit_0/user_pll.locked endPortLSB {0}
	set_connection_parameter_value reset_handler.conduit_0/user_pll.locked startPort {}
	set_connection_parameter_value reset_handler.conduit_0/user_pll.locked startPortLSB {0}
	set_connection_parameter_value reset_handler.conduit_0/user_pll.locked width {0}
	add_connection reset_handler.reset_n_out/axil_driver.axil_driver_rst_n
	set_connection_parameter_value reset_handler.reset_n_out/axil_driver.axil_driver_rst_n clockDomainSysInfo {-1}
	set_connection_parameter_value reset_handler.reset_n_out/axil_driver.axil_driver_rst_n clockResetSysInfo {}
	set_connection_parameter_value reset_handler.reset_n_out/axil_driver.axil_driver_rst_n resetDomainSysInfo {-1}
	add_connection reset_handler.reset_n_out/emif.s0_axi4lite_reset_n
	set_connection_parameter_value reset_handler.reset_n_out/emif.s0_axi4lite_reset_n clockDomainSysInfo {-1}
	set_connection_parameter_value reset_handler.reset_n_out/emif.s0_axi4lite_reset_n clockResetSysInfo {}
	set_connection_parameter_value reset_handler.reset_n_out/emif.s0_axi4lite_reset_n resetDomainSysInfo {-1}
	add_connection rrip.ninit_done/emif.core_init_n
	set_connection_parameter_value rrip.ninit_done/emif.core_init_n clockDomainSysInfo {-1}
	set_connection_parameter_value rrip.ninit_done/emif.core_init_n clockResetSysInfo {}
	set_connection_parameter_value rrip.ninit_done/emif.core_init_n resetDomainSysInfo {-1}
	add_connection rrip.ninit_done/reset_handler.reset_n_0
	set_connection_parameter_value rrip.ninit_done/reset_handler.reset_n_0 clockDomainSysInfo {-1}
	set_connection_parameter_value rrip.ninit_done/reset_handler.reset_n_0 clockResetSysInfo {}
	set_connection_parameter_value rrip.ninit_done/reset_handler.reset_n_0 resetDomainSysInfo {-1}
	add_connection rrip.ninit_done/user_pll.reset
	set_connection_parameter_value rrip.ninit_done/user_pll.reset clockDomainSysInfo {-1}
	set_connection_parameter_value rrip.ninit_done/user_pll.reset clockResetSysInfo {}
	set_connection_parameter_value rrip.ninit_done/user_pll.reset resetDomainSysInfo {-1}
	add_connection user_pll.outclk0/axil_driver.axil_driver_clk
	set_connection_parameter_value user_pll.outclk0/axil_driver.axil_driver_clk clockDomainSysInfo {-1}
	set_connection_parameter_value user_pll.outclk0/axil_driver.axil_driver_clk clockRateSysInfo {-1.0}
	set_connection_parameter_value user_pll.outclk0/axil_driver.axil_driver_clk clockResetSysInfo {}
	set_connection_parameter_value user_pll.outclk0/axil_driver.axil_driver_clk resetDomainSysInfo {-1}
	add_connection user_pll.outclk0/emif.s0_axi4lite_clock
	set_connection_parameter_value user_pll.outclk0/emif.s0_axi4lite_clock clockDomainSysInfo {-1}
	set_connection_parameter_value user_pll.outclk0/emif.s0_axi4lite_clock clockRateSysInfo {-1.0}
	set_connection_parameter_value user_pll.outclk0/emif.s0_axi4lite_clock clockResetSysInfo {}
	set_connection_parameter_value user_pll.outclk0/emif.s0_axi4lite_clock resetDomainSysInfo {-1}
	add_connection user_pll.outclk0/reset_handler.clk
	set_connection_parameter_value user_pll.outclk0/reset_handler.clk clockDomainSysInfo {-1}
	set_connection_parameter_value user_pll.outclk0/reset_handler.clk clockRateSysInfo {-1.0}
	set_connection_parameter_value user_pll.outclk0/reset_handler.clk clockResetSysInfo {}
	set_connection_parameter_value user_pll.outclk0/reset_handler.clk resetDomainSysInfo {-1}

	# add the exports
	set_interface_property to_ddr_clk EXPORT_OF emif.s0_axi4_clock_in
	set_interface_property emif_s0_axi4_ctrl_ready EXPORT_OF emif.s0_axi4_ctrl_ready
	set_interface_property to_ddr EXPORT_OF emif.s0_axi4
	set_interface_property mem_0 EXPORT_OF emif.mem_0
	set_interface_property mem_ck_0 EXPORT_OF emif.mem_ck_0
	set_interface_property mem_reset_n EXPORT_OF emif.mem_reset_n
	set_interface_property oct_0 EXPORT_OF emif.oct_0
	set_interface_property ref_clk EXPORT_OF emif.ref_clk
	set_interface_property clk_100 EXPORT_OF user_pll.refclk

	# set values for exposed HDL parameters
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.enableAllPipelines FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.enableEccProtection FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.enableInstrumentation FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.fifoDepth 8
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.interconnectType STANDARD
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.maxAdditionalLatency 1
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.syncResets TRUE
	set_domain_assignment axil_driver.axil_driver_axi4_lite qsys_mm.widthAdapterImplementation GENERIC_CONVERTER

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="axil_driver">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
 <element __value="emif">
  <datum __value="_sortIndex" value="3" type="int" />
 </element>
 <element __value="reset_handler">
  <datum __value="_sortIndex" value="2" type="int" />
 </element>
 <element __value="rrip">
  <datum __value="_sortIndex" value="1" type="int" />
 </element>
 <element __value="user_pll">
  <datum __value="_sortIndex" value="4" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {emif.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {emif}

	# save the system
	sync_sysinfo_parameters
	save_system emif
}

# create the system "hps"
proc do_create_hps {} {
	# create the system
	create_system hps
	set_project_property BOARD {Agilex 5 FPGA E-Series 065B Modular Development Kit MK-A5E065BB32AES1}
	set_project_property DEVICE {A5ED065BB32AE6SR0}
	set_project_property DEVICE_FAMILY {Agilex 5}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component agx5_hps ip/hps/hps_intel_agilex_5_soc_0.ip intel_agilex_5_soc agx5_hps
	load_component agx5_hps
	set_component_parameter_value ATB_Enable {0}
	set_component_parameter_value CM_Mode {N/A}
	set_component_parameter_value CM_PinMuxing {Unused}
	set_component_parameter_value CTI_Enable {0}
	set_component_parameter_value DMA_Enable {No No No No No No No No}
	set_component_parameter_value Debug_APB_Enable {0}
	set_component_parameter_value ED_en_questa {1}
	set_component_parameter_value ED_en_riviera {0}
	set_component_parameter_value ED_en_sim_gen {1}
	set_component_parameter_value ED_en_synth_gen {0}
	set_component_parameter_value ED_en_vcsmx {1}
	set_component_parameter_value ED_en_xcelium {1}
	set_component_parameter_value ED_f2h_addr_width {38}
	set_component_parameter_value ED_f2h_connectivity {1}
	set_component_parameter_value ED_f2h_data_width {256}
	set_component_parameter_value ED_f2h_packet_size {1}
	set_component_parameter_value ED_f2h_traffic_pattern {0}
	set_component_parameter_value ED_f2sdram_addr_width {40}
	set_component_parameter_value ED_f2sdram_connectivity {1}
	set_component_parameter_value ED_f2sdram_data_width {256}
	set_component_parameter_value ED_f2sdram_packet_size {1}
	set_component_parameter_value ED_f2sdram_traffic_pattern {0}
	set_component_parameter_value ED_h2f_addr_width {26}
	set_component_parameter_value ED_h2f_connectivity {1}
	set_component_parameter_value ED_h2f_data_width {128}
	set_component_parameter_value ED_h2f_packet_size {1}
	set_component_parameter_value ED_h2f_traffic_pattern {0}
	set_component_parameter_value ED_lwh2f_addr_width {26}
	set_component_parameter_value ED_lwh2f_connectivity {1}
	set_component_parameter_value ED_lwh2f_data_width {32}
	set_component_parameter_value ED_lwh2f_packet_size {1}
	set_component_parameter_value ED_lwh2f_traffic_pattern {0}
	set_component_parameter_value EMAC0_Mode {N/A}
	set_component_parameter_value EMAC0_PPS_Enable {false}
	set_component_parameter_value EMAC0_PTP {0}
	set_component_parameter_value EMAC0_PinMuxing {Unused}
	set_component_parameter_value EMAC1_Mode {N/A}
	set_component_parameter_value EMAC1_PPS_Enable {false}
	set_component_parameter_value EMAC1_PTP {0}
	set_component_parameter_value EMAC1_PinMuxing {Unused}
	set_component_parameter_value EMAC2_Mode {RGMII_with_MDIO}
	set_component_parameter_value EMAC2_PPS_Enable {false}
	set_component_parameter_value EMAC2_PTP {0}
	set_component_parameter_value EMAC2_PinMuxing {IO}
	set_component_parameter_value EMIF_AXI_Enable {1}
	set_component_parameter_value EMIF_Topology {1}
	set_component_parameter_value F2H_IRQ_Enable {1}
	set_component_parameter_value F2H_free_clk_mhz {125}
	set_component_parameter_value F2H_free_clock_enable {0}
	set_component_parameter_value FPGA_EMAC0_gtx_clk_mhz {125.0}
	set_component_parameter_value FPGA_EMAC0_md_clk_mhz {2.5}
	set_component_parameter_value FPGA_EMAC0_tx_clk_en {1}
	set_component_parameter_value FPGA_EMAC1_gtx_clk_mhz {125.0}
	set_component_parameter_value FPGA_EMAC1_md_clk_mhz {2.5}
	set_component_parameter_value FPGA_EMAC1_tx_clk_en {1}
	set_component_parameter_value FPGA_EMAC2_gtx_clk_mhz {125.0}
	set_component_parameter_value FPGA_EMAC2_md_clk_mhz {2.5}
	set_component_parameter_value FPGA_EMAC2_tx_clk_en {1}
	set_component_parameter_value FPGA_EMAC_PTP_clk_en {1}
	set_component_parameter_value FPGA_I2C0_sclk_mhz {125.0}
	set_component_parameter_value FPGA_I2C1_sclk_mhz {125.0}
	set_component_parameter_value FPGA_I2CEMAC0_clk_mhz {125.0}
	set_component_parameter_value FPGA_I2CEMAC1_clk_mhz {125.0}
	set_component_parameter_value FPGA_I2CEMAC2_clk_mhz {125.0}
	set_component_parameter_value FPGA_I3C0_sclk_mhz {125.0}
	set_component_parameter_value FPGA_I3C1_sclk_mhz {125.0}
	set_component_parameter_value FPGA_SPIM0_sclk_mhz {125.0}
	set_component_parameter_value FPGA_SPIM1_sclk_mhz {125.0}
	set_component_parameter_value GP_Enable {0}
	set_component_parameter_value H2F_Address_Width {33}
	set_component_parameter_value H2F_IRQ_DMA_Enable0 {0}
	set_component_parameter_value H2F_IRQ_DMA_Enable1 {0}
	set_component_parameter_value H2F_IRQ_ECC_SERR_Enable {0}
	set_component_parameter_value H2F_IRQ_EMAC0_Enable {0}
	set_component_parameter_value H2F_IRQ_EMAC1_Enable {0}
	set_component_parameter_value H2F_IRQ_EMAC2_Enable {0}
	set_component_parameter_value H2F_IRQ_GPIO0_Enable {0}
	set_component_parameter_value H2F_IRQ_GPIO1_Enable {0}
	set_component_parameter_value H2F_IRQ_I2C0_Enable {0}
	set_component_parameter_value H2F_IRQ_I2C1_Enable {0}
	set_component_parameter_value H2F_IRQ_I2CEMAC0_Enable {0}
	set_component_parameter_value H2F_IRQ_I2CEMAC1_Enable {0}
	set_component_parameter_value H2F_IRQ_I2CEMAC2_Enable {0}
	set_component_parameter_value H2F_IRQ_I3C0_Enable {0}
	set_component_parameter_value H2F_IRQ_I3C1_Enable {0}
	set_component_parameter_value H2F_IRQ_L4Timer_Enable {0}
	set_component_parameter_value H2F_IRQ_NAND_Enable {0}
	set_component_parameter_value H2F_IRQ_PeriphClock_Enable {0}
	set_component_parameter_value H2F_IRQ_SDMMC_Enable {0}
	set_component_parameter_value H2F_IRQ_SPIM0_Enable {0}
	set_component_parameter_value H2F_IRQ_SPIM1_Enable {0}
	set_component_parameter_value H2F_IRQ_SPIS0_Enable {0}
	set_component_parameter_value H2F_IRQ_SPIS1_Enable {0}
	set_component_parameter_value H2F_IRQ_SYSTimer_Enable {0}
	set_component_parameter_value H2F_IRQ_UART0_Enable {0}
	set_component_parameter_value H2F_IRQ_UART1_Enable {0}
	set_component_parameter_value H2F_IRQ_USB0_Enable {0}
	set_component_parameter_value H2F_IRQ_USB1_Enable {0}
	set_component_parameter_value H2F_IRQ_Watchdog_Enable {0}
	set_component_parameter_value H2F_Width {32}
	set_component_parameter_value HPS_IO_Enable {GPIO0:IO0 NONE UART0:TX UART0:RX EMAC2:PPS2 EMAC2:PPSTRIG2 MDIO2:MDIO MDIO2:MDC I2C_EMAC1:SDA I2C_EMAC1:SCL GPIO0:IO10 HCLK:HPS_OSC_CLK NONE NONE NONE NONE NONE NONE NONE NONE NONE NONE NONE NONE SDMMC:DATA0 SDMMC:DATA1 SDMMC:CCLK GPIO1:IO3 GPIO1:IO4 SDMMC:DATA2 SDMMC:DATA3 SDMMC:CMD JTAG:TCK JTAG:TMS JTAG:TDO JTAG:TDI EMAC2:TX_CLK EMAC2:TX_CTL EMAC2:RX_CLK EMAC2:RX_CTL EMAC2:TXD0 EMAC2:TXD1 EMAC2:RXD0 EMAC2:RXD1 EMAC2:TXD2 EMAC2:TXD3 EMAC2:RXD2 EMAC2:RXD3}
	set_component_parameter_value I2C0_Mode {N/A}
	set_component_parameter_value I2C0_PinMuxing {Unused}
	set_component_parameter_value I2C1_Mode {N/A}
	set_component_parameter_value I2C1_PinMuxing {Unused}
	set_component_parameter_value I2CEMAC0_Mode {N/A}
	set_component_parameter_value I2CEMAC0_PinMuxing {Unused}
	set_component_parameter_value I2CEMAC1_Mode {default}
	set_component_parameter_value I2CEMAC1_PinMuxing {IO}
	set_component_parameter_value I2CEMAC2_Mode {N/A}
	set_component_parameter_value I2CEMAC2_PinMuxing {Unused}
	set_component_parameter_value I3C0_Mode {N/A}
	set_component_parameter_value I3C0_PinMuxing {Unused}
	set_component_parameter_value I3C1_Mode {N/A}
	set_component_parameter_value I3C1_PinMuxing {Unused}
	set_component_parameter_value IO_INPUT_DELAY0 {-1}
	set_component_parameter_value IO_INPUT_DELAY1 {-1}
	set_component_parameter_value IO_INPUT_DELAY10 {-1}
	set_component_parameter_value IO_INPUT_DELAY11 {-1}
	set_component_parameter_value IO_INPUT_DELAY12 {-1}
	set_component_parameter_value IO_INPUT_DELAY13 {-1}
	set_component_parameter_value IO_INPUT_DELAY14 {-1}
	set_component_parameter_value IO_INPUT_DELAY15 {-1}
	set_component_parameter_value IO_INPUT_DELAY16 {-1}
	set_component_parameter_value IO_INPUT_DELAY17 {-1}
	set_component_parameter_value IO_INPUT_DELAY18 {-1}
	set_component_parameter_value IO_INPUT_DELAY19 {-1}
	set_component_parameter_value IO_INPUT_DELAY2 {-1}
	set_component_parameter_value IO_INPUT_DELAY20 {-1}
	set_component_parameter_value IO_INPUT_DELAY21 {-1}
	set_component_parameter_value IO_INPUT_DELAY22 {-1}
	set_component_parameter_value IO_INPUT_DELAY23 {-1}
	set_component_parameter_value IO_INPUT_DELAY24 {-1}
	set_component_parameter_value IO_INPUT_DELAY25 {-1}
	set_component_parameter_value IO_INPUT_DELAY26 {-1}
	set_component_parameter_value IO_INPUT_DELAY27 {-1}
	set_component_parameter_value IO_INPUT_DELAY28 {-1}
	set_component_parameter_value IO_INPUT_DELAY29 {-1}
	set_component_parameter_value IO_INPUT_DELAY3 {-1}
	set_component_parameter_value IO_INPUT_DELAY30 {-1}
	set_component_parameter_value IO_INPUT_DELAY31 {-1}
	set_component_parameter_value IO_INPUT_DELAY32 {-1}
	set_component_parameter_value IO_INPUT_DELAY33 {-1}
	set_component_parameter_value IO_INPUT_DELAY34 {-1}
	set_component_parameter_value IO_INPUT_DELAY35 {-1}
	set_component_parameter_value IO_INPUT_DELAY36 {-1}
	set_component_parameter_value IO_INPUT_DELAY37 {-1}
	set_component_parameter_value IO_INPUT_DELAY38 {21}
	set_component_parameter_value IO_INPUT_DELAY39 {-1}
	set_component_parameter_value IO_INPUT_DELAY4 {-1}
	set_component_parameter_value IO_INPUT_DELAY40 {-1}
	set_component_parameter_value IO_INPUT_DELAY41 {-1}
	set_component_parameter_value IO_INPUT_DELAY42 {-1}
	set_component_parameter_value IO_INPUT_DELAY43 {-1}
	set_component_parameter_value IO_INPUT_DELAY44 {-1}
	set_component_parameter_value IO_INPUT_DELAY45 {-1}
	set_component_parameter_value IO_INPUT_DELAY46 {-1}
	set_component_parameter_value IO_INPUT_DELAY47 {-1}
	set_component_parameter_value IO_INPUT_DELAY5 {-1}
	set_component_parameter_value IO_INPUT_DELAY6 {-1}
	set_component_parameter_value IO_INPUT_DELAY7 {-1}
	set_component_parameter_value IO_INPUT_DELAY8 {-1}
	set_component_parameter_value IO_INPUT_DELAY9 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY0 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY1 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY10 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY11 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY12 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY13 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY14 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY15 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY16 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY17 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY18 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY19 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY2 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY20 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY21 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY22 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY23 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY24 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY25 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY26 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY27 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY28 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY29 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY3 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY30 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY31 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY32 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY33 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY34 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY35 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY36 {21}
	set_component_parameter_value IO_OUTPUT_DELAY37 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY38 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY39 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY4 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY40 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY41 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY42 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY43 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY44 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY45 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY46 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY47 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY5 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY6 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY7 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY8 {-1}
	set_component_parameter_value IO_OUTPUT_DELAY9 {-1}
	set_component_parameter_value JTAG_Enable {0}
	set_component_parameter_value LWH2F_Address_Width {21}
	set_component_parameter_value LWH2F_Width {32}
	set_component_parameter_value MPLL_C0_Override_mhz {800.0}
	set_component_parameter_value MPLL_C1_Override_mhz {800.0}
	set_component_parameter_value MPLL_C2_Override_mhz {533.33}
	set_component_parameter_value MPLL_C3_Override_mhz {400.0}
	set_component_parameter_value MPLL_Clock_Source {0}
	set_component_parameter_value MPLL_Override {1}
	set_component_parameter_value MPLL_VCO_Override_mhz {3200.0}
	set_component_parameter_value MPU_Events_Enable {0}
	set_component_parameter_value MPU_clk_freq_override_mhz {533.33}
	set_component_parameter_value MPU_clk_override {1}
	set_component_parameter_value MPU_clk_src_override {2}
	set_component_parameter_value MPU_core01_freq_override_mhz {800.0}
	set_component_parameter_value MPU_core01_src_override {1}
	set_component_parameter_value MPU_core23_src_override {0}
	set_component_parameter_value MPU_core2_freq_override_mhz {800.0}
	set_component_parameter_value MPU_core3_freq_override_mhz {800.0}
	set_component_parameter_value NAND_Mode {N/A}
	set_component_parameter_value NAND_PinMuxing {Unused}
	set_component_parameter_value NOC_clk_cs_debug_div {4}
	set_component_parameter_value NOC_clk_cs_div {1}
	set_component_parameter_value NOC_clk_cs_trace_div {4}
	set_component_parameter_value NOC_clk_free_l4_div {4}
	set_component_parameter_value NOC_clk_periph_l4_div {2}
	set_component_parameter_value NOC_clk_phy_div {4}
	set_component_parameter_value NOC_clk_slow_l4_div {4}
	set_component_parameter_value NOC_clk_src_select {3}
	set_component_parameter_value PLL_CLK0 {Unused}
	set_component_parameter_value PLL_CLK1 {Unused}
	set_component_parameter_value PLL_CLK2 {Unused}
	set_component_parameter_value PLL_CLK3 {Unused}
	set_component_parameter_value PLL_CLK4 {Unused}
	set_component_parameter_value PPLL_C0_Override_mhz {600.0}
	set_component_parameter_value PPLL_C1_Override_mhz {600.0}
	set_component_parameter_value PPLL_C2_Override_mhz {24.0}
	set_component_parameter_value PPLL_C3_Override_mhz {500.0}
	set_component_parameter_value PPLL_Clock_Source {0}
	set_component_parameter_value PPLL_Override {1}
	set_component_parameter_value PPLL_VCO_Override_mhz {3000.0}
	set_component_parameter_value Periph_clk_emac0_sel {250}
	set_component_parameter_value Periph_clk_emac1_sel {250}
	set_component_parameter_value Periph_clk_emac2_sel {250}
	set_component_parameter_value Periph_clk_override {0}
	set_component_parameter_value Periph_emac_ptp_freq_override {400.0}
	set_component_parameter_value Periph_emac_ptp_src_override {7}
	set_component_parameter_value Periph_emaca_src_override {7}
	set_component_parameter_value Periph_emacb_src_override {7}
	set_component_parameter_value Periph_gpio_freq_override {400.0}
	set_component_parameter_value Periph_gpio_src_override {3}
	set_component_parameter_value Periph_psi_freq_override {500.0}
	set_component_parameter_value Periph_psi_src_override {7}
	set_component_parameter_value Periph_usb_freq_override {20.0}
	set_component_parameter_value Periph_usb_src_override {3}
	set_component_parameter_value Pwr_a55_core0_1_on {1}
	set_component_parameter_value Pwr_a76_core2_on {1}
	set_component_parameter_value Pwr_a76_core3_on {1}
	set_component_parameter_value Pwr_boot_core_sel {0}
	set_component_parameter_value Pwr_cpu_app_select {0}
	set_component_parameter_value Pwr_mpu_l3_cache_size {2}
	set_component_parameter_value Pwr_override_cache_size {0}
	set_component_parameter_value Rst_h2f_cold_en {0}
	set_component_parameter_value Rst_hps_warm_en {0}
	set_component_parameter_value Rst_sdm_wd_config {0}
	set_component_parameter_value Rst_watchdog_en {0}
	set_component_parameter_value SDMMC_Mode {4-bit}
	set_component_parameter_value SDMMC_PinMuxing {IO}
	set_component_parameter_value SPIM0_Mode {N/A}
	set_component_parameter_value SPIM0_PinMuxing {Unused}
	set_component_parameter_value SPIM1_Mode {N/A}
	set_component_parameter_value SPIM1_PinMuxing {Unused}
	set_component_parameter_value SPIS0_Mode {N/A}
	set_component_parameter_value SPIS0_PinMuxing {Unused}
	set_component_parameter_value SPIS1_Mode {N/A}
	set_component_parameter_value SPIS1_PinMuxing {Unused}
	set_component_parameter_value STM_Enable {0}
	set_component_parameter_value TPIU_Select {HPS Clock Manager}
	set_component_parameter_value TRACE_Mode {N/A}
	set_component_parameter_value TRACE_PinMuxing {Unused}
	set_component_parameter_value UART0_Mode {No_flow_control}
	set_component_parameter_value UART0_PinMuxing {IO}
	set_component_parameter_value UART1_Mode {N/A}
	set_component_parameter_value UART1_PinMuxing {Unused}
	set_component_parameter_value USB0_Mode {N/A}
	set_component_parameter_value USB0_PinMuxing {Unused}
	set_component_parameter_value USB1_Mode {N/A}
	set_component_parameter_value USB1_PinMuxing {Unused}
	set_component_parameter_value User0_clk_enable {0}
	set_component_parameter_value User0_clk_freq {500.0}
	set_component_parameter_value User0_clk_src_select {7}
	set_component_parameter_value User1_clk_enable {0}
	set_component_parameter_value User1_clk_freq {500.0}
	set_component_parameter_value User1_clk_src_select {7}
	set_component_parameter_value eosc1_clk_mhz {25.0}
	set_component_parameter_value f2s_SMMU {0}
	set_component_parameter_value f2s_address_width {37}
	set_component_parameter_value f2s_data_width {0}
	set_component_parameter_value f2s_mode {ace5lite}
	set_component_parameter_value f2sdram_SMMU {0}
	set_component_parameter_value f2sdram_address_width {37}
	set_component_parameter_value f2sdram_data_width {256}
	set_component_parameter_value hps_ioa10_opd_en {0}
	set_component_parameter_value hps_ioa11_opd_en {0}
	set_component_parameter_value hps_ioa12_opd_en {0}
	set_component_parameter_value hps_ioa13_opd_en {0}
	set_component_parameter_value hps_ioa14_opd_en {0}
	set_component_parameter_value hps_ioa15_opd_en {0}
	set_component_parameter_value hps_ioa16_opd_en {0}
	set_component_parameter_value hps_ioa17_opd_en {0}
	set_component_parameter_value hps_ioa18_opd_en {0}
	set_component_parameter_value hps_ioa19_opd_en {0}
	set_component_parameter_value hps_ioa1_opd_en {0}
	set_component_parameter_value hps_ioa20_opd_en {0}
	set_component_parameter_value hps_ioa21_opd_en {0}
	set_component_parameter_value hps_ioa22_opd_en {0}
	set_component_parameter_value hps_ioa23_opd_en {0}
	set_component_parameter_value hps_ioa24_opd_en {0}
	set_component_parameter_value hps_ioa2_opd_en {0}
	set_component_parameter_value hps_ioa3_opd_en {0}
	set_component_parameter_value hps_ioa4_opd_en {0}
	set_component_parameter_value hps_ioa5_opd_en {0}
	set_component_parameter_value hps_ioa6_opd_en {0}
	set_component_parameter_value hps_ioa7_opd_en {0}
	set_component_parameter_value hps_ioa8_opd_en {0}
	set_component_parameter_value hps_ioa9_opd_en {0}
	set_component_parameter_value hps_iob10_opd_en {0}
	set_component_parameter_value hps_iob11_opd_en {0}
	set_component_parameter_value hps_iob12_opd_en {0}
	set_component_parameter_value hps_iob13_opd_en {0}
	set_component_parameter_value hps_iob14_opd_en {0}
	set_component_parameter_value hps_iob15_opd_en {0}
	set_component_parameter_value hps_iob16_opd_en {0}
	set_component_parameter_value hps_iob17_opd_en {0}
	set_component_parameter_value hps_iob18_opd_en {0}
	set_component_parameter_value hps_iob19_opd_en {0}
	set_component_parameter_value hps_iob1_opd_en {0}
	set_component_parameter_value hps_iob20_opd_en {0}
	set_component_parameter_value hps_iob21_opd_en {0}
	set_component_parameter_value hps_iob22_opd_en {0}
	set_component_parameter_value hps_iob23_opd_en {0}
	set_component_parameter_value hps_iob24_opd_en {0}
	set_component_parameter_value hps_iob2_opd_en {0}
	set_component_parameter_value hps_iob3_opd_en {0}
	set_component_parameter_value hps_iob4_opd_en {0}
	set_component_parameter_value hps_iob5_opd_en {0}
	set_component_parameter_value hps_iob6_opd_en {0}
	set_component_parameter_value hps_iob7_opd_en {0}
	set_component_parameter_value hps_iob8_opd_en {0}
	set_component_parameter_value hps_iob9_opd_en {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation agx5_hps
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.CPU_FREQ {50000000u}
	set_instantiation_assignment_value embeddedsw.configuration.cpuArchitecture {sm_hps}
	add_instantiation_interface h2f_reset reset OUTPUT
	set_instantiation_interface_parameter_value h2f_reset associatedClock {}
	set_instantiation_interface_parameter_value h2f_reset associatedDirectReset {}
	set_instantiation_interface_parameter_value h2f_reset associatedResetSinks {none}
	set_instantiation_interface_parameter_value h2f_reset synchronousEdges {NONE}
	add_instantiation_interface_port h2f_reset h2f_reset_reset reset 1 STD_LOGIC Output
	add_instantiation_interface hps2fpga_axi_clock clock INPUT
	set_instantiation_interface_parameter_value hps2fpga_axi_clock clockRate {0}
	set_instantiation_interface_parameter_value hps2fpga_axi_clock externallyDriven {false}
	set_instantiation_interface_parameter_value hps2fpga_axi_clock ptfSchematicName {}
	add_instantiation_interface_port hps2fpga_axi_clock hps2fpga_axi_clock_clk clk 1 STD_LOGIC Input
	add_instantiation_interface hps2fpga_axi_reset reset INPUT
	set_instantiation_interface_parameter_value hps2fpga_axi_reset associatedClock {}
	set_instantiation_interface_parameter_value hps2fpga_axi_reset synchronousEdges {NONE}
	add_instantiation_interface_port hps2fpga_axi_reset hps2fpga_axi_reset_reset reset 1 STD_LOGIC Input
	add_instantiation_interface hps2fpga axi4 OUTPUT
	set_instantiation_interface_parameter_value hps2fpga addressCheck {false}
	set_instantiation_interface_parameter_value hps2fpga associatedClock {hps2fpga_axi_clock}
	set_instantiation_interface_parameter_value hps2fpga associatedReset {hps2fpga_axi_reset}
	set_instantiation_interface_parameter_value hps2fpga combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value hps2fpga dataCheck {false}
	set_instantiation_interface_parameter_value hps2fpga enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value hps2fpga isTranslator {false}
	set_instantiation_interface_parameter_value hps2fpga issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value hps2fpga issuesINCRBursts {true}
	set_instantiation_interface_parameter_value hps2fpga issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value hps2fpga maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value hps2fpga maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value hps2fpga maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value hps2fpga noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value hps2fpga optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value hps2fpga poison {false}
	set_instantiation_interface_parameter_value hps2fpga readIssuingCapability {32}
	set_instantiation_interface_parameter_value hps2fpga securityAttribute {false}
	set_instantiation_interface_parameter_value hps2fpga traceSignals {false}
	set_instantiation_interface_parameter_value hps2fpga trustzoneAware {true}
	set_instantiation_interface_parameter_value hps2fpga uniqueIdSupport {false}
	set_instantiation_interface_parameter_value hps2fpga userData {false}
	set_instantiation_interface_parameter_value hps2fpga wakeupSignals {false}
	set_instantiation_interface_parameter_value hps2fpga writeIssuingCapability {32}
	add_instantiation_interface_port hps2fpga hps2fpga_awid awid 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awaddr awaddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awlock awlock 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port hps2fpga hps2fpga_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port hps2fpga hps2fpga_bid bid 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps2fpga hps2fpga_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps2fpga hps2fpga_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port hps2fpga hps2fpga_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_arid arid 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_araddr araddr 33 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_arlock arlock 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps2fpga hps2fpga_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port hps2fpga hps2fpga_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port hps2fpga hps2fpga_rid rid 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps2fpga hps2fpga_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps2fpga hps2fpga_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps2fpga hps2fpga_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port hps2fpga hps2fpga_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port hps2fpga hps2fpga_rready rready 1 STD_LOGIC Output
	add_instantiation_interface lwhps2fpga_axi_clock clock INPUT
	set_instantiation_interface_parameter_value lwhps2fpga_axi_clock clockRate {0}
	set_instantiation_interface_parameter_value lwhps2fpga_axi_clock externallyDriven {false}
	set_instantiation_interface_parameter_value lwhps2fpga_axi_clock ptfSchematicName {}
	add_instantiation_interface_port lwhps2fpga_axi_clock lwhps2fpga_axi_clock_clk clk 1 STD_LOGIC Input
	add_instantiation_interface lwhps2fpga_axi_reset reset INPUT
	set_instantiation_interface_parameter_value lwhps2fpga_axi_reset associatedClock {}
	set_instantiation_interface_parameter_value lwhps2fpga_axi_reset synchronousEdges {NONE}
	add_instantiation_interface_port lwhps2fpga_axi_reset lwhps2fpga_axi_reset_reset reset 1 STD_LOGIC Input
	add_instantiation_interface lwhps2fpga axi4 OUTPUT
	set_instantiation_interface_parameter_value lwhps2fpga addressCheck {false}
	set_instantiation_interface_parameter_value lwhps2fpga associatedClock {lwhps2fpga_axi_clock}
	set_instantiation_interface_parameter_value lwhps2fpga associatedReset {lwhps2fpga_axi_reset}
	set_instantiation_interface_parameter_value lwhps2fpga combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value lwhps2fpga dataCheck {false}
	set_instantiation_interface_parameter_value lwhps2fpga enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value lwhps2fpga isTranslator {false}
	set_instantiation_interface_parameter_value lwhps2fpga issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value lwhps2fpga issuesINCRBursts {true}
	set_instantiation_interface_parameter_value lwhps2fpga issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value lwhps2fpga maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value lwhps2fpga maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value lwhps2fpga maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value lwhps2fpga noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value lwhps2fpga optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value lwhps2fpga poison {false}
	set_instantiation_interface_parameter_value lwhps2fpga readIssuingCapability {32}
	set_instantiation_interface_parameter_value lwhps2fpga securityAttribute {false}
	set_instantiation_interface_parameter_value lwhps2fpga traceSignals {false}
	set_instantiation_interface_parameter_value lwhps2fpga trustzoneAware {true}
	set_instantiation_interface_parameter_value lwhps2fpga uniqueIdSupport {false}
	set_instantiation_interface_parameter_value lwhps2fpga userData {false}
	set_instantiation_interface_parameter_value lwhps2fpga wakeupSignals {false}
	set_instantiation_interface_parameter_value lwhps2fpga writeIssuingCapability {32}
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awid awid 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awaddr awaddr 21 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awlock awlock 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_bid bid 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arid arid 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_araddr araddr 21 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arlock arlock 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_rid rid 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port lwhps2fpga lwhps2fpga_rready rready 1 STD_LOGIC Output
	add_instantiation_interface emac2_app_rst reset OUTPUT
	set_instantiation_interface_parameter_value emac2_app_rst associatedClock {}
	set_instantiation_interface_parameter_value emac2_app_rst associatedDirectReset {}
	set_instantiation_interface_parameter_value emac2_app_rst associatedResetSinks {none}
	set_instantiation_interface_parameter_value emac2_app_rst synchronousEdges {NONE}
	add_instantiation_interface_port emac2_app_rst emac2_app_rst_reset_n reset_n 1 STD_LOGIC Output
	add_instantiation_interface h2f_warm_reset_handshake conduit INPUT
	set_instantiation_interface_parameter_value h2f_warm_reset_handshake associatedClock {}
	set_instantiation_interface_parameter_value h2f_warm_reset_handshake associatedReset {}
	set_instantiation_interface_parameter_value h2f_warm_reset_handshake prSafe {false}
	add_instantiation_interface_port h2f_warm_reset_handshake h2f_warm_reset_handshake_reset_req reset_req 1 STD_LOGIC Output
	add_instantiation_interface_port h2f_warm_reset_handshake h2f_warm_reset_handshake_reset_ack reset_ack 1 STD_LOGIC Input
	add_instantiation_interface hps_io conduit INPUT
	set_instantiation_interface_parameter_value hps_io associatedClock {}
	set_instantiation_interface_parameter_value hps_io associatedReset {}
	set_instantiation_interface_parameter_value hps_io prSafe {false}
	add_instantiation_interface_port hps_io hps_io_hps_osc_clk hps_osc_clk 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_sdmmc_data0 sdmmc_data0 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_sdmmc_data1 sdmmc_data1 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_sdmmc_cclk sdmmc_cclk 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_sdmmc_data2 sdmmc_data2 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_sdmmc_data3 sdmmc_data3 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_sdmmc_cmd sdmmc_cmd 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_emac2_tx_clk emac2_tx_clk 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_tx_ctl emac2_tx_ctl 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_rx_clk emac2_rx_clk 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_emac2_rx_ctl emac2_rx_ctl 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_emac2_txd0 emac2_txd0 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_txd1 emac2_txd1 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_rxd0 emac2_rxd0 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_emac2_rxd1 emac2_rxd1 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_emac2_txd2 emac2_txd2 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_txd3 emac2_txd3 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_rxd2 emac2_rxd2 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_emac2_rxd3 emac2_rxd3 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_emac2_pps emac2_pps 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_emac2_pps_trig emac2_pps_trig 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_mdio2_mdio mdio2_mdio 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_mdio2_mdc mdio2_mdc 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_i2c_emac1_sda i2c_emac1_sda 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_i2c_emac1_scl i2c_emac1_scl 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_uart0_tx uart0_tx 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_uart0_rx uart0_rx 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_jtag_tck jtag_tck 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_jtag_tms jtag_tms 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_jtag_tdo jtag_tdo 1 STD_LOGIC Output
	add_instantiation_interface_port hps_io hps_io_jtag_tdi jtag_tdi 1 STD_LOGIC Input
	add_instantiation_interface_port hps_io hps_io_gpio0 gpio0 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_gpio10 gpio10 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_gpio27 gpio27 1 STD_LOGIC Bidir
	add_instantiation_interface_port hps_io hps_io_gpio28 gpio28 1 STD_LOGIC Bidir
	add_instantiation_interface fpga2hps_interrupt_irq1 interrupt OUTPUT
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq1 associatedAddressablePoint {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq1 associatedClock {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq1 associatedReset {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq1 irqMap {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq1 irqScheme {INDIVIDUAL_REQUESTS}
	add_instantiation_interface_port fpga2hps_interrupt_irq1 fpga2hps_interrupt_irq1_irq irq 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface fpga2hps_interrupt_irq0 interrupt OUTPUT
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq0 associatedAddressablePoint {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq0 associatedClock {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq0 associatedReset {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq0 irqMap {}
	set_instantiation_interface_parameter_value fpga2hps_interrupt_irq0 irqScheme {INDIVIDUAL_REQUESTS}
	add_instantiation_interface_port fpga2hps_interrupt_irq0 fpga2hps_interrupt_irq0_irq irq 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface f2sdram_axi_clock clock INPUT
	set_instantiation_interface_parameter_value f2sdram_axi_clock clockRate {0}
	set_instantiation_interface_parameter_value f2sdram_axi_clock externallyDriven {false}
	set_instantiation_interface_parameter_value f2sdram_axi_clock ptfSchematicName {}
	add_instantiation_interface_port f2sdram_axi_clock f2sdram_axi_clock_clk clk 1 STD_LOGIC Input
	add_instantiation_interface f2sdram_axi_reset reset INPUT
	set_instantiation_interface_parameter_value f2sdram_axi_reset associatedClock {}
	set_instantiation_interface_parameter_value f2sdram_axi_reset synchronousEdges {NONE}
	add_instantiation_interface_port f2sdram_axi_reset f2sdram_axi_reset_reset reset 1 STD_LOGIC Input
	add_instantiation_interface f2sdram axi4 INPUT
	set_instantiation_interface_parameter_value f2sdram addressCheck {false}
	set_instantiation_interface_parameter_value f2sdram associatedClock {f2sdram_axi_clock}
	set_instantiation_interface_parameter_value f2sdram associatedReset {f2sdram_axi_reset}
	set_instantiation_interface_parameter_value f2sdram bridgesToMaster {}
	set_instantiation_interface_parameter_value f2sdram combinedAcceptanceCapability {64}
	set_instantiation_interface_parameter_value f2sdram dataCheck {false}
	set_instantiation_interface_parameter_value f2sdram dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value f2sdram dfhFeatureId {35}
	set_instantiation_interface_parameter_value f2sdram dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value f2sdram dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value f2sdram dfhFeatureType {3}
	set_instantiation_interface_parameter_value f2sdram dfhGroupId {0}
	set_instantiation_interface_parameter_value f2sdram dfhParameterData {}
	set_instantiation_interface_parameter_value f2sdram dfhParameterDataLength {}
	set_instantiation_interface_parameter_value f2sdram dfhParameterId {}
	set_instantiation_interface_parameter_value f2sdram dfhParameterName {}
	set_instantiation_interface_parameter_value f2sdram dfhParameterVersion {}
	set_instantiation_interface_parameter_value f2sdram isTranslator {false}
	set_instantiation_interface_parameter_value f2sdram maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value f2sdram maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value f2sdram maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value f2sdram noNarrowTransfer {false}
	set_instantiation_interface_parameter_value f2sdram optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value f2sdram poison {false}
	set_instantiation_interface_parameter_value f2sdram readAcceptanceCapability {32}
	set_instantiation_interface_parameter_value f2sdram readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value f2sdram securityAttribute {false}
	set_instantiation_interface_parameter_value f2sdram traceSignals {false}
	set_instantiation_interface_parameter_value f2sdram trustzoneAware {true}
	set_instantiation_interface_parameter_value f2sdram uniqueIdSupport {false}
	set_instantiation_interface_parameter_value f2sdram userData {false}
	set_instantiation_interface_parameter_value f2sdram wakeupSignals {false}
	set_instantiation_interface_parameter_value f2sdram writeAcceptanceCapability {32}
	set_instantiation_interface_sysinfo_parameter_value f2sdram address_map {<address-map><slave name='f2sdram' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value f2sdram address_width {37}
	set_instantiation_interface_sysinfo_parameter_value f2sdram max_slave_data_width {256}
	add_instantiation_interface_port f2sdram f2sdram_araddr araddr 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arcache arcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arid arid 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arlock arlock 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arqos arqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port f2sdram f2sdram_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_awaddr awaddr 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awcache awcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awid awid 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awlock awlock 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awqos awqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port f2sdram f2sdram_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_bid bid 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port f2sdram f2sdram_rdata rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_rid rid 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port f2sdram f2sdram_rready rready 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port f2sdram f2sdram_wdata wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_wlast wlast 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port f2sdram f2sdram_wstrb wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port f2sdram f2sdram_aruser aruser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_awuser awuser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_wuser wuser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_buser buser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_arregion arregion 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port f2sdram f2sdram_ruser ruser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port f2sdram f2sdram_awregion awregion 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface io96b0_to_hps conduit INPUT
	set_instantiation_interface_parameter_value io96b0_to_hps associatedClock {}
	set_instantiation_interface_parameter_value io96b0_to_hps associatedReset {}
	set_instantiation_interface_parameter_value io96b0_to_hps prSafe {false}
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_clk ch0_axil_clk 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_reset_n ch0_axil_reset_n 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_arready ch0_axil_arready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_awready ch0_axil_awready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_bresp ch0_axil_bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_bvalid ch0_axil_bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_rdata ch0_axil_rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_rresp ch0_axil_rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_rvalid ch0_axil_rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_wready ch0_axil_wready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_araddr ch0_axil_araddr 27 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_arvalid ch0_axil_arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_awaddr ch0_axil_awaddr 27 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_awvalid ch0_axil_awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_bready ch0_axil_bready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_rready ch0_axil_rready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_wdata ch0_axil_wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_wstrb ch0_axil_wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_wvalid ch0_axil_wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_arprot ch0_axil_arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_ch0_axil_awprot ch0_axil_awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_clk axi4_ch0_clk 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_reset_n axi4_ch0_reset_n 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arready axi4_ch0_arready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awready axi4_ch0_awready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_bid axi4_ch0_bid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_bresp axi4_ch0_bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_bvalid axi4_ch0_bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_rdata axi4_ch0_rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_rid axi4_ch0_rid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_rlast axi4_ch0_rlast 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_rresp axi4_ch0_rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_ruser axi4_ch0_ruser 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_rvalid axi4_ch0_rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_wready axi4_ch0_wready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_araddr axi4_ch0_araddr 40 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arburst axi4_ch0_arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arid axi4_ch0_arid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arlen axi4_ch0_arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arlock axi4_ch0_arlock 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arqos axi4_ch0_arqos 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arsize axi4_ch0_arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_aruser axi4_ch0_aruser 14 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arvalid axi4_ch0_arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awaddr axi4_ch0_awaddr 40 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awburst axi4_ch0_awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awid axi4_ch0_awid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awlen axi4_ch0_awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awlock axi4_ch0_awlock 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awqos axi4_ch0_awqos 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awsize axi4_ch0_awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awuser axi4_ch0_awuser 14 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awvalid axi4_ch0_awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_bready axi4_ch0_bready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_rready axi4_ch0_rready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_wdata axi4_ch0_wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_wlast axi4_ch0_wlast 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_wstrb axi4_ch0_wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_wuser axi4_ch0_wuser 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_wvalid axi4_ch0_wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_arprot axi4_ch0_arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps io96b0_to_hps_axi4_ch0_awprot axi4_ch0_awprot 3 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component agx5_hps_emif ip/hps/hps_emif_io96b_hps_0.ip emif_io96b_hps agx5_hps_emif
	load_component agx5_hps_emif
	set_component_parameter_value EMIF_PROTOCOL {DDR4_COMP}
	set_component_parameter_value EMIF_REF_CLK_SHARING {0}
	set_component_parameter_value EMIF_RZQ_SHARING {0}
	set_component_parameter_value EMIF_SHOW_INTERNAL_SETTINGS {0}
	set_component_parameter_value EMIF_TOPOLOGY {1x32}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	set_component_sub_module_parameter_value emif_0_ddr4comp ADV_CAL_ENABLE_MARGIN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp ADV_CAL_ENABLE_REQ {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp ADV_CAL_ENABLE_WEQ {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_ddr4comp AXI4_ADDR_WIDTH {40}
	set_component_sub_module_parameter_value emif_0_ddr4comp AXI4_USER_WIDTH {32}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_ALL_STRB_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_AUTO_PRECHARGE_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_BG_ROTATE_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_DMDBI_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_DM_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_ECC_AUTOCORRECT_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_FIXED_PRIORITY_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_FIXED_R_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_FIXED_W_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_PERFORMANCE_PROFILE {SEQ}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_PLACEMENT_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_RD_DBI_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_SCRAMBLER_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp CTRL_WR_DBI_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp DIAG_EXTRA_PARAMETERS {}
	set_component_sub_module_parameter_value emif_0_ddr4comp DIAG_HMC_ADDR_SWAP_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp EX_DESIGN_PMON_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp EX_DESIGN_PMON_INTERNAL_JAMB_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp EX_DESIGN_TG_WIDE_IF {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp HPS_EMIF_RZQ_SHARING {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp INSTANCE_ID {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp IS_HPS {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp JEDEC_OVERRIDE_TABLE_PARAM_NAME {MEM_TRAS_NS MEM_TCCD_L_NS MEM_TCCD_S_NS MEM_TRRD_L_NS MEM_TFAW_NS MEM_TWTR_L_NS MEM_TWTR_S_NS MEM_TMRD_NS MEM_TCKSRE_NS MEM_TCKSRX_NS MEM_TCKE_NS MEM_TMPRR_NS MEM_TXP_NS MEM_TXS_DLL_NS MEM_TCPDED_NS MEM_TMOD_NS MEM_TZQCS_NS}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_3DS_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_AC_MIRRORING_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_AC_PARITY_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_AC_PARITY_LATENCY_MODE {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_AL_CYC {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_A_WIDTH {17}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_BANK_ADDR_WIDTH {2}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_BANK_GROUP_ADDR_WIDTH {2}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CHANNEL_ADDR_NUM_BITS {36}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CHANNEL_CAPACITY_GBITS {64}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CHANNEL_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CHANNEL_ECC_DQ_WIDTH {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CKE_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CK_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CLAMSHELL_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CL_CYC {12.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_COL_ADDR_WIDTH {10}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CS_WIDTH_PHYSICAL {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_CWL_CYC {9.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_C_WIDTH {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_DIE_DENSITY_GBITS {16}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_DIE_DQ_WIDTH {8}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_DQ_PER_DQS {8}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_DQ_VREF {35}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_FINE_GRANULARITY_REFRESH_MODE {1.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_NUM_CHANNELS {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_NUM_CHANNELS_PER_IO96 {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_NUM_IO96 {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_DQ_X_IDLE {off}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_DQ_X_NON_TGT_RD {off}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_DQ_X_NON_TGT_WR {off}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_DQ_X_RON {7}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_DQ_X_TGT_WR {4}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_NOM {off}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_PARK {4}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ODT_WR {off}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_OPERATING_FREQ_MHZ {800}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_PAGE_SIZE {1024.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_RANKS_SHARE_CK_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_RD_PREAMBLE_MODE {1.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_ROW_ADDR_WIDTH {17}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_SPEEDBIN {1600L}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_SPEEDBIN_DATARATE {1600}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCCD_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCCD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCCD_S_NS {4.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCKESR_CYC {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCKE_NS {4.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCKSRE_NS {8.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCKSRX_NS {8.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCK_CL_CWL_MAX_NS {1.5}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCK_CL_CWL_MIN_NS {1.25}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TCPDED_NS {4.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TDQSCK_MAX_MIN_NS {0.225}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TDQSCK_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TFAW_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TFAW_NS {35.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TMOD_NS {24.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TMPRR_NS {1.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TMRD_NS {8.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRAS_MAX_NS {70200.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRAS_MIN_NS {35.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRAS_NS {35.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRCD_NS {15.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRC_NS {50.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TREFI_NS {7800.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRFC_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRFC_NS {550.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRP_NS {15.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRRD_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRRD_L_NS {6.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRRD_S_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TRTP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TWR_CRC_DM_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TWR_NS {15.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TWTR_L_CRC_DM_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TWTR_L_NS {6.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TWTR_S_CRC_DM_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TWTR_S_NS {2.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TXP_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TXS_DLL_NS {597.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TXS_NS {560.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TZQCS_NS {128.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TZQINIT_CYC {1024.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_TZQOPER_CYC {512.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_VREF_DQ_X_RANGE {2}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_VREF_DQ_X_VALUE {67.75}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_WR_CRC_EN {0.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp MEM_WR_PREAMBLE_MODE {1.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_AC_PLACEMENT {BOT}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_AC_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_ALERT_N_PLACEMENT {AC2}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_CK_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_CS_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_DQ_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_FORCE_MIN_4_AC_LANES_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_REFCLK_FREQ_MHZ {150.0}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_SWIZZLE_MAP {BYTE_SWIZZLE_CH0=0 X X X 1 2 3 X;PIN_SWIZZLE_CH0_DQS3=26 30 28 24 25 27 29 31;PIN_SWIZZLE_CH0_DQS2=16 20 22 18 23 21 19 17;PIN_SWIZZLE_CH0_DQS1=14 11 12 8 10 9 13 15;PIN_SWIZZLE_CH0_DQS0=2 0 6 4 7 5 3 1;}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {SSTL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_AC_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_SSTL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_CK_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {SSTL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_CS_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_DQ_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_DQ_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_DQ_VREF {68.3}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}
	set_component_sub_module_parameter_value emif_0_ddr4comp PLACEMENT_SCHEMES {DDR4_X32_3AC_BOT}
	set_component_sub_module_parameter_value emif_0_ddr4comp S0_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_R2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_R2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr4comp TURNAROUND_W2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp ADV_CAL_ENABLE_MARGIN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp ADV_CAL_ENABLE_RD_DFE {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp ADV_CAL_ENABLE_REQ {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp ADV_CAL_ENABLE_WEQ {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp ADV_CAL_ENABLE_WR_DFE {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_ddr5comp AXI4_ADDR_WIDTH {31}
	set_component_sub_module_parameter_value emif_0_ddr5comp AXI4_USER_WIDTH {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_2N_MODE_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_ALL_STRB_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_AUTO_PRECHARGE_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_BG_ROTATE_EN {2}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_DM_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_ECC_AUTOCORRECT_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_FIXED_PRIORITY_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_FIXED_R_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_FIXED_W_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_PERFORMANCE_PROFILE {SEQ}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_PLACEMENT_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp CTRL_SCRAMBLER_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp DIAG_EXTRA_PARAMETERS {}
	set_component_sub_module_parameter_value emif_0_ddr5comp DIAG_FORCE_SLIM_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp DIAG_HMC_ADDR_SWAP_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp EX_DESIGN_PMON_CH1_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp EX_DESIGN_PMON_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp EX_DESIGN_PMON_INTERNAL_JAMB_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp EX_DESIGN_TG_WIDE_IF {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp HPS_EMIF_RZQ_SHARING {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp INSTANCE_ID {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp IS_HPS {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp JEDEC_OVERRIDE_TABLE_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_BANK_ADDR_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_BANK_GROUP_ADDR_WIDTH {2}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CA_VREF {55}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CA_WIDTH {13}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CHANNEL_ADDR_NUM_BITS {34}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CHANNEL_CAPACITY_GBITS {16}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CHANNEL_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CHANNEL_ECC_DQ_WIDTH {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CHANNEL_ECC_DQ_WIDTH_ROUNDED {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CK_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CL_CYC {40.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_COL_ADDR_WIDTH {10}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CS_VREF {95}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_CWL_CYC {38.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DFE_X_TAP_1 {n9}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DFE_X_TAP_2 {n3}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DFE_X_TAP_3 {n1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DFE_X_TAP_4 {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DIE_DENSITY_GBITS {8}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DIE_DQ_WIDTH {16}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DQ_PER_DQS {8}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_DQ_VREF {46}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_FINE_GRANULARITY_REFRESH_MODE {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_NUM_CHANNELS {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_NUM_CHANNELS_PER_IO96 {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_NUM_IO96 {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_CA_X_CA {6}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_CA_X_CK {6}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_CA_X_CS {6}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_DQ_X_IDLE {5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_DQ_X_NON_TGT_RD {off}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_DQ_X_NON_TGT_WR {off}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_DQ_X_RON {7}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ODT_DQ_X_TGT_WR {5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_OPERATING_DATARATE {5600}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_OPERATING_FREQ_MHZ {2800}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_OPERATING_SPEEDBIN {5600AN}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_RD_POSTAMBLE_MODE {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_RD_PREAMBLE_MODE {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_ROW_ADDR_WIDTH {16}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_SPEEDBIN {5600AN}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_SPEEDBIN_DATARATE {5600}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TACTPDEN_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCCD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCCD_L_WR2_NS {10.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCCD_L_WR_NS {20.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCCD_S_CYC {8.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCKLCS_CYC {15.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCKSRX_NS {3.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCPDED_CYC {14.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCSH_SREXIT_MAX_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCSH_SREXIT_MIN_NS {13.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCSH_SREXIT_NS {13.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TCSL_NS {10.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDFE_NS {80.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDLLK_NS {640.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDQSCK_CYC {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDQSCK_MAX_CYC {0.325}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDQSCK_MIN_CYC {-0.325}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDQSS_CYC {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDQSS_MAX_CYC {0.625}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TDQSS_MIN_CYC {-0.625}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TFAW_NS {14.28571}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TMRD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TMRR_NS {14.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TMRR_P_NS {2.85714}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TMRW_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TPD_MAX_NS {19500.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TPD_MIN_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TPD_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TPPD_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TPRPDEN_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRAS_MAX_NS {19500.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRAS_MIN_NS {32.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRAS_NS {32.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRCD_NS {14.28571}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRC_NS {46.28571}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TREFI1_NS {3900.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TREFI2_NS {1950.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TREFISB_NS {975.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TREFPDEN_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TREFSBRD_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRFC1_NS {195.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRFC2_NS {130.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRFCSB_NS {115.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRP_NS {14.28571}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRRD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRRD_S_CYC {8.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TRTP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TWPRE_EN_CYC {2.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TWR_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TWTRA_NS {22.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TWTR_L_NS {10.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TWTR_S_NS {2.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TXP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TZQCAL_NS {1000.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_TZQLAT_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_VREF_CA_X_CA_VALUE {70.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_VREF_CA_X_CS_VALUE {50.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_VREF_DQ_X_VALUE {74.5}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_WR_POSTAMBLE_MODE {1.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp MEM_WR_PREAMBLE_MODE {3.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_AC_PLACEMENT {BOT}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_AC_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_CK_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_CS_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_DFE_X_TAP_1 {n1}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_DFE_X_TAP_2 {n1}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_DFE_X_TAP_3 {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_DFE_X_TAP_4 {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_DQ_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_REFCLK_FREQ_MHZ {200.0}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_AC_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_POD}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_CK_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_CS_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_DQ_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_DQ_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_DQ_VREF {71.82}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_60_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}
	set_component_sub_module_parameter_value emif_0_ddr5comp PLACEMENT_SCHEMES {DDR5_X32_BOT}
	set_component_sub_module_parameter_value emif_0_ddr5comp S0_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_ddr5comp S1_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_R2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_R2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5comp TURNAROUND_W2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm ADV_CAL_ENABLE_MARGIN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm ADV_CAL_ENABLE_RD_DFE {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm ADV_CAL_ENABLE_REQ {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm ADV_CAL_ENABLE_WEQ {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm ADV_CAL_ENABLE_WR_DFE {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_ddr5dimm AXI4_ADDR_WIDTH {32}
	set_component_sub_module_parameter_value emif_0_ddr5dimm AXI4_USER_WIDTH {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_2N_MODE_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_ALL_STRB_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_AUTO_PRECHARGE_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_BG_ROTATE_EN {2}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_DM_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_ECC_AUTOCORRECT_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_FIXED_PRIORITY_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_FIXED_R_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_FIXED_W_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_PERFORMANCE_PROFILE {SEQ}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_PLACEMENT_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm CTRL_SCRAMBLER_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm DIAG_EXTRA_PARAMETERS {}
	set_component_sub_module_parameter_value emif_0_ddr5dimm DIAG_HMC_ADDR_SWAP_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm EX_DESIGN_PMON_CH1_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm EX_DESIGN_PMON_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm EX_DESIGN_PMON_INTERNAL_JAMB_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm EX_DESIGN_TG_WIDE_IF {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm HPS_EMIF_RZQ_SHARING {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm INSTANCE_ID {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm IS_HPS {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm JEDEC_OVERRIDE_TABLE_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_3DS_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_BANK_ADDR_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_BANK_GROUP_ADDR_WIDTH {3}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CA_VREF {55}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CA_WIDTH {13}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CHANNEL_ADDR_NUM_BITS {35}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CHANNEL_CAPACITY_GBITS {32}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CHANNEL_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CHANNEL_ECC_DQ_WIDTH {4}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CHANNEL_ECC_DQ_WIDTH_ROUNDED {8}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CK_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CL_CYC {40.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_COL_ADDR_WIDTH {10}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CS_VREF {95}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_CWL_CYC {38.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DFE_X_TAP_1 {n9}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DFE_X_TAP_2 {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DFE_X_TAP_3 {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DFE_X_TAP_4 {n1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DIE_DENSITY_GBITS {8}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DIE_DQ_WIDTH {8}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DIMM_TYPE {UDIMM}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DQ_PER_DQS {8}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_DQ_VREF {39}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_FINE_GRANULARITY_REFRESH_MODE {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_NUM_CHANNELS {2}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_NUM_CHANNELS_PER_IO96 {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_NUM_IO96 {2}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_CA_X_CA {6}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_CA_X_CK {6}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_CA_X_CS {6}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_DQ_X_IDLE {5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_DQ_X_NON_TGT_RD {off}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_DQ_X_NON_TGT_WR {off}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_DQ_X_RON {7}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ODT_DQ_X_TGT_WR {5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_OPERATING_DATARATE {5600}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_OPERATING_FREQ_MHZ {2800}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_OPERATING_SPEEDBIN {5600AN}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_RCD_DCA_IBT {3}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_RCD_DCK_IBT {3}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_RCD_DCS_IBT {3}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_RCD_DERROR_IBT {3}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_RD_POSTAMBLE_MODE {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_RD_PREAMBLE_MODE {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_ROW_ADDR_WIDTH {16}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPD248_CK_CONTROL_ENABLE {32.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPD249_QCA_CS_ENABLE {8.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPD250_QCK_SIGNAL_DRIVER_STRENGTH {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPD252_QCA_QCS_SIGNAL_DRIVER_STRENGTH {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPD254_CK_CA_CS_SLEW_RATE {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPEEDBIN {5600AN}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_SPEEDBIN_DATARATE {5600}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TACTPDEN_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCCD_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCCD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCCD_L_WR2_NS {10.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCCD_L_WR_NS {20.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCCD_S_CYC {8.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCKLCS_CYC {15.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCKSRX_NS {3.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCPDED_CYC {14.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCSH_SREXIT_MAX_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCSH_SREXIT_MIN_NS {13.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCSH_SREXIT_NS {13.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TCSL_NS {10.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDFE_NS {80.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDLLK_NS {640.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDQSCK_CYC {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDQSCK_MAX_CYC {0.325}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDQSCK_MIN_CYC {-0.325}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDQSS_CYC {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDQSS_MAX_CYC {0.625}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TDQSS_MIN_CYC {-0.625}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TFAW_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TFAW_NS {11.42857}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TMRD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TMRR_NS {14.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TMRR_P_NS {2.85714}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TMRW_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TPD_MAX_NS {19500.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TPD_MIN_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TPD_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TPPD_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TPRPDEN_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRAS_MAX_NS {19500.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRAS_MIN_NS {32.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRAS_NS {32.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRCD_NS {14.28571}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRC_NS {46.28571}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TREFI1_NS {3900.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TREFI2_NS {1950.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TREFISB_NS {975.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TREFPDEN_CYC {2.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TREFSBRD_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRFC1_NS {195.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRFC2_NS {130.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRFCSB_NS {115.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRP_NS {14.28571}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRRD_DLR_NS {0.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRRD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRRD_S_CYC {8.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TRTP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TWPRE_EN_CYC {2.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TWR_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TWTRA_NS {22.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TWTR_L_NS {10.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TWTR_S_NS {2.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TXP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TZQCAL_NS {1000.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_TZQLAT_NS {30.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_VREF_CA_X_CA_VALUE {70.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_VREF_CA_X_CS_VALUE {50.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_VREF_DQ_X_VALUE {78.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_WR_POSTAMBLE_MODE {1.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm MEM_WR_PREAMBLE_MODE {3.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_AC_PLACEMENT {BOT_BOT}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_AC_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_CK_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_CS_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_DFE_X_TAP_1 {n1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_DFE_X_TAP_2 {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_DFE_X_TAP_3 {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_DFE_X_TAP_4 {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_DQ_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_REFCLK_FREQ_MHZ {200.0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_AC_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_POD}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_CK_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_CS_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_DQS_IO_STD_TYPE {DF_POD}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_DQ_IO_STD_TYPE {POD}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_DQ_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_DQ_VREF {75.45}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_34_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_60_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}
	set_component_sub_module_parameter_value emif_0_ddr5dimm PLACEMENT_SCHEMES {DDR5_X40_BOT_ECC_ON DDR5_X40_BOT_ECC_ON}
	set_component_sub_module_parameter_value emif_0_ddr5dimm S0_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_ddr5dimm S1_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_R2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_R2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_ddr5dimm TURNAROUND_W2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 ADV_CAL_ENABLE_MARGIN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 ADV_CAL_ENABLE_REQ {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 ADV_CAL_ENABLE_WEQ {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_lpddr4 AXI4_ADDR_WIDTH {31}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_ALL_STRB_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_AUTO_PRECHARGE_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_DM_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_ECC_AUTOCORRECT_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_ECC_INLINE_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_FIXED_PRIORITY_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_FIXED_R_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_FIXED_W_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_PERFORMANCE_PROFILE {SEQ}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_PLACEMENT_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_RD_DBI_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_SCRAMBLER_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 CTRL_WR_DBI_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 DIAG_EXTRA_PARAMETERS {}
	set_component_sub_module_parameter_value emif_0_lpddr4 DIAG_FORCE_SLIM_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 DIAG_HMC_ADDR_SWAP_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 EX_DESIGN_PMON_CH1_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 EX_DESIGN_PMON_CH2_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 EX_DESIGN_PMON_CH3_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 EX_DESIGN_PMON_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 EX_DESIGN_PMON_INTERNAL_JAMB_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 EX_DESIGN_TG_WIDE_IF {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 INSTANCE_ID {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 IS_HPS {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 JEDEC_OVERRIDE_TABLE_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_BANK_ADDR_WIDTH {3}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CA_VREF {13}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CA_WIDTH {6}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CHANNEL_ADDR_NUM_BITS {34}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CHANNEL_CAPACITY_GBITS {16.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CHANNEL_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CKE_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CK_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CL_CYC {36}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_COL_ADDR_WIDTH {10}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_CWL_CYC {34}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_DIE_DENSITY_GBITS {16}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_DQ_PER_DQS {8}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_DQ_VREF {20}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_MINNUMREFSREQ {8192.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_NUM_CHANNELS {2}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_NUM_CHANNELS_PER_IO96 {2}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_NUM_IO96 {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_CA_X_CA_COMM {3}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_CA_X_CA_ENABLE {true}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_CA_X_CK_ENABLE {true}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_CA_X_CS_ENABLE {true}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_DQ_X_IDLE {off}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_DQ_X_RON {6}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ODT_DQ_X_TGT_WR {5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_OPERATING_FREQ_MHZ {2133.333}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_PER_BANK_REF_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_RD_POSTAMBLE_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_RD_PREAMBLE_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_ROW_ADDR_WIDTH {17}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCCD_NS {3.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCKCKEH_NS {1.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCKCKEL_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCKEHCMD_NS {7.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCKELCK_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCKELCMD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCKE_NS {7.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCMDCKE_NS {1.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCSCKEH_NS {1.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TCSCKE_NS {1.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TDQSCK_MAX_NS {3.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TDQSCK_MIN_NS {1.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TECH_IS_X {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TESCKE_NS {1.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TFAW_NS {40.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TMRD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TMRR_NS {3.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TMRWCKEL_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TMRW_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TPPD_CYC {4.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRAS_NS {42.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRCD_NS {18.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRC_NS {63.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TREFI_NS {3904.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TREFW_NS {32000000.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRFCAB_NS {380.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRFCPB_NS {190.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRPAB_NS {21.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRPPB_NS {18.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRRD_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TRTP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TSR_NS {15.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TWR_NS {18.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TWTR_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TXP_NS {7.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TXSR_NS {387.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TZQCAL_NS {1000.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TZQCKE_NS {1.75}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_TZQLAT_NS {30.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_VREF_CA_X_CA_RANGE {2}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_VREF_CA_X_CA_VALUE {27.2}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_VREF_DQ_X_RANGE {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_VREF_DQ_X_VALUE {18.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_WLS {1.0}
	set_component_sub_module_parameter_value emif_0_lpddr4 MEM_WR_POSTAMBLE_CYC {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 NUM_IO96_IN_CHIP {8}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_AC_PLACEMENT {FULL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_AC_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_CK_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_CS_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_DQ_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_REFCLK_FREQ_MHZ {199.111}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_AC_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_CK_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_CS_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_DQS_IO_STD_TYPE {DF_LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_DQ_IO_STD_TYPE {LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_DQ_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_DQ_VREF {17.5}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_50_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}
	set_component_sub_module_parameter_value emif_0_lpddr4 PLACEMENT_SCHEMES {LPDDR4_X16X2}
	set_component_sub_module_parameter_value emif_0_lpddr4 S0_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr4 S1_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr4 S2_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr4 S3_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_R2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_R2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr4 TURNAROUND_W2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 ADV_CAL_ENABLE_MARGIN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 ADV_CAL_ENABLE_RD_DFE {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 ADV_CAL_ENABLE_REQ {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 ADV_CAL_ENABLE_WEQ {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 ADV_CAL_ENABLE_WR_DFE {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 ANALOG_PARAM_DERIVATION_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_lpddr5 AXI4_ADDR_WIDTH {32}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ALL_STRB_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_AUTO_PRECHARGE_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_BG_ROTATE_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_DM_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_AUTOCORRECT_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_INLINE_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_RD_LINK_EN_FSP0 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_RD_LINK_EN_FSP1 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_RD_LINK_EN_FSP2 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_WR_LINK_EN_FSP0 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_WR_LINK_EN_FSP1 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_ECC_WR_LINK_EN_FSP2 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_FIXED_PRIORITY_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_FIXED_R_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_FIXED_W_PRIORITY {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_PERFORMANCE_PROFILE {SEQ}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_PLACEMENT_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_RD_DBI_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_SCRAMBLER_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 CTRL_WR_DBI_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 DIAG_EXTRA_PARAMETERS {}
	set_component_sub_module_parameter_value emif_0_lpddr5 DIAG_FORCE_SLIM_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 DIAG_HMC_ADDR_SWAP_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 EX_DESIGN_PMON_CH1_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 EX_DESIGN_PMON_CH2_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 EX_DESIGN_PMON_CH3_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 EX_DESIGN_PMON_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 EX_DESIGN_PMON_INTERNAL_JAMB_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 EX_DESIGN_TG_WIDE_IF {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 INSTANCE_ID {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 IS_HPS {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 JEDEC_OVERRIDE_TABLE_PARAM_NAME {}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_BANK_ADDR_WIDTH {2}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_BANK_GROUP_ADDR_WIDTH {2}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_BANK_MODE {LPDDR5_BANK_MODE_16B_BG_AUTO}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_BURST_ADDR_WIDTH {4}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CA_VREF {80}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CA_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CHANNEL_ADDR_NUM_BITS {35}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CHANNEL_CAPACITY_GBITS {32.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CHANNEL_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CK_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_COL_ADDR_WIDTH {6}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_CS_WIDTH {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_DFE_X_TAP_1 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_DFS_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_DIE_DENSITY_GBITS {32}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_DQ_PER_DQS {8}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_DQ_VREF {28}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_CK_FREQ_MHZ {687.5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_CL_CYC {15}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_CWL_CYC {14}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_OPERATING_FREQ_MHZ {2750}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TCKCSH_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TCMDPD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TCSLCK_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TCSPD_NS {12.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TESPD_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TMRD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TMRR_NS {6.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TMRWPD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TMRW_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TPBR2PBR_NS {90.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TPPD_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TRBTP_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TRFCAB_NS {380.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TRFCPB_NS {190.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TRRD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TRRD_S_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TWTR_L_NS {12.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TWTR_S_NS {7.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TXP_NS {7.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TXSR_NS {388.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP0_TZQPD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_CK_FREQ_MHZ {687.5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_CL_CYC {15}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_CWL_CYC {14}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_OPERATING_FREQ_MHZ {2750}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TCKCSH_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TCMDPD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TCSLCK_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TCSPD_NS {12.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TESPD_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TMRD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TMRR_NS {6.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TMRWPD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TMRW_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TPBR2PBR_NS {90.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TPPD_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TRBTP_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TRFCAB_NS {380.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TRFCPB_NS {190.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TRRD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TRRD_S_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TWTR_L_NS {12.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TWTR_S_NS {7.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TXP_NS {7.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TXSR_NS {388.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP1_TZQPD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_CK_FREQ_MHZ {687.5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_CL_CYC {15}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_CWL_CYC {14}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_OPERATING_FREQ_MHZ {2750}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_OPERATING_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TCKCSH_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TCMDPD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TCSLCK_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TCSPD_NS {12.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TESPD_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TMRD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TMRR_NS {6.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TMRWPD_NS {14.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TMRW_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TPBR2PBR_NS {90.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TPPD_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TRBTP_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TRFCAB_NS {380.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TRFCPB_NS {190.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TRRD_L_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TRRD_S_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TWTR_L_NS {12.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TWTR_S_NS {7.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TXP_NS {7.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TXSR_NS {388.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_FSP2_TZQPD_NS {5.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_MINNUMREFSREQ {8192.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_NUM_CHANNELS {2}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_NUM_CHANNELS_PER_IO96 {2}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_NUM_IO96 {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_CA_X_CA_COMM {5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_CA_X_CA_ENABLE {true}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_CA_X_CK_ENABLE {false}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_CA_X_CS_ENABLE {true}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_DQ_X_IDLE {off}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_DQ_X_NON_TGT {off}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_DQ_X_RON {5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_DQ_X_TGT_WR {5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ODT_DQ_X_WCK {5}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_OPERATING_FREQ_MHZ {2750}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_PER_BANK_REF_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_RDQS_POSTAMBLE_MODE {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_RD_POSTAMBLE_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_RD_PREAMBLE_CYC {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_ROW_ADDR_WIDTH {17}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TCCDMW_NS {16.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TCSH_NS {3.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TDQSCK_NS {0.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TERQE_NS {35.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TERQX_NS {35.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TFAW_NS {20.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TOSCO_NS {40.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TPBR2ACT_8B_NS {10.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TPBR2ACT_NS {8.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TPW_RESET_NS {100.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRAS_MAX_NS {35000.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRAS_NS {42.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRCD_NS {18.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRC_NS {63.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRDQE_OD_NS {35.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRDQSTFE_NS {35.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRDQSTFX_NS {35.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRDQX_OD_NS {35.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TREFI_NS {3906.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TREFW_NS {32000000.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRPAB_NS {21.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TRPPB_NS {18.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TSR_NS {15.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TWR_NS {34.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_TZQLAT_NS {30.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_VREF_CA_X_CA_VALUE {50.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_VREF_DQ_X_VALUE {24.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_WCK_WIDTH {2}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_WLS {1.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 MEM_WR_POSTAMBLE_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 NUM_IO96_IN_CHIP {8}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_AC_PLACEMENT {FULL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_AC_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_CK_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_CS_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_DFE_X_TAP_1 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_DFE_X_TAP_2 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_DFE_X_TAP_3 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_DFE_X_TAP_4 {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_DQ_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_REFCLK_ADVANCED_SELECT_EN {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_REFCLK_FREQ_MHZ {200.0}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_REFCLK_FREQ_MHZ_AUTOSET_EN {1}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_RESET_N_TX_EQUALIZATION {OFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_AC_OUTPUT_IO_STD_TYPE {LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_AC_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_CK_OUTPUT_IO_STD_TYPE {DF_LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_CK_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_CS_OUTPUT_IO_STD_TYPE {LVSTL105}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_CS_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_DQS_IO_STD_TYPE {DF_LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_DQ_IO_STD_TYPE {LVSTL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_DQ_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_DQ_VREF {14.67}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_GPIO_IO_STD_TYPE {LVCMOS}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_REFCLK_IO_STD_TYPE {TRUE_DIFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_RESET_N_OUTPUT_IO_STD_TYPE {LVSTL105}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_RESET_N_SLEW_RATE {FASTEST}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_S_AC_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_S_CK_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_S_CS_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_S_DQ_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_S_RESET_N_OUTPUT_OHM {SERIES_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_T_DQ_INPUT_OHM {RT_40_OHM_CAL}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_T_GPIO_INPUT_OHM {RT_OFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PHY_TERM_X_R_T_REFCLK_INPUT_OHM {RT_DIFF}
	set_component_sub_module_parameter_value emif_0_lpddr5 PLACEMENT_SCHEMES {LPDDR5_X16X2}
	set_component_sub_module_parameter_value emif_0_lpddr5 S0_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr5 S1_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr5 S2_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr5 S3_AXID_WIDTH {7}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_R2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_R2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_R2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_R2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_W2R_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_W2R_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_W2W_DIFFCS_CYC {0}
	set_component_sub_module_parameter_value emif_0_lpddr5 TURNAROUND_W2W_SAMECS_CYC {0}
	set_component_sub_module_parameter_value emif_1_ddr4comp INSTANCE_ID {1}
	set_component_sub_module_parameter_value emif_1_ddr4comp PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_1_ddr5comp INSTANCE_ID {1}
	set_component_sub_module_parameter_value emif_1_ddr5comp PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_1_ddr5dimm INSTANCE_ID {1}
	set_component_sub_module_parameter_value emif_1_ddr5dimm PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_1_lpddr4 INSTANCE_ID {1}
	set_component_sub_module_parameter_value emif_1_lpddr4 PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value emif_1_lpddr5 INSTANCE_ID {1}
	set_component_sub_module_parameter_value emif_1_lpddr5 PHY_SWIZZLE_MAP {}
	set_component_sub_module_parameter_value refclk_bridge CONNECTIONS {refclk_in\ \ \ \ \ \ \ \ refclk_in_gpio refclk_out_gpio\ \ refclk_out}
	set_component_sub_module_parameter_value refclk_bridge CUSTOM_ELABORATION_COMMANDS {}
	set_component_sub_module_parameter_value refclk_bridge INTERFACES {refclk_in\ \ \ \ \ \ \ \ clock\ \ \ \ sink refclk_out\ \ \ \ \ \ \ clock\ \ \ \ source refclk_in_gpio\ \ \ conduit\ \ end refclk_out_gpio\ \ conduit\ \ start}
	set_component_sub_module_parameter_value refclk_bridge PORTS {refclk_in\ \ \ \ \ \ \ \ refclk_in\ \ \ \ \ \ \ \ \ clk\ \ \ \ \ \ input\ \ \ \ 1 refclk_out\ \ \ \ \ \ \ refclk_out\ \ \ \ \ \ \ \ clk\ \ \ \ \ \ output\ \ \ 1 refclk_in_gpio\ \ \ refclk_in_gpio\ \ \ \ export\ \ \ output\ \ \ 1 refclk_out_gpio\ \ refclk_out_gpio\ \ \ export\ \ \ input\ \ \ \ 1}
	save_component
	load_instantiation agx5_hps_emif
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface io96b0_to_hps conduit INPUT
	set_instantiation_interface_parameter_value io96b0_to_hps associatedClock {}
	set_instantiation_interface_parameter_value io96b0_to_hps associatedReset {}
	set_instantiation_interface_parameter_value io96b0_to_hps prSafe {false}
	add_instantiation_interface_port io96b0_to_hps noc_aclk_0 axi4_ch0_clk 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps noc_rst_n_0 axi4_ch0_reset_n 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_clock ch0_axil_clk 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_reset_n ch0_axil_reset_n 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_awaddr ch0_axil_awaddr 27 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_awvalid ch0_axil_awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_awready ch0_axil_awready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_araddr ch0_axil_araddr 27 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_arvalid ch0_axil_arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_arready ch0_axil_arready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_wdata ch0_axil_wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_wvalid ch0_axil_wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_wready ch0_axil_wready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_rresp ch0_axil_rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_rdata ch0_axil_rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_rvalid ch0_axil_rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_rready ch0_axil_rready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_bresp ch0_axil_bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_bvalid ch0_axil_bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_bready ch0_axil_bready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_awprot ch0_axil_awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_wstrb ch0_axil_wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_noc_axi4lite_arprot ch0_axil_arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awaddr axi4_ch0_awaddr 40 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awburst axi4_ch0_awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awid axi4_ch0_awid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awlen axi4_ch0_awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awlock axi4_ch0_awlock 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awqos axi4_ch0_awqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awsize axi4_ch0_awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awvalid axi4_ch0_awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awuser axi4_ch0_awuser 14 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awprot axi4_ch0_awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_awready axi4_ch0_awready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_araddr axi4_ch0_araddr 40 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arburst axi4_ch0_arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arid axi4_ch0_arid 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arlen axi4_ch0_arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arlock axi4_ch0_arlock 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arqos axi4_ch0_arqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arsize axi4_ch0_arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arvalid axi4_ch0_arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_aruser axi4_ch0_aruser 14 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arprot axi4_ch0_arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_arready axi4_ch0_arready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_wdata axi4_ch0_wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_wstrb axi4_ch0_wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_wlast axi4_ch0_wlast 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_wvalid axi4_ch0_wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_wready axi4_ch0_wready 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_bready axi4_ch0_bready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_bid axi4_ch0_bid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_bresp axi4_ch0_bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_bvalid axi4_ch0_bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_rready axi4_ch0_rready 1 STD_LOGIC Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_rdata axi4_ch0_rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_rid axi4_ch0_rid 7 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_rlast axi4_ch0_rlast 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_rresp axi4_ch0_rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_rvalid axi4_ch0_rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port io96b0_to_hps s0_axi4_wuser axi4_ch0_wuser 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port io96b0_to_hps s0_axi4_ruser axi4_ch0_ruser 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface mem_0 conduit INPUT
	set_instantiation_interface_parameter_value mem_0 associatedClock {}
	set_instantiation_interface_parameter_value mem_0 associatedReset {}
	set_instantiation_interface_parameter_value mem_0 prSafe {false}
	add_instantiation_interface_port mem_0 mem_0_cke mem_cke 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_odt mem_odt 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_cs_n mem_cs_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_a mem_a 17 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_ba mem_ba 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_bg mem_bg 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_0 mem_0_act_n mem_act_n 1 STD_LOGIC Output
	add_instantiation_interface_port mem_0 mem_0_par mem_par 1 STD_LOGIC Output
	add_instantiation_interface_port mem_0 mem_0_dq mem_dq 32 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_0 mem_0_dqs_t mem_dqs_t 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_0 mem_0_dqs_c mem_dqs_c 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_0 mem_0_alert_n mem_alert_n 1 STD_LOGIC Input
	add_instantiation_interface mem_ck_0 conduit INPUT
	set_instantiation_interface_parameter_value mem_ck_0 associatedClock {}
	set_instantiation_interface_parameter_value mem_ck_0 associatedReset {}
	set_instantiation_interface_parameter_value mem_ck_0 prSafe {false}
	add_instantiation_interface_port mem_ck_0 mem_0_ck_t mem_ck_t 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_ck_0 mem_0_ck_c mem_ck_c 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface mem_reset_n conduit INPUT
	set_instantiation_interface_parameter_value mem_reset_n associatedClock {}
	set_instantiation_interface_parameter_value mem_reset_n associatedReset {}
	set_instantiation_interface_parameter_value mem_reset_n prSafe {false}
	add_instantiation_interface_port mem_reset_n mem_0_reset_n mem_reset_n 1 STD_LOGIC Output
	add_instantiation_interface oct_0 conduit INPUT
	set_instantiation_interface_parameter_value oct_0 associatedClock {}
	set_instantiation_interface_parameter_value oct_0 associatedReset {}
	set_instantiation_interface_parameter_value oct_0 prSafe {false}
	add_instantiation_interface_port oct_0 oct_rzqin_0 oct_rzqin 1 STD_LOGIC Input
	add_instantiation_interface ref_clk clock INPUT
	set_instantiation_interface_parameter_value ref_clk clockRate {0}
	set_instantiation_interface_parameter_value ref_clk externallyDriven {false}
	set_instantiation_interface_parameter_value ref_clk ptfSchematicName {}
	add_instantiation_interface_port ref_clk ref_clk clk 1 STD_LOGIC Input
	save_instantiation
	add_component csr_bridge ip/hps/hps_csr_bridge_0.ip altera_avalon_mm_bridge csr_bridge
	load_component csr_bridge
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {16}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {8}
	set_component_parameter_value MAX_PENDING_RESPONSES {8}
	set_component_parameter_value MAX_PENDING_WRITES {0}
	set_component_parameter_value PIPELINE_COMMAND {1}
	set_component_parameter_value PIPELINE_RESPONSE {1}
	set_component_parameter_value S0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value SYMBOL_WIDTH {8}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_AUTO_ADDRESS_WIDTH {0}
	set_component_parameter_value USE_RESPONSE {0}
	set_component_parameter_value USE_WRITERESPONSE {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation csr_bridge
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clk}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface s0 avalon INPUT
	set_instantiation_interface_parameter_value s0 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s0 addressGroup {0}
	set_instantiation_interface_parameter_value s0 addressSpan {65536}
	set_instantiation_interface_parameter_value s0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clk}
	set_instantiation_interface_parameter_value s0 associatedReset {reset}
	set_instantiation_interface_parameter_value s0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s0 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {m0}
	set_instantiation_interface_parameter_value s0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s0 holdTime {0}
	set_instantiation_interface_parameter_value s0 interleaveBursts {false}
	set_instantiation_interface_parameter_value s0 isBigEndian {false}
	set_instantiation_interface_parameter_value s0 isFlash {false}
	set_instantiation_interface_parameter_value s0 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s0 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s0 linewrapBursts {false}
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {8}
	set_instantiation_interface_parameter_value s0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s0 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s0 prSafe {false}
	set_instantiation_interface_parameter_value s0 printableDevice {false}
	set_instantiation_interface_parameter_value s0 readLatency {0}
	set_instantiation_interface_parameter_value s0 readWaitStates {0}
	set_instantiation_interface_parameter_value s0 readWaitTime {0}
	set_instantiation_interface_parameter_value s0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s0 setupTime {0}
	set_instantiation_interface_parameter_value s0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s0 transparentBridge {false}
	set_instantiation_interface_parameter_value s0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s0 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s0 writeLatency {0}
	set_instantiation_interface_parameter_value s0 writeWaitStates {0}
	set_instantiation_interface_parameter_value s0 writeWaitTime {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_burstcount burstcount 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_address address 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_write write 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_read read 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_debugaccess debugaccess 1 STD_LOGIC Input
	add_instantiation_interface m0 avalon OUTPUT
	set_instantiation_interface_parameter_value m0 adaptsTo {}
	set_instantiation_interface_parameter_value m0 addressGroup {0}
	set_instantiation_interface_parameter_value m0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value m0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {reset}
	set_instantiation_interface_parameter_value m0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value m0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value m0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value m0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value m0 dBSBigEndian {false}
	set_instantiation_interface_parameter_value m0 doStreamReads {false}
	set_instantiation_interface_parameter_value m0 doStreamWrites {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 holdTime {0}
	set_instantiation_interface_parameter_value m0 interleaveBursts {false}
	set_instantiation_interface_parameter_value m0 isAsynchronous {false}
	set_instantiation_interface_parameter_value m0 isBigEndian {false}
	set_instantiation_interface_parameter_value m0 isReadable {false}
	set_instantiation_interface_parameter_value m0 isWriteable {false}
	set_instantiation_interface_parameter_value m0 linewrapBursts {false}
	set_instantiation_interface_parameter_value m0 maxAddressWidth {32}
	set_instantiation_interface_parameter_value m0 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value m0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value m0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value m0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value m0 optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value m0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value m0 writeWaitTime {0}
	add_instantiation_interface_port m0 m0_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_readdata readdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_burstcount burstcount 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component csr_clk ip/system/system_csr_clk_0.ip altera_clock_bridge csr_clk
	load_component csr_clk
	set_component_parameter_value EXPLICIT_CLOCK_RATE {100000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation csr_clk
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {100000000}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {100000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {100000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component csr_rst ip/hps/hps_reset_bridge_0.ip altera_reset_bridge csr_rst
	load_component csr_rst
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation csr_rst
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_reset reset INPUT
	set_instantiation_interface_parameter_value in_reset associatedClock {clk}
	set_instantiation_interface_parameter_value in_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_reset in_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface out_reset reset OUTPUT
	set_instantiation_interface_parameter_value out_reset associatedClock {clk}
	set_instantiation_interface_parameter_value out_reset associatedDirectReset {in_reset}
	set_instantiation_interface_parameter_value out_reset associatedResetSinks {in_reset}
	set_instantiation_interface_parameter_value out_reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port out_reset out_reset_n reset_n 1 STD_LOGIC Output
	save_instantiation
	add_component f2sdram_adapter_256 ip/hps/hps_f2sdram_adapter_0.ip f2sdram_adapter f2sdram_adapter_0
	load_component f2sdram_adapter_256
	set_component_parameter_value ADDR_WIDTH {37}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation f2sdram_adapter_256
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clock}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface axi4_man axi4 OUTPUT
	set_instantiation_interface_parameter_value axi4_man addressCheck {false}
	set_instantiation_interface_parameter_value axi4_man associatedClock {clock}
	set_instantiation_interface_parameter_value axi4_man associatedReset {reset}
	set_instantiation_interface_parameter_value axi4_man combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value axi4_man dataCheck {false}
	set_instantiation_interface_parameter_value axi4_man enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value axi4_man isTranslator {false}
	set_instantiation_interface_parameter_value axi4_man issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value axi4_man issuesINCRBursts {true}
	set_instantiation_interface_parameter_value axi4_man issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value axi4_man maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value axi4_man maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value axi4_man maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value axi4_man noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value axi4_man optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value axi4_man poison {false}
	set_instantiation_interface_parameter_value axi4_man readIssuingCapability {1}
	set_instantiation_interface_parameter_value axi4_man securityAttribute {false}
	set_instantiation_interface_parameter_value axi4_man traceSignals {false}
	set_instantiation_interface_parameter_value axi4_man trustzoneAware {true}
	set_instantiation_interface_parameter_value axi4_man uniqueIdSupport {false}
	set_instantiation_interface_parameter_value axi4_man userData {false}
	set_instantiation_interface_parameter_value axi4_man wakeupSignals {false}
	set_instantiation_interface_parameter_value axi4_man writeIssuingCapability {1}
	add_instantiation_interface_port axi4_man man_araddr araddr 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arid arid 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arlock arlock 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arqos arqos 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_man man_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_awaddr awaddr 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awid awid 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awlock awlock 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awqos awqos 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_man man_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_bid bid 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_man man_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_rid rid 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_man man_rready rready 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_man man_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_man man_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_man man_aruser aruser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_awuser awuser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_wuser wuser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_buser buser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_arregion arregion 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_man man_ruser ruser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_man man_awregion awregion 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface axi4_sub axi4 INPUT
	set_instantiation_interface_parameter_value axi4_sub addressCheck {false}
	set_instantiation_interface_parameter_value axi4_sub associatedClock {clock}
	set_instantiation_interface_parameter_value axi4_sub associatedReset {reset}
	set_instantiation_interface_parameter_value axi4_sub bridgesToMaster {}
	set_instantiation_interface_parameter_value axi4_sub combinedAcceptanceCapability {1}
	set_instantiation_interface_parameter_value axi4_sub dataCheck {false}
	set_instantiation_interface_parameter_value axi4_sub dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value axi4_sub dfhFeatureId {35}
	set_instantiation_interface_parameter_value axi4_sub dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value axi4_sub dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value axi4_sub dfhFeatureType {3}
	set_instantiation_interface_parameter_value axi4_sub dfhGroupId {0}
	set_instantiation_interface_parameter_value axi4_sub dfhParameterData {}
	set_instantiation_interface_parameter_value axi4_sub dfhParameterDataLength {}
	set_instantiation_interface_parameter_value axi4_sub dfhParameterId {}
	set_instantiation_interface_parameter_value axi4_sub dfhParameterName {}
	set_instantiation_interface_parameter_value axi4_sub dfhParameterVersion {}
	set_instantiation_interface_parameter_value axi4_sub isTranslator {false}
	set_instantiation_interface_parameter_value axi4_sub maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value axi4_sub maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value axi4_sub maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value axi4_sub noNarrowTransfer {false}
	set_instantiation_interface_parameter_value axi4_sub optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value axi4_sub poison {false}
	set_instantiation_interface_parameter_value axi4_sub readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value axi4_sub readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value axi4_sub securityAttribute {false}
	set_instantiation_interface_parameter_value axi4_sub traceSignals {false}
	set_instantiation_interface_parameter_value axi4_sub trustzoneAware {true}
	set_instantiation_interface_parameter_value axi4_sub uniqueIdSupport {false}
	set_instantiation_interface_parameter_value axi4_sub userData {false}
	set_instantiation_interface_parameter_value axi4_sub wakeupSignals {false}
	set_instantiation_interface_parameter_value axi4_sub writeAcceptanceCapability {1}
	set_instantiation_interface_sysinfo_parameter_value axi4_sub address_map {<address-map><slave name='axi4_sub' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value axi4_sub address_width {37}
	set_instantiation_interface_sysinfo_parameter_value axi4_sub max_slave_data_width {256}
	add_instantiation_interface_port axi4_sub sub_araddr araddr 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arcache arcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arid arid 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arlock arlock 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_arprot arprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arqos arqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_sub sub_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_awaddr awaddr 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awcache awcache 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awid awid 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awlock awlock 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_awprot awprot 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awqos awqos 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_sub sub_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_bid bid 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_bresp bresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_sub sub_rdata rdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_rid rid 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_sub sub_rready rready 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_rresp rresp 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_sub sub_wdata wdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_wlast wlast 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port axi4_sub sub_wstrb wstrb 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port axi4_sub sub_aruser aruser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_awuser awuser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_wuser wuser 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_buser buser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_arregion arregion 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port axi4_sub sub_ruser ruser 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port axi4_sub sub_awregion awregion 4 STD_LOGIC_VECTOR Input
	save_instantiation
	add_component msgdma2axi4_256_f ip/hps/hps_msgdma2axi4_0.ip msgdma2axi4 msgdma2axi4_256_0
	load_component msgdma2axi4_256_f
	set_component_parameter_value ADDR_WIDTH {37}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value ENABLE_S0_READ {1}
	set_component_parameter_value ENABLE_S1_WRITE {1}
	set_component_parameter_value MAX_BURST_COUNT {128}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation msgdma2axi4_256_f
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clock}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface s0 avalon INPUT
	set_instantiation_interface_parameter_value s0 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s0 addressGroup {0}
	set_instantiation_interface_parameter_value s0 addressSpan {137438953472}
	set_instantiation_interface_parameter_value s0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clock}
	set_instantiation_interface_parameter_value s0 associatedReset {reset}
	set_instantiation_interface_parameter_value s0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s0 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {}
	set_instantiation_interface_parameter_value s0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s0 holdTime {0}
	set_instantiation_interface_parameter_value s0 interleaveBursts {false}
	set_instantiation_interface_parameter_value s0 isBigEndian {false}
	set_instantiation_interface_parameter_value s0 isFlash {false}
	set_instantiation_interface_parameter_value s0 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s0 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s0 linewrapBursts {false}
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {16}
	set_instantiation_interface_parameter_value s0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s0 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s0 prSafe {false}
	set_instantiation_interface_parameter_value s0 printableDevice {false}
	set_instantiation_interface_parameter_value s0 readLatency {0}
	set_instantiation_interface_parameter_value s0 readWaitStates {1}
	set_instantiation_interface_parameter_value s0 readWaitTime {1}
	set_instantiation_interface_parameter_value s0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s0 setupTime {0}
	set_instantiation_interface_parameter_value s0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s0 transparentBridge {false}
	set_instantiation_interface_parameter_value s0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s0 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s0 writeLatency {0}
	set_instantiation_interface_parameter_value s0 writeWaitStates {0}
	set_instantiation_interface_parameter_value s0 writeWaitTime {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {<address-map><slave name='s0' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {37}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {256}
	add_instantiation_interface_port s0 s0_read_address address 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_read_read read 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_read_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_read_readdata readdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_read_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_read_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_read_burstcount burstcount 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface s1 avalon INPUT
	set_instantiation_interface_parameter_value s1 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s1 addressGroup {0}
	set_instantiation_interface_parameter_value s1 addressSpan {137438953472}
	set_instantiation_interface_parameter_value s1 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s1 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s1 associatedClock {clock}
	set_instantiation_interface_parameter_value s1 associatedReset {reset}
	set_instantiation_interface_parameter_value s1 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s1 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s1 bridgesToMaster {}
	set_instantiation_interface_parameter_value s1 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s1 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s1 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s1 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s1 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s1 dfhGroupId {0}
	set_instantiation_interface_parameter_value s1 dfhParameterData {}
	set_instantiation_interface_parameter_value s1 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s1 dfhParameterId {}
	set_instantiation_interface_parameter_value s1 dfhParameterName {}
	set_instantiation_interface_parameter_value s1 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s1 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s1 holdTime {0}
	set_instantiation_interface_parameter_value s1 interleaveBursts {false}
	set_instantiation_interface_parameter_value s1 isBigEndian {false}
	set_instantiation_interface_parameter_value s1 isFlash {false}
	set_instantiation_interface_parameter_value s1 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s1 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s1 linewrapBursts {false}
	set_instantiation_interface_parameter_value s1 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value s1 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s1 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s1 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s1 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s1 prSafe {false}
	set_instantiation_interface_parameter_value s1 printableDevice {false}
	set_instantiation_interface_parameter_value s1 readLatency {0}
	set_instantiation_interface_parameter_value s1 readWaitStates {1}
	set_instantiation_interface_parameter_value s1 readWaitTime {1}
	set_instantiation_interface_parameter_value s1 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s1 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s1 setupTime {0}
	set_instantiation_interface_parameter_value s1 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s1 transparentBridge {false}
	set_instantiation_interface_parameter_value s1 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s1 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s1 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s1 writeLatency {0}
	set_instantiation_interface_parameter_value s1 writeWaitStates {0}
	set_instantiation_interface_parameter_value s1 writeWaitTime {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s1 address_map {<address-map><slave name='s1' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s1 address_width {37}
	set_instantiation_interface_sysinfo_parameter_value s1 max_slave_data_width {256}
	add_instantiation_interface_port s1 s1_write_address address 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 s1_write_write write 1 STD_LOGIC Input
	add_instantiation_interface_port s1 s1_write_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 s1_write_writedata writedata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 s1_write_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s1 s1_write_burstcount burstcount 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clock}
	set_instantiation_interface_parameter_value m0 associatedReset {reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {false}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {false}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {32}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {32}
	add_instantiation_interface_port m0 m0_araddr araddr 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arid arid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arlock arlock 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awid awid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awlock awlock 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_bid bid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rid rid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	save_instantiation
	add_component msgdma2axi4_256_h ip/hps/hps_msgdma2axi4_0.ip msgdma2axi4 msgdma2axi4_256_0
	load_component msgdma2axi4_256_h
	set_component_parameter_value ADDR_WIDTH {37}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value ENABLE_S0_READ {1}
	set_component_parameter_value ENABLE_S1_WRITE {1}
	set_component_parameter_value MAX_BURST_COUNT {128}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation msgdma2axi4_256_h
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset reset INPUT
	set_instantiation_interface_parameter_value reset associatedClock {clock}
	set_instantiation_interface_parameter_value reset synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset reset reset 1 STD_LOGIC Input
	add_instantiation_interface s0 avalon INPUT
	set_instantiation_interface_parameter_value s0 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s0 addressGroup {0}
	set_instantiation_interface_parameter_value s0 addressSpan {137438953472}
	set_instantiation_interface_parameter_value s0 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s0 associatedClock {clock}
	set_instantiation_interface_parameter_value s0 associatedReset {reset}
	set_instantiation_interface_parameter_value s0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s0 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s0 bridgesToMaster {}
	set_instantiation_interface_parameter_value s0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s0 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s0 dfhGroupId {0}
	set_instantiation_interface_parameter_value s0 dfhParameterData {}
	set_instantiation_interface_parameter_value s0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s0 dfhParameterId {}
	set_instantiation_interface_parameter_value s0 dfhParameterName {}
	set_instantiation_interface_parameter_value s0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s0 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s0 holdTime {0}
	set_instantiation_interface_parameter_value s0 interleaveBursts {false}
	set_instantiation_interface_parameter_value s0 isBigEndian {false}
	set_instantiation_interface_parameter_value s0 isFlash {false}
	set_instantiation_interface_parameter_value s0 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s0 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s0 linewrapBursts {false}
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {16}
	set_instantiation_interface_parameter_value s0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s0 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s0 prSafe {false}
	set_instantiation_interface_parameter_value s0 printableDevice {false}
	set_instantiation_interface_parameter_value s0 readLatency {0}
	set_instantiation_interface_parameter_value s0 readWaitStates {1}
	set_instantiation_interface_parameter_value s0 readWaitTime {1}
	set_instantiation_interface_parameter_value s0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s0 setupTime {0}
	set_instantiation_interface_parameter_value s0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s0 transparentBridge {false}
	set_instantiation_interface_parameter_value s0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s0 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s0 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s0 writeLatency {0}
	set_instantiation_interface_parameter_value s0 writeWaitStates {0}
	set_instantiation_interface_parameter_value s0 writeWaitTime {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s0 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {<address-map><slave name='s0' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {37}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {256}
	add_instantiation_interface_port s0 s0_read_address address 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_read_read read 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_read_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_read_readdata readdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_read_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_read_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_read_burstcount burstcount 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface s1 avalon INPUT
	set_instantiation_interface_parameter_value s1 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s1 addressGroup {0}
	set_instantiation_interface_parameter_value s1 addressSpan {137438953472}
	set_instantiation_interface_parameter_value s1 addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value s1 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s1 associatedClock {clock}
	set_instantiation_interface_parameter_value s1 associatedReset {reset}
	set_instantiation_interface_parameter_value s1 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s1 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s1 bridgesToMaster {}
	set_instantiation_interface_parameter_value s1 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s1 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s1 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s1 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s1 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s1 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s1 dfhGroupId {0}
	set_instantiation_interface_parameter_value s1 dfhParameterData {}
	set_instantiation_interface_parameter_value s1 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s1 dfhParameterId {}
	set_instantiation_interface_parameter_value s1 dfhParameterName {}
	set_instantiation_interface_parameter_value s1 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s1 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value s1 holdTime {0}
	set_instantiation_interface_parameter_value s1 interleaveBursts {false}
	set_instantiation_interface_parameter_value s1 isBigEndian {false}
	set_instantiation_interface_parameter_value s1 isFlash {false}
	set_instantiation_interface_parameter_value s1 isMemoryDevice {false}
	set_instantiation_interface_parameter_value s1 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s1 linewrapBursts {false}
	set_instantiation_interface_parameter_value s1 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value s1 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s1 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s1 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s1 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s1 prSafe {false}
	set_instantiation_interface_parameter_value s1 printableDevice {false}
	set_instantiation_interface_parameter_value s1 readLatency {0}
	set_instantiation_interface_parameter_value s1 readWaitStates {1}
	set_instantiation_interface_parameter_value s1 readWaitTime {1}
	set_instantiation_interface_parameter_value s1 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s1 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s1 setupTime {0}
	set_instantiation_interface_parameter_value s1 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s1 transparentBridge {false}
	set_instantiation_interface_parameter_value s1 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s1 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s1 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s1 writeLatency {0}
	set_instantiation_interface_parameter_value s1 writeWaitStates {0}
	set_instantiation_interface_parameter_value s1 writeWaitTime {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s1 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s1 address_map {<address-map><slave name='s1' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s1 address_width {37}
	set_instantiation_interface_sysinfo_parameter_value s1 max_slave_data_width {256}
	add_instantiation_interface_port s1 s1_write_address address 37 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 s1_write_write write 1 STD_LOGIC Input
	add_instantiation_interface_port s1 s1_write_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 s1_write_writedata writedata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 s1_write_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port s1 s1_write_burstcount burstcount 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clock}
	set_instantiation_interface_parameter_value m0 associatedReset {reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {64}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {false}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {false}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {32}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {32}
	add_instantiation_interface_port m0 m0_araddr araddr 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arburst arburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arcache arcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arid arid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arlen arlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arlock arlock 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_arsize arsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 37 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awburst awburst 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awcache awcache 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awid awid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awlen awlen 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awlock awlock 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_awsize awsize 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_bid bid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_bresp bresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rdata rdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rid rid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rlast rlast 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_rresp rresp 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wstrb wstrb 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	save_instantiation
	add_component msgdma_256 ip/hps/hps_msgdma_0.ip altera_msgdma msgdma_256
	load_component msgdma_256
	set_component_parameter_value BURST_ENABLE {1}
	set_component_parameter_value BURST_WRAPPING_SUPPORT {0}
	set_component_parameter_value CHANNEL_ENABLE {0}
	set_component_parameter_value CHANNEL_WIDTH {8}
	set_component_parameter_value DATA_FIFO_DEPTH {128}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value DESCRIPTOR_FIFO_DEPTH {128}
	set_component_parameter_value ENHANCED_FEATURES {1}
	set_component_parameter_value ERROR_ENABLE {0}
	set_component_parameter_value ERROR_WIDTH {8}
	set_component_parameter_value EXPOSE_ST_PORT {0}
	set_component_parameter_value FIX_ADDRESS_WIDTH {38}
	set_component_parameter_value MAX_BURST_COUNT {16}
	set_component_parameter_value MAX_BYTE {2147483647}
	set_component_parameter_value MAX_STRIDE {1}
	set_component_parameter_value MODE {0}
	set_component_parameter_value NO_BYTEENABLES {0}
	set_component_parameter_value PACKET_ENABLE {0}
	set_component_parameter_value PREFETCHER_DATA_WIDTH {32}
	set_component_parameter_value PREFETCHER_ENABLE {0}
	set_component_parameter_value PREFETCHER_MAX_READ_BURST_COUNT {2}
	set_component_parameter_value PREFETCHER_READ_BURST_ENABLE {0}
	set_component_parameter_value PROGRAMMABLE_BURST_ENABLE {0}
	set_component_parameter_value RESPONSE_PORT {2}
	set_component_parameter_value SIDEBAND_ENABLE {0}
	set_component_parameter_value STRIDE_ENABLE {0}
	set_component_parameter_value TRANSFER_TYPE {Full Word Accesses Only}
	set_component_parameter_value USE_FIX_ADDRESS_WIDTH {1}
	set_component_parameter_value WRITE_RESPONSE_ENABLE {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation msgdma_256
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_ENABLE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_WRAPPING_SUPPORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {256}
	set_instantiation_assignment_value embeddedsw.CMacro.DESCRIPTOR_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DMA_MODE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ENHANCED_FEATURES {1}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BURST_COUNT {16}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BYTE {2147483647}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_STRIDE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PREFETCHER_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PROGRAMMABLE_BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.RESPONSE_PORT {2}
	set_instantiation_assignment_value embeddedsw.CMacro.SIDEBAND_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.STRIDE_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.STRIDE_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.TRANSFER_TYPE {Full Word Accesses Only}
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,msgdma-1.0}
	set_instantiation_assignment_value embeddedsw.dts.group {msgdma}
	set_instantiation_assignment_value embeddedsw.dts.name {msgdma}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clock_clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset_n reset INPUT
	set_instantiation_interface_parameter_value reset_n associatedClock {clock}
	set_instantiation_interface_parameter_value reset_n synchronousEdges {BOTH}
	add_instantiation_interface_port reset_n reset_n_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface csr avalon INPUT
	set_instantiation_interface_parameter_value csr addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value csr addressGroup {0}
	set_instantiation_interface_parameter_value csr addressSpan {32}
	set_instantiation_interface_parameter_value csr addressUnits {WORDS}
	set_instantiation_interface_parameter_value csr alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value csr associatedClock {clock}
	set_instantiation_interface_parameter_value csr associatedReset {reset_n}
	set_instantiation_interface_parameter_value csr bitsPerSymbol {8}
	set_instantiation_interface_parameter_value csr bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value csr bridgesToMaster {}
	set_instantiation_interface_parameter_value csr burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value csr burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value csr constantBurstBehavior {false}
	set_instantiation_interface_parameter_value csr dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value csr dfhFeatureId {35}
	set_instantiation_interface_parameter_value csr dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value csr dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value csr dfhFeatureType {3}
	set_instantiation_interface_parameter_value csr dfhGroupId {0}
	set_instantiation_interface_parameter_value csr dfhParameterData {}
	set_instantiation_interface_parameter_value csr dfhParameterDataLength {}
	set_instantiation_interface_parameter_value csr dfhParameterId {}
	set_instantiation_interface_parameter_value csr dfhParameterName {}
	set_instantiation_interface_parameter_value csr dfhParameterVersion {}
	set_instantiation_interface_parameter_value csr explicitAddressSpan {0}
	set_instantiation_interface_parameter_value csr holdTime {0}
	set_instantiation_interface_parameter_value csr interleaveBursts {false}
	set_instantiation_interface_parameter_value csr isBigEndian {false}
	set_instantiation_interface_parameter_value csr isFlash {false}
	set_instantiation_interface_parameter_value csr isMemoryDevice {false}
	set_instantiation_interface_parameter_value csr isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value csr linewrapBursts {false}
	set_instantiation_interface_parameter_value csr maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value csr maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value csr minimumReadLatency {1}
	set_instantiation_interface_parameter_value csr minimumResponseLatency {1}
	set_instantiation_interface_parameter_value csr minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value csr prSafe {false}
	set_instantiation_interface_parameter_value csr printableDevice {false}
	set_instantiation_interface_parameter_value csr readLatency {1}
	set_instantiation_interface_parameter_value csr readWaitStates {1}
	set_instantiation_interface_parameter_value csr readWaitTime {1}
	set_instantiation_interface_parameter_value csr registerIncomingSignals {false}
	set_instantiation_interface_parameter_value csr registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value csr setupTime {0}
	set_instantiation_interface_parameter_value csr timingUnits {Cycles}
	set_instantiation_interface_parameter_value csr transparentBridge {false}
	set_instantiation_interface_parameter_value csr waitrequestAllowance {0}
	set_instantiation_interface_parameter_value csr waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value csr wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value csr writeLatency {0}
	set_instantiation_interface_parameter_value csr writeWaitStates {0}
	set_instantiation_interface_parameter_value csr writeWaitTime {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value csr address_map {<address-map><slave name='csr' start='0x0' end='0x20' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value csr address_width {5}
	set_instantiation_interface_sysinfo_parameter_value csr max_slave_data_width {32}
	add_instantiation_interface_port csr csr_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_write write 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr csr_read read 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_address address 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface descriptor_slave avalon INPUT
	set_instantiation_interface_parameter_value descriptor_slave addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value descriptor_slave addressGroup {0}
	set_instantiation_interface_parameter_value descriptor_slave addressSpan {32}
	set_instantiation_interface_parameter_value descriptor_slave addressUnits {WORDS}
	set_instantiation_interface_parameter_value descriptor_slave alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value descriptor_slave associatedClock {clock}
	set_instantiation_interface_parameter_value descriptor_slave associatedReset {reset_n}
	set_instantiation_interface_parameter_value descriptor_slave bitsPerSymbol {8}
	set_instantiation_interface_parameter_value descriptor_slave bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value descriptor_slave bridgesToMaster {}
	set_instantiation_interface_parameter_value descriptor_slave burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value descriptor_slave burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value descriptor_slave constantBurstBehavior {false}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureId {35}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureType {3}
	set_instantiation_interface_parameter_value descriptor_slave dfhGroupId {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterData {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterDataLength {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterId {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterName {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterVersion {}
	set_instantiation_interface_parameter_value descriptor_slave explicitAddressSpan {0}
	set_instantiation_interface_parameter_value descriptor_slave holdTime {0}
	set_instantiation_interface_parameter_value descriptor_slave interleaveBursts {false}
	set_instantiation_interface_parameter_value descriptor_slave isBigEndian {false}
	set_instantiation_interface_parameter_value descriptor_slave isFlash {false}
	set_instantiation_interface_parameter_value descriptor_slave isMemoryDevice {false}
	set_instantiation_interface_parameter_value descriptor_slave isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value descriptor_slave linewrapBursts {false}
	set_instantiation_interface_parameter_value descriptor_slave maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value descriptor_slave maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value descriptor_slave minimumReadLatency {1}
	set_instantiation_interface_parameter_value descriptor_slave minimumResponseLatency {1}
	set_instantiation_interface_parameter_value descriptor_slave minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value descriptor_slave prSafe {false}
	set_instantiation_interface_parameter_value descriptor_slave printableDevice {false}
	set_instantiation_interface_parameter_value descriptor_slave readLatency {0}
	set_instantiation_interface_parameter_value descriptor_slave readWaitStates {1}
	set_instantiation_interface_parameter_value descriptor_slave readWaitTime {1}
	set_instantiation_interface_parameter_value descriptor_slave registerIncomingSignals {false}
	set_instantiation_interface_parameter_value descriptor_slave registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value descriptor_slave setupTime {0}
	set_instantiation_interface_parameter_value descriptor_slave timingUnits {Cycles}
	set_instantiation_interface_parameter_value descriptor_slave transparentBridge {false}
	set_instantiation_interface_parameter_value descriptor_slave waitrequestAllowance {0}
	set_instantiation_interface_parameter_value descriptor_slave waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value descriptor_slave wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value descriptor_slave writeLatency {0}
	set_instantiation_interface_parameter_value descriptor_slave writeWaitStates {0}
	set_instantiation_interface_parameter_value descriptor_slave writeWaitTime {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_map {<address-map><slave name='descriptor_slave' start='0x0' end='0x20' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_width {5}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave max_slave_data_width {256}
	add_instantiation_interface_port descriptor_slave descriptor_slave_write write 1 STD_LOGIC Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port descriptor_slave descriptor_slave_writedata writedata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface csr_irq interrupt INPUT
	set_instantiation_interface_parameter_value csr_irq associatedAddressablePoint {csr}
	set_instantiation_interface_parameter_value csr_irq associatedClock {clock}
	set_instantiation_interface_parameter_value csr_irq associatedReset {reset_n}
	set_instantiation_interface_parameter_value csr_irq bridgedReceiverOffset {0}
	set_instantiation_interface_parameter_value csr_irq bridgesToReceiver {}
	set_instantiation_interface_parameter_value csr_irq irqScheme {NONE}
	add_instantiation_interface_port csr_irq csr_irq_irq irq 1 STD_LOGIC Output
	add_instantiation_interface mm_read avalon OUTPUT
	set_instantiation_interface_parameter_value mm_read adaptsTo {}
	set_instantiation_interface_parameter_value mm_read addressGroup {0}
	set_instantiation_interface_parameter_value mm_read addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value mm_read alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value mm_read associatedClock {clock}
	set_instantiation_interface_parameter_value mm_read associatedReset {reset_n}
	set_instantiation_interface_parameter_value mm_read bitsPerSymbol {8}
	set_instantiation_interface_parameter_value mm_read burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value mm_read burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value mm_read constantBurstBehavior {false}
	set_instantiation_interface_parameter_value mm_read dBSBigEndian {false}
	set_instantiation_interface_parameter_value mm_read doStreamReads {false}
	set_instantiation_interface_parameter_value mm_read doStreamWrites {false}
	set_instantiation_interface_parameter_value mm_read enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value mm_read holdTime {0}
	set_instantiation_interface_parameter_value mm_read interleaveBursts {false}
	set_instantiation_interface_parameter_value mm_read isAsynchronous {false}
	set_instantiation_interface_parameter_value mm_read isBigEndian {false}
	set_instantiation_interface_parameter_value mm_read isReadable {false}
	set_instantiation_interface_parameter_value mm_read isWriteable {false}
	set_instantiation_interface_parameter_value mm_read linewrapBursts {false}
	set_instantiation_interface_parameter_value mm_read maxAddressWidth {32}
	set_instantiation_interface_parameter_value mm_read maximumPendingReadTransactions {16}
	set_instantiation_interface_parameter_value mm_read maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value mm_read minimumReadLatency {1}
	set_instantiation_interface_parameter_value mm_read minimumResponseLatency {1}
	set_instantiation_interface_parameter_value mm_read optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value mm_read prSafe {false}
	set_instantiation_interface_parameter_value mm_read readLatency {0}
	set_instantiation_interface_parameter_value mm_read readWaitTime {1}
	set_instantiation_interface_parameter_value mm_read registerIncomingSignals {false}
	set_instantiation_interface_parameter_value mm_read registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value mm_read setupTime {0}
	set_instantiation_interface_parameter_value mm_read timingUnits {Cycles}
	set_instantiation_interface_parameter_value mm_read waitrequestAllowance {0}
	set_instantiation_interface_parameter_value mm_read waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value mm_read writeWaitTime {0}
	add_instantiation_interface_port mm_read mm_read_address address 38 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_read read 1 STD_LOGIC Output
	add_instantiation_interface_port mm_read mm_read_byteenable byteenable 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_readdata readdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mm_read mm_read_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_read mm_read_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port mm_read mm_read_burstcount burstcount 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface mm_write avalon OUTPUT
	set_instantiation_interface_parameter_value mm_write adaptsTo {}
	set_instantiation_interface_parameter_value mm_write addressGroup {0}
	set_instantiation_interface_parameter_value mm_write addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value mm_write alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value mm_write associatedClock {clock}
	set_instantiation_interface_parameter_value mm_write associatedReset {reset_n}
	set_instantiation_interface_parameter_value mm_write bitsPerSymbol {8}
	set_instantiation_interface_parameter_value mm_write burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value mm_write burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value mm_write constantBurstBehavior {false}
	set_instantiation_interface_parameter_value mm_write dBSBigEndian {false}
	set_instantiation_interface_parameter_value mm_write doStreamReads {false}
	set_instantiation_interface_parameter_value mm_write doStreamWrites {false}
	set_instantiation_interface_parameter_value mm_write enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value mm_write holdTime {0}
	set_instantiation_interface_parameter_value mm_write interleaveBursts {false}
	set_instantiation_interface_parameter_value mm_write isAsynchronous {false}
	set_instantiation_interface_parameter_value mm_write isBigEndian {false}
	set_instantiation_interface_parameter_value mm_write isReadable {false}
	set_instantiation_interface_parameter_value mm_write isWriteable {false}
	set_instantiation_interface_parameter_value mm_write linewrapBursts {false}
	set_instantiation_interface_parameter_value mm_write maxAddressWidth {32}
	set_instantiation_interface_parameter_value mm_write maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value mm_write maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value mm_write minimumReadLatency {1}
	set_instantiation_interface_parameter_value mm_write minimumResponseLatency {1}
	set_instantiation_interface_parameter_value mm_write optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value mm_write prSafe {false}
	set_instantiation_interface_parameter_value mm_write readLatency {0}
	set_instantiation_interface_parameter_value mm_write readWaitTime {1}
	set_instantiation_interface_parameter_value mm_write registerIncomingSignals {false}
	set_instantiation_interface_parameter_value mm_write registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value mm_write setupTime {0}
	set_instantiation_interface_parameter_value mm_write timingUnits {Cycles}
	set_instantiation_interface_parameter_value mm_write waitrequestAllowance {0}
	set_instantiation_interface_parameter_value mm_write waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value mm_write writeWaitTime {0}
	add_instantiation_interface_port mm_write mm_write_address address 38 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_write write 1 STD_LOGIC Output
	add_instantiation_interface_port mm_write mm_write_byteenable byteenable 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_writedata writedata 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_write mm_write_burstcount burstcount 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_response response 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mm_write mm_write_writeresponsevalid writeresponsevalid 1 STD_LOGIC Input
	save_instantiation
	add_component msgdma_streaming_256 ip/hps/hps_msgdma_streaming_0.ip altera_msgdma msgdma_streaming_256
	load_component msgdma_streaming_256
	set_component_parameter_value BURST_ENABLE {1}
	set_component_parameter_value BURST_WRAPPING_SUPPORT {0}
	set_component_parameter_value CHANNEL_ENABLE {0}
	set_component_parameter_value CHANNEL_WIDTH {8}
	set_component_parameter_value DATA_FIFO_DEPTH {1024}
	set_component_parameter_value DATA_WIDTH {256}
	set_component_parameter_value DESCRIPTOR_FIFO_DEPTH {128}
	set_component_parameter_value ENHANCED_FEATURES {1}
	set_component_parameter_value ERROR_ENABLE {0}
	set_component_parameter_value ERROR_WIDTH {8}
	set_component_parameter_value EXPOSE_ST_PORT {0}
	set_component_parameter_value FIX_ADDRESS_WIDTH {38}
	set_component_parameter_value MAX_BURST_COUNT {8}
	set_component_parameter_value MAX_BYTE {1073741824}
	set_component_parameter_value MAX_STRIDE {1}
	set_component_parameter_value MODE {1}
	set_component_parameter_value NO_BYTEENABLES {0}
	set_component_parameter_value PACKET_ENABLE {0}
	set_component_parameter_value PREFETCHER_DATA_WIDTH {32}
	set_component_parameter_value PREFETCHER_ENABLE {0}
	set_component_parameter_value PREFETCHER_MAX_READ_BURST_COUNT {2}
	set_component_parameter_value PREFETCHER_READ_BURST_ENABLE {0}
	set_component_parameter_value PROGRAMMABLE_BURST_ENABLE {0}
	set_component_parameter_value RESPONSE_PORT {2}
	set_component_parameter_value SIDEBAND_ENABLE {0}
	set_component_parameter_value STRIDE_ENABLE {0}
	set_component_parameter_value TRANSFER_TYPE {Full Word Accesses Only}
	set_component_parameter_value USE_FIX_ADDRESS_WIDTH {1}
	set_component_parameter_value WRITE_RESPONSE_ENABLE {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation msgdma_streaming_256
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_ENABLE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_WRAPPING_SUPPORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_FIFO_DEPTH {1024}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {256}
	set_instantiation_assignment_value embeddedsw.CMacro.DESCRIPTOR_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DMA_MODE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.ENHANCED_FEATURES {1}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BURST_COUNT {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BYTE {1073741824}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_STRIDE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PREFETCHER_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PROGRAMMABLE_BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.RESPONSE_PORT {2}
	set_instantiation_assignment_value embeddedsw.CMacro.SIDEBAND_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.STRIDE_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.STRIDE_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.TRANSFER_TYPE {Full Word Accesses Only}
	set_instantiation_assignment_value embeddedsw.dts.compatible {altr,msgdma-1.0}
	set_instantiation_assignment_value embeddedsw.dts.group {msgdma}
	set_instantiation_assignment_value embeddedsw.dts.name {msgdma}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface clock clock INPUT
	set_instantiation_interface_parameter_value clock clockRate {0}
	set_instantiation_interface_parameter_value clock externallyDriven {false}
	set_instantiation_interface_parameter_value clock ptfSchematicName {}
	add_instantiation_interface_port clock clock_clk clk 1 STD_LOGIC Input
	add_instantiation_interface reset_n reset INPUT
	set_instantiation_interface_parameter_value reset_n associatedClock {clock}
	set_instantiation_interface_parameter_value reset_n synchronousEdges {BOTH}
	add_instantiation_interface_port reset_n reset_n_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface csr avalon INPUT
	set_instantiation_interface_parameter_value csr addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value csr addressGroup {0}
	set_instantiation_interface_parameter_value csr addressSpan {32}
	set_instantiation_interface_parameter_value csr addressUnits {WORDS}
	set_instantiation_interface_parameter_value csr alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value csr associatedClock {clock}
	set_instantiation_interface_parameter_value csr associatedReset {reset_n}
	set_instantiation_interface_parameter_value csr bitsPerSymbol {8}
	set_instantiation_interface_parameter_value csr bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value csr bridgesToMaster {}
	set_instantiation_interface_parameter_value csr burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value csr burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value csr constantBurstBehavior {false}
	set_instantiation_interface_parameter_value csr dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value csr dfhFeatureId {35}
	set_instantiation_interface_parameter_value csr dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value csr dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value csr dfhFeatureType {3}
	set_instantiation_interface_parameter_value csr dfhGroupId {0}
	set_instantiation_interface_parameter_value csr dfhParameterData {}
	set_instantiation_interface_parameter_value csr dfhParameterDataLength {}
	set_instantiation_interface_parameter_value csr dfhParameterId {}
	set_instantiation_interface_parameter_value csr dfhParameterName {}
	set_instantiation_interface_parameter_value csr dfhParameterVersion {}
	set_instantiation_interface_parameter_value csr explicitAddressSpan {0}
	set_instantiation_interface_parameter_value csr holdTime {0}
	set_instantiation_interface_parameter_value csr interleaveBursts {false}
	set_instantiation_interface_parameter_value csr isBigEndian {false}
	set_instantiation_interface_parameter_value csr isFlash {false}
	set_instantiation_interface_parameter_value csr isMemoryDevice {false}
	set_instantiation_interface_parameter_value csr isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value csr linewrapBursts {false}
	set_instantiation_interface_parameter_value csr maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value csr maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value csr minimumReadLatency {1}
	set_instantiation_interface_parameter_value csr minimumResponseLatency {1}
	set_instantiation_interface_parameter_value csr minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value csr prSafe {false}
	set_instantiation_interface_parameter_value csr printableDevice {false}
	set_instantiation_interface_parameter_value csr readLatency {1}
	set_instantiation_interface_parameter_value csr readWaitStates {1}
	set_instantiation_interface_parameter_value csr readWaitTime {1}
	set_instantiation_interface_parameter_value csr registerIncomingSignals {false}
	set_instantiation_interface_parameter_value csr registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value csr setupTime {0}
	set_instantiation_interface_parameter_value csr timingUnits {Cycles}
	set_instantiation_interface_parameter_value csr transparentBridge {false}
	set_instantiation_interface_parameter_value csr waitrequestAllowance {0}
	set_instantiation_interface_parameter_value csr waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value csr wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value csr writeLatency {0}
	set_instantiation_interface_parameter_value csr writeWaitStates {0}
	set_instantiation_interface_parameter_value csr writeWaitTime {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value csr embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value csr address_map {<address-map><slave name='csr' start='0x0' end='0x20' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value csr address_width {5}
	set_instantiation_interface_sysinfo_parameter_value csr max_slave_data_width {32}
	add_instantiation_interface_port csr csr_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_write write 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_byteenable byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port csr csr_readdata readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port csr csr_read read 1 STD_LOGIC Input
	add_instantiation_interface_port csr csr_address address 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface descriptor_slave avalon INPUT
	set_instantiation_interface_parameter_value descriptor_slave addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value descriptor_slave addressGroup {0}
	set_instantiation_interface_parameter_value descriptor_slave addressSpan {32}
	set_instantiation_interface_parameter_value descriptor_slave addressUnits {WORDS}
	set_instantiation_interface_parameter_value descriptor_slave alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value descriptor_slave associatedClock {clock}
	set_instantiation_interface_parameter_value descriptor_slave associatedReset {reset_n}
	set_instantiation_interface_parameter_value descriptor_slave bitsPerSymbol {8}
	set_instantiation_interface_parameter_value descriptor_slave bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value descriptor_slave bridgesToMaster {}
	set_instantiation_interface_parameter_value descriptor_slave burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value descriptor_slave burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value descriptor_slave constantBurstBehavior {false}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureId {35}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhFeatureType {3}
	set_instantiation_interface_parameter_value descriptor_slave dfhGroupId {0}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterData {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterDataLength {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterId {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterName {}
	set_instantiation_interface_parameter_value descriptor_slave dfhParameterVersion {}
	set_instantiation_interface_parameter_value descriptor_slave explicitAddressSpan {0}
	set_instantiation_interface_parameter_value descriptor_slave holdTime {0}
	set_instantiation_interface_parameter_value descriptor_slave interleaveBursts {false}
	set_instantiation_interface_parameter_value descriptor_slave isBigEndian {false}
	set_instantiation_interface_parameter_value descriptor_slave isFlash {false}
	set_instantiation_interface_parameter_value descriptor_slave isMemoryDevice {false}
	set_instantiation_interface_parameter_value descriptor_slave isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value descriptor_slave linewrapBursts {false}
	set_instantiation_interface_parameter_value descriptor_slave maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value descriptor_slave maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value descriptor_slave minimumReadLatency {1}
	set_instantiation_interface_parameter_value descriptor_slave minimumResponseLatency {1}
	set_instantiation_interface_parameter_value descriptor_slave minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value descriptor_slave prSafe {false}
	set_instantiation_interface_parameter_value descriptor_slave printableDevice {false}
	set_instantiation_interface_parameter_value descriptor_slave readLatency {0}
	set_instantiation_interface_parameter_value descriptor_slave readWaitStates {1}
	set_instantiation_interface_parameter_value descriptor_slave readWaitTime {1}
	set_instantiation_interface_parameter_value descriptor_slave registerIncomingSignals {false}
	set_instantiation_interface_parameter_value descriptor_slave registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value descriptor_slave setupTime {0}
	set_instantiation_interface_parameter_value descriptor_slave timingUnits {Cycles}
	set_instantiation_interface_parameter_value descriptor_slave transparentBridge {false}
	set_instantiation_interface_parameter_value descriptor_slave waitrequestAllowance {0}
	set_instantiation_interface_parameter_value descriptor_slave waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value descriptor_slave wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value descriptor_slave writeLatency {0}
	set_instantiation_interface_parameter_value descriptor_slave writeWaitStates {0}
	set_instantiation_interface_parameter_value descriptor_slave writeWaitTime {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isMemoryDevice {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value descriptor_slave embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_map {<address-map><slave name='descriptor_slave' start='0x0' end='0x20' datawidth='256' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_width {5}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave max_slave_data_width {256}
	add_instantiation_interface_port descriptor_slave descriptor_slave_write write 1 STD_LOGIC Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port descriptor_slave descriptor_slave_writedata writedata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_byteenable byteenable 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface csr_irq interrupt INPUT
	set_instantiation_interface_parameter_value csr_irq associatedAddressablePoint {csr}
	set_instantiation_interface_parameter_value csr_irq associatedClock {clock}
	set_instantiation_interface_parameter_value csr_irq associatedReset {reset_n}
	set_instantiation_interface_parameter_value csr_irq bridgedReceiverOffset {0}
	set_instantiation_interface_parameter_value csr_irq bridgesToReceiver {}
	set_instantiation_interface_parameter_value csr_irq irqScheme {NONE}
	add_instantiation_interface_port csr_irq csr_irq_irq irq 1 STD_LOGIC Output
	add_instantiation_interface mm_read avalon OUTPUT
	set_instantiation_interface_parameter_value mm_read adaptsTo {}
	set_instantiation_interface_parameter_value mm_read addressGroup {0}
	set_instantiation_interface_parameter_value mm_read addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value mm_read alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value mm_read associatedClock {clock}
	set_instantiation_interface_parameter_value mm_read associatedReset {reset_n}
	set_instantiation_interface_parameter_value mm_read bitsPerSymbol {8}
	set_instantiation_interface_parameter_value mm_read burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value mm_read burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value mm_read constantBurstBehavior {false}
	set_instantiation_interface_parameter_value mm_read dBSBigEndian {false}
	set_instantiation_interface_parameter_value mm_read doStreamReads {false}
	set_instantiation_interface_parameter_value mm_read doStreamWrites {false}
	set_instantiation_interface_parameter_value mm_read enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value mm_read holdTime {0}
	set_instantiation_interface_parameter_value mm_read interleaveBursts {false}
	set_instantiation_interface_parameter_value mm_read isAsynchronous {false}
	set_instantiation_interface_parameter_value mm_read isBigEndian {false}
	set_instantiation_interface_parameter_value mm_read isReadable {false}
	set_instantiation_interface_parameter_value mm_read isWriteable {false}
	set_instantiation_interface_parameter_value mm_read linewrapBursts {false}
	set_instantiation_interface_parameter_value mm_read maxAddressWidth {32}
	set_instantiation_interface_parameter_value mm_read maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value mm_read maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value mm_read minimumReadLatency {1}
	set_instantiation_interface_parameter_value mm_read minimumResponseLatency {1}
	set_instantiation_interface_parameter_value mm_read optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value mm_read prSafe {false}
	set_instantiation_interface_parameter_value mm_read readLatency {0}
	set_instantiation_interface_parameter_value mm_read readWaitTime {1}
	set_instantiation_interface_parameter_value mm_read registerIncomingSignals {false}
	set_instantiation_interface_parameter_value mm_read registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value mm_read setupTime {0}
	set_instantiation_interface_parameter_value mm_read timingUnits {Cycles}
	set_instantiation_interface_parameter_value mm_read waitrequestAllowance {0}
	set_instantiation_interface_parameter_value mm_read waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value mm_read writeWaitTime {0}
	add_instantiation_interface_port mm_read mm_read_address address 38 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_read read 1 STD_LOGIC Output
	add_instantiation_interface_port mm_read mm_read_byteenable byteenable 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_readdata readdata 256 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mm_read mm_read_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_read mm_read_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port mm_read mm_read_burstcount burstcount 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface st_source avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value st_source associatedClock {clock}
	set_instantiation_interface_parameter_value st_source associatedReset {reset_n}
	set_instantiation_interface_parameter_value st_source beatsPerCycle {1}
	set_instantiation_interface_parameter_value st_source dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value st_source emptyWithinPacket {false}
	set_instantiation_interface_parameter_value st_source errorDescriptor {}
	set_instantiation_interface_parameter_value st_source firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value st_source highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value st_source maxChannel {0}
	set_instantiation_interface_parameter_value st_source packetDescription {}
	set_instantiation_interface_parameter_value st_source prSafe {false}
	set_instantiation_interface_parameter_value st_source readyAllowance {0}
	set_instantiation_interface_parameter_value st_source readyLatency {0}
	set_instantiation_interface_parameter_value st_source symbolsPerBeat {32}
	add_instantiation_interface_port st_source st_source_data data 256 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port st_source st_source_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port st_source st_source_ready ready 1 STD_LOGIC Input
	save_instantiation
	add_component src_prb_rst ip/system/system_src_prb_rst.ip altera_in_system_sources_probes src_prb_rst
	load_component src_prb_rst
	set_component_parameter_value active_low_reset {0}
	set_component_parameter_value create_source_clock {1}
	set_component_parameter_value create_source_clock_enable {0}
	set_component_parameter_value gui_use_auto_index {1}
	set_component_parameter_value instance_id {NONE}
	set_component_parameter_value probe_width {0}
	set_component_parameter_value reset_source {0}
	set_component_parameter_value sld_instance_index {0}
	set_component_parameter_value source_initial_value {1}
	set_component_parameter_value source_width {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation src_prb_rst
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.group {ignore}
	set_instantiation_assignment_value embeddedsw.dts.name {debug}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface sources conduit INPUT
	set_instantiation_interface_parameter_value sources associatedClock {source_clk}
	set_instantiation_interface_parameter_value sources associatedReset {}
	set_instantiation_interface_parameter_value sources prSafe {false}
	add_instantiation_interface_port sources source source 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface source_clk clock INPUT
	set_instantiation_interface_parameter_value source_clk clockRate {0}
	set_instantiation_interface_parameter_value source_clk externallyDriven {false}
	set_instantiation_interface_parameter_value source_clk ptfSchematicName {}
	add_instantiation_interface_port source_clk source_clk clk 1 STD_LOGIC Input
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection agx5_hps.fpga2hps_interrupt_irq0/msgdma_256.csr_irq
	set_connection_parameter_value agx5_hps.fpga2hps_interrupt_irq0/msgdma_256.csr_irq interruptsUsedSysInfo {-1}
	set_connection_parameter_value agx5_hps.fpga2hps_interrupt_irq0/msgdma_256.csr_irq irqNumber {0}
	add_connection agx5_hps.fpga2hps_interrupt_irq0/msgdma_streaming_256.csr_irq
	set_connection_parameter_value agx5_hps.fpga2hps_interrupt_irq0/msgdma_streaming_256.csr_irq interruptsUsedSysInfo {-1}
	set_connection_parameter_value agx5_hps.fpga2hps_interrupt_irq0/msgdma_streaming_256.csr_irq irqNumber {1}
	add_connection agx5_hps.io96b0_to_hps/agx5_hps_emif.io96b0_to_hps
	set_connection_parameter_value agx5_hps.io96b0_to_hps/agx5_hps_emif.io96b0_to_hps endPort {}
	set_connection_parameter_value agx5_hps.io96b0_to_hps/agx5_hps_emif.io96b0_to_hps endPortLSB {0}
	set_connection_parameter_value agx5_hps.io96b0_to_hps/agx5_hps_emif.io96b0_to_hps startPort {}
	set_connection_parameter_value agx5_hps.io96b0_to_hps/agx5_hps_emif.io96b0_to_hps startPortLSB {0}
	set_connection_parameter_value agx5_hps.io96b0_to_hps/agx5_hps_emif.io96b0_to_hps width {0}
	add_connection agx5_hps.lwhps2fpga/csr_bridge.s0
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 addressMapSysInfo {<address-map><slave name='msgdma_256.csr' start='0x0' end='0x20' datawidth='32' /><slave name='msgdma_256.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='msgdma_streaming_256.csr' start='0x1000' end='0x1020' datawidth='32' /><slave name='msgdma_streaming_256.descriptor_slave' start='0x1020' end='0x1040' datawidth='256' /><slave name='csr_bridge.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 addressWidthSysInfo {17}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 arbitrationPriority {1}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 baseAddress {0x00010000}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 defaultConnection {0}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 domainAlias {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/csr_bridge.s0 slaveDataWidthSysInfo {-1}
	add_connection agx5_hps.lwhps2fpga/msgdma_256.csr
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr addressMapSysInfo {<address-map><slave name='msgdma_256.csr' start='0x0' end='0x20' datawidth='32' /><slave name='msgdma_256.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='msgdma_streaming_256.csr' start='0x1000' end='0x1020' datawidth='32' /><slave name='msgdma_streaming_256.descriptor_slave' start='0x1020' end='0x1040' datawidth='256' /><slave name='csr_bridge.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr addressWidthSysInfo {17}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr arbitrationPriority {1}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr baseAddress {0x0000}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr cpuInfoIdSysInfo {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr defaultConnection {0}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr domainAlias {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.fifoDepth {8}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.syncResets {TRUE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.csr slaveDataWidthSysInfo {-1}
	add_connection agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave addressMapSysInfo {<address-map><slave name='msgdma_256.csr' start='0x0' end='0x20' datawidth='32' /><slave name='msgdma_256.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='msgdma_streaming_256.csr' start='0x1000' end='0x1020' datawidth='32' /><slave name='msgdma_streaming_256.descriptor_slave' start='0x1020' end='0x1040' datawidth='256' /><slave name='csr_bridge.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave addressWidthSysInfo {17}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave arbitrationPriority {1}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave baseAddress {0x0020}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave cpuInfoIdSysInfo {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave defaultConnection {0}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave domainAlias {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.fifoDepth {8}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.syncResets {TRUE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_256.descriptor_slave slaveDataWidthSysInfo {-1}
	add_connection agx5_hps.lwhps2fpga/msgdma_streaming_256.csr
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr addressMapSysInfo {<address-map><slave name='msgdma_256.csr' start='0x0' end='0x20' datawidth='32' /><slave name='msgdma_256.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='msgdma_streaming_256.csr' start='0x1000' end='0x1020' datawidth='32' /><slave name='msgdma_streaming_256.descriptor_slave' start='0x1020' end='0x1040' datawidth='256' /><slave name='csr_bridge.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr addressWidthSysInfo {17}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr arbitrationPriority {1}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr baseAddress {0x1000}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr cpuInfoIdSysInfo {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr defaultConnection {0}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr domainAlias {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.fifoDepth {8}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.syncResets {TRUE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.csr slaveDataWidthSysInfo {-1}
	add_connection agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave addressMapSysInfo {<address-map><slave name='msgdma_256.csr' start='0x0' end='0x20' datawidth='32' /><slave name='msgdma_256.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='msgdma_streaming_256.csr' start='0x1000' end='0x1020' datawidth='32' /><slave name='msgdma_streaming_256.descriptor_slave' start='0x1020' end='0x1040' datawidth='256' /><slave name='csr_bridge.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave addressWidthSysInfo {17}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave arbitrationPriority {1}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave baseAddress {0x1020}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave cpuInfoIdSysInfo {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave defaultConnection {0}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave domainAlias {}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.fifoDepth {8}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.syncResets {TRUE}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value agx5_hps.lwhps2fpga/msgdma_streaming_256.descriptor_slave slaveDataWidthSysInfo {-1}
	add_connection csr_clk.out_clk/agx5_hps.f2sdram_axi_clock
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.f2sdram_axi_clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.f2sdram_axi_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.f2sdram_axi_clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.f2sdram_axi_clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/agx5_hps.hps2fpga_axi_clock
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.hps2fpga_axi_clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.hps2fpga_axi_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.hps2fpga_axi_clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.hps2fpga_axi_clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/agx5_hps.lwhps2fpga_axi_clock
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.lwhps2fpga_axi_clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.lwhps2fpga_axi_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.lwhps2fpga_axi_clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/agx5_hps.lwhps2fpga_axi_clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/csr_bridge.clk
	set_connection_parameter_value csr_clk.out_clk/csr_bridge.clk clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/csr_bridge.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/csr_bridge.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/csr_bridge.clk resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/csr_rst.clk
	set_connection_parameter_value csr_clk.out_clk/csr_rst.clk clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/csr_rst.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/csr_rst.clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/csr_rst.clk resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/f2sdram_adapter_256.clock
	set_connection_parameter_value csr_clk.out_clk/f2sdram_adapter_256.clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/f2sdram_adapter_256.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/f2sdram_adapter_256.clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/f2sdram_adapter_256.clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/msgdma2axi4_256_f.clock
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_f.clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_f.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_f.clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_f.clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/msgdma2axi4_256_h.clock
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_h.clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_h.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_h.clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/msgdma2axi4_256_h.clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/msgdma_256.clock
	set_connection_parameter_value csr_clk.out_clk/msgdma_256.clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/msgdma_256.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/msgdma_256.clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/msgdma_256.clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/msgdma_streaming_256.clock
	set_connection_parameter_value csr_clk.out_clk/msgdma_streaming_256.clock clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/msgdma_streaming_256.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/msgdma_streaming_256.clock clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/msgdma_streaming_256.clock resetDomainSysInfo {-1}
	add_connection csr_clk.out_clk/src_prb_rst.source_clk
	set_connection_parameter_value csr_clk.out_clk/src_prb_rst.source_clk clockDomainSysInfo {-1}
	set_connection_parameter_value csr_clk.out_clk/src_prb_rst.source_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value csr_clk.out_clk/src_prb_rst.source_clk clockResetSysInfo {}
	set_connection_parameter_value csr_clk.out_clk/src_prb_rst.source_clk resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/agx5_hps.f2sdram_axi_reset
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.f2sdram_axi_reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.f2sdram_axi_reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.f2sdram_axi_reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/agx5_hps.hps2fpga_axi_reset
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.hps2fpga_axi_reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.hps2fpga_axi_reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.hps2fpga_axi_reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/agx5_hps.lwhps2fpga_axi_reset
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.lwhps2fpga_axi_reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.lwhps2fpga_axi_reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/agx5_hps.lwhps2fpga_axi_reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/csr_bridge.reset
	set_connection_parameter_value csr_rst.out_reset/csr_bridge.reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/csr_bridge.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/csr_bridge.reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/f2sdram_adapter_256.reset
	set_connection_parameter_value csr_rst.out_reset/f2sdram_adapter_256.reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/f2sdram_adapter_256.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/f2sdram_adapter_256.reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/msgdma2axi4_256_f.reset
	set_connection_parameter_value csr_rst.out_reset/msgdma2axi4_256_f.reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/msgdma2axi4_256_f.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/msgdma2axi4_256_f.reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/msgdma2axi4_256_h.reset
	set_connection_parameter_value csr_rst.out_reset/msgdma2axi4_256_h.reset clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/msgdma2axi4_256_h.reset clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/msgdma2axi4_256_h.reset resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/msgdma_256.reset_n
	set_connection_parameter_value csr_rst.out_reset/msgdma_256.reset_n clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/msgdma_256.reset_n clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/msgdma_256.reset_n resetDomainSysInfo {-1}
	add_connection csr_rst.out_reset/msgdma_streaming_256.reset_n
	set_connection_parameter_value csr_rst.out_reset/msgdma_streaming_256.reset_n clockDomainSysInfo {-1}
	set_connection_parameter_value csr_rst.out_reset/msgdma_streaming_256.reset_n clockResetSysInfo {}
	set_connection_parameter_value csr_rst.out_reset/msgdma_streaming_256.reset_n resetDomainSysInfo {-1}
	add_connection f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram addressMapSysInfo {<address-map><slave name='agx5_hps.f2sdram' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram addressWidthSysInfo {37}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram arbitrationPriority {1}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram baseAddress {0x0000}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram cpuInfoIdSysInfo {}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram defaultConnection {0}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram domainAlias {}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.clockCrossingAdapter {AUTO}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.fifoDepth {8}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.syncResets {TRUE}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value f2sdram_adapter_256.axi4_man/agx5_hps.f2sdram slaveDataWidthSysInfo {-1}
	add_connection msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub addressMapSysInfo {<address-map><slave name='f2sdram_adapter_256.axi4_sub' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub addressWidthSysInfo {37}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub arbitrationPriority {1}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub baseAddress {0x0000}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub cpuInfoIdSysInfo {}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub defaultConnection {0}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub domainAlias {}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.fifoDepth {8}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.syncResets {TRUE}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma2axi4_256_h.m0/f2sdram_adapter_256.axi4_sub slaveDataWidthSysInfo {-1}
	add_connection msgdma_256.mm_read/msgdma2axi4_256_f.s0
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 addressMapSysInfo {<address-map><slave name='msgdma2axi4_256_h.s0' start='0x0' end='0x2000000000' datawidth='256' /><slave name='msgdma2axi4_256_f.s0' start='0x2000000000' end='0x4000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 addressWidthSysInfo {38}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 arbitrationPriority {1}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 baseAddress {0x0000002000000000}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 defaultConnection {0}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 domainAlias {}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_f.s0 slaveDataWidthSysInfo {-1}
	add_connection msgdma_256.mm_read/msgdma2axi4_256_h.s0
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 addressMapSysInfo {<address-map><slave name='msgdma2axi4_256_h.s0' start='0x0' end='0x2000000000' datawidth='256' /><slave name='msgdma2axi4_256_f.s0' start='0x2000000000' end='0x4000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 addressWidthSysInfo {38}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 arbitrationPriority {1}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 baseAddress {0x0000}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 defaultConnection {0}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 domainAlias {}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.fifoDepth {8}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_read/msgdma2axi4_256_h.s0 slaveDataWidthSysInfo {-1}
	add_connection msgdma_256.mm_write/msgdma2axi4_256_f.s1
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 addressMapSysInfo {<address-map><slave name='msgdma2axi4_256_h.s1' start='0x0' end='0x2000000000' datawidth='256' /><slave name='msgdma2axi4_256_f.s1' start='0x2000000000' end='0x4000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 addressWidthSysInfo {38}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 arbitrationPriority {1}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 baseAddress {0x0000002000000000}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 defaultConnection {0}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 domainAlias {}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.fifoDepth {8}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_f.s1 slaveDataWidthSysInfo {-1}
	add_connection msgdma_256.mm_write/msgdma2axi4_256_h.s1
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 addressMapSysInfo {<address-map><slave name='msgdma2axi4_256_h.s1' start='0x0' end='0x2000000000' datawidth='256' /><slave name='msgdma2axi4_256_f.s1' start='0x2000000000' end='0x4000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 addressWidthSysInfo {38}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 arbitrationPriority {1}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 baseAddress {0x0000}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 defaultConnection {0}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 domainAlias {}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.fifoDepth {8}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma_256.mm_write/msgdma2axi4_256_h.s1 slaveDataWidthSysInfo {-1}
	add_connection msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub addressMapSysInfo {<address-map><slave name='f2sdram_adapter_256.axi4_sub' start='0x0' end='0x2000000000' datawidth='256' /></address-map>}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub addressWidthSysInfo {37}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub arbitrationPriority {1}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub baseAddress {0x0000}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub cpuInfoIdSysInfo {}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub defaultConnection {0}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub domainAlias {}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.fifoDepth {8}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.splitCommandsFor4KBoundary {FALSE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.syncResets {TRUE}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value msgdma_streaming_256.mm_read/f2sdram_adapter_256.axi4_sub slaveDataWidthSysInfo {-1}

	# add the exports
	set_interface_property agx5_hps_h2f_reset EXPORT_OF agx5_hps.h2f_reset
	set_interface_property hps_to_ddr EXPORT_OF agx5_hps.hps2fpga
	set_interface_property agx5_hps_h2f_warm_reset_handshake EXPORT_OF agx5_hps.h2f_warm_reset_handshake
	set_interface_property hps_io EXPORT_OF agx5_hps.hps_io
	set_interface_property dla_irq EXPORT_OF agx5_hps.fpga2hps_interrupt_irq1
	set_interface_property emif_hps_mem_0 EXPORT_OF agx5_hps_emif.mem_0
	set_interface_property emif_hps_mem_ck_0 EXPORT_OF agx5_hps_emif.mem_ck_0
	set_interface_property emif_hps_mem_reset_n EXPORT_OF agx5_hps_emif.mem_reset_n
	set_interface_property emif_hps_oct_0 EXPORT_OF agx5_hps_emif.oct_0
	set_interface_property emif_hps_ref_clk EXPORT_OF agx5_hps_emif.ref_clk
	set_interface_property hps_to_csr EXPORT_OF csr_bridge.m0
	set_interface_property clk_100_in_clk EXPORT_OF csr_clk.in_clk
	set_interface_property csr_rst_in EXPORT_OF csr_rst.in_reset
	set_interface_property dma_to_ddr EXPORT_OF msgdma2axi4_256_f.m0
	set_interface_property streaming_out EXPORT_OF msgdma_streaming_256.st_source
	set_interface_property src_prb_rst_sources EXPORT_OF src_prb_rst.sources

	# set values for exposed HDL parameters
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.enableAllPipelines FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.enableEccProtection FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.enableInstrumentation FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.fifoDepth 8
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.interconnectType STANDARD
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.maxAdditionalLatency 3
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.syncResets TRUE
	set_domain_assignment agx5_hps.lwhps2fpga qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.clockCrossingAdapter AUTO
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.enableAllPipelines FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.enableEccProtection FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.enableInstrumentation FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.fifoDepth 8
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.interconnectType STANDARD
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.maxAdditionalLatency 1
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.syncResets TRUE
	set_domain_assignment f2sdram_adapter_256.axi4_man qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.enableAllPipelines FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.enableEccProtection FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.enableInstrumentation FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.fifoDepth 8
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.interconnectType STANDARD
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.maxAdditionalLatency 1
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.syncResets TRUE
	set_domain_assignment msgdma2axi4_256_h.m0 qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment msgdma_256.mm_read qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment msgdma_256.mm_read qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment msgdma_256.mm_read qsys_mm.enableAllPipelines FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.enableEccProtection FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.enableInstrumentation FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.fifoDepth 8
	set_domain_assignment msgdma_256.mm_read qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment msgdma_256.mm_read qsys_mm.interconnectType STANDARD
	set_domain_assignment msgdma_256.mm_read qsys_mm.maxAdditionalLatency 3
	set_domain_assignment msgdma_256.mm_read qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment msgdma_256.mm_read qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment msgdma_256.mm_read qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment msgdma_256.mm_read qsys_mm.syncResets TRUE
	set_domain_assignment msgdma_256.mm_read qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment msgdma_256.mm_write qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment msgdma_256.mm_write qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment msgdma_256.mm_write qsys_mm.enableAllPipelines FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.enableEccProtection FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.enableInstrumentation FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.fifoDepth 8
	set_domain_assignment msgdma_256.mm_write qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment msgdma_256.mm_write qsys_mm.interconnectType STANDARD
	set_domain_assignment msgdma_256.mm_write qsys_mm.maxAdditionalLatency 3
	set_domain_assignment msgdma_256.mm_write qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment msgdma_256.mm_write qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment msgdma_256.mm_write qsys_mm.splitCommandsFor4KBoundary FALSE
	set_domain_assignment msgdma_256.mm_write qsys_mm.syncResets TRUE
	set_domain_assignment msgdma_256.mm_write qsys_mm.widthAdapterImplementation GENERIC_CONVERTER

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="agx5_hps">
  <datum __value="_sortIndex" value="3" type="int" />
 </element>
 <element __value="agx5_hps_emif">
  <datum __value="_sortIndex" value="4" type="int" />
 </element>
 <element __value="csr_bridge">
  <datum __value="_sortIndex" value="10" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="csr_bridge.s0">
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="csr_clk">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="csr_rst">
  <datum __value="_sortIndex" value="1" type="int" />
 </element>
 <element __value="f2sdram_adapter_256">
  <datum __value="_sortIndex" value="5" type="int" />
 </element>
 <element __value="msgdma2axi4_256_f">
  <datum __value="_sortIndex" value="8" type="int" />
 </element>
 <element __value="msgdma2axi4_256_f.s0">
  <datum __value="baseAddress" value="137438953472" type="String" />
 </element>
 <element __value="msgdma2axi4_256_f.s1">
  <datum __value="baseAddress" value="137438953472" type="String" />
 </element>
 <element __value="msgdma2axi4_256_h">
  <datum __value="_sortIndex" value="6" type="int" />
 </element>
 <element __value="msgdma_0.response">
  <datum __value="baseAddress" value="65648" type="String" />
 </element>
 <element __value="msgdma_256">
  <datum __value="_sortIndex" value="7" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
 <element __value="msgdma_256.csr">
  <datum __value="baseAddress" value="65568" type="String" />
 </element>
 <element __value="msgdma_256.descriptor_slave">
  <datum __value="baseAddress" value="65600" type="String" />
 </element>
 <element __value="msgdma_streaming_256">
  <datum __value="_sortIndex" value="9" type="int" />
 </element>
 <element __value="msgdma_streaming_256.csr">
  <datum __value="baseAddress" value="4096" type="String" />
 </element>
 <element __value="msgdma_streaming_256.descriptor_slave">
  <datum __value="baseAddress" value="4128" type="String" />
 </element>
 <element __value="src_prb_rst">
  <datum __value="_sortIndex" value="2" type="int" />
  <datum __value="sopceditor_expanded" value="1" type="boolean" />
 </element>
</bonusData>
}
	set_module_property FILE {hps.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {hps}

	# save the system
	sync_sysinfo_parameters
	save_system hps
}

proc do_set_exported_interface_sysinfo_parameters {} {
	load_system dla.qsys
	set_exported_interface_sysinfo_parameter_value csr_clk clock_domain {4}
	set_exported_interface_sysinfo_parameter_value csr_clk clock_rate {100000000}
	set_exported_interface_sysinfo_parameter_value csr_clk reset_domain {4}
	set_exported_interface_sysinfo_parameter_value dla_to_ddr address_map {<address-map><slave name='parent/axi_address_span_extender_256.s_axi4' start='0x0' end='0x100000000' datawidth='256' /></address-map>}
	set_exported_interface_sysinfo_parameter_value dla_to_ddr address_width {32}
	set_exported_interface_sysinfo_parameter_value ddr_clk clock_domain {3}
	set_exported_interface_sysinfo_parameter_value ddr_clk clock_rate {200000000}
	set_exported_interface_sysinfo_parameter_value ddr_clk reset_domain {3}
	set_exported_interface_sysinfo_parameter_value dla_clk clock_domain {2}
	set_exported_interface_sysinfo_parameter_value dla_clk clock_rate {300000000}
	set_exported_interface_sysinfo_parameter_value dla_clk reset_domain {2}
	save_system dla.qsys
	load_system hps.qsys
	set_exported_interface_sysinfo_parameter_value hps_to_csr address_map {<address-map><slave name='parent/dla.mailbox_ram_0.s1' start='0x0' end='0x1000' datawidth='32' /><slave name='parent/dla/altera_ai_ip_0.csr_axi' start='0x4000' end='0x4800' datawidth='32' /></address-map>}
	set_exported_interface_sysinfo_parameter_value hps_to_csr address_width {16}
	set_exported_interface_sysinfo_parameter_value clk_100_in_clk clock_domain {4}
	set_exported_interface_sysinfo_parameter_value clk_100_in_clk clock_rate {100000000}
	set_exported_interface_sysinfo_parameter_value clk_100_in_clk reset_domain {4}
	save_system hps.qsys
}

# create all the systems, from bottom up
do_create_hps
reload_ip_catalog
do_create_emif
reload_ip_catalog
do_create_dla
reload_ip_catalog
do_create_system

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters

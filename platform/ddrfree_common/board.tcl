package require -exact qsys 26.3

# create the system "board"
proc do_create_board {} {
	# create the system
	create_system board
	set_project_property BOARD {default}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component board_hw_timer ip/board/board_hw_timer.ip altera_avalon_mm_bridge board_hw_timer
	load_component board_hw_timer
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {11}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {1}
	set_component_parameter_value MAX_PENDING_RESPONSES {1}
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
	load_instantiation board_hw_timer
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
	set_instantiation_interface_parameter_value s0 addressSpan {2048}
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
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {1}
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
	add_instantiation_interface_port s0 s0_burstcount burstcount 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_address address 11 STD_LOGIC_VECTOR Input
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
	add_instantiation_interface_port m0 m0_burstcount burstcount 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component board_kernel_clk ip/board/board_kernel_clk.ip altera_clock_bridge board_kernel_clk
	load_component board_kernel_clk
	set_component_parameter_value EXPLICIT_CLOCK_RATE {600000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation board_kernel_clk
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {0}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {600000000}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {600000000}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component board_sys_clk ip/board/sys_pll.ip altera_clock_bridge sys_pll
	load_component board_sys_clk
	set_component_parameter_value EXPLICIT_CLOCK_RATE {100000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation board_sys_clk
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
	add_component clock_in ip/board/board_clock_in.ip altera_clock_bridge clock_in
	load_component clock_in
	set_component_parameter_value EXPLICIT_CLOCK_RATE {100000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation clock_in
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
	add_component dla_csr_bridge_0 ip/board/dla_csr_axi_bridge.ip altera_axi_bridge mem_dla_csr_axi
	load_component dla_csr_bridge_0
	set_component_parameter_value ACE5_LITE_SUPPORT {0}
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {11}
	set_component_parameter_value ATOMIC_TXN {0}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value CACHESTASHING_TXN {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {1}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {8}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value READ_ADDR_USER_WIDTH {64}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {64}
	set_component_parameter_value READ_ISSUING_CAPABILITY {1}
	set_component_parameter_value S0_ID_WIDTH {8}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SID_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value UNTRANSLATED_TXN {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {0}
	set_component_parameter_value USE_M0_ARCACHE {0}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {0}
	set_component_parameter_value USE_M0_ARLOCK {0}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {0}
	set_component_parameter_value USE_M0_ARSNOOP {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWAKEUP {0}
	set_component_parameter_value USE_M0_AWBURST {0}
	set_component_parameter_value USE_M0_AWCACHE {0}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {0}
	set_component_parameter_value USE_M0_AWLOCK {0}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {0}
	set_component_parameter_value USE_M0_AWSNOOP {0}
	set_component_parameter_value USE_M0_AWUNIQUE {0}
	set_component_parameter_value USE_M0_AWUSER {0}
	set_component_parameter_value USE_M0_BID {1}
	set_component_parameter_value USE_M0_BRESP {0}
	set_component_parameter_value USE_M0_BUSER {0}
	set_component_parameter_value USE_M0_DATACHK {0}
	set_component_parameter_value USE_M0_POISON {0}
	set_component_parameter_value USE_M0_RID {1}
	set_component_parameter_value USE_M0_RLAST {0}
	set_component_parameter_value USE_M0_RRESP {0}
	set_component_parameter_value USE_M0_RUSER {0}
	set_component_parameter_value USE_M0_SAI {0}
	set_component_parameter_value USE_M0_TRACE {0}
	set_component_parameter_value USE_M0_USER_DATA {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {0}
	set_component_parameter_value USE_S0_ARLOCK {0}
	set_component_parameter_value USE_S0_ARPROT {0}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARSIZE {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWAKEUP {0}
	set_component_parameter_value USE_S0_AWCACHE {0}
	set_component_parameter_value USE_S0_AWLOCK {0}
	set_component_parameter_value USE_S0_AWPROT {0}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWSIZE {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BID {0}
	set_component_parameter_value USE_S0_BRESP {0}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RID {0}
	set_component_parameter_value USE_S0_RRESP {0}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_TRACE {0}
	set_component_parameter_value USE_S0_USER_DATA {0}
	set_component_parameter_value USE_S0_WLAST {0}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {64}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {64}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {1}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {64}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_csr_bridge_0
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
	set_instantiation_interface_parameter_value s0 combinedAcceptanceCapability {1}
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
	set_instantiation_interface_parameter_value s0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value s0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0 poison {false}
	set_instantiation_interface_parameter_value s0 readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value s0 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0 securityAttribute {false}
	set_instantiation_interface_parameter_value s0 traceSignals {false}
	set_instantiation_interface_parameter_value s0 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0 userData {false}
	set_instantiation_interface_parameter_value s0 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0 writeAcceptanceCapability {1}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_awid awid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awaddr awaddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_wdata wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wstrb wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bid bid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arid arid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_araddr araddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rid rid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rdata rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {1}
	add_instantiation_interface_port m0 m0_awid awid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bid bid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arid arid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_araddr araddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rid rid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component dla_csr_bridge_1 ip/board/dla_csr_axi_bridge.ip altera_axi_bridge mem_dla_csr_axi
	load_component dla_csr_bridge_1
	set_component_parameter_value ACE5_LITE_SUPPORT {0}
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {11}
	set_component_parameter_value ATOMIC_TXN {0}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value CACHESTASHING_TXN {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {1}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {8}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value READ_ADDR_USER_WIDTH {64}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {64}
	set_component_parameter_value READ_ISSUING_CAPABILITY {1}
	set_component_parameter_value S0_ID_WIDTH {8}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SID_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value UNTRANSLATED_TXN {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {0}
	set_component_parameter_value USE_M0_ARCACHE {0}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {0}
	set_component_parameter_value USE_M0_ARLOCK {0}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {0}
	set_component_parameter_value USE_M0_ARSNOOP {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWAKEUP {0}
	set_component_parameter_value USE_M0_AWBURST {0}
	set_component_parameter_value USE_M0_AWCACHE {0}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {0}
	set_component_parameter_value USE_M0_AWLOCK {0}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {0}
	set_component_parameter_value USE_M0_AWSNOOP {0}
	set_component_parameter_value USE_M0_AWUNIQUE {0}
	set_component_parameter_value USE_M0_AWUSER {0}
	set_component_parameter_value USE_M0_BID {1}
	set_component_parameter_value USE_M0_BRESP {0}
	set_component_parameter_value USE_M0_BUSER {0}
	set_component_parameter_value USE_M0_DATACHK {0}
	set_component_parameter_value USE_M0_POISON {0}
	set_component_parameter_value USE_M0_RID {1}
	set_component_parameter_value USE_M0_RLAST {0}
	set_component_parameter_value USE_M0_RRESP {0}
	set_component_parameter_value USE_M0_RUSER {0}
	set_component_parameter_value USE_M0_SAI {0}
	set_component_parameter_value USE_M0_TRACE {0}
	set_component_parameter_value USE_M0_USER_DATA {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {0}
	set_component_parameter_value USE_S0_ARLOCK {0}
	set_component_parameter_value USE_S0_ARPROT {0}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARSIZE {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWAKEUP {0}
	set_component_parameter_value USE_S0_AWCACHE {0}
	set_component_parameter_value USE_S0_AWLOCK {0}
	set_component_parameter_value USE_S0_AWPROT {0}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWSIZE {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BID {0}
	set_component_parameter_value USE_S0_BRESP {0}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RID {0}
	set_component_parameter_value USE_S0_RRESP {0}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_TRACE {0}
	set_component_parameter_value USE_S0_USER_DATA {0}
	set_component_parameter_value USE_S0_WLAST {0}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {64}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {64}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {1}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {64}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_csr_bridge_1
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
	set_instantiation_interface_parameter_value s0 combinedAcceptanceCapability {1}
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
	set_instantiation_interface_parameter_value s0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value s0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0 poison {false}
	set_instantiation_interface_parameter_value s0 readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value s0 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0 securityAttribute {false}
	set_instantiation_interface_parameter_value s0 traceSignals {false}
	set_instantiation_interface_parameter_value s0 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0 userData {false}
	set_instantiation_interface_parameter_value s0 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0 writeAcceptanceCapability {1}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_awid awid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awaddr awaddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_wdata wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wstrb wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bid bid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arid arid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_araddr araddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rid rid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rdata rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {1}
	add_instantiation_interface_port m0 m0_awid awid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bid bid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arid arid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_araddr araddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rid rid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component dla_csr_bridge_2 ip/board/dla_csr_axi_bridge.ip altera_axi_bridge mem_dla_csr_axi
	load_component dla_csr_bridge_2
	set_component_parameter_value ACE5_LITE_SUPPORT {0}
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {11}
	set_component_parameter_value ATOMIC_TXN {0}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value CACHESTASHING_TXN {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {1}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {8}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value READ_ADDR_USER_WIDTH {64}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {64}
	set_component_parameter_value READ_ISSUING_CAPABILITY {1}
	set_component_parameter_value S0_ID_WIDTH {8}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SID_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value UNTRANSLATED_TXN {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {0}
	set_component_parameter_value USE_M0_ARCACHE {0}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {0}
	set_component_parameter_value USE_M0_ARLOCK {0}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {0}
	set_component_parameter_value USE_M0_ARSNOOP {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWAKEUP {0}
	set_component_parameter_value USE_M0_AWBURST {0}
	set_component_parameter_value USE_M0_AWCACHE {0}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {0}
	set_component_parameter_value USE_M0_AWLOCK {0}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {0}
	set_component_parameter_value USE_M0_AWSNOOP {0}
	set_component_parameter_value USE_M0_AWUNIQUE {0}
	set_component_parameter_value USE_M0_AWUSER {0}
	set_component_parameter_value USE_M0_BID {1}
	set_component_parameter_value USE_M0_BRESP {0}
	set_component_parameter_value USE_M0_BUSER {0}
	set_component_parameter_value USE_M0_DATACHK {0}
	set_component_parameter_value USE_M0_POISON {0}
	set_component_parameter_value USE_M0_RID {1}
	set_component_parameter_value USE_M0_RLAST {0}
	set_component_parameter_value USE_M0_RRESP {0}
	set_component_parameter_value USE_M0_RUSER {0}
	set_component_parameter_value USE_M0_SAI {0}
	set_component_parameter_value USE_M0_TRACE {0}
	set_component_parameter_value USE_M0_USER_DATA {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {0}
	set_component_parameter_value USE_S0_ARLOCK {0}
	set_component_parameter_value USE_S0_ARPROT {0}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARSIZE {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWAKEUP {0}
	set_component_parameter_value USE_S0_AWCACHE {0}
	set_component_parameter_value USE_S0_AWLOCK {0}
	set_component_parameter_value USE_S0_AWPROT {0}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWSIZE {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BID {0}
	set_component_parameter_value USE_S0_BRESP {0}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RID {0}
	set_component_parameter_value USE_S0_RRESP {0}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_TRACE {0}
	set_component_parameter_value USE_S0_USER_DATA {0}
	set_component_parameter_value USE_S0_WLAST {0}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {64}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {64}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {1}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {64}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_csr_bridge_2
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
	set_instantiation_interface_parameter_value s0 combinedAcceptanceCapability {1}
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
	set_instantiation_interface_parameter_value s0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value s0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0 poison {false}
	set_instantiation_interface_parameter_value s0 readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value s0 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0 securityAttribute {false}
	set_instantiation_interface_parameter_value s0 traceSignals {false}
	set_instantiation_interface_parameter_value s0 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0 userData {false}
	set_instantiation_interface_parameter_value s0 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0 writeAcceptanceCapability {1}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_awid awid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awaddr awaddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_wdata wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wstrb wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bid bid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arid arid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_araddr araddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rid rid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rdata rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {1}
	add_instantiation_interface_port m0 m0_awid awid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bid bid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arid arid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_araddr araddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rid rid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component dla_csr_bridge_3 ip/board/dla_csr_axi_bridge.ip altera_axi_bridge mem_dla_csr_axi
	load_component dla_csr_bridge_3
	set_component_parameter_value ACE5_LITE_SUPPORT {0}
	set_component_parameter_value ACE_LITE_SUPPORT {0}
	set_component_parameter_value ADDR_WIDTH {11}
	set_component_parameter_value ATOMIC_TXN {0}
	set_component_parameter_value AXI_VERSION {AXI4}
	set_component_parameter_value BACKPRESSURE_DURING_RESET {0}
	set_component_parameter_value BITSPERBYTE {0}
	set_component_parameter_value CACHESTASHING_TXN {0}
	set_component_parameter_value COMBINED_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value COMBINED_ISSUING_CAPABILITY {1}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value ENABLE_CONCURRENT_SUBORDINATE_ACCESS {0}
	set_component_parameter_value ENABLE_OOO {0}
	set_component_parameter_value M0_ID_WIDTH {8}
	set_component_parameter_value NO_REPEATED_IDS_BETWEEN_SUBORDINATES {0}
	set_component_parameter_value READ_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value READ_ADDR_USER_WIDTH {64}
	set_component_parameter_value READ_DATA_REORDERING_DEPTH {1}
	set_component_parameter_value READ_DATA_USER_WIDTH {64}
	set_component_parameter_value READ_ISSUING_CAPABILITY {1}
	set_component_parameter_value S0_ID_WIDTH {8}
	set_component_parameter_value SAI_WIDTH {1}
	set_component_parameter_value SID_WIDTH {1}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value UNTRANSLATED_TXN {0}
	set_component_parameter_value USE_M0_ADDRCHK {0}
	set_component_parameter_value USE_M0_ARBURST {0}
	set_component_parameter_value USE_M0_ARCACHE {0}
	set_component_parameter_value USE_M0_ARID {1}
	set_component_parameter_value USE_M0_ARLEN {0}
	set_component_parameter_value USE_M0_ARLOCK {0}
	set_component_parameter_value USE_M0_ARQOS {0}
	set_component_parameter_value USE_M0_ARREGION {0}
	set_component_parameter_value USE_M0_ARSIZE {0}
	set_component_parameter_value USE_M0_ARSNOOP {0}
	set_component_parameter_value USE_M0_ARUSER {0}
	set_component_parameter_value USE_M0_AWAKEUP {0}
	set_component_parameter_value USE_M0_AWBURST {0}
	set_component_parameter_value USE_M0_AWCACHE {0}
	set_component_parameter_value USE_M0_AWID {1}
	set_component_parameter_value USE_M0_AWLEN {0}
	set_component_parameter_value USE_M0_AWLOCK {0}
	set_component_parameter_value USE_M0_AWQOS {0}
	set_component_parameter_value USE_M0_AWREGION {0}
	set_component_parameter_value USE_M0_AWSIZE {0}
	set_component_parameter_value USE_M0_AWSNOOP {0}
	set_component_parameter_value USE_M0_AWUNIQUE {0}
	set_component_parameter_value USE_M0_AWUSER {0}
	set_component_parameter_value USE_M0_BID {1}
	set_component_parameter_value USE_M0_BRESP {0}
	set_component_parameter_value USE_M0_BUSER {0}
	set_component_parameter_value USE_M0_DATACHK {0}
	set_component_parameter_value USE_M0_POISON {0}
	set_component_parameter_value USE_M0_RID {1}
	set_component_parameter_value USE_M0_RLAST {0}
	set_component_parameter_value USE_M0_RRESP {0}
	set_component_parameter_value USE_M0_RUSER {0}
	set_component_parameter_value USE_M0_SAI {0}
	set_component_parameter_value USE_M0_TRACE {0}
	set_component_parameter_value USE_M0_USER_DATA {0}
	set_component_parameter_value USE_M0_WSTRB {1}
	set_component_parameter_value USE_M0_WUSER {0}
	set_component_parameter_value USE_PIPELINE {1}
	set_component_parameter_value USE_S0_ADDRCHK {0}
	set_component_parameter_value USE_S0_ARCACHE {0}
	set_component_parameter_value USE_S0_ARLOCK {0}
	set_component_parameter_value USE_S0_ARPROT {0}
	set_component_parameter_value USE_S0_ARQOS {0}
	set_component_parameter_value USE_S0_ARREGION {0}
	set_component_parameter_value USE_S0_ARSIZE {0}
	set_component_parameter_value USE_S0_ARUSER {0}
	set_component_parameter_value USE_S0_AWAKEUP {0}
	set_component_parameter_value USE_S0_AWCACHE {0}
	set_component_parameter_value USE_S0_AWLOCK {0}
	set_component_parameter_value USE_S0_AWPROT {0}
	set_component_parameter_value USE_S0_AWQOS {0}
	set_component_parameter_value USE_S0_AWREGION {0}
	set_component_parameter_value USE_S0_AWSIZE {0}
	set_component_parameter_value USE_S0_AWUSER {0}
	set_component_parameter_value USE_S0_BID {0}
	set_component_parameter_value USE_S0_BRESP {0}
	set_component_parameter_value USE_S0_BUSER {0}
	set_component_parameter_value USE_S0_DATACHK {0}
	set_component_parameter_value USE_S0_POISON {0}
	set_component_parameter_value USE_S0_RID {0}
	set_component_parameter_value USE_S0_RRESP {0}
	set_component_parameter_value USE_S0_RUSER {0}
	set_component_parameter_value USE_S0_SAI {0}
	set_component_parameter_value USE_S0_TRACE {0}
	set_component_parameter_value USE_S0_USER_DATA {0}
	set_component_parameter_value USE_S0_WLAST {0}
	set_component_parameter_value USE_S0_WUSER {0}
	set_component_parameter_value WRITE_ACCEPTANCE_CAPABILITY {1}
	set_component_parameter_value WRITE_ADDR_USER_WIDTH {64}
	set_component_parameter_value WRITE_DATA_USER_WIDTH {64}
	set_component_parameter_value WRITE_ISSUING_CAPABILITY {1}
	set_component_parameter_value WRITE_RESP_USER_WIDTH {64}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_csr_bridge_3
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
	set_instantiation_interface_parameter_value s0 combinedAcceptanceCapability {1}
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
	set_instantiation_interface_parameter_value s0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value s0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value s0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value s0 poison {false}
	set_instantiation_interface_parameter_value s0 readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value s0 readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value s0 securityAttribute {false}
	set_instantiation_interface_parameter_value s0 traceSignals {false}
	set_instantiation_interface_parameter_value s0 trustzoneAware {true}
	set_instantiation_interface_parameter_value s0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value s0 userData {false}
	set_instantiation_interface_parameter_value s0 wakeupSignals {false}
	set_instantiation_interface_parameter_value s0 writeAcceptanceCapability {1}
	set_instantiation_interface_sysinfo_parameter_value s0 address_map {}
	set_instantiation_interface_sysinfo_parameter_value s0 address_width {}
	set_instantiation_interface_sysinfo_parameter_value s0 max_slave_data_width {}
	add_instantiation_interface_port s0 s0_awid awid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awaddr awaddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awlen awlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awsize awsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awburst awburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_awvalid awvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_awready awready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_wdata wdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wstrb wstrb 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_wvalid wvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_wready wready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bid bid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_bvalid bvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_bready bready 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arid arid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_araddr araddr 11 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arlen arlen 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arsize arsize 3 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arburst arburst 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_arvalid arvalid 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_arready arready 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rid rid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rdata rdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_rlast rlast 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rvalid rvalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_rready rready 1 STD_LOGIC Input
	add_instantiation_interface m0 axi4 OUTPUT
	set_instantiation_interface_parameter_value m0 addressCheck {false}
	set_instantiation_interface_parameter_value m0 associatedClock {clk}
	set_instantiation_interface_parameter_value m0 associatedReset {clk_reset}
	set_instantiation_interface_parameter_value m0 combinedIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 dataCheck {false}
	set_instantiation_interface_parameter_value m0 enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value m0 isTranslator {false}
	set_instantiation_interface_parameter_value m0 issuesFIXEDBursts {true}
	set_instantiation_interface_parameter_value m0 issuesINCRBursts {true}
	set_instantiation_interface_parameter_value m0 issuesWRAPBursts {true}
	set_instantiation_interface_parameter_value m0 maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value m0 maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value m0 noRepeatedIdsBetweenSubordinates {0}
	set_instantiation_interface_parameter_value m0 optionalAssociatedReset {false}
	set_instantiation_interface_parameter_value m0 poison {false}
	set_instantiation_interface_parameter_value m0 readIssuingCapability {1}
	set_instantiation_interface_parameter_value m0 securityAttribute {false}
	set_instantiation_interface_parameter_value m0 traceSignals {false}
	set_instantiation_interface_parameter_value m0 trustzoneAware {true}
	set_instantiation_interface_parameter_value m0 uniqueIdSupport {false}
	set_instantiation_interface_parameter_value m0 userData {false}
	set_instantiation_interface_parameter_value m0 wakeupSignals {false}
	set_instantiation_interface_parameter_value m0 writeIssuingCapability {1}
	add_instantiation_interface_port m0 m0_awid awid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awaddr awaddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awprot awprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_awvalid awvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_awready awready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_wdata wdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wstrb wstrb 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_wlast wlast 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wvalid wvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_wready wready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bid bid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_bvalid bvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_bready bready 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arid arid 8 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_araddr araddr 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arprot arprot 3 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_arvalid arvalid 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_arready arready 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rid rid 8 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rdata rdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_rvalid rvalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_rready rready 1 STD_LOGIC Output
	save_instantiation
	add_component egress_msgdma ip/board/egress_msgdma.ip altera_msgdma egress_msgdma
	load_component egress_msgdma
	set_component_parameter_value BURST_ENABLE {0}
	set_component_parameter_value BURST_WRAPPING_SUPPORT {0}
	set_component_parameter_value CHANNEL_ENABLE {0}
	set_component_parameter_value CHANNEL_WIDTH {8}
	set_component_parameter_value DATA_FIFO_DEPTH {128}
	set_component_parameter_value DATA_WIDTH {128}
	set_component_parameter_value DESCRIPTOR_FIFO_DEPTH {32}
	set_component_parameter_value ENHANCED_FEATURES {0}
	set_component_parameter_value ERROR_ENABLE {0}
	set_component_parameter_value ERROR_WIDTH {8}
	set_component_parameter_value EXPOSE_ST_PORT {0}
	set_component_parameter_value FIX_ADDRESS_WIDTH {32}
	set_component_parameter_value MAX_BURST_COUNT {2}
	set_component_parameter_value MAX_BYTE {131072}
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
	set_component_parameter_value TRANSFER_TYPE {Full Word Accesses Only}
	set_component_parameter_value USE_FIX_ADDRESS_WIDTH {0}
	set_component_parameter_value WRITE_RESPONSE_ENABLE {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation egress_msgdma
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_WRAPPING_SUPPORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DESCRIPTOR_FIFO_DEPTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.DMA_MODE {2}
	set_instantiation_assignment_value embeddedsw.CMacro.ENHANCED_FEATURES {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BURST_COUNT {2}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BYTE {131072}
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
	set_instantiation_interface_parameter_value descriptor_slave addressSpan {16}
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
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_map {<address-map><slave name='descriptor_slave' start='0x0' end='0x10' datawidth='128' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_width {4}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave max_slave_data_width {128}
	add_instantiation_interface_port descriptor_slave descriptor_slave_write write 1 STD_LOGIC Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port descriptor_slave descriptor_slave_writedata writedata 128 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_byteenable byteenable 16 STD_LOGIC_VECTOR Input
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
	add_instantiation_interface_port mm_write mm_write_byteenable byteenable 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_writedata writedata 128 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_waitrequest waitrequest 1 STD_LOGIC Input
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
	set_instantiation_interface_parameter_value st_sink symbolsPerBeat {16}
	add_instantiation_interface_port st_sink st_sink_data data 128 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port st_sink st_sink_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port st_sink st_sink_ready ready 1 STD_LOGIC Output
	save_instantiation
	add_component egress_onchip_memory ip/board/egress_onchip_memory.ip intel_onchip_memory egress_onchip_memory
	load_component egress_onchip_memory
	set_component_parameter_value AXI_interface {1}
	set_component_parameter_value allowInSystemMemoryContentEditor {0}
	set_component_parameter_value blockType {AUTO}
	set_component_parameter_value clockEnable {0}
	set_component_parameter_value copyInitFile {0}
	set_component_parameter_value dataWidth {32}
	set_component_parameter_value dataWidth2 {32}
	set_component_parameter_value dualPort {1}
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
	set_component_parameter_value memorySize {131072.0}
	set_component_parameter_value poison_enable {0}
	set_component_parameter_value readDuringWriteMode_Mixed {DONT_CARE}
	set_component_parameter_value resetrequest_enabled {1}
	set_component_parameter_value singleClockOperation {0}
	set_component_parameter_value tightly_coupled_ecc {0}
	set_component_parameter_value useNonDefaultInitFile {0}
	set_component_parameter_value writable {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation egress_onchip_memory
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CONTENTS_INFO {""}
	set_instantiation_assignment_value embeddedsw.CMacro.DUAL_PORT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.GUI_RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_CONTENTS_FILE {egress_onchip_memory_egress_onchip_memory}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_MEM_CONTENT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.INSTANCE_ID {NONE}
	set_instantiation_assignment_value embeddedsw.CMacro.NON_DEFAULT_INIT_FILE_ENABLED {0}
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
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_FILENAME {egress_onchip_memory_egress_onchip_memory}
	set_instantiation_assignment_value postgeneration.simulation.init_file.param_name {INIT_FILE}
	set_instantiation_assignment_value postgeneration.simulation.init_file.type {MEM_INIT}
	add_instantiation_interface clk1 clock INPUT
	set_instantiation_interface_parameter_value clk1 clockRate {0}
	set_instantiation_interface_parameter_value clk1 externallyDriven {false}
	set_instantiation_interface_parameter_value clk1 ptfSchematicName {}
	add_instantiation_interface_port clk1 clk clk 1 STD_LOGIC Input
	add_instantiation_interface s1 avalon INPUT
	set_instantiation_interface_parameter_value s1 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s1 addressGroup {1}
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
	add_instantiation_interface s2 avalon INPUT
	set_instantiation_interface_parameter_value s2 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s2 addressGroup {1}
	set_instantiation_interface_parameter_value s2 addressSpan {131072}
	set_instantiation_interface_parameter_value s2 addressUnits {WORDS}
	set_instantiation_interface_parameter_value s2 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s2 associatedClock {clk1}
	set_instantiation_interface_parameter_value s2 associatedReset {reset1}
	set_instantiation_interface_parameter_value s2 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s2 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s2 bridgesToMaster {}
	set_instantiation_interface_parameter_value s2 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s2 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s2 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s2 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s2 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s2 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s2 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s2 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s2 dfhGroupId {0}
	set_instantiation_interface_parameter_value s2 dfhParameterData {}
	set_instantiation_interface_parameter_value s2 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s2 dfhParameterId {}
	set_instantiation_interface_parameter_value s2 dfhParameterName {}
	set_instantiation_interface_parameter_value s2 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s2 explicitAddressSpan {131072}
	set_instantiation_interface_parameter_value s2 holdTime {0}
	set_instantiation_interface_parameter_value s2 interleaveBursts {false}
	set_instantiation_interface_parameter_value s2 isBigEndian {false}
	set_instantiation_interface_parameter_value s2 isFlash {false}
	set_instantiation_interface_parameter_value s2 isMemoryDevice {true}
	set_instantiation_interface_parameter_value s2 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s2 linewrapBursts {false}
	set_instantiation_interface_parameter_value s2 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value s2 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s2 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s2 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s2 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s2 prSafe {false}
	set_instantiation_interface_parameter_value s2 printableDevice {false}
	set_instantiation_interface_parameter_value s2 readLatency {1}
	set_instantiation_interface_parameter_value s2 readWaitStates {0}
	set_instantiation_interface_parameter_value s2 readWaitTime {0}
	set_instantiation_interface_parameter_value s2 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s2 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s2 setupTime {0}
	set_instantiation_interface_parameter_value s2 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s2 transparentBridge {false}
	set_instantiation_interface_parameter_value s2 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s2 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s2 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s2 writeLatency {0}
	set_instantiation_interface_parameter_value s2 writeWaitStates {0}
	set_instantiation_interface_parameter_value s2 writeWaitTime {0}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isMemoryDevice {1}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s2 address_map {<address-map><slave name='s2' start='0x0' end='0x20000' datawidth='32' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s2 address_width {17}
	set_instantiation_interface_sysinfo_parameter_value s2 max_slave_data_width {32}
	add_instantiation_interface_port s2 address2 address 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s2 read2 read 1 STD_LOGIC Input
	add_instantiation_interface_port s2 readdata2 readdata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s2 byteenable2 byteenable 4 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s2 write2 write 1 STD_LOGIC Input
	add_instantiation_interface_port s2 writedata2 writedata 32 STD_LOGIC_VECTOR Input
	save_instantiation
	add_component global_reset_in ip/board/board_reset_in.ip altera_reset_bridge reset_in
	load_component global_reset_in
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation global_reset_in
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
	add_component hw_timer_addr_decode ip/board/hw_timer_addr_decode.ip altera_avalon_mm_bridge hw_timer_addr_decode
	load_component hw_timer_addr_decode
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {11}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {1}
	set_component_parameter_value MAX_PENDING_RESPONSES {1}
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
	load_instantiation hw_timer_addr_decode
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
	set_instantiation_interface_parameter_value s0 addressSpan {2048}
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
	set_instantiation_interface_parameter_value s0 maximumPendingReadTransactions {1}
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
	add_instantiation_interface_port s0 s0_burstcount burstcount 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_writedata writedata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_address address 11 STD_LOGIC_VECTOR Input
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
	add_instantiation_interface_port m0 m0_burstcount burstcount 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 11 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component ingress_msgdma ip/board/ingress_msgdma.ip altera_msgdma ingress_msgdma
	load_component ingress_msgdma
	set_component_parameter_value BURST_ENABLE {0}
	set_component_parameter_value BURST_WRAPPING_SUPPORT {0}
	set_component_parameter_value CHANNEL_ENABLE {0}
	set_component_parameter_value CHANNEL_WIDTH {8}
	set_component_parameter_value DATA_FIFO_DEPTH {128}
	set_component_parameter_value DATA_WIDTH {128}
	set_component_parameter_value DESCRIPTOR_FIFO_DEPTH {32}
	set_component_parameter_value ENHANCED_FEATURES {0}
	set_component_parameter_value ERROR_ENABLE {0}
	set_component_parameter_value ERROR_WIDTH {8}
	set_component_parameter_value EXPOSE_ST_PORT {0}
	set_component_parameter_value FIX_ADDRESS_WIDTH {32}
	set_component_parameter_value MAX_BURST_COUNT {2}
	set_component_parameter_value MAX_BYTE {524288}
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
	set_component_parameter_value USE_FIX_ADDRESS_WIDTH {0}
	set_component_parameter_value WRITE_RESPONSE_ENABLE {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ingress_msgdma
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_WRAPPING_SUPPORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DESCRIPTOR_FIFO_DEPTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.DMA_MODE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.ENHANCED_FEATURES {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BURST_COUNT {2}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BYTE {524288}
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
	set_instantiation_interface_parameter_value descriptor_slave addressSpan {16}
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
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_map {<address-map><slave name='descriptor_slave' start='0x0' end='0x10' datawidth='128' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave address_width {4}
	set_instantiation_interface_sysinfo_parameter_value descriptor_slave max_slave_data_width {128}
	add_instantiation_interface_port descriptor_slave descriptor_slave_write write 1 STD_LOGIC Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_waitrequest waitrequest 1 STD_LOGIC Output
	add_instantiation_interface_port descriptor_slave descriptor_slave_writedata writedata 128 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port descriptor_slave descriptor_slave_byteenable byteenable 16 STD_LOGIC_VECTOR Input
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
	add_instantiation_interface_port mm_read mm_read_address address 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_read read 1 STD_LOGIC Output
	add_instantiation_interface_port mm_read mm_read_byteenable byteenable 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_readdata readdata 128 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mm_read mm_read_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_read mm_read_readdatavalid readdatavalid 1 STD_LOGIC Input
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
	set_instantiation_interface_parameter_value st_source symbolsPerBeat {16}
	add_instantiation_interface_port st_source st_source_data data 128 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port st_source st_source_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port st_source st_source_ready ready 1 STD_LOGIC Input
	save_instantiation
	add_component ingress_onchip_memory ip/board/ingress_onchip_memory.ip intel_onchip_memory ingress_onchip_memory
	load_component ingress_onchip_memory
	set_component_parameter_value AXI_interface {1}
	set_component_parameter_value allowInSystemMemoryContentEditor {0}
	set_component_parameter_value blockType {AUTO}
	set_component_parameter_value clockEnable {0}
	set_component_parameter_value copyInitFile {0}
	set_component_parameter_value dataWidth {128}
	set_component_parameter_value dataWidth2 {32}
	set_component_parameter_value dualPort {1}
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
	set_component_parameter_value memorySize {524288.0}
	set_component_parameter_value poison_enable {0}
	set_component_parameter_value readDuringWriteMode_Mixed {DONT_CARE}
	set_component_parameter_value resetrequest_enabled {1}
	set_component_parameter_value singleClockOperation {0}
	set_component_parameter_value tightly_coupled_ecc {0}
	set_component_parameter_value useNonDefaultInitFile {0}
	set_component_parameter_value writable {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ingress_onchip_memory
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.ALLOW_IN_SYSTEM_MEMORY_CONTENT_EDITOR {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CONTENTS_INFO {""}
	set_instantiation_assignment_value embeddedsw.CMacro.DUAL_PORT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.GUI_RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_CONTENTS_FILE {ingress_onchip_memory_ingress_onchip_memory}
	set_instantiation_assignment_value embeddedsw.CMacro.INIT_MEM_CONTENT {1}
	set_instantiation_assignment_value embeddedsw.CMacro.INSTANCE_ID {NONE}
	set_instantiation_assignment_value embeddedsw.CMacro.NON_DEFAULT_INIT_FILE_ENABLED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.RAM_BLOCK_TYPE {AUTO}
	set_instantiation_assignment_value embeddedsw.CMacro.READ_DURING_WRITE_MODE {DONT_CARE}
	set_instantiation_assignment_value embeddedsw.CMacro.SINGLE_CLOCK_OP {0}
	set_instantiation_assignment_value embeddedsw.CMacro.SIZE_MULTIPLE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.SIZE_VALUE {524288}
	set_instantiation_assignment_value embeddedsw.CMacro.WRITABLE {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.DAT_SYM_INSTALL_DIR {SIM_DIR}
	set_instantiation_assignment_value embeddedsw.memoryInfo.GENERATE_DAT_SYM {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.GENERATE_HEX {1}
	set_instantiation_assignment_value embeddedsw.memoryInfo.HAS_BYTE_LANE {0}
	set_instantiation_assignment_value embeddedsw.memoryInfo.HEX_INSTALL_DIR {QPF_DIR}
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_DATA_WIDTH {128}
	set_instantiation_assignment_value embeddedsw.memoryInfo.MEM_INIT_FILENAME {ingress_onchip_memory_ingress_onchip_memory}
	set_instantiation_assignment_value postgeneration.simulation.init_file.param_name {INIT_FILE}
	set_instantiation_assignment_value postgeneration.simulation.init_file.type {MEM_INIT}
	add_instantiation_interface clk1 clock INPUT
	set_instantiation_interface_parameter_value clk1 clockRate {0}
	set_instantiation_interface_parameter_value clk1 externallyDriven {false}
	set_instantiation_interface_parameter_value clk1 ptfSchematicName {}
	add_instantiation_interface_port clk1 clk clk 1 STD_LOGIC Input
	add_instantiation_interface s1 avalon INPUT
	set_instantiation_interface_parameter_value s1 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s1 addressGroup {1}
	set_instantiation_interface_parameter_value s1 addressSpan {524288}
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
	set_instantiation_interface_parameter_value s1 explicitAddressSpan {524288}
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
	set_instantiation_interface_sysinfo_parameter_value s1 address_map {<address-map><slave name='s1' start='0x0' end='0x80000' datawidth='128' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s1 address_width {19}
	set_instantiation_interface_sysinfo_parameter_value s1 max_slave_data_width {128}
	add_instantiation_interface_port s1 address address 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 read read 1 STD_LOGIC Input
	add_instantiation_interface_port s1 readdata readdata 128 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s1 byteenable byteenable 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s1 write write 1 STD_LOGIC Input
	add_instantiation_interface_port s1 writedata writedata 128 STD_LOGIC_VECTOR Input
	add_instantiation_interface reset1 reset INPUT
	set_instantiation_interface_parameter_value reset1 associatedClock {clk1}
	set_instantiation_interface_parameter_value reset1 synchronousEdges {DEASSERT}
	add_instantiation_interface_port reset1 reset reset 1 STD_LOGIC Input
	add_instantiation_interface_port reset1 reset_req reset_req 1 STD_LOGIC Input
	add_instantiation_interface s2 avalon INPUT
	set_instantiation_interface_parameter_value s2 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value s2 addressGroup {1}
	set_instantiation_interface_parameter_value s2 addressSpan {524288}
	set_instantiation_interface_parameter_value s2 addressUnits {WORDS}
	set_instantiation_interface_parameter_value s2 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value s2 associatedClock {clk1}
	set_instantiation_interface_parameter_value s2 associatedReset {reset1}
	set_instantiation_interface_parameter_value s2 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value s2 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value s2 bridgesToMaster {}
	set_instantiation_interface_parameter_value s2 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value s2 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value s2 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value s2 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value s2 dfhFeatureId {35}
	set_instantiation_interface_parameter_value s2 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value s2 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value s2 dfhFeatureType {3}
	set_instantiation_interface_parameter_value s2 dfhGroupId {0}
	set_instantiation_interface_parameter_value s2 dfhParameterData {}
	set_instantiation_interface_parameter_value s2 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value s2 dfhParameterId {}
	set_instantiation_interface_parameter_value s2 dfhParameterName {}
	set_instantiation_interface_parameter_value s2 dfhParameterVersion {}
	set_instantiation_interface_parameter_value s2 explicitAddressSpan {524288}
	set_instantiation_interface_parameter_value s2 holdTime {0}
	set_instantiation_interface_parameter_value s2 interleaveBursts {false}
	set_instantiation_interface_parameter_value s2 isBigEndian {false}
	set_instantiation_interface_parameter_value s2 isFlash {false}
	set_instantiation_interface_parameter_value s2 isMemoryDevice {true}
	set_instantiation_interface_parameter_value s2 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value s2 linewrapBursts {false}
	set_instantiation_interface_parameter_value s2 maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value s2 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value s2 minimumReadLatency {1}
	set_instantiation_interface_parameter_value s2 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value s2 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value s2 prSafe {false}
	set_instantiation_interface_parameter_value s2 printableDevice {false}
	set_instantiation_interface_parameter_value s2 readLatency {1}
	set_instantiation_interface_parameter_value s2 readWaitStates {0}
	set_instantiation_interface_parameter_value s2 readWaitTime {0}
	set_instantiation_interface_parameter_value s2 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value s2 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value s2 setupTime {0}
	set_instantiation_interface_parameter_value s2 timingUnits {Cycles}
	set_instantiation_interface_parameter_value s2 transparentBridge {false}
	set_instantiation_interface_parameter_value s2 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value s2 waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value s2 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value s2 writeLatency {0}
	set_instantiation_interface_parameter_value s2 writeWaitStates {0}
	set_instantiation_interface_parameter_value s2 writeWaitTime {0}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isMemoryDevice {1}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value s2 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value s2 address_map {<address-map><slave name='s2' start='0x0' end='0x80000' datawidth='128' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value s2 address_width {19}
	set_instantiation_interface_sysinfo_parameter_value s2 max_slave_data_width {128}
	add_instantiation_interface_port s2 address2 address 15 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s2 read2 read 1 STD_LOGIC Input
	add_instantiation_interface_port s2 readdata2 readdata 128 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s2 byteenable2 byteenable 16 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s2 write2 write 1 STD_LOGIC Input
	add_instantiation_interface_port s2 writedata2 writedata 128 STD_LOGIC_VECTOR Input
	save_instantiation
	add_component jtag_to_avalon ip/board/jtag_to_avalon.ip altera_jtag_avalon_master jtag_to_avalon
	load_component jtag_to_avalon
	set_component_parameter_value FAST_VER {0}
	set_component_parameter_value FIFO_DEPTHS {2}
	set_component_parameter_value PLI_PORT {50000}
	set_component_parameter_value USE_PLI {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation jtag_to_avalon
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value debug.hostConnection {type jtag id 110:132}
	add_instantiation_interface clk clock INPUT
	set_instantiation_interface_parameter_value clk clockRate {0}
	set_instantiation_interface_parameter_value clk externallyDriven {false}
	set_instantiation_interface_parameter_value clk ptfSchematicName {}
	add_instantiation_interface_port clk clk_clk clk 1 STD_LOGIC Input
	add_instantiation_interface clk_reset reset INPUT
	set_instantiation_interface_parameter_value clk_reset associatedClock {}
	set_instantiation_interface_parameter_value clk_reset synchronousEdges {NONE}
	add_instantiation_interface_port clk_reset clk_reset_reset reset 1 STD_LOGIC Input
	add_instantiation_interface master_reset reset OUTPUT
	set_instantiation_interface_parameter_value master_reset associatedClock {}
	set_instantiation_interface_parameter_value master_reset associatedDirectReset {}
	set_instantiation_interface_parameter_value master_reset associatedResetSinks {none}
	set_instantiation_interface_parameter_value master_reset synchronousEdges {NONE}
	add_instantiation_interface_port master_reset master_reset_reset reset 1 STD_LOGIC Output
	add_instantiation_interface master avalon OUTPUT
	set_instantiation_interface_parameter_value master adaptsTo {}
	set_instantiation_interface_parameter_value master addressGroup {0}
	set_instantiation_interface_parameter_value master addressUnits {SYMBOLS}
	set_instantiation_interface_parameter_value master alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value master associatedClock {clk}
	set_instantiation_interface_parameter_value master associatedReset {clk_reset}
	set_instantiation_interface_parameter_value master bitsPerSymbol {8}
	set_instantiation_interface_parameter_value master burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value master burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value master constantBurstBehavior {false}
	set_instantiation_interface_parameter_value master dBSBigEndian {false}
	set_instantiation_interface_parameter_value master doStreamReads {false}
	set_instantiation_interface_parameter_value master doStreamWrites {false}
	set_instantiation_interface_parameter_value master enableConcurrentSubordinateAccess {0}
	set_instantiation_interface_parameter_value master holdTime {0}
	set_instantiation_interface_parameter_value master interleaveBursts {false}
	set_instantiation_interface_parameter_value master isAsynchronous {false}
	set_instantiation_interface_parameter_value master isBigEndian {false}
	set_instantiation_interface_parameter_value master isReadable {false}
	set_instantiation_interface_parameter_value master isWriteable {false}
	set_instantiation_interface_parameter_value master linewrapBursts {false}
	set_instantiation_interface_parameter_value master maxAddressWidth {32}
	set_instantiation_interface_parameter_value master maximumPendingReadTransactions {0}
	set_instantiation_interface_parameter_value master maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value master minimumReadLatency {1}
	set_instantiation_interface_parameter_value master minimumResponseLatency {1}
	set_instantiation_interface_parameter_value master optimizedReadsWithBE {0}
	set_instantiation_interface_parameter_value master prSafe {false}
	set_instantiation_interface_parameter_value master readLatency {0}
	set_instantiation_interface_parameter_value master readWaitTime {1}
	set_instantiation_interface_parameter_value master registerIncomingSignals {false}
	set_instantiation_interface_parameter_value master registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value master setupTime {0}
	set_instantiation_interface_parameter_value master timingUnits {Cycles}
	set_instantiation_interface_parameter_value master waitrequestAllowance {0}
	set_instantiation_interface_parameter_value master waitrequestTimeout {1024}
	set_instantiation_interface_parameter_value master writeWaitTime {0}
	set_instantiation_interface_assignment_value master debug.controlledBy {in_stream}
	set_instantiation_interface_assignment_value master debug.providesServices {master}
	set_instantiation_interface_assignment_value master debug.typeName {altera_jtag_avalon_master.master}
	set_instantiation_interface_assignment_value master debug.visible {true}
	add_instantiation_interface_port master master_address address 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port master master_readdata readdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port master master_read read 1 STD_LOGIC Output
	add_instantiation_interface_port master master_write write 1 STD_LOGIC Output
	add_instantiation_interface_port master master_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port master master_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port master master_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port master master_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component kernel_pll ip/board/kernel_pll.ip altera_iopll kernel_pll
	load_component kernel_pll
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
	set_component_parameter_value gui_output_clock_frequency0 {600.0}
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
	set_component_parameter_value gui_output_clock_frequency_ps0 {1666.667}
	set_component_parameter_value gui_output_clock_frequency_ps1 {10000.0}
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
	set_component_parameter_value gui_pll_bandwidth_preset {High}
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
	set_component_parameter_value gui_simulation_type {0}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {1}
	set_component_parameter_value gui_use_fractional_division {0}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {600.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation kernel_pll
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
	set_instantiation_interface_parameter_value outclk0 clockRate {600000000}
	set_instantiation_interface_parameter_value outclk0 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk0 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk0 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk0 clock_rate {600000000}
	add_instantiation_interface_port outclk0 outclk_0 clk 1 STD_LOGIC Output
	save_instantiation
	add_component pll_resetn_in ip/board/pll_resetn_in.ip altera_reset_bridge pll_resetn_in
	load_component pll_resetn_in
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation pll_resetn_in
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
	add_component reset_release_inst ip/board/reset_release_inst.ip altera_s10_user_rst_clkgate reset_release_inst
	load_component reset_release_inst
	set_component_parameter_value outputType {Conduit Interface}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation reset_release_inst
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface ninit_done conduit INPUT
	set_instantiation_interface_parameter_value ninit_done associatedClock {}
	set_instantiation_interface_parameter_value ninit_done associatedReset {}
	set_instantiation_interface_parameter_value ninit_done prSafe {false}
	add_instantiation_interface_port ninit_done ninit_done ninit_done 1 STD_LOGIC Output
	save_instantiation
	add_component st_adapter_0 ip/board/board_st_adapter_0.ip altera_avalon_st_adapter st_adapter_0
	load_component st_adapter_0
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value inBitsPerSymbol {8}
	set_component_parameter_value inChannelWidth {0}
	set_component_parameter_value inDataWidth {128}
	set_component_parameter_value inErrorDescriptor {}
	set_component_parameter_value inErrorWidth {0}
	set_component_parameter_value inMaxChannel {1}
	set_component_parameter_value inReadyLatency {0}
	set_component_parameter_value inUseEmptyPort {0}
	set_component_parameter_value inUsePackets {0}
	set_component_parameter_value inUseReady {1}
	set_component_parameter_value inUseValid {1}
	set_component_parameter_value outChannelWidth {0}
	set_component_parameter_value outDataWidth {INPUT_DATA_WIDTH}
	set_component_parameter_value outErrorDescriptor {}
	set_component_parameter_value outErrorWidth {0}
	set_component_parameter_value outMaxChannel {1}
	set_component_parameter_value outReadyLatency {0}
	set_component_parameter_value outUseEmptyPort {0}
	set_component_parameter_value outUseReady {1}
	set_component_parameter_value outUseValid {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation st_adapter_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk_0 clock INPUT
	set_instantiation_interface_parameter_value in_clk_0 clockRate {0}
	set_instantiation_interface_parameter_value in_clk_0 externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk_0 ptfSchematicName {}
	add_instantiation_interface_port in_clk_0 in_clk_0_clk clk 1 STD_LOGIC Input
	add_instantiation_interface in_rst_0 reset INPUT
	set_instantiation_interface_parameter_value in_rst_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_rst_0 synchronousEdges {DEASSERT}
	add_instantiation_interface_port in_rst_0 in_rst_0_reset reset 1 STD_LOGIC Input
	add_instantiation_interface in_0 avalon_streaming INPUT
	set_instantiation_interface_parameter_value in_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value in_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value in_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value in_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value in_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value in_0 errorDescriptor {}
	set_instantiation_interface_parameter_value in_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value in_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value in_0 maxChannel {1}
	set_instantiation_interface_parameter_value in_0 packetDescription {}
	set_instantiation_interface_parameter_value in_0 prSafe {false}
	set_instantiation_interface_parameter_value in_0 readyAllowance {0}
	set_instantiation_interface_parameter_value in_0 readyLatency {0}
	set_instantiation_interface_parameter_value in_0 symbolsPerBeat {16}
	add_instantiation_interface_port in_0 in_0_data data 128 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port in_0 in_0_valid valid 1 STD_LOGIC Input
	add_instantiation_interface_port in_0 in_0_ready ready 1 STD_LOGIC Output
	add_instantiation_interface out_0 avalon_streaming OUTPUT
	set_instantiation_interface_parameter_value out_0 associatedClock {in_clk_0}
	set_instantiation_interface_parameter_value out_0 associatedReset {in_rst_0}
	set_instantiation_interface_parameter_value out_0 beatsPerCycle {1}
	set_instantiation_interface_parameter_value out_0 dataBitsPerSymbol {8}
	set_instantiation_interface_parameter_value out_0 emptyWithinPacket {false}
	set_instantiation_interface_parameter_value out_0 errorDescriptor {}
	set_instantiation_interface_parameter_value out_0 firstSymbolInHighOrderBits {true}
	set_instantiation_interface_parameter_value out_0 highOrderSymbolAtMSB {false}
	set_instantiation_interface_parameter_value out_0 maxChannel {1}
	set_instantiation_interface_parameter_value out_0 packetDescription {}
	set_instantiation_interface_parameter_value out_0 prSafe {false}
	set_instantiation_interface_parameter_value out_0 readyAllowance {0}
	set_instantiation_interface_parameter_value out_0 readyLatency {0}
	set_instantiation_interface_parameter_value out_0 symbolsPerBeat {INPUT_DATA_WIDTH_IN_BYTES}
	add_instantiation_interface_port out_0 out_0_data data INPUT_DATA_WIDTH STD_LOGIC_VECTOR Output
	add_instantiation_interface_port out_0 out_0_valid valid 1 STD_LOGIC Output
	add_instantiation_interface_port out_0 out_0_ready ready 1 STD_LOGIC Input
	save_instantiation
	add_component system_clk_iopll ip/board/system_clk_iopll.ip altera_iopll system_clk_iopll
	load_component system_clk_iopll
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
	set_component_parameter_value gui_divide_factor_c0 {1}
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
	set_component_parameter_value gui_multiply_factor {14}
	set_component_parameter_value gui_new_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_number_of_clocks {1}
	set_component_parameter_value gui_operation_mode {direct}
	set_component_parameter_value gui_output_clock_frequency0 {100.0}
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
	set_component_parameter_value gui_output_clock_frequency_ps0 {10000.0}
	set_component_parameter_value gui_output_clock_frequency_ps1 {10000.0}
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
	set_component_parameter_value gui_simulation_type {1}
	set_component_parameter_value gui_skip_sdc_generation {0}
	set_component_parameter_value gui_switchover_delay {0}
	set_component_parameter_value gui_switchover_mode {Automatic Switchover}
	set_component_parameter_value gui_use_NDFB_modes {0}
	set_component_parameter_value gui_use_coreclk {1}
	set_component_parameter_value gui_use_fractional_division {0}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {1400.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation system_clk_iopll
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
	set_instantiation_interface_parameter_value outclk0 clockRate {100000000}
	set_instantiation_interface_parameter_value outclk0 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk0 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk0 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk0 clock_rate {100000000}
	add_instantiation_interface_port outclk0 outclk_0 clk 1 STD_LOGIC Output
	save_instantiation
	add_component system_source ip/board/system_source.ip altera_in_system_sources_probes system_source
	load_component system_source
	set_component_parameter_value create_source_clock {0}
	set_component_parameter_value create_source_clock_enable {0}
	set_component_parameter_value gui_use_auto_index {1}
	set_component_parameter_value instance_id {NONE}
	set_component_parameter_value probe_width {0}
	set_component_parameter_value sld_instance_index {0}
	set_component_parameter_value source_initial_value {0}
	set_component_parameter_value source_width {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation system_source
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.dts.group {ignore}
	set_instantiation_assignment_value embeddedsw.dts.name {debug}
	set_instantiation_assignment_value embeddedsw.dts.vendor {altr}
	add_instantiation_interface sources conduit INPUT
	set_instantiation_interface_parameter_value sources associatedClock {}
	set_instantiation_interface_parameter_value sources associatedReset {}
	set_instantiation_interface_parameter_value sources prSafe {false}
	add_instantiation_interface_port sources source source 1 STD_LOGIC_VECTOR Output
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection clock_in.out_clk/global_reset_in.clk
	set_connection_parameter_value clock_in.out_clk/global_reset_in.clk clockDomainSysInfo {-1}
	set_connection_parameter_value clock_in.out_clk/global_reset_in.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value clock_in.out_clk/global_reset_in.clk clockResetSysInfo {}
	set_connection_parameter_value clock_in.out_clk/global_reset_in.clk resetDomainSysInfo {-1}
	add_connection clock_in.out_clk/kernel_pll.refclk
	set_connection_parameter_value clock_in.out_clk/kernel_pll.refclk clockDomainSysInfo {-1}
	set_connection_parameter_value clock_in.out_clk/kernel_pll.refclk clockRateSysInfo {100000000.0}
	set_connection_parameter_value clock_in.out_clk/kernel_pll.refclk clockResetSysInfo {}
	set_connection_parameter_value clock_in.out_clk/kernel_pll.refclk resetDomainSysInfo {-1}
	add_connection clock_in.out_clk/system_clk_iopll.refclk
	set_connection_parameter_value clock_in.out_clk/system_clk_iopll.refclk clockDomainSysInfo {-1}
	set_connection_parameter_value clock_in.out_clk/system_clk_iopll.refclk clockRateSysInfo {100000000.0}
	set_connection_parameter_value clock_in.out_clk/system_clk_iopll.refclk clockResetSysInfo {}
	set_connection_parameter_value clock_in.out_clk/system_clk_iopll.refclk resetDomainSysInfo {-1}
	add_connection egress_msgdma.mm_write/egress_onchip_memory.s2
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 addressMapSysInfo {<address-map><slave name='egress_onchip_memory.s2' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 addressWidthSysInfo {22}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 arbitrationPriority {1}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 baseAddress {0x00280000}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 cpuInfoIdSysInfo {}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 defaultConnection {0}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 domainAlias {}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value egress_msgdma.mm_write/egress_onchip_memory.s2 slaveDataWidthSysInfo {-1}
	add_connection global_reset_in.out_reset/kernel_pll.reset
	set_connection_parameter_value global_reset_in.out_reset/kernel_pll.reset clockDomainSysInfo {-1}
	set_connection_parameter_value global_reset_in.out_reset/kernel_pll.reset clockResetSysInfo {}
	set_connection_parameter_value global_reset_in.out_reset/kernel_pll.reset resetDomainSysInfo {-1}
	add_connection global_reset_in.out_reset/system_clk_iopll.reset
	set_connection_parameter_value global_reset_in.out_reset/system_clk_iopll.reset clockDomainSysInfo {-1}
	set_connection_parameter_value global_reset_in.out_reset/system_clk_iopll.reset clockResetSysInfo {}
	set_connection_parameter_value global_reset_in.out_reset/system_clk_iopll.reset resetDomainSysInfo {-1}
	add_connection hw_timer_addr_decode.m0/board_hw_timer.s0
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 addressMapSysInfo {<address-map><slave name='board_hw_timer.s0' start='0x0' end='0x800' datawidth='32' /></address-map>}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 addressWidthSysInfo {11}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 arbitrationPriority {1}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 baseAddress {0x0000}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 defaultConnection {0}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 domainAlias {}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hw_timer_addr_decode.m0/board_hw_timer.s0 slaveDataWidthSysInfo {-1}
	add_connection ingress_msgdma.mm_read/ingress_onchip_memory.s2
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 addressMapSysInfo {<address-map><slave name='ingress_onchip_memory.s2' start='0x200000' end='0x280000' datawidth='128' /></address-map>}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 addressWidthSysInfo {22}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 arbitrationPriority {1}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 baseAddress {0x00200000}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 cpuInfoIdSysInfo {}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 defaultConnection {0}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 domainAlias {}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ingress_msgdma.mm_read/ingress_onchip_memory.s2 slaveDataWidthSysInfo {-1}
	add_connection ingress_msgdma.st_source/st_adapter_0.in_0
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value ingress_msgdma.st_source/st_adapter_0.in_0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	add_connection jtag_to_avalon.master/dla_csr_bridge_0.s0
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 baseAddress {0x00038000}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/dla_csr_bridge_1.s0
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 baseAddress {0x00039000}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_1.s0 slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/dla_csr_bridge_2.s0
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 baseAddress {0x0003a000}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_2.s0 slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/dla_csr_bridge_3.s0
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 baseAddress {0x0003b000}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/dla_csr_bridge_3.s0 slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/egress_msgdma.csr
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr baseAddress {0x00030040}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.csr slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/egress_msgdma.descriptor_slave
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave baseAddress {0x00030060}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/egress_msgdma.descriptor_slave slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/egress_onchip_memory.s1
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 baseAddress {0x00280000}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/egress_onchip_memory.s1 slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/hw_timer_addr_decode.s0
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 baseAddress {0x00037000}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/hw_timer_addr_decode.s0 slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/ingress_msgdma.csr
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr baseAddress {0x00030000}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.csr slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/ingress_msgdma.descriptor_slave
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave baseAddress {0x00030020}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/ingress_msgdma.descriptor_slave slaveDataWidthSysInfo {-1}
	add_connection jtag_to_avalon.master/ingress_onchip_memory.s1
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 addressMapSysInfo {<address-map><slave name='ingress_msgdma.csr' start='0x30000' end='0x30020' datawidth='32' /><slave name='ingress_msgdma.descriptor_slave' start='0x30020' end='0x30030' datawidth='128' /><slave name='egress_msgdma.csr' start='0x30040' end='0x30060' datawidth='32' /><slave name='egress_msgdma.descriptor_slave' start='0x30060' end='0x30070' datawidth='128' /><slave name='board_hw_timer.s0' start='0x37000' end='0x37800' datawidth='32' /><slave name='dla_csr_bridge_0.s0' start='0x38000' end='0x38800' datawidth='32' /><slave name='dla_csr_bridge_1.s0' start='0x39000' end='0x39800' datawidth='32' /><slave name='dla_csr_bridge_2.s0' start='0x3A000' end='0x3A800' datawidth='32' /><slave name='dla_csr_bridge_3.s0' start='0x3B000' end='0x3B800' datawidth='32' /><slave name='ingress_onchip_memory.s1' start='0x200000' end='0x280000' datawidth='128' /><slave name='egress_onchip_memory.s1' start='0x280000' end='0x2A0000' datawidth='32' /></address-map>}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 addressWidthSysInfo {22}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 arbitrationPriority {1}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 baseAddress {0x00200000}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 cpuInfoIdSysInfo {}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 defaultConnection {0}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 domainAlias {}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.syncResets {TRUE}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value jtag_to_avalon.master/ingress_onchip_memory.s1 slaveDataWidthSysInfo {-1}
	add_connection kernel_pll.outclk0/board_hw_timer.clk
	set_connection_parameter_value kernel_pll.outclk0/board_hw_timer.clk clockDomainSysInfo {-1}
	set_connection_parameter_value kernel_pll.outclk0/board_hw_timer.clk clockRateSysInfo {600000000.0}
	set_connection_parameter_value kernel_pll.outclk0/board_hw_timer.clk clockResetSysInfo {}
	set_connection_parameter_value kernel_pll.outclk0/board_hw_timer.clk resetDomainSysInfo {-1}
	add_connection kernel_pll.outclk0/board_kernel_clk.in_clk
	set_connection_parameter_value kernel_pll.outclk0/board_kernel_clk.in_clk clockDomainSysInfo {-1}
	set_connection_parameter_value kernel_pll.outclk0/board_kernel_clk.in_clk clockRateSysInfo {600000000.0}
	set_connection_parameter_value kernel_pll.outclk0/board_kernel_clk.in_clk clockResetSysInfo {}
	set_connection_parameter_value kernel_pll.outclk0/board_kernel_clk.in_clk resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/board_hw_timer.reset
	set_connection_parameter_value pll_resetn_in.out_reset/board_hw_timer.reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/board_hw_timer.reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/board_hw_timer.reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/dla_csr_bridge_0.clk_reset
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_0.clk_reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_0.clk_reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_0.clk_reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/dla_csr_bridge_1.clk_reset
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_1.clk_reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_1.clk_reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_1.clk_reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/dla_csr_bridge_2.clk_reset
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_2.clk_reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_2.clk_reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_2.clk_reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/dla_csr_bridge_3.clk_reset
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_3.clk_reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_3.clk_reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/dla_csr_bridge_3.clk_reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/egress_msgdma.reset_n
	set_connection_parameter_value pll_resetn_in.out_reset/egress_msgdma.reset_n clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/egress_msgdma.reset_n clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/egress_msgdma.reset_n resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/egress_onchip_memory.reset1
	set_connection_parameter_value pll_resetn_in.out_reset/egress_onchip_memory.reset1 clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/egress_onchip_memory.reset1 clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/egress_onchip_memory.reset1 resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/hw_timer_addr_decode.reset
	set_connection_parameter_value pll_resetn_in.out_reset/hw_timer_addr_decode.reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/hw_timer_addr_decode.reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/hw_timer_addr_decode.reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/ingress_msgdma.reset_n
	set_connection_parameter_value pll_resetn_in.out_reset/ingress_msgdma.reset_n clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/ingress_msgdma.reset_n clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/ingress_msgdma.reset_n resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/ingress_onchip_memory.reset1
	set_connection_parameter_value pll_resetn_in.out_reset/ingress_onchip_memory.reset1 clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/ingress_onchip_memory.reset1 clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/ingress_onchip_memory.reset1 resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/jtag_to_avalon.clk_reset
	set_connection_parameter_value pll_resetn_in.out_reset/jtag_to_avalon.clk_reset clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/jtag_to_avalon.clk_reset clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/jtag_to_avalon.clk_reset resetDomainSysInfo {-1}
	add_connection pll_resetn_in.out_reset/st_adapter_0.in_rst_0
	set_connection_parameter_value pll_resetn_in.out_reset/st_adapter_0.in_rst_0 clockDomainSysInfo {-1}
	set_connection_parameter_value pll_resetn_in.out_reset/st_adapter_0.in_rst_0 clockResetSysInfo {}
	set_connection_parameter_value pll_resetn_in.out_reset/st_adapter_0.in_rst_0 resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/board_sys_clk.in_clk
	set_connection_parameter_value system_clk_iopll.outclk0/board_sys_clk.in_clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/board_sys_clk.in_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/board_sys_clk.in_clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/board_sys_clk.in_clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/dla_csr_bridge_0.clk
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_0.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/dla_csr_bridge_1.clk
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_1.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_1.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_1.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_1.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/dla_csr_bridge_2.clk
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_2.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_2.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_2.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_2.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/dla_csr_bridge_3.clk
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_3.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_3.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_3.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/dla_csr_bridge_3.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/egress_msgdma.clock
	set_connection_parameter_value system_clk_iopll.outclk0/egress_msgdma.clock clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/egress_msgdma.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/egress_msgdma.clock clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/egress_msgdma.clock resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/egress_onchip_memory.clk1
	set_connection_parameter_value system_clk_iopll.outclk0/egress_onchip_memory.clk1 clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/egress_onchip_memory.clk1 clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/egress_onchip_memory.clk1 clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/egress_onchip_memory.clk1 resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/hw_timer_addr_decode.clk
	set_connection_parameter_value system_clk_iopll.outclk0/hw_timer_addr_decode.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/hw_timer_addr_decode.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/hw_timer_addr_decode.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/hw_timer_addr_decode.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/ingress_msgdma.clock
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_msgdma.clock clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_msgdma.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_msgdma.clock clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_msgdma.clock resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/ingress_onchip_memory.clk1
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_onchip_memory.clk1 clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_onchip_memory.clk1 clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_onchip_memory.clk1 clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/ingress_onchip_memory.clk1 resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/jtag_to_avalon.clk
	set_connection_parameter_value system_clk_iopll.outclk0/jtag_to_avalon.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/jtag_to_avalon.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/jtag_to_avalon.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/jtag_to_avalon.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/pll_resetn_in.clk
	set_connection_parameter_value system_clk_iopll.outclk0/pll_resetn_in.clk clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/pll_resetn_in.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/pll_resetn_in.clk clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/pll_resetn_in.clk resetDomainSysInfo {-1}
	add_connection system_clk_iopll.outclk0/st_adapter_0.in_clk_0
	set_connection_parameter_value system_clk_iopll.outclk0/st_adapter_0.in_clk_0 clockDomainSysInfo {-1}
	set_connection_parameter_value system_clk_iopll.outclk0/st_adapter_0.in_clk_0 clockRateSysInfo {100000000.0}
	set_connection_parameter_value system_clk_iopll.outclk0/st_adapter_0.in_clk_0 clockResetSysInfo {}
	set_connection_parameter_value system_clk_iopll.outclk0/st_adapter_0.in_clk_0 resetDomainSysInfo {-1}

	# add the exports
	set_interface_property dla_hw_timer EXPORT_OF board_hw_timer.m0
	set_interface_property kernel_clk EXPORT_OF board_kernel_clk.out_clk
	set_interface_property sys_pll_clk EXPORT_OF board_sys_clk.out_clk
	set_interface_property clk EXPORT_OF clock_in.in_clk
	set_interface_property csr_axi_bridge_0_m0 EXPORT_OF dla_csr_bridge_0.m0
	set_interface_property csr_axi_bridge_1_m0 EXPORT_OF dla_csr_bridge_1.m0
	set_interface_property csr_axi_bridge_2_m0 EXPORT_OF dla_csr_bridge_2.m0
	set_interface_property csr_axi_bridge_3_m0 EXPORT_OF dla_csr_bridge_3.m0
	set_interface_property egress_st EXPORT_OF egress_msgdma.st_sink
	set_interface_property resetn EXPORT_OF global_reset_in.in_reset
	set_interface_property iopll_locked EXPORT_OF kernel_pll.locked
	set_interface_property pll_resetn_in EXPORT_OF pll_resetn_in.in_reset
	set_interface_property done_resetn EXPORT_OF reset_release_inst.ninit_done
	set_interface_property ingress_st EXPORT_OF st_adapter_0.out_0
	set_interface_property source EXPORT_OF system_source.sources

	# set values for exposed HDL parameters
	set_domain_assignment egress_msgdma.mm_write qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment egress_msgdma.mm_write qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.enableAllPipelines FALSE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.enableEccProtection FALSE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.enableInstrumentation FALSE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment egress_msgdma.mm_write qsys_mm.interconnectType STANDARD
	set_domain_assignment egress_msgdma.mm_write qsys_mm.maxAdditionalLatency 1
	set_domain_assignment egress_msgdma.mm_write qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment egress_msgdma.mm_write qsys_mm.syncResets TRUE
	set_domain_assignment egress_msgdma.mm_write qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.enableAllPipelines FALSE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.enableEccProtection FALSE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.enableInstrumentation FALSE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.interconnectType STANDARD
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.maxAdditionalLatency 1
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.syncResets TRUE
	set_domain_assignment hw_timer_addr_decode.m0 qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.enableAllPipelines FALSE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.enableEccProtection FALSE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.enableInstrumentation FALSE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.interconnectType STANDARD
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.maxAdditionalLatency 1
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.syncResets TRUE
	set_domain_assignment ingress_msgdma.mm_read qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment jtag_to_avalon.master qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment jtag_to_avalon.master qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment jtag_to_avalon.master qsys_mm.enableAllPipelines FALSE
	set_domain_assignment jtag_to_avalon.master qsys_mm.enableEccProtection FALSE
	set_domain_assignment jtag_to_avalon.master qsys_mm.enableInstrumentation FALSE
	set_domain_assignment jtag_to_avalon.master qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment jtag_to_avalon.master qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment jtag_to_avalon.master qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment jtag_to_avalon.master qsys_mm.interconnectType STANDARD
	set_domain_assignment jtag_to_avalon.master qsys_mm.maxAdditionalLatency 1
	set_domain_assignment jtag_to_avalon.master qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment jtag_to_avalon.master qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment jtag_to_avalon.master qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment jtag_to_avalon.master qsys_mm.syncResets TRUE
	set_domain_assignment jtag_to_avalon.master qsys_mm.widthAdapterImplementation GENERIC_CONVERTER

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="board_hw_timer">
  <datum __value="_sortIndex" value="20" type="int" />
 </element>
 <element __value="board_kernel_clk">
  <datum __value="_sortIndex" value="6" type="int" />
 </element>
 <element __value="board_sys_clk">
  <datum __value="_sortIndex" value="7" type="int" />
 </element>
 <element __value="clock_in">
  <datum __value="_sortIndex" value="2" type="int" />
 </element>
 <element __value="dla_csr_bridge_0">
  <datum __value="_sortIndex" value="15" type="int" />
 </element>
 <element __value="dla_csr_bridge_0.s0">
  <datum __value="baseAddress" value="229376" type="String" />
 </element>
 <element __value="dla_csr_bridge_1">
  <datum __value="_sortIndex" value="16" type="int" />
 </element>
 <element __value="dla_csr_bridge_1.s0">
  <datum __value="baseAddress" value="233472" type="String" />
 </element>
 <element __value="dla_csr_bridge_2">
  <datum __value="_sortIndex" value="17" type="int" />
 </element>
 <element __value="dla_csr_bridge_2.s0">
  <datum __value="baseAddress" value="237568" type="String" />
 </element>
 <element __value="dla_csr_bridge_3">
  <datum __value="_sortIndex" value="18" type="int" />
 </element>
 <element __value="dla_csr_bridge_3.s0">
  <datum __value="baseAddress" value="241664" type="String" />
 </element>
 <element __value="egress_msgdma">
  <datum __value="_sortIndex" value="14" type="int" />
 </element>
 <element __value="egress_msgdma.csr">
  <datum __value="baseAddress" value="196672" type="String" />
 </element>
 <element __value="egress_msgdma.descriptor_slave">
  <datum __value="baseAddress" value="196704" type="String" />
 </element>
 <element __value="egress_onchip_memory">
  <datum __value="_sortIndex" value="11" type="int" />
 </element>
 <element __value="egress_onchip_memory.s1">
  <datum __value="baseAddress" value="2621440" type="String" />
 </element>
 <element __value="egress_onchip_memory.s2">
  <datum __value="baseAddress" value="2621440" type="String" />
 </element>
 <element __value="global_reset_in">
  <datum __value="_sortIndex" value="5" type="int" />
 </element>
 <element __value="hw_timer_addr_decode">
  <datum __value="_sortIndex" value="19" type="int" />
 </element>
 <element __value="hw_timer_addr_decode.s0">
  <datum __value="baseAddress" value="225280" type="String" />
 </element>
 <element __value="ingress_msgdma">
  <datum __value="_sortIndex" value="12" type="int" />
 </element>
 <element __value="ingress_msgdma.csr">
  <datum __value="baseAddress" value="196608" type="String" />
 </element>
 <element __value="ingress_msgdma.descriptor_slave">
  <datum __value="baseAddress" value="196640" type="String" />
 </element>
 <element __value="ingress_onchip_memory">
  <datum __value="_sortIndex" value="10" type="int" />
 </element>
 <element __value="ingress_onchip_memory.s1">
  <datum __value="baseAddress" value="2097152" type="String" />
 </element>
 <element __value="ingress_onchip_memory.s2">
  <datum __value="baseAddress" value="2097152" type="String" />
 </element>
 <element __value="jtag_to_avalon">
  <datum __value="_sortIndex" value="9" type="int" />
 </element>
 <element __value="kernel_pll">
  <datum __value="_sortIndex" value="3" type="int" />
 </element>
 <element __value="pll_resetn_in">
  <datum __value="_sortIndex" value="8" type="int" />
 </element>
 <element __value="reset_release_inst">
  <datum __value="_sortIndex" value="1" type="int" />
 </element>
 <element __value="st_adapter_0">
  <datum __value="_sortIndex" value="13" type="int" />
 </element>
 <element __value="system_clk_iopll">
  <datum __value="_sortIndex" value="4" type="int" />
 </element>
 <element __value="system_source">
  <datum __value="_sortIndex" value="0" type="int" />
 </element>
</bonusData>
}
	set_module_property FILE {board.qsys}
	set_module_property GENERATION_ID {0x00000000}
	set_module_property NAME {board}

	# save the system
	sync_sysinfo_parameters
	save_system board
}

proc do_set_exported_interface_sysinfo_parameters {} {
}

# create all the systems, from bottom up
do_create_board

# set system info parameters on exported interface, from bottom up
do_set_exported_interface_sysinfo_parameters

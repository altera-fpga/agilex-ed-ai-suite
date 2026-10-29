package require -exact qsys 26.3

# create the system "system"
proc do_create_system {} {
	# create the system
	create_system system
	set_project_property BOARD {Arria 10 SX SoC Development Kits DK-SOC-10AS066S-D}
	set_project_property DEVICE {10AS066N3F40E2SG}
	set_project_property DEVICE_FAMILY {Arria 10}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component a10_clk_100_0 ip/system/clk_100_0.ip altera_clock_bridge clock_bridge_0
	load_component a10_clk_100_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {100000000.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation a10_clk_100_0
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
	add_instance dla_0 dla
	add_component dla_pll_0 ip/system/system_iopll_0.ip altera_iopll iopll_0
	load_component dla_pll_0
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
	set_component_parameter_value gui_new_mif_file_path {~/pll.mif}
	set_component_parameter_value gui_number_of_clocks {1}
	set_component_parameter_value gui_operation_mode {direct}
	set_component_parameter_value gui_output_clock_frequency0 {200.0}
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
	set_component_parameter_value gui_output_clock_frequency_ps0 {5000.0}
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
	set_component_parameter_value gui_pll_auto_reset {1}
	set_component_parameter_value gui_pll_bandwidth_preset {Low}
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
	set_component_parameter_value gui_use_coreclk {0}
	set_component_parameter_value gui_use_locked {1}
	set_component_parameter_value gui_use_logical {0}
	set_component_parameter_value gui_user_base_address {0}
	set_component_parameter_value gui_usr_device_speed_grade {1}
	set_component_parameter_value gui_vco_frequency {600.0}
	set_component_parameter_value hp_qsys_scripting_mode {0}
	set_component_parameter_value system_info_device_iobank_rev {}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_pll_0
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
	set_instantiation_interface_parameter_value outclk0 clockRate {200000000}
	set_instantiation_interface_parameter_value outclk0 clockRateKnown {true}
	set_instantiation_interface_parameter_value outclk0 externallyDriven {false}
	set_instantiation_interface_parameter_value outclk0 ptfSchematicName {}
	set_instantiation_interface_assignment_value outclk0 ui.blockdiagram.direction {output}
	set_instantiation_interface_sysinfo_parameter_value outclk0 clock_rate {200000000}
	add_instantiation_interface_port outclk0 outclk_0 clk 1 STD_LOGIC Output
	save_instantiation
	add_instance emif_0 emif
	add_component emif_rst_export_0 ip/system/rst_bdg_0.ip altera_reset_bridge rst_bdg_0
	load_component emif_rst_export_0
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation emif_rst_export_0
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
	add_instance hps_0 hps
	add_component rst_bdg ip/system/rst_bdg.ip altera_reset_bridge rst_100_1
	load_component rst_bdg
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rst_bdg
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
	add_component rst_in ip/system/rst_in.ip altera_reset_bridge reset_bridge_0
	load_component rst_in
	set_component_parameter_value ACTIVE_LOW_RESET {1}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation rst_in
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

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection a10_clk_100_0.out_clk/dla_0.csr_clk
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_0.csr_clk clockDomainSysInfo {1}
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_0.csr_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_0.csr_clk clockResetSysInfo {}
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_0.csr_clk resetDomainSysInfo {1}
	add_connection a10_clk_100_0.out_clk/dla_pll_0.refclk
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_pll_0.refclk clockDomainSysInfo {1}
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_pll_0.refclk clockRateSysInfo {100000000.0}
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_pll_0.refclk clockResetSysInfo {}
	set_connection_parameter_value a10_clk_100_0.out_clk/dla_pll_0.refclk resetDomainSysInfo {1}
	add_connection a10_clk_100_0.out_clk/emif_rst_export_0.clk
	set_connection_parameter_value a10_clk_100_0.out_clk/emif_rst_export_0.clk clockDomainSysInfo {1}
	set_connection_parameter_value a10_clk_100_0.out_clk/emif_rst_export_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value a10_clk_100_0.out_clk/emif_rst_export_0.clk clockResetSysInfo {}
	set_connection_parameter_value a10_clk_100_0.out_clk/emif_rst_export_0.clk resetDomainSysInfo {1}
	add_connection a10_clk_100_0.out_clk/hps_0.csr_clk
	set_connection_parameter_value a10_clk_100_0.out_clk/hps_0.csr_clk clockDomainSysInfo {1}
	set_connection_parameter_value a10_clk_100_0.out_clk/hps_0.csr_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value a10_clk_100_0.out_clk/hps_0.csr_clk clockResetSysInfo {}
	set_connection_parameter_value a10_clk_100_0.out_clk/hps_0.csr_clk resetDomainSysInfo {1}
	add_connection a10_clk_100_0.out_clk/rst_bdg.clk
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_bdg.clk clockDomainSysInfo {1}
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_bdg.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_bdg.clk clockResetSysInfo {}
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_bdg.clk resetDomainSysInfo {1}
	add_connection a10_clk_100_0.out_clk/rst_in.clk
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_in.clk clockDomainSysInfo {1}
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_in.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_in.clk clockResetSysInfo {}
	set_connection_parameter_value a10_clk_100_0.out_clk/rst_in.clk resetDomainSysInfo {1}
	add_connection dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 addressMapSysInfo {<address-map><slave name='emif_0.ddr4_emif.ctrl_amm_0' start='0x0' end='0x80000000' datawidth='512' /></address-map>}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 addressWidthSysInfo {31}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 arbitrationPriority {1}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 baseAddress {0x0000}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 defaultConnection {0}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 domainAlias {}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla_0.dla_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 slaveDataWidthSysInfo {-1}
	add_connection dla_pll_0.outclk0/dla_0.dla_clk
	set_connection_parameter_value dla_pll_0.outclk0/dla_0.dla_clk clockDomainSysInfo {2}
	set_connection_parameter_value dla_pll_0.outclk0/dla_0.dla_clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value dla_pll_0.outclk0/dla_0.dla_clk clockResetSysInfo {}
	set_connection_parameter_value dla_pll_0.outclk0/dla_0.dla_clk resetDomainSysInfo {2}
	add_connection emif_0.ddr4_emif_emif_usr_clk/dla_0.ddr_clk
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_clk/dla_0.ddr_clk clockDomainSysInfo {3}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_clk/dla_0.ddr_clk clockRateSysInfo {266666665.0}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_clk/dla_0.ddr_clk clockResetSysInfo {}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_clk/dla_0.ddr_clk resetDomainSysInfo {3}
	add_connection emif_0.ddr4_emif_emif_usr_reset_n/dla_0.ddr_rst
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_reset_n/dla_0.ddr_rst clockDomainSysInfo {4}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_reset_n/dla_0.ddr_rst clockResetSysInfo {}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_reset_n/dla_0.ddr_rst resetDomainSysInfo {4}
	add_connection emif_0.ddr4_emif_emif_usr_reset_n/rst_bdg.in_reset
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_reset_n/rst_bdg.in_reset clockDomainSysInfo {4}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_reset_n/rst_bdg.in_reset clockResetSysInfo {}
	set_connection_parameter_value emif_0.ddr4_emif_emif_usr_reset_n/rst_bdg.in_reset resetDomainSysInfo {4}
	add_connection hps_0.a10_hps_h2f_reset/dla_0.csr_rst
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/dla_0.csr_rst clockDomainSysInfo {5}
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/dla_0.csr_rst clockResetSysInfo {<info><reset name="csr_rst" domain="0" /></info>}
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/dla_0.csr_rst resetDomainSysInfo {5}
	add_connection hps_0.a10_hps_h2f_reset/hps_0.csr_rst
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/hps_0.csr_rst clockDomainSysInfo {5}
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/hps_0.csr_rst clockResetSysInfo {<info><reset name="csr_rst" domain="0" /></info>}
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/hps_0.csr_rst resetDomainSysInfo {5}
	add_connection hps_0.a10_hps_h2f_reset/rst_bdg.in_reset
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/rst_bdg.in_reset clockDomainSysInfo {5}
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/rst_bdg.in_reset clockResetSysInfo {<info><reset name="in_reset" domain="0" /></info>}
	set_connection_parameter_value hps_0.a10_hps_h2f_reset/rst_bdg.in_reset resetDomainSysInfo {5}
	add_connection hps_0.dla_irq/dla_0.dla_irq
	set_connection_parameter_value hps_0.dla_irq/dla_0.dla_irq interruptsUsedSysInfo {1}
	set_connection_parameter_value hps_0.dla_irq/dla_0.dla_irq irqNumber {0}
	add_connection hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 addressMapSysInfo {<address-map><slave name='emif_0.ddr4_emif.ctrl_amm_0' start='0x0' end='0x80000000' datawidth='512' /></address-map>}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 addressWidthSysInfo {31}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 arbitrationPriority {1}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 baseAddress {0x0000}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 defaultConnection {0}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 domainAlias {}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_0.dma_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 slaveDataWidthSysInfo {-1}
	add_connection hps_0.hps_to_csr/dla_0.csr_bridge
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge addressMapSysInfo {<address-map><slave name='dla_0/dla_a10_altera_ai_ip_0.csr_axi' start='0x4000' end='0x4800' datawidth='32' /></address-map>}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge addressWidthSysInfo {16}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge arbitrationPriority {1}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge baseAddress {0x0000}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge defaultConnection {0}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge domainAlias {}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_0.hps_to_csr/dla_0.csr_bridge slaveDataWidthSysInfo {32}
	add_connection hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 addressMapSysInfo {<address-map><slave name='emif_0.ddr4_emif.ctrl_amm_0' start='0x0' end='0x80000000' datawidth='512' /></address-map>}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 addressWidthSysInfo {31}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 arbitrationPriority {1}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 baseAddress {0x0000}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 defaultConnection {0}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 domainAlias {}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.maxAdditionalLatency {1}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_0.hps_to_ddr/emif_0.ddr4_emif_ctrl_amm_0 slaveDataWidthSysInfo {-1}
	add_connection rst_in.out_reset/dla_0.csr_rst
	set_connection_parameter_value rst_in.out_reset/dla_0.csr_rst clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/dla_0.csr_rst clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/dla_0.csr_rst resetDomainSysInfo {6}
	add_connection rst_in.out_reset/dla_pll_0.reset
	set_connection_parameter_value rst_in.out_reset/dla_pll_0.reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/dla_pll_0.reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/dla_pll_0.reset resetDomainSysInfo {6}
	add_connection rst_in.out_reset/emif_rst_export_0.in_reset
	set_connection_parameter_value rst_in.out_reset/emif_rst_export_0.in_reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/emif_rst_export_0.in_reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/emif_rst_export_0.in_reset resetDomainSysInfo {6}
	add_connection rst_in.out_reset/hps_0.csr_rst
	set_connection_parameter_value rst_in.out_reset/hps_0.csr_rst clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/hps_0.csr_rst clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/hps_0.csr_rst resetDomainSysInfo {6}
	add_connection rst_in.out_reset/rst_bdg.in_reset
	set_connection_parameter_value rst_in.out_reset/rst_bdg.in_reset clockDomainSysInfo {6}
	set_connection_parameter_value rst_in.out_reset/rst_bdg.in_reset clockResetSysInfo {}
	set_connection_parameter_value rst_in.out_reset/rst_bdg.in_reset resetDomainSysInfo {6}

	# add the exports
	set_interface_property clk_100 EXPORT_OF a10_clk_100_0.in_clk
	set_interface_property dla_pll_locked EXPORT_OF dla_pll_0.locked
	set_interface_property ddr4_emif_usr_reset_n EXPORT_OF emif_rst_export_0.out_reset
	set_interface_property hps_fpga_reset EXPORT_OF rst_bdg.out_reset
	set_interface_property reset EXPORT_OF rst_in.in_reset
	set_interface_property dla_0_dla_resetn EXPORT_OF dla_0.dla_resetn
	set_interface_property ddr4_emif_global_reset_n EXPORT_OF emif_0.ddr4_emif_global_reset_n
	set_interface_property ddr4_emif_pll_ref_clk EXPORT_OF emif_0.ddr4_emif_pll_ref_clk
	set_interface_property ddr4_emif_pll_locked EXPORT_OF emif_0.ddr4_emif_pll_locked
	set_interface_property ddr4_emif_oct EXPORT_OF emif_0.ddr4_emif_oct
	set_interface_property ddr4_emif_mem EXPORT_OF emif_0.ddr4_emif_mem
	set_interface_property ddr4_emif_status EXPORT_OF emif_0.ddr4_emif_status
	set_interface_property hps_0_a10_hps_f2h_cold_reset_req EXPORT_OF hps_0.a10_hps_f2h_cold_reset_req
	set_interface_property hps_0_a10_hps_f2h_debug_reset_req EXPORT_OF hps_0.a10_hps_f2h_debug_reset_req
	set_interface_property hps_0_a10_hps_f2h_warm_reset_req EXPORT_OF hps_0.a10_hps_f2h_warm_reset_req
	set_interface_property hps_0_a10_hps_f2h_stm_hw_events EXPORT_OF hps_0.a10_hps_f2h_stm_hw_events
	set_interface_property hps_io EXPORT_OF hps_0.a10_hps_hps_io
	set_interface_property hps_0_emif_a10_hps_pll_ref_clk_clock_sink EXPORT_OF hps_0.emif_a10_hps_pll_ref_clk_clock_sink
	set_interface_property hps_0_emif_a10_hps_oct_conduit_end EXPORT_OF hps_0.emif_a10_hps_oct_conduit_end
	set_interface_property hps_0_emif_a10_hps_mem_conduit_end EXPORT_OF hps_0.emif_a10_hps_mem_conduit_end

	# set values for exposed HDL parameters
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.enableAllPipelines FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.enableEccProtection FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.enableInstrumentation FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.interconnectType STANDARD
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.maxAdditionalLatency 1
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.syncResets FALSE
	set_domain_assignment dla_0.dla_to_ddr qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps_0.hps_to_csr qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment hps_0.hps_to_csr qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.enableAllPipelines FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.enableEccProtection FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.enableInstrumentation FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment hps_0.hps_to_csr qsys_mm.interconnectType STANDARD
	set_domain_assignment hps_0.hps_to_csr qsys_mm.maxAdditionalLatency 1
	set_domain_assignment hps_0.hps_to_csr qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment hps_0.hps_to_csr qsys_mm.syncResets FALSE
	set_domain_assignment hps_0.hps_to_csr qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_postadaptation_assignment mm_interconnect_0|cmd_mux.src/emif_0_ddr4_emif_ctrl_amm_0_burst_adapter.sink0 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|crosser.out/cmd_mux.sink0 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|crosser_001.out/cmd_mux.sink1 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|crosser_002.out/cmd_mux.sink3 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|crosser_003.out/rsp_mux.sink0 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|crosser_004.out/rsp_mux_001.sink0 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|crosser_005.out/rsp_mux_003.sink0 qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|emif_0_ddr4_emif_ctrl_amm_0_burst_adapter.source0/emif_0_ddr4_emif_ctrl_amm_0_agent.cp qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|hps_0_hps_to_ddr_rd_cmd_width_adapter.src/cmd_demux_001.sink qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|hps_0_hps_to_ddr_wr_cmd_width_adapter.src/cmd_demux.sink qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|router_002.src/cmd_demux_002.sink qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|router_003.src/hps_0_dma_to_ddr_cmd_width_adapter.sink qsys_mm.postTransform.pipelineCount 1
	set_postadaptation_assignment mm_interconnect_0|rsp_mux_002.src/dla_0_dla_to_ddr_agent.rp qsys_mm.postTransform.pipelineCount 1

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="a10_clk_100_0">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_0">
  <datum __value="_sortIndex" value="6" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_pll_0">
  <datum __value="_sortIndex" value="7" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="emif_0">
  <datum __value="_sortIndex" value="4" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="emif_rst_export_0">
  <datum __value="_sortIndex" value="3" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_0">
  <datum __value="_sortIndex" value="5" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="rst_bdg">
  <datum __value="_sortIndex" value="2" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="rst_in">
  <datum __value="_sortIndex" value="1" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
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
	set_project_property BOARD {Arria 10 SX SoC Development Kits DK-SOC-10AS066S-D}
	set_project_property DEVICE {10AS066N3F40E2SG}
	set_project_property DEVICE_FAMILY {Arria 10}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component dla_a10_csr_clk_0 ip/dla/dla_csr_clk_0.ip altera_clock_bridge clock_bridge_0
	load_component dla_a10_csr_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_a10_csr_clk_0
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
	add_component dla_a10_altera_ai_ip_0 ip/dla/dla_a10_altera_ai_ip_0.ip altera_ai_ip altera_ai_ip_0
	load_component dla_a10_altera_ai_ip_0
	set_component_parameter_value ARCH_OPTION {A10_Performance_A10}
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
	load_instantiation dla_a10_altera_ai_ip_0
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
	set_instantiation_interface_parameter_value csr_axi associatedClock {ddr_clk}
	set_instantiation_interface_parameter_value csr_axi associatedReset {dla_resetn}
	set_instantiation_interface_parameter_value csr_axi bridgesToMaster {}
	set_instantiation_interface_parameter_value csr_axi combinedAcceptanceCapability {1}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureId {35}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value csr_axi dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value csr_axi dfhGroupId {0}
	set_instantiation_interface_parameter_value csr_axi dfhParameterData {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterDataLength {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterId {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterName {}
	set_instantiation_interface_parameter_value csr_axi dfhParameterVersion {}
	set_instantiation_interface_parameter_value csr_axi maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value csr_axi maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value csr_axi maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value csr_axi poison {false}
	set_instantiation_interface_parameter_value csr_axi readAcceptanceCapability {1}
	set_instantiation_interface_parameter_value csr_axi readDataReorderingDepth {1}
	set_instantiation_interface_parameter_value csr_axi traceSignals {false}
	set_instantiation_interface_parameter_value csr_axi trustzoneAware {true}
	set_instantiation_interface_parameter_value csr_axi uniqueIdSupport {false}
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
	set_instantiation_interface_parameter_value ddr_axi associatedClock {ddr_clk}
	set_instantiation_interface_parameter_value ddr_axi associatedReset {dla_resetn}
	set_instantiation_interface_parameter_value ddr_axi combinedIssuingCapability {16}
	set_instantiation_interface_parameter_value ddr_axi issuesFIXEDBursts {false}
	set_instantiation_interface_parameter_value ddr_axi issuesINCRBursts {true}
	set_instantiation_interface_parameter_value ddr_axi issuesWRAPBursts {false}
	set_instantiation_interface_parameter_value ddr_axi maximumOutstandingReads {1}
	set_instantiation_interface_parameter_value ddr_axi maximumOutstandingTransactions {1}
	set_instantiation_interface_parameter_value ddr_axi maximumOutstandingWrites {1}
	set_instantiation_interface_parameter_value ddr_axi poison {false}
	set_instantiation_interface_parameter_value ddr_axi readIssuingCapability {16}
	set_instantiation_interface_parameter_value ddr_axi traceSignals {false}
	set_instantiation_interface_parameter_value ddr_axi trustzoneAware {true}
	set_instantiation_interface_parameter_value ddr_axi uniqueIdSupport {false}
	set_instantiation_interface_parameter_value ddr_axi wakeupSignals {false}
	set_instantiation_interface_parameter_value ddr_axi writeIssuingCapability {16}
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
	add_instantiation_interface_port ddr_axi ddr_axi_rdata rdata 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ddr_axi ddr_axi_rid rid 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ddr_axi ddr_axi_wdata wdata 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ddr_axi ddr_axi_wstrb wstrb 64 STD_LOGIC_VECTOR Output
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
	add_component dla_clk_0 ip/dla/dla_clock_bridge_0.ip altera_clock_bridge clock_bridge_0
	load_component dla_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_clk_0
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
	add_component dla_csr_bridge_0 ip/dla/dla_csr_bridge_0.ip altera_avalon_mm_bridge mm_bridge_0
	load_component dla_csr_bridge_0
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {16}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {1}
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
	load_instantiation dla_csr_bridge_0
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
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value m0 writeWaitTime {0}
	add_instantiation_interface_port m0 m0_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_readdata readdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_burstcount burstcount 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 16 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component dla_csr_rst_0 ip/dla/dla_csr_rst_0.ip altera_reset_bridge reset_bridge_0
	load_component dla_csr_rst_0
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_csr_rst_0
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
	add_component dla_ddr_bridge_0 ip/dla/dla_ddr_bridge_0.ip altera_avalon_mm_bridge csr_bridge_1
	load_component dla_ddr_bridge_0
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {31}
	set_component_parameter_value DATA_WIDTH {512}
	set_component_parameter_value LINEWRAPBURSTS {0}
	set_component_parameter_value M0_WAITREQUEST_ALLOWANCE {0}
	set_component_parameter_value MAX_BURST_SIZE {16}
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
	load_instantiation dla_ddr_bridge_0
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
	set_instantiation_interface_parameter_value s0 addressSpan {2147483648}
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
	add_instantiation_interface_port s0 s0_readdata readdata 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port s0 s0_readdatavalid readdatavalid 1 STD_LOGIC Output
	add_instantiation_interface_port s0 s0_burstcount burstcount 5 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_writedata writedata 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_address address 31 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port s0 s0_write write 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_read read 1 STD_LOGIC Input
	add_instantiation_interface_port s0 s0_byteenable byteenable 64 STD_LOGIC_VECTOR Input
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
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value m0 writeWaitTime {0}
	add_instantiation_interface_port m0 m0_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_readdata readdata 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_burstcount burstcount 5 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 31 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 64 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation
	add_component dla_ddr_clk_0 ip/dla/dla_ddr_clk_0.ip altera_clock_bridge csr_clk_1
	load_component dla_ddr_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_ddr_clk_0
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface in_clk clock INPUT
	set_instantiation_interface_parameter_value in_clk clockRate {266666665}
	set_instantiation_interface_parameter_value in_clk externallyDriven {false}
	set_instantiation_interface_parameter_value in_clk ptfSchematicName {}
	add_instantiation_interface_port in_clk in_clk clk 1 STD_LOGIC Input
	add_instantiation_interface out_clk clock OUTPUT
	set_instantiation_interface_parameter_value out_clk associatedDirectClock {in_clk}
	set_instantiation_interface_parameter_value out_clk clockRate {266666665}
	set_instantiation_interface_parameter_value out_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value out_clk externallyDriven {false}
	set_instantiation_interface_parameter_value out_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value out_clk clock_rate {266666665}
	add_instantiation_interface_port out_clk out_clk clk 1 STD_LOGIC Output
	save_instantiation
	add_component dla_ddr_rst_0 ip/dla/dla_ddr_rst_0.ip altera_reset_bridge csr_rst_1
	load_component dla_ddr_rst_0
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation dla_ddr_rst_0
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
	add_component dla_rst_0 ip/dla/ddr_rst_1.ip altera_reset_bridge ddr_rst_1
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

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection dla_a10_csr_clk_0.out_clk/dla_a10_altera_ai_ip_0.irq_clk
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_a10_altera_ai_ip_0.irq_clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_a10_altera_ai_ip_0.irq_clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_a10_altera_ai_ip_0.irq_clk clockResetSysInfo {}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_a10_altera_ai_ip_0.irq_clk resetDomainSysInfo {-1}
	add_connection dla_a10_csr_clk_0.out_clk/dla_csr_bridge_0.clk
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_bridge_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_bridge_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_bridge_0.clk resetDomainSysInfo {-1}
	add_connection dla_a10_csr_clk_0.out_clk/dla_csr_rst_0.clk
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_rst_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_rst_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_csr_rst_0.clk resetDomainSysInfo {-1}
	add_connection dla_a10_csr_clk_0.out_clk/dla_rst_0.clk
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_rst_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_rst_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value dla_a10_csr_clk_0.out_clk/dla_rst_0.clk resetDomainSysInfo {-1}
	add_connection dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 addressMapSysInfo {}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 addressWidthSysInfo {31}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 baseAddress {0x0000}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 domainAlias {}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.burstAdapterImplementation {PER_BURST_TYPE_CONVERTER}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla_a10_altera_ai_ip_0.ddr_axi/dla_ddr_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection dla_clk_0.out_clk/dla_a10_altera_ai_ip_0.dla_clk
	set_connection_parameter_value dla_clk_0.out_clk/dla_a10_altera_ai_ip_0.dla_clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_clk_0.out_clk/dla_a10_altera_ai_ip_0.dla_clk clockRateSysInfo {200000000.0}
	set_connection_parameter_value dla_clk_0.out_clk/dla_a10_altera_ai_ip_0.dla_clk clockResetSysInfo {}
	set_connection_parameter_value dla_clk_0.out_clk/dla_a10_altera_ai_ip_0.dla_clk resetDomainSysInfo {-1}
	add_connection dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi addressMapSysInfo {}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi addressWidthSysInfo {15}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi arbitrationPriority {1}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi baseAddress {0x4000}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi defaultConnection {0}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi domainAlias {}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.maxAdditionalLatency {2}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.syncResets {FALSE}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value dla_csr_bridge_0.m0/dla_a10_altera_ai_ip_0.csr_axi slaveDataWidthSysInfo {-1}
	add_connection dla_csr_rst_0.out_reset/dla_csr_bridge_0.reset
	set_connection_parameter_value dla_csr_rst_0.out_reset/dla_csr_bridge_0.reset clockDomainSysInfo {-1}
	set_connection_parameter_value dla_csr_rst_0.out_reset/dla_csr_bridge_0.reset clockResetSysInfo {}
	set_connection_parameter_value dla_csr_rst_0.out_reset/dla_csr_bridge_0.reset resetDomainSysInfo {-1}
	add_connection dla_ddr_clk_0.out_clk/dla_a10_altera_ai_ip_0.ddr_clk
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_a10_altera_ai_ip_0.ddr_clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_a10_altera_ai_ip_0.ddr_clk clockRateSysInfo {266666665.0}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_a10_altera_ai_ip_0.ddr_clk clockResetSysInfo {}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_a10_altera_ai_ip_0.ddr_clk resetDomainSysInfo {-1}
	add_connection dla_ddr_clk_0.out_clk/dla_ddr_bridge_0.clk
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_bridge_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_bridge_0.clk clockRateSysInfo {266666665.0}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_bridge_0.clk resetDomainSysInfo {-1}
	add_connection dla_ddr_clk_0.out_clk/dla_ddr_rst_0.clk
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_rst_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_rst_0.clk clockRateSysInfo {266666665.0}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value dla_ddr_clk_0.out_clk/dla_ddr_rst_0.clk resetDomainSysInfo {-1}
	add_connection dla_ddr_rst_0.out_reset/dla_ddr_bridge_0.reset
	set_connection_parameter_value dla_ddr_rst_0.out_reset/dla_ddr_bridge_0.reset clockDomainSysInfo {-1}
	set_connection_parameter_value dla_ddr_rst_0.out_reset/dla_ddr_bridge_0.reset clockResetSysInfo {}
	set_connection_parameter_value dla_ddr_rst_0.out_reset/dla_ddr_bridge_0.reset resetDomainSysInfo {-1}
	add_connection dla_rst_0.out_reset/dla_a10_altera_ai_ip_0.dla_resetn
	set_connection_parameter_value dla_rst_0.out_reset/dla_a10_altera_ai_ip_0.dla_resetn clockDomainSysInfo {-1}
	set_connection_parameter_value dla_rst_0.out_reset/dla_a10_altera_ai_ip_0.dla_resetn clockResetSysInfo {}
	set_connection_parameter_value dla_rst_0.out_reset/dla_a10_altera_ai_ip_0.dla_resetn resetDomainSysInfo {-1}

	# add the exports
	set_interface_property csr_clk EXPORT_OF dla_a10_csr_clk_0.in_clk
	set_interface_property dla_irq EXPORT_OF dla_a10_altera_ai_ip_0.irq_level
	set_interface_property dla_clk EXPORT_OF dla_clk_0.in_clk
	set_interface_property csr_bridge EXPORT_OF dla_csr_bridge_0.s0
	set_interface_property csr_rst EXPORT_OF dla_csr_rst_0.in_reset
	set_interface_property dla_to_ddr EXPORT_OF dla_ddr_bridge_0.m0
	set_interface_property ddr_clk EXPORT_OF dla_ddr_clk_0.in_clk
	set_interface_property ddr_rst EXPORT_OF dla_ddr_rst_0.in_reset
	set_interface_property dla_resetn EXPORT_OF dla_rst_0.in_reset

	# set values for exposed HDL parameters
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.burstAdapterImplementation PER_BURST_TYPE_CONVERTER
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.enableAllPipelines FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.enableEccProtection FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.enableInstrumentation FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.interconnectType STANDARD
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.maxAdditionalLatency 3
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.syncResets FALSE
	set_domain_assignment dla_a10_altera_ai_ip_0.ddr_axi qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.enableAllPipelines FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.enableEccProtection FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.enableInstrumentation FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.interconnectType STANDARD
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.maxAdditionalLatency 2
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.syncResets FALSE
	set_domain_assignment dla_csr_bridge_0.m0 qsys_mm.widthAdapterImplementation GENERIC_CONVERTER

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="dla_a10_csr_clk_0">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_a10_altera_ai_ip_0">
  <datum __value="_sortIndex" value="4" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_a10_altera_ai_ip_0.csr_axi">
  <datum __value="_lockedAddress" value="1" type="boolean" />
  <datum __value="baseAddress" value="16384" type="String" />
 </element>
 <element __value="dla_clk_0">
  <datum __value="_sortIndex" value="8" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_csr_bridge_0">
  <datum __value="_sortIndex" value="6" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_csr_rst_0">
  <datum __value="_sortIndex" value="1" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_ddr_bridge_0">
  <datum __value="_sortIndex" value="7" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_ddr_bridge_0.s0">
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="dla_ddr_clk_0">
  <datum __value="_sortIndex" value="2" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_ddr_rst_0">
  <datum __value="_sortIndex" value="3" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="dla_rst_0">
  <datum __value="_sortIndex" value="5" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
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
	set_project_property BOARD {Arria 10 SX SoC Development Kits DK-SOC-10AS066S-D}
	set_project_property DEVICE {10AS066N3F40E2SG}
	set_project_property DEVICE_FAMILY {Arria 10}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_component ddr4_emif ip/emif/ddr4_emif.ip altera_emif emif_0
	load_component ddr4_emif
	set_component_parameter_value BOARD_DDR3_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_DDR3_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR3_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR3_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_DDR3_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_DDR3_IS_SKEW_WITHIN_DQS_DESKEWED {0}
	set_component_parameter_value BOARD_DDR3_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR3_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR3_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR3_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR3_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_DDR3_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR3_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR3_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR3_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_RCLK_SLEW_RATE {5.0}
	set_component_parameter_value BOARD_DDR3_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_RDATA_SLEW_RATE {2.5}
	set_component_parameter_value BOARD_DDR3_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR3_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR3_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_DDR3_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_DDR4_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_DDR4_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR4_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR4_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_DDR4_IS_SKEW_WITHIN_AC_DESKEWED {0}
	set_component_parameter_value BOARD_DDR4_IS_SKEW_WITHIN_DQS_DESKEWED {1}
	set_component_parameter_value BOARD_DDR4_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR4_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR4_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR4_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR4_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_DDR4_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR4_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR4_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR4_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_RCLK_SLEW_RATE {8.0}
	set_component_parameter_value BOARD_DDR4_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_RDATA_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR4_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR4_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR4_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_DDR4_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_DDRT_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_DDRT_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDRT_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDRT_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_DDRT_IS_SKEW_WITHIN_AC_DESKEWED {0}
	set_component_parameter_value BOARD_DDRT_IS_SKEW_WITHIN_DQS_DESKEWED {1}
	set_component_parameter_value BOARD_DDRT_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDRT_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDRT_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDRT_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDRT_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_DDRT_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDRT_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDRT_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDRT_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_RCLK_SLEW_RATE {8.0}
	set_component_parameter_value BOARD_DDRT_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_RDATA_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDRT_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDRT_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDRT_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_DDRT_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_LPDDR3_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_LPDDR3_IS_SKEW_WITHIN_DQS_DESKEWED {0}
	set_component_parameter_value BOARD_LPDDR3_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_LPDDR3_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_LPDDR3_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_LPDDR3_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_LPDDR3_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_LPDDR3_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_LPDDR3_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_QDR2_AC_TO_K_SKEW_NS {0.0}
	set_component_parameter_value BOARD_QDR2_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR2_BRD_SKEW_WITHIN_D_NS {0.02}
	set_component_parameter_value BOARD_QDR2_BRD_SKEW_WITHIN_Q_NS {0.02}
	set_component_parameter_value BOARD_QDR2_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_QDR2_IS_SKEW_WITHIN_D_DESKEWED {0}
	set_component_parameter_value BOARD_QDR2_IS_SKEW_WITHIN_Q_DESKEWED {0}
	set_component_parameter_value BOARD_QDR2_MAX_K_DELAY_NS {0.6}
	set_component_parameter_value BOARD_QDR2_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR2_PKG_BRD_SKEW_WITHIN_D_NS {0.02}
	set_component_parameter_value BOARD_QDR2_PKG_BRD_SKEW_WITHIN_Q_NS {0.02}
	set_component_parameter_value BOARD_QDR2_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR2_USER_K_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR2_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_RCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR2_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_RDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR2_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR2_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_QDR2_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_QDR4_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_QDR4_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR4_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_QDR4_DK_TO_CK_SKEW_NS {-0.02}
	set_component_parameter_value BOARD_QDR4_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_QDR4_IS_SKEW_WITHIN_QK_DESKEWED {1}
	set_component_parameter_value BOARD_QDR4_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_QDR4_MAX_DK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_QDR4_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR4_PKG_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_QDR4_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_QDR4_SKEW_BETWEEN_DK_NS {0.02}
	set_component_parameter_value BOARD_QDR4_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR4_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR4_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_RCLK_SLEW_RATE {5.0}
	set_component_parameter_value BOARD_QDR4_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_RDATA_SLEW_RATE {2.5}
	set_component_parameter_value BOARD_QDR4_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR4_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR4_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_QDR4_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_RLD3_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_RLD3_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_RLD3_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_RLD3_DK_TO_CK_SKEW_NS {-0.02}
	set_component_parameter_value BOARD_RLD3_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_RLD3_IS_SKEW_WITHIN_QK_DESKEWED {0}
	set_component_parameter_value BOARD_RLD3_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_RLD3_MAX_DK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_RLD3_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_RLD3_PKG_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_RLD3_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_RLD3_SKEW_BETWEEN_DK_NS {0.02}
	set_component_parameter_value BOARD_RLD3_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_RLD3_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_RLD3_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_RCLK_SLEW_RATE {7.0}
	set_component_parameter_value BOARD_RLD3_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_RDATA_SLEW_RATE {3.5}
	set_component_parameter_value BOARD_RLD3_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_RLD3_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_RLD3_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_RLD3_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value CTRL_DDR3_ADDR_ORDER_ENUM {DDR3_CTRL_ADDR_ORDER_CS_R_B_C}
	set_component_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_DDR3_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_DDR3_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_DDR3_ECC_AUTO_CORRECTION_EN {0}
	set_component_parameter_value CTRL_DDR3_ECC_EN {0}
	set_component_parameter_value CTRL_DDR3_ECC_READDATAERROR_EN {0}
	set_component_parameter_value CTRL_DDR3_ECC_STATUS_EN {0}
	set_component_parameter_value CTRL_DDR3_MMR_EN {0}
	set_component_parameter_value CTRL_DDR3_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_REORDER_EN {1}
	set_component_parameter_value CTRL_DDR3_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR3_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_DDR3_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_DDR3_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR3_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_ADDR_ORDER_ENUM {DDR4_CTRL_ADDR_ORDER_CS_R_B_C_BG}
	set_component_parameter_value CTRL_DDR4_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_DDR4_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_DDR4_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_DDR4_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_DDR4_ECC_AUTO_CORRECTION_EN {0}
	set_component_parameter_value CTRL_DDR4_ECC_EN {0}
	set_component_parameter_value CTRL_DDR4_ECC_READDATAERROR_EN {0}
	set_component_parameter_value CTRL_DDR4_ECC_STATUS_EN {0}
	set_component_parameter_value CTRL_DDR4_MAJOR_MODE_EN {0}
	set_component_parameter_value CTRL_DDR4_MMR_EN {0}
	set_component_parameter_value CTRL_DDR4_POST_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_POST_REFRESH_LOWER_LIMIT {0}
	set_component_parameter_value CTRL_DDR4_POST_REFRESH_UPPER_LIMIT {2}
	set_component_parameter_value CTRL_DDR4_PRE_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_PRE_REFRESH_UPPER_LIMIT {1}
	set_component_parameter_value CTRL_DDR4_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_REORDER_EN {1}
	set_component_parameter_value CTRL_DDR4_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_DDR4_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_DDR4_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_ADDR_INTERLEAVING {COARSE}
	set_component_parameter_value CTRL_DDRT_ADDR_ORDER_ENUM {DDRT_CTRL_ADDR_ORDER_CS_R_B_C_BG}
	set_component_parameter_value CTRL_DDRT_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_DDRT_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_DDRT_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_DDRT_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_DDRT_DIMM_DENSITY {128}
	set_component_parameter_value CTRL_DDRT_DIMM_VIRAL_FLOW_EN {0}
	set_component_parameter_value CTRL_DDRT_ECC_AUTO_CORRECTION_EN {0}
	set_component_parameter_value CTRL_DDRT_ECC_EN {0}
	set_component_parameter_value CTRL_DDRT_ECC_READDATAERROR_EN {1}
	set_component_parameter_value CTRL_DDRT_ECC_STATUS_EN {1}
	set_component_parameter_value CTRL_DDRT_ERR_INJECT_EN {0}
	set_component_parameter_value CTRL_DDRT_ERR_REPLAY_EN {0}
	set_component_parameter_value CTRL_DDRT_EXT_ERR_INJECT_EN {0}
	set_component_parameter_value CTRL_DDRT_GNT_TO_GNT_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_GNT_TO_WR_DIFF_CHIP_DELTA_CYCS {1}
	set_component_parameter_value CTRL_DDRT_GNT_TO_WR_SAME_CHIP_DELTA_CYCS {1}
	set_component_parameter_value CTRL_DDRT_HOST_VIRAL_FLOW_EN {0}
	set_component_parameter_value CTRL_DDRT_MMR_EN {0}
	set_component_parameter_value CTRL_DDRT_NUM_OF_AXIS_ID {1}
	set_component_parameter_value CTRL_DDRT_PARITY_CMD_EN {0}
	set_component_parameter_value CTRL_DDRT_PMM_ADR_FLOW_EN {0}
	set_component_parameter_value CTRL_DDRT_PMM_WPQ_FLUSH_EN {0}
	set_component_parameter_value CTRL_DDRT_POISON_DETECTION_EN {0}
	set_component_parameter_value CTRL_DDRT_PORT_AFI_C_WIDTH {2}
	set_component_parameter_value CTRL_DDRT_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_REORDER_EN {1}
	set_component_parameter_value CTRL_DDRT_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDRT_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_DDRT_UPI_EN {0}
	set_component_parameter_value CTRL_DDRT_UPI_ID_WIDTH {8}
	set_component_parameter_value CTRL_DDRT_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_DDRT_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDRT_WR_ACK_POLICY {POSTED}
	set_component_parameter_value CTRL_DDRT_WR_TO_GNT_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_GNT_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_ZQ_INTERVAL_MS {3}
	set_component_parameter_value CTRL_LPDDR3_ADDR_ORDER_ENUM {LPDDR3_CTRL_ADDR_ORDER_CS_R_B_C}
	set_component_parameter_value CTRL_LPDDR3_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_LPDDR3_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_LPDDR3_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_LPDDR3_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_LPDDR3_MMR_EN {0}
	set_component_parameter_value CTRL_LPDDR3_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_REORDER_EN {1}
	set_component_parameter_value CTRL_LPDDR3_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_LPDDR3_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_LPDDR3_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_LPDDR3_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_LPDDR3_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_QDR2_AVL_ENABLE_POWER_OF_TWO_BUS {0}
	set_component_parameter_value CTRL_QDR2_AVL_MAX_BURST_COUNT {4}
	set_component_parameter_value CTRL_QDR2_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_QDR4_ADD_RAW_TURNAROUND_DELAY_CYC {0}
	set_component_parameter_value CTRL_QDR4_ADD_WAR_TURNAROUND_DELAY_CYC {0}
	set_component_parameter_value CTRL_QDR4_AVL_ENABLE_POWER_OF_TWO_BUS {0}
	set_component_parameter_value CTRL_QDR4_AVL_MAX_BURST_COUNT {4}
	set_component_parameter_value CTRL_QDR4_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_QDR4_DEF_RAW_TURNAROUND_DELAY_CYC {4}
	set_component_parameter_value CTRL_RLD2_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_RLD3_ADDR_ORDER_ENUM {RLD3_CTRL_ADDR_ORDER_CS_R_B_C}
	set_component_parameter_value CTRL_RLD3_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value DIAG_ADD_READY_PIPELINE {1}
	set_component_parameter_value DIAG_BOARD_DELAY_CONFIG_STR {}
	set_component_parameter_value DIAG_DB_RESET_AUTO_RELEASE {avl_release}
	set_component_parameter_value DIAG_DDR3_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_DDR3_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_DDR3_CAL_ADDR0 {0}
	set_component_parameter_value DIAG_DDR3_CAL_ADDR1 {8}
	set_component_parameter_value DIAG_DDR3_CAL_ENABLE_MICRON_AP {0}
	set_component_parameter_value DIAG_DDR3_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value DIAG_DDR3_CAL_FULL_CAL_ON_RESET {1}
	set_component_parameter_value DIAG_DDR3_CA_DESKEW_EN {0}
	set_component_parameter_value DIAG_DDR3_CA_LEVEL_EN {0}
	set_component_parameter_value DIAG_DDR3_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_DDR3_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR3_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_DDR3_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_DDR3_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_DDR3_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_DDR3_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR3_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_DDR3_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_DDR3_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_DDR3_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_DDR3_INTERFACE_ID {0}
	set_component_parameter_value DIAG_DDR3_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_DDR3_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_DDR3_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_DDR3_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_DDR3_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_DDR3_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR3_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR3_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_DDR3_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_DDR3_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_DDR3_USE_TG_HBM {0}
	set_component_parameter_value DIAG_DDR4_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_DDR4_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_DDR4_CAL_ADDR0 {0}
	set_component_parameter_value DIAG_DDR4_CAL_ADDR1 {8}
	set_component_parameter_value DIAG_DDR4_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value DIAG_DDR4_CAL_FULL_CAL_ON_RESET {1}
	set_component_parameter_value DIAG_DDR4_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_DDR4_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR4_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_DDR4_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_DDR4_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_DDR4_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_DDR4_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_JTAG}
	set_component_parameter_value DIAG_DDR4_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_DDR4_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_DDR4_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_DDR4_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_DDR4_INTERFACE_ID {0}
	set_component_parameter_value DIAG_DDR4_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_DDR4_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_DDR4_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_DDR4_SKIP_AC_PARITY_CHECK {0}
	set_component_parameter_value DIAG_DDR4_SKIP_CA_DESKEW {0}
	set_component_parameter_value DIAG_DDR4_SKIP_CA_LEVEL {0}
	set_component_parameter_value DIAG_DDR4_SKIP_VREF_CAL {0}
	set_component_parameter_value DIAG_DDR4_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_DDR4_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_DDR4_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR4_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR4_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_DDR4_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_DDR4_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_DDR4_USE_TG_HBM {0}
	set_component_parameter_value DIAG_DDRT_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_DDRT_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_DDRT_CAL_ADDR0 {0}
	set_component_parameter_value DIAG_DDRT_CAL_ADDR1 {8}
	set_component_parameter_value DIAG_DDRT_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value DIAG_DDRT_CAL_FULL_CAL_ON_RESET {1}
	set_component_parameter_value DIAG_DDRT_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_DDRT_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_DDRT_EFF_TEST {0}
	set_component_parameter_value DIAG_DDRT_ENABLE_DEFAULT_MODE {1}
	set_component_parameter_value DIAG_DDRT_ENABLE_DRIVER_MARGINING {0}
	set_component_parameter_value DIAG_DDRT_ENABLE_ENHANCED_TESTING {0}
	set_component_parameter_value DIAG_DDRT_ENABLE_USER_MODE {0}
	set_component_parameter_value DIAG_DDRT_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_DDRT_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_DDRT_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_DDRT_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_DDRT_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_DDRT_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_DDRT_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_DDRT_INTERFACE_ID {0}
	set_component_parameter_value DIAG_DDRT_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_DDRT_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_DDRT_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_DDRT_SKIP_CA_DESKEW {0}
	set_component_parameter_value DIAG_DDRT_SKIP_CA_LEVEL {0}
	set_component_parameter_value DIAG_DDRT_SKIP_VREF_CAL {0}
	set_component_parameter_value DIAG_DDRT_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_DDRT_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_DDRT_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_DDRT_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_DDRT_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_DDRT_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_DDRT_USE_TG_AVL_2 {1}
	set_component_parameter_value DIAG_DDRT_USE_TG_HBM {0}
	set_component_parameter_value DIAG_ECLIPSE_DEBUG {0}
	set_component_parameter_value DIAG_ENABLE_HPS_EMIF_DEBUG {0}
	set_component_parameter_value DIAG_ENABLE_JTAG_UART {0}
	set_component_parameter_value DIAG_ENABLE_JTAG_UART_HEX {0}
	set_component_parameter_value DIAG_EXPORT_PLL_LOCKED {1}
	set_component_parameter_value DIAG_EXPORT_PLL_REF_CLK_OUT {0}
	set_component_parameter_value DIAG_EXPORT_VJI {0}
	set_component_parameter_value DIAG_EXPOSE_DFT_SIGNALS {0}
	set_component_parameter_value DIAG_EXPOSE_EARLY_READY {0}
	set_component_parameter_value DIAG_EXPOSE_RD_TYPE {0}
	set_component_parameter_value DIAG_EXTRA_CONFIGS {}
	set_component_parameter_value DIAG_EXT_DOCS {0}
	set_component_parameter_value DIAG_EX_DESIGN_ADD_TEST_EMIFS {}
	set_component_parameter_value DIAG_EX_DESIGN_SEPARATE_RESETS {0}
	set_component_parameter_value DIAG_FAST_SIM_OVERRIDE {FAST_SIM_OVERRIDE_DEFAULT}
	set_component_parameter_value DIAG_HMC_HRC {auto}
	set_component_parameter_value DIAG_LPDDR3_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_LPDDR3_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_LPDDR3_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_LPDDR3_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_LPDDR3_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_LPDDR3_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_LPDDR3_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_LPDDR3_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_LPDDR3_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_LPDDR3_INTERFACE_ID {0}
	set_component_parameter_value DIAG_LPDDR3_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_LPDDR3_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_LPDDR3_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_LPDDR3_SKIP_CA_DESKEW {0}
	set_component_parameter_value DIAG_LPDDR3_SKIP_CA_LEVEL {0}
	set_component_parameter_value DIAG_LPDDR3_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_LPDDR3_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_LPDDR3_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_LPDDR3_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_LPDDR3_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_LPDDR3_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_LPDDR3_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_LPDDR3_USE_TG_HBM {0}
	set_component_parameter_value DIAG_QDR2_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_QDR2_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_QDR2_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_QDR2_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR2_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_QDR2_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_QDR2_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_QDR2_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_QDR2_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR2_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_QDR2_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_QDR2_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_QDR2_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_QDR2_INTERFACE_ID {0}
	set_component_parameter_value DIAG_QDR2_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_QDR2_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_QDR2_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_QDR2_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_QDR2_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_QDR2_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR2_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR2_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_QDR2_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_QDR2_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_QDR2_USE_TG_HBM {0}
	set_component_parameter_value DIAG_QDR4_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_QDR4_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_QDR4_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_QDR4_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR4_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_QDR4_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_QDR4_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_QDR4_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_QDR4_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR4_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_QDR4_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_QDR4_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_QDR4_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_QDR4_INTERFACE_ID {0}
	set_component_parameter_value DIAG_QDR4_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_QDR4_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_QDR4_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_QDR4_SKIP_VREF_CAL {0}
	set_component_parameter_value DIAG_QDR4_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_QDR4_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_QDR4_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR4_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR4_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_QDR4_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_QDR4_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_QDR4_USE_TG_HBM {0}
	set_component_parameter_value DIAG_RLD2_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_RLD2_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_RLD2_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_RLD2_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD2_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_RLD2_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_RLD2_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_RLD2_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_RLD2_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD2_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_RLD2_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_RLD2_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_RLD2_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_RLD2_INTERFACE_ID {0}
	set_component_parameter_value DIAG_RLD2_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_RLD2_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_RLD2_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_RLD2_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_RLD2_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_RLD2_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD2_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD2_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_RLD2_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_RLD2_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_RLD2_USE_TG_HBM {0}
	set_component_parameter_value DIAG_RLD3_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_RLD3_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_RLD3_CA_DESKEW_EN {0}
	set_component_parameter_value DIAG_RLD3_CA_LEVEL_EN {0}
	set_component_parameter_value DIAG_RLD3_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_RLD3_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD3_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_RLD3_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_RLD3_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_RLD3_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_RLD3_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD3_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_RLD3_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_RLD3_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_RLD3_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_RLD3_INTERFACE_ID {0}
	set_component_parameter_value DIAG_RLD3_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_RLD3_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_RLD3_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_RLD3_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_RLD3_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_RLD3_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD3_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD3_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_RLD3_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_RLD3_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_RLD3_USE_TG_HBM {0}
	set_component_parameter_value DIAG_RS232_UART_BAUDRATE {57600}
	set_component_parameter_value DIAG_SEQ_RESET_AUTO_RELEASE {avl}
	set_component_parameter_value DIAG_SIM_REGTEST_MODE {0}
	set_component_parameter_value DIAG_SOFT_NIOS_CLOCK_FREQUENCY {100}
	set_component_parameter_value DIAG_SOFT_NIOS_MODE {SOFT_NIOS_MODE_DISABLED}
	set_component_parameter_value DIAG_SYNTH_FOR_SIM {0}
	set_component_parameter_value DIAG_TG_AVL_2_NUM_CFG_INTERFACES {0}
	set_component_parameter_value DIAG_TIMING_REGTEST_MODE {0}
	set_component_parameter_value DIAG_USE_BOARD_DELAY_MODEL {0}
	set_component_parameter_value DIAG_USE_RS232_UART {0}
	set_component_parameter_value DIAG_VERBOSE_IOAUX {0}
	set_component_parameter_value EMIF_0_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_0_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_0_STORED_PARAM {}
	set_component_parameter_value EMIF_10_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_10_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_10_STORED_PARAM {}
	set_component_parameter_value EMIF_11_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_11_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_11_STORED_PARAM {}
	set_component_parameter_value EMIF_12_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_12_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_12_STORED_PARAM {}
	set_component_parameter_value EMIF_13_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_13_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_13_STORED_PARAM {}
	set_component_parameter_value EMIF_14_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_14_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_14_STORED_PARAM {}
	set_component_parameter_value EMIF_15_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_15_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_15_STORED_PARAM {}
	set_component_parameter_value EMIF_1_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_1_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_1_STORED_PARAM {}
	set_component_parameter_value EMIF_2_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_2_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_2_STORED_PARAM {}
	set_component_parameter_value EMIF_3_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_3_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_3_STORED_PARAM {}
	set_component_parameter_value EMIF_4_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_4_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_4_STORED_PARAM {}
	set_component_parameter_value EMIF_5_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_5_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_5_STORED_PARAM {}
	set_component_parameter_value EMIF_6_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_6_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_6_STORED_PARAM {}
	set_component_parameter_value EMIF_7_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_7_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_7_STORED_PARAM {}
	set_component_parameter_value EMIF_8_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_8_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_8_STORED_PARAM {}
	set_component_parameter_value EMIF_9_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_9_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_9_STORED_PARAM {}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_SIM {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value INTERNAL_TESTING_MODE {0}
	set_component_parameter_value IS_ED_SLAVE {0}
	set_component_parameter_value MEM_DDR3_ALERT_N_DQS_GROUP {0}
	set_component_parameter_value MEM_DDR3_ALERT_N_PLACEMENT_ENUM {DDR3_ALERT_N_PLACEMENT_AC_LANES}
	set_component_parameter_value MEM_DDR3_ASR_ENUM {DDR3_ASR_MANUAL}
	set_component_parameter_value MEM_DDR3_ATCL_ENUM {DDR3_ATCL_DISABLED}
	set_component_parameter_value MEM_DDR3_BANK_ADDR_WIDTH {3}
	set_component_parameter_value MEM_DDR3_BL_ENUM {DDR3_BL_BL8}
	set_component_parameter_value MEM_DDR3_BT_ENUM {DDR3_BT_SEQUENTIAL}
	set_component_parameter_value MEM_DDR3_CFG_GEN_DBE {0}
	set_component_parameter_value MEM_DDR3_CFG_GEN_SBE {0}
	set_component_parameter_value MEM_DDR3_CKE_PER_DIMM {1}
	set_component_parameter_value MEM_DDR3_CK_WIDTH {1}
	set_component_parameter_value MEM_DDR3_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_DDR3_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_DDR3_DISCRETE_MIRROR_ADDRESSING_EN {0}
	set_component_parameter_value MEM_DDR3_DLL_EN {1}
	set_component_parameter_value MEM_DDR3_DM_EN {1}
	set_component_parameter_value MEM_DDR3_DQ_PER_DQS {8}
	set_component_parameter_value MEM_DDR3_DQ_WIDTH {72}
	set_component_parameter_value MEM_DDR3_DRV_STR_ENUM {DDR3_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDR3_FORMAT_ENUM {MEM_FORMAT_UDIMM}
	set_component_parameter_value MEM_DDR3_HIDE_ADV_MR_SETTINGS {1}
	set_component_parameter_value MEM_DDR3_LRDIMM_EXTENDED_CONFIG {000000000000000000}
	set_component_parameter_value MEM_DDR3_MIRROR_ADDRESSING_EN {1}
	set_component_parameter_value MEM_DDR3_NUM_OF_DIMMS {1}
	set_component_parameter_value MEM_DDR3_PD_ENUM {DDR3_PD_OFF}
	set_component_parameter_value MEM_DDR3_RANKS_PER_DIMM {1}
	set_component_parameter_value MEM_DDR3_RDIMM_CONFIG {0000000000000000}
	set_component_parameter_value MEM_DDR3_ROW_ADDR_WIDTH {15}
	set_component_parameter_value MEM_DDR3_RTT_NOM_ENUM {DDR3_RTT_NOM_ODT_DISABLED}
	set_component_parameter_value MEM_DDR3_RTT_WR_ENUM {DDR3_RTT_WR_RZQ_4}
	set_component_parameter_value MEM_DDR3_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_DDR3_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_DDR3_R_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR3_R_ODT0_4X4 {off off on off}
	set_component_parameter_value MEM_DDR3_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_DDR3_R_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR3_R_ODT1_4X4 {off off off on}
	set_component_parameter_value MEM_DDR3_R_ODT2_4X4 {on off off off}
	set_component_parameter_value MEM_DDR3_R_ODT3_4X4 {off on off off}
	set_component_parameter_value MEM_DDR3_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR3_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR3_R_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR3_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR3_SPEEDBIN_ENUM {DDR3_SPEEDBIN_2133}
	set_component_parameter_value MEM_DDR3_SRT_ENUM {DDR3_SRT_NORMAL}
	set_component_parameter_value MEM_DDR3_TCL {14}
	set_component_parameter_value MEM_DDR3_TDH_DC_MV {100}
	set_component_parameter_value MEM_DDR3_TDH_PS {55}
	set_component_parameter_value MEM_DDR3_TDQSCK_PS {180}
	set_component_parameter_value MEM_DDR3_TDQSQ_PS {75}
	set_component_parameter_value MEM_DDR3_TDQSS_CYC {0.27}
	set_component_parameter_value MEM_DDR3_TDSH_CYC {0.18}
	set_component_parameter_value MEM_DDR3_TDSS_CYC {0.18}
	set_component_parameter_value MEM_DDR3_TDS_AC_MV {135}
	set_component_parameter_value MEM_DDR3_TDS_PS {53}
	set_component_parameter_value MEM_DDR3_TFAW_NS {25.0}
	set_component_parameter_value MEM_DDR3_TIH_DC_MV {100}
	set_component_parameter_value MEM_DDR3_TIH_PS {95}
	set_component_parameter_value MEM_DDR3_TINIT_US {500}
	set_component_parameter_value MEM_DDR3_TIS_AC_MV {135}
	set_component_parameter_value MEM_DDR3_TIS_PS {60}
	set_component_parameter_value MEM_DDR3_TMRD_CK_CYC {4}
	set_component_parameter_value MEM_DDR3_TQH_CYC {0.38}
	set_component_parameter_value MEM_DDR3_TQSH_CYC {0.4}
	set_component_parameter_value MEM_DDR3_TRAS_NS {33.0}
	set_component_parameter_value MEM_DDR3_TRCD_NS {13.09}
	set_component_parameter_value MEM_DDR3_TREFI_US {7.8}
	set_component_parameter_value MEM_DDR3_TRFC_NS {160.0}
	set_component_parameter_value MEM_DDR3_TRP_NS {13.09}
	set_component_parameter_value MEM_DDR3_TRRD_CYC {6}
	set_component_parameter_value MEM_DDR3_TRTP_CYC {8}
	set_component_parameter_value MEM_DDR3_TWLH_PS {125.0}
	set_component_parameter_value MEM_DDR3_TWLS_PS {125.0}
	set_component_parameter_value MEM_DDR3_TWR_NS {15.0}
	set_component_parameter_value MEM_DDR3_TWTR_CYC {8}
	set_component_parameter_value MEM_DDR3_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_DDR3_WTCL {10}
	set_component_parameter_value MEM_DDR3_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_DDR3_W_ODT0_2X2 {on off}
	set_component_parameter_value MEM_DDR3_W_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR3_W_ODT0_4X4 {on off on off}
	set_component_parameter_value MEM_DDR3_W_ODT1_2X2 {off on}
	set_component_parameter_value MEM_DDR3_W_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR3_W_ODT1_4X4 {off on off on}
	set_component_parameter_value MEM_DDR3_W_ODT2_4X4 {on off on off}
	set_component_parameter_value MEM_DDR3_W_ODT3_4X4 {off on off on}
	set_component_parameter_value MEM_DDR3_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR3_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR3_W_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR3_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_AC_PARITY_LATENCY {DDR4_AC_PARITY_LATENCY_DISABLE}
	set_component_parameter_value MEM_DDR4_AC_PERSISTENT_ERROR {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_AC_LANE {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_AC_PIN {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_DQS_GROUP {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_PLACEMENT_ENUM {DDR4_ALERT_N_PLACEMENT_DATA_LANES}
	set_component_parameter_value MEM_DDR4_ALERT_PAR_EN {1}
	set_component_parameter_value MEM_DDR4_ASR_ENUM {DDR4_ASR_MANUAL_NORMAL}
	set_component_parameter_value MEM_DDR4_ATCL_ENUM {DDR4_ATCL_DISABLED}
	set_component_parameter_value MEM_DDR4_BANK_ADDR_WIDTH {2}
	set_component_parameter_value MEM_DDR4_BANK_GROUP_WIDTH {1}
	set_component_parameter_value MEM_DDR4_BL_ENUM {DDR4_BL_BL8}
	set_component_parameter_value MEM_DDR4_BT_ENUM {DDR4_BT_SEQUENTIAL}
	set_component_parameter_value MEM_DDR4_CAL_MODE {0}
	set_component_parameter_value MEM_DDR4_CFG_GEN_DBE {0}
	set_component_parameter_value MEM_DDR4_CFG_GEN_SBE {0}
	set_component_parameter_value MEM_DDR4_CHIP_ID_WIDTH {0}
	set_component_parameter_value MEM_DDR4_CKE_PER_DIMM {1}
	set_component_parameter_value MEM_DDR4_CK_WIDTH {1}
	set_component_parameter_value MEM_DDR4_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_DDR4_DB_DQ_DRV_ENUM {DDR4_DB_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDR4_DB_RTT_NOM_ENUM {DDR4_DB_RTT_NOM_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_DB_RTT_PARK_ENUM {DDR4_DB_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_DB_RTT_WR_ENUM {DDR4_DB_RTT_WR_RZQ_3}
	set_component_parameter_value MEM_DDR4_DEFAULT_VREFOUT {1}
	set_component_parameter_value MEM_DDR4_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_DDR4_DISCRETE_MIRROR_ADDRESSING_EN {0}
	set_component_parameter_value MEM_DDR4_DLL_EN {1}
	set_component_parameter_value MEM_DDR4_DM_EN {1}
	set_component_parameter_value MEM_DDR4_DQ_PER_DQS {8}
	set_component_parameter_value MEM_DDR4_DQ_WIDTH {64}
	set_component_parameter_value MEM_DDR4_DRV_STR_ENUM {DDR4_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDR4_FINE_GRANULARITY_REFRESH {DDR4_FINE_REFRESH_FIXED_1X}
	set_component_parameter_value MEM_DDR4_FORMAT_ENUM {MEM_FORMAT_UDIMM}
	set_component_parameter_value MEM_DDR4_GEARDOWN {DDR4_GEARDOWN_HR}
	set_component_parameter_value MEM_DDR4_HIDE_ADV_MR_SETTINGS {1}
	set_component_parameter_value MEM_DDR4_INTEL_DEFAULT_TERM {1}
	set_component_parameter_value MEM_DDR4_INTERNAL_VREFDQ_MONITOR {0}
	set_component_parameter_value MEM_DDR4_LRDIMM_ODT_LESS_BS {1}
	set_component_parameter_value MEM_DDR4_LRDIMM_ODT_LESS_BS_PARK_OHM {240}
	set_component_parameter_value MEM_DDR4_LRDIMM_VREFDQ_VALUE {}
	set_component_parameter_value MEM_DDR4_MAX_POWERDOWN {0}
	set_component_parameter_value MEM_DDR4_MIRROR_ADDRESSING_EN {1}
	set_component_parameter_value MEM_DDR4_MPR_READ_FORMAT {DDR4_MPR_READ_FORMAT_SERIAL}
	set_component_parameter_value MEM_DDR4_NUM_OF_DIMMS {1}
	set_component_parameter_value MEM_DDR4_ODT_IN_POWERDOWN {1}
	set_component_parameter_value MEM_DDR4_PER_DRAM_ADDR {0}
	set_component_parameter_value MEM_DDR4_RANKS_PER_DIMM {1}
	set_component_parameter_value MEM_DDR4_RCD_CA_IBT_ENUM {DDR4_RCD_CA_IBT_100}
	set_component_parameter_value MEM_DDR4_RCD_CKE_IBT_ENUM {DDR4_RCD_CKE_IBT_100}
	set_component_parameter_value MEM_DDR4_RCD_CS_IBT_ENUM {DDR4_RCD_CS_IBT_100}
	set_component_parameter_value MEM_DDR4_RCD_ODT_IBT_ENUM {DDR4_RCD_ODT_IBT_100}
	set_component_parameter_value MEM_DDR4_READ_DBI {1}
	set_component_parameter_value MEM_DDR4_READ_PREAMBLE {2}
	set_component_parameter_value MEM_DDR4_READ_PREAMBLE_TRAINING {0}
	set_component_parameter_value MEM_DDR4_ROW_ADDR_WIDTH {15}
	set_component_parameter_value MEM_DDR4_RTT_NOM_ENUM {DDR4_RTT_NOM_RZQ_4}
	set_component_parameter_value MEM_DDR4_RTT_PARK {DDR4_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_RTT_WR_ENUM {DDR4_RTT_WR_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_DDR4_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_DDR4_R_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR4_R_ODT0_4X4 {off off on off}
	set_component_parameter_value MEM_DDR4_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_DDR4_R_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR4_R_ODT1_4X4 {off off off on}
	set_component_parameter_value MEM_DDR4_R_ODT2_4X4 {on off off off}
	set_component_parameter_value MEM_DDR4_R_ODT3_4X4 {off on off off}
	set_component_parameter_value MEM_DDR4_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR4_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR4_R_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_SELF_RFSH_ABORT {0}
	set_component_parameter_value MEM_DDR4_SPD_133_RCD_DB_VENDOR_LSB {0}
	set_component_parameter_value MEM_DDR4_SPD_134_RCD_DB_VENDOR_MSB {0}
	set_component_parameter_value MEM_DDR4_SPD_135_RCD_REV {0}
	set_component_parameter_value MEM_DDR4_SPD_137_RCD_CA_DRV {101}
	set_component_parameter_value MEM_DDR4_SPD_138_RCD_CK_DRV {5}
	set_component_parameter_value MEM_DDR4_SPD_139_DB_REV {0}
	set_component_parameter_value MEM_DDR4_SPD_140_DRAM_VREFDQ_R0 {29}
	set_component_parameter_value MEM_DDR4_SPD_141_DRAM_VREFDQ_R1 {29}
	set_component_parameter_value MEM_DDR4_SPD_142_DRAM_VREFDQ_R2 {29}
	set_component_parameter_value MEM_DDR4_SPD_143_DRAM_VREFDQ_R3 {29}
	set_component_parameter_value MEM_DDR4_SPD_144_DB_VREFDQ {37}
	set_component_parameter_value MEM_DDR4_SPD_145_DB_MDQ_DRV {21}
	set_component_parameter_value MEM_DDR4_SPD_148_DRAM_DRV {0}
	set_component_parameter_value MEM_DDR4_SPD_149_DRAM_RTT_WR_NOM {20}
	set_component_parameter_value MEM_DDR4_SPD_152_DRAM_RTT_PARK {39}
	set_component_parameter_value MEM_DDR4_SPD_155_DB_VREFDQ_RANGE {0}
	set_component_parameter_value MEM_DDR4_SPEEDBIN_ENUM {DDR4_SPEEDBIN_2666}
	set_component_parameter_value MEM_DDR4_TCCD_L_CYC {6}
	set_component_parameter_value MEM_DDR4_TCCD_S_CYC {4}
	set_component_parameter_value MEM_DDR4_TCL {20}
	set_component_parameter_value MEM_DDR4_TDIVW_DJ_CYC {0.1}
	set_component_parameter_value MEM_DDR4_TDIVW_TOTAL_UI {0.22}
	set_component_parameter_value MEM_DDR4_TDQSCK_PS {170}
	set_component_parameter_value MEM_DDR4_TDQSQ_PS {66}
	set_component_parameter_value MEM_DDR4_TDQSQ_UI {0.18}
	set_component_parameter_value MEM_DDR4_TDQSS_CYC {0.27}
	set_component_parameter_value MEM_DDR4_TDSH_CYC {0.18}
	set_component_parameter_value MEM_DDR4_TDSS_CYC {0.18}
	set_component_parameter_value MEM_DDR4_TDVWP_UI {0.72}
	set_component_parameter_value MEM_DDR4_TEMP_CONTROLLED_RFSH_ENA {0}
	set_component_parameter_value MEM_DDR4_TEMP_CONTROLLED_RFSH_RANGE {DDR4_TEMP_CONTROLLED_RFSH_NORMAL}
	set_component_parameter_value MEM_DDR4_TEMP_SENSOR_READOUT {0}
	set_component_parameter_value MEM_DDR4_TFAW_DLR_CYC {16}
	set_component_parameter_value MEM_DDR4_TFAW_NS {30.0}
	set_component_parameter_value MEM_DDR4_TIH_DC_MV {65}
	set_component_parameter_value MEM_DDR4_TIH_PS {80}
	set_component_parameter_value MEM_DDR4_TINIT_US {500}
	set_component_parameter_value MEM_DDR4_TIS_AC_MV {90}
	set_component_parameter_value MEM_DDR4_TIS_PS {55}
	set_component_parameter_value MEM_DDR4_TMRD_CK_CYC {8}
	set_component_parameter_value MEM_DDR4_TQH_CYC {0.38}
	set_component_parameter_value MEM_DDR4_TQH_UI {0.74}
	set_component_parameter_value MEM_DDR4_TQSH_CYC {0.4}
	set_component_parameter_value MEM_DDR4_TRAS_NS {32.0}
	set_component_parameter_value MEM_DDR4_TRCD_NS {14.25}
	set_component_parameter_value MEM_DDR4_TREFI_US {7.8}
	set_component_parameter_value MEM_DDR4_TRFC_DLR_NS {90.0}
	set_component_parameter_value MEM_DDR4_TRFC_NS {350.0}
	set_component_parameter_value MEM_DDR4_TRP_NS {14.25}
	set_component_parameter_value MEM_DDR4_TRRD_DLR_CYC {4}
	set_component_parameter_value MEM_DDR4_TRRD_L_CYC {8}
	set_component_parameter_value MEM_DDR4_TRRD_S_CYC {7}
	set_component_parameter_value MEM_DDR4_TWLH_CYC {0.13}
	set_component_parameter_value MEM_DDR4_TWLH_PS {0.0}
	set_component_parameter_value MEM_DDR4_TWLS_CYC {0.13}
	set_component_parameter_value MEM_DDR4_TWLS_PS {0.0}
	set_component_parameter_value MEM_DDR4_TWR_NS {15.0}
	set_component_parameter_value MEM_DDR4_TWTR_L_CYC {9}
	set_component_parameter_value MEM_DDR4_TWTR_S_CYC {3}
	set_component_parameter_value MEM_DDR4_USER_VREFDQ_TRAINING_RANGE {DDR4_VREFDQ_TRAINING_RANGE_0}
	set_component_parameter_value MEM_DDR4_USER_VREFDQ_TRAINING_VALUE {72.2}
	set_component_parameter_value MEM_DDR4_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_DDR4_VDIVW_TOTAL {120}
	set_component_parameter_value MEM_DDR4_WRITE_CRC {0}
	set_component_parameter_value MEM_DDR4_WRITE_DBI {0}
	set_component_parameter_value MEM_DDR4_WRITE_PREAMBLE {1}
	set_component_parameter_value MEM_DDR4_WTCL {16}
	set_component_parameter_value MEM_DDR4_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_DDR4_W_ODT0_2X2 {on off}
	set_component_parameter_value MEM_DDR4_W_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR4_W_ODT0_4X4 {on off on off}
	set_component_parameter_value MEM_DDR4_W_ODT1_2X2 {off on}
	set_component_parameter_value MEM_DDR4_W_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR4_W_ODT1_4X4 {off on off on}
	set_component_parameter_value MEM_DDR4_W_ODT2_4X4 {on off on off}
	set_component_parameter_value MEM_DDR4_W_ODT3_4X4 {off on off on}
	set_component_parameter_value MEM_DDR4_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR4_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR4_W_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_AC_PARITY_LATENCY {DDRT_AC_PARITY_LATENCY_DISABLE}
	set_component_parameter_value MEM_DDRT_AC_PERSISTENT_ERROR {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_AC_LANE {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_AC_PIN {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_DQS_GROUP {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_PLACEMENT_ENUM {DDRT_ALERT_N_PLACEMENT_AUTO}
	set_component_parameter_value MEM_DDRT_ALERT_PAR_EN {1}
	set_component_parameter_value MEM_DDRT_ASR_ENUM {DDRT_ASR_MANUAL_NORMAL}
	set_component_parameter_value MEM_DDRT_ATCL_ENUM {DDRT_ATCL_DISABLED}
	set_component_parameter_value MEM_DDRT_BANK_ADDR_WIDTH {2}
	set_component_parameter_value MEM_DDRT_BANK_GROUP_WIDTH {2}
	set_component_parameter_value MEM_DDRT_BL_ENUM {DDRT_BL_BL8}
	set_component_parameter_value MEM_DDRT_BT_ENUM {DDRT_BT_SEQUENTIAL}
	set_component_parameter_value MEM_DDRT_CAL_MODE {0}
	set_component_parameter_value MEM_DDRT_CFG_GEN_DBE {0}
	set_component_parameter_value MEM_DDRT_CFG_GEN_SBE {0}
	set_component_parameter_value MEM_DDRT_CKE_PER_DIMM {1}
	set_component_parameter_value MEM_DDRT_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_DDRT_DB_DQ_DRV_ENUM {DDRT_DB_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDRT_DB_RTT_NOM_ENUM {DDRT_DB_RTT_NOM_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_DB_RTT_PARK_ENUM {DDRT_DB_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_DB_RTT_WR_ENUM {DDRT_DB_RTT_WR_RZQ_3}
	set_component_parameter_value MEM_DDRT_DEFAULT_ADDED_LATENCY {1}
	set_component_parameter_value MEM_DDRT_DEFAULT_PREAMBLE {1}
	set_component_parameter_value MEM_DDRT_DEFAULT_VREFOUT {1}
	set_component_parameter_value MEM_DDRT_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_DDRT_DISCRETE_MIRROR_ADDRESSING_EN {0}
	set_component_parameter_value MEM_DDRT_DLL_EN {1}
	set_component_parameter_value MEM_DDRT_DM_EN {0}
	set_component_parameter_value MEM_DDRT_DQ_PER_DQS {4}
	set_component_parameter_value MEM_DDRT_DQ_WIDTH {72}
	set_component_parameter_value MEM_DDRT_DRV_STR_ENUM {DDRT_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDRT_FINE_GRANULARITY_REFRESH {DDRT_FINE_REFRESH_FIXED_1X}
	set_component_parameter_value MEM_DDRT_FORMAT_ENUM {MEM_FORMAT_LRDIMM}
	set_component_parameter_value MEM_DDRT_GEARDOWN {DDRT_GEARDOWN_HR}
	set_component_parameter_value MEM_DDRT_HIDE_ADV_MR_SETTINGS {1}
	set_component_parameter_value MEM_DDRT_HIDE_LATENCY_SETTINGS {1}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_0_SA {0}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_1_SA {1}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_2_SA {2}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_3_SA {3}
	set_component_parameter_value MEM_DDRT_INTERNAL_VREFDQ_MONITOR {0}
	set_component_parameter_value MEM_DDRT_LRDIMM_ODT_LESS_BS {0}
	set_component_parameter_value MEM_DDRT_LRDIMM_ODT_LESS_BS_PARK_OHM {240}
	set_component_parameter_value MEM_DDRT_LRDIMM_VREFDQ_VALUE {}
	set_component_parameter_value MEM_DDRT_MAX_POWERDOWN {0}
	set_component_parameter_value MEM_DDRT_MIRROR_ADDRESSING_EN {1}
	set_component_parameter_value MEM_DDRT_MPR_READ_FORMAT {DDRT_MPR_READ_FORMAT_SERIAL}
	set_component_parameter_value MEM_DDRT_NUM_OF_DIMMS {1}
	set_component_parameter_value MEM_DDRT_ODT_IN_POWERDOWN {1}
	set_component_parameter_value MEM_DDRT_PARTIAL_WRITES {0}
	set_component_parameter_value MEM_DDRT_PERSISTENT_MODE {1}
	set_component_parameter_value MEM_DDRT_PER_DRAM_ADDR {0}
	set_component_parameter_value MEM_DDRT_PWR_MODE {DDRT_PWR_MODE_12W}
	set_component_parameter_value MEM_DDRT_RANKS_PER_DIMM {1}
	set_component_parameter_value MEM_DDRT_RCD_CA_IBT_ENUM {DDRT_RCD_CA_IBT_100}
	set_component_parameter_value MEM_DDRT_RCD_CKE_IBT_ENUM {DDRT_RCD_CKE_IBT_100}
	set_component_parameter_value MEM_DDRT_RCD_CS_IBT_ENUM {DDRT_RCD_CS_IBT_100}
	set_component_parameter_value MEM_DDRT_RCD_ODT_IBT_ENUM {DDRT_RCD_ODT_IBT_100}
	set_component_parameter_value MEM_DDRT_READ_DBI {0}
	set_component_parameter_value MEM_DDRT_READ_PREAMBLE_TRAINING {0}
	set_component_parameter_value MEM_DDRT_ROW_ADDR_WIDTH {18}
	set_component_parameter_value MEM_DDRT_RTT_NOM_ENUM {DDRT_RTT_NOM_RZQ_4}
	set_component_parameter_value MEM_DDRT_RTT_PARK {DDRT_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_RTT_WR_ENUM {DDRT_RTT_WR_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_DDRT_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_DDRT_R_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDRT_R_ODT0_4X4 {off off off off}
	set_component_parameter_value MEM_DDRT_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_DDRT_R_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDRT_R_ODT1_4X4 {off off on on}
	set_component_parameter_value MEM_DDRT_R_ODT2_4X4 {off off off off}
	set_component_parameter_value MEM_DDRT_R_ODT3_4X4 {on on off off}
	set_component_parameter_value MEM_DDRT_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDRT_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDRT_R_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_SELF_RFSH_ABORT {0}
	set_component_parameter_value MEM_DDRT_SPD_133_RCD_DB_VENDOR_LSB {0}
	set_component_parameter_value MEM_DDRT_SPD_134_RCD_DB_VENDOR_MSB {0}
	set_component_parameter_value MEM_DDRT_SPD_135_RCD_REV {0}
	set_component_parameter_value MEM_DDRT_SPD_137_RCD_CA_DRV {85}
	set_component_parameter_value MEM_DDRT_SPD_138_RCD_CK_DRV {5}
	set_component_parameter_value MEM_DDRT_SPD_139_DB_REV {0}
	set_component_parameter_value MEM_DDRT_SPD_140_DRAM_VREFDQ_R0 {29}
	set_component_parameter_value MEM_DDRT_SPD_141_DRAM_VREFDQ_R1 {29}
	set_component_parameter_value MEM_DDRT_SPD_142_DRAM_VREFDQ_R2 {29}
	set_component_parameter_value MEM_DDRT_SPD_143_DRAM_VREFDQ_R3 {29}
	set_component_parameter_value MEM_DDRT_SPD_144_DB_VREFDQ {37}
	set_component_parameter_value MEM_DDRT_SPD_145_DB_MDQ_DRV {21}
	set_component_parameter_value MEM_DDRT_SPD_148_DRAM_DRV {0}
	set_component_parameter_value MEM_DDRT_SPD_149_DRAM_RTT_WR_NOM {20}
	set_component_parameter_value MEM_DDRT_SPD_152_DRAM_RTT_PARK {39}
	set_component_parameter_value MEM_DDRT_SPEEDBIN_ENUM {DDRT_SPEEDBIN_2400}
	set_component_parameter_value MEM_DDRT_TCCD_L_CYC {6}
	set_component_parameter_value MEM_DDRT_TCCD_S_CYC {4}
	set_component_parameter_value MEM_DDRT_TCL {15}
	set_component_parameter_value MEM_DDRT_TDIVW_DJ_CYC {0.1}
	set_component_parameter_value MEM_DDRT_TDIVW_TOTAL_UI {0.2}
	set_component_parameter_value MEM_DDRT_TDQSCK_PS {165}
	set_component_parameter_value MEM_DDRT_TDQSQ_PS {66}
	set_component_parameter_value MEM_DDRT_TDQSQ_UI {0.16}
	set_component_parameter_value MEM_DDRT_TDQSS_CYC {0.27}
	set_component_parameter_value MEM_DDRT_TDSH_CYC {0.18}
	set_component_parameter_value MEM_DDRT_TDSS_CYC {0.18}
	set_component_parameter_value MEM_DDRT_TDVWP_UI {0.72}
	set_component_parameter_value MEM_DDRT_TEMP_CONTROLLED_RFSH_ENA {0}
	set_component_parameter_value MEM_DDRT_TEMP_CONTROLLED_RFSH_RANGE {DDRT_TEMP_CONTROLLED_RFSH_NORMAL}
	set_component_parameter_value MEM_DDRT_TEMP_SENSOR_READOUT {0}
	set_component_parameter_value MEM_DDRT_TFAW_DLR_CYC {16}
	set_component_parameter_value MEM_DDRT_TFAW_NS {21.0}
	set_component_parameter_value MEM_DDRT_TIH_DC_MV {75}
	set_component_parameter_value MEM_DDRT_TIH_PS {95}
	set_component_parameter_value MEM_DDRT_TINIT_US {500}
	set_component_parameter_value MEM_DDRT_TIS_AC_MV {100}
	set_component_parameter_value MEM_DDRT_TIS_PS {60}
	set_component_parameter_value MEM_DDRT_TMRD_CK_CYC {8}
	set_component_parameter_value MEM_DDRT_TQH_CYC {0.38}
	set_component_parameter_value MEM_DDRT_TQH_UI {0.76}
	set_component_parameter_value MEM_DDRT_TQSH_CYC {0.38}
	set_component_parameter_value MEM_DDRT_TRAS_NS {32.0}
	set_component_parameter_value MEM_DDRT_TRCD_NS {15.0}
	set_component_parameter_value MEM_DDRT_TREFI_US {7.8}
	set_component_parameter_value MEM_DDRT_TRFC_DLR_NS {90.0}
	set_component_parameter_value MEM_DDRT_TRFC_NS {260.0}
	set_component_parameter_value MEM_DDRT_TRP_NS {15.0}
	set_component_parameter_value MEM_DDRT_TRRD_DLR_CYC {4}
	set_component_parameter_value MEM_DDRT_TRRD_L_CYC {6}
	set_component_parameter_value MEM_DDRT_TRRD_S_CYC {4}
	set_component_parameter_value MEM_DDRT_TWLH_CYC {0.13}
	set_component_parameter_value MEM_DDRT_TWLH_PS {0.0}
	set_component_parameter_value MEM_DDRT_TWLS_CYC {0.13}
	set_component_parameter_value MEM_DDRT_TWLS_PS {0.0}
	set_component_parameter_value MEM_DDRT_TWR_NS {15.0}
	set_component_parameter_value MEM_DDRT_TWTR_L_CYC {9}
	set_component_parameter_value MEM_DDRT_TWTR_S_CYC {3}
	set_component_parameter_value MEM_DDRT_USER_READ_PREAMBLE {1}
	set_component_parameter_value MEM_DDRT_USER_TCL_ADDED {0}
	set_component_parameter_value MEM_DDRT_USER_VREFDQ_TRAINING_RANGE {DDRT_VREFDQ_TRAINING_RANGE_1}
	set_component_parameter_value MEM_DDRT_USER_VREFDQ_TRAINING_VALUE {56.0}
	set_component_parameter_value MEM_DDRT_USER_WRITE_PREAMBLE {1}
	set_component_parameter_value MEM_DDRT_USER_WTCL_ADDED {6}
	set_component_parameter_value MEM_DDRT_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_DDRT_VDIVW_TOTAL {136}
	set_component_parameter_value MEM_DDRT_WRITE_CRC {0}
	set_component_parameter_value MEM_DDRT_WRITE_DBI {0}
	set_component_parameter_value MEM_DDRT_WTCL {18}
	set_component_parameter_value MEM_DDRT_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_DDRT_W_ODT0_2X2 {on off}
	set_component_parameter_value MEM_DDRT_W_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDRT_W_ODT0_4X4 {on on off off}
	set_component_parameter_value MEM_DDRT_W_ODT1_2X2 {off on}
	set_component_parameter_value MEM_DDRT_W_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDRT_W_ODT1_4X4 {off off on on}
	set_component_parameter_value MEM_DDRT_W_ODT2_4X4 {off off on on}
	set_component_parameter_value MEM_DDRT_W_ODT3_4X4 {on on off off}
	set_component_parameter_value MEM_DDRT_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDRT_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDRT_W_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_LPDDR3_BANK_ADDR_WIDTH {3}
	set_component_parameter_value MEM_LPDDR3_BL {LPDDR3_BL_BL8}
	set_component_parameter_value MEM_LPDDR3_CK_WIDTH {1}
	set_component_parameter_value MEM_LPDDR3_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_LPDDR3_DATA_LATENCY {LPDDR3_DL_RL12_WL6}
	set_component_parameter_value MEM_LPDDR3_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_LPDDR3_DM_EN {1}
	set_component_parameter_value MEM_LPDDR3_DQODT {LPDDR3_DQODT_DISABLE}
	set_component_parameter_value MEM_LPDDR3_DQ_WIDTH {32}
	set_component_parameter_value MEM_LPDDR3_DRV_STR {LPDDR3_DRV_STR_40D_40U}
	set_component_parameter_value MEM_LPDDR3_PDODT {LPDDR3_PDODT_DISABLED}
	set_component_parameter_value MEM_LPDDR3_ROW_ADDR_WIDTH {15}
	set_component_parameter_value MEM_LPDDR3_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_LPDDR3_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT0_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT1_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT2_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT3_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_LPDDR3_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_LPDDR3_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_LPDDR3_SPEEDBIN_ENUM {LPDDR3_SPEEDBIN_1600}
	set_component_parameter_value MEM_LPDDR3_TDH_DC_MV {100}
	set_component_parameter_value MEM_LPDDR3_TDH_PS {100}
	set_component_parameter_value MEM_LPDDR3_TDQSCKDL {614}
	set_component_parameter_value MEM_LPDDR3_TDQSQ_PS {135}
	set_component_parameter_value MEM_LPDDR3_TDQSS_CYC {1.25}
	set_component_parameter_value MEM_LPDDR3_TDSH_CYC {0.2}
	set_component_parameter_value MEM_LPDDR3_TDSS_CYC {0.2}
	set_component_parameter_value MEM_LPDDR3_TDS_AC_MV {150}
	set_component_parameter_value MEM_LPDDR3_TDS_PS {75}
	set_component_parameter_value MEM_LPDDR3_TFAW_NS {50.0}
	set_component_parameter_value MEM_LPDDR3_TIH_DC_MV {100}
	set_component_parameter_value MEM_LPDDR3_TIH_PS {100}
	set_component_parameter_value MEM_LPDDR3_TINIT_US {500}
	set_component_parameter_value MEM_LPDDR3_TIS_AC_MV {150}
	set_component_parameter_value MEM_LPDDR3_TIS_PS {75}
	set_component_parameter_value MEM_LPDDR3_TMRR_CK_CYC {4}
	set_component_parameter_value MEM_LPDDR3_TMRW_CK_CYC {10}
	set_component_parameter_value MEM_LPDDR3_TQH_CYC {0.38}
	set_component_parameter_value MEM_LPDDR3_TQSH_CYC {0.38}
	set_component_parameter_value MEM_LPDDR3_TRAS_NS {42.5}
	set_component_parameter_value MEM_LPDDR3_TRCD_NS {18.0}
	set_component_parameter_value MEM_LPDDR3_TREFI_US {3.9}
	set_component_parameter_value MEM_LPDDR3_TRFC_NS {210.0}
	set_component_parameter_value MEM_LPDDR3_TRP_NS {18.0}
	set_component_parameter_value MEM_LPDDR3_TRRD_CYC {8}
	set_component_parameter_value MEM_LPDDR3_TRTP_CYC {6}
	set_component_parameter_value MEM_LPDDR3_TWLH_PS {175.0}
	set_component_parameter_value MEM_LPDDR3_TWLS_PS {175.0}
	set_component_parameter_value MEM_LPDDR3_TWR_NS {15.0}
	set_component_parameter_value MEM_LPDDR3_TWTR_CYC {6}
	set_component_parameter_value MEM_LPDDR3_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_LPDDR3_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_LPDDR3_W_ODT0_2X2 {on on}
	set_component_parameter_value MEM_LPDDR3_W_ODT0_4X4 {on on on on}
	set_component_parameter_value MEM_LPDDR3_W_ODT1_2X2 {off off}
	set_component_parameter_value MEM_LPDDR3_W_ODT1_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_W_ODT2_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_W_ODT3_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_LPDDR3_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_LPDDR3_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_QDR2_ADDR_WIDTH {19}
	set_component_parameter_value MEM_QDR2_BL {4}
	set_component_parameter_value MEM_QDR2_BWS_EN {1}
	set_component_parameter_value MEM_QDR2_DATA_PER_DEVICE {36}
	set_component_parameter_value MEM_QDR2_INTERNAL_JITTER_NS {0.08}
	set_component_parameter_value MEM_QDR2_SPEEDBIN_ENUM {QDR2_SPEEDBIN_633}
	set_component_parameter_value MEM_QDR2_TCCQO_NS {0.45}
	set_component_parameter_value MEM_QDR2_TCQDOH_NS {-0.09}
	set_component_parameter_value MEM_QDR2_TCQD_NS {0.09}
	set_component_parameter_value MEM_QDR2_TCQH_NS {0.71}
	set_component_parameter_value MEM_QDR2_THA_NS {0.18}
	set_component_parameter_value MEM_QDR2_THD_NS {0.18}
	set_component_parameter_value MEM_QDR2_TRL_CYC {2.5}
	set_component_parameter_value MEM_QDR2_TSA_NS {0.23}
	set_component_parameter_value MEM_QDR2_TSD_NS {0.23}
	set_component_parameter_value MEM_QDR2_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_QDR4_AC_ODT_MODE_ENUM {QDR4_ODT_25_PCT}
	set_component_parameter_value MEM_QDR4_ADDR_INV_ENA {0}
	set_component_parameter_value MEM_QDR4_ADDR_WIDTH {21}
	set_component_parameter_value MEM_QDR4_CK_ODT_MODE_ENUM {QDR4_ODT_25_PCT}
	set_component_parameter_value MEM_QDR4_DATA_INV_ENA {1}
	set_component_parameter_value MEM_QDR4_DATA_ODT_MODE_ENUM {QDR4_ODT_25_PCT}
	set_component_parameter_value MEM_QDR4_DQ_PER_PORT_PER_DEVICE {36}
	set_component_parameter_value MEM_QDR4_MEM_TYPE_ENUM {MEM_XP}
	set_component_parameter_value MEM_QDR4_PD_OUTPUT_DRIVE_MODE_ENUM {QDR4_OUTPUT_DRIVE_25_PCT}
	set_component_parameter_value MEM_QDR4_PU_OUTPUT_DRIVE_MODE_ENUM {QDR4_OUTPUT_DRIVE_25_PCT}
	set_component_parameter_value MEM_QDR4_SKIP_ODT_SWEEPING {1}
	set_component_parameter_value MEM_QDR4_SPEEDBIN_ENUM {QDR4_SPEEDBIN_2133}
	set_component_parameter_value MEM_QDR4_TASH_PS {170}
	set_component_parameter_value MEM_QDR4_TCKDK_MAX_PS {150}
	set_component_parameter_value MEM_QDR4_TCKDK_MIN_PS {-150}
	set_component_parameter_value MEM_QDR4_TCKQK_MAX_PS {225}
	set_component_parameter_value MEM_QDR4_TCSH_PS {170}
	set_component_parameter_value MEM_QDR4_TISH_PS {150}
	set_component_parameter_value MEM_QDR4_TQH_CYC {0.4}
	set_component_parameter_value MEM_QDR4_TQKQ_MAX_PS {75}
	set_component_parameter_value MEM_QDR4_USE_ADDR_PARITY {0}
	set_component_parameter_value MEM_QDR4_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD2_ADDR_WIDTH {21}
	set_component_parameter_value MEM_RLD2_BANK_ADDR_WIDTH {3}
	set_component_parameter_value MEM_RLD2_BL {4}
	set_component_parameter_value MEM_RLD2_CONFIG_ENUM {RLD2_CONFIG_TRC_8_TRL_8_TWL_9}
	set_component_parameter_value MEM_RLD2_DM_EN {1}
	set_component_parameter_value MEM_RLD2_DQ_PER_DEVICE {9}
	set_component_parameter_value MEM_RLD2_DRIVE_IMPEDENCE_ENUM {RLD2_DRIVE_IMPEDENCE_INTERNAL_50}
	set_component_parameter_value MEM_RLD2_ODT_MODE_ENUM {RLD2_ODT_ON}
	set_component_parameter_value MEM_RLD2_REFRESH_INTERVAL_US {0.24}
	set_component_parameter_value MEM_RLD2_SPEEDBIN_ENUM {RLD2_SPEEDBIN_18}
	set_component_parameter_value MEM_RLD2_TAH_NS {0.3}
	set_component_parameter_value MEM_RLD2_TAS_NS {0.3}
	set_component_parameter_value MEM_RLD2_TCKDK_MAX_NS {0.3}
	set_component_parameter_value MEM_RLD2_TCKDK_MIN_NS {-0.3}
	set_component_parameter_value MEM_RLD2_TCKH_CYC {0.45}
	set_component_parameter_value MEM_RLD2_TCKQK_MAX_NS {0.2}
	set_component_parameter_value MEM_RLD2_TDH_NS {0.17}
	set_component_parameter_value MEM_RLD2_TDS_NS {0.17}
	set_component_parameter_value MEM_RLD2_TQKH_HCYC {0.9}
	set_component_parameter_value MEM_RLD2_TQKQ_MAX_NS {0.12}
	set_component_parameter_value MEM_RLD2_TQKQ_MIN_NS {-0.12}
	set_component_parameter_value MEM_RLD2_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD3_ADDR_WIDTH {20}
	set_component_parameter_value MEM_RLD3_AREF_PROTOCOL_ENUM {RLD3_AREF_BAC}
	set_component_parameter_value MEM_RLD3_BANK_ADDR_WIDTH {4}
	set_component_parameter_value MEM_RLD3_BL {2}
	set_component_parameter_value MEM_RLD3_DATA_LATENCY_MODE_ENUM {RLD3_DL_RL16_WL17}
	set_component_parameter_value MEM_RLD3_DEPTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD3_DM_EN {1}
	set_component_parameter_value MEM_RLD3_DQ_PER_DEVICE {36}
	set_component_parameter_value MEM_RLD3_ODT_MODE_ENUM {RLD3_ODT_40}
	set_component_parameter_value MEM_RLD3_OUTPUT_DRIVE_MODE_ENUM {RLD3_OUTPUT_DRIVE_40}
	set_component_parameter_value MEM_RLD3_SPEEDBIN_ENUM {RLD3_SPEEDBIN_093E}
	set_component_parameter_value MEM_RLD3_TCKDK_MAX_CYC {0.27}
	set_component_parameter_value MEM_RLD3_TCKDK_MIN_CYC {-0.27}
	set_component_parameter_value MEM_RLD3_TCKQK_MAX_PS {135}
	set_component_parameter_value MEM_RLD3_TDH_DC_MV {100}
	set_component_parameter_value MEM_RLD3_TDH_PS {5}
	set_component_parameter_value MEM_RLD3_TDS_AC_MV {150}
	set_component_parameter_value MEM_RLD3_TDS_PS {-30}
	set_component_parameter_value MEM_RLD3_TIH_DC_MV {100}
	set_component_parameter_value MEM_RLD3_TIH_PS {65}
	set_component_parameter_value MEM_RLD3_TIS_AC_MV {150}
	set_component_parameter_value MEM_RLD3_TIS_PS {85}
	set_component_parameter_value MEM_RLD3_TQH_CYC {0.38}
	set_component_parameter_value MEM_RLD3_TQKQ_MAX_PS {75}
	set_component_parameter_value MEM_RLD3_T_RC_MODE_ENUM {RLD3_TRC_9}
	set_component_parameter_value MEM_RLD3_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD3_WRITE_PROTOCOL_ENUM {RLD3_WRITE_1BANK}
	set_component_parameter_value NUM_IPS {1}
	set_component_parameter_value PHY_DDR3_CAL_ADDR0 {0}
	set_component_parameter_value PHY_DDR3_CAL_ADDR1 {8}
	set_component_parameter_value PHY_DDR3_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value PHY_DDR3_CONFIG_ENUM {CONFIG_PHY_AND_HARD_CTRL}
	set_component_parameter_value PHY_DDR3_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_DDR3_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_DDR3_DEFAULT_IO {1}
	set_component_parameter_value PHY_DDR3_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_DDR3_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_DDR3_IO_VOLTAGE {1.5}
	set_component_parameter_value PHY_DDR3_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_DDR3_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_DDR3_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_DDR3_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_DDR3_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR3_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_DDR3_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR3_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_DDR3_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_DDR3_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_DDR3_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_DDR3_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_DDR4_ALLOW_72_DQ_WIDTH {0}
	set_component_parameter_value PHY_DDR4_CONFIG_ENUM {CONFIG_PHY_AND_HARD_CTRL}
	set_component_parameter_value PHY_DDR4_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_DDR4_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_DDR4_DEFAULT_IO {0}
	set_component_parameter_value PHY_DDR4_DEFAULT_REF_CLK_FREQ {0}
	set_component_parameter_value PHY_DDR4_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_DDR4_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_DDR4_MEM_CLK_FREQ_MHZ {1066.66666}
	set_component_parameter_value PHY_DDR4_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_DDR4_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_DDR4_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_DDR4_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_AC_IO_STD_ENUM {IO_STD_SSTL_12}
	set_component_parameter_value PHY_DDR4_USER_AC_MODE_ENUM {OUT_OCT_40_CAL}
	set_component_parameter_value PHY_DDR4_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR4_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_DDR4_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_CK_IO_STD_ENUM {IO_STD_SSTL_12}
	set_component_parameter_value PHY_DDR4_USER_CK_MODE_ENUM {OUT_OCT_40_CAL}
	set_component_parameter_value PHY_DDR4_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR4_USER_CLAMSHELL_EN {0}
	set_component_parameter_value PHY_DDR4_USER_DATA_IN_MODE_ENUM {IN_OCT_60_CAL}
	set_component_parameter_value PHY_DDR4_USER_DATA_IO_STD_ENUM {IO_STD_POD_12}
	set_component_parameter_value PHY_DDR4_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_DATA_OUT_MODE_ENUM {OUT_OCT_48_CAL}
	set_component_parameter_value PHY_DDR4_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_DDR4_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_DDR4_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_DDR4_USER_PLL_REF_CLK_IO_STD_ENUM {IO_STD_LVDS}
	set_component_parameter_value PHY_DDR4_USER_REF_CLK_FREQ_MHZ {133.333}
	set_component_parameter_value PHY_DDR4_USER_RZQ_IO_STD_ENUM {IO_STD_CMOS_12}
	set_component_parameter_value PHY_DDR4_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_DDRT_2CH_EN {0}
	set_component_parameter_value PHY_DDRT_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_DDRT_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_DDRT_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_DDRT_DEFAULT_IO {1}
	set_component_parameter_value PHY_DDRT_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_DDRT_EXPORT_CLK_STP_IF {0}
	set_component_parameter_value PHY_DDRT_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_DDRT_I2C_USE_SMC {0}
	set_component_parameter_value PHY_DDRT_IC_EN {1}
	set_component_parameter_value PHY_DDRT_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_DDRT_MEM_CLK_FREQ_MHZ {1200.0}
	set_component_parameter_value PHY_DDRT_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_DDRT_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_DDRT_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_DDRT_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDRT_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_DDRT_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDRT_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_DDRT_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_DDRT_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_DDRT_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_DDRT_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_DDRT_USE_OLD_SMBUS_MULTICOL {0}
	set_component_parameter_value PHY_LPDDR3_CONFIG_ENUM {CONFIG_PHY_AND_HARD_CTRL}
	set_component_parameter_value PHY_LPDDR3_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_LPDDR3_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_LPDDR3_DEFAULT_IO {1}
	set_component_parameter_value PHY_LPDDR3_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_LPDDR3_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_LPDDR3_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_LPDDR3_MEM_CLK_FREQ_MHZ {800.0}
	set_component_parameter_value PHY_LPDDR3_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_LPDDR3_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_LPDDR3_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_LPDDR3_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_LPDDR3_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_LPDDR3_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_LPDDR3_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_LPDDR3_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_LPDDR3_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_LPDDR3_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_QDR2_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_QDR2_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_QDR2_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_QDR2_DEFAULT_IO {1}
	set_component_parameter_value PHY_QDR2_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_QDR2_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_QDR2_IO_VOLTAGE {1.5}
	set_component_parameter_value PHY_QDR2_MEM_CLK_FREQ_MHZ {633.333}
	set_component_parameter_value PHY_QDR2_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_QDR2_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_QDR2_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_QDR2_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR2_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_QDR2_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR2_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_QDR2_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_QDR2_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_QDR2_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_QDR2_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_QDR4_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_QDR4_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_QDR4_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_QDR4_DEFAULT_IO {1}
	set_component_parameter_value PHY_QDR4_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_QDR4_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_QDR4_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_QDR4_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_QDR4_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_QDR4_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_QDR4_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_QDR4_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR4_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_QDR4_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR4_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_QDR4_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_QDR4_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_QDR4_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_QDR4_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_RLD2_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_RLD2_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_RLD2_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_RLD2_DEFAULT_IO {1}
	set_component_parameter_value PHY_RLD2_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_RLD2_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_RLD2_IO_VOLTAGE {1.8}
	set_component_parameter_value PHY_RLD2_MEM_CLK_FREQ_MHZ {533.333}
	set_component_parameter_value PHY_RLD2_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_RLD2_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_RLD2_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_RLD2_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD2_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_RLD2_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD2_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_RLD2_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_RLD2_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_RLD2_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_RLD2_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_RLD3_CONFIG_ENUM {CONFIG_PHY_ONLY}
	set_component_parameter_value PHY_RLD3_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_RLD3_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_RLD3_DEFAULT_IO {1}
	set_component_parameter_value PHY_RLD3_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_RLD3_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_RLD3_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_RLD3_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_RLD3_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_RLD3_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_RLD3_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_RLD3_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD3_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_RLD3_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD3_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_RLD3_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_RLD3_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_RLD3_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_RLD3_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PLL_ADD_EXTRA_CLKS {0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_0 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_1 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_2 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_3 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_4 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_5 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_6 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_7 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_8 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_0 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_1 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_2 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_3 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_4 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_5 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_6 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_7 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_8 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_0 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_1 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_2 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_3 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_4 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_5 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_6 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_7 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_8 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_0 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_1 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_2 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_3 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_4 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_5 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_6 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_7 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_8 {ps}
	set_component_parameter_value PLL_USER_NUM_OF_EXTRA_CLKS {0}
	set_component_parameter_value PROTOCOL_ENUM {PROTOCOL_DDR4}
	set_component_parameter_value SHORT_QSYS_INTERFACE_NAMES {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation ddr4_emif
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface global_reset_n reset INPUT
	set_instantiation_interface_parameter_value global_reset_n associatedClock {}
	set_instantiation_interface_parameter_value global_reset_n synchronousEdges {NONE}
	add_instantiation_interface_port global_reset_n global_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface pll_ref_clk clock INPUT
	set_instantiation_interface_parameter_value pll_ref_clk clockRate {0}
	set_instantiation_interface_parameter_value pll_ref_clk externallyDriven {false}
	set_instantiation_interface_parameter_value pll_ref_clk ptfSchematicName {}
	add_instantiation_interface_port pll_ref_clk pll_ref_clk clk 1 STD_LOGIC Input
	add_instantiation_interface pll_locked conduit INPUT
	set_instantiation_interface_parameter_value pll_locked associatedClock {}
	set_instantiation_interface_parameter_value pll_locked associatedReset {}
	set_instantiation_interface_parameter_value pll_locked prSafe {false}
	add_instantiation_interface_port pll_locked pll_locked pll_locked 1 STD_LOGIC Output
	add_instantiation_interface oct conduit INPUT
	set_instantiation_interface_parameter_value oct associatedClock {}
	set_instantiation_interface_parameter_value oct associatedReset {}
	set_instantiation_interface_parameter_value oct prSafe {false}
	add_instantiation_interface_port oct oct_rzqin oct_rzqin 1 STD_LOGIC Input
	add_instantiation_interface mem conduit INPUT
	set_instantiation_interface_parameter_value mem associatedClock {}
	set_instantiation_interface_parameter_value mem associatedReset {}
	set_instantiation_interface_parameter_value mem prSafe {false}
	add_instantiation_interface_port mem mem_ck mem_ck 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_ck_n mem_ck_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_a mem_a 17 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_act_n mem_act_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_ba mem_ba 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_bg mem_bg 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_cke mem_cke 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_cs_n mem_cs_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_odt mem_odt 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_reset_n mem_reset_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_par mem_par 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem mem_alert_n mem_alert_n 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mem mem_dqs mem_dqs 8 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem mem_dqs_n mem_dqs_n 8 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem mem_dq mem_dq 64 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem mem_dbi_n mem_dbi_n 8 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface status conduit INPUT
	set_instantiation_interface_parameter_value status associatedClock {}
	set_instantiation_interface_parameter_value status associatedReset {}
	set_instantiation_interface_parameter_value status prSafe {false}
	add_instantiation_interface_port status local_cal_success local_cal_success 1 STD_LOGIC Output
	add_instantiation_interface_port status local_cal_fail local_cal_fail 1 STD_LOGIC Output
	add_instantiation_interface emif_usr_reset_n reset OUTPUT
	set_instantiation_interface_parameter_value emif_usr_reset_n associatedClock {}
	set_instantiation_interface_parameter_value emif_usr_reset_n associatedDirectReset {}
	set_instantiation_interface_parameter_value emif_usr_reset_n associatedResetSinks {global_reset_n}
	set_instantiation_interface_parameter_value emif_usr_reset_n synchronousEdges {NONE}
	add_instantiation_interface_port emif_usr_reset_n emif_usr_reset_n reset_n 1 STD_LOGIC Output
	add_instantiation_interface emif_usr_clk clock OUTPUT
	set_instantiation_interface_parameter_value emif_usr_clk associatedDirectClock {}
	set_instantiation_interface_parameter_value emif_usr_clk clockRate {266666665}
	set_instantiation_interface_parameter_value emif_usr_clk clockRateKnown {true}
	set_instantiation_interface_parameter_value emif_usr_clk externallyDriven {false}
	set_instantiation_interface_parameter_value emif_usr_clk ptfSchematicName {}
	set_instantiation_interface_sysinfo_parameter_value emif_usr_clk clock_rate {266666665}
	add_instantiation_interface_port emif_usr_clk emif_usr_clk clk 1 STD_LOGIC Output
	add_instantiation_interface ctrl_amm_0 avalon INPUT
	set_instantiation_interface_parameter_value ctrl_amm_0 addressAlignment {DYNAMIC}
	set_instantiation_interface_parameter_value ctrl_amm_0 addressGroup {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 addressSpan {2147483648}
	set_instantiation_interface_parameter_value ctrl_amm_0 addressUnits {WORDS}
	set_instantiation_interface_parameter_value ctrl_amm_0 alwaysBurstMaxBurst {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 associatedClock {emif_usr_clk}
	set_instantiation_interface_parameter_value ctrl_amm_0 associatedReset {emif_usr_reset_n}
	set_instantiation_interface_parameter_value ctrl_amm_0 bitsPerSymbol {8}
	set_instantiation_interface_parameter_value ctrl_amm_0 bridgedAddressOffset {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 bridgesToMaster {}
	set_instantiation_interface_parameter_value ctrl_amm_0 burstOnBurstBoundariesOnly {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 burstcountUnits {WORDS}
	set_instantiation_interface_parameter_value ctrl_amm_0 constantBurstBehavior {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhFeatureGuid {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhFeatureId {35}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhFeatureMajorVersion {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhFeatureMinorVersion {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhGroupId {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhParameterData {}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhParameterDataLength {}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhParameterId {}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhParameterName {}
	set_instantiation_interface_parameter_value ctrl_amm_0 dfhParameterVersion {}
	set_instantiation_interface_parameter_value ctrl_amm_0 explicitAddressSpan {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 holdTime {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 interleaveBursts {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 isBigEndian {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 isFlash {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 isMemoryDevice {true}
	set_instantiation_interface_parameter_value ctrl_amm_0 isNonVolatileStorage {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 linewrapBursts {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 maximumPendingReadTransactions {64}
	set_instantiation_interface_parameter_value ctrl_amm_0 maximumPendingWriteTransactions {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 minimumReadLatency {1}
	set_instantiation_interface_parameter_value ctrl_amm_0 minimumResponseLatency {1}
	set_instantiation_interface_parameter_value ctrl_amm_0 minimumUninterruptedRunLength {1}
	set_instantiation_interface_parameter_value ctrl_amm_0 prSafe {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 printableDevice {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 readLatency {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 readWaitStates {1}
	set_instantiation_interface_parameter_value ctrl_amm_0 readWaitTime {1}
	set_instantiation_interface_parameter_value ctrl_amm_0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 setupTime {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value ctrl_amm_0 transparentBridge {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 wellBehavedWaitrequest {false}
	set_instantiation_interface_parameter_value ctrl_amm_0 writeLatency {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 writeWaitStates {0}
	set_instantiation_interface_parameter_value ctrl_amm_0 writeWaitTime {0}
	set_instantiation_interface_assignment_value ctrl_amm_0 embeddedsw.configuration.isFlash {0}
	set_instantiation_interface_assignment_value ctrl_amm_0 embeddedsw.configuration.isMemoryDevice {1}
	set_instantiation_interface_assignment_value ctrl_amm_0 embeddedsw.configuration.isNonVolatileStorage {0}
	set_instantiation_interface_assignment_value ctrl_amm_0 embeddedsw.configuration.isPrintableDevice {0}
	set_instantiation_interface_sysinfo_parameter_value ctrl_amm_0 address_map {<address-map><slave name='ctrl_amm_0' start='0x0' end='0x80000000' datawidth='512' /></address-map>}
	set_instantiation_interface_sysinfo_parameter_value ctrl_amm_0 address_width {31}
	set_instantiation_interface_sysinfo_parameter_value ctrl_amm_0 max_slave_data_width {512}
	add_instantiation_interface_port ctrl_amm_0 amm_ready_0 waitrequest_n 1 STD_LOGIC Output
	add_instantiation_interface_port ctrl_amm_0 amm_read_0 read 1 STD_LOGIC Input
	add_instantiation_interface_port ctrl_amm_0 amm_write_0 write 1 STD_LOGIC Input
	add_instantiation_interface_port ctrl_amm_0 amm_address_0 address 25 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ctrl_amm_0 amm_readdata_0 readdata 512 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port ctrl_amm_0 amm_writedata_0 writedata 512 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ctrl_amm_0 amm_burstcount_0 burstcount 7 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ctrl_amm_0 amm_byteenable_0 byteenable 64 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port ctrl_amm_0 amm_readdatavalid_0 readdatavalid 1 STD_LOGIC Output
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the exports
	set_interface_property ddr4_emif_global_reset_n EXPORT_OF ddr4_emif.global_reset_n
	set_interface_property ddr4_emif_pll_ref_clk EXPORT_OF ddr4_emif.pll_ref_clk
	set_interface_property ddr4_emif_pll_locked EXPORT_OF ddr4_emif.pll_locked
	set_interface_property ddr4_emif_oct EXPORT_OF ddr4_emif.oct
	set_interface_property ddr4_emif_mem EXPORT_OF ddr4_emif.mem
	set_interface_property ddr4_emif_status EXPORT_OF ddr4_emif.status
	set_interface_property ddr4_emif_emif_usr_reset_n EXPORT_OF ddr4_emif.emif_usr_reset_n
	set_interface_property ddr4_emif_emif_usr_clk EXPORT_OF ddr4_emif.emif_usr_clk
	set_interface_property ddr4_emif_ctrl_amm_0 EXPORT_OF ddr4_emif.ctrl_amm_0

	# set values for exposed HDL parameters

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="ddr4_emif">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
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
	set_project_property BOARD {Arria 10 SX SoC Development Kits DK-SOC-10AS066S-D}
	set_project_property DEVICE {10AS066N3F40E2SG}
	set_project_property DEVICE_FAMILY {Arria 10}
	set_project_property HIDE_FROM_IP_CATALOG {false}
	set_use_testbench_naming_pattern 0 {}

	# add HDL parameters

	# add the components
	add_instance a10_hps altera_arria10_hps 19.1
	set_instance_parameter_value a10_hps {BOOT_FROM_FPGA_Enable} {0}
	set_instance_parameter_value a10_hps {BSEL} {1}
	set_instance_parameter_value a10_hps {BSEL_EN} {0}
	set_instance_parameter_value a10_hps {CLK_EMACA_SOURCE} {1}
	set_instance_parameter_value a10_hps {CLK_EMACB_SOURCE} {1}
	set_instance_parameter_value a10_hps {CLK_EMAC_PTP_SOURCE} {1}
	set_instance_parameter_value a10_hps {CLK_GPIO_SOURCE} {1}
	set_instance_parameter_value a10_hps {CLK_HMC_PLL_SOURCE} {0}
	set_instance_parameter_value a10_hps {CLK_MAIN_PLL_SOURCE2} {0}
	set_instance_parameter_value a10_hps {CLK_MPU_CNT} {0}
	set_instance_parameter_value a10_hps {CLK_MPU_SOURCE} {0}
	set_instance_parameter_value a10_hps {CLK_NOC_CNT} {0}
	set_instance_parameter_value a10_hps {CLK_NOC_SOURCE} {0}
	set_instance_parameter_value a10_hps {CLK_PERI_PLL_SOURCE2} {0}
	set_instance_parameter_value a10_hps {CLK_S2F_USER0_SOURCE} {0}
	set_instance_parameter_value a10_hps {CLK_S2F_USER1_SOURCE} {0}
	set_instance_parameter_value a10_hps {CLK_SDMMC_SOURCE} {1}
	set_instance_parameter_value a10_hps {CM_Mode} {N/A}
	set_instance_parameter_value a10_hps {CM_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {CTI_Enable} {0}
	set_instance_parameter_value a10_hps {CUSTOM_MPU_CLK} {800}
	set_instance_parameter_value a10_hps {DEBUG_APB_Enable} {0}
	set_instance_parameter_value a10_hps {DISABLE_PERI_PLL} {0}
	set_instance_parameter_value a10_hps {DMA_Enable} {No No No No No No No No}
	set_instance_parameter_value a10_hps {EMAC0_CLK} {250}
	set_instance_parameter_value a10_hps {EMAC0_Mode} {RGMII_with_MDIO}
	set_instance_parameter_value a10_hps {EMAC0_PTP} {0}
	set_instance_parameter_value a10_hps {EMAC0_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {EMAC0_SWITCH_Enable} {0}
	set_instance_parameter_value a10_hps {EMAC1_CLK} {250}
	set_instance_parameter_value a10_hps {EMAC1_Mode} {N/A}
	set_instance_parameter_value a10_hps {EMAC1_PTP} {0}
	set_instance_parameter_value a10_hps {EMAC1_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {EMAC1_SWITCH_Enable} {0}
	set_instance_parameter_value a10_hps {EMAC2_CLK} {250}
	set_instance_parameter_value a10_hps {EMAC2_Mode} {N/A}
	set_instance_parameter_value a10_hps {EMAC2_PTP} {0}
	set_instance_parameter_value a10_hps {EMAC2_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {EMAC2_SWITCH_Enable} {0}
	set_instance_parameter_value a10_hps {EMAC_PTP_REF_CLK} {100}
	set_instance_parameter_value a10_hps {EMIF_BYPASS_CHECK} {0}
	set_instance_parameter_value a10_hps {EMIF_CONDUIT_Enable} {1}
	set_instance_parameter_value a10_hps {F2H_COLD_RST_Enable} {1}
	set_instance_parameter_value a10_hps {F2H_DBG_RST_Enable} {1}
	set_instance_parameter_value a10_hps {F2H_DELAY} {3}
	set_instance_parameter_value a10_hps {F2H_FREE_CLK_Enable} {0}
	set_instance_parameter_value a10_hps {F2H_FREE_CLK_FREQ} {200}
	set_instance_parameter_value a10_hps {F2H_WARM_RST_Enable} {1}
	set_instance_parameter_value a10_hps {F2SDRAM0_ENABLED} {1}
	set_instance_parameter_value a10_hps {F2SDRAM1_ENABLED} {1}
	set_instance_parameter_value a10_hps {F2SDRAM2_DELAY} {4}
	set_instance_parameter_value a10_hps {F2SDRAM2_ENABLED} {0}
	set_instance_parameter_value a10_hps {F2SDRAM_ADDRESS_WIDTH} {30}
	set_instance_parameter_value a10_hps {F2SDRAM_PORT_CONFIG} {5}
	set_instance_parameter_value a10_hps {F2SDRAM_READY_LATENCY} {0}
	set_instance_parameter_value a10_hps {F2SINTERRUPT_Enable} {1}
	set_instance_parameter_value a10_hps {F2S_Width} {0}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC0_GTX_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC0_MD_CLK} {2.5}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC1_GTX_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC1_MD_CLK} {2.5}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC2_GTX_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_EMAC2_MD_CLK} {2.5}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2C0_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2C1_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2CEMAC0_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2CEMAC1_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_I2CEMAC2_CLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_QSPI_SCLK_OUT} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SDMMC_CCLK} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SPIM0_SCLK_OUT} {100}
	set_instance_parameter_value a10_hps {FPGA_PERIPHERAL_OUTPUT_CLOCK_FREQ_SPIM1_SCLK_OUT} {100}
	set_instance_parameter_value a10_hps {GPIO_REF_CLK} {4}
	set_instance_parameter_value a10_hps {GP_Enable} {0}
	set_instance_parameter_value a10_hps {H2F_COLD_RST_Enable} {0}
	set_instance_parameter_value a10_hps {H2F_DELAY} {3}
	set_instance_parameter_value a10_hps {H2F_LW_DELAY} {3}
	set_instance_parameter_value a10_hps {H2F_PENDING_RST_Enable} {0}
	set_instance_parameter_value a10_hps {H2F_USER0_CLK_Enable} {0}
	set_instance_parameter_value a10_hps {H2F_USER0_CLK_FREQ} {400}
	set_instance_parameter_value a10_hps {H2F_USER1_CLK_Enable} {1}
	set_instance_parameter_value a10_hps {H2F_USER1_CLK_FREQ} {400}
	set_instance_parameter_value a10_hps {HMC_PLL_REF_CLK} {800}
	set_instance_parameter_value a10_hps {HPS_DIV_GPIO_FREQ} {125}
	set_instance_parameter_value a10_hps {HPS_IO_Enable} {SDMMC:D0 SDMMC:CMD SDMMC:CCLK SDMMC:D1 SDMMC:D2 SDMMC:D3 NONE NONE SDMMC:D4 SDMMC:D5 SDMMC:D6 SDMMC:D7 UART1:TX UART1:RX USB0:CLK USB0:STP USB0:DIR USB0:DATA0 USB0:DATA1 USB0:NXT USB0:DATA2 USB0:DATA3 USB0:DATA4 USB0:DATA5 USB0:DATA6 USB0:DATA7 EMAC0:TX_CLK EMAC0:TX_CTL EMAC0:RX_CLK EMAC0:RX_CTL EMAC0:TXD0 EMAC0:TXD1 EMAC0:RXD0 EMAC0:RXD1 EMAC0:TXD2 EMAC0:TXD3 EMAC0:RXD2 EMAC0:RXD3 SPIM1:CLK SPIM1:MOSI SPIM1:MISO SPIM1:SS0_N SPIM1:SS1_N GPIO NONE NONE NONE NONE MDIO0:MDIO MDIO0:MDC I2C1:SDA I2C1:SCL GPIO TRACE:CLK GPIO GPIO NONE GPIO TRACE:D0 TRACE:D1 TRACE:D2 TRACE:D3}
	set_instance_parameter_value a10_hps {I2C0_Mode} {N/A}
	set_instance_parameter_value a10_hps {I2C0_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {I2C1_Mode} {default}
	set_instance_parameter_value a10_hps {I2C1_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {I2CEMAC0_Mode} {N/A}
	set_instance_parameter_value a10_hps {I2CEMAC0_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {I2CEMAC1_Mode} {N/A}
	set_instance_parameter_value a10_hps {I2CEMAC1_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {I2CEMAC2_Mode} {N/A}
	set_instance_parameter_value a10_hps {I2CEMAC2_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {INTERNAL_OSCILLATOR_ENABLE} {60}
	set_instance_parameter_value a10_hps {JTAG_Enable} {0}
	set_instance_parameter_value a10_hps {L3_MAIN_FREE_CLK} {400}
	set_instance_parameter_value a10_hps {L4_SYS_FREE_CLK} {1}
	set_instance_parameter_value a10_hps {LWH2F_Enable} {2}
	set_instance_parameter_value a10_hps {MPU_CLK_VCCL} {1}
	set_instance_parameter_value a10_hps {MPU_EVENTS_Enable} {0}
	set_instance_parameter_value a10_hps {NAND_Mode} {N/A}
	set_instance_parameter_value a10_hps {NAND_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {NOCDIV_CS_ATCLK} {0}
	set_instance_parameter_value a10_hps {NOCDIV_CS_PDBGCLK} {1}
	set_instance_parameter_value a10_hps {NOCDIV_CS_TRACECLK} {1}
	set_instance_parameter_value a10_hps {NOCDIV_L4MAINCLK} {0}
	set_instance_parameter_value a10_hps {NOCDIV_L4MPCLK} {1}
	set_instance_parameter_value a10_hps {NOCDIV_L4SPCLK} {2}
	set_instance_parameter_value a10_hps {OVERIDE_PERI_PLL} {0}
	set_instance_parameter_value a10_hps {PERI_PLL_MANUAL_VCO_FREQ} {2000}
	set_instance_parameter_value a10_hps {PLL_CLK0} {Unused}
	set_instance_parameter_value a10_hps {PLL_CLK1} {Unused}
	set_instance_parameter_value a10_hps {PLL_CLK2} {Unused}
	set_instance_parameter_value a10_hps {PLL_CLK3} {Unused}
	set_instance_parameter_value a10_hps {PLL_CLK4} {Unused}
	set_instance_parameter_value a10_hps {QSPI_Mode} {N/A}
	set_instance_parameter_value a10_hps {QSPI_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {RUN_INTERNAL_BUILD_CHECKS} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_CLOCKPERIPHERAL_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_CTI_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_DMA_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_EMAC0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_EMAC1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_EMAC2_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_FPGAMANAGER_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_GPIO_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_HMC_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_I2C0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_I2C1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_I2CEMAC0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_I2CEMAC1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_I2CEMAC2_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_L4TIMER_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_NAND_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_QSPI_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SDMMC_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SPIM0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SPIM1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SPIS0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SPIS1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SYSTEMMANAGER_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_SYSTIMER_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_UART0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_UART1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_USB0_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_USB1_Enable} {0}
	set_instance_parameter_value a10_hps {S2FINTERRUPT_WATCHDOG_Enable} {0}
	set_instance_parameter_value a10_hps {S2F_Width} {4}
	set_instance_parameter_value a10_hps {SDMMC_Mode} {8-bit}
	set_instance_parameter_value a10_hps {SDMMC_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {SDMMC_REF_CLK} {200}
	set_instance_parameter_value a10_hps {SECURITY_MODULE_Enable} {0}
	set_instance_parameter_value a10_hps {SPIM0_Mode} {N/A}
	set_instance_parameter_value a10_hps {SPIM0_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {SPIM1_Mode} {Dual_slave_selects}
	set_instance_parameter_value a10_hps {SPIM1_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {SPIS0_Mode} {N/A}
	set_instance_parameter_value a10_hps {SPIS0_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {SPIS1_Mode} {N/A}
	set_instance_parameter_value a10_hps {SPIS1_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {STM_Enable} {1}
	set_instance_parameter_value a10_hps {TESTIOCTRL_DEBUGCLKSEL} {16}
	set_instance_parameter_value a10_hps {TESTIOCTRL_MAINCLKSEL} {8}
	set_instance_parameter_value a10_hps {TESTIOCTRL_PERICLKSEL} {8}
	set_instance_parameter_value a10_hps {TEST_Enable} {0}
	set_instance_parameter_value a10_hps {TRACE_Mode} {default}
	set_instance_parameter_value a10_hps {TRACE_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {UART0_Mode} {N/A}
	set_instance_parameter_value a10_hps {UART0_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {UART1_Mode} {No_flow_control}
	set_instance_parameter_value a10_hps {UART1_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {USB0_Mode} {default}
	set_instance_parameter_value a10_hps {USB0_PinMuxing} {IO}
	set_instance_parameter_value a10_hps {USB1_Mode} {N/A}
	set_instance_parameter_value a10_hps {USB1_PinMuxing} {Unused}
	set_instance_parameter_value a10_hps {USE_DEFAULT_MPU_CLK} {0}
	set_instance_parameter_value a10_hps {eosc1_clk_mhz} {25.0}
	add_component emif_a10_hps ip/hps/hps_emif_a10_hps.ip altera_emif_a10_hps emif_a10_hps
	load_component emif_a10_hps
	set_component_parameter_value BOARD_DDR3_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_DDR3_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR3_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR3_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_DDR3_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_DDR3_IS_SKEW_WITHIN_DQS_DESKEWED {0}
	set_component_parameter_value BOARD_DDR3_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR3_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR3_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR3_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR3_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_DDR3_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR3_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR3_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR3_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_RCLK_SLEW_RATE {5.0}
	set_component_parameter_value BOARD_DDR3_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_RDATA_SLEW_RATE {2.5}
	set_component_parameter_value BOARD_DDR3_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR3_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR3_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR3_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_DDR3_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_DDR4_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_DDR4_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR4_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR4_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_DDR4_IS_SKEW_WITHIN_AC_DESKEWED {0}
	set_component_parameter_value BOARD_DDR4_IS_SKEW_WITHIN_DQS_DESKEWED {1}
	set_component_parameter_value BOARD_DDR4_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR4_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDR4_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDR4_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR4_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_DDR4_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDR4_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR4_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR4_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_RCLK_SLEW_RATE {8.0}
	set_component_parameter_value BOARD_DDR4_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_RDATA_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR4_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDR4_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDR4_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDR4_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_DDR4_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_DDRT_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_DDRT_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDRT_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDRT_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_DDRT_IS_SKEW_WITHIN_AC_DESKEWED {0}
	set_component_parameter_value BOARD_DDRT_IS_SKEW_WITHIN_DQS_DESKEWED {1}
	set_component_parameter_value BOARD_DDRT_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDRT_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_DDRT_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_DDRT_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDRT_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_DDRT_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_DDRT_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDRT_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDRT_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_RCLK_SLEW_RATE {8.0}
	set_component_parameter_value BOARD_DDRT_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_RDATA_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDRT_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_DDRT_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_DDRT_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_DDRT_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_DDRT_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_LPDDR3_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_DQS_TO_CK_SKEW_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_LPDDR3_IS_SKEW_WITHIN_DQS_DESKEWED {0}
	set_component_parameter_value BOARD_LPDDR3_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_LPDDR3_MAX_DQS_DELAY_NS {0.6}
	set_component_parameter_value BOARD_LPDDR3_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_PKG_BRD_SKEW_WITHIN_DQS_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_LPDDR3_SKEW_BETWEEN_DQS_NS {0.02}
	set_component_parameter_value BOARD_LPDDR3_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_LPDDR3_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_RDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_LPDDR3_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_LPDDR3_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_LPDDR3_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_QDR2_AC_TO_K_SKEW_NS {0.0}
	set_component_parameter_value BOARD_QDR2_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR2_BRD_SKEW_WITHIN_D_NS {0.02}
	set_component_parameter_value BOARD_QDR2_BRD_SKEW_WITHIN_Q_NS {0.02}
	set_component_parameter_value BOARD_QDR2_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_QDR2_IS_SKEW_WITHIN_D_DESKEWED {0}
	set_component_parameter_value BOARD_QDR2_IS_SKEW_WITHIN_Q_DESKEWED {0}
	set_component_parameter_value BOARD_QDR2_MAX_K_DELAY_NS {0.6}
	set_component_parameter_value BOARD_QDR2_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR2_PKG_BRD_SKEW_WITHIN_D_NS {0.02}
	set_component_parameter_value BOARD_QDR2_PKG_BRD_SKEW_WITHIN_Q_NS {0.02}
	set_component_parameter_value BOARD_QDR2_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR2_USER_K_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR2_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_RCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR2_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_RDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR2_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR2_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR2_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_QDR2_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_QDR4_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_QDR4_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR4_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_QDR4_DK_TO_CK_SKEW_NS {-0.02}
	set_component_parameter_value BOARD_QDR4_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_QDR4_IS_SKEW_WITHIN_QK_DESKEWED {1}
	set_component_parameter_value BOARD_QDR4_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_QDR4_MAX_DK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_QDR4_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_QDR4_PKG_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_QDR4_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_QDR4_SKEW_BETWEEN_DK_NS {0.02}
	set_component_parameter_value BOARD_QDR4_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR4_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR4_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_RCLK_SLEW_RATE {5.0}
	set_component_parameter_value BOARD_QDR4_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_RDATA_SLEW_RATE {2.5}
	set_component_parameter_value BOARD_QDR4_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_QDR4_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_QDR4_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_QDR4_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_QDR4_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value BOARD_RLD3_AC_TO_CK_SKEW_NS {0.0}
	set_component_parameter_value BOARD_RLD3_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_RLD3_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_RLD3_DK_TO_CK_SKEW_NS {-0.02}
	set_component_parameter_value BOARD_RLD3_IS_SKEW_WITHIN_AC_DESKEWED {1}
	set_component_parameter_value BOARD_RLD3_IS_SKEW_WITHIN_QK_DESKEWED {0}
	set_component_parameter_value BOARD_RLD3_MAX_CK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_RLD3_MAX_DK_DELAY_NS {0.6}
	set_component_parameter_value BOARD_RLD3_PKG_BRD_SKEW_WITHIN_AC_NS {0.02}
	set_component_parameter_value BOARD_RLD3_PKG_BRD_SKEW_WITHIN_QK_NS {0.02}
	set_component_parameter_value BOARD_RLD3_SKEW_BETWEEN_DIMMS_NS {0.05}
	set_component_parameter_value BOARD_RLD3_SKEW_BETWEEN_DK_NS {0.02}
	set_component_parameter_value BOARD_RLD3_USER_AC_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_AC_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_RLD3_USER_CK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_RLD3_USER_RCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_RCLK_SLEW_RATE {7.0}
	set_component_parameter_value BOARD_RLD3_USER_RDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_RDATA_SLEW_RATE {3.5}
	set_component_parameter_value BOARD_RLD3_USER_WCLK_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_WCLK_SLEW_RATE {4.0}
	set_component_parameter_value BOARD_RLD3_USER_WDATA_ISI_NS {0.0}
	set_component_parameter_value BOARD_RLD3_USER_WDATA_SLEW_RATE {2.0}
	set_component_parameter_value BOARD_RLD3_USE_DEFAULT_ISI_VALUES {1}
	set_component_parameter_value BOARD_RLD3_USE_DEFAULT_SLEW_RATES {1}
	set_component_parameter_value CTRL_DDR3_ADDR_ORDER_ENUM {DDR3_CTRL_ADDR_ORDER_CS_R_B_C}
	set_component_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_DDR3_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_DDR3_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_DDR3_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_ST}
	set_component_parameter_value CTRL_DDR3_ECC_AUTO_CORRECTION_EN {0}
	set_component_parameter_value CTRL_DDR3_ECC_EN {0}
	set_component_parameter_value CTRL_DDR3_ECC_READDATAERROR_EN {0}
	set_component_parameter_value CTRL_DDR3_ECC_STATUS_EN {0}
	set_component_parameter_value CTRL_DDR3_MMR_EN {0}
	set_component_parameter_value CTRL_DDR3_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_REORDER_EN {1}
	set_component_parameter_value CTRL_DDR3_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR3_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_DDR3_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_DDR3_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR3_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR3_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_ADDR_ORDER_ENUM {DDR4_CTRL_ADDR_ORDER_CS_R_B_C_BG}
	set_component_parameter_value CTRL_DDR4_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_DDR4_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_DDR4_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_DDR4_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_ST}
	set_component_parameter_value CTRL_DDR4_ECC_AUTO_CORRECTION_EN {0}
	set_component_parameter_value CTRL_DDR4_ECC_EN {0}
	set_component_parameter_value CTRL_DDR4_ECC_READDATAERROR_EN {0}
	set_component_parameter_value CTRL_DDR4_ECC_STATUS_EN {0}
	set_component_parameter_value CTRL_DDR4_MAJOR_MODE_EN {0}
	set_component_parameter_value CTRL_DDR4_MMR_EN {1}
	set_component_parameter_value CTRL_DDR4_POST_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_POST_REFRESH_LOWER_LIMIT {0}
	set_component_parameter_value CTRL_DDR4_POST_REFRESH_UPPER_LIMIT {2}
	set_component_parameter_value CTRL_DDR4_PRE_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_PRE_REFRESH_UPPER_LIMIT {1}
	set_component_parameter_value CTRL_DDR4_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_REORDER_EN {1}
	set_component_parameter_value CTRL_DDR4_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_DDR4_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_DDR4_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDR4_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDR4_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_ADDR_INTERLEAVING {COARSE}
	set_component_parameter_value CTRL_DDRT_ADDR_ORDER_ENUM {DDRT_CTRL_ADDR_ORDER_CS_R_B_C_BG}
	set_component_parameter_value CTRL_DDRT_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_DDRT_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_DDRT_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_DDRT_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_DDRT_DIMM_DENSITY {128}
	set_component_parameter_value CTRL_DDRT_DIMM_VIRAL_FLOW_EN {0}
	set_component_parameter_value CTRL_DDRT_ECC_AUTO_CORRECTION_EN {0}
	set_component_parameter_value CTRL_DDRT_ECC_EN {0}
	set_component_parameter_value CTRL_DDRT_ECC_READDATAERROR_EN {1}
	set_component_parameter_value CTRL_DDRT_ECC_STATUS_EN {1}
	set_component_parameter_value CTRL_DDRT_ERR_INJECT_EN {0}
	set_component_parameter_value CTRL_DDRT_ERR_REPLAY_EN {0}
	set_component_parameter_value CTRL_DDRT_EXT_ERR_INJECT_EN {0}
	set_component_parameter_value CTRL_DDRT_GNT_TO_GNT_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_GNT_TO_WR_DIFF_CHIP_DELTA_CYCS {1}
	set_component_parameter_value CTRL_DDRT_GNT_TO_WR_SAME_CHIP_DELTA_CYCS {1}
	set_component_parameter_value CTRL_DDRT_HOST_VIRAL_FLOW_EN {0}
	set_component_parameter_value CTRL_DDRT_MMR_EN {0}
	set_component_parameter_value CTRL_DDRT_NUM_OF_AXIS_ID {1}
	set_component_parameter_value CTRL_DDRT_PARITY_CMD_EN {0}
	set_component_parameter_value CTRL_DDRT_PMM_ADR_FLOW_EN {0}
	set_component_parameter_value CTRL_DDRT_PMM_WPQ_FLUSH_EN {0}
	set_component_parameter_value CTRL_DDRT_POISON_DETECTION_EN {0}
	set_component_parameter_value CTRL_DDRT_PORT_AFI_C_WIDTH {2}
	set_component_parameter_value CTRL_DDRT_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_REORDER_EN {1}
	set_component_parameter_value CTRL_DDRT_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDRT_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_DDRT_UPI_EN {0}
	set_component_parameter_value CTRL_DDRT_UPI_ID_WIDTH {8}
	set_component_parameter_value CTRL_DDRT_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_DDRT_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_DDRT_WR_ACK_POLICY {POSTED}
	set_component_parameter_value CTRL_DDRT_WR_TO_GNT_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_GNT_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_DDRT_ZQ_INTERVAL_MS {3}
	set_component_parameter_value CTRL_LPDDR3_ADDR_ORDER_ENUM {LPDDR3_CTRL_ADDR_ORDER_CS_R_B_C}
	set_component_parameter_value CTRL_LPDDR3_AUTO_POWER_DOWN_CYCS {32}
	set_component_parameter_value CTRL_LPDDR3_AUTO_POWER_DOWN_EN {0}
	set_component_parameter_value CTRL_LPDDR3_AUTO_PRECHARGE_EN {0}
	set_component_parameter_value CTRL_LPDDR3_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_ST}
	set_component_parameter_value CTRL_LPDDR3_MMR_EN {0}
	set_component_parameter_value CTRL_LPDDR3_RD_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_RD_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_RD_TO_WR_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_REORDER_EN {1}
	set_component_parameter_value CTRL_LPDDR3_SELF_REFRESH_EN {0}
	set_component_parameter_value CTRL_LPDDR3_STARVE_LIMIT {10}
	set_component_parameter_value CTRL_LPDDR3_USER_PRIORITY_EN {0}
	set_component_parameter_value CTRL_LPDDR3_USER_REFRESH_EN {0}
	set_component_parameter_value CTRL_LPDDR3_WR_TO_RD_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_WR_TO_RD_SAME_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_LPDDR3_WR_TO_WR_DIFF_CHIP_DELTA_CYCS {0}
	set_component_parameter_value CTRL_QDR2_AVL_ENABLE_POWER_OF_TWO_BUS {0}
	set_component_parameter_value CTRL_QDR2_AVL_MAX_BURST_COUNT {4}
	set_component_parameter_value CTRL_QDR2_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_QDR4_ADD_RAW_TURNAROUND_DELAY_CYC {0}
	set_component_parameter_value CTRL_QDR4_ADD_WAR_TURNAROUND_DELAY_CYC {0}
	set_component_parameter_value CTRL_QDR4_AVL_ENABLE_POWER_OF_TWO_BUS {0}
	set_component_parameter_value CTRL_QDR4_AVL_MAX_BURST_COUNT {4}
	set_component_parameter_value CTRL_QDR4_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_QDR4_DEF_RAW_TURNAROUND_DELAY_CYC {4}
	set_component_parameter_value CTRL_RLD2_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value CTRL_RLD3_ADDR_ORDER_ENUM {RLD3_CTRL_ADDR_ORDER_CS_R_B_C}
	set_component_parameter_value CTRL_RLD3_AVL_PROTOCOL_ENUM {CTRL_AVL_PROTOCOL_MM}
	set_component_parameter_value DIAG_ADD_READY_PIPELINE {1}
	set_component_parameter_value DIAG_BOARD_DELAY_CONFIG_STR {}
	set_component_parameter_value DIAG_DB_RESET_AUTO_RELEASE {avl_release}
	set_component_parameter_value DIAG_DDR3_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_DDR3_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_DDR3_CAL_ADDR0 {0}
	set_component_parameter_value DIAG_DDR3_CAL_ADDR1 {8}
	set_component_parameter_value DIAG_DDR3_CAL_ENABLE_MICRON_AP {0}
	set_component_parameter_value DIAG_DDR3_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value DIAG_DDR3_CAL_FULL_CAL_ON_RESET {1}
	set_component_parameter_value DIAG_DDR3_CA_DESKEW_EN {0}
	set_component_parameter_value DIAG_DDR3_CA_LEVEL_EN {0}
	set_component_parameter_value DIAG_DDR3_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_DDR3_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR3_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_DDR3_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_DDR3_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_DDR3_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_DDR3_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR3_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_DDR3_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_DDR3_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_DDR3_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_DDR3_INTERFACE_ID {0}
	set_component_parameter_value DIAG_DDR3_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_DDR3_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_DDR3_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_DDR3_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_DDR3_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_DDR3_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR3_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR3_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_DDR3_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_DDR3_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_DDR3_USE_TG_HBM {0}
	set_component_parameter_value DIAG_DDR4_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_DDR4_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_DDR4_CAL_ADDR0 {0}
	set_component_parameter_value DIAG_DDR4_CAL_ADDR1 {8}
	set_component_parameter_value DIAG_DDR4_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value DIAG_DDR4_CAL_FULL_CAL_ON_RESET {1}
	set_component_parameter_value DIAG_DDR4_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_DDR4_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR4_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_DDR4_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_DDR4_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_DDR4_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_DDR4_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_DDR4_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_DDR4_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_DDR4_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_DDR4_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_DDR4_INTERFACE_ID {0}
	set_component_parameter_value DIAG_DDR4_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_DDR4_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_DDR4_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_DDR4_SKIP_AC_PARITY_CHECK {0}
	set_component_parameter_value DIAG_DDR4_SKIP_CA_DESKEW {0}
	set_component_parameter_value DIAG_DDR4_SKIP_CA_LEVEL {1}
	set_component_parameter_value DIAG_DDR4_SKIP_VREF_CAL {0}
	set_component_parameter_value DIAG_DDR4_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_DDR4_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_DDR4_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR4_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_DDR4_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_DDR4_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_DDR4_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_DDR4_USE_TG_HBM {0}
	set_component_parameter_value DIAG_DDRT_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_DDRT_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_DDRT_CAL_ADDR0 {0}
	set_component_parameter_value DIAG_DDRT_CAL_ADDR1 {8}
	set_component_parameter_value DIAG_DDRT_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value DIAG_DDRT_CAL_FULL_CAL_ON_RESET {1}
	set_component_parameter_value DIAG_DDRT_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_DDRT_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_DDRT_EFF_TEST {0}
	set_component_parameter_value DIAG_DDRT_ENABLE_DEFAULT_MODE {1}
	set_component_parameter_value DIAG_DDRT_ENABLE_DRIVER_MARGINING {0}
	set_component_parameter_value DIAG_DDRT_ENABLE_ENHANCED_TESTING {0}
	set_component_parameter_value DIAG_DDRT_ENABLE_USER_MODE {0}
	set_component_parameter_value DIAG_DDRT_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_DDRT_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_DDRT_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_DDRT_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_DDRT_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_DDRT_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_DDRT_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_DDRT_INTERFACE_ID {0}
	set_component_parameter_value DIAG_DDRT_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_DDRT_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_DDRT_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_DDRT_SKIP_CA_DESKEW {0}
	set_component_parameter_value DIAG_DDRT_SKIP_CA_LEVEL {0}
	set_component_parameter_value DIAG_DDRT_SKIP_VREF_CAL {0}
	set_component_parameter_value DIAG_DDRT_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_DDRT_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_DDRT_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_DDRT_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_DDRT_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_DDRT_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_DDRT_USE_TG_AVL_2 {1}
	set_component_parameter_value DIAG_DDRT_USE_TG_HBM {0}
	set_component_parameter_value DIAG_ECLIPSE_DEBUG {0}
	set_component_parameter_value DIAG_ENABLE_HPS_EMIF_DEBUG {0}
	set_component_parameter_value DIAG_ENABLE_JTAG_UART {0}
	set_component_parameter_value DIAG_ENABLE_JTAG_UART_HEX {0}
	set_component_parameter_value DIAG_EXPORT_PLL_LOCKED {0}
	set_component_parameter_value DIAG_EXPORT_PLL_REF_CLK_OUT {0}
	set_component_parameter_value DIAG_EXPORT_VJI {0}
	set_component_parameter_value DIAG_EXPOSE_DFT_SIGNALS {0}
	set_component_parameter_value DIAG_EXPOSE_EARLY_READY {0}
	set_component_parameter_value DIAG_EXPOSE_RD_TYPE {0}
	set_component_parameter_value DIAG_EXTRA_CONFIGS {}
	set_component_parameter_value DIAG_EXT_DOCS {0}
	set_component_parameter_value DIAG_EX_DESIGN_ADD_TEST_EMIFS {}
	set_component_parameter_value DIAG_EX_DESIGN_SEPARATE_RESETS {0}
	set_component_parameter_value DIAG_FAST_SIM_OVERRIDE {FAST_SIM_OVERRIDE_DEFAULT}
	set_component_parameter_value DIAG_HMC_HRC {auto}
	set_component_parameter_value DIAG_LPDDR3_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_LPDDR3_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_LPDDR3_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_LPDDR3_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_LPDDR3_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_LPDDR3_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_LPDDR3_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_LPDDR3_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_LPDDR3_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_LPDDR3_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_LPDDR3_INTERFACE_ID {0}
	set_component_parameter_value DIAG_LPDDR3_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_LPDDR3_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_LPDDR3_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_LPDDR3_SKIP_CA_DESKEW {0}
	set_component_parameter_value DIAG_LPDDR3_SKIP_CA_LEVEL {0}
	set_component_parameter_value DIAG_LPDDR3_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_LPDDR3_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_LPDDR3_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_LPDDR3_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_LPDDR3_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_LPDDR3_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_LPDDR3_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_LPDDR3_USE_TG_HBM {0}
	set_component_parameter_value DIAG_QDR2_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_QDR2_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_QDR2_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_QDR2_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR2_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_QDR2_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_QDR2_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_QDR2_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_QDR2_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR2_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_QDR2_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_QDR2_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_QDR2_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_QDR2_INTERFACE_ID {0}
	set_component_parameter_value DIAG_QDR2_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_QDR2_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_QDR2_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_QDR2_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_QDR2_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_QDR2_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR2_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR2_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_QDR2_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_QDR2_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_QDR2_USE_TG_HBM {0}
	set_component_parameter_value DIAG_QDR4_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_QDR4_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_QDR4_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_QDR4_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR4_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_QDR4_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_QDR4_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_QDR4_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_QDR4_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_QDR4_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_QDR4_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_QDR4_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_QDR4_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_QDR4_INTERFACE_ID {0}
	set_component_parameter_value DIAG_QDR4_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_QDR4_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_QDR4_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_QDR4_SKIP_VREF_CAL {0}
	set_component_parameter_value DIAG_QDR4_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_QDR4_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_QDR4_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR4_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_QDR4_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_QDR4_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_QDR4_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_QDR4_USE_TG_HBM {0}
	set_component_parameter_value DIAG_RLD2_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_RLD2_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_RLD2_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_RLD2_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD2_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_RLD2_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_RLD2_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_RLD2_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_RLD2_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD2_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_RLD2_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_RLD2_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_RLD2_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_RLD2_INTERFACE_ID {0}
	set_component_parameter_value DIAG_RLD2_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_RLD2_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_RLD2_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_RLD2_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_RLD2_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_RLD2_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD2_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD2_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_RLD2_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_RLD2_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_RLD2_USE_TG_HBM {0}
	set_component_parameter_value DIAG_RLD3_ABSTRACT_PHY {0}
	set_component_parameter_value DIAG_RLD3_AC_PARITY_ERR {0}
	set_component_parameter_value DIAG_RLD3_CA_DESKEW_EN {0}
	set_component_parameter_value DIAG_RLD3_CA_LEVEL_EN {0}
	set_component_parameter_value DIAG_RLD3_DISABLE_AFI_P2C_REGISTERS {0}
	set_component_parameter_value DIAG_RLD3_EFFICIENCY_MONITOR {EFFMON_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD3_ENABLE_DEFAULT_MODE {0}
	set_component_parameter_value DIAG_RLD3_ENABLE_USER_MODE {1}
	set_component_parameter_value DIAG_RLD3_EXPORT_SEQ_AVALON_HEAD_OF_CHAIN {1}
	set_component_parameter_value DIAG_RLD3_EXPORT_SEQ_AVALON_MASTER {0}
	set_component_parameter_value DIAG_RLD3_EXPORT_SEQ_AVALON_SLAVE {CAL_DEBUG_EXPORT_MODE_DISABLED}
	set_component_parameter_value DIAG_RLD3_EXPORT_TG_CFG_AVALON_SLAVE {TG_CFG_AMM_EXPORT_MODE_EXPORT}
	set_component_parameter_value DIAG_RLD3_EX_DESIGN_ISSP_EN {1}
	set_component_parameter_value DIAG_RLD3_EX_DESIGN_NUM_OF_SLAVES {1}
	set_component_parameter_value DIAG_RLD3_EX_DESIGN_SEPARATE_RZQS {1}
	set_component_parameter_value DIAG_RLD3_INTERFACE_ID {0}
	set_component_parameter_value DIAG_RLD3_SEPARATE_READ_WRITE_ITFS {0}
	set_component_parameter_value DIAG_RLD3_SIM_CAL_MODE_ENUM {SIM_CAL_MODE_SKIP}
	set_component_parameter_value DIAG_RLD3_SIM_VERBOSE {1}
	set_component_parameter_value DIAG_RLD3_TG2_TEST_DURATION {SHORT}
	set_component_parameter_value DIAG_RLD3_USER_SIM_MEMORY_PRELOAD {0}
	set_component_parameter_value DIAG_RLD3_USER_SIM_MEMORY_PRELOAD_PRI_EMIF_FILE {EMIF_PRI_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD3_USER_SIM_MEMORY_PRELOAD_SEC_EMIF_FILE {EMIF_SEC_PRELOAD.txt}
	set_component_parameter_value DIAG_RLD3_USER_USE_SIM_MEMORY_VALIDATION_TG {1}
	set_component_parameter_value DIAG_RLD3_USE_NEW_EFFMON_S10 {0}
	set_component_parameter_value DIAG_RLD3_USE_TG_AVL_2 {0}
	set_component_parameter_value DIAG_RLD3_USE_TG_HBM {0}
	set_component_parameter_value DIAG_RS232_UART_BAUDRATE {57600}
	set_component_parameter_value DIAG_SEQ_RESET_AUTO_RELEASE {avl}
	set_component_parameter_value DIAG_SIM_REGTEST_MODE {0}
	set_component_parameter_value DIAG_SOFT_NIOS_CLOCK_FREQUENCY {100}
	set_component_parameter_value DIAG_SOFT_NIOS_MODE {SOFT_NIOS_MODE_DISABLED}
	set_component_parameter_value DIAG_SYNTH_FOR_SIM {0}
	set_component_parameter_value DIAG_TG_AVL_2_NUM_CFG_INTERFACES {0}
	set_component_parameter_value DIAG_TIMING_REGTEST_MODE {0}
	set_component_parameter_value DIAG_USE_BOARD_DELAY_MODEL {0}
	set_component_parameter_value DIAG_USE_RS232_UART {0}
	set_component_parameter_value DIAG_VERBOSE_IOAUX {0}
	set_component_parameter_value EMIF_0_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_0_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_0_STORED_PARAM {}
	set_component_parameter_value EMIF_10_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_10_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_10_STORED_PARAM {}
	set_component_parameter_value EMIF_11_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_11_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_11_STORED_PARAM {}
	set_component_parameter_value EMIF_12_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_12_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_12_STORED_PARAM {}
	set_component_parameter_value EMIF_13_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_13_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_13_STORED_PARAM {}
	set_component_parameter_value EMIF_14_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_14_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_14_STORED_PARAM {}
	set_component_parameter_value EMIF_15_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_15_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_15_STORED_PARAM {}
	set_component_parameter_value EMIF_1_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_1_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_1_STORED_PARAM {}
	set_component_parameter_value EMIF_2_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_2_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_2_STORED_PARAM {}
	set_component_parameter_value EMIF_3_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_3_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_3_STORED_PARAM {}
	set_component_parameter_value EMIF_4_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_4_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_4_STORED_PARAM {}
	set_component_parameter_value EMIF_5_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_5_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_5_STORED_PARAM {}
	set_component_parameter_value EMIF_6_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_6_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_6_STORED_PARAM {}
	set_component_parameter_value EMIF_7_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_7_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_7_STORED_PARAM {}
	set_component_parameter_value EMIF_8_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_8_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_8_STORED_PARAM {}
	set_component_parameter_value EMIF_9_CONN_TO_CALIP {CALIP_0}
	set_component_parameter_value EMIF_9_REF_CLK_SHARING {EXPORTED}
	set_component_parameter_value EMIF_9_STORED_PARAM {}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_DDR3_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_DDR4_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_DDRT_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_LPDDR3_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_QDR2_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_QDR4_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_RLD2_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_BSI {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_CDC {0}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_SIM {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_GEN_SYNTH {1}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_HDL_FORMAT {HDL_FORMAT_VERILOG}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_PREV_PRESET {TARGET_DEV_KIT_NONE}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_SEL_DESIGN {AVAIL_EX_DESIGNS_GEN_DESIGN}
	set_component_parameter_value EX_DESIGN_GUI_RLD3_TARGET_DEV_KIT {TARGET_DEV_KIT_NONE}
	set_component_parameter_value INTERNAL_TESTING_MODE {0}
	set_component_parameter_value IS_ED_SLAVE {0}
	set_component_parameter_value MEM_DDR3_ALERT_N_DQS_GROUP {0}
	set_component_parameter_value MEM_DDR3_ALERT_N_PLACEMENT_ENUM {DDR3_ALERT_N_PLACEMENT_AC_LANES}
	set_component_parameter_value MEM_DDR3_ASR_ENUM {DDR3_ASR_MANUAL}
	set_component_parameter_value MEM_DDR3_ATCL_ENUM {DDR3_ATCL_DISABLED}
	set_component_parameter_value MEM_DDR3_BANK_ADDR_WIDTH {3}
	set_component_parameter_value MEM_DDR3_BL_ENUM {DDR3_BL_BL8}
	set_component_parameter_value MEM_DDR3_BT_ENUM {DDR3_BT_SEQUENTIAL}
	set_component_parameter_value MEM_DDR3_CFG_GEN_DBE {0}
	set_component_parameter_value MEM_DDR3_CFG_GEN_SBE {0}
	set_component_parameter_value MEM_DDR3_CKE_PER_DIMM {1}
	set_component_parameter_value MEM_DDR3_CK_WIDTH {1}
	set_component_parameter_value MEM_DDR3_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_DDR3_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_DDR3_DISCRETE_MIRROR_ADDRESSING_EN {0}
	set_component_parameter_value MEM_DDR3_DLL_EN {1}
	set_component_parameter_value MEM_DDR3_DM_EN {1}
	set_component_parameter_value MEM_DDR3_DQ_PER_DQS {8}
	set_component_parameter_value MEM_DDR3_DQ_WIDTH {32}
	set_component_parameter_value MEM_DDR3_DRV_STR_ENUM {DDR3_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDR3_FORMAT_ENUM {MEM_FORMAT_UDIMM}
	set_component_parameter_value MEM_DDR3_HIDE_ADV_MR_SETTINGS {1}
	set_component_parameter_value MEM_DDR3_LRDIMM_EXTENDED_CONFIG {000000000000000000}
	set_component_parameter_value MEM_DDR3_MIRROR_ADDRESSING_EN {1}
	set_component_parameter_value MEM_DDR3_NUM_OF_DIMMS {1}
	set_component_parameter_value MEM_DDR3_PD_ENUM {DDR3_PD_OFF}
	set_component_parameter_value MEM_DDR3_RANKS_PER_DIMM {1}
	set_component_parameter_value MEM_DDR3_RDIMM_CONFIG {0000000000000000}
	set_component_parameter_value MEM_DDR3_ROW_ADDR_WIDTH {15}
	set_component_parameter_value MEM_DDR3_RTT_NOM_ENUM {DDR3_RTT_NOM_ODT_DISABLED}
	set_component_parameter_value MEM_DDR3_RTT_WR_ENUM {DDR3_RTT_WR_RZQ_4}
	set_component_parameter_value MEM_DDR3_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_DDR3_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_DDR3_R_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR3_R_ODT0_4X4 {off off on off}
	set_component_parameter_value MEM_DDR3_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_DDR3_R_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR3_R_ODT1_4X4 {off off off on}
	set_component_parameter_value MEM_DDR3_R_ODT2_4X4 {on off off off}
	set_component_parameter_value MEM_DDR3_R_ODT3_4X4 {off on off off}
	set_component_parameter_value MEM_DDR3_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR3_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR3_R_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR3_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR3_SPEEDBIN_ENUM {DDR3_SPEEDBIN_2133}
	set_component_parameter_value MEM_DDR3_SRT_ENUM {DDR3_SRT_NORMAL}
	set_component_parameter_value MEM_DDR3_TCL {14}
	set_component_parameter_value MEM_DDR3_TDH_DC_MV {100}
	set_component_parameter_value MEM_DDR3_TDH_PS {55}
	set_component_parameter_value MEM_DDR3_TDQSCK_PS {180}
	set_component_parameter_value MEM_DDR3_TDQSQ_PS {75}
	set_component_parameter_value MEM_DDR3_TDQSS_CYC {0.27}
	set_component_parameter_value MEM_DDR3_TDSH_CYC {0.18}
	set_component_parameter_value MEM_DDR3_TDSS_CYC {0.18}
	set_component_parameter_value MEM_DDR3_TDS_AC_MV {135}
	set_component_parameter_value MEM_DDR3_TDS_PS {53}
	set_component_parameter_value MEM_DDR3_TFAW_NS {25.0}
	set_component_parameter_value MEM_DDR3_TIH_DC_MV {100}
	set_component_parameter_value MEM_DDR3_TIH_PS {95}
	set_component_parameter_value MEM_DDR3_TINIT_US {500}
	set_component_parameter_value MEM_DDR3_TIS_AC_MV {135}
	set_component_parameter_value MEM_DDR3_TIS_PS {60}
	set_component_parameter_value MEM_DDR3_TMRD_CK_CYC {4}
	set_component_parameter_value MEM_DDR3_TQH_CYC {0.38}
	set_component_parameter_value MEM_DDR3_TQSH_CYC {0.4}
	set_component_parameter_value MEM_DDR3_TRAS_NS {33.0}
	set_component_parameter_value MEM_DDR3_TRCD_NS {13.09}
	set_component_parameter_value MEM_DDR3_TREFI_US {7.8}
	set_component_parameter_value MEM_DDR3_TRFC_NS {160.0}
	set_component_parameter_value MEM_DDR3_TRP_NS {13.09}
	set_component_parameter_value MEM_DDR3_TRRD_CYC {6}
	set_component_parameter_value MEM_DDR3_TRTP_CYC {8}
	set_component_parameter_value MEM_DDR3_TWLH_PS {125.0}
	set_component_parameter_value MEM_DDR3_TWLS_PS {125.0}
	set_component_parameter_value MEM_DDR3_TWR_NS {15.0}
	set_component_parameter_value MEM_DDR3_TWTR_CYC {8}
	set_component_parameter_value MEM_DDR3_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_DDR3_WTCL {10}
	set_component_parameter_value MEM_DDR3_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_DDR3_W_ODT0_2X2 {on off}
	set_component_parameter_value MEM_DDR3_W_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR3_W_ODT0_4X4 {on off on off}
	set_component_parameter_value MEM_DDR3_W_ODT1_2X2 {off on}
	set_component_parameter_value MEM_DDR3_W_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR3_W_ODT1_4X4 {off on off on}
	set_component_parameter_value MEM_DDR3_W_ODT2_4X4 {on off on off}
	set_component_parameter_value MEM_DDR3_W_ODT3_4X4 {off on off on}
	set_component_parameter_value MEM_DDR3_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR3_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR3_W_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR3_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_AC_PARITY_LATENCY {DDR4_AC_PARITY_LATENCY_DISABLE}
	set_component_parameter_value MEM_DDR4_AC_PERSISTENT_ERROR {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_AC_LANE {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_AC_PIN {0}
	set_component_parameter_value MEM_DDR4_ALERT_N_DQS_GROUP {3}
	set_component_parameter_value MEM_DDR4_ALERT_N_PLACEMENT_ENUM {DDR4_ALERT_N_PLACEMENT_DATA_LANES}
	set_component_parameter_value MEM_DDR4_ALERT_PAR_EN {1}
	set_component_parameter_value MEM_DDR4_ASR_ENUM {DDR4_ASR_MANUAL_NORMAL}
	set_component_parameter_value MEM_DDR4_ATCL_ENUM {DDR4_ATCL_DISABLED}
	set_component_parameter_value MEM_DDR4_BANK_ADDR_WIDTH {2}
	set_component_parameter_value MEM_DDR4_BANK_GROUP_WIDTH {1}
	set_component_parameter_value MEM_DDR4_BL_ENUM {DDR4_BL_BL8}
	set_component_parameter_value MEM_DDR4_BT_ENUM {DDR4_BT_SEQUENTIAL}
	set_component_parameter_value MEM_DDR4_CAL_MODE {0}
	set_component_parameter_value MEM_DDR4_CFG_GEN_DBE {0}
	set_component_parameter_value MEM_DDR4_CFG_GEN_SBE {0}
	set_component_parameter_value MEM_DDR4_CHIP_ID_WIDTH {0}
	set_component_parameter_value MEM_DDR4_CKE_PER_DIMM {1}
	set_component_parameter_value MEM_DDR4_CK_WIDTH {1}
	set_component_parameter_value MEM_DDR4_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_DDR4_DB_DQ_DRV_ENUM {DDR4_DB_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDR4_DB_RTT_NOM_ENUM {DDR4_DB_RTT_NOM_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_DB_RTT_PARK_ENUM {DDR4_DB_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_DB_RTT_WR_ENUM {DDR4_DB_RTT_WR_RZQ_3}
	set_component_parameter_value MEM_DDR4_DEFAULT_VREFOUT {1}
	set_component_parameter_value MEM_DDR4_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_DDR4_DISCRETE_MIRROR_ADDRESSING_EN {0}
	set_component_parameter_value MEM_DDR4_DLL_EN {1}
	set_component_parameter_value MEM_DDR4_DM_EN {1}
	set_component_parameter_value MEM_DDR4_DQ_PER_DQS {8}
	set_component_parameter_value MEM_DDR4_DQ_WIDTH {32}
	set_component_parameter_value MEM_DDR4_DRV_STR_ENUM {DDR4_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDR4_FINE_GRANULARITY_REFRESH {DDR4_FINE_REFRESH_FIXED_1X}
	set_component_parameter_value MEM_DDR4_FORMAT_ENUM {MEM_FORMAT_UDIMM}
	set_component_parameter_value MEM_DDR4_GEARDOWN {DDR4_GEARDOWN_HR}
	set_component_parameter_value MEM_DDR4_HIDE_ADV_MR_SETTINGS {1}
	set_component_parameter_value MEM_DDR4_INTEL_DEFAULT_TERM {1}
	set_component_parameter_value MEM_DDR4_INTERNAL_VREFDQ_MONITOR {0}
	set_component_parameter_value MEM_DDR4_LRDIMM_ODT_LESS_BS {1}
	set_component_parameter_value MEM_DDR4_LRDIMM_ODT_LESS_BS_PARK_OHM {240}
	set_component_parameter_value MEM_DDR4_LRDIMM_VREFDQ_VALUE {}
	set_component_parameter_value MEM_DDR4_MAX_POWERDOWN {0}
	set_component_parameter_value MEM_DDR4_MIRROR_ADDRESSING_EN {1}
	set_component_parameter_value MEM_DDR4_MPR_READ_FORMAT {DDR4_MPR_READ_FORMAT_SERIAL}
	set_component_parameter_value MEM_DDR4_NUM_OF_DIMMS {1}
	set_component_parameter_value MEM_DDR4_ODT_IN_POWERDOWN {1}
	set_component_parameter_value MEM_DDR4_PER_DRAM_ADDR {0}
	set_component_parameter_value MEM_DDR4_RANKS_PER_DIMM {1}
	set_component_parameter_value MEM_DDR4_RCD_CA_IBT_ENUM {DDR4_RCD_CA_IBT_100}
	set_component_parameter_value MEM_DDR4_RCD_CKE_IBT_ENUM {DDR4_RCD_CKE_IBT_100}
	set_component_parameter_value MEM_DDR4_RCD_CS_IBT_ENUM {DDR4_RCD_CS_IBT_100}
	set_component_parameter_value MEM_DDR4_RCD_ODT_IBT_ENUM {DDR4_RCD_ODT_IBT_100}
	set_component_parameter_value MEM_DDR4_READ_DBI {1}
	set_component_parameter_value MEM_DDR4_READ_PREAMBLE {2}
	set_component_parameter_value MEM_DDR4_READ_PREAMBLE_TRAINING {0}
	set_component_parameter_value MEM_DDR4_ROW_ADDR_WIDTH {15}
	set_component_parameter_value MEM_DDR4_RTT_NOM_ENUM {DDR4_RTT_NOM_RZQ_6}
	set_component_parameter_value MEM_DDR4_RTT_PARK {DDR4_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_RTT_WR_ENUM {DDR4_RTT_WR_ODT_DISABLED}
	set_component_parameter_value MEM_DDR4_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_DDR4_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_DDR4_R_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR4_R_ODT0_4X4 {off off on off}
	set_component_parameter_value MEM_DDR4_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_DDR4_R_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR4_R_ODT1_4X4 {off off off on}
	set_component_parameter_value MEM_DDR4_R_ODT2_4X4 {on off off off}
	set_component_parameter_value MEM_DDR4_R_ODT3_4X4 {off on off off}
	set_component_parameter_value MEM_DDR4_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR4_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR4_R_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_SELF_RFSH_ABORT {0}
	set_component_parameter_value MEM_DDR4_SPD_133_RCD_DB_VENDOR_LSB {0}
	set_component_parameter_value MEM_DDR4_SPD_134_RCD_DB_VENDOR_MSB {0}
	set_component_parameter_value MEM_DDR4_SPD_135_RCD_REV {0}
	set_component_parameter_value MEM_DDR4_SPD_137_RCD_CA_DRV {101}
	set_component_parameter_value MEM_DDR4_SPD_138_RCD_CK_DRV {5}
	set_component_parameter_value MEM_DDR4_SPD_139_DB_REV {0}
	set_component_parameter_value MEM_DDR4_SPD_140_DRAM_VREFDQ_R0 {29}
	set_component_parameter_value MEM_DDR4_SPD_141_DRAM_VREFDQ_R1 {29}
	set_component_parameter_value MEM_DDR4_SPD_142_DRAM_VREFDQ_R2 {29}
	set_component_parameter_value MEM_DDR4_SPD_143_DRAM_VREFDQ_R3 {29}
	set_component_parameter_value MEM_DDR4_SPD_144_DB_VREFDQ {37}
	set_component_parameter_value MEM_DDR4_SPD_145_DB_MDQ_DRV {21}
	set_component_parameter_value MEM_DDR4_SPD_148_DRAM_DRV {0}
	set_component_parameter_value MEM_DDR4_SPD_149_DRAM_RTT_WR_NOM {20}
	set_component_parameter_value MEM_DDR4_SPD_152_DRAM_RTT_PARK {39}
	set_component_parameter_value MEM_DDR4_SPD_155_DB_VREFDQ_RANGE {0}
	set_component_parameter_value MEM_DDR4_SPEEDBIN_ENUM {DDR4_SPEEDBIN_2666}
	set_component_parameter_value MEM_DDR4_TCCD_L_CYC {6}
	set_component_parameter_value MEM_DDR4_TCCD_S_CYC {4}
	set_component_parameter_value MEM_DDR4_TCL {20}
	set_component_parameter_value MEM_DDR4_TDIVW_DJ_CYC {0.1}
	set_component_parameter_value MEM_DDR4_TDIVW_TOTAL_UI {0.22}
	set_component_parameter_value MEM_DDR4_TDQSCK_PS {170}
	set_component_parameter_value MEM_DDR4_TDQSQ_PS {66}
	set_component_parameter_value MEM_DDR4_TDQSQ_UI {0.18}
	set_component_parameter_value MEM_DDR4_TDQSS_CYC {0.27}
	set_component_parameter_value MEM_DDR4_TDSH_CYC {0.18}
	set_component_parameter_value MEM_DDR4_TDSS_CYC {0.18}
	set_component_parameter_value MEM_DDR4_TDVWP_UI {0.72}
	set_component_parameter_value MEM_DDR4_TEMP_CONTROLLED_RFSH_ENA {0}
	set_component_parameter_value MEM_DDR4_TEMP_CONTROLLED_RFSH_RANGE {DDR4_TEMP_CONTROLLED_RFSH_NORMAL}
	set_component_parameter_value MEM_DDR4_TEMP_SENSOR_READOUT {0}
	set_component_parameter_value MEM_DDR4_TFAW_DLR_CYC {16}
	set_component_parameter_value MEM_DDR4_TFAW_NS {30.0}
	set_component_parameter_value MEM_DDR4_TIH_DC_MV {65}
	set_component_parameter_value MEM_DDR4_TIH_PS {80}
	set_component_parameter_value MEM_DDR4_TINIT_US {500}
	set_component_parameter_value MEM_DDR4_TIS_AC_MV {90}
	set_component_parameter_value MEM_DDR4_TIS_PS {55}
	set_component_parameter_value MEM_DDR4_TMRD_CK_CYC {8}
	set_component_parameter_value MEM_DDR4_TQH_CYC {0.38}
	set_component_parameter_value MEM_DDR4_TQH_UI {0.74}
	set_component_parameter_value MEM_DDR4_TQSH_CYC {0.4}
	set_component_parameter_value MEM_DDR4_TRAS_NS {32.0}
	set_component_parameter_value MEM_DDR4_TRCD_NS {14.25}
	set_component_parameter_value MEM_DDR4_TREFI_US {7.8}
	set_component_parameter_value MEM_DDR4_TRFC_DLR_NS {90.0}
	set_component_parameter_value MEM_DDR4_TRFC_NS {350.0}
	set_component_parameter_value MEM_DDR4_TRP_NS {14.25}
	set_component_parameter_value MEM_DDR4_TRRD_DLR_CYC {4}
	set_component_parameter_value MEM_DDR4_TRRD_L_CYC {8}
	set_component_parameter_value MEM_DDR4_TRRD_S_CYC {7}
	set_component_parameter_value MEM_DDR4_TWLH_CYC {0.13}
	set_component_parameter_value MEM_DDR4_TWLH_PS {0.0}
	set_component_parameter_value MEM_DDR4_TWLS_CYC {0.13}
	set_component_parameter_value MEM_DDR4_TWLS_PS {0.0}
	set_component_parameter_value MEM_DDR4_TWR_NS {15.0}
	set_component_parameter_value MEM_DDR4_TWTR_L_CYC {9}
	set_component_parameter_value MEM_DDR4_TWTR_S_CYC {3}
	set_component_parameter_value MEM_DDR4_USER_VREFDQ_TRAINING_RANGE {DDR4_VREFDQ_TRAINING_RANGE_1}
	set_component_parameter_value MEM_DDR4_USER_VREFDQ_TRAINING_VALUE {56.0}
	set_component_parameter_value MEM_DDR4_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_DDR4_VDIVW_TOTAL {120}
	set_component_parameter_value MEM_DDR4_WRITE_CRC {0}
	set_component_parameter_value MEM_DDR4_WRITE_DBI {0}
	set_component_parameter_value MEM_DDR4_WRITE_PREAMBLE {1}
	set_component_parameter_value MEM_DDR4_WTCL {16}
	set_component_parameter_value MEM_DDR4_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_DDR4_W_ODT0_2X2 {on off}
	set_component_parameter_value MEM_DDR4_W_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDR4_W_ODT0_4X4 {on off on off}
	set_component_parameter_value MEM_DDR4_W_ODT1_2X2 {off on}
	set_component_parameter_value MEM_DDR4_W_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDR4_W_ODT1_4X4 {off on off on}
	set_component_parameter_value MEM_DDR4_W_ODT2_4X4 {on off on off}
	set_component_parameter_value MEM_DDR4_W_ODT3_4X4 {off on off on}
	set_component_parameter_value MEM_DDR4_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDR4_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDR4_W_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDR4_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_AC_PARITY_LATENCY {DDRT_AC_PARITY_LATENCY_DISABLE}
	set_component_parameter_value MEM_DDRT_AC_PERSISTENT_ERROR {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_AC_LANE {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_AC_PIN {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_DQS_GROUP {0}
	set_component_parameter_value MEM_DDRT_ALERT_N_PLACEMENT_ENUM {DDRT_ALERT_N_PLACEMENT_AUTO}
	set_component_parameter_value MEM_DDRT_ALERT_PAR_EN {1}
	set_component_parameter_value MEM_DDRT_ASR_ENUM {DDRT_ASR_MANUAL_NORMAL}
	set_component_parameter_value MEM_DDRT_ATCL_ENUM {DDRT_ATCL_DISABLED}
	set_component_parameter_value MEM_DDRT_BANK_ADDR_WIDTH {2}
	set_component_parameter_value MEM_DDRT_BANK_GROUP_WIDTH {2}
	set_component_parameter_value MEM_DDRT_BL_ENUM {DDRT_BL_BL8}
	set_component_parameter_value MEM_DDRT_BT_ENUM {DDRT_BT_SEQUENTIAL}
	set_component_parameter_value MEM_DDRT_CAL_MODE {0}
	set_component_parameter_value MEM_DDRT_CFG_GEN_DBE {0}
	set_component_parameter_value MEM_DDRT_CFG_GEN_SBE {0}
	set_component_parameter_value MEM_DDRT_CKE_PER_DIMM {1}
	set_component_parameter_value MEM_DDRT_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_DDRT_DB_DQ_DRV_ENUM {DDRT_DB_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDRT_DB_RTT_NOM_ENUM {DDRT_DB_RTT_NOM_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_DB_RTT_PARK_ENUM {DDRT_DB_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_DB_RTT_WR_ENUM {DDRT_DB_RTT_WR_RZQ_3}
	set_component_parameter_value MEM_DDRT_DEFAULT_ADDED_LATENCY {1}
	set_component_parameter_value MEM_DDRT_DEFAULT_PREAMBLE {1}
	set_component_parameter_value MEM_DDRT_DEFAULT_VREFOUT {1}
	set_component_parameter_value MEM_DDRT_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_DDRT_DISCRETE_MIRROR_ADDRESSING_EN {0}
	set_component_parameter_value MEM_DDRT_DLL_EN {1}
	set_component_parameter_value MEM_DDRT_DM_EN {0}
	set_component_parameter_value MEM_DDRT_DQ_PER_DQS {4}
	set_component_parameter_value MEM_DDRT_DQ_WIDTH {32}
	set_component_parameter_value MEM_DDRT_DRV_STR_ENUM {DDRT_DRV_STR_RZQ_7}
	set_component_parameter_value MEM_DDRT_FINE_GRANULARITY_REFRESH {DDRT_FINE_REFRESH_FIXED_1X}
	set_component_parameter_value MEM_DDRT_FORMAT_ENUM {MEM_FORMAT_LRDIMM}
	set_component_parameter_value MEM_DDRT_GEARDOWN {DDRT_GEARDOWN_HR}
	set_component_parameter_value MEM_DDRT_HIDE_ADV_MR_SETTINGS {1}
	set_component_parameter_value MEM_DDRT_HIDE_LATENCY_SETTINGS {1}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_0_SA {0}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_1_SA {1}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_2_SA {2}
	set_component_parameter_value MEM_DDRT_I2C_DIMM_3_SA {3}
	set_component_parameter_value MEM_DDRT_INTERNAL_VREFDQ_MONITOR {0}
	set_component_parameter_value MEM_DDRT_LRDIMM_ODT_LESS_BS {0}
	set_component_parameter_value MEM_DDRT_LRDIMM_ODT_LESS_BS_PARK_OHM {240}
	set_component_parameter_value MEM_DDRT_LRDIMM_VREFDQ_VALUE {}
	set_component_parameter_value MEM_DDRT_MAX_POWERDOWN {0}
	set_component_parameter_value MEM_DDRT_MIRROR_ADDRESSING_EN {1}
	set_component_parameter_value MEM_DDRT_MPR_READ_FORMAT {DDRT_MPR_READ_FORMAT_SERIAL}
	set_component_parameter_value MEM_DDRT_NUM_OF_DIMMS {1}
	set_component_parameter_value MEM_DDRT_ODT_IN_POWERDOWN {1}
	set_component_parameter_value MEM_DDRT_PARTIAL_WRITES {0}
	set_component_parameter_value MEM_DDRT_PERSISTENT_MODE {1}
	set_component_parameter_value MEM_DDRT_PER_DRAM_ADDR {0}
	set_component_parameter_value MEM_DDRT_PWR_MODE {DDRT_PWR_MODE_12W}
	set_component_parameter_value MEM_DDRT_RANKS_PER_DIMM {1}
	set_component_parameter_value MEM_DDRT_RCD_CA_IBT_ENUM {DDRT_RCD_CA_IBT_100}
	set_component_parameter_value MEM_DDRT_RCD_CKE_IBT_ENUM {DDRT_RCD_CKE_IBT_100}
	set_component_parameter_value MEM_DDRT_RCD_CS_IBT_ENUM {DDRT_RCD_CS_IBT_100}
	set_component_parameter_value MEM_DDRT_RCD_ODT_IBT_ENUM {DDRT_RCD_ODT_IBT_100}
	set_component_parameter_value MEM_DDRT_READ_DBI {0}
	set_component_parameter_value MEM_DDRT_READ_PREAMBLE_TRAINING {0}
	set_component_parameter_value MEM_DDRT_ROW_ADDR_WIDTH {18}
	set_component_parameter_value MEM_DDRT_RTT_NOM_ENUM {DDRT_RTT_NOM_RZQ_4}
	set_component_parameter_value MEM_DDRT_RTT_PARK {DDRT_RTT_PARK_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_RTT_WR_ENUM {DDRT_RTT_WR_ODT_DISABLED}
	set_component_parameter_value MEM_DDRT_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_DDRT_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_DDRT_R_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDRT_R_ODT0_4X4 {off off off off}
	set_component_parameter_value MEM_DDRT_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_DDRT_R_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDRT_R_ODT1_4X4 {off off on on}
	set_component_parameter_value MEM_DDRT_R_ODT2_4X4 {off off off off}
	set_component_parameter_value MEM_DDRT_R_ODT3_4X4 {on on off off}
	set_component_parameter_value MEM_DDRT_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDRT_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDRT_R_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_SELF_RFSH_ABORT {0}
	set_component_parameter_value MEM_DDRT_SPD_133_RCD_DB_VENDOR_LSB {0}
	set_component_parameter_value MEM_DDRT_SPD_134_RCD_DB_VENDOR_MSB {0}
	set_component_parameter_value MEM_DDRT_SPD_135_RCD_REV {0}
	set_component_parameter_value MEM_DDRT_SPD_137_RCD_CA_DRV {85}
	set_component_parameter_value MEM_DDRT_SPD_138_RCD_CK_DRV {5}
	set_component_parameter_value MEM_DDRT_SPD_139_DB_REV {0}
	set_component_parameter_value MEM_DDRT_SPD_140_DRAM_VREFDQ_R0 {29}
	set_component_parameter_value MEM_DDRT_SPD_141_DRAM_VREFDQ_R1 {29}
	set_component_parameter_value MEM_DDRT_SPD_142_DRAM_VREFDQ_R2 {29}
	set_component_parameter_value MEM_DDRT_SPD_143_DRAM_VREFDQ_R3 {29}
	set_component_parameter_value MEM_DDRT_SPD_144_DB_VREFDQ {37}
	set_component_parameter_value MEM_DDRT_SPD_145_DB_MDQ_DRV {21}
	set_component_parameter_value MEM_DDRT_SPD_148_DRAM_DRV {0}
	set_component_parameter_value MEM_DDRT_SPD_149_DRAM_RTT_WR_NOM {20}
	set_component_parameter_value MEM_DDRT_SPD_152_DRAM_RTT_PARK {39}
	set_component_parameter_value MEM_DDRT_SPEEDBIN_ENUM {DDRT_SPEEDBIN_2400}
	set_component_parameter_value MEM_DDRT_TCCD_L_CYC {6}
	set_component_parameter_value MEM_DDRT_TCCD_S_CYC {4}
	set_component_parameter_value MEM_DDRT_TCL {15}
	set_component_parameter_value MEM_DDRT_TDIVW_DJ_CYC {0.1}
	set_component_parameter_value MEM_DDRT_TDIVW_TOTAL_UI {0.2}
	set_component_parameter_value MEM_DDRT_TDQSCK_PS {165}
	set_component_parameter_value MEM_DDRT_TDQSQ_PS {66}
	set_component_parameter_value MEM_DDRT_TDQSQ_UI {0.16}
	set_component_parameter_value MEM_DDRT_TDQSS_CYC {0.27}
	set_component_parameter_value MEM_DDRT_TDSH_CYC {0.18}
	set_component_parameter_value MEM_DDRT_TDSS_CYC {0.18}
	set_component_parameter_value MEM_DDRT_TDVWP_UI {0.72}
	set_component_parameter_value MEM_DDRT_TEMP_CONTROLLED_RFSH_ENA {0}
	set_component_parameter_value MEM_DDRT_TEMP_CONTROLLED_RFSH_RANGE {DDRT_TEMP_CONTROLLED_RFSH_NORMAL}
	set_component_parameter_value MEM_DDRT_TEMP_SENSOR_READOUT {0}
	set_component_parameter_value MEM_DDRT_TFAW_DLR_CYC {16}
	set_component_parameter_value MEM_DDRT_TFAW_NS {21.0}
	set_component_parameter_value MEM_DDRT_TIH_DC_MV {75}
	set_component_parameter_value MEM_DDRT_TIH_PS {95}
	set_component_parameter_value MEM_DDRT_TINIT_US {500}
	set_component_parameter_value MEM_DDRT_TIS_AC_MV {100}
	set_component_parameter_value MEM_DDRT_TIS_PS {60}
	set_component_parameter_value MEM_DDRT_TMRD_CK_CYC {8}
	set_component_parameter_value MEM_DDRT_TQH_CYC {0.38}
	set_component_parameter_value MEM_DDRT_TQH_UI {0.76}
	set_component_parameter_value MEM_DDRT_TQSH_CYC {0.38}
	set_component_parameter_value MEM_DDRT_TRAS_NS {32.0}
	set_component_parameter_value MEM_DDRT_TRCD_NS {15.0}
	set_component_parameter_value MEM_DDRT_TREFI_US {7.8}
	set_component_parameter_value MEM_DDRT_TRFC_DLR_NS {90.0}
	set_component_parameter_value MEM_DDRT_TRFC_NS {260.0}
	set_component_parameter_value MEM_DDRT_TRP_NS {15.0}
	set_component_parameter_value MEM_DDRT_TRRD_DLR_CYC {4}
	set_component_parameter_value MEM_DDRT_TRRD_L_CYC {6}
	set_component_parameter_value MEM_DDRT_TRRD_S_CYC {4}
	set_component_parameter_value MEM_DDRT_TWLH_CYC {0.13}
	set_component_parameter_value MEM_DDRT_TWLH_PS {0.0}
	set_component_parameter_value MEM_DDRT_TWLS_CYC {0.13}
	set_component_parameter_value MEM_DDRT_TWLS_PS {0.0}
	set_component_parameter_value MEM_DDRT_TWR_NS {15.0}
	set_component_parameter_value MEM_DDRT_TWTR_L_CYC {9}
	set_component_parameter_value MEM_DDRT_TWTR_S_CYC {3}
	set_component_parameter_value MEM_DDRT_USER_READ_PREAMBLE {1}
	set_component_parameter_value MEM_DDRT_USER_TCL_ADDED {0}
	set_component_parameter_value MEM_DDRT_USER_VREFDQ_TRAINING_RANGE {DDRT_VREFDQ_TRAINING_RANGE_1}
	set_component_parameter_value MEM_DDRT_USER_VREFDQ_TRAINING_VALUE {56.0}
	set_component_parameter_value MEM_DDRT_USER_WRITE_PREAMBLE {1}
	set_component_parameter_value MEM_DDRT_USER_WTCL_ADDED {6}
	set_component_parameter_value MEM_DDRT_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_DDRT_VDIVW_TOTAL {136}
	set_component_parameter_value MEM_DDRT_WRITE_CRC {0}
	set_component_parameter_value MEM_DDRT_WRITE_DBI {0}
	set_component_parameter_value MEM_DDRT_WTCL {18}
	set_component_parameter_value MEM_DDRT_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_DDRT_W_ODT0_2X2 {on off}
	set_component_parameter_value MEM_DDRT_W_ODT0_4X2 {off off on on}
	set_component_parameter_value MEM_DDRT_W_ODT0_4X4 {on on off off}
	set_component_parameter_value MEM_DDRT_W_ODT1_2X2 {off on}
	set_component_parameter_value MEM_DDRT_W_ODT1_4X2 {on on off off}
	set_component_parameter_value MEM_DDRT_W_ODT1_4X4 {off off on on}
	set_component_parameter_value MEM_DDRT_W_ODT2_4X4 {off off on on}
	set_component_parameter_value MEM_DDRT_W_ODT3_4X4 {on on off off}
	set_component_parameter_value MEM_DDRT_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_DDRT_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_DDRT_W_ODTN_4X2 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_DDRT_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_LPDDR3_BANK_ADDR_WIDTH {3}
	set_component_parameter_value MEM_LPDDR3_BL {LPDDR3_BL_BL8}
	set_component_parameter_value MEM_LPDDR3_CK_WIDTH {1}
	set_component_parameter_value MEM_LPDDR3_COL_ADDR_WIDTH {10}
	set_component_parameter_value MEM_LPDDR3_DATA_LATENCY {LPDDR3_DL_RL12_WL6}
	set_component_parameter_value MEM_LPDDR3_DISCRETE_CS_WIDTH {1}
	set_component_parameter_value MEM_LPDDR3_DM_EN {1}
	set_component_parameter_value MEM_LPDDR3_DQODT {LPDDR3_DQODT_DISABLE}
	set_component_parameter_value MEM_LPDDR3_DQ_WIDTH {32}
	set_component_parameter_value MEM_LPDDR3_DRV_STR {LPDDR3_DRV_STR_40D_40U}
	set_component_parameter_value MEM_LPDDR3_PDODT {LPDDR3_PDODT_DISABLED}
	set_component_parameter_value MEM_LPDDR3_ROW_ADDR_WIDTH {15}
	set_component_parameter_value MEM_LPDDR3_R_ODT0_1X1 {off}
	set_component_parameter_value MEM_LPDDR3_R_ODT0_2X2 {off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT0_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT1_2X2 {off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT1_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT2_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODT3_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_R_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_LPDDR3_R_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_LPDDR3_R_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_LPDDR3_SPEEDBIN_ENUM {LPDDR3_SPEEDBIN_1600}
	set_component_parameter_value MEM_LPDDR3_TDH_DC_MV {100}
	set_component_parameter_value MEM_LPDDR3_TDH_PS {100}
	set_component_parameter_value MEM_LPDDR3_TDQSCKDL {614}
	set_component_parameter_value MEM_LPDDR3_TDQSQ_PS {135}
	set_component_parameter_value MEM_LPDDR3_TDQSS_CYC {1.25}
	set_component_parameter_value MEM_LPDDR3_TDSH_CYC {0.2}
	set_component_parameter_value MEM_LPDDR3_TDSS_CYC {0.2}
	set_component_parameter_value MEM_LPDDR3_TDS_AC_MV {150}
	set_component_parameter_value MEM_LPDDR3_TDS_PS {75}
	set_component_parameter_value MEM_LPDDR3_TFAW_NS {50.0}
	set_component_parameter_value MEM_LPDDR3_TIH_DC_MV {100}
	set_component_parameter_value MEM_LPDDR3_TIH_PS {100}
	set_component_parameter_value MEM_LPDDR3_TINIT_US {500}
	set_component_parameter_value MEM_LPDDR3_TIS_AC_MV {150}
	set_component_parameter_value MEM_LPDDR3_TIS_PS {75}
	set_component_parameter_value MEM_LPDDR3_TMRR_CK_CYC {4}
	set_component_parameter_value MEM_LPDDR3_TMRW_CK_CYC {10}
	set_component_parameter_value MEM_LPDDR3_TQH_CYC {0.38}
	set_component_parameter_value MEM_LPDDR3_TQSH_CYC {0.38}
	set_component_parameter_value MEM_LPDDR3_TRAS_NS {42.5}
	set_component_parameter_value MEM_LPDDR3_TRCD_NS {18.0}
	set_component_parameter_value MEM_LPDDR3_TREFI_US {3.9}
	set_component_parameter_value MEM_LPDDR3_TRFC_NS {210.0}
	set_component_parameter_value MEM_LPDDR3_TRP_NS {18.0}
	set_component_parameter_value MEM_LPDDR3_TRRD_CYC {8}
	set_component_parameter_value MEM_LPDDR3_TRTP_CYC {6}
	set_component_parameter_value MEM_LPDDR3_TWLH_PS {175.0}
	set_component_parameter_value MEM_LPDDR3_TWLS_PS {175.0}
	set_component_parameter_value MEM_LPDDR3_TWR_NS {15.0}
	set_component_parameter_value MEM_LPDDR3_TWTR_CYC {6}
	set_component_parameter_value MEM_LPDDR3_USE_DEFAULT_ODT {1}
	set_component_parameter_value MEM_LPDDR3_W_ODT0_1X1 {on}
	set_component_parameter_value MEM_LPDDR3_W_ODT0_2X2 {on on}
	set_component_parameter_value MEM_LPDDR3_W_ODT0_4X4 {on on on on}
	set_component_parameter_value MEM_LPDDR3_W_ODT1_2X2 {off off}
	set_component_parameter_value MEM_LPDDR3_W_ODT1_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_W_ODT2_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_W_ODT3_4X4 {off off off off}
	set_component_parameter_value MEM_LPDDR3_W_ODTN_1X1 {Rank\ 0}
	set_component_parameter_value MEM_LPDDR3_W_ODTN_2X2 {Rank\ 0 Rank\ 1}
	set_component_parameter_value MEM_LPDDR3_W_ODTN_4X4 {Rank\ 0 Rank\ 1 Rank\ 2 Rank\ 3}
	set_component_parameter_value MEM_QDR2_ADDR_WIDTH {19}
	set_component_parameter_value MEM_QDR2_BL {4}
	set_component_parameter_value MEM_QDR2_BWS_EN {1}
	set_component_parameter_value MEM_QDR2_DATA_PER_DEVICE {36}
	set_component_parameter_value MEM_QDR2_INTERNAL_JITTER_NS {0.08}
	set_component_parameter_value MEM_QDR2_SPEEDBIN_ENUM {QDR2_SPEEDBIN_633}
	set_component_parameter_value MEM_QDR2_TCCQO_NS {0.45}
	set_component_parameter_value MEM_QDR2_TCQDOH_NS {-0.09}
	set_component_parameter_value MEM_QDR2_TCQD_NS {0.09}
	set_component_parameter_value MEM_QDR2_TCQH_NS {0.71}
	set_component_parameter_value MEM_QDR2_THA_NS {0.18}
	set_component_parameter_value MEM_QDR2_THD_NS {0.18}
	set_component_parameter_value MEM_QDR2_TRL_CYC {2.5}
	set_component_parameter_value MEM_QDR2_TSA_NS {0.23}
	set_component_parameter_value MEM_QDR2_TSD_NS {0.23}
	set_component_parameter_value MEM_QDR2_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_QDR4_AC_ODT_MODE_ENUM {QDR4_ODT_25_PCT}
	set_component_parameter_value MEM_QDR4_ADDR_INV_ENA {0}
	set_component_parameter_value MEM_QDR4_ADDR_WIDTH {21}
	set_component_parameter_value MEM_QDR4_CK_ODT_MODE_ENUM {QDR4_ODT_25_PCT}
	set_component_parameter_value MEM_QDR4_DATA_INV_ENA {1}
	set_component_parameter_value MEM_QDR4_DATA_ODT_MODE_ENUM {QDR4_ODT_25_PCT}
	set_component_parameter_value MEM_QDR4_DQ_PER_PORT_PER_DEVICE {36}
	set_component_parameter_value MEM_QDR4_MEM_TYPE_ENUM {MEM_XP}
	set_component_parameter_value MEM_QDR4_PD_OUTPUT_DRIVE_MODE_ENUM {QDR4_OUTPUT_DRIVE_25_PCT}
	set_component_parameter_value MEM_QDR4_PU_OUTPUT_DRIVE_MODE_ENUM {QDR4_OUTPUT_DRIVE_25_PCT}
	set_component_parameter_value MEM_QDR4_SKIP_ODT_SWEEPING {1}
	set_component_parameter_value MEM_QDR4_SPEEDBIN_ENUM {QDR4_SPEEDBIN_2133}
	set_component_parameter_value MEM_QDR4_TASH_PS {170}
	set_component_parameter_value MEM_QDR4_TCKDK_MAX_PS {150}
	set_component_parameter_value MEM_QDR4_TCKDK_MIN_PS {-150}
	set_component_parameter_value MEM_QDR4_TCKQK_MAX_PS {225}
	set_component_parameter_value MEM_QDR4_TCSH_PS {170}
	set_component_parameter_value MEM_QDR4_TISH_PS {150}
	set_component_parameter_value MEM_QDR4_TQH_CYC {0.4}
	set_component_parameter_value MEM_QDR4_TQKQ_MAX_PS {75}
	set_component_parameter_value MEM_QDR4_USE_ADDR_PARITY {0}
	set_component_parameter_value MEM_QDR4_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD2_ADDR_WIDTH {21}
	set_component_parameter_value MEM_RLD2_BANK_ADDR_WIDTH {3}
	set_component_parameter_value MEM_RLD2_BL {4}
	set_component_parameter_value MEM_RLD2_CONFIG_ENUM {RLD2_CONFIG_TRC_8_TRL_8_TWL_9}
	set_component_parameter_value MEM_RLD2_DM_EN {1}
	set_component_parameter_value MEM_RLD2_DQ_PER_DEVICE {9}
	set_component_parameter_value MEM_RLD2_DRIVE_IMPEDENCE_ENUM {RLD2_DRIVE_IMPEDENCE_INTERNAL_50}
	set_component_parameter_value MEM_RLD2_ODT_MODE_ENUM {RLD2_ODT_ON}
	set_component_parameter_value MEM_RLD2_REFRESH_INTERVAL_US {0.24}
	set_component_parameter_value MEM_RLD2_SPEEDBIN_ENUM {RLD2_SPEEDBIN_18}
	set_component_parameter_value MEM_RLD2_TAH_NS {0.3}
	set_component_parameter_value MEM_RLD2_TAS_NS {0.3}
	set_component_parameter_value MEM_RLD2_TCKDK_MAX_NS {0.3}
	set_component_parameter_value MEM_RLD2_TCKDK_MIN_NS {-0.3}
	set_component_parameter_value MEM_RLD2_TCKH_CYC {0.45}
	set_component_parameter_value MEM_RLD2_TCKQK_MAX_NS {0.2}
	set_component_parameter_value MEM_RLD2_TDH_NS {0.17}
	set_component_parameter_value MEM_RLD2_TDS_NS {0.17}
	set_component_parameter_value MEM_RLD2_TQKH_HCYC {0.9}
	set_component_parameter_value MEM_RLD2_TQKQ_MAX_NS {0.12}
	set_component_parameter_value MEM_RLD2_TQKQ_MIN_NS {-0.12}
	set_component_parameter_value MEM_RLD2_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD3_ADDR_WIDTH {20}
	set_component_parameter_value MEM_RLD3_AREF_PROTOCOL_ENUM {RLD3_AREF_BAC}
	set_component_parameter_value MEM_RLD3_BANK_ADDR_WIDTH {4}
	set_component_parameter_value MEM_RLD3_BL {2}
	set_component_parameter_value MEM_RLD3_DATA_LATENCY_MODE_ENUM {RLD3_DL_RL16_WL17}
	set_component_parameter_value MEM_RLD3_DEPTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD3_DM_EN {1}
	set_component_parameter_value MEM_RLD3_DQ_PER_DEVICE {36}
	set_component_parameter_value MEM_RLD3_ODT_MODE_ENUM {RLD3_ODT_40}
	set_component_parameter_value MEM_RLD3_OUTPUT_DRIVE_MODE_ENUM {RLD3_OUTPUT_DRIVE_40}
	set_component_parameter_value MEM_RLD3_SPEEDBIN_ENUM {RLD3_SPEEDBIN_093E}
	set_component_parameter_value MEM_RLD3_TCKDK_MAX_CYC {0.27}
	set_component_parameter_value MEM_RLD3_TCKDK_MIN_CYC {-0.27}
	set_component_parameter_value MEM_RLD3_TCKQK_MAX_PS {135}
	set_component_parameter_value MEM_RLD3_TDH_DC_MV {100}
	set_component_parameter_value MEM_RLD3_TDH_PS {5}
	set_component_parameter_value MEM_RLD3_TDS_AC_MV {150}
	set_component_parameter_value MEM_RLD3_TDS_PS {-30}
	set_component_parameter_value MEM_RLD3_TIH_DC_MV {100}
	set_component_parameter_value MEM_RLD3_TIH_PS {65}
	set_component_parameter_value MEM_RLD3_TIS_AC_MV {150}
	set_component_parameter_value MEM_RLD3_TIS_PS {85}
	set_component_parameter_value MEM_RLD3_TQH_CYC {0.38}
	set_component_parameter_value MEM_RLD3_TQKQ_MAX_PS {75}
	set_component_parameter_value MEM_RLD3_T_RC_MODE_ENUM {RLD3_TRC_9}
	set_component_parameter_value MEM_RLD3_WIDTH_EXPANDED {0}
	set_component_parameter_value MEM_RLD3_WRITE_PROTOCOL_ENUM {RLD3_WRITE_1BANK}
	set_component_parameter_value NUM_IPS {1}
	set_component_parameter_value PHY_DDR3_CAL_ADDR0 {0}
	set_component_parameter_value PHY_DDR3_CAL_ADDR1 {8}
	set_component_parameter_value PHY_DDR3_CAL_ENABLE_NON_DES {0}
	set_component_parameter_value PHY_DDR3_CONFIG_ENUM {CONFIG_PHY_AND_HARD_CTRL}
	set_component_parameter_value PHY_DDR3_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_DDR3_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_DDR3_DEFAULT_IO {1}
	set_component_parameter_value PHY_DDR3_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_DDR3_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_DDR3_IO_VOLTAGE {1.5}
	set_component_parameter_value PHY_DDR3_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_DDR3_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_DDR3_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_DDR3_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_DDR3_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR3_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_DDR3_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR3_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_DDR3_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_DDR3_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_DDR3_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_DDR3_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDR3_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_DDR4_ALLOW_72_DQ_WIDTH {0}
	set_component_parameter_value PHY_DDR4_CONFIG_ENUM {CONFIG_PHY_AND_HARD_CTRL}
	set_component_parameter_value PHY_DDR4_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_DDR4_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_DDR4_DEFAULT_IO {0}
	set_component_parameter_value PHY_DDR4_DEFAULT_REF_CLK_FREQ {0}
	set_component_parameter_value PHY_DDR4_HPS_ENABLE_EARLY_RELEASE {1}
	set_component_parameter_value PHY_DDR4_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_DDR4_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_DDR4_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_DDR4_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_DDR4_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_DDR4_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_AC_IO_STD_ENUM {IO_STD_SSTL_12}
	set_component_parameter_value PHY_DDR4_USER_AC_MODE_ENUM {OUT_OCT_40_CAL}
	set_component_parameter_value PHY_DDR4_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR4_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_DDR4_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_CK_IO_STD_ENUM {IO_STD_SSTL_12}
	set_component_parameter_value PHY_DDR4_USER_CK_MODE_ENUM {OUT_OCT_40_CAL}
	set_component_parameter_value PHY_DDR4_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDR4_USER_CLAMSHELL_EN {0}
	set_component_parameter_value PHY_DDR4_USER_DATA_IN_MODE_ENUM {IN_OCT_60_CAL}
	set_component_parameter_value PHY_DDR4_USER_DATA_IO_STD_ENUM {IO_STD_POD_12}
	set_component_parameter_value PHY_DDR4_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_DATA_OUT_MODE_ENUM {OUT_OCT_34_CAL}
	set_component_parameter_value PHY_DDR4_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_DDR4_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_DDR4_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_DDR4_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_DDR4_USER_PLL_REF_CLK_IO_STD_ENUM {IO_STD_LVDS}
	set_component_parameter_value PHY_DDR4_USER_REF_CLK_FREQ_MHZ {133.333}
	set_component_parameter_value PHY_DDR4_USER_RZQ_IO_STD_ENUM {IO_STD_CMOS_12}
	set_component_parameter_value PHY_DDR4_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_DDRT_2CH_EN {0}
	set_component_parameter_value PHY_DDRT_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_DDRT_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_DDRT_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_DDRT_DEFAULT_IO {1}
	set_component_parameter_value PHY_DDRT_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_DDRT_EXPORT_CLK_STP_IF {0}
	set_component_parameter_value PHY_DDRT_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_DDRT_I2C_USE_SMC {0}
	set_component_parameter_value PHY_DDRT_IC_EN {1}
	set_component_parameter_value PHY_DDRT_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_DDRT_MEM_CLK_FREQ_MHZ {1200.0}
	set_component_parameter_value PHY_DDRT_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_DDRT_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_DDRT_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_DDRT_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDRT_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_DDRT_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_DDRT_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_DDRT_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_DDRT_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_DDRT_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_DDRT_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_DDRT_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_DDRT_USE_OLD_SMBUS_MULTICOL {0}
	set_component_parameter_value PHY_LPDDR3_CONFIG_ENUM {CONFIG_PHY_AND_HARD_CTRL}
	set_component_parameter_value PHY_LPDDR3_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_LPDDR3_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_LPDDR3_DEFAULT_IO {1}
	set_component_parameter_value PHY_LPDDR3_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_LPDDR3_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_LPDDR3_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_LPDDR3_MEM_CLK_FREQ_MHZ {800.0}
	set_component_parameter_value PHY_LPDDR3_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_LPDDR3_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_LPDDR3_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_LPDDR3_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_LPDDR3_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_LPDDR3_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_LPDDR3_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_LPDDR3_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_LPDDR3_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_LPDDR3_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_LPDDR3_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_QDR2_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_QDR2_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_QDR2_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_QDR2_DEFAULT_IO {1}
	set_component_parameter_value PHY_QDR2_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_QDR2_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_QDR2_IO_VOLTAGE {1.5}
	set_component_parameter_value PHY_QDR2_MEM_CLK_FREQ_MHZ {633.333}
	set_component_parameter_value PHY_QDR2_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_QDR2_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_QDR2_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_QDR2_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR2_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_QDR2_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR2_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_QDR2_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_QDR2_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_QDR2_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_QDR2_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR2_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_QDR4_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_QDR4_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_QDR4_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_QDR4_DEFAULT_IO {1}
	set_component_parameter_value PHY_QDR4_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_QDR4_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_QDR4_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_QDR4_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_QDR4_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_QDR4_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_QDR4_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_QDR4_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR4_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_QDR4_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_QDR4_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_QDR4_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_QDR4_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_QDR4_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_QDR4_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_QDR4_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_RLD2_CONFIG_ENUM {CONFIG_PHY_AND_SOFT_CTRL}
	set_component_parameter_value PHY_RLD2_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_RLD2_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_RLD2_DEFAULT_IO {1}
	set_component_parameter_value PHY_RLD2_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_RLD2_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_RLD2_IO_VOLTAGE {1.8}
	set_component_parameter_value PHY_RLD2_MEM_CLK_FREQ_MHZ {533.333}
	set_component_parameter_value PHY_RLD2_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_RLD2_RATE_ENUM {RATE_HALF}
	set_component_parameter_value PHY_RLD2_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_RLD2_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD2_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_RLD2_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD2_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_RLD2_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_RLD2_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_RLD2_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_RLD2_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD2_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PHY_RLD3_CONFIG_ENUM {CONFIG_PHY_ONLY}
	set_component_parameter_value PHY_RLD3_CORE_CLKS_SHARING_ENUM {CORE_CLKS_SHARING_DISABLED}
	set_component_parameter_value PHY_RLD3_CORE_CLKS_SHARING_EXPOSE_SLAVE_OUT {0}
	set_component_parameter_value PHY_RLD3_DEFAULT_IO {1}
	set_component_parameter_value PHY_RLD3_DEFAULT_REF_CLK_FREQ {1}
	set_component_parameter_value PHY_RLD3_HPS_ENABLE_EARLY_RELEASE {0}
	set_component_parameter_value PHY_RLD3_IO_VOLTAGE {1.2}
	set_component_parameter_value PHY_RLD3_MEM_CLK_FREQ_MHZ {1066.667}
	set_component_parameter_value PHY_RLD3_MIMIC_HPS_EMIF {0}
	set_component_parameter_value PHY_RLD3_RATE_ENUM {RATE_QUARTER}
	set_component_parameter_value PHY_RLD3_REF_CLK_JITTER_PS {10.0}
	set_component_parameter_value PHY_RLD3_USER_AC_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_AC_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_AC_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_AC_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD3_USER_AUTO_STARTING_VREFIN_EN {1}
	set_component_parameter_value PHY_RLD3_USER_CK_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_CK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_CK_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_CK_SLEW_RATE_ENUM {SLEW_RATE_FAST}
	set_component_parameter_value PHY_RLD3_USER_DATA_IN_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_OUT_DEEMPHASIS_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_OUT_MODE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DATA_OUT_SLEW_RATE_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_DLL_CORE_UPDN_EN {0}
	set_component_parameter_value PHY_RLD3_USER_PERIODIC_OCT_RECAL_ENUM {PERIODIC_OCT_RECAL_AUTO}
	set_component_parameter_value PHY_RLD3_USER_PING_PONG_EN {0}
	set_component_parameter_value PHY_RLD3_USER_PLL_REF_CLK_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_REF_CLK_FREQ_MHZ {-1.0}
	set_component_parameter_value PHY_RLD3_USER_RZQ_IO_STD_ENUM {unset}
	set_component_parameter_value PHY_RLD3_USER_STARTING_VREFIN {70.0}
	set_component_parameter_value PLL_ADD_EXTRA_CLKS {0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_0 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_1 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_2 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_3 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_4 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_5 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_6 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_7 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_8 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_0 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_1 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_2 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_3 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_4 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_5 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_6 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_7 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_DUTY_CYCLE_GUI_8 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_FREQ_MHZ_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_DEG_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_ACTUAL_PHASE_PS_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_0 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_1 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_2 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_3 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_4 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_5 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_6 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_7 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_DUTY_CYCLE_GUI_8 {50.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_FREQ_MHZ_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_0 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_1 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_2 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_3 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_4 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_5 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_6 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_7 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_DESIRED_PHASE_GUI_8 {0.0}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_0 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_1 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_2 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_3 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_4 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_5 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_6 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_7 {ps}
	set_component_parameter_value PLL_EXTRA_CLK_PHASE_SHIFT_UNIT_GUI_8 {ps}
	set_component_parameter_value PLL_USER_NUM_OF_EXTRA_CLKS {0}
	set_component_parameter_value PROTOCOL_ENUM {PROTOCOL_DDR4}
	set_component_parameter_value SHORT_QSYS_INTERFACE_NAMES {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation emif_a10_hps
	remove_instantiation_interfaces_and_ports
	add_instantiation_interface global_reset_reset_sink reset INPUT
	set_instantiation_interface_parameter_value global_reset_reset_sink associatedClock {}
	set_instantiation_interface_parameter_value global_reset_reset_sink synchronousEdges {NONE}
	add_instantiation_interface_port global_reset_reset_sink global_reset_n reset_n 1 STD_LOGIC Input
	add_instantiation_interface pll_ref_clk_clock_sink clock INPUT
	set_instantiation_interface_parameter_value pll_ref_clk_clock_sink clockRate {0}
	set_instantiation_interface_parameter_value pll_ref_clk_clock_sink externallyDriven {false}
	set_instantiation_interface_parameter_value pll_ref_clk_clock_sink ptfSchematicName {}
	add_instantiation_interface_port pll_ref_clk_clock_sink pll_ref_clk clk 1 STD_LOGIC Input
	add_instantiation_interface oct_conduit_end conduit INPUT
	set_instantiation_interface_parameter_value oct_conduit_end associatedClock {}
	set_instantiation_interface_parameter_value oct_conduit_end associatedReset {}
	set_instantiation_interface_parameter_value oct_conduit_end prSafe {false}
	add_instantiation_interface_port oct_conduit_end oct_rzqin oct_rzqin 1 STD_LOGIC Input
	add_instantiation_interface mem_conduit_end conduit INPUT
	set_instantiation_interface_parameter_value mem_conduit_end associatedClock {}
	set_instantiation_interface_parameter_value mem_conduit_end associatedReset {}
	set_instantiation_interface_parameter_value mem_conduit_end prSafe {false}
	add_instantiation_interface_port mem_conduit_end mem_ck mem_ck 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_ck_n mem_ck_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_a mem_a 17 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_act_n mem_act_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_ba mem_ba 2 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_bg mem_bg 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_cke mem_cke 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_cs_n mem_cs_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_odt mem_odt 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_reset_n mem_reset_n 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_par mem_par 1 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mem_conduit_end mem_alert_n mem_alert_n 1 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mem_conduit_end mem_dqs mem_dqs 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_conduit_end mem_dqs_n mem_dqs_n 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_conduit_end mem_dq mem_dq 32 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface_port mem_conduit_end mem_dbi_n mem_dbi_n 4 STD_LOGIC_VECTOR Bidir
	add_instantiation_interface hps_emif_conduit_end conduit INPUT
	set_instantiation_interface_parameter_value hps_emif_conduit_end associatedClock {}
	set_instantiation_interface_parameter_value hps_emif_conduit_end associatedReset {}
	set_instantiation_interface_parameter_value hps_emif_conduit_end prSafe {false}
	add_instantiation_interface_port hps_emif_conduit_end hps_to_emif hps_to_emif 4096 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps_emif_conduit_end emif_to_hps emif_to_hps 4096 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port hps_emif_conduit_end hps_to_emif_gp gp_to_emif 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port hps_emif_conduit_end emif_to_hps_gp emif_to_gp 1 STD_LOGIC_VECTOR Output
	save_instantiation
	add_component hps_a10_csr_bridge_0 ip/hps/hps_csr_bridge_0.ip altera_avalon_mm_bridge msg_bridge_1
	load_component hps_a10_csr_bridge_0
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
	load_instantiation hps_a10_csr_bridge_0
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
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
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
	add_component hps_a10_msgdma_0 ip/hps/hps_msgdma_0.ip altera_msgdma msgdma_0
	load_component hps_a10_msgdma_0
	set_component_parameter_value BURST_ENABLE {0}
	set_component_parameter_value BURST_WRAPPING_SUPPORT {0}
	set_component_parameter_value CHANNEL_ENABLE {0}
	set_component_parameter_value CHANNEL_WIDTH {8}
	set_component_parameter_value DATA_FIFO_DEPTH {32}
	set_component_parameter_value DATA_WIDTH {32}
	set_component_parameter_value DESCRIPTOR_FIFO_DEPTH {128}
	set_component_parameter_value ENHANCED_FEATURES {1}
	set_component_parameter_value ERROR_ENABLE {0}
	set_component_parameter_value ERROR_WIDTH {8}
	set_component_parameter_value EXPOSE_ST_PORT {0}
	set_component_parameter_value FIX_ADDRESS_WIDTH {32}
	set_component_parameter_value MAX_BURST_COUNT {2}
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
	set_component_parameter_value STRIDE_ENABLE {0}
	set_component_parameter_value TRANSFER_TYPE {Aligned Accesses}
	set_component_parameter_value USE_FIX_ADDRESS_WIDTH {0}
	set_component_parameter_value WRITE_RESPONSE_ENABLE {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation hps_a10_msgdma_0
	remove_instantiation_interfaces_and_ports
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.BURST_WRAPPING_SUPPORT {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.CHANNEL_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_FIFO_DEPTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.DATA_WIDTH {32}
	set_instantiation_assignment_value embeddedsw.CMacro.DESCRIPTOR_FIFO_DEPTH {128}
	set_instantiation_assignment_value embeddedsw.CMacro.DMA_MODE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ENHANCED_FEATURES {1}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.ERROR_WIDTH {8}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BURST_COUNT {2}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_BYTE {2147483647}
	set_instantiation_assignment_value embeddedsw.CMacro.MAX_STRIDE {1}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PACKET_ENABLE_DERIVED {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PREFETCHER_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.PROGRAMMABLE_BURST_ENABLE {0}
	set_instantiation_assignment_value embeddedsw.CMacro.RESPONSE_PORT {2}
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
	set_instantiation_interface_parameter_value mm_read prSafe {false}
	set_instantiation_interface_parameter_value mm_read readLatency {0}
	set_instantiation_interface_parameter_value mm_read readWaitTime {1}
	set_instantiation_interface_parameter_value mm_read registerIncomingSignals {false}
	set_instantiation_interface_parameter_value mm_read registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value mm_read setupTime {0}
	set_instantiation_interface_parameter_value mm_read timingUnits {Cycles}
	set_instantiation_interface_parameter_value mm_read waitrequestAllowance {0}
	set_instantiation_interface_parameter_value mm_read writeWaitTime {0}
	add_instantiation_interface_port mm_read mm_read_address address 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_read read 1 STD_LOGIC Output
	add_instantiation_interface_port mm_read mm_read_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_read mm_read_readdata readdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mm_read mm_read_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_read mm_read_readdatavalid readdatavalid 1 STD_LOGIC Input
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
	set_instantiation_interface_parameter_value mm_write prSafe {false}
	set_instantiation_interface_parameter_value mm_write readLatency {0}
	set_instantiation_interface_parameter_value mm_write readWaitTime {1}
	set_instantiation_interface_parameter_value mm_write registerIncomingSignals {false}
	set_instantiation_interface_parameter_value mm_write registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value mm_write setupTime {0}
	set_instantiation_interface_parameter_value mm_write timingUnits {Cycles}
	set_instantiation_interface_parameter_value mm_write waitrequestAllowance {0}
	set_instantiation_interface_parameter_value mm_write writeWaitTime {0}
	add_instantiation_interface_port mm_write mm_write_address address 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_write write 1 STD_LOGIC Output
	add_instantiation_interface_port mm_write mm_write_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port mm_write mm_write_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port mm_write mm_write_response response 2 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port mm_write mm_write_writeresponsevalid writeresponsevalid 1 STD_LOGIC Input
	save_instantiation
	add_component hps_csr_clk_0 ip/hps/hps_csr_clk_0.ip altera_clock_bridge hps_axi_clk_bridge
	load_component hps_csr_clk_0
	set_component_parameter_value EXPLICIT_CLOCK_RATE {0.0}
	set_component_parameter_value NUM_CLOCK_OUTPUTS {1}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation hps_csr_clk_0
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
	add_component hps_csr_rst_0 ip/hps/hps_csr_rst_0.ip altera_reset_bridge hps_axi_rst_bridge
	load_component hps_csr_rst_0
	set_component_parameter_value ACTIVE_LOW_RESET {0}
	set_component_parameter_value NUM_RESET_OUTPUTS {1}
	set_component_parameter_value SYNCHRONOUS_EDGES {deassert}
	set_component_parameter_value SYNC_RESET {0}
	set_component_parameter_value USE_RESET_REQUEST {0}
	set_component_project_property HIDE_FROM_IP_CATALOG {false}
	save_component
	load_instantiation hps_csr_rst_0
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
	add_component hps_dma_bridge_0 ip/hps/hps_dma_bridge_0.ip altera_avalon_mm_bridge mm_bridge_0
	load_component hps_dma_bridge_0
	set_component_parameter_value ADDRESS_UNITS {SYMBOLS}
	set_component_parameter_value ADDRESS_WIDTH {31}
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
	load_instantiation hps_dma_bridge_0
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
	set_instantiation_interface_parameter_value s0 addressSpan {2147483648}
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
	add_instantiation_interface_port s0 s0_address address 31 STD_LOGIC_VECTOR Input
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
	set_instantiation_interface_parameter_value m0 prSafe {false}
	set_instantiation_interface_parameter_value m0 readLatency {0}
	set_instantiation_interface_parameter_value m0 readWaitTime {1}
	set_instantiation_interface_parameter_value m0 registerIncomingSignals {false}
	set_instantiation_interface_parameter_value m0 registerOutgoingSignals {false}
	set_instantiation_interface_parameter_value m0 setupTime {0}
	set_instantiation_interface_parameter_value m0 timingUnits {Cycles}
	set_instantiation_interface_parameter_value m0 waitrequestAllowance {0}
	set_instantiation_interface_parameter_value m0 writeWaitTime {0}
	add_instantiation_interface_port m0 m0_waitrequest waitrequest 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_readdata readdata 32 STD_LOGIC_VECTOR Input
	add_instantiation_interface_port m0 m0_readdatavalid readdatavalid 1 STD_LOGIC Input
	add_instantiation_interface_port m0 m0_burstcount burstcount 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_writedata writedata 32 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_address address 31 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_write write 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_read read 1 STD_LOGIC Output
	add_instantiation_interface_port m0 m0_byteenable byteenable 4 STD_LOGIC_VECTOR Output
	add_instantiation_interface_port m0 m0_debugaccess debugaccess 1 STD_LOGIC Output
	save_instantiation

	# add wirelevel expressions

	# preserve ports for debug

	# add the connections
	add_connection a10_hps.f2h_irq0/hps_a10_msgdma_0.csr_irq
	set_connection_parameter_value a10_hps.f2h_irq0/hps_a10_msgdma_0.csr_irq interruptsUsedSysInfo {-1}
	set_connection_parameter_value a10_hps.f2h_irq0/hps_a10_msgdma_0.csr_irq irqNumber {0}
	add_connection a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 addressMapSysInfo {<address-map><slave name='hps_a10_msgdma_0.csr' start='0x0' end='0x20' datawidth='32' /><slave name='hps_a10_msgdma_0.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='hps_a10_csr_bridge_0.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 addressWidthSysInfo {17}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 baseAddress {0x00010000}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 domainAlias {}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_csr_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr addressMapSysInfo {<address-map><slave name='hps_a10_msgdma_0.csr' start='0x0' end='0x20' datawidth='32' /><slave name='hps_a10_msgdma_0.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='hps_a10_csr_bridge_0.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr addressWidthSysInfo {17}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr arbitrationPriority {1}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr baseAddress {0x0000}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr defaultConnection {0}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr domainAlias {}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.syncResets {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.csr slaveDataWidthSysInfo {-1}
	add_connection a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave addressMapSysInfo {<address-map><slave name='hps_a10_msgdma_0.csr' start='0x0' end='0x20' datawidth='32' /><slave name='hps_a10_msgdma_0.descriptor_slave' start='0x20' end='0x40' datawidth='256' /><slave name='hps_a10_csr_bridge_0.s0' start='0x10000' end='0x20000' datawidth='32' /></address-map>}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave addressWidthSysInfo {17}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave arbitrationPriority {1}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave baseAddress {0x0020}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave defaultConnection {0}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave domainAlias {}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.syncResets {FALSE}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value a10_hps.h2f_lw_axi_master/hps_a10_msgdma_0.descriptor_slave slaveDataWidthSysInfo {-1}
	add_connection emif_a10_hps.hps_emif_conduit_end/a10_hps.emif
	set_connection_parameter_value emif_a10_hps.hps_emif_conduit_end/a10_hps.emif endPort {}
	set_connection_parameter_value emif_a10_hps.hps_emif_conduit_end/a10_hps.emif endPortLSB {0}
	set_connection_parameter_value emif_a10_hps.hps_emif_conduit_end/a10_hps.emif startPort {}
	set_connection_parameter_value emif_a10_hps.hps_emif_conduit_end/a10_hps.emif startPortLSB {0}
	set_connection_parameter_value emif_a10_hps.hps_emif_conduit_end/a10_hps.emif width {0}
	add_connection hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data addressMapSysInfo {<address-map><slave name='a10_hps/bridges.f2sdram1_data' start='0x0' end='0x40000000' datawidth='64' /><slave name='hps_dma_bridge_0.s0' start='0x80000000' end='0x100000000' datawidth='32' /></address-map>}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data addressWidthSysInfo {32}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data arbitrationPriority {1}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data baseAddress {0x0000}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data defaultConnection {0}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data domainAlias {}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/a10_hps.f2sdram1_data slaveDataWidthSysInfo {-1}
	add_connection hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 addressMapSysInfo {<address-map><slave name='a10_hps/bridges.f2sdram1_data' start='0x0' end='0x40000000' datawidth='64' /><slave name='hps_dma_bridge_0.s0' start='0x80000000' end='0x100000000' datawidth='32' /></address-map>}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 addressWidthSysInfo {32}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 baseAddress {0x80000000}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 domainAlias {}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_read/hps_dma_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data addressMapSysInfo {<address-map><slave name='a10_hps/bridges.f2sdram1_data' start='0x0' end='0x40000000' datawidth='64' /><slave name='hps_dma_bridge_0.s0' start='0x80000000' end='0x100000000' datawidth='32' /></address-map>}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data addressWidthSysInfo {32}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data arbitrationPriority {1}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data baseAddress {0x0000}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data defaultConnection {0}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data domainAlias {}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/a10_hps.f2sdram1_data slaveDataWidthSysInfo {-1}
	add_connection hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 addressMapSysInfo {<address-map><slave name='a10_hps/bridges.f2sdram1_data' start='0x0' end='0x40000000' datawidth='64' /><slave name='hps_dma_bridge_0.s0' start='0x80000000' end='0x100000000' datawidth='32' /></address-map>}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 addressWidthSysInfo {32}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 arbitrationPriority {1}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 baseAddress {0x80000000}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 defaultConnection {0}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 domainAlias {}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.burstAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.clockCrossingAdapter {HANDSHAKE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.enableAllPipelines {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.enableEccProtection {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.enableInstrumentation {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.enableOutOfOrderSupport {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.insertDefaultSlave {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.interconnectResetSource {DEFAULT}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.interconnectType {STANDARD}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.maxAdditionalLatency {3}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.optimizeRdFifoSize {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.piplineType {PIPELINE_STAGE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.responseFifoType {REGISTER_BASED}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.syncResets {FALSE}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 qsys_mm.widthAdapterImplementation {GENERIC_CONVERTER}
	set_connection_parameter_value hps_a10_msgdma_0.mm_write/hps_dma_bridge_0.s0 slaveDataWidthSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/a10_hps.f2sdram0_clock
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram0_clock clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram0_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram0_clock clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram0_clock resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/a10_hps.f2sdram1_clock
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram1_clock clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram1_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram1_clock clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.f2sdram1_clock resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/a10_hps.h2f_axi_clock
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_axi_clock clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_axi_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_axi_clock clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_axi_clock resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/a10_hps.h2f_lw_axi_clock
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_lw_axi_clock clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_lw_axi_clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_lw_axi_clock clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/a10_hps.h2f_lw_axi_clock resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/hps_a10_csr_bridge_0.clk
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_csr_bridge_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_csr_bridge_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_csr_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_csr_bridge_0.clk resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/hps_a10_msgdma_0.clock
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_msgdma_0.clock clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_msgdma_0.clock clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_msgdma_0.clock clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_a10_msgdma_0.clock resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/hps_csr_rst_0.clk
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_csr_rst_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_csr_rst_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_csr_rst_0.clk clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_csr_rst_0.clk resetDomainSysInfo {-1}
	add_connection hps_csr_clk_0.out_clk/hps_dma_bridge_0.clk
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_dma_bridge_0.clk clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_dma_bridge_0.clk clockRateSysInfo {100000000.0}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_dma_bridge_0.clk clockResetSysInfo {}
	set_connection_parameter_value hps_csr_clk_0.out_clk/hps_dma_bridge_0.clk resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/a10_hps.f2sdram0_reset
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.f2sdram0_reset clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.f2sdram0_reset clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.f2sdram0_reset resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/a10_hps.f2sdram1_reset
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.f2sdram1_reset clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.f2sdram1_reset clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.f2sdram1_reset resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/a10_hps.h2f_axi_reset
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.h2f_axi_reset clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.h2f_axi_reset clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.h2f_axi_reset resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/a10_hps.h2f_lw_axi_reset
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.h2f_lw_axi_reset clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.h2f_lw_axi_reset clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/a10_hps.h2f_lw_axi_reset resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/emif_a10_hps.global_reset_reset_sink
	set_connection_parameter_value hps_csr_rst_0.out_reset/emif_a10_hps.global_reset_reset_sink clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/emif_a10_hps.global_reset_reset_sink clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/emif_a10_hps.global_reset_reset_sink resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/hps_a10_csr_bridge_0.reset
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_a10_csr_bridge_0.reset clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_a10_csr_bridge_0.reset clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_a10_csr_bridge_0.reset resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/hps_a10_msgdma_0.reset_n
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_a10_msgdma_0.reset_n clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_a10_msgdma_0.reset_n clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_a10_msgdma_0.reset_n resetDomainSysInfo {-1}
	add_connection hps_csr_rst_0.out_reset/hps_dma_bridge_0.reset
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_dma_bridge_0.reset clockDomainSysInfo {-1}
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_dma_bridge_0.reset clockResetSysInfo {}
	set_connection_parameter_value hps_csr_rst_0.out_reset/hps_dma_bridge_0.reset resetDomainSysInfo {-1}

	# add the exports
	set_interface_property a10_hps_f2h_cold_reset_req EXPORT_OF a10_hps.f2h_cold_reset_req
	set_interface_property a10_hps_f2h_debug_reset_req EXPORT_OF a10_hps.f2h_debug_reset_req
	set_interface_property a10_hps_f2h_warm_reset_req EXPORT_OF a10_hps.f2h_warm_reset_req
	set_interface_property a10_hps_f2h_stm_hw_events EXPORT_OF a10_hps.f2h_stm_hw_events
	set_interface_property a10_hps_hps_io EXPORT_OF a10_hps.hps_io
	set_interface_property a10_hps_h2f_reset EXPORT_OF a10_hps.h2f_reset
	set_interface_property hps_to_ddr EXPORT_OF a10_hps.h2f_axi_master
	set_interface_property dla_irq EXPORT_OF a10_hps.f2h_irq1
	set_interface_property emif_a10_hps_pll_ref_clk_clock_sink EXPORT_OF emif_a10_hps.pll_ref_clk_clock_sink
	set_interface_property emif_a10_hps_oct_conduit_end EXPORT_OF emif_a10_hps.oct_conduit_end
	set_interface_property emif_a10_hps_mem_conduit_end EXPORT_OF emif_a10_hps.mem_conduit_end
	set_interface_property hps_to_csr EXPORT_OF hps_a10_csr_bridge_0.m0
	set_interface_property csr_clk EXPORT_OF hps_csr_clk_0.in_clk
	set_interface_property csr_rst EXPORT_OF hps_csr_rst_0.in_reset
	set_interface_property dma_to_ddr EXPORT_OF hps_dma_bridge_0.m0

	# set values for exposed HDL parameters
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.enableAllPipelines FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.enableEccProtection FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.enableInstrumentation FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.interconnectType STANDARD
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.maxAdditionalLatency 3
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.syncResets FALSE
	set_domain_assignment a10_hps.h2f_lw_axi_master qsys_mm.widthAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.burstAdapterImplementation GENERIC_CONVERTER
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.clockCrossingAdapter HANDSHAKE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.enableAllPipelines FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.enableEccProtection FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.enableInstrumentation FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.enableOutOfOrderSupport FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.insertDefaultSlave FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.interconnectResetSource DEFAULT
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.interconnectType STANDARD
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.maxAdditionalLatency 3
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.optimizeRdFifoSize FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.piplineType PIPELINE_STAGE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.responseFifoType REGISTER_BASED
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.syncResets FALSE
	set_domain_assignment hps_a10_msgdma_0.mm_read qsys_mm.widthAdapterImplementation GENERIC_CONVERTER

	# set the the module properties
	set_module_property BONUS_DATA {<?xml version="1.0" encoding="UTF-8"?>
<bonusData>
 <element __value="a10_hps">
  <datum __value="_sortIndex" value="2" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="a10_hps.f2sdram0_data">
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="a10_hps.f2sdram1_data">
  <datum __value="baseAddress" value="2147483648" type="String" />
 </element>
 <element __value="emif_a10_hps">
  <datum __value="_sortIndex" value="3" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_a10_csr_bridge_0">
  <datum __value="_sortIndex" value="6" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_a10_csr_bridge_0.m0">
  <datum __value="_tags" value="" type="String" />
 </element>
 <element __value="hps_a10_csr_bridge_0.s0">
  <datum __value="baseAddress" value="0" type="String" />
 </element>
 <element __value="hps_a10_msgdma_0">
  <datum __value="_sortIndex" value="4" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_a10_msgdma_0.csr">
  <datum __value="baseAddress" value="65600" type="String" />
 </element>
 <element __value="hps_a10_msgdma_0.descriptor_slave">
  <datum __value="baseAddress" value="65536" type="String" />
 </element>
 <element __value="hps_a10_msgdma_0.response">
  <datum __value="baseAddress" value="65648" type="String" />
 </element>
 <element __value="hps_csr_clk_0">
  <datum __value="_sortIndex" value="0" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_csr_rst_0">
  <datum __value="_sortIndex" value="1" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_dma_bridge_0">
  <datum __value="_sortIndex" value="5" type="int" />
  <datum __value="sopceditor_expanded" value="0" type="boolean" />
 </element>
 <element __value="hps_dma_bridge_0.s0">
  <datum __value="baseAddress" value="0" type="String" />
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
	set_exported_interface_sysinfo_parameter_value csr_clk clock_domain {1}
	set_exported_interface_sysinfo_parameter_value csr_clk clock_rate {100000000}
	set_exported_interface_sysinfo_parameter_value csr_clk reset_domain {1}
	set_exported_interface_sysinfo_parameter_value dla_clk clock_domain {2}
	set_exported_interface_sysinfo_parameter_value dla_clk clock_rate {200000000}
	set_exported_interface_sysinfo_parameter_value dla_clk reset_domain {2}
	set_exported_interface_sysinfo_parameter_value dla_to_ddr address_map {<address-map><slave name='parent/emif_0.ddr4_emif.ctrl_amm_0' start='0x0' end='0x80000000' datawidth='512' /></address-map>}
	set_exported_interface_sysinfo_parameter_value dla_to_ddr address_width {31}
	set_exported_interface_sysinfo_parameter_value ddr_clk clock_domain {3}
	set_exported_interface_sysinfo_parameter_value ddr_clk clock_rate {266666665}
	set_exported_interface_sysinfo_parameter_value ddr_clk reset_domain {3}
	save_system dla.qsys
	load_system hps.qsys
	set_exported_interface_sysinfo_parameter_value hps_to_csr address_map {<address-map><slave name='parent/dla_0/dla_a10_altera_ai_ip_0.csr_axi' start='0x4000' end='0x4800' datawidth='32' /></address-map>}
	set_exported_interface_sysinfo_parameter_value hps_to_csr address_width {16}
	set_exported_interface_sysinfo_parameter_value csr_clk clock_domain {1}
	set_exported_interface_sysinfo_parameter_value csr_clk clock_rate {100000000}
	set_exported_interface_sysinfo_parameter_value csr_clk reset_domain {1}
	set_exported_interface_sysinfo_parameter_value dma_to_ddr address_map {<address-map><slave name='parent/emif_0.ddr4_emif.ctrl_amm_0' start='0x0' end='0x80000000' datawidth='512' /></address-map>}
	set_exported_interface_sysinfo_parameter_value dma_to_ddr address_width {31}
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

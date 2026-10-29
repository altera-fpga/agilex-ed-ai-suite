set_location_assignment PIN_U6  -to io_lpddr4_comp1_dq[31]
set_location_assignment PIN_W5  -to io_lpddr4_comp1_dq[30]
set_location_assignment PIN_P7  -to io_lpddr4_comp1_dq[29]
set_location_assignment PIN_R7  -to io_lpddr4_comp1_dq[28]
set_location_assignment PIN_N6  -to io_lpddr4_comp1_dq[27]
set_location_assignment PIN_N7  -to io_lpddr4_comp1_dq[26]
set_location_assignment PIN_V6  -to io_lpddr4_comp1_dq[25]
set_location_assignment PIN_V5  -to io_lpddr4_comp1_dq[24]
set_location_assignment PIN_N3  -to io_lpddr4_comp1_dq[23]
set_location_assignment PIN_P3  -to io_lpddr4_comp1_dq[22]
set_location_assignment PIN_U4  -to io_lpddr4_comp1_dq[21]
set_location_assignment PIN_W3  -to io_lpddr4_comp1_dq[20]
set_location_assignment PIN_V3  -to io_lpddr4_comp1_dq[19]
set_location_assignment PIN_U3  -to io_lpddr4_comp1_dq[18]
set_location_assignment PIN_P5  -to io_lpddr4_comp1_dq[17]
set_location_assignment PIN_P4  -to io_lpddr4_comp1_dq[16]
set_location_assignment PIN_AJ3 -to io_lpddr4_comp1_dq[15]
set_location_assignment PIN_AH3 -to io_lpddr4_comp1_dq[14]
set_location_assignment PIN_AH2 -to io_lpddr4_comp1_dq[13]
set_location_assignment PIN_AG3 -to io_lpddr4_comp1_dq[12]
set_location_assignment PIN_AJ8 -to io_lpddr4_comp1_dq[11]
set_location_assignment PIN_AJ7 -to io_lpddr4_comp1_dq[10]
set_location_assignment PIN_AK7 -to io_lpddr4_comp1_dq[9]
set_location_assignment PIN_AK6 -to io_lpddr4_comp1_dq[8]
set_location_assignment PIN_AE2 -to io_lpddr4_comp1_dq[7]
set_location_assignment PIN_AF1 -to io_lpddr4_comp1_dq[6]
set_location_assignment PIN_AF2 -to io_lpddr4_comp1_dq[5]
set_location_assignment PIN_AG1 -to io_lpddr4_comp1_dq[4]
set_location_assignment PIN_Y2  -to io_lpddr4_comp1_dq[3]
set_location_assignment PIN_AA1 -to io_lpddr4_comp1_dq[2]
set_location_assignment PIN_AA2 -to io_lpddr4_comp1_dq[1]
set_location_assignment PIN_AB1 -to io_lpddr4_comp1_dq[0]

set_location_assignment PIN_R5  -to io_lpddr4_comp1_dqs_p[3]
set_location_assignment PIN_U5  -to io_lpddr4_comp1_dqs_p[2]
set_location_assignment PIN_AK4 -to io_lpddr4_comp1_dqs_p[1]
set_location_assignment PIN_AC1 -to io_lpddr4_comp1_dqs_p[0]

set_location_assignment PIN_R6  -to io_lpddr4_comp1_dqs_n[3]
set_location_assignment PIN_T4  -to io_lpddr4_comp1_dqs_n[2]
set_location_assignment PIN_AJ4 -to io_lpddr4_comp1_dqs_n[1]
set_location_assignment PIN_AC2 -to io_lpddr4_comp1_dqs_n[0]

set_location_assignment PIN_T6  -to io_lpddr4_comp1_dmi[3]
set_location_assignment PIN_T3  -to io_lpddr4_comp1_dmi[2]
set_location_assignment PIN_AJ5 -to io_lpddr4_comp1_dmi[1]
set_location_assignment PIN_AD2 -to io_lpddr4_comp1_dmi[0]

set_location_assignment PIN_M1   -to i_fpga_core_resetn
set_location_assignment PIN_AJ27 -to i_pll_ref_clk
set_location_assignment PIN_AF3  -to i_lpddr4_comp1_refclk_p
set_location_assignment PIN_AD3  -to i_lpddr4_comp1_rzq

set_location_assignment PIN_AG5 -to o_lpddr4_comp1_ca[5]
set_location_assignment PIN_AH5 -to o_lpddr4_comp1_ca[4]
set_location_assignment PIN_AE6 -to o_lpddr4_comp1_ca[3]
set_location_assignment PIN_AF6 -to o_lpddr4_comp1_ca[2]
set_location_assignment PIN_AE7 -to o_lpddr4_comp1_ca[1]
set_location_assignment PIN_AF7 -to o_lpddr4_comp1_ca[0]

set_location_assignment PIN_AD4 -to o_lpddr4_comp1_reset_n

set_location_assignment PIN_AH6 -to o_lpddr4_comp1_cke[0]
set_location_assignment PIN_AA4 -to o_lpddr4_comp1_ck_n[0]
set_location_assignment PIN_AB3 -to o_lpddr4_comp1_ck_p[0]
set_location_assignment PIN_AF4 -to o_lpddr4_comp1_cs[0]

set_instance_assignment -name IO_STANDARD "1.1V TRUE DIFFERENTIAL SIGNALING" -to i_lpddr4_comp1_refclk_p -entity top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_pll_ref_clk -entity top
set_instance_assignment -name IO_STANDARD "1.3-V LVCMOS" -to i_fpga_core_resetn -entity top
set_instance_assignment -name IO_STANDARD "1.1 V" -to i_lpddr4_comp1_rzq -entity top

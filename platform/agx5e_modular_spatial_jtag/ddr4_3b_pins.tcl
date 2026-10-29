# Pin locations and IO standards for the DDR4 interface on IO bank 3B.
#
# Copied from the Agilex 5 065B Development Kit examples:
# examples/bts_emif/bts_ddr4_3B/ed_synth.qsf

set_location_assignment PIN_AC68 -to ddr4_3b_refclk_clk
set_location_assignment PIN_Y77 -to ddr4_3b_mem_alert_n
set_location_assignment PIN_AC79 -to ddr4_3b_oct_oct_rzqin
set_location_assignment PIN_P74 -to ddr4_3b_mem_a[0]
set_location_assignment PIN_T65 -to ddr4_3b_mem_a[10]
set_location_assignment PIN_P65 -to ddr4_3b_mem_a[11]
set_location_assignment PIN_AG79 -to ddr4_3b_mem_a[12]
set_location_assignment PIN_AG72 -to ddr4_3b_mem_a[13]
set_location_assignment PIN_AG75 -to ddr4_3b_mem_a[14]
set_location_assignment PIN_AG83 -to ddr4_3b_mem_a[15]
set_location_assignment PIN_AC83 -to ddr4_3b_mem_a[16]
set_location_assignment PIN_T74 -to ddr4_3b_mem_a[1]
set_location_assignment PIN_V77 -to ddr4_3b_mem_a[2]
set_location_assignment PIN_T77 -to ddr4_3b_mem_a[3]
set_location_assignment PIN_M74 -to ddr4_3b_mem_a[4]
set_location_assignment PIN_K74 -to ddr4_3b_mem_a[5]
set_location_assignment PIN_V67 -to ddr4_3b_mem_a[6]
set_location_assignment PIN_T67 -to ddr4_3b_mem_a[7]
set_location_assignment PIN_M65 -to ddr4_3b_mem_a[8]
set_location_assignment PIN_K65 -to ddr4_3b_mem_a[9]
set_location_assignment PIN_H77 -to ddr4_3b_mem_act_n
set_location_assignment PIN_Y74 -to ddr4_3b_mem_ba[0]
set_location_assignment PIN_Y67 -to ddr4_3b_mem_ba[1]
set_location_assignment PIN_Y65 -to ddr4_3b_mem_bg[0]
set_location_assignment PIN_K77 -to ddr4_3b_mem_bg[1]
set_location_assignment PIN_F67 -to ddr4_3b_ck_mem_ck_c
set_location_assignment PIN_H67 -to ddr4_3b_ck_mem_ck_t
set_location_assignment PIN_M67 -to ddr4_3b_mem_cke
set_location_assignment PIN_F77 -to ddr4_3b_mem_cs_n
set_location_assignment PIN_D74 -to ddr4_3b_mem_odt
set_location_assignment PIN_D65 -to ddr4_3b_mem_par
set_location_assignment PIN_M77 -to ddr4_3b_rst_mem_reset_n
set_location_assignment PIN_B73 -to ddr4_3b_mem_dbi_n[0]
set_location_assignment PIN_AC53 -to ddr4_3b_mem_dbi_n[1]
set_location_assignment PIN_V47 -to ddr4_3b_mem_dbi_n[2]
set_location_assignment PIN_M47 -to ddr4_3b_mem_dbi_n[3]
set_location_assignment PIN_B51 -to ddr4_3b_mem_dbi_n[4]
set_location_assignment PIN_B82 -to ddr4_3b_mem_dq[0]
set_location_assignment PIN_AC61 -to ddr4_3b_mem_dq[10]
set_location_assignment PIN_Y55 -to ddr4_3b_mem_dq[11]
set_location_assignment PIN_AC64 -to ddr4_3b_mem_dq[12]
set_location_assignment PIN_AG61 -to ddr4_3b_mem_dq[13]
set_location_assignment PIN_AG64 -to ddr4_3b_mem_dq[14]
set_location_assignment PIN_Y44 -to ddr4_3b_mem_dq[15]
set_location_assignment PIN_P55 -to ddr4_3b_mem_dq[16]
set_location_assignment PIN_T55 -to ddr4_3b_mem_dq[17]
set_location_assignment PIN_V58 -to ddr4_3b_mem_dq[18]
set_location_assignment PIN_T58 -to ddr4_3b_mem_dq[19]
set_location_assignment PIN_A66 -to ddr4_3b_mem_dq[1]
set_location_assignment PIN_P44 -to ddr4_3b_mem_dq[20]
set_location_assignment PIN_T44 -to ddr4_3b_mem_dq[21]
set_location_assignment PIN_K44 -to ddr4_3b_mem_dq[22]
set_location_assignment PIN_M44 -to ddr4_3b_mem_dq[23]
set_location_assignment PIN_H58 -to ddr4_3b_mem_dq[24]
set_location_assignment PIN_F58 -to ddr4_3b_mem_dq[25]
set_location_assignment PIN_M58 -to ddr4_3b_mem_dq[26]
set_location_assignment PIN_K58 -to ddr4_3b_mem_dq[27]
set_location_assignment PIN_F47 -to ddr4_3b_mem_dq[28]
set_location_assignment PIN_H47 -to ddr4_3b_mem_dq[29]
set_location_assignment PIN_A82 -to ddr4_3b_mem_dq[2]
set_location_assignment PIN_D44 -to ddr4_3b_mem_dq[30]
set_location_assignment PIN_F44 -to ddr4_3b_mem_dq[31]
set_location_assignment PIN_B56 -to ddr4_3b_mem_dq[32]
set_location_assignment PIN_B45 -to ddr4_3b_mem_dq[33]
set_location_assignment PIN_A60 -to ddr4_3b_mem_dq[34]
set_location_assignment PIN_A48 -to ddr4_3b_mem_dq[35]
set_location_assignment PIN_B60 -to ddr4_3b_mem_dq[36]
set_location_assignment PIN_B42 -to ddr4_3b_mem_dq[37]
set_location_assignment PIN_A63 -to ddr4_3b_mem_dq[38]
set_location_assignment PIN_A45 -to ddr4_3b_mem_dq[39]
set_location_assignment PIN_A70 -to ddr4_3b_mem_dq[3]
set_location_assignment PIN_A85 -to ddr4_3b_mem_dq[4]
set_location_assignment PIN_B66 -to ddr4_3b_mem_dq[5]
set_location_assignment PIN_B85 -to ddr4_3b_mem_dq[6]
set_location_assignment PIN_B70 -to ddr4_3b_mem_dq[7]
set_location_assignment PIN_Y58 -to ddr4_3b_mem_dq[8]
set_location_assignment PIN_Y47 -to ddr4_3b_mem_dq[9]
set_location_assignment PIN_B76 -to ddr4_3b_mem_dqs_c[0]
set_location_assignment PIN_AG53 -to ddr4_3b_mem_dqs_c[1]
set_location_assignment PIN_M55 -to ddr4_3b_mem_dqs_c[2]
set_location_assignment PIN_D55 -to ddr4_3b_mem_dqs_c[3]
set_location_assignment PIN_B54 -to ddr4_3b_mem_dqs_c[4]
set_location_assignment PIN_A80 -to ddr4_3b_mem_dqs_t[0]
set_location_assignment PIN_AG57 -to ddr4_3b_mem_dqs_t[1]
set_location_assignment PIN_K55 -to ddr4_3b_mem_dqs_t[2]
set_location_assignment PIN_F55 -to ddr4_3b_mem_dqs_t[3]
set_location_assignment PIN_A54 -to ddr4_3b_mem_dqs_t[4]

set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_a[*] -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_act_n -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_ba[*] -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_bg[*] -entity system_top
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to ddr4_3b_ck_mem_ck_c -entity system_top
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to ddr4_3b_ck_mem_ck_t -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_cke -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_cs_n -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_odt -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_mem_par -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_3b_rst_mem_reset_n -entity system_top
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to ddr4_3b_mem_dbi_n[*] -entity system_top
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to ddr4_3b_mem_dq[*] -entity system_top

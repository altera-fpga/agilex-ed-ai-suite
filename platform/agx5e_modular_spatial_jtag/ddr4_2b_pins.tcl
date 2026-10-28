# Pin locations and IO standards for the DDR4 interface on IO bank 2B.
#
# Copied from the Agilex 5 065B Development Kit examples:
# examples/bts_emif/bts_ddr4_2B/ed_synth.qsf

set_location_assignment PIN_BR49 -to ddr4_2b_refclk_clk
set_location_assignment PIN_BR38 -to ddr4_2b_mem_alert_n
set_location_assignment PIN_BR52 -to ddr4_2b_oct_oct_rzqin
set_location_assignment PIN_CF52 -to ddr4_2b_mem_a[0]
set_location_assignment PIN_CH38 -to ddr4_2b_mem_a[10]
set_location_assignment PIN_CF38 -to ddr4_2b_mem_a[11]
set_location_assignment PIN_BU52 -to ddr4_2b_mem_a[12]
set_location_assignment PIN_BW49 -to ddr4_2b_mem_a[13]
set_location_assignment PIN_CA49 -to ddr4_2b_mem_a[14]
set_location_assignment PIN_BR41 -to ddr4_2b_mem_a[15]
set_location_assignment PIN_BU41 -to ddr4_2b_mem_a[16]
set_location_assignment PIN_CH52 -to ddr4_2b_mem_a[1]
set_location_assignment PIN_CC52 -to ddr4_2b_mem_a[2]
set_location_assignment PIN_CA52 -to ddr4_2b_mem_a[3]
set_location_assignment PIN_CF49 -to ddr4_2b_mem_a[4]
set_location_assignment PIN_CH49 -to ddr4_2b_mem_a[5]
set_location_assignment PIN_CH41 -to ddr4_2b_mem_a[6]
set_location_assignment PIN_CF41 -to ddr4_2b_mem_a[7]
set_location_assignment PIN_CC41 -to ddr4_2b_mem_a[8]
set_location_assignment PIN_CA41 -to ddr4_2b_mem_a[9]
set_location_assignment PIN_CL45 -to ddr4_2b_mem_act_n
set_location_assignment PIN_BU38 -to ddr4_2b_mem_ba[0]
set_location_assignment PIN_CA38 -to ddr4_2b_mem_ba[1]
set_location_assignment PIN_BW38 -to ddr4_2b_mem_bg[0]
set_location_assignment PIN_CL42 -to ddr4_2b_mem_bg[1]
set_location_assignment PIN_CL30 -to ddr4_2b_ck_mem_ck_c
set_location_assignment PIN_CK33 -to ddr4_2b_ck_mem_ck_t
set_location_assignment PIN_CK35 -to ddr4_2b_mem_cke
set_location_assignment PIN_CK48 -to ddr4_2b_mem_cs_n
set_location_assignment PIN_CK39 -to ddr4_2b_mem_odt
set_location_assignment PIN_CL26 -to ddr4_2b_mem_par
set_location_assignment PIN_CK45 -to ddr4_2b_rst_mem_reset_n
set_location_assignment PIN_BP41 -to ddr4_2b_mem_dbi_n[0]
set_location_assignment PIN_CL56 -to ddr4_2b_mem_dbi_n[1]
set_location_assignment PIN_BF57 -to ddr4_2b_mem_dbi_n[2]
set_location_assignment PIN_CL14 -to ddr4_2b_mem_dbi_n[3]
set_location_assignment PIN_BK38 -to ddr4_2b_mem_dq[0]
set_location_assignment PIN_CK54 -to ddr4_2b_mem_dq[10]
set_location_assignment PIN_CL73 -to ddr4_2b_mem_dq[11]
set_location_assignment PIN_CL54 -to ddr4_2b_mem_dq[12]
set_location_assignment PIN_CK73 -to ddr4_2b_mem_dq[13]
set_location_assignment PIN_CK56 -to ddr4_2b_mem_dq[14]
set_location_assignment PIN_CL70 -to ddr4_2b_mem_dq[15]
set_location_assignment PIN_BF50 -to ddr4_2b_mem_dq[16]
set_location_assignment PIN_BF64 -to ddr4_2b_mem_dq[17]
set_location_assignment PIN_BE50 -to ddr4_2b_mem_dq[18]
set_location_assignment PIN_BF68 -to ddr4_2b_mem_dq[19]
set_location_assignment PIN_BH49 -to ddr4_2b_mem_dq[1]
set_location_assignment PIN_BE46 -to ddr4_2b_mem_dq[20]
set_location_assignment PIN_BE64 -to ddr4_2b_mem_dq[21]
set_location_assignment PIN_BF46 -to ddr4_2b_mem_dq[22]
set_location_assignment PIN_BE68 -to ddr4_2b_mem_dq[23]
set_location_assignment PIN_CK8 -to ddr4_2b_mem_dq[24]
set_location_assignment PIN_CK20 -to ddr4_2b_mem_dq[25]
set_location_assignment PIN_CK11 -to ddr4_2b_mem_dq[26]
set_location_assignment PIN_CL20 -to ddr4_2b_mem_dq[27]
set_location_assignment PIN_CL6 -to ddr4_2b_mem_dq[28]
set_location_assignment PIN_CK26 -to ddr4_2b_mem_dq[29]
set_location_assignment PIN_BH41 -to ddr4_2b_mem_dq[2]
set_location_assignment PIN_CL8 -to ddr4_2b_mem_dq[30]
set_location_assignment PIN_CL23 -to ddr4_2b_mem_dq[31]
set_location_assignment PIN_BH52 -to ddr4_2b_mem_dq[3]
set_location_assignment PIN_BH38 -to ddr4_2b_mem_dq[4]
set_location_assignment PIN_BP52 -to ddr4_2b_mem_dq[5]
set_location_assignment PIN_BM38 -to ddr4_2b_mem_dq[6]
set_location_assignment PIN_BM52 -to ddr4_2b_mem_dq[7]
set_location_assignment PIN_CL51 -to ddr4_2b_mem_dq[8]
set_location_assignment PIN_CK66 -to ddr4_2b_mem_dq[9]
set_location_assignment PIN_BM49 -to ddr4_2b_mem_dqs_c[0]
set_location_assignment PIN_CL66 -to ddr4_2b_mem_dqs_c[1]
set_location_assignment PIN_BE57 -to ddr4_2b_mem_dqs_c[2]
set_location_assignment PIN_CL17 -to ddr4_2b_mem_dqs_c[3]
set_location_assignment PIN_BK49 -to ddr4_2b_mem_dqs_t[0]
set_location_assignment PIN_CK63 -to ddr4_2b_mem_dqs_t[1]
set_location_assignment PIN_BE61 -to ddr4_2b_mem_dqs_t[2]
set_location_assignment PIN_CK17 -to ddr4_2b_mem_dqs_t[3]

set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_a[*] -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_act_n -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_ba[*] -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_bg[*] -entity system_top
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to ddr4_2b_ck_mem_ck_c -entity system_top
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to ddr4_2b_ck_mem_ck_t -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_cke -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_cs_n -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_odt -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_mem_par -entity system_top
set_instance_assignment -name IO_STANDARD "SSTL-12" -to ddr4_2b_rst_mem_reset_n -entity system_top
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to ddr4_2b_mem_dbi_n[*] -entity system_top
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to ddr4_2b_mem_dq[*] -entity system_top

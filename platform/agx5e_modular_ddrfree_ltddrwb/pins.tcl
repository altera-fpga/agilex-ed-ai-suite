set_location_assignment PIN_BK31 -to clk_sys_100m_p
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to clk_sys_100m_p -entity top

# EMIF
set_location_assignment PIN_BR49 -to mem_ddr4_mem_ref_clk
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to mem_ddr4_mem_ref_clk
set_location_assignment PIN_CK35 -to mem_ddr4_mem_cke -comment IOBANK_2B_B
set_location_assignment PIN_CK39 -to mem_ddr4_mem_odt -comment IOBANK_2B_B
set_location_assignment PIN_CK48 -to mem_ddr4_mem_cs_n -comment IOBANK_2B_B
set_location_assignment PIN_CF52 -to mem_ddr4_mem_a[0] -comment IOBANK_2B_B
set_location_assignment PIN_CH52 -to mem_ddr4_mem_a[1] -comment IOBANK_2B_B
set_location_assignment PIN_CC52 -to mem_ddr4_mem_a[2] -comment IOBANK_2B_B
set_location_assignment PIN_CA52 -to mem_ddr4_mem_a[3] -comment IOBANK_2B_B
set_location_assignment PIN_CF49 -to mem_ddr4_mem_a[4] -comment IOBANK_2B_B
set_location_assignment PIN_CH49 -to mem_ddr4_mem_a[5] -comment IOBANK_2B_B
set_location_assignment PIN_CH41 -to mem_ddr4_mem_a[6] -comment IOBANK_2B_B
set_location_assignment PIN_CF41 -to mem_ddr4_mem_a[7] -comment IOBANK_2B_B
set_location_assignment PIN_CC41 -to mem_ddr4_mem_a[8] -comment IOBANK_2B_B
set_location_assignment PIN_CA41 -to mem_ddr4_mem_a[9] -comment IOBANK_2B_B
set_location_assignment PIN_CH38 -to mem_ddr4_mem_a[10] -comment IOBANK_2B_B
set_location_assignment PIN_CF38 -to mem_ddr4_mem_a[11] -comment IOBANK_2B_B
set_location_assignment PIN_BU52 -to mem_ddr4_mem_a[12] -comment IOBANK_2B_B
set_location_assignment PIN_BW49 -to mem_ddr4_mem_a[13] -comment IOBANK_2B_B
set_location_assignment PIN_CA49 -to mem_ddr4_mem_a[14] -comment IOBANK_2B_B
set_location_assignment PIN_BR41 -to mem_ddr4_mem_a[15] -comment IOBANK_2B_B
set_location_assignment PIN_BU41 -to mem_ddr4_mem_a[16] -comment IOBANK_2B_B
set_location_assignment PIN_BU38 -to mem_ddr4_mem_ba[0] -comment IOBANK_2B_B
set_location_assignment PIN_CA38 -to mem_ddr4_mem_ba[1] -comment IOBANK_2B_B
set_location_assignment PIN_CL42 -to mem_ddr4_mem_bg[1] -comment IOBANK_2B_B
set_location_assignment PIN_BW38 -to mem_ddr4_mem_bg[0] -comment IOBANK_2B_B
set_location_assignment PIN_CL45 -to mem_ddr4_mem_act_n -comment IOBANK_2B_B
set_location_assignment PIN_CL26 -to mem_ddr4_mem_par -comment IOBANK_2B_B
set_location_assignment PIN_BK38 -to mem_ddr4_mem_dq[0] -comment IOBANK_2B_T
set_location_assignment PIN_BH49 -to mem_ddr4_mem_dq[1] -comment IOBANK_2B_T
set_location_assignment PIN_BH41 -to mem_ddr4_mem_dq[2] -comment IOBANK_2B_T
set_location_assignment PIN_BH52 -to mem_ddr4_mem_dq[3] -comment IOBANK_2B_T
set_location_assignment PIN_BH38 -to mem_ddr4_mem_dq[4] -comment IOBANK_2B_T
set_location_assignment PIN_BP52 -to mem_ddr4_mem_dq[5] -comment IOBANK_2B_T
set_location_assignment PIN_BM38 -to mem_ddr4_mem_dq[6] -comment IOBANK_2B_T
set_location_assignment PIN_BM52 -to mem_ddr4_mem_dq[7] -comment IOBANK_2B_T
set_location_assignment PIN_CL51 -to mem_ddr4_mem_dq[8] -comment IOBANK_2B_B
set_location_assignment PIN_CK66 -to mem_ddr4_mem_dq[9] -comment IOBANK_2B_B
set_location_assignment PIN_CK54 -to mem_ddr4_mem_dq[10] -comment IOBANK_2B_B
set_location_assignment PIN_CL73 -to mem_ddr4_mem_dq[11] -comment IOBANK_2B_B
set_location_assignment PIN_CL54 -to mem_ddr4_mem_dq[12] -comment IOBANK_2B_B
set_location_assignment PIN_CK73 -to mem_ddr4_mem_dq[13] -comment IOBANK_2B_B
set_location_assignment PIN_CK56 -to mem_ddr4_mem_dq[14] -comment IOBANK_2B_B
set_location_assignment PIN_CL70 -to mem_ddr4_mem_dq[15] -comment IOBANK_2B_B
set_location_assignment PIN_BF50 -to mem_ddr4_mem_dq[16] -comment IOBANK_2B_T
set_location_assignment PIN_BF64 -to mem_ddr4_mem_dq[17] -comment IOBANK_2B_T
set_location_assignment PIN_BE50 -to mem_ddr4_mem_dq[18] -comment IOBANK_2B_T
set_location_assignment PIN_BF68 -to mem_ddr4_mem_dq[19] -comment IOBANK_2B_T
set_location_assignment PIN_BE46 -to mem_ddr4_mem_dq[20] -comment IOBANK_2B_T
set_location_assignment PIN_BE64 -to mem_ddr4_mem_dq[21] -comment IOBANK_2B_T
set_location_assignment PIN_BF46 -to mem_ddr4_mem_dq[22] -comment IOBANK_2B_T
set_location_assignment PIN_BE68 -to mem_ddr4_mem_dq[23] -comment IOBANK_2B_T
set_location_assignment PIN_CK8 -to mem_ddr4_mem_dq[24] -comment IOBANK_2B_T
set_location_assignment PIN_CK20 -to mem_ddr4_mem_dq[25] -comment IOBANK_2B_T
set_location_assignment PIN_CK11 -to mem_ddr4_mem_dq[26] -comment IOBANK_2B_T
set_location_assignment PIN_CL20 -to mem_ddr4_mem_dq[27] -comment IOBANK_2B_T
set_location_assignment PIN_CL6 -to mem_ddr4_mem_dq[28] -comment IOBANK_2B_T
set_location_assignment PIN_CK26 -to mem_ddr4_mem_dq[29] -comment IOBANK_2B_T
set_location_assignment PIN_CL8 -to mem_ddr4_mem_dq[30] -comment IOBANK_2B_T
set_location_assignment PIN_CL23 -to mem_ddr4_mem_dq[31] -comment IOBANK_2B_T
set_location_assignment PIN_BK49 -to mem_ddr4_mem_dqs_t[0] -comment IOBANK_2B_T
set_location_assignment PIN_CK63 -to mem_ddr4_mem_dqs_t[1] -comment IOBANK_2B_B
set_location_assignment PIN_BE61 -to mem_ddr4_mem_dqs_t[2] -comment IOBANK_2B_T
set_location_assignment PIN_CK17 -to mem_ddr4_mem_dqs_t[3] -comment IOBANK_2B_T
set_location_assignment PIN_BM49 -to mem_ddr4_mem_dqs_c[0] -comment IOBANK_2B_T
set_location_assignment PIN_CL66 -to mem_ddr4_mem_dqs_c[1] -comment IOBANK_2B_B
set_location_assignment PIN_BE57 -to mem_ddr4_mem_dqs_c[2] -comment IOBANK_2B_T
set_location_assignment PIN_CL17 -to mem_ddr4_mem_dqs_c[3] -comment IOBANK_2B_T
set_location_assignment PIN_BR38 -to mem_ddr4_mem_alert_n -comment IOBANK_2B_B
set_location_assignment PIN_BP41 -to mem_ddr4_mem_dbi_n[0] -comment IOBANK_2B_T
set_location_assignment PIN_CL56 -to mem_ddr4_mem_dbi_n[1] -comment IOBANK_2B_B
set_location_assignment PIN_BF57 -to mem_ddr4_mem_dbi_n[2] -comment IOBANK_2B_T
set_location_assignment PIN_CL14 -to mem_ddr4_mem_dbi_n[3] -comment IOBANK_2B_T
set_location_assignment PIN_CK33 -to mem_ddr4_ck_mem_ck_t -comment IOBANK_2B_B
set_location_assignment PIN_CL30 -to mem_ddr4_ck_mem_ck_c -comment IOBANK_2B_B
set_location_assignment PIN_CK45 -to mem_ddr4_reset_n_mem_reset_n -comment IOBANK_2B_B
set_location_assignment PIN_BR52 -to mem_ddr4_mem_oct_oct_rzqin


set_location_assignment PIN_CM29 -to fpga_clk_100
set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to fpga_clk_100
set_location_assignment PIN_AB53 -to fpga_reset_n
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_reset_n
set_location_assignment PIN_Y49 -to fpga_sgpio_sync
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_sgpio_sync
set_location_assignment PIN_W48 -to fpga_sgpio_clk
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_sgpio_clk
set_location_assignment PIN_T49 -to fpga_sgpi
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_sgpi
set_location_assignment PIN_U48 -to fpga_sgpo
set_instance_assignment -name IO_STANDARD "1.2 V" -to fpga_sgpo

set_instance_assignment -name IO_STANDARD "TRUE DIFFERENTIAL SIGNALING" -to emif_agx_0_pll_ref_clk_clk[0] 
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to emif_agx_0_pll_ref_clk_clk[0] 


set_location_assignment PIN_AD51 -to refclk_bti
set_instance_assignment -name IO_STANDARD "1.2-V" -to refclk_bti -entity top

set_location_assignment PIN_U34 -to emif_hps_pll_ref_clk
set_location_assignment PIN_W34 -to emif_hps_oct_oct_rzqin
set_location_assignment PIN_L32 -to emif_hps_mem_mem_a[0]
set_location_assignment PIN_M33 -to emif_hps_mem_mem_a[1]
set_location_assignment PIN_R32 -to emif_hps_mem_mem_a[2]
set_location_assignment PIN_P33 -to emif_hps_mem_mem_a[3]
set_location_assignment PIN_L30 -to emif_hps_mem_mem_a[4]
set_location_assignment PIN_M31 -to emif_hps_mem_mem_a[5]
set_location_assignment PIN_R30 -to emif_hps_mem_mem_a[6]
set_location_assignment PIN_P31 -to emif_hps_mem_mem_a[7]
set_location_assignment PIN_L28 -to emif_hps_mem_mem_a[8]
set_location_assignment PIN_M29 -to emif_hps_mem_mem_a[9]
set_location_assignment PIN_R28 -to emif_hps_mem_mem_a[10]
set_location_assignment PIN_P29 -to emif_hps_mem_mem_a[11]
set_location_assignment PIN_Y35 -to emif_hps_mem_mem_a[12]
set_location_assignment PIN_U32 -to emif_hps_mem_mem_a[13]
set_location_assignment PIN_T33 -to emif_hps_mem_mem_a[14]
set_location_assignment PIN_W32 -to emif_hps_mem_mem_a[15]
set_location_assignment PIN_Y33 -to emif_hps_mem_mem_a[16]
set_location_assignment PIN_T31 -to emif_hps_mem_mem_ba[0]
set_location_assignment PIN_W30 -to emif_hps_mem_mem_ba[1]
set_location_assignment PIN_Y31 -to emif_hps_mem_mem_bg[0]
set_location_assignment PIN_P39 -to emif_hps_mem_mem_act_n[0]
set_location_assignment PIN_U30 -to emif_hps_mem_mem_alert_n[0]
set_location_assignment PIN_L34 -to emif_hps_mem_mem_ck[0]
set_location_assignment PIN_M35 -to emif_hps_mem_mem_ck_n[0]
set_location_assignment PIN_R36 -to emif_hps_mem_mem_cke[0]
set_location_assignment PIN_R38 -to emif_hps_mem_mem_cs_n[0]
set_location_assignment PIN_L36 -to emif_hps_mem_mem_odt[0]
set_location_assignment PIN_P35 -to emif_hps_mem_mem_par[0]
set_location_assignment PIN_M39 -to emif_hps_mem_mem_reset_n[0]
set_location_assignment PIN_G24 -to emif_hps_mem_mem_dqs[0]
set_location_assignment PIN_E28 -to emif_hps_mem_mem_dqs[1]
set_location_assignment PIN_G30 -to emif_hps_mem_mem_dqs[2]
set_location_assignment PIN_A34 -to emif_hps_mem_mem_dqs[3]
set_location_assignment PIN_AA38 -to emif_hps_mem_mem_dqs[4]
set_location_assignment PIN_U38 -to emif_hps_mem_mem_dqs[5]
set_location_assignment PIN_G42 -to emif_hps_mem_mem_dqs[6]
set_location_assignment PIN_L42 -to emif_hps_mem_mem_dqs[7]
set_location_assignment PIN_AA32 -to emif_hps_mem_mem_dqs[8]
set_location_assignment PIN_F25 -to emif_hps_mem_mem_dqs_n[0]
set_location_assignment PIN_D29 -to emif_hps_mem_mem_dqs_n[1]
set_location_assignment PIN_F31 -to emif_hps_mem_mem_dqs_n[2]
set_location_assignment PIN_B35 -to emif_hps_mem_mem_dqs_n[3]
set_location_assignment PIN_AB39 -to emif_hps_mem_mem_dqs_n[4]
set_location_assignment PIN_T39 -to emif_hps_mem_mem_dqs_n[5]
set_location_assignment PIN_F43 -to emif_hps_mem_mem_dqs_n[6]
set_location_assignment PIN_M43 -to emif_hps_mem_mem_dqs_n[7]
set_location_assignment PIN_AB33 -to emif_hps_mem_mem_dqs_n[8]
set_location_assignment PIN_J24 -to emif_hps_mem_mem_dbi_n[0]
set_location_assignment PIN_A28 -to emif_hps_mem_mem_dbi_n[1]
set_location_assignment PIN_J30 -to emif_hps_mem_mem_dbi_n[2]
set_location_assignment PIN_E34 -to emif_hps_mem_mem_dbi_n[3]
set_location_assignment PIN_AE38 -to emif_hps_mem_mem_dbi_n[4]
set_location_assignment PIN_W38 -to emif_hps_mem_mem_dbi_n[5]
set_location_assignment PIN_J42 -to emif_hps_mem_mem_dbi_n[6]
set_location_assignment PIN_R42 -to emif_hps_mem_mem_dbi_n[7]
set_location_assignment PIN_AE32 -to emif_hps_mem_mem_dbi_n[8]
set_location_assignment PIN_G26 -to emif_hps_mem_mem_dq[0]
set_location_assignment PIN_F27 -to emif_hps_mem_mem_dq[1]
set_location_assignment PIN_J26 -to emif_hps_mem_mem_dq[2]
set_location_assignment PIN_K27 -to emif_hps_mem_mem_dq[3]
set_location_assignment PIN_G22 -to emif_hps_mem_mem_dq[4]
set_location_assignment PIN_F23 -to emif_hps_mem_mem_dq[5]
set_location_assignment PIN_J22 -to emif_hps_mem_mem_dq[6]
set_location_assignment PIN_K23 -to emif_hps_mem_mem_dq[7]
set_location_assignment PIN_A30 -to emif_hps_mem_mem_dq[8]
set_location_assignment PIN_B31 -to emif_hps_mem_mem_dq[9]
set_location_assignment PIN_D31 -to emif_hps_mem_mem_dq[10]
set_location_assignment PIN_E30 -to emif_hps_mem_mem_dq[11]
set_location_assignment PIN_A26 -to emif_hps_mem_mem_dq[12]
set_location_assignment PIN_B27 -to emif_hps_mem_mem_dq[13]
set_location_assignment PIN_E26 -to emif_hps_mem_mem_dq[14]
set_location_assignment PIN_D27 -to emif_hps_mem_mem_dq[15]
set_location_assignment PIN_G32 -to emif_hps_mem_mem_dq[16]
set_location_assignment PIN_K33 -to emif_hps_mem_mem_dq[17]
set_location_assignment PIN_J32 -to emif_hps_mem_mem_dq[18]
set_location_assignment PIN_F33 -to emif_hps_mem_mem_dq[19]
set_location_assignment PIN_G28 -to emif_hps_mem_mem_dq[20]
set_location_assignment PIN_F29 -to emif_hps_mem_mem_dq[21]
set_location_assignment PIN_J28 -to emif_hps_mem_mem_dq[22]
set_location_assignment PIN_K29 -to emif_hps_mem_mem_dq[23]
set_location_assignment PIN_A36 -to emif_hps_mem_mem_dq[24]
set_location_assignment PIN_B37 -to emif_hps_mem_mem_dq[25]
set_location_assignment PIN_E36 -to emif_hps_mem_mem_dq[26]
set_location_assignment PIN_D37 -to emif_hps_mem_mem_dq[27]
set_location_assignment PIN_A32 -to emif_hps_mem_mem_dq[28]
set_location_assignment PIN_B33 -to emif_hps_mem_mem_dq[29]
set_location_assignment PIN_E32 -to emif_hps_mem_mem_dq[30]
set_location_assignment PIN_D33 -to emif_hps_mem_mem_dq[31]
set_location_assignment PIN_AE40 -to emif_hps_mem_mem_dq[32]
set_location_assignment PIN_AA40 -to emif_hps_mem_mem_dq[33]
set_location_assignment PIN_AD41 -to emif_hps_mem_mem_dq[34]
set_location_assignment PIN_AB41 -to emif_hps_mem_mem_dq[35]
set_location_assignment PIN_AD37 -to emif_hps_mem_mem_dq[36]
set_location_assignment PIN_AE36 -to emif_hps_mem_mem_dq[37]
set_location_assignment PIN_AB37 -to emif_hps_mem_mem_dq[38]
set_location_assignment PIN_AA36 -to emif_hps_mem_mem_dq[39]
set_location_assignment PIN_T41 -to emif_hps_mem_mem_dq[40]
set_location_assignment PIN_U40 -to emif_hps_mem_mem_dq[41]
set_location_assignment PIN_Y41 -to emif_hps_mem_mem_dq[42]
set_location_assignment PIN_W40 -to emif_hps_mem_mem_dq[43]
set_location_assignment PIN_U36 -to emif_hps_mem_mem_dq[44]
set_location_assignment PIN_T37 -to emif_hps_mem_mem_dq[45]
set_location_assignment PIN_W36 -to emif_hps_mem_mem_dq[46]
set_location_assignment PIN_Y37 -to emif_hps_mem_mem_dq[47]
set_location_assignment PIN_F45 -to emif_hps_mem_mem_dq[48]
set_location_assignment PIN_G44 -to emif_hps_mem_mem_dq[49]
set_location_assignment PIN_K45 -to emif_hps_mem_mem_dq[50]
set_location_assignment PIN_J44 -to emif_hps_mem_mem_dq[51]
set_location_assignment PIN_J40 -to emif_hps_mem_mem_dq[52]
set_location_assignment PIN_K41 -to emif_hps_mem_mem_dq[53]
set_location_assignment PIN_G40 -to emif_hps_mem_mem_dq[54]
set_location_assignment PIN_F41 -to emif_hps_mem_mem_dq[55]
set_location_assignment PIN_L44 -to emif_hps_mem_mem_dq[56]
set_location_assignment PIN_P45 -to emif_hps_mem_mem_dq[57]
set_location_assignment PIN_M45 -to emif_hps_mem_mem_dq[58]
set_location_assignment PIN_R44 -to emif_hps_mem_mem_dq[59]
set_location_assignment PIN_L40 -to emif_hps_mem_mem_dq[60]
set_location_assignment PIN_M41 -to emif_hps_mem_mem_dq[61]
set_location_assignment PIN_R40 -to emif_hps_mem_mem_dq[62]
set_location_assignment PIN_P41 -to emif_hps_mem_mem_dq[63]
set_location_assignment PIN_AA34 -to emif_hps_mem_mem_dq[64]
set_location_assignment PIN_AB35 -to emif_hps_mem_mem_dq[65]
set_location_assignment PIN_AE34 -to emif_hps_mem_mem_dq[66]
set_location_assignment PIN_AD35 -to emif_hps_mem_mem_dq[67]
set_location_assignment PIN_AA30 -to emif_hps_mem_mem_dq[68]
set_location_assignment PIN_AB31 -to emif_hps_mem_mem_dq[69]
set_location_assignment PIN_AE30 -to emif_hps_mem_mem_dq[70]
set_location_assignment PIN_AD31 -to emif_hps_mem_mem_dq[71]


set_location_assignment PIN_DL40 -to emif_agx_0_mem_mem_dq[3]
set_location_assignment PIN_DM39 -to emif_agx_0_mem_mem_dq[0]
set_location_assignment PIN_DR40 -to emif_agx_0_mem_mem_dq[2]
set_location_assignment PIN_DP39 -to emif_agx_0_mem_mem_dq[1]
set_location_assignment PIN_DL36 -to emif_agx_0_mem_mem_dq[4]
set_location_assignment PIN_DM35 -to emif_agx_0_mem_mem_dq[5]
set_location_assignment PIN_DR36 -to emif_agx_0_mem_mem_dq[6]
set_location_assignment PIN_DP35 -to emif_agx_0_mem_mem_dq[7]
set_location_assignment PIN_DG36 -to emif_agx_0_mem_mem_dq[8]
set_location_assignment PIN_DF35 -to emif_agx_0_mem_mem_dq[9]
set_location_assignment PIN_DJ36 -to emif_agx_0_mem_mem_dq[11]
set_location_assignment PIN_DK35 -to emif_agx_0_mem_mem_dq[10]
set_location_assignment PIN_DG32 -to emif_agx_0_mem_mem_dq[15]
set_location_assignment PIN_DF31 -to emif_agx_0_mem_mem_dq[14]
set_location_assignment PIN_DJ32 -to emif_agx_0_mem_mem_dq[12]
set_location_assignment PIN_DK31 -to emif_agx_0_mem_mem_dq[13]
set_location_assignment PIN_DL34 -to emif_agx_0_mem_mem_dq[17]
set_location_assignment PIN_DM33 -to emif_agx_0_mem_mem_dq[16]
set_location_assignment PIN_DR34 -to emif_agx_0_mem_mem_dq[18]
set_location_assignment PIN_DP33 -to emif_agx_0_mem_mem_dq[19]
set_location_assignment PIN_DL30 -to emif_agx_0_mem_mem_dq[20]
set_location_assignment PIN_DM29 -to emif_agx_0_mem_mem_dq[23]
set_location_assignment PIN_DR30 -to emif_agx_0_mem_mem_dq[22]
set_location_assignment PIN_DP29 -to emif_agx_0_mem_mem_dq[21]
set_location_assignment PIN_DG30 -to emif_agx_0_mem_mem_dq[25]
set_location_assignment PIN_DF29 -to emif_agx_0_mem_mem_dq[27]
set_location_assignment PIN_DK29 -to emif_agx_0_mem_mem_dq[24]
set_location_assignment PIN_DJ30 -to emif_agx_0_mem_mem_dq[26]
set_location_assignment PIN_DG26 -to emif_agx_0_mem_mem_dq[30]
set_location_assignment PIN_DF25 -to emif_agx_0_mem_mem_dq[29]
set_location_assignment PIN_DJ26 -to emif_agx_0_mem_mem_dq[31]
set_location_assignment PIN_DK25 -to emif_agx_0_mem_mem_dq[28]
set_location_assignment PIN_DL22 -to emif_agx_0_mem_mem_dq[33]
set_location_assignment PIN_DM21 -to emif_agx_0_mem_mem_dq[35]
set_location_assignment PIN_DP21 -to emif_agx_0_mem_mem_dq[34]
set_location_assignment PIN_DR22 -to emif_agx_0_mem_mem_dq[32]
set_location_assignment PIN_DL18 -to emif_agx_0_mem_mem_dq[36]
set_location_assignment PIN_DM17 -to emif_agx_0_mem_mem_dq[39]
set_location_assignment PIN_DR18 -to emif_agx_0_mem_mem_dq[38]
set_location_assignment PIN_DP17 -to emif_agx_0_mem_mem_dq[37]
set_location_assignment PIN_DM27 -to emif_agx_0_mem_mem_dq[41]
set_location_assignment PIN_DL28 -to emif_agx_0_mem_mem_dq[42]
set_location_assignment PIN_DR28 -to emif_agx_0_mem_mem_dq[43]
set_location_assignment PIN_DP27 -to emif_agx_0_mem_mem_dq[40]
set_location_assignment PIN_DM23 -to emif_agx_0_mem_mem_dq[45]
set_location_assignment PIN_DL24 -to emif_agx_0_mem_mem_dq[47]
set_location_assignment PIN_DR24 -to emif_agx_0_mem_mem_dq[44]
set_location_assignment PIN_DP23 -to emif_agx_0_mem_mem_dq[46]
set_location_assignment PIN_DA24 -to emif_agx_0_mem_mem_dq[49]
set_location_assignment PIN_DB23 -to emif_agx_0_mem_mem_dq[51]
set_location_assignment PIN_DE24 -to emif_agx_0_mem_mem_dq[48]
set_location_assignment PIN_DD23 -to emif_agx_0_mem_mem_dq[50]
set_location_assignment PIN_DA20 -to emif_agx_0_mem_mem_dq[52]
set_location_assignment PIN_DB19 -to emif_agx_0_mem_mem_dq[55]
set_location_assignment PIN_DE20 -to emif_agx_0_mem_mem_dq[54]
set_location_assignment PIN_DD19 -to emif_agx_0_mem_mem_dq[53]
set_location_assignment PIN_DF23 -to emif_agx_0_mem_mem_dq[59]
set_location_assignment PIN_DK23 -to emif_agx_0_mem_mem_dq[57]
set_location_assignment PIN_DJ24 -to emif_agx_0_mem_mem_dq[56]
set_location_assignment PIN_DG24 -to emif_agx_0_mem_mem_dq[58]
set_location_assignment PIN_DG20 -to emif_agx_0_mem_mem_dq[60]
set_location_assignment PIN_DF19 -to emif_agx_0_mem_mem_dq[61]
set_location_assignment PIN_DJ20 -to emif_agx_0_mem_mem_dq[62]
set_location_assignment PIN_DK19 -to emif_agx_0_mem_mem_dq[63]
set_location_assignment PIN_DA30 -to emif_agx_0_mem_mem_dq[65]
set_location_assignment PIN_DB29 -to emif_agx_0_mem_mem_dq[64]
set_location_assignment PIN_DE30 -to emif_agx_0_mem_mem_dq[66]
set_location_assignment PIN_DD29 -to emif_agx_0_mem_mem_dq[67]
set_location_assignment PIN_DA26 -to emif_agx_0_mem_mem_dq[68]
set_location_assignment PIN_DB25 -to emif_agx_0_mem_mem_dq[69]
set_location_assignment PIN_DD25 -to emif_agx_0_mem_mem_dq[70]
set_location_assignment PIN_DE26 -to emif_agx_0_mem_mem_dq[71]

# Commented out pins for x4 RDIMM only. Comment them for x8 
set_location_assignment PIN_DR38 -to emif_agx_0_mem_mem_dqs_n[0]
set_location_assignment PIN_DP37 -to emif_agx_0_mem_mem_dqs[0]
#set_location_assignment PIN_DL38 -to emif_agx_0_mem_mem_dqs_n[1]
#set_location_assignment PIN_DM37 -to emif_agx_0_mem_mem_dqs[1]
set_location_assignment PIN_DJ34 -to emif_agx_0_mem_mem_dqs_n[1]
set_location_assignment PIN_DK33 -to emif_agx_0_mem_mem_dqs[1]
#set_location_assignment PIN_DG34 -to emif_agx_0_mem_mem_dqs_n[3]
#set_location_assignment PIN_DF33 -to emif_agx_0_mem_mem_dqs[3]
set_location_assignment PIN_DR32 -to emif_agx_0_mem_mem_dqs_n[2]
set_location_assignment PIN_DP31 -to emif_agx_0_mem_mem_dqs[2]
#set_location_assignment PIN_DL32 -to emif_agx_0_mem_mem_dqs_n[5]
#set_location_assignment PIN_DM31 -to emif_agx_0_mem_mem_dqs[5]
set_location_assignment PIN_DJ28 -to emif_agx_0_mem_mem_dqs_n[3]
set_location_assignment PIN_DK27 -to emif_agx_0_mem_mem_dqs[3]
#set_location_assignment PIN_DG28 -to emif_agx_0_mem_mem_dqs_n[7]
#set_location_assignment PIN_DF27 -to emif_agx_0_mem_mem_dqs[7]
set_location_assignment PIN_DP19 -to emif_agx_0_mem_mem_dqs_n[4]
set_location_assignment PIN_DR20 -to emif_agx_0_mem_mem_dqs[4]
#set_location_assignment PIN_DL20 -to emif_agx_0_mem_mem_dqs_n[9]
#set_location_assignment PIN_DM19 -to emif_agx_0_mem_mem_dqs[9]
set_location_assignment PIN_DR26 -to emif_agx_0_mem_mem_dqs_n[5]
set_location_assignment PIN_DP25 -to emif_agx_0_mem_mem_dqs[5]
#set_location_assignment PIN_DL26 -to emif_agx_0_mem_mem_dqs_n[11]
#set_location_assignment PIN_DM25 -to emif_agx_0_mem_mem_dqs[11]
set_location_assignment PIN_DE22 -to emif_agx_0_mem_mem_dqs_n[6]
set_location_assignment PIN_DD21 -to emif_agx_0_mem_mem_dqs[6]
#set_location_assignment PIN_DA22 -to emif_agx_0_mem_mem_dqs_n[13]
#set_location_assignment PIN_DB21 -to emif_agx_0_mem_mem_dqs[13]
set_location_assignment PIN_DJ22 -to emif_agx_0_mem_mem_dqs_n[7]
set_location_assignment PIN_DK21 -to emif_agx_0_mem_mem_dqs[7]
#set_location_assignment PIN_DF21 -to emif_agx_0_mem_mem_dqs_n[15]
#set_location_assignment PIN_DG22 -to emif_agx_0_mem_mem_dqs[15]
set_location_assignment PIN_DE28 -to emif_agx_0_mem_mem_dqs_n[8]
set_location_assignment PIN_DD27 -to emif_agx_0_mem_mem_dqs[8]
#set_location_assignment PIN_DA28 -to emif_agx_0_mem_mem_dqs_n[17]
#set_location_assignment PIN_DB27 -to emif_agx_0_mem_mem_dqs[17]

# KORUSYS x8 RDIMM
# DQSP9 on schematics
set_location_assignment PIN_DM37 -to emif_agx_0_mem_mem_dbi_n[0] 
# DQSP10 on schematics
set_location_assignment PIN_DF33 -to emif_agx_0_mem_mem_dbi_n[1]
# DQSP11 on schematics
set_location_assignment PIN_DM31 -to emif_agx_0_mem_mem_dbi_n[2]
# DQSP12 on schematics
set_location_assignment PIN_DF27 -to emif_agx_0_mem_mem_dbi_n[3]
# DQSP13 on schematics
set_location_assignment PIN_DM19 -to emif_agx_0_mem_mem_dbi_n[4]
# DQSP14 on schematics
set_location_assignment PIN_DM25 -to emif_agx_0_mem_mem_dbi_n[5]
# DQSP15 on schematics
set_location_assignment PIN_DB21 -to emif_agx_0_mem_mem_dbi_n[6]
# DQSP16 on schematics
set_location_assignment PIN_DG22 -to emif_agx_0_mem_mem_dbi_n[7]
# DQSP17 on schematics
set_location_assignment PIN_DB27 -to emif_agx_0_mem_mem_dbi_n[8]



set_location_assignment PIN_DD35 -to emif_agx_0_pll_ref_clk_clk[0]
#set_location_assignment PIN_DD31 -to emif_agx_0_mem_mem_a[17]
set_location_assignment PIN_DA34 -to emif_agx_0_mem_mem_a[16]
set_location_assignment PIN_DB33 -to emif_agx_0_mem_mem_a[15]
set_location_assignment PIN_DA36 -to emif_agx_0_mem_mem_a[12]
set_location_assignment PIN_DE34 -to emif_agx_0_mem_mem_a[14]
set_location_assignment PIN_DD33 -to emif_agx_0_mem_mem_a[13]
set_location_assignment PIN_CU36 -to emif_agx_0_mem_mem_a[11]
set_location_assignment PIN_CT35 -to emif_agx_0_mem_mem_a[10]
set_location_assignment PIN_CW36 -to emif_agx_0_mem_mem_a[9]
set_location_assignment PIN_CY35 -to emif_agx_0_mem_mem_a[8]
set_location_assignment PIN_CU38 -to emif_agx_0_mem_mem_a[7]
set_location_assignment PIN_CT37 -to emif_agx_0_mem_mem_a[6]
set_location_assignment PIN_CT39 -to emif_agx_0_mem_mem_a[3]
set_location_assignment PIN_CU40 -to emif_agx_0_mem_mem_a[2]
set_location_assignment PIN_CW40 -to emif_agx_0_mem_mem_a[1]
set_location_assignment PIN_CY39 -to emif_agx_0_mem_mem_a[0]
set_location_assignment PIN_CW38 -to emif_agx_0_mem_mem_a[5]
set_location_assignment PIN_CY37 -to emif_agx_0_mem_mem_a[4]
set_location_assignment PIN_CP37 -to emif_agx_0_mem_mem_odt[0]
set_location_assignment PIN_CM37 -to emif_agx_0_mem_mem_cke[0]
set_location_assignment PIN_CL40 -to emif_agx_0_mem_mem_act_n
set_location_assignment PIN_CM39 -to emif_agx_0_mem_mem_cs_n[0]
set_location_assignment PIN_CP39 -to emif_agx_0_mem_mem_reset_n[0]
set_location_assignment PIN_CR36 -to emif_agx_0_mem_mem_ck_n[0]
set_location_assignment PIN_CP35 -to emif_agx_0_mem_mem_ck[0]
set_location_assignment PIN_CL36 -to emif_agx_0_mem_mem_par[0]
set_location_assignment PIN_CY29 -to emif_agx_0_mem_mem_alert_n[0]
set_location_assignment PIN_DB35 -to emif_agx_0_oct_oct_rzqin[0]
set_location_assignment PIN_CR40 -to emif_agx_0_mem_mem_bg[1]
set_location_assignment PIN_DA32 -to emif_agx_0_mem_mem_bg[0]
set_location_assignment PIN_DB31 -to emif_agx_0_mem_mem_ba[1]
set_location_assignment PIN_DE32 -to emif_agx_0_mem_mem_ba[0]

#set_location_assignment PIN_CU30 -to emif_agx_0_mem_mem_ck_n[1]
#set_location_assignment PIN_CT29 -to emif_agx_0_mem_mem_ck[1]
#set_location_assignment PIN_CM35 -to emif_agx_0_mem_mem_cs_n[1]
#set_location_assignment PIN_CL38 -to emif_agx_0_mem_mem_cke[1]
#set_location_assignment PIN_CR38 -to emif_agx_0_mem_mem_odt[1]



set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_ref_clk
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tck
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tms
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tdo
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tdi
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_jtag_tdo
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_jtag_tck
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_jtag_tms
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_jtag_tdi
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdmmc_CMD
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdmmc_CCLK
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_sdmmc_CMD
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_sdmmc_CCLK
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdmmc_CMD
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdmmc_D0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_sdmmc_D0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdmmc_D0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdmmc_D1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_sdmmc_D1
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdmmc_D1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdmmc_D2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_sdmmc_D2
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdmmc_D2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdmmc_D3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_sdmmc_D3
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdmmc_D3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_STP
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DIR
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_NXT
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_STP
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_CLK
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DIR
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_NXT
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA1
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA2
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA3
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA4
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA4
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA4
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA5
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA5
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA5
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA6
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA6
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA6
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DATA7
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb0_DATA7
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb0_DATA7
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RX_CTL
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac0_TX_CLK
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac0_TX_CTL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_RX_CLK
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_RX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac0_TXD0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac0_TXD1
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac0_TXD2
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac0_TXD3
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_MDIO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_MDC
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac0_MDIO
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac0_MDC
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_emac0_MDIO
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac0_MDIO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_uart0_TX
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_uart0_RX
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_uart0_TX
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_uart0_RX
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_i2c1_SDA
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_i2c1_SCL
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_i2c1_SDA
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_i2c1_SCL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_i2c1_SDA
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_i2c1_SCL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_i2c1_SDA
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_i2c1_SCL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io0
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io1
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io1
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io4
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io4
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io4
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io5
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io5
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io5
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io19
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io19
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io19
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io20
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io20
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io20
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io21
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io21
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio1_io21

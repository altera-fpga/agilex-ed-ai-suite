################################################################################
#
# SoC Pins
#
################################################################################

set_location_assignment PIN_AV21 -to fpga_reset_n


#Group0
set_location_assignment PIN_AF10 -to mem_dq[0]
set_location_assignment PIN_AD10 -to mem_dq[1]
set_location_assignment PIN_AC11 -to mem_dq[2]
set_location_assignment PIN_AD8 -to mem_dq[3]
set_location_assignment PIN_AC9 -to mem_dq[4]
set_location_assignment PIN_AC8 -to mem_dq[5]
set_location_assignment PIN_AE10 -to mem_dq[6]
set_location_assignment PIN_AD9 -to mem_dq[7]

set_location_assignment PIN_AF8 -to mem_dqs[0]
set_location_assignment PIN_AE8 -to mem_dqs_n[0]

set_location_assignment PIN_AE11 -to mem_dm[0]



#Group1
set_location_assignment PIN_AK8 -to mem_dq[8]
set_location_assignment PIN_AL8 -to mem_dq[9]
set_location_assignment PIN_AK10 -to mem_dq[10]
set_location_assignment PIN_AL9 -to mem_dq[11]
set_location_assignment PIN_AN6 -to mem_dq[12]
set_location_assignment PIN_AK7 -to mem_dq[13]
set_location_assignment PIN_AM9 -to mem_dq[14]
set_location_assignment PIN_AL7 -to mem_dq[15]

set_location_assignment PIN_AN7 -to mem_dqs[1]
set_location_assignment PIN_AM7 -to mem_dqs_n[1]

set_location_assignment PIN_AM6 -to mem_dm[1]



#Group 2
set_location_assignment PIN_AR3 -to mem_dq[16]
set_location_assignment PIN_AU2 -to mem_dq[17]
set_location_assignment PIN_AP4 -to mem_dq[18]
set_location_assignment PIN_AP3 -to mem_dq[19]
set_location_assignment PIN_AN4 -to mem_dq[20]
set_location_assignment PIN_AU1 -to mem_dq[21]
set_location_assignment PIN_AP5 -to mem_dq[22]
set_location_assignment PIN_AT3 -to mem_dq[23]

set_location_assignment PIN_AR5 -to mem_dqs[2]
set_location_assignment PIN_AP6 -to mem_dqs_n[2]

set_location_assignment PIN_AM5 -to mem_dm[2]


#Group 3
set_location_assignment PIN_AU4 -to mem_dq[24]
set_location_assignment PIN_AW5 -to mem_dq[25]
set_location_assignment PIN_AU5 -to mem_dq[26]
set_location_assignment PIN_AV4 -to mem_dq[27]
set_location_assignment PIN_AW4 -to mem_dq[28]
set_location_assignment PIN_AR6 -to mem_dq[29]
set_location_assignment PIN_AR7 -to mem_dq[30]
set_location_assignment PIN_AT5 -to mem_dq[31]

set_location_assignment PIN_AW6 -to mem_dqs[3]
set_location_assignment PIN_AV6 -to mem_dqs_n[3]

set_location_assignment PIN_AT4 -to mem_dm[3]



#Group 4
set_location_assignment PIN_Y8 -to mem_dq[32]
set_location_assignment PIN_AB11 -to mem_dq[33]
set_location_assignment PIN_AB10 -to mem_dq[34]
set_location_assignment PIN_AB9 -to mem_dq[35]
set_location_assignment PIN_W8 -to mem_dq[36]
set_location_assignment PIN_Y10 -to mem_dq[37]
set_location_assignment PIN_AA9 -to mem_dq[38]
set_location_assignment PIN_AB7 -to mem_dq[39]

set_location_assignment PIN_AA7 -to mem_dqs[4]
set_location_assignment PIN_AA8 -to mem_dqs_n[4]

set_location_assignment PIN_AA10 -to mem_dm[4]



#Group 5
set_location_assignment PIN_Y6 -to mem_dq[40]
set_location_assignment PIN_Y7 -to mem_dq[41]
set_location_assignment PIN_AA5 -to mem_dq[42]
set_location_assignment PIN_Y5 -to mem_dq[43]
set_location_assignment PIN_AD4 -to mem_dq[44]
set_location_assignment PIN_AC6 -to mem_dq[45]
set_location_assignment PIN_AD5 -to mem_dq[46]
set_location_assignment PIN_AB6 -to mem_dq[47]

set_location_assignment PIN_AE5 -to mem_dqs[5]
set_location_assignment PIN_AE6 -to mem_dqs_n[5]

set_location_assignment PIN_AB5 -to mem_dm[5]



#Group 6
set_location_assignment PIN_AB4 -to mem_dq[48]
set_location_assignment PIN_W1 -to mem_dq[49]
set_location_assignment PIN_Y1 -to mem_dq[50]
set_location_assignment PIN_AA4 -to mem_dq[51]
set_location_assignment PIN_Y3 -to mem_dq[52]
set_location_assignment PIN_AB1 -to mem_dq[53]
set_location_assignment PIN_Y2 -to mem_dq[54]
set_location_assignment PIN_AC4 -to mem_dq[55]

set_location_assignment PIN_AA2 -to mem_dqs[6]
set_location_assignment PIN_AA3 -to mem_dqs_n[6]

set_location_assignment PIN_AB2 -to mem_dm[6]



#Group 7
set_location_assignment PIN_AE3 -to mem_dq[56]
set_location_assignment PIN_AE2 -to mem_dq[57]
set_location_assignment PIN_AE1 -to mem_dq[58]
set_location_assignment PIN_AF3 -to mem_dq[59]
set_location_assignment PIN_AG2 -to mem_dq[60]
set_location_assignment PIN_AF2 -to mem_dq[61]
set_location_assignment PIN_AD3 -to mem_dq[62]
set_location_assignment PIN_AD1 -to mem_dq[63]

set_location_assignment PIN_AH1 -to mem_dqs[7]
set_location_assignment PIN_AG1 -to mem_dqs_n[7]

set_location_assignment PIN_AC1 -to mem_dm[7]


# ###########ADDRESS, CLK, RZQ and REF Clock pins##################
set_location_assignment PIN_AH7 -to mem_oct_rzqin

set_location_assignment PIN_AN3 -to mem_a[0]
set_location_assignment PIN_AM4 -to mem_a[1]
set_location_assignment PIN_AL3 -to mem_a[2]
set_location_assignment PIN_AL4 -to mem_a[3]
set_location_assignment PIN_AL5 -to mem_a[4]
set_location_assignment PIN_AK5 -to mem_a[5]
set_location_assignment PIN_AK6 -to mem_a[6]
set_location_assignment PIN_AJ6 -to mem_a[7]
set_location_assignment PIN_AK3 -to mem_a[8]
set_location_assignment PIN_AJ4 -to mem_a[9]
set_location_assignment PIN_AJ5 -to mem_a[10]
set_location_assignment PIN_AH6 -to mem_a[11]
set_location_assignment PIN_AG7 -to mem_a[12]
set_location_assignment PIN_AJ3 -to mem_a[13]
set_location_assignment PIN_AH3 -to mem_a[14]
set_location_assignment PIN_AF7 -to mem_a[15]
set_location_assignment PIN_AE7 -to mem_a[16]

set_location_assignment PIN_AF5 -to mem_ba[0]
set_location_assignment PIN_AH4 -to mem_ba[1]
set_location_assignment PIN_AG4 -to mem_bg[0]

set_location_assignment PIN_AK1 -to mem_ck[0]
set_location_assignment PIN_AK2 -to mem_ck_n[0]
set_location_assignment PIN_AM1 -to mem_cke[0]

set_location_assignment PIN_AM2 -to mem_cs_n[0]
set_location_assignment PIN_AL2 -to mem_act_n[0]
set_location_assignment PIN_AR1 -to mem_odt[0]
set_location_assignment PIN_AN2 -to mem_reset_n[0]
set_location_assignment PIN_AH2 -to mem_par[0]

set_location_assignment PIN_AF9 -to mem_alert_n[0]

set_location_assignment PIN_AG6 -to "mem_clk(n)"
set_location_assignment PIN_AG5 -to mem_clk

set_location_assignment PIN_AM10 -to fpga_clk_100


# ######################################################################
# HPS pin allocation
# ######################################################################

# memory assignments from GHRD in embedded examples folder

set_location_assignment PIN_F25 -to emif_ref_clk
set_location_assignment PIN_G24 -to "emif_ref_clk(n)"
set_location_assignment PIN_E26 -to hps_memory_oct_rzqin
set_instance_assignment -name IO_STANDARD LVDS -to emif_ref_clk 
set_instance_assignment -name IO_STANDARD LVDS -to "emif_ref_clk(n)" 
set_location_assignment PIN_AG24 -to hps_memory_mem_alert_n[0]

set_location_assignment PIN_H18 -to hps_emac0_TX_CLK
set_location_assignment PIN_H19 -to hps_emac0_TX_CTL
set_location_assignment PIN_E20 -to hps_emac0_TXD0
set_location_assignment PIN_F20 -to hps_emac0_TXD1
set_location_assignment PIN_F19 -to hps_emac0_TXD2
set_location_assignment PIN_G19 -to hps_emac0_TXD3
set_location_assignment PIN_F18 -to hps_emac0_RX_CLK
set_location_assignment PIN_G17 -to hps_emac0_RX_CTL
set_location_assignment PIN_G20 -to hps_emac0_RXD0
set_location_assignment PIN_G21 -to hps_emac0_RXD1
set_location_assignment PIN_F22 -to hps_emac0_RXD2
set_location_assignment PIN_G22 -to hps_emac0_RXD3
set_location_assignment PIN_K20 -to hps_emac0_MDC
set_location_assignment PIN_K21 -to hps_emac0_MDIO
set_location_assignment PIN_B21 -to hps_memory_mem_act_n[0]
set_location_assignment PIN_J24 -to hps_memory_mem_bg[0]
set_location_assignment PIN_A18 -to hps_memory_mem_par[0]
set_location_assignment PIN_B26 -to hps_memory_mem_a[0]
set_location_assignment PIN_C26 -to hps_memory_mem_a[1]
set_location_assignment PIN_C22 -to hps_memory_mem_a[2]
set_location_assignment PIN_C21 -to hps_memory_mem_a[3]
set_location_assignment PIN_C25 -to hps_memory_mem_a[4]
set_location_assignment PIN_B24 -to hps_memory_mem_a[5]
set_location_assignment PIN_B22 -to hps_memory_mem_a[6]
set_location_assignment PIN_C23 -to hps_memory_mem_a[7]
set_location_assignment PIN_D23 -to hps_memory_mem_a[8]
set_location_assignment PIN_E23 -to hps_memory_mem_a[9]
set_location_assignment PIN_C24 -to hps_memory_mem_a[10]
set_location_assignment PIN_D24 -to hps_memory_mem_a[11]
set_location_assignment PIN_F26 -to hps_memory_mem_a[12]
set_location_assignment PIN_G26 -to hps_memory_mem_a[13]
set_location_assignment PIN_G25 -to hps_memory_mem_a[14]
set_location_assignment PIN_F24 -to hps_memory_mem_a[15]
set_location_assignment PIN_F23 -to hps_memory_mem_a[16]
set_location_assignment PIN_E25 -to hps_memory_mem_ba[0]
set_location_assignment PIN_H24 -to hps_memory_mem_ba[1]
set_location_assignment PIN_B20 -to hps_memory_mem_ck[0]
set_location_assignment PIN_B19 -to hps_memory_mem_ck_n[0]
set_location_assignment PIN_A24 -to hps_memory_mem_cke[0]
set_location_assignment PIN_A22 -to hps_memory_mem_cs_n[0]
set_location_assignment PIN_A19 -to hps_memory_mem_reset_n[0]
set_location_assignment PIN_A26 -to hps_memory_mem_odt[0]
set_location_assignment PIN_AN26 -to hps_memory_mem_dbi_n[0]
set_location_assignment PIN_AU25 -to hps_memory_mem_dbi_n[1]
set_location_assignment PIN_AV26 -to hps_memory_mem_dbi_n[2]
set_location_assignment PIN_AH25 -to hps_memory_mem_dbi_n[3]
set_location_assignment PIN_AP26 -to hps_memory_mem_dq[0]
set_location_assignment PIN_AN24 -to hps_memory_mem_dq[1]
set_location_assignment PIN_AN23 -to hps_memory_mem_dq[2]
set_location_assignment PIN_AM24 -to hps_memory_mem_dq[3]
set_location_assignment PIN_AK26 -to hps_memory_mem_dq[4]
set_location_assignment PIN_AL23 -to hps_memory_mem_dq[5]
set_location_assignment PIN_AL26 -to hps_memory_mem_dq[6]
set_location_assignment PIN_AK23 -to hps_memory_mem_dq[7]
set_location_assignment PIN_AP23 -to hps_memory_mem_dq[8]
set_location_assignment PIN_AT26 -to hps_memory_mem_dq[9]
set_location_assignment PIN_AR26 -to hps_memory_mem_dq[10]
set_location_assignment PIN_AR25 -to hps_memory_mem_dq[11]
set_location_assignment PIN_AT23 -to hps_memory_mem_dq[12]
set_location_assignment PIN_AP25 -to hps_memory_mem_dq[13]
set_location_assignment PIN_AU24 -to hps_memory_mem_dq[14]
set_location_assignment PIN_AU26 -to hps_memory_mem_dq[15]
set_location_assignment PIN_AU28 -to hps_memory_mem_dq[16]
set_location_assignment PIN_AU27 -to hps_memory_mem_dq[17]
set_location_assignment PIN_AV23 -to hps_memory_mem_dq[18]
set_location_assignment PIN_AW28 -to hps_memory_mem_dq[19]
set_location_assignment PIN_AV24 -to hps_memory_mem_dq[20]
set_location_assignment PIN_AW24 -to hps_memory_mem_dq[21]
set_location_assignment PIN_AV28 -to hps_memory_mem_dq[22]
set_location_assignment PIN_AV27 -to hps_memory_mem_dq[23]
set_location_assignment PIN_AH24 -to hps_memory_mem_dq[24]
set_location_assignment PIN_AH23 -to hps_memory_mem_dq[25]
set_location_assignment PIN_AG25 -to hps_memory_mem_dq[26]
set_location_assignment PIN_AF24 -to hps_memory_mem_dq[27]
set_location_assignment PIN_AF25 -to hps_memory_mem_dq[28]
set_location_assignment PIN_AJ24 -to hps_memory_mem_dq[29]
set_location_assignment PIN_AJ23 -to hps_memory_mem_dq[30]
set_location_assignment PIN_AJ26 -to hps_memory_mem_dq[31]
set_location_assignment PIN_AM25 -to hps_memory_mem_dqs[0]
set_location_assignment PIN_AT25 -to hps_memory_mem_dqs[1]
set_location_assignment PIN_AW26 -to hps_memory_mem_dqs[2]
set_location_assignment PIN_AK25 -to hps_memory_mem_dqs[3]
set_location_assignment PIN_AL25 -to hps_memory_mem_dqs_n[0]
set_location_assignment PIN_AT24 -to hps_memory_mem_dqs_n[1]
set_location_assignment PIN_AW25 -to hps_memory_mem_dqs_n[2]
set_location_assignment PIN_AJ25 -to hps_memory_mem_dqs_n[3]
set_location_assignment PIN_K16 -to hps_sdio_CLK
set_location_assignment PIN_H16 -to hps_sdio_CMD
set_location_assignment PIN_E16 -to hps_sdio_D0
set_location_assignment PIN_G16 -to hps_sdio_D1
set_location_assignment PIN_H17 -to hps_sdio_D2
set_location_assignment PIN_F15 -to hps_sdio_D3
set_location_assignment PIN_M19 -to hps_sdio_D4
set_location_assignment PIN_E15 -to hps_sdio_D5
set_location_assignment PIN_J16 -to hps_sdio_D6
set_location_assignment PIN_L18 -to hps_sdio_D7
set_location_assignment PIN_D18 -to hps_usb0_CLK
set_location_assignment PIN_C19 -to hps_usb0_DIR
set_location_assignment PIN_F17 -to hps_usb0_NXT
set_location_assignment PIN_E18 -to hps_usb0_STP
set_location_assignment PIN_D19 -to hps_usb0_D0
set_location_assignment PIN_E17 -to hps_usb0_D1
set_location_assignment PIN_C17 -to hps_usb0_D2
set_location_assignment PIN_C18 -to hps_usb0_D3
set_location_assignment PIN_D21 -to hps_usb0_D4
set_location_assignment PIN_D20 -to hps_usb0_D5
set_location_assignment PIN_E21 -to hps_usb0_D6
set_location_assignment PIN_E22 -to hps_usb0_D7
set_location_assignment PIN_K18 -to hps_spim1_CLK
set_location_assignment PIN_L19 -to hps_spim1_MOSI
set_location_assignment PIN_H22 -to hps_spim1_MISO
set_location_assignment PIN_H21 -to hps_spim1_SS0_N
set_location_assignment PIN_J21 -to hps_spim1_SS1_N
set_location_assignment PIN_M17 -to hps_uart1_TX
set_location_assignment PIN_K17 -to hps_uart1_RX
set_location_assignment PIN_L20 -to hps_i2c1_SDA
set_location_assignment PIN_M20 -to hps_i2c1_SCL
set_location_assignment PIN_J20 -to hps_gpio_GPIO05
set_location_assignment PIN_N20 -to hps_gpio_GPIO14
set_location_assignment PIN_K23 -to hps_gpio_GPIO16
set_location_assignment PIN_L23 -to hps_gpio_GPIO17
set_location_assignment PIN_N22 -to hps_gpio_GPIO19
set_location_assignment PIN_P20 -to hps_trace_CLK
set_location_assignment PIN_K22 -to hps_trace_D0
set_location_assignment PIN_L22 -to hps_trace_D1
set_location_assignment PIN_M22 -to hps_trace_D2
set_location_assignment PIN_M21 -to hps_trace_D3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_CMD
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D4
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D5
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D6
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_sdio_D7
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_TXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_MDC
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac0_MDIO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_spim1_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_spim1_MOSI
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_spim1_MISO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_spim1_SS0_N
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_spim1_SS1_N
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_uart1_TX
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_uart1_RX
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_DIR
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_NXT
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_STP
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D4
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D5
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D6
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb0_D7
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_i2c1_SDA
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_i2c1_SCL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio_GPIO05
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio_GPIO14
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio_GPIO16
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio_GPIO17
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio_GPIO19
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_trace_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_trace_D0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_trace_D1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_trace_D2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_trace_D3
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to hps_sdio_CLK
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to hps_sdio_CMD
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to hps_sdio_D0
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to hps_sdio_D1
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to hps_sdio_D2
set_instance_assignment -name CURRENT_STRENGTH_NEW "MAXIMUM CURRENT" -to hps_sdio_D3
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdio_D4
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdio_D5
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdio_D6
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_sdio_D7
set_instance_assignment -name SLEW_RATE 1 -to hps_sdio_CLK
set_instance_assignment -name SLEW_RATE 1 -to hps_sdio_CMD
set_instance_assignment -name SLEW_RATE 1 -to hps_sdio_D0
set_instance_assignment -name SLEW_RATE 1 -to hps_sdio_D1
set_instance_assignment -name SLEW_RATE 1 -to hps_sdio_D2
set_instance_assignment -name SLEW_RATE 1 -to hps_sdio_D3
set_instance_assignment -name OUTPUT_DELAY_CHAIN 8 -to hps_emac0_TX_CLK

set_instance_assignment -name IO_STANDARD LVDS -to mem_clk -entity top
set_instance_assignment -name IO_STANDARD LVDS -to "mem_clk(n)" -entity top
set_instance_assignment -name IO_STANDARD "1.8 V" -to fpga_reset_n -entity top
set_instance_assignment -name IO_STANDARD LVDS -to fpga_clk_100 -entity top
set_instance_assignment -name INPUT_TERMINATION DIFFERENTIAL -to fpga_clk_100 -entity top

# Clocks and resets
set_location_assignment PIN_BK31 -to fpga_clk_100
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to fpga_clk_100
set_location_assignment PIN_BU28 -to fpga_reset_n
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to fpga_reset_n

# HPS EMIF
set_location_assignment PIN_AK111 -to hps_emif_mem_oct_rzqin
set_location_assignment PIN_AB117 -to hps_emif_mem_ref_clk

# FPGA EMIF
set_location_assignment PIN_BR52 -to fpga_emif_mem_oct_rzqin
set_location_assignment PIN_BR49 -to fpga_emif_mem_ref_clk
set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to fpga_emif_mem_ref_clk

# Buttons / LEDs / DIP switches removed: top.v ports commented out.
# Bank 3A_T assignments conflicted with HPS DDR ECC balls on production MDK.

# HPS
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_osc_clk
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tck
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tms
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tdo
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tdi
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_jtag_tdo
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_jtag_tck
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_jtag_tms
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_jtag_tdi
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_STP
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DIR
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_NXT
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_STP
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_CLK
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DIR
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_NXT
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA1
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA2
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA3
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA4
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA4
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA4
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA5
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA5
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA5
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA6
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA6
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA6
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA7
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA7
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_usb1_DATA7
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RX_CTL
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac2_TX_CLK
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TX_CTL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_RX_CLK
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_RX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD1
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD2
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD3
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_MDIO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_MDC
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac2_MDIO
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac2_MDC
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_emac2_MDIO
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_emac2_MDIO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_uart0_TX
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_uart0_RX
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_uart0_TX
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_uart0_RX
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_i2c_emac1_SDA
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_i2c_emac1_SCL
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_i2c_emac1_SDA
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_i2c_emac1_SCL
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_i2c_emac1_SDA
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_i2c_emac1_SCL
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_i2c_emac1_SDA
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_i2c_emac1_SCL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio0_io0
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio0_io0
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio0_io0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio0_io10
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio0_io10
set_instance_assignment -name WEAK_PULL_UP_RESISTOR ON -to hps_gpio0_io10
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io3
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io4
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io4

# Fitter Assignments
set_location_assignment PIN_CL23 -to fpga_emif_mem_dq[31] -comment IOBANK_2B_T
set_location_assignment PIN_F84 -to hps_emif_mem_dq[29] -comment IOBANK_3A_T
set_location_assignment PIN_H117 -to hps_emif_mem_reset_n -comment IOBANK_3A_B
set_location_assignment PIN_CL8 -to fpga_emif_mem_dq[30] -comment IOBANK_2B_T
set_location_assignment PIN_M98 -to hps_emif_mem_dq[28] -comment IOBANK_3A_T
set_location_assignment PIN_K108 -to hps_emif_mem_par -comment IOBANK_3A_B
set_location_assignment PIN_CK26 -to fpga_emif_mem_dq[29] -comment IOBANK_2B_T
set_location_assignment PIN_M87 -to hps_emif_mem_dq[27] -comment IOBANK_3A_T
set_location_assignment PIN_Y108 -to hps_emif_mem_alert_n -comment IOBANK_3A_B
set_location_assignment PIN_CL6 -to fpga_emif_mem_dq[28] -comment IOBANK_2B_T
set_location_assignment PIN_H98 -to hps_emif_mem_dq[26] -comment IOBANK_3A_T
# Removed (HPS ECC conflict on 3A_T):
# PIN_A97/B101/A110 fpga_button_pio[1:3]
# PIN_A106/A101/B88/A94 fpga_dipsw_pio[0:3]
set_location_assignment PIN_CF52 -to fpga_emif_mem_a[0] -comment IOBANK_2B_B
set_location_assignment PIN_CH52 -to fpga_emif_mem_a[1] -comment IOBANK_2B_B
set_location_assignment PIN_CC52 -to fpga_emif_mem_a[2] -comment IOBANK_2B_B
set_location_assignment PIN_CA52 -to fpga_emif_mem_a[3] -comment IOBANK_2B_B
set_location_assignment PIN_CF49 -to fpga_emif_mem_a[4] -comment IOBANK_2B_B
set_location_assignment PIN_CH49 -to fpga_emif_mem_a[5] -comment IOBANK_2B_B
set_location_assignment PIN_CH41 -to fpga_emif_mem_a[6] -comment IOBANK_2B_B
set_location_assignment PIN_CF41 -to fpga_emif_mem_a[7] -comment IOBANK_2B_B
set_location_assignment PIN_CC41 -to fpga_emif_mem_a[8] -comment IOBANK_2B_B
set_location_assignment PIN_CA41 -to fpga_emif_mem_a[9] -comment IOBANK_2B_B
set_location_assignment PIN_CH38 -to fpga_emif_mem_a[10] -comment IOBANK_2B_B
set_location_assignment PIN_CF38 -to fpga_emif_mem_a[11] -comment IOBANK_2B_B
set_location_assignment PIN_BU52 -to fpga_emif_mem_a[12] -comment IOBANK_2B_B
set_location_assignment PIN_BW49 -to fpga_emif_mem_a[13] -comment IOBANK_2B_B
set_location_assignment PIN_CA49 -to fpga_emif_mem_a[14] -comment IOBANK_2B_B
set_location_assignment PIN_BR41 -to fpga_emif_mem_a[15] -comment IOBANK_2B_B
set_location_assignment PIN_BU41 -to fpga_emif_mem_a[16] -comment IOBANK_2B_B
set_location_assignment PIN_CL45 -to fpga_emif_mem_act_n -comment IOBANK_2B_B
set_location_assignment PIN_BR38 -to fpga_emif_mem_alert_n -comment IOBANK_2B_B
set_location_assignment PIN_BU38 -to fpga_emif_mem_ba[0] -comment IOBANK_2B_B
set_location_assignment PIN_CA38 -to fpga_emif_mem_ba[1] -comment IOBANK_2B_B
set_location_assignment PIN_BW38 -to fpga_emif_mem_bg[0] -comment IOBANK_2B_B
set_location_assignment PIN_CL42 -to fpga_emif_mem_bg[1] -comment IOBANK_2B_B
set_location_assignment PIN_CL30 -to fpga_emif_mem_ck_c -comment IOBANK_2B_B
set_location_assignment PIN_CK33 -to fpga_emif_mem_ck_t -comment IOBANK_2B_B
set_location_assignment PIN_CK35 -to fpga_emif_mem_cke -comment IOBANK_2B_B
set_location_assignment PIN_CK48 -to fpga_emif_mem_cs_n -comment IOBANK_2B_B
set_location_assignment PIN_BP41 -to fpga_emif_mem_dbi_n[0] -comment IOBANK_2B_T
set_location_assignment PIN_CL56 -to fpga_emif_mem_dbi_n[1] -comment IOBANK_2B_B
set_location_assignment PIN_BF57 -to fpga_emif_mem_dbi_n[2] -comment IOBANK_2B_T
set_location_assignment PIN_CL14 -to fpga_emif_mem_dbi_n[3] -comment IOBANK_2B_T
set_location_assignment PIN_BK38 -to fpga_emif_mem_dq[0] -comment IOBANK_2B_T
set_location_assignment PIN_BH49 -to fpga_emif_mem_dq[1] -comment IOBANK_2B_T
set_location_assignment PIN_BH41 -to fpga_emif_mem_dq[2] -comment IOBANK_2B_T
set_location_assignment PIN_BH52 -to fpga_emif_mem_dq[3] -comment IOBANK_2B_T
set_location_assignment PIN_BH38 -to fpga_emif_mem_dq[4] -comment IOBANK_2B_T
set_location_assignment PIN_BP52 -to fpga_emif_mem_dq[5] -comment IOBANK_2B_T
set_location_assignment PIN_BM38 -to fpga_emif_mem_dq[6] -comment IOBANK_2B_T
set_location_assignment PIN_BM52 -to fpga_emif_mem_dq[7] -comment IOBANK_2B_T
set_location_assignment PIN_CL51 -to fpga_emif_mem_dq[8] -comment IOBANK_2B_B
set_location_assignment PIN_CK66 -to fpga_emif_mem_dq[9] -comment IOBANK_2B_B
set_location_assignment PIN_CK54 -to fpga_emif_mem_dq[10] -comment IOBANK_2B_B
set_location_assignment PIN_CL73 -to fpga_emif_mem_dq[11] -comment IOBANK_2B_B
set_location_assignment PIN_CL54 -to fpga_emif_mem_dq[12] -comment IOBANK_2B_B
set_location_assignment PIN_CK73 -to fpga_emif_mem_dq[13] -comment IOBANK_2B_B
set_location_assignment PIN_CK56 -to fpga_emif_mem_dq[14] -comment IOBANK_2B_B
set_location_assignment PIN_CL70 -to fpga_emif_mem_dq[15] -comment IOBANK_2B_B
set_location_assignment PIN_BF50 -to fpga_emif_mem_dq[16] -comment IOBANK_2B_T
set_location_assignment PIN_BF64 -to fpga_emif_mem_dq[17] -comment IOBANK_2B_T
set_location_assignment PIN_BE50 -to fpga_emif_mem_dq[18] -comment IOBANK_2B_T
set_location_assignment PIN_BF68 -to fpga_emif_mem_dq[19] -comment IOBANK_2B_T
set_location_assignment PIN_BE46 -to fpga_emif_mem_dq[20] -comment IOBANK_2B_T
set_location_assignment PIN_BE64 -to fpga_emif_mem_dq[21] -comment IOBANK_2B_T
set_location_assignment PIN_BF46 -to fpga_emif_mem_dq[22] -comment IOBANK_2B_T
set_location_assignment PIN_BE68 -to fpga_emif_mem_dq[23] -comment IOBANK_2B_T
set_location_assignment PIN_CK8 -to fpga_emif_mem_dq[24] -comment IOBANK_2B_T
set_location_assignment PIN_CK20 -to fpga_emif_mem_dq[25] -comment IOBANK_2B_T
set_location_assignment PIN_CK11 -to fpga_emif_mem_dq[26] -comment IOBANK_2B_T
set_location_assignment PIN_CL20 -to fpga_emif_mem_dq[27] -comment IOBANK_2B_T
set_location_assignment PIN_BM49 -to fpga_emif_mem_dqs_c[0] -comment IOBANK_2B_T
set_location_assignment PIN_CL66 -to fpga_emif_mem_dqs_c[1] -comment IOBANK_2B_B
set_location_assignment PIN_BE57 -to fpga_emif_mem_dqs_c[2] -comment IOBANK_2B_T
set_location_assignment PIN_CL17 -to fpga_emif_mem_dqs_c[3] -comment IOBANK_2B_T
set_location_assignment PIN_BK49 -to fpga_emif_mem_dqs_t[0] -comment IOBANK_2B_T
set_location_assignment PIN_CK63 -to fpga_emif_mem_dqs_t[1] -comment IOBANK_2B_B
set_location_assignment PIN_BE61 -to fpga_emif_mem_dqs_t[2] -comment IOBANK_2B_T
set_location_assignment PIN_CK17 -to fpga_emif_mem_dqs_t[3] -comment IOBANK_2B_T
set_location_assignment PIN_CK39 -to fpga_emif_mem_odt -comment IOBANK_2B_B
set_location_assignment PIN_CL26 -to fpga_emif_mem_par -comment IOBANK_2B_B
set_location_assignment PIN_CK45 -to fpga_emif_mem_reset_n -comment IOBANK_2B_B
# Removed (HPS ECC conflict on 3A_T): PIN_B106/B91/A91 fpga_led_pio[1:3]
set_location_assignment PIN_T114 -to hps_emif_mem_a[0] -comment IOBANK_3A_B
set_location_assignment PIN_P114 -to hps_emif_mem_a[1] -comment IOBANK_3A_B
set_location_assignment PIN_V117 -to hps_emif_mem_a[2] -comment IOBANK_3A_B
set_location_assignment PIN_T117 -to hps_emif_mem_a[3] -comment IOBANK_3A_B
set_location_assignment PIN_M114 -to hps_emif_mem_a[4] -comment IOBANK_3A_B
set_location_assignment PIN_K114 -to hps_emif_mem_a[5] -comment IOBANK_3A_B
set_location_assignment PIN_V108 -to hps_emif_mem_a[6] -comment IOBANK_3A_B
set_location_assignment PIN_T108 -to hps_emif_mem_a[7] -comment IOBANK_3A_B
set_location_assignment PIN_T105 -to hps_emif_mem_a[8] -comment IOBANK_3A_B
set_location_assignment PIN_P105 -to hps_emif_mem_a[9] -comment IOBANK_3A_B
set_location_assignment PIN_M105 -to hps_emif_mem_a[10] -comment IOBANK_3A_B
set_location_assignment PIN_K105 -to hps_emif_mem_a[11] -comment IOBANK_3A_B
set_location_assignment PIN_AG111 -to hps_emif_mem_a[12] -comment IOBANK_3A_B
set_location_assignment PIN_Y114 -to hps_emif_mem_a[13] -comment IOBANK_3A_B
set_location_assignment PIN_AB114 -to hps_emif_mem_a[14] -comment IOBANK_3A_B
set_location_assignment PIN_AK107 -to hps_emif_mem_a[15] -comment IOBANK_3A_B
set_location_assignment PIN_AK104 -to hps_emif_mem_a[16] -comment IOBANK_3A_B
set_location_assignment PIN_M117 -to hps_emif_mem_act_n -comment IOBANK_3A_B
set_location_assignment PIN_AB108 -to hps_emif_mem_ba[0] -comment IOBANK_3A_B
set_location_assignment PIN_Y105 -to hps_emif_mem_ba[1] -comment IOBANK_3A_B
set_location_assignment PIN_AB105 -to hps_emif_mem_bg[0] -comment IOBANK_3A_B
set_location_assignment PIN_F117 -to hps_emif_mem_bg[1] -comment IOBANK_3A_B
set_location_assignment PIN_F108 -to hps_emif_mem_ck_c -comment IOBANK_3A_B
set_location_assignment PIN_H108 -to hps_emif_mem_ck_t -comment IOBANK_3A_B
set_location_assignment PIN_F105 -to hps_emif_mem_cke -comment IOBANK_3A_B
set_location_assignment PIN_K117 -to hps_emif_mem_cs_n -comment IOBANK_3A_B
set_location_assignment PIN_A128 -to hps_emif_mem_dq[0] -comment IOBANK_3A_B
set_location_assignment PIN_A113 -to hps_emif_mem_dq[1] -comment IOBANK_3A_B
set_location_assignment PIN_B128 -to hps_emif_mem_dq[2] -comment IOBANK_3A_B
set_location_assignment PIN_B113 -to hps_emif_mem_dq[3] -comment IOBANK_3A_B
set_location_assignment PIN_A130 -to hps_emif_mem_dq[4] -comment IOBANK_3A_B
set_location_assignment PIN_A116 -to hps_emif_mem_dq[5] -comment IOBANK_3A_B
set_location_assignment PIN_B130 -to hps_emif_mem_dq[6] -comment IOBANK_3A_B
set_location_assignment PIN_B116 -to hps_emif_mem_dq[7] -comment IOBANK_3A_B
set_location_assignment PIN_AC96 -to hps_emif_mem_dq[8] -comment IOBANK_3A_T
set_location_assignment PIN_Y95 -to hps_emif_mem_dq[9] -comment IOBANK_3A_T
set_location_assignment PIN_Y98 -to hps_emif_mem_dq[10] -comment IOBANK_3A_T
set_location_assignment PIN_AG104 -to hps_emif_mem_dq[11] -comment IOBANK_3A_T
set_location_assignment PIN_AC100 -to hps_emif_mem_dq[12] -comment IOBANK_3A_T
set_location_assignment PIN_Y87 -to hps_emif_mem_dq[13] -comment IOBANK_3A_T
set_location_assignment PIN_AG100 -to hps_emif_mem_dq[14] -comment IOBANK_3A_T
set_location_assignment PIN_Y84 -to hps_emif_mem_dq[15] -comment IOBANK_3A_T
set_location_assignment PIN_V98 -to hps_emif_mem_dq[16] -comment IOBANK_3A_T
set_location_assignment PIN_P84 -to hps_emif_mem_dq[17] -comment IOBANK_3A_T
set_location_assignment PIN_T95 -to hps_emif_mem_dq[18] -comment IOBANK_3A_T
set_location_assignment PIN_T84 -to hps_emif_mem_dq[19] -comment IOBANK_3A_T
set_location_assignment PIN_T98 -to hps_emif_mem_dq[20] -comment IOBANK_3A_T
set_location_assignment PIN_M84 -to hps_emif_mem_dq[21] -comment IOBANK_3A_T
set_location_assignment PIN_P95 -to hps_emif_mem_dq[22] -comment IOBANK_3A_T
set_location_assignment PIN_K84 -to hps_emif_mem_dq[23] -comment IOBANK_3A_T
set_location_assignment PIN_K98 -to hps_emif_mem_dq[24] -comment IOBANK_3A_T
set_location_assignment PIN_K87 -to hps_emif_mem_dq[25] -comment IOBANK_3A_T
set_location_assignment PIN_F98 -to hps_emif_mem_dq[30] -comment IOBANK_3A_T
set_location_assignment PIN_D84 -to hps_emif_mem_dq[31] -comment IOBANK_3A_T
set_location_assignment PIN_A125 -to hps_emif_mem_dqs_c[0] -comment IOBANK_3A_B
set_location_assignment PIN_AG93 -to hps_emif_mem_dqs_c[1] -comment IOBANK_3A_T
set_location_assignment PIN_M95 -to hps_emif_mem_dqs_c[2] -comment IOBANK_3A_T
set_location_assignment PIN_D95 -to hps_emif_mem_dqs_c[3] -comment IOBANK_3A_T
set_location_assignment PIN_B122 -to hps_emif_mem_dqs_t[0] -comment IOBANK_3A_B
set_location_assignment PIN_AG90 -to hps_emif_mem_dqs_t[1] -comment IOBANK_3A_T
set_location_assignment PIN_K95 -to hps_emif_mem_dqs_t[2] -comment IOBANK_3A_T
set_location_assignment PIN_F95 -to hps_emif_mem_dqs_t[3] -comment IOBANK_3A_T
set_location_assignment PIN_F114 -to hps_emif_mem_odt -comment IOBANK_3A_B

# Fitter Voltages for fpga_led/dipsw/button_pio removed (ports no longer in top.v)

# FPGA EMIF 2 - Bank 3B (from Robo board_subsystem.qsf)
set_location_assignment PIN_P74  -to bank_3b_mem_a[0]     -comment IOBANK_3B
set_location_assignment PIN_T65  -to bank_3b_mem_a[10]    -comment IOBANK_3B
set_location_assignment PIN_P65  -to bank_3b_mem_a[11]    -comment IOBANK_3B
set_location_assignment PIN_AG79 -to bank_3b_mem_a[12]    -comment IOBANK_3B
set_location_assignment PIN_AG72 -to bank_3b_mem_a[13]    -comment IOBANK_3B
set_location_assignment PIN_AG75 -to bank_3b_mem_a[14]    -comment IOBANK_3B
set_location_assignment PIN_AG83 -to bank_3b_mem_a[15]    -comment IOBANK_3B
set_location_assignment PIN_AC83 -to bank_3b_mem_a[16]    -comment IOBANK_3B
set_location_assignment PIN_T74  -to bank_3b_mem_a[1]     -comment IOBANK_3B
set_location_assignment PIN_V77  -to bank_3b_mem_a[2]     -comment IOBANK_3B
set_location_assignment PIN_T77  -to bank_3b_mem_a[3]     -comment IOBANK_3B
set_location_assignment PIN_M74  -to bank_3b_mem_a[4]     -comment IOBANK_3B
set_location_assignment PIN_K74  -to bank_3b_mem_a[5]     -comment IOBANK_3B
set_location_assignment PIN_V67  -to bank_3b_mem_a[6]     -comment IOBANK_3B
set_location_assignment PIN_T67  -to bank_3b_mem_a[7]     -comment IOBANK_3B
set_location_assignment PIN_M65  -to bank_3b_mem_a[8]     -comment IOBANK_3B
set_location_assignment PIN_K65  -to bank_3b_mem_a[9]     -comment IOBANK_3B
set_location_assignment PIN_H77  -to bank_3b_mem_act_n    -comment IOBANK_3B
set_location_assignment PIN_Y77  -to bank_3b_mem_alert_n  -comment IOBANK_3B
set_location_assignment PIN_Y74  -to bank_3b_mem_ba[0]    -comment IOBANK_3B
set_location_assignment PIN_Y67  -to bank_3b_mem_ba[1]    -comment IOBANK_3B
set_location_assignment PIN_Y65  -to bank_3b_mem_bg[0]    -comment IOBANK_3B
set_location_assignment PIN_K77  -to bank_3b_mem_bg[1]    -comment IOBANK_3B
set_location_assignment PIN_H67  -to bank_3b_mem_ck[0]    -comment IOBANK_3B
set_location_assignment PIN_F67  -to bank_3b_mem_ck_n[0]  -comment IOBANK_3B
set_location_assignment PIN_M67  -to bank_3b_mem_cke[0]   -comment IOBANK_3B
set_location_assignment PIN_F77  -to bank_3b_mem_cs_n[0]  -comment IOBANK_3B
set_location_assignment PIN_B73  -to bank_3b_mem_dbi_n[0] -comment IOBANK_3B
set_location_assignment PIN_AC53 -to bank_3b_mem_dbi_n[1] -comment IOBANK_3B
set_location_assignment PIN_V47  -to bank_3b_mem_dbi_n[2] -comment IOBANK_3B
set_location_assignment PIN_M47  -to bank_3b_mem_dbi_n[3] -comment IOBANK_3B
set_location_assignment PIN_B51  -to bank_3b_mem_dbi_n[4] -comment IOBANK_3B
set_location_assignment PIN_B82  -to bank_3b_mem_dq[0]    -comment IOBANK_3B
set_location_assignment PIN_AC61 -to bank_3b_mem_dq[10]   -comment IOBANK_3B
set_location_assignment PIN_Y55  -to bank_3b_mem_dq[11]   -comment IOBANK_3B
set_location_assignment PIN_AC64 -to bank_3b_mem_dq[12]   -comment IOBANK_3B
set_location_assignment PIN_AG61 -to bank_3b_mem_dq[13]   -comment IOBANK_3B
set_location_assignment PIN_AG64 -to bank_3b_mem_dq[14]   -comment IOBANK_3B
set_location_assignment PIN_Y44  -to bank_3b_mem_dq[15]   -comment IOBANK_3B
set_location_assignment PIN_P55  -to bank_3b_mem_dq[16]   -comment IOBANK_3B
set_location_assignment PIN_T55  -to bank_3b_mem_dq[17]   -comment IOBANK_3B
set_location_assignment PIN_V58  -to bank_3b_mem_dq[18]   -comment IOBANK_3B
set_location_assignment PIN_T58  -to bank_3b_mem_dq[19]   -comment IOBANK_3B
set_location_assignment PIN_A66  -to bank_3b_mem_dq[1]    -comment IOBANK_3B
set_location_assignment PIN_P44  -to bank_3b_mem_dq[20]   -comment IOBANK_3B
set_location_assignment PIN_T44  -to bank_3b_mem_dq[21]   -comment IOBANK_3B
set_location_assignment PIN_K44  -to bank_3b_mem_dq[22]   -comment IOBANK_3B
set_location_assignment PIN_M44  -to bank_3b_mem_dq[23]   -comment IOBANK_3B
set_location_assignment PIN_H58  -to bank_3b_mem_dq[24]   -comment IOBANK_3B
set_location_assignment PIN_F58  -to bank_3b_mem_dq[25]   -comment IOBANK_3B
set_location_assignment PIN_M58  -to bank_3b_mem_dq[26]   -comment IOBANK_3B
set_location_assignment PIN_K58  -to bank_3b_mem_dq[27]   -comment IOBANK_3B
set_location_assignment PIN_F47  -to bank_3b_mem_dq[28]   -comment IOBANK_3B
set_location_assignment PIN_H47  -to bank_3b_mem_dq[29]   -comment IOBANK_3B
set_location_assignment PIN_A82  -to bank_3b_mem_dq[2]    -comment IOBANK_3B
set_location_assignment PIN_D44  -to bank_3b_mem_dq[30]   -comment IOBANK_3B
set_location_assignment PIN_F44  -to bank_3b_mem_dq[31]   -comment IOBANK_3B
set_location_assignment PIN_B56  -to bank_3b_mem_dq[32]   -comment IOBANK_3B
set_location_assignment PIN_B45  -to bank_3b_mem_dq[33]   -comment IOBANK_3B
set_location_assignment PIN_A60  -to bank_3b_mem_dq[34]   -comment IOBANK_3B
set_location_assignment PIN_A48  -to bank_3b_mem_dq[35]   -comment IOBANK_3B
set_location_assignment PIN_B60  -to bank_3b_mem_dq[36]   -comment IOBANK_3B
set_location_assignment PIN_B42  -to bank_3b_mem_dq[37]   -comment IOBANK_3B
set_location_assignment PIN_A63  -to bank_3b_mem_dq[38]   -comment IOBANK_3B
set_location_assignment PIN_A45  -to bank_3b_mem_dq[39]   -comment IOBANK_3B
set_location_assignment PIN_A70  -to bank_3b_mem_dq[3]    -comment IOBANK_3B
set_location_assignment PIN_A85  -to bank_3b_mem_dq[4]    -comment IOBANK_3B
set_location_assignment PIN_B66  -to bank_3b_mem_dq[5]    -comment IOBANK_3B
set_location_assignment PIN_B85  -to bank_3b_mem_dq[6]    -comment IOBANK_3B
set_location_assignment PIN_B70  -to bank_3b_mem_dq[7]    -comment IOBANK_3B
set_location_assignment PIN_Y58  -to bank_3b_mem_dq[8]    -comment IOBANK_3B
set_location_assignment PIN_Y47  -to bank_3b_mem_dq[9]    -comment IOBANK_3B
set_location_assignment PIN_A80  -to bank_3b_mem_dqs[0]   -comment IOBANK_3B
set_location_assignment PIN_AG57 -to bank_3b_mem_dqs[1]   -comment IOBANK_3B
set_location_assignment PIN_K55  -to bank_3b_mem_dqs[2]   -comment IOBANK_3B
set_location_assignment PIN_F55  -to bank_3b_mem_dqs[3]   -comment IOBANK_3B
set_location_assignment PIN_A54  -to bank_3b_mem_dqs[4]   -comment IOBANK_3B
set_location_assignment PIN_B76  -to bank_3b_mem_dqs_n[0] -comment IOBANK_3B
set_location_assignment PIN_AG53 -to bank_3b_mem_dqs_n[1] -comment IOBANK_3B
set_location_assignment PIN_M55  -to bank_3b_mem_dqs_n[2] -comment IOBANK_3B
set_location_assignment PIN_D55  -to bank_3b_mem_dqs_n[3] -comment IOBANK_3B
set_location_assignment PIN_B54  -to bank_3b_mem_dqs_n[4] -comment IOBANK_3B
set_location_assignment PIN_AC79 -to bank_3b_mem_oct_rzqin -comment IOBANK_3B
set_location_assignment PIN_D74  -to bank_3b_mem_odt[0]   -comment IOBANK_3B
set_location_assignment PIN_D65  -to bank_3b_mem_par      -comment IOBANK_3B
set_location_assignment PIN_AC68 -to bank_3b_mem_pll_ref_clk -comment IOBANK_3B
set_location_assignment PIN_M77  -to bank_3b_mem_reset_n  -comment IOBANK_3B
set_instance_assignment -name IO_STANDARD "1.2-V" -to bank_3b_mem_alert_n  
set_instance_assignment -name IO_STANDARD "1.2-V" -to bank_3b_mem_oct_rzqin
set_instance_assignment -name IO_STANDARD "1.2-V TRUE DIFFERENTIAL SIGNALING" -to bank_3b_mem_pll_ref_clk
set_instance_assignment -name IO_STANDARD "1.2-V TRUE DIFFERENTIAL SIGNALING" -to "bank_3b_mem_pll_ref_clk(n)"
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[0] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[10]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[11]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[12]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[13]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[14]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[15]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[16]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[1] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[2] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[3] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[4] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[5] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[6] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[7] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[8] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_a[9] 
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_act_n
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_ba[0]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_ba[1]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_bg[0]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_bg[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to bank_3b_mem_ck[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V SSTL" -to bank_3b_mem_ck_n[0]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_cke[0]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_cs_n[0]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_odt[0]
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_par
set_instance_assignment -name IO_STANDARD "SSTL-12" -to bank_3b_mem_reset_n
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dbi_n[0]
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dbi_n[1]
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dbi_n[2]
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dbi_n[3]
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dbi_n[4]
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[0]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[10]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[11]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[12]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[13]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[14]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[15]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[16]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[17]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[18]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[19]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[1]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[20]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[21]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[22]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[23]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[24]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[25]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[26]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[27]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[28]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[29]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[2]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[30]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[31]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[32]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[33]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[34]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[35]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[36]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[37]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[38]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[39]  
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[3]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[4]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[5]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[6]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[7]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[8]   
set_instance_assignment -name IO_STANDARD "1.2-V POD" -to bank_3b_mem_dq[9]   
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs[0]  
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs[1]  
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs[2]  
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs[3]  
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs[4]  
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs_n[0]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs_n[1]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs_n[2]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs_n[3]
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.2-V POD" -to bank_3b_mem_dqs_n[4]
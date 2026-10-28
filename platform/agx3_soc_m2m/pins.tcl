# Clocks and resets
set_location_assignment PIN_AJ27 -to fpga_clk_100
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to fpga_clk_100
set_location_assignment PIN_M1 -to fpga_reset_n
set_instance_assignment -name IO_STANDARD "1.1-V" -to fpga_reset_n

# Buttons
set_location_assignment PIN_L1 -to fpga_button_pio[0]

# LEDs
set_location_assignment PIN_K1 -to fpga_led_pio[0]
set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to fpga_led_pio[0]
set_location_assignment PIN_L2 -to fpga_led_pio[1]
set_instance_assignment -name CURRENT_STRENGTH_NEW 12MA -to fpga_led_pio[1]

# HPS
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_osc_clk
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_jtag_tck
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tms
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tdo
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_jtag_tdi
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_jtag_tdo
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_jtag_tck
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_jtag_tms
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_jtag_tdi
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_STP
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DIR
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_NXT
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_STP
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_CLK
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DIR
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_NXT
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA0
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA1
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA2
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA3
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA4
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA4
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA4
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA5
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA5
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA5
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA6
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA6
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA6
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_usb1_DATA7
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_usb1_DATA7
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_usb1_DATA7
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RX_CLK
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RX_CTL
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac2_TX_CLK
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TX_CTL
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_RX_CLK
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_RX_CTL
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD0
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD0
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_RXD0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD1
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD1
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_RXD1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD2
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD2
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_RXD2
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_TXD3
set_instance_assignment -name CURRENT_STRENGTH_NEW 8MA -to hps_emac2_TXD3
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_RXD3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_MDIO
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_emac2_MDC
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac2_MDIO
set_instance_assignment -name CURRENT_STRENGTH_NEW 4MA -to hps_emac2_MDC
set_instance_assignment -name AUTO_OPEN_DRAIN_PINS ON -to hps_emac2_MDIO
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_emac2_MDIO
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
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_gpio0_io0
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio0_io1
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio0_io1
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_gpio0_io1
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio0_io11
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio0_io11
set_instance_assignment -name WEAK_PULL_UP_DN_SEL PULL_UP_20 -to hps_gpio0_io11
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io3
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io3
set_instance_assignment -name IO_STANDARD "1.8 V" -to hps_gpio1_io4
set_instance_assignment -name CURRENT_STRENGTH_NEW 2MA -to hps_gpio1_io4

# Fitter Assignments

# FPGA EMIF

set_location_assignment PIN_AB1 -to fpga_emif_mem_dq[0] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[0]
set_location_assignment PIN_AA2 -to fpga_emif_mem_dq[1] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[1]
set_location_assignment PIN_AA1 -to fpga_emif_mem_dq[2] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[2]
set_location_assignment PIN_Y2 -to fpga_emif_mem_dq[3] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[3]
set_location_assignment PIN_AG1 -to fpga_emif_mem_dq[4] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[4]
set_location_assignment PIN_AF2 -to fpga_emif_mem_dq[5] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[5]
set_location_assignment PIN_AF1 -to fpga_emif_mem_dq[6] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[6]
set_location_assignment PIN_AE2 -to fpga_emif_mem_dq[7] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[7]
set_location_assignment PIN_AK6 -to fpga_emif_mem_dq[8] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[8]
set_location_assignment PIN_AK7 -to fpga_emif_mem_dq[9] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[9]
set_location_assignment PIN_AJ7 -to fpga_emif_mem_dq[10] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[10]
set_location_assignment PIN_AJ8 -to fpga_emif_mem_dq[11] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[11]
set_location_assignment PIN_AG3 -to fpga_emif_mem_dq[12] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[12]
set_location_assignment PIN_AH2 -to fpga_emif_mem_dq[13] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[13]
set_location_assignment PIN_AH3 -to fpga_emif_mem_dq[14] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[14]
set_location_assignment PIN_AJ3 -to fpga_emif_mem_dq[15] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[15]
set_location_assignment PIN_P4 -to fpga_emif_mem_dq[16] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[16]
set_location_assignment PIN_P5 -to fpga_emif_mem_dq[17] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[17]
set_location_assignment PIN_U3 -to fpga_emif_mem_dq[18] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[18]
set_location_assignment PIN_V3 -to fpga_emif_mem_dq[19] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[19]
set_location_assignment PIN_W3 -to fpga_emif_mem_dq[20] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[20]
set_location_assignment PIN_U4 -to fpga_emif_mem_dq[21] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[21]
set_location_assignment PIN_P3 -to fpga_emif_mem_dq[22] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[22]
set_location_assignment PIN_N3 -to fpga_emif_mem_dq[23] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[23]
set_location_assignment PIN_V5 -to fpga_emif_mem_dq[24] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[24]
set_location_assignment PIN_V6 -to fpga_emif_mem_dq[25] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[25]
set_location_assignment PIN_N7 -to fpga_emif_mem_dq[26] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[26]
set_location_assignment PIN_N6 -to fpga_emif_mem_dq[27] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[27]
set_location_assignment PIN_R7 -to fpga_emif_mem_dq[28] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[28]
set_location_assignment PIN_P7 -to fpga_emif_mem_dq[29] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[29]
set_location_assignment PIN_W5 -to fpga_emif_mem_dq[30] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[30]
set_location_assignment PIN_U6 -to fpga_emif_mem_dq[31] -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_dq[31]

set_location_assignment PIN_AC1 -to fpga_emif_mem_dqs_p[0] -comment IOBANK_2A
set_location_assignment PIN_AK4 -to fpga_emif_mem_dqs_p[1] -comment IOBANK_2A
set_location_assignment PIN_U5 -to fpga_emif_mem_dqs_p[2] -comment IOBANK_2A
set_location_assignment PIN_R5 -to fpga_emif_mem_dqs_p[3] -comment IOBANK_2A

set_location_assignment PIN_AC2 -to fpga_emif_mem_dqs_n[0] -comment IOBANK_2A
set_location_assignment PIN_AJ4 -to fpga_emif_mem_dqs_n[1] -comment IOBANK_2A
set_location_assignment PIN_T4 -to fpga_emif_mem_dqs_n[2] -comment IOBANK_2A
set_location_assignment PIN_R6 -to fpga_emif_mem_dqs_n[3] -comment IOBANK_2A

set_location_assignment PIN_AD2 -to fpga_emif_mem_dmi[0] -comment IOBANK_2A
set_location_assignment PIN_AJ5 -to fpga_emif_mem_dmi[1] -comment IOBANK_2A
set_location_assignment PIN_T3 -to fpga_emif_mem_dmi[2] -comment IOBANK_2A
set_location_assignment PIN_T6 -to fpga_emif_mem_dmi[3] -comment IOBANK_2A

set_location_assignment PIN_AF3 -to fpga_emif_mem_refclk_p -comment IOBANK_2A
#set_instance_assignment -name IO_STANDARD "1.1V TRUE DIFFERENTIAL SIGNALING" -to fpga_emif_mem_refclk_p
set_location_assignment PIN_AD3 -to fpga_emif_mem_rzq -comment IOBANK_2A
#set_instance_assignment -name IO_STANDARD "1.1 V" -to fpga_emif_mem_rzq

set_location_assignment PIN_AF7 -to fpga_emif_mem_ca[0]
set_location_assignment PIN_AE7 -to fpga_emif_mem_ca[1]
set_location_assignment PIN_AF6 -to fpga_emif_mem_ca[2]
set_location_assignment PIN_AE6 -to fpga_emif_mem_ca[3]
set_location_assignment PIN_AH5 -to fpga_emif_mem_ca[4]
set_location_assignment PIN_AG5 -to fpga_emif_mem_ca[5]

set_location_assignment PIN_AD4 -to fpga_emif_mem_reset_n -comment IOBANK_2A

set_location_assignment PIN_AH6 -to fpga_emif_mem_cke -comment IOBANK_2A

set_location_assignment PIN_AA4 -to fpga_emif_mem_ck_n -comment IOBANK_2A
set_location_assignment PIN_AB3 -to fpga_emif_mem_ck_p -comment IOBANK_2A
set_location_assignment PIN_AF4 -to fpga_emif_mem_cs_n -comment IOBANK_2A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to fpga_emif_mem_cs_n

# HPS EMIF

set_location_assignment PIN_E9 -to hps_emif_mem_ck_p -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_ck_p
set_location_assignment PIN_E10 -to hps_emif_mem_ck_n -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_ck_n
set_location_assignment PIN_A4 -to hps_emif_mem_cke -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_cke
set_location_assignment PIN_E15 -to hps_emif_mem_reset_n -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_reset_n
set_location_assignment PIN_C7 -to hps_emif_mem_cs_n -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_cs_n

set_location_assignment PIN_C2 -to hps_emif_mem_ca[0]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_ca[0]
set_location_assignment PIN_D3 -to hps_emif_mem_ca[1]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_ca[1]
set_location_assignment PIN_C3 -to hps_emif_mem_ca[2]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_ca[2]
set_location_assignment PIN_B3 -to hps_emif_mem_ca[3]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_ca[3]
set_location_assignment PIN_A6 -to hps_emif_mem_ca[4]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_ca[4]
set_location_assignment PIN_B5 -to hps_emif_mem_ca[5]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_ca[5]

set_location_assignment PIN_H6 -to hps_emif_mem_dq[0] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[0]
set_location_assignment PIN_H7 -to hps_emif_mem_dq[1] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[1]
set_location_assignment PIN_G5 -to hps_emif_mem_dq[2] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[2]
set_location_assignment PIN_G6 -to hps_emif_mem_dq[3] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[3]
set_location_assignment PIN_M6 -to hps_emif_mem_dq[4] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[4]
set_location_assignment PIN_N5 -to hps_emif_mem_dq[5] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[5]
set_location_assignment PIN_M5 -to hps_emif_mem_dq[6] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[6]
set_location_assignment PIN_L6 -to hps_emif_mem_dq[7] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[7]
set_location_assignment PIN_L3 -to hps_emif_mem_dq[8] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[8]
set_location_assignment PIN_J5 -to hps_emif_mem_dq[9] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[9]
set_location_assignment PIN_M3 -to hps_emif_mem_dq[10] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[10]
set_location_assignment PIN_L4 -to hps_emif_mem_dq[11] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[11]
set_location_assignment PIN_M4 -to hps_emif_mem_dq[12] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[12]
set_location_assignment PIN_G4 -to hps_emif_mem_dq[13] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[13]
set_location_assignment PIN_H3 -to hps_emif_mem_dq[14] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[14]
set_location_assignment PIN_H5 -to hps_emif_mem_dq[15] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[15]
set_location_assignment PIN_D15 -to hps_emif_mem_dq[16] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[16]
set_location_assignment PIN_C13 -to hps_emif_mem_dq[17] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[17]
set_location_assignment PIN_C10 -to hps_emif_mem_dq[18] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[18]
set_location_assignment PIN_D10 -to hps_emif_mem_dq[19] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[19]
set_location_assignment PIN_C8 -to hps_emif_mem_dq[20] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[20]
set_location_assignment PIN_D9 -to hps_emif_mem_dq[21] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[21]
set_location_assignment PIN_D14 -to hps_emif_mem_dq[22] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[22]
set_location_assignment PIN_C15 -to hps_emif_mem_dq[23] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[23]
set_location_assignment PIN_A8 -to hps_emif_mem_dq[24] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[24]
set_location_assignment PIN_B8 -to hps_emif_mem_dq[25] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[25]
set_location_assignment PIN_A9 -to hps_emif_mem_dq[26] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[26]
set_location_assignment PIN_B9 -to hps_emif_mem_dq[27] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[27]
set_location_assignment PIN_B13 -to hps_emif_mem_dq[28] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[28]
set_location_assignment PIN_A13 -to hps_emif_mem_dq[29] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[29]
set_location_assignment PIN_B14 -to hps_emif_mem_dq[30] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[30]
set_location_assignment PIN_A14 -to hps_emif_mem_dq[31] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dq[31]

set_location_assignment PIN_B6 -to "hps_emif_mem_ref_clk(n)"
set_location_assignment PIN_A7 -to hps_emif_mem_ref_clk

set_location_assignment PIN_L7 -to hps_emif_mem_dmi[0]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dmi[0]
set_location_assignment PIN_K5 -to hps_emif_mem_dmi[1]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dmi[1]
set_location_assignment PIN_D13 -to hps_emif_mem_dmi[2]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dmi[2]
set_location_assignment PIN_B11 -to hps_emif_mem_dmi[3]
set_instance_assignment -name IO_STANDARD "1.1-V LVSTL" -to hps_emif_mem_dmi[3]

set_location_assignment PIN_B10 -to hps_emif_mem_dqs_p[3] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_p[3]
set_location_assignment PIN_A11 -to hps_emif_mem_dqs_n[3] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_n[3]
set_location_assignment PIN_K7 -to hps_emif_mem_dqs_p[0] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_p[0]
set_location_assignment PIN_J7 -to hps_emif_mem_dqs_n[0] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_n[0]
set_location_assignment PIN_J4 -to hps_emif_mem_dqs_p[1] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_p[1]
set_location_assignment PIN_D12 -to hps_emif_mem_dqs_p[2] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_p[2]
set_location_assignment PIN_J3 -to hps_emif_mem_dqs_n[1] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_n[1]
set_location_assignment PIN_C11 -to hps_emif_mem_dqs_n[2] -comment IOBANK_3A
set_instance_assignment -name IO_STANDARD "DIFFERENTIAL 1.1-V LVSTL" -to hps_emif_mem_dqs_n[2]
set_location_assignment PIN_E14 -to hps_emif_mem_oct_rzqin
set_instance_assignment -name IO_STANDARD "1.1-V" -to hps_emif_mem_oct_rzqin

# Fitter Voltages
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_sdmmc_CMD
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_sdmmc_D0
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_sdmmc_D1
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_sdmmc_D2
set_instance_assignment -name IO_STANDARD "1.8-V" -to hps_sdmmc_D3

set_instance_assignment -name IO_STANDARD "1.1-V" -to fpga_button_pio[0]

set_instance_assignment -name IO_STANDARD "1.1-V" -to fpga_led_pio[0]
set_instance_assignment -name SLEW_RATE 0 -to fpga_led_pio[0]
set_instance_assignment -name IO_STANDARD "1.1-V" -to fpga_led_pio[1]
set_instance_assignment -name SLEW_RATE 0 -to fpga_led_pio[1]

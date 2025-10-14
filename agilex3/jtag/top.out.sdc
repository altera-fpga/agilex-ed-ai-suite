## Generated SDC file "top.out.sdc"

## Copyright (C) 2024  Altera Corporation. All rights reserved.
## Your use of Altera Corporation's design tools, logic functions
## and other software and tools, and any partner logic
## functions, and any output files from any of the foregoing
## (including device programming or simulation files), and any
## associated documentation or information are expressly subject
## to the terms and conditions of the Altera Program License
## Subscription Agreement, the Altera Quartus Prime License Agreement,
## the Altera FPGA IP License Agreement, or other applicable license
## agreement, including, without limitation, that your use is for
## the sole purpose of programming logic devices manufactured by
## Altera and sold by Altera or its authorized distributors.  Please
## refer to the Altera FPGA Software License Subscription Agreements
## on the Quartus Prime software download page.


################## Source JTAG-related SDCs #############
source ./jtag_example.sdc
#########################################################

#**************************************************************
# Time Information
#**************************************************************

set_time_format -unit ns -decimal_places 3



#**************************************************************
# Create Clock
#**************************************************************

# create_clock -name {dla_ref_clk_100mhz} -period 10.000 -waveform { 0.000 5.000 } [get_ports {i_hvio6c_pllrefclk1}]
# create_clock -name {ddr_ref_clk_100hmz} -period 10.000 -waveform { 0.000 5.000 } [get_ports {i_ddr4_comp1_refclk_p}]


#**************************************************************
# Create Generated Clock
#**************************************************************

#create_generated_clock -name {pd|user_pll|altera_iopll_inst_n_cnt_clk} -source [get_ports {i_axi_ref_clk}] -duty_cycle 50/1 -multiply_by 1 -divide_by 2 -master_clock {pd|user_pll|altera_iopll_inst_refclk}
#create_generated_clock -name {pd|user_pll|altera_iopll_inst_m_cnt_clk} -duty_cycle 50/1 -multiply_by 1 -divide_by 32 -master_clock {pd|user_pll|altera_iopll_inst_n_cnt_clk}
#create_generated_clock -name {pd|user_pll|altera_iopll_inst_outclk0} -duty_cycle 50/1 -multiply_by 16 -divide_by 16 -master_clock {pd|user_pll|altera_iopll_inst_n_cnt_clk} [get_pins {pd|user_pll|altera_iopll_inst|tennm_ph2_iopll|out_clk[0]}]
# create_generated_clock -name {pd|shell_pll_0|csr_clk_100mhz} -source [get_ports {i_hvio6c_pllrefclk1}] -multiply_by 1 -divide_by 1 -master_clock {dla_ref_clk_100mhz} [get_ports {pd|shell_pll_0|outclk_1}]
# create_generated_clock -name {pd|shell_pll_0|dla_clk_400mhz} -source [get_ports {i_hvio6c_pllrefclk1}] -multiply_by 4 -divide_by 1 -master_clock {dla_ref_clk_100mhz} [get_ports {pd|shell_pll_0|outclk_0}]
# create_generated_clock -name {pd|emif|emif_clk_200mhz}       -source [get_ports {i_ddr4_comp1_refclk_p}] -multiply_by 2 -divide_by 1 -master_clock {ddr_ref_clk_100hmz} [get_ports {pd|emif_ph2_0|emif_ph2_0_usr_clk_0_clk}]

#**************************************************************
# Set Clock Latency
#**************************************************************



#**************************************************************
# Set Clock Uncertainty
#**************************************************************



#**************************************************************
# Set Input Delay
#**************************************************************



#**************************************************************
# Set Output Delay
#**************************************************************



#**************************************************************
# Set Clock Groups
#**************************************************************



#**************************************************************
# Set False Path
#**************************************************************
# TODO: add more false paths

#**************************************************************
# Set Multicycle Path
#**************************************************************



#**************************************************************
# Set Maximum Delay
#**************************************************************



#**************************************************************
# Set Minimum Delay
#**************************************************************



#**************************************************************
# Set Input Transition
#**************************************************************


#****************************************************************************
#
# SPDX-License-Identifier: MIT-0
# Copyright(c) 2019-2026 Altera Corporation.
#
#****************************************************************************
#
# SDC for Agilex 5 SoC M2M DLA platform.
#
#****************************************************************************

# Set the default time format
set_time_format -unit ns -decimal_places 3

# 100MHz board input clock, 150MHz for EMIF refclk
create_clock -name MAIN_CLOCK -period 10 [get_ports fpga_clk_100]
create_clock -name HPS_EMIF_REF_CLOCK -period 150MHz [get_ports hps_emif_mem_ref_clk]
create_clock -name FPGA_EMIF_REF_CLOCK -period 150MHz [get_ports fpga_emif_mem_ref_clk]

set_false_path -from [get_ports {fpga_reset_n}]

# FPGA IO port constraints
set_false_path -from [get_ports {fpga_user_push_buttons[0]}] -to *
set_false_path -from [get_ports {fpga_user_switches[0]}] -to *
set_false_path -from [get_ports {fpga_user_switches[1]}] -to *
set_false_path -from * -to [get_ports {fpga_user_leds[0]}]
set_output_delay -clock MAIN_CLOCK 5 [get_ports {fpga_user_leds[0]}]
set_false_path -from [get_registers {blink_100[25]}] -to *

# Set multicycle path for warm_reset_handshake signal
set_multicycle_path 2 -setup -from [get_registers {*|agx5_hps|agx5_hps|sm_hps|sundancemesa_hps_inst~intosc_clk.reg}] -to [get_registers {*|agx5_hps|agx5_hps|sm_hps|sundancemesa_hps_inst~intosc_clk.reg}]
set_multicycle_path 1 -hold -from [get_registers {*|agx5_hps|agx5_hps|sm_hps|sundancemesa_hps_inst~intosc_clk.reg}] -to [get_registers {*|agx5_hps|agx5_hps|sm_hps|sundancemesa_hps_inst~intosc_clk.reg}]

# sourcing JTAG related SDCs
source ./jtag.sdc

#****************************************************************************
#
# SPDX-License-Identifier: MIT-0
# Copyright(c) 2019-2021 Altera Corporation.
#
#****************************************************************************
#
# Sample SDC for Agilex GHRD.
#
#****************************************************************************
# JTAG clock constraints
source ./jtag_example.sdc

set_time_format -unit ns -decimal_places 3

# 100MHz board input clock
create_clock -name {clk_sys_100m_p} -period 10.000 -waveform {0 10} {clk_sys_100m_p}


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

set_time_format -unit ns -decimal_places 3

# 100MHz board input clock, 133.3333MHz for EMIF refclk
create_clock -name MAIN_CLOCK -period 10 [get_ports fpga_clk_100[0]]
create_clock -name HPS_EMIF_REF_CLOCK -period 6.0 [get_ports emif_hps_pll_ref_clk]
create_clock -name EMIF_REF_CLOCK -period 6.0 [get_ports emif_agx_0_pll_ref_clk_clk[0]]
create_clock -name PCS_CLOCK -period 8 [get_ports enet_refclk[0]]

set_false_path -from [get_keepers -no_duplicates {coredla_resetn}] -to [get_keepers -no_duplicates *]
set_false_path -to [get_keepers -no_duplicates {emif_pll_locked_meta}]
set_false_path -from [get_ports {fpga_reset_n[0]}]

# sourcing JTAG related SDCs
source ./jtag.sdc

set_max_skew -to [get_ports "emac1_mdc"] 2
set_max_skew -to [get_ports "emac1_mdio"] 2
set_false_path -from * -to [ get_ports emac1_phy_rst_n ]
set_false_path -from [get_ports {emac1_phy_irq}] -to *

set_max_skew -to [get_ports "emac2_mdc"] 2
set_max_skew -to [get_ports "emac2_mdio"] 2
set_false_path -from * -to [ get_ports emac2_phy_rst_n ]

set_false_path -from [get_ports {emac2_phy_irq}] -to *

set_false_path -from {soc_inst|src_prb_rst|*|sync_src_1_bit[2]} -to {soc_inst|rst_controller_*altera_reset_synchronizer_int_chain[1]}

set_false_path -from {soc_inst|rst_controller_*|altera_reset_synchronizer_int_chain_out} -to {soc_inst|rst_controller_*|altera_reset_synchronizer_int_chain[1]}

set_false_path -from fpga_reset_n_debounced -to {soc_inst|rst_controller_*|altera_reset_synchronizer_int_chain[1]}

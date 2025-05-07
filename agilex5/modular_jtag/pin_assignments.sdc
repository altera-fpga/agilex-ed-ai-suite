set_location_assignment PIN_BU28 -to i_fpga_core_resetn
set_location_assignment PIN_BK31 -to i_clk_hvio_6a_100m
set_location_assignment PIN_BR49 -to i_ddr4_comp1_refclk_p
set_location_assignment PIN_BR52 -to i_ddr4_comp1_rzq

set_instance_assignment -name IO_STANDARD "1.2V TRUE DIFFERENTIAL SIGNALING" -to i_ddr4_comp1_refclk_p -entity top
set_instance_assignment -name IO_STANDARD "3.3-V LVCMOS" -to i_clk_hvio_6a_100m -entity top

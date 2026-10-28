// Copyright 2020-2023 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.


module top (

// Clock and Reset
input    wire     	fpga_clk_100,
// External FPGA Reset
input    wire		fpga_reset_n,
// HPS External Oscillator
input    wire          	hps_osc_clk,

// LEDs, DIP switches, buttons
output   wire [0:0]     fpga_user_leds,
input    wire [1:0]     fpga_user_switches,
input    wire [0:0]     fpga_user_push_buttons,

// HPS
// HPS EMIF
output   wire          	hps_emif_mem_ck_t,
output   wire          	hps_emif_mem_ck_c,
output   wire [16:0]   	hps_emif_mem_a,
output   wire          	hps_emif_mem_act_n,
output   wire [1:0]    	hps_emif_mem_ba,
output   wire [1:0]    	hps_emif_mem_bg,
output   wire          	hps_emif_mem_cke,
output   wire          	hps_emif_mem_cs_n,
output   wire          	hps_emif_mem_odt,
output   wire          	hps_emif_mem_reset_n,
output   wire          	hps_emif_mem_par,
input    wire          	hps_emif_mem_alert_n,
input    wire          	hps_emif_mem_oct_rzqin,
input    wire          	hps_emif_mem_ref_clk,
inout    wire [3:0]    	hps_emif_mem_dqs_t,
inout    wire [3:0]    	hps_emif_mem_dqs_c,
inout    wire [31:0]   	hps_emif_mem_dq,

// HPS JTAG
input    wire          	hps_jtag_tck,
input    wire           hps_jtag_tms,
output   wire           hps_jtag_tdo,
input    wire           hps_jtag_tdi,

// HPS SD
output   wire           hps_sdmmc_CCLK,
inout    wire           hps_sdmmc_CMD,
inout    wire           hps_sdmmc_D0,
inout    wire           hps_sdmmc_D1,
inout    wire           hps_sdmmc_D2,
inout    wire           hps_sdmmc_D3,

// HPS Ethernet
output   wire          	hps_emac2_TX_CLK,
input    wire          	hps_emac2_RX_CLK,
output   wire          	hps_emac2_TX_CTL,
input    wire          	hps_emac2_RX_CTL,
output   wire          	hps_emac2_TXD0,
output   wire          	hps_emac2_TXD1,
input    wire          	hps_emac2_RXD0,
input    wire          	hps_emac2_RXD1,
output   wire          	hps_emac2_PPS,
input    wire          	hps_emac2_PPS_TRIG,
output   wire          	hps_emac2_TXD2,
output   wire          	hps_emac2_TXD3,
input    wire          	hps_emac2_RXD2,
input    wire          	hps_emac2_RXD3,
inout    wire          	hps_emac2_MDIO,
output   wire          	hps_emac2_MDC,

// HPS UART
input    wire          	hps_uart0_RX,
output   wire          	hps_uart0_TX,

// HPS I2C
inout    wire          	hps_i2c_emac1_SDA,
inout    wire          	hps_i2c_emac1_SCL,

// HPS GPIO
inout    wire          	hps_gpio0_io0,
inout    wire          	hps_gpio0_io10,
inout    wire          	hps_gpio1_io3,
inout    wire          	hps_gpio1_io4,

// FPGA EMIF
input    wire            fpga_emif_mem_ref_clk,
output   wire            fpga_emif_mem_cke,
output   wire            fpga_emif_mem_odt,
output   wire            fpga_emif_mem_cs_n,
output   wire [16:0]     fpga_emif_mem_a,
output   wire [1:0]      fpga_emif_mem_ba,
output   wire [1:0]      fpga_emif_mem_bg,
output   wire            fpga_emif_mem_act_n,
output   wire            fpga_emif_mem_par,
inout    wire [31:0]     fpga_emif_mem_dq,
inout    wire [3:0]      fpga_emif_mem_dqs_t,
inout    wire [3:0]      fpga_emif_mem_dqs_c,
input    wire            fpga_emif_mem_alert_n,
inout    wire [3:0]      fpga_emif_mem_dbi_n,
output   wire            fpga_emif_mem_ck_t,
output   wire            fpga_emif_mem_ck_c,
output   wire            fpga_emif_mem_reset_n,
input    wire            fpga_emif_mem_oct_rzqin
);

wire [43:0] stm_hw_events;
assign stm_hw_events = 44'b0;

wire system_clk_100;
assign system_clk_100 = fpga_clk_100;

wire system_reset;
wire h2f_reset;
wire ninit_done;
wire combined_reset_n;
assign combined_reset_n = fpga_reset_n & ~h2f_reset & ~ninit_done;
altera_reset_synchronizer #(
    .ASYNC_RESET (1),
    .DEPTH       (2)
) sys_rst_inst (
    .reset_in  (~combined_reset_n),
    .clk       (system_clk_100),
    .reset_out (system_reset)
);

// Directly loop reset request signal to the reset acknowledge signals.
wire h2f_warm_reset_handshake_reset_ack;
wire h2f_warm_reset_handshake_reset_req;

assign h2f_warm_reset_handshake_reset_ack = h2f_warm_reset_handshake_reset_req;

// Debounce logic to clean out glitches within 1ms
wire [1-1:0] fpga_debounced_buttons;
debounce #(
    .WIDTH         (1),
    .POLARITY      ("LOW"),
    .TIMEOUT       (100000),
    .TIMEOUT_WIDTH (17)
) debounce_inst (
    .clk      (system_clk_100),
    .reset_n  (~system_reset),
    .data_in  (fpga_user_push_buttons),
    .data_out (fpga_debounced_buttons)
);

// Qsys Top module
system system_inst (
// Clocks and resets
.clk_100_clk 				(system_clk_100),
.reset_reset_n				(~system_reset),
.h2f_reset_reset                        (h2f_reset),
.ninit_done_ninit_done                  (ninit_done),
//.agx_hps_f2h_stm_hw_events_stm_hwevents (stm_hw_events),

// HPS
.hps_io_hps_osc_clk                     (hps_osc_clk),

// HPS EMIF
.hps_emif_mem_ck_0_mem_ck_t        	(hps_emif_mem_ck_t),
.hps_emif_mem_ck_0_mem_ck_c           	(hps_emif_mem_ck_c),
.hps_emif_mem_0_mem_a                 	(hps_emif_mem_a),
.hps_emif_mem_0_mem_act_n             	(hps_emif_mem_act_n),
.hps_emif_mem_0_mem_ba                	(hps_emif_mem_ba),
.hps_emif_mem_0_mem_bg                	(hps_emif_mem_bg),
.hps_emif_mem_0_mem_cke               	(hps_emif_mem_cke),
.hps_emif_mem_0_mem_cs_n             	(hps_emif_mem_cs_n),
.hps_emif_mem_0_mem_odt               	(hps_emif_mem_odt),
.hps_emif_mem_reset_n_mem_reset_n  	(hps_emif_mem_reset_n),
.hps_emif_mem_0_mem_par               	(hps_emif_mem_par),
.hps_emif_mem_0_mem_alert_n           	(hps_emif_mem_alert_n),
.hps_emif_mem_0_mem_dqs_t             	(hps_emif_mem_dqs_t),
.hps_emif_mem_0_mem_dqs_c             	(hps_emif_mem_dqs_c),
.hps_emif_mem_0_mem_dq                	(hps_emif_mem_dq),
.hps_emif_oct_0_oct_rzqin            	(hps_emif_mem_oct_rzqin),
.hps_emif_pll_ref_clk_clk              	(hps_emif_mem_ref_clk),

// HPS JTAG
.hps_io_jtag_tck                           	(hps_jtag_tck),
.hps_io_jtag_tms                           	(hps_jtag_tms),
.hps_io_jtag_tdo                           	(hps_jtag_tdo),
.hps_io_jtag_tdi                           	(hps_jtag_tdi),

// HPS Ethernet
.hps_io_emac2_tx_clk                       	(hps_emac2_TX_CLK),
.hps_io_emac2_rx_clk                       	(hps_emac2_RX_CLK),
.hps_io_emac2_tx_ctl                       	(hps_emac2_TX_CTL),
.hps_io_emac2_rx_ctl                      	(hps_emac2_RX_CTL),
.hps_io_emac2_txd0                         	(hps_emac2_TXD0),
.hps_io_emac2_txd1                         	(hps_emac2_TXD1),
.hps_io_emac2_rxd0                         	(hps_emac2_RXD0),
.hps_io_emac2_rxd1                         	(hps_emac2_RXD1),
.hps_io_emac2_pps                          	(hps_emac2_PPS),
.hps_io_emac2_pps_trig                     	(hps_emac2_PPS_TRIG),
.hps_io_emac2_txd2                         	(hps_emac2_TXD2),
.hps_io_emac2_txd3                         	(hps_emac2_TXD3),
.hps_io_emac2_rxd2                        	(hps_emac2_RXD2),
.hps_io_emac2_rxd3                         	(hps_emac2_RXD3),
.hps_io_mdio2_mdio                         	(hps_emac2_MDIO),
.hps_io_mdio2_mdc                          	(hps_emac2_MDC),

// HPS SD
.hps_io_sdmmc_cclk                         	(hps_sdmmc_CCLK),
.hps_io_sdmmc_cmd                          	(hps_sdmmc_CMD),
.hps_io_sdmmc_data0                        	(hps_sdmmc_D0),
.hps_io_sdmmc_data1                        	(hps_sdmmc_D1),
.hps_io_sdmmc_data2                        	(hps_sdmmc_D2),
.hps_io_sdmmc_data3                        	(hps_sdmmc_D3),

// HPS I2C
.hps_io_i2c_emac1_sda                      	(hps_i2c_emac1_SDA),
.hps_io_i2c_emac1_scl                      	(hps_i2c_emac1_SCL),

// HPS UART
.hps_io_uart0_rx                           	(hps_uart0_RX),
.hps_io_uart0_tx                           	(hps_uart0_TX),

// HPS GPIO
.hps_io_gpio0                          		(hps_gpio0_io0),
.hps_io_gpio10                          	(hps_gpio0_io10),
.hps_io_gpio27                          	(hps_gpio1_io3),
.hps_io_gpio28                          	(hps_gpio1_io4),

// FPGA EMIF
.fpga_emif_ref_clk_clk             (fpga_emif_mem_ref_clk),
.fpga_emif_mem_0_mem_cke           (fpga_emif_mem_cke),
.fpga_emif_mem_0_mem_odt           (fpga_emif_mem_odt),
.fpga_emif_mem_0_mem_cs_n          (fpga_emif_mem_cs_n),
.fpga_emif_mem_0_mem_a             (fpga_emif_mem_a),
.fpga_emif_mem_0_mem_ba            (fpga_emif_mem_ba),
.fpga_emif_mem_0_mem_bg            (fpga_emif_mem_bg),
.fpga_emif_mem_0_mem_act_n         (fpga_emif_mem_act_n),
.fpga_emif_mem_0_mem_par           (fpga_emif_mem_par),
.fpga_emif_mem_0_mem_dq            (fpga_emif_mem_dq),
.fpga_emif_mem_0_mem_dqs_t         (fpga_emif_mem_dqs_t),
.fpga_emif_mem_0_mem_dqs_c         (fpga_emif_mem_dqs_c),
.fpga_emif_mem_0_mem_alert_n       (fpga_emif_mem_alert_n),
.fpga_emif_mem_0_mem_dbi_n         (fpga_emif_mem_dbi_n),
.fpga_emif_mem_ck_0_mem_ck_t       (fpga_emif_mem_ck_t),
.fpga_emif_mem_ck_0_mem_ck_c       (fpga_emif_mem_ck_c),
.fpga_emif_mem_reset_n_mem_reset_n (fpga_emif_mem_reset_n),
.fpga_emif_oct_0_oct_rzqin         (fpga_emif_mem_oct_rzqin)
);

reg [25:0] blink_100;

always @ (posedge fpga_clk_100)
begin
  blink_100 <= blink_100 + 1'b1;
end

assign fpga_user_leds[0] = blink_100[25];

endmodule

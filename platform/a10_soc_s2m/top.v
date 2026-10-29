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

module top
   (

   // -------------------------------------------------------------------------
   //full i/o definitions
   // -------------------------------------------------------------------------
   input  wire                               fpga_reset_n,    
   input  wire                               fpga_clk_100,    
   input  wire                               mem_clk,         

   //DDR4
   input    wire                             mem_oct_rzqin,
   output   wire  [0:0]                      mem_ck,
   output   wire  [0:0]                      mem_ck_n,
   output   wire  [16:0]                     mem_a,
   output   wire  [0:0]                      mem_act_n,
   output   wire  [1:0]                      mem_ba,
   output   wire  [0:0]                      mem_bg,
   output   wire  [0:0]                      mem_cke,
   output   wire  [0:0]                      mem_cs_n,
   output   wire  [0:0]                      mem_odt,
   output   wire  [0:0]                      mem_reset_n,
   inout    wire  [7:0]                      mem_dqs,
   inout    wire  [7:0]                      mem_dqs_n,
   inout    wire  [63:0]                     mem_dq,
   inout    wire  [7:0]                      mem_dm,
   input    wire  [0:0]                      mem_alert_n,
   output   wire  [0:0]                      mem_par,

   // HPS Memory
   input   wire                             emif_ref_clk,
   input   wire                             hps_memory_oct_rzqin,
   output  wire  [0:0]                      hps_memory_mem_ck,
   output  wire  [0:0]                      hps_memory_mem_ck_n,
   output  wire  [16:0]                     hps_memory_mem_a,
   output  wire  [0:0]                      hps_memory_mem_act_n,
   output  wire  [1:0]                      hps_memory_mem_ba,
   output  wire  [0:0]                      hps_memory_mem_bg,
   output  wire  [0:0]                      hps_memory_mem_cke,
   output  wire  [0:0]                      hps_memory_mem_cs_n,
   output  wire  [0:0]                      hps_memory_mem_odt,
   output  wire  [0:0]                      hps_memory_mem_reset_n,
   output  wire  [0:0]                      hps_memory_mem_par,
   input   wire  [0:0]                      hps_memory_mem_alert_n,
   inout   wire  [3:0]                      hps_memory_mem_dqs,
   inout   wire  [3:0]                      hps_memory_mem_dqs_n,
   inout   wire  [31:0]                     hps_memory_mem_dq,
   inout   wire  [3:0]                      hps_memory_mem_dbi_n,

   // HPS peripherals
   output  wire                             hps_emac0_TX_CLK,
   output  wire                             hps_emac0_TXD0,
   output  wire                             hps_emac0_TXD1,
   output  wire                             hps_emac0_TXD2,
   output  wire                             hps_emac0_TXD3,
   input   wire                             hps_emac0_RXD0,
   inout   wire                             hps_emac0_MDIO,
   output  wire                             hps_emac0_MDC,
   input   wire                             hps_emac0_RX_CTL,
   output  wire                             hps_emac0_TX_CTL,
   input   wire                             hps_emac0_RX_CLK,
   input   wire                             hps_emac0_RXD1,
   input   wire                             hps_emac0_RXD2,
   input   wire                             hps_emac0_RXD3,
   inout   wire                             hps_usb0_D0,
   inout   wire                             hps_usb0_D1,
   inout   wire                             hps_usb0_D2,
   inout   wire                             hps_usb0_D3,
   inout   wire                             hps_usb0_D4,
   inout   wire                             hps_usb0_D5,
   inout   wire                             hps_usb0_D6,
   inout   wire                             hps_usb0_D7,
   input   wire                             hps_usb0_CLK,
   output  wire                             hps_usb0_STP,
   input   wire                             hps_usb0_DIR,
   input   wire                             hps_usb0_NXT,
   output  wire                             hps_spim1_CLK,
   output  wire                             hps_spim1_MOSI,
   input   wire                             hps_spim1_MISO,
   output  wire                             hps_spim1_SS0_N,
   output  wire                             hps_spim1_SS1_N,
   input   wire                             hps_uart1_RX,
   output  wire                             hps_uart1_TX,
   inout   wire                             hps_i2c1_SDA,
   inout   wire                             hps_i2c1_SCL,
   inout   wire                             hps_sdio_CMD,
   output  wire                             hps_sdio_CLK,
   inout   wire                             hps_sdio_D0,
   inout   wire                             hps_sdio_D1,
   inout   wire                             hps_sdio_D2,
   inout   wire                             hps_sdio_D3,
   inout   wire                             hps_sdio_D4,
   inout   wire                             hps_sdio_D5,
   inout   wire                             hps_sdio_D6,
   inout   wire                             hps_sdio_D7,
   output  wire                             hps_trace_CLK,
   output  wire                             hps_trace_D0,
   output  wire                             hps_trace_D1,
   output  wire                             hps_trace_D2,
   output  wire                             hps_trace_D3,
   inout   wire                             hps_gpio_GPIO14,
   inout   wire                             hps_gpio_GPIO05,
   inout   wire                             hps_gpio_GPIO16,
   inout   wire                             hps_gpio_GPIO17,
   inout   wire                             hps_gpio_GPIO19

   );


wire        hps_fpga_reset;
wire [2:0]  hps_reset_req;
wire        hps_cold_reset;
wire        hps_warm_reset;
wire        hps_debug_reset;
wire        emif_usr_resetn;
wire        emif_fpga_pll_locked;
reg         emif_pll_locked_meta;
reg         emif_pll_locked_safe;
wire        dla_pll_locked;
reg         dla_pll_locked_meta;
reg         dla_pll_locked_safe;
 
reg [15:0]  dla_reset_counter;
reg         coredla_resetn;

   // GHRD In-System Probe is not used in this design.
   assign hps_reset_req = 3'b0;
	
   //----------------------------------------------------------------------------
   //Qsys system with control Nios and VIP pipeline
   //----------------------------------------------------------------------------
   system system (
      .clk_100_clk                                       (fpga_clk_100),
      .reset_reset_n                                     (fpga_reset_n),
      .hps_fpga_reset_reset                              (hps_fpga_reset),
      .ddr4_emif_usr_reset_n_reset_n                     (emif_usr_resetn),
	   .dla_0_dla_resetn_reset_n                          (coredla_resetn),
		.dla_pll_locked_export                             (dla_pll_locked),
      .ddr4_emif_pll_locked_pll_locked                   (emif_fpga_pll_locked),

      .ddr4_emif_global_reset_n_reset_n                  (fpga_reset_n),
      .ddr4_emif_pll_ref_clk_clk                         (mem_clk),
      .ddr4_emif_mem_mem_par                             (mem_par),
      .ddr4_emif_mem_mem_alert_n                         (mem_alert_n),
      .ddr4_emif_mem_mem_ck                              (mem_ck),
      .ddr4_emif_mem_mem_ck_n                            (mem_ck_n),
      .ddr4_emif_mem_mem_a                               (mem_a),
      .ddr4_emif_mem_mem_act_n                           (mem_act_n),
      .ddr4_emif_mem_mem_ba                              (mem_ba),
      .ddr4_emif_mem_mem_bg                              (mem_bg),
      .ddr4_emif_mem_mem_cke                             (mem_cke),
      .ddr4_emif_mem_mem_cs_n                            (mem_cs_n),
      .ddr4_emif_mem_mem_odt                             (mem_odt),
      .ddr4_emif_mem_mem_reset_n                         (mem_reset_n),
      .ddr4_emif_mem_mem_dqs                             (mem_dqs),
      .ddr4_emif_mem_mem_dqs_n                           (mem_dqs_n),
      .ddr4_emif_mem_mem_dq                              (mem_dq),
      .ddr4_emif_mem_mem_dbi_n                           (mem_dm),
      .ddr4_emif_oct_oct_rzqin                           (mem_oct_rzqin),
      .ddr4_emif_status_local_cal_success                (),
      .ddr4_emif_status_local_cal_fail                   (),


      .hps_0_a10_hps_f2h_cold_reset_req_reset_n          (~hps_cold_reset),
      .hps_0_a10_hps_f2h_debug_reset_req_reset_n         (~hps_debug_reset),
      .hps_0_a10_hps_f2h_warm_reset_req_reset_n          (~hps_warm_reset),
      .hps_0_a10_hps_f2h_stm_hw_events_stm_hwevents      (0),

      .hps_io_hps_io_phery_emac0_TX_CLK                  (hps_emac0_TX_CLK),
      .hps_io_hps_io_phery_emac0_TXD0                    (hps_emac0_TXD0),
      .hps_io_hps_io_phery_emac0_TXD1                    (hps_emac0_TXD1),
      .hps_io_hps_io_phery_emac0_TXD2                    (hps_emac0_TXD2),
      .hps_io_hps_io_phery_emac0_TXD3                    (hps_emac0_TXD3),
      .hps_io_hps_io_phery_emac0_RX_CTL                  (hps_emac0_RX_CTL),
      .hps_io_hps_io_phery_emac0_TX_CTL                  (hps_emac0_TX_CTL),
      .hps_io_hps_io_phery_emac0_RX_CLK                  (hps_emac0_RX_CLK),
      .hps_io_hps_io_phery_emac0_RXD0                    (hps_emac0_RXD0),
      .hps_io_hps_io_phery_emac0_RXD1                    (hps_emac0_RXD1),
      .hps_io_hps_io_phery_emac0_RXD2                    (hps_emac0_RXD2),
      .hps_io_hps_io_phery_emac0_RXD3                    (hps_emac0_RXD3),
      .hps_io_hps_io_phery_emac0_MDIO                    (hps_emac0_MDIO),
      .hps_io_hps_io_phery_emac0_MDC                     (hps_emac0_MDC),
      .hps_io_hps_io_phery_sdmmc_CMD                     (hps_sdio_CMD),
      .hps_io_hps_io_phery_sdmmc_D0                      (hps_sdio_D0),
      .hps_io_hps_io_phery_sdmmc_D1                      (hps_sdio_D1),
      .hps_io_hps_io_phery_sdmmc_D2                      (hps_sdio_D2),
      .hps_io_hps_io_phery_sdmmc_D3                      (hps_sdio_D3),
      .hps_io_hps_io_phery_sdmmc_D4                      (hps_sdio_D4),
      .hps_io_hps_io_phery_sdmmc_D5                      (hps_sdio_D5),
      .hps_io_hps_io_phery_sdmmc_D6                      (hps_sdio_D6),
      .hps_io_hps_io_phery_sdmmc_D7                      (hps_sdio_D7),
      .hps_io_hps_io_phery_sdmmc_CCLK                    (hps_sdio_CLK),
      .hps_io_hps_io_phery_usb0_DATA0                    (hps_usb0_D0),
      .hps_io_hps_io_phery_usb0_DATA1                    (hps_usb0_D1),
      .hps_io_hps_io_phery_usb0_DATA2                    (hps_usb0_D2),
      .hps_io_hps_io_phery_usb0_DATA3                    (hps_usb0_D3),
      .hps_io_hps_io_phery_usb0_DATA4                    (hps_usb0_D4),
      .hps_io_hps_io_phery_usb0_DATA5                    (hps_usb0_D5),
      .hps_io_hps_io_phery_usb0_DATA6                    (hps_usb0_D6),
      .hps_io_hps_io_phery_usb0_DATA7                    (hps_usb0_D7),
      .hps_io_hps_io_phery_usb0_CLK                      (hps_usb0_CLK),
      .hps_io_hps_io_phery_usb0_STP                      (hps_usb0_STP),
      .hps_io_hps_io_phery_usb0_DIR                      (hps_usb0_DIR),
      .hps_io_hps_io_phery_usb0_NXT                      (hps_usb0_NXT),
      .hps_io_hps_io_phery_spim1_CLK                     (hps_spim1_CLK),
      .hps_io_hps_io_phery_spim1_MOSI                    (hps_spim1_MOSI),
      .hps_io_hps_io_phery_spim1_MISO                    (hps_spim1_MISO),
      .hps_io_hps_io_phery_spim1_SS0_N                   (hps_spim1_SS0_N),
      .hps_io_hps_io_phery_spim1_SS1_N                   (hps_spim1_SS1_N),
      .hps_io_hps_io_phery_trace_CLK                     (hps_trace_CLK),
      .hps_io_hps_io_phery_trace_D0                      (hps_trace_D0),
      .hps_io_hps_io_phery_trace_D1                      (hps_trace_D1),
      .hps_io_hps_io_phery_trace_D2                      (hps_trace_D2),
      .hps_io_hps_io_phery_trace_D3                      (hps_trace_D3),
      .hps_io_hps_io_phery_uart1_RX                      (hps_uart1_RX),
      .hps_io_hps_io_phery_uart1_TX                      (hps_uart1_TX),
      .hps_io_hps_io_phery_i2c1_SDA                      (hps_i2c1_SDA),
      .hps_io_hps_io_phery_i2c1_SCL                      (hps_i2c1_SCL),

      .hps_io_hps_io_gpio_gpio1_io5                      (hps_gpio_GPIO05),
      .hps_io_hps_io_gpio_gpio1_io14                     (hps_gpio_GPIO14),
      .hps_io_hps_io_gpio_gpio1_io16                     (hps_gpio_GPIO16),
      .hps_io_hps_io_gpio_gpio1_io17                     (hps_gpio_GPIO17),
      .hps_io_hps_io_gpio_gpio1_io19                     (hps_gpio_GPIO19),


      .hps_0_emif_a10_hps_pll_ref_clk_clock_sink_clk     (emif_ref_clk),
      .hps_0_emif_a10_hps_oct_conduit_end_oct_rzqin      (hps_memory_oct_rzqin),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_ck         (hps_memory_mem_ck),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_ck_n       (hps_memory_mem_ck_n),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_a          (hps_memory_mem_a),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_act_n      (hps_memory_mem_act_n),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_ba         (hps_memory_mem_ba),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_bg         (hps_memory_mem_bg),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_cke        (hps_memory_mem_cke),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_cs_n       (hps_memory_mem_cs_n),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_odt        (hps_memory_mem_odt),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_reset_n    (hps_memory_mem_reset_n),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_par        (hps_memory_mem_par),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_alert_n    (hps_memory_mem_alert_n),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_dqs        (hps_memory_mem_dqs),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_dqs_n      (hps_memory_mem_dqs_n),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_dq         (hps_memory_mem_dq),
      .hps_0_emif_a10_hps_mem_conduit_end_mem_dbi_n      (hps_memory_mem_dbi_n)


   );


//////////////////////////////////////////////////////////
// Retime PLL Locked Signals
//////////////////////////////////////////////////////////
always @(posedge fpga_clk_100) begin
  // Retime PLL locked signals
  emif_pll_locked_meta    <= emif_fpga_pll_locked;
  emif_pll_locked_safe    <= emif_pll_locked_meta;
  
  dla_pll_locked_meta     <= dla_pll_locked;
  dla_pll_locked_safe     <= dla_pll_locked_meta;

  if (hps_fpga_reset) begin
    emif_pll_locked_meta    <= 1'b0;
    emif_pll_locked_safe    <= 1'b0;
    dla_pll_locked_meta     <= 1'b0;
    dla_pll_locked_safe     <= 1'b0;
  end
end
//////////////////////////////////////////////////////////

//////////////////////////////////////////////////////////
// coreDLA Reset Generation
//////////////////////////////////////////////////////////
always @(posedge fpga_clk_100)  begin
  // PLLs must be locked
  dla_reset_counter <= dla_reset_counter + 1;
  if (dla_reset_counter == 1023) begin     // coreDLA requires 1024 slow clock cycles once all clocks are running
    coredla_resetn     <= 1'b1;
  end

	if (hps_fpga_reset || ~emif_usr_resetn || ~emif_pll_locked_safe || ~dla_pll_locked_safe) begin
    dla_reset_counter   <= 0;
    coredla_resetn      <= 1'b0;
  end
end

altera_edge_detector pulse_cold_reset (
.clk       (fpga_clk_100),
.rst_n     (~hps_fpga_reset),
.signal_in (hps_reset_req[0]),
.pulse_out (hps_cold_reset)
);
defparam pulse_cold_reset.PULSE_EXT = 6;
defparam pulse_cold_reset.EDGE_TYPE = 1;
defparam pulse_cold_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_warm_reset (
.clk       (fpga_clk_100),
.rst_n     (~hps_fpga_reset),
.signal_in (hps_reset_req[1]),
.pulse_out (hps_warm_reset)
);
defparam pulse_warm_reset.PULSE_EXT = 2;
defparam pulse_warm_reset.EDGE_TYPE = 1;
defparam pulse_warm_reset.IGNORE_RST_WHILE_BUSY = 1;

altera_edge_detector pulse_debug_reset (
.clk       (fpga_clk_100),
.rst_n     (~hps_fpga_reset),
.signal_in (hps_reset_req[2]),
.pulse_out (hps_debug_reset)
);
defparam pulse_debug_reset.PULSE_EXT = 32;
defparam pulse_debug_reset.EDGE_TYPE = 1;
defparam pulse_debug_reset.IGNORE_RST_WHILE_BUSY = 1;

endmodule

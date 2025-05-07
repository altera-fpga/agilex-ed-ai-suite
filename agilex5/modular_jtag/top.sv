// Copyright 2024 Altera Corporation.
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


`resetall
`undefineall
`default_nettype none

module top #() (
  //Reset&Clock
  input  wire         i_fpga_core_resetn        , // Reset, low active
  input  wire         i_clk_hvio_6a_100m       , // 100 MHz reference clock, HVIO6A

  //Memory interface: DDR4 COMP1
 input  wire         i_ddr4_comp1_refclk_p     ,
 output logic        o_ddr4_comp1_ck_p         ,
 output logic        o_ddr4_comp1_ck_n         ,
 output logic [16:0] o_ddr4_comp1_a            ,
 output logic        o_ddr4_comp1_act_n        ,
 output logic [1:0]  o_ddr4_comp1_ba           ,
 output logic [1:0]  o_ddr4_comp1_bg           ,
 output logic        o_ddr4_comp1_cke          ,
 output logic        o_ddr4_comp1_cs_n         ,
 output logic        o_ddr4_comp1_odt          ,
 output logic        o_ddr4_comp1_reset_n      ,
 output logic        o_ddr4_comp1_par          ,
 input  wire         i_ddr4_comp1_alert_n      ,
 inout  wire [3:0]   io_ddr4_comp1_dqs_p        ,
 inout  wire [3:0]   io_ddr4_comp1_dqs_n        ,
//  DBI is disabled
//  inout  wire [4:0]   io_ddr4_comp1_dbi_n        ,
 inout  wire [31:0]  io_ddr4_comp1_dq           ,
 input  wire         i_ddr4_comp1_rzq          
);

`include "dla_dma_param.svh"
`include "dla_acl_parameter_assert.svh"

localparam int AXI_BURST_LENGTH_WIDTH           = 8;    //width of the axi burst length signal as per the axi4 spec
localparam int AXI_BURST_SIZE_WIDTH             = 3;    //width of the axi burst size signal as per the axi4 spec
localparam int AXI_BURST_TYPE_WIDTH             = 2;    //width of the axi burst type signal as per the axi4 spec

// Assuming a few hundred MHz, a free running 32-bit counter won't overflow within 1 second
localparam int HW_TIMER_WIDTH = 32;

// This ED only supports 1 DLA instance
localparam int MAX_DLA_INSTANCES=1;

logic                                   interrupt_level;
logic                                   csr_arvalid, csr_arready;
logic        [C_CSR_AXI_ADDR_WIDTH-1:0] csr_araddr;
logic                                   csr_rvalid, csr_rready;
logic        [C_CSR_AXI_DATA_WIDTH-1:0] csr_rdata;
logic                                   csr_awvalid, csr_awready;
logic        [C_CSR_AXI_ADDR_WIDTH-1:0] csr_awaddr;
logic                                   csr_wvalid, csr_wready;
logic        [C_CSR_AXI_DATA_WIDTH-1:0] csr_wdata;
logic                                   csr_bvalid, csr_bready;
logic                                   ddr_arvalid, ddr_arready;
logic        [C_DDR_AXI_ADDR_WIDTH-1:0] ddr_araddr;
logic      [AXI_BURST_LENGTH_WIDTH-1:0] ddr_arlen;
logic        [AXI_BURST_SIZE_WIDTH-1:0] ddr_arsize;
logic        [AXI_BURST_TYPE_WIDTH-1:0] ddr_arburst;
logic   [C_DDR_AXI_THREAD_ID_WIDTH-1:0] ddr_arid;
logic                                   ddr_rvalid, ddr_rready;
logic        [C_DDR_AXI_DATA_WIDTH-1:0] ddr_rdata;
logic   [C_DDR_AXI_THREAD_ID_WIDTH-1:0] ddr_rid;
logic                                   ddr_awvalid, ddr_awready;
logic        [C_DDR_AXI_ADDR_WIDTH-1:0] ddr_awaddr;
logic      [AXI_BURST_LENGTH_WIDTH-1:0] ddr_awlen;
logic        [AXI_BURST_SIZE_WIDTH-1:0] ddr_awsize;
logic        [AXI_BURST_TYPE_WIDTH-1:0] ddr_awburst;
logic                                   ddr_wvalid, ddr_wready;
logic        [C_DDR_AXI_DATA_WIDTH-1:0] ddr_wdata;
logic    [(C_DDR_AXI_DATA_WIDTH/8)-1:0] ddr_wstrb;
logic                                   ddr_wlast;
logic                                   ddr_bvalid, ddr_bready;

//main execution
logic                                   clk_ddr;
logic                                   sync_dla_clk_fpga_core_resetn;
logic                                   clk_dla;
logic                                   clk_pcie;
logic                                   dut_resetn;

//hw timer, for inferring CoreDLA clock frequency from host
// Avalon interface from system console
logic                                   dla_hw_timer_write;
logic                                   dla_hw_timer_read;
logic             [HW_TIMER_WIDTH-1:0]  dla_hw_timer_readdata;
logic             [HW_TIMER_WIDTH-1:0]  dla_hw_timer_writedata;
logic                                   dla_hw_timer_start;
logic                                   dla_hw_timer_stop;
logic              [HW_TIMER_WIDTH-1:0] dla_hw_timer_counter;

//mapping of avalon interface to the hw timer signals
assign dla_hw_timer_start = dla_hw_timer_write & dla_hw_timer_writedata[0];
assign dla_hw_timer_stop = dla_hw_timer_write & dla_hw_timer_writedata[1];
assign dla_hw_timer_readdata = dla_hw_timer_counter;

assign clk_pcie = clk_ddr;

`DLA_ACL_PARAMETER_ASSERT(C_DDR_AXI_ADDR_WIDTH == 32)
`DLA_ACL_PARAMETER_ASSERT(C_DDR_AXI_DATA_WIDTH == 256)
`DLA_ACL_PARAMETER_ASSERT(AXI_BURST_LENGTH_WIDTH == 8)
`DLA_ACL_PARAMETER_ASSERT(AXI_BURST_SIZE_WIDTH == 3)
`DLA_ACL_PARAMETER_ASSERT(AXI_BURST_TYPE_WIDTH == 2)

dla_platform_wrapper #(
  .C_CSR_AXI_ADDR_WIDTH (C_CSR_AXI_ADDR_WIDTH),         //width of the byte address signal, determines CSR address space size, e.g. 11 bit address = 2048 bytes, the largest size that uses only 1 M20K
  .C_CSR_AXI_DATA_WIDTH (C_CSR_AXI_DATA_WIDTH),         //width of the CSR data path, typically 4 bytes
  .C_DDR_AXI_ADDR_WIDTH (C_DDR_AXI_ADDR_WIDTH),         //width of all byte address signals to global memory, 32 would allow 4 GB of addressable memory
  .C_DDR_AXI_BURST_WIDTH (C_DDR_AXI_BURST_WIDTH),        //internal width of the axi burst length signal, typically 4, max number of words in a burst = 2**DDR_BURST_WIDTH
  .C_DDR_AXI_DATA_WIDTH (C_DDR_AXI_DATA_WIDTH),         //width of the global memory data path, typically 64 bytes
  .C_DDR_AXI_THREAD_ID_WIDTH (C_DDR_AXI_THREAD_ID_WIDTH),    //width of the axi id signal for reads, need enough bits to uniquely identify which master a request came from
  .MAX_DLA_INSTANCES (MAX_DLA_INSTANCES),            //maximum number of DLA instances defined by the number of CSR and DDR interfaces provided by the BSP
  .HW_TIMER_WIDTH (HW_TIMER_WIDTH),               //width of the hw timer counter, for inferring CoreDLA clock frequency from host
  .ENABLE_INPUT_STREAMING (ENABLE_INPUT_STREAMING),       //AXI-s input-enable toggle
  .AXI_ISTREAM_DATA_WIDTH (AXI_ISTREAM_DATA_WIDTH),       //width of input AXI-S streamer data bus
  .AXI_ISTREAM_FIFO_DEPTH (AXI_ISTREAM_FIFO_DEPTH),       //depth of the dcfifo in the input streamer
  .ENABLE_OUTPUT_STREAMER (ENABLE_OUTPUT_STREAMER),       //AXI-s output-enable toggle
  .AXI_OSTREAM_DATA_WIDTH (AXI_OSTREAM_DATA_WIDTH),       //width of output AXI-S streamer data bus
  .AXI_OSTREAM_FIFO_DEPTH (AXI_OSTREAM_FIFO_DEPTH)       //depth of the dcfifo in the output streamer
) dla_platform_inst (
  //clocks and resets
  .clk_dla                                      (clk_dla),
  .clk_ddr                                      ({clk_ddr}),                    //one ddr clock for each ddr bank
  .clk_axi                                      ({1'b0}),                           //one AXI-s clock for each instance
  .clk_pcie                                     (clk_pcie),
  // dut_resetn has already by synchronized by the reset handler in the platform designer system.
  .i_resetn_dla                                 (dut_resetn),            //active low reset synchronized to clk_dla
  .i_resetn_ddr                                 ({1'b1}),                  //active low reset synchronized to each clk_ddr.
  .i_resetn_axi                                 ({1'b1}),                  //active low reset synchronized to each AXI-s clock
  .i_resetn_pcie                                ({1'b1}),                 //active low reset synchronized to clk_pcie

  //interrupt request, AXI4 stream master without data, runs on pcie clock
  .o_interrupt_level(),

  //AXI interfaces for CSR
  .i_csr_awaddr                                 ({csr_awaddr}),
  .i_csr_awvalid                                ({csr_awvalid}),
  .o_csr_awready                                ({csr_awready}),
  .i_csr_wdata                                  ({csr_wdata}),
  .i_csr_wvalid                                 ({csr_wvalid}),
  .o_csr_wready                                 ({csr_wready}),
  .o_csr_bvalid                                 ({csr_bvalid}),
  .i_csr_bready                                 ({csr_bready}),
  .i_csr_araddr                                 ({csr_araddr}),
  .i_csr_arvalid                                ({csr_arvalid}),
  .o_csr_arready                                ({csr_arready}),
  .o_csr_rdata                                  ({csr_rdata}),
  .o_csr_rvalid                                 ({csr_rvalid}),
  .i_csr_rready                                 ({csr_rready}),

  //AXI interfaces for DDR
  .o_ddr_arvalid                                ({ddr_arvalid}),
  .o_ddr_araddr                                 ({ddr_araddr}),
  .o_ddr_arlen                                  ({ddr_arlen}),
  .o_ddr_arsize                                 ({ddr_arsize}),
  .o_ddr_arburst                                ({ddr_arburst}),
  .o_ddr_arid                                   ({ddr_arid}),
  .i_ddr_arready                                ({ddr_arready}),
  .i_ddr_rvalid                                 ({ddr_rvalid}),
  .i_ddr_rdata                                  ({ddr_rdata}),
  .i_ddr_rid                                    ({ddr_rid}),
  .o_ddr_rready                                 ({ddr_rready}),
  .o_ddr_awvalid                                ({ddr_awvalid}),
  .o_ddr_awaddr                                 ({ddr_awaddr}),
  .o_ddr_awlen                                  ({ddr_awlen}),
  .o_ddr_awsize                                 ({ddr_awsize}),
  .o_ddr_awburst                                ({ddr_awburst}),
  .i_ddr_awready                                ({ddr_awready}),
  .o_ddr_wvalid                                 ({ddr_wvalid}),
  .o_ddr_wdata                                  ({ddr_wdata}),
  .o_ddr_wstrb                                  ({ddr_wstrb}),
  .o_ddr_wlast                                  ({ddr_wlast}),
  .i_ddr_wready                                 ({ddr_wready}),
  .i_ddr_bvalid                                 ({ddr_bvalid}),
  .o_ddr_bready                                 ({ddr_bready}),

  .i_istream_axi_t_valid                        ({1'b0}),
  .o_istream_axi_t_ready                        (),
  .i_istream_axi_t_data                         ({0}),

  .o_ostream_axi_t_valid                        (),
  .i_ostream_axi_t_ready                        ({1'b0}),
  .o_ostream_axi_t_last                         (),
  .o_ostream_axi_t_data                         (),
  .o_ostream_axi_t_strb                         (),

  //hw timer, for inferring CoreDLA clock frequency from host
  .i_hw_timer_start                             (dla_hw_timer_start),
  .i_hw_timer_stop                              (dla_hw_timer_stop),
  .o_hw_timer_counter                           (dla_hw_timer_counter)
);

shell pd (
  .emif_0_mem_0_ck_mem_ck_t          (o_ddr4_comp1_ck_p),
  .emif_0_mem_0_ck_mem_ck_c          (o_ddr4_comp1_ck_n),
  .emif_0_mem_0_mem_cke              (o_ddr4_comp1_cke),
  .emif_0_mem_0_mem_odt              (o_ddr4_comp1_odt),
  .emif_0_mem_0_mem_cs_n             (o_ddr4_comp1_cs_n),
  .emif_0_mem_0_mem_a                (o_ddr4_comp1_a),
  .emif_0_mem_0_mem_ba               (o_ddr4_comp1_ba),
  .emif_0_mem_0_mem_bg               (o_ddr4_comp1_bg),
  .emif_0_mem_0_mem_act_n            (o_ddr4_comp1_act_n),
  .emif_0_mem_0_mem_par              (o_ddr4_comp1_par),
  .emif_0_mem_0_mem_alert_n          (i_ddr4_comp1_alert_n),
  .emif_0_mem_0_reset_n_mem_reset_n  (o_ddr4_comp1_reset_n),
  .emif_0_mem_0_mem_dq               (io_ddr4_comp1_dq),
  .emif_0_mem_0_mem_dqs_t            (io_ddr4_comp1_dqs_p),
  .emif_0_mem_0_mem_dqs_c            (io_ddr4_comp1_dqs_n),
  .emif_0_oct_0_oct_rzqin            (i_ddr4_comp1_rzq),

  .emif_data_bridge_0_s0_awid                  (2'd0),               //  input,    width = 2
  .emif_data_bridge_0_s0_awaddr                ({1'b0, ddr_awaddr}),         //   input,   width = 33, so need to pad DLA.araddr
  .emif_data_bridge_0_s0_awlen                 (ddr_awlen),          //   input,    width = 8
  .emif_data_bridge_0_s0_awsize                (ddr_awsize),         //   input,    width = 3
  .emif_data_bridge_0_s0_awburst               (ddr_awburst),        //   input,    width = 2
  .emif_data_bridge_0_s0_awvalid               (ddr_awvalid),        //   input,    width = 1
  .emif_data_bridge_0_s0_awready               (ddr_awready),        //  output,    width = 1
  .emif_data_bridge_0_s0_wdata                 (ddr_wdata),          //   input,  width = 256
  .emif_data_bridge_0_s0_wstrb                 (ddr_wstrb),          //   input,   width = 32
  .emif_data_bridge_0_s0_wlast                 (ddr_wlast),
  .emif_data_bridge_0_s0_wvalid                (ddr_wvalid),
  .emif_data_bridge_0_s0_wready                (ddr_wready),

  .emif_data_bridge_0_s0_bid                   (),
  .emif_data_bridge_0_s0_bvalid                (ddr_bvalid),
  .emif_data_bridge_0_s0_bready                (ddr_bready),

  .emif_data_bridge_0_s0_arid                  (ddr_arid),
  .emif_data_bridge_0_s0_araddr                ({1'b0, ddr_araddr}),        //   input,   width = 33, so need to pad DLA.araddr
  .emif_data_bridge_0_s0_arlen                 (ddr_arlen),         //   input,    width = 8
  .emif_data_bridge_0_s0_arsize                (ddr_arsize),
  .emif_data_bridge_0_s0_arburst               (ddr_arburst),

  .emif_data_bridge_0_s0_arvalid               (ddr_arvalid),
  .emif_data_bridge_0_s0_arready               (ddr_arready),

  .emif_data_bridge_0_s0_rid                   (ddr_rid),

  .emif_data_bridge_0_s0_rdata                 (ddr_rdata),         //  output,  width = 256
  .emif_data_bridge_0_s0_rlast                 (),
  .emif_data_bridge_0_s0_rvalid                (ddr_rvalid),
  .emif_data_bridge_0_s0_rready                (ddr_rready),

  .csr_data_bridge_0_m0_awaddr                (csr_awaddr),                //  output,   width = 11,                   csr_data_bridge_0_m0.awaddr
  .csr_data_bridge_0_m0_awprot                (/*csr_awprot*/),                //  output,    width = 3,                                  .awprot
  .csr_data_bridge_0_m0_awvalid               (csr_awvalid),               //  output,    width = 1,                                  .awvalid
  .csr_data_bridge_0_m0_awready               (csr_awready),               //   input,    width = 1,                                  .awready
  .csr_data_bridge_0_m0_wdata                 (csr_wdata),                 //  output,   width = 32,                                  .wdata
  .csr_data_bridge_0_m0_wstrb                 (/*csr_wstrb*/),                 //  output,    width = 4,                                  .wstrb
  .csr_data_bridge_0_m0_wvalid                (csr_wvalid),                //  output,    width = 1,                                  .wvalid
  .csr_data_bridge_0_m0_wready                (csr_wready),                //   input,    width = 1,                                  .wready
  .csr_data_bridge_0_m0_bresp                 (/*csr_bresp*/),             //   input,    width = 2,                          .bresp
  .csr_data_bridge_0_m0_bvalid                (csr_bvalid),                //   input,    width = 1,                                  .bvalid
  .csr_data_bridge_0_m0_bready                (csr_bready),                //  output,    width = 1,                                  .bready
  .csr_data_bridge_0_m0_araddr                (csr_araddr),                //  output,   width = 11,                                  .araddr
  .csr_data_bridge_0_m0_arprot                (/*csr_arprot*/),                //  output,    width = 3,                                  .arprot
  .csr_data_bridge_0_m0_arvalid               (csr_arvalid),               //  output,    width = 1,                                  .arvalid
  .csr_data_bridge_0_m0_arready               (csr_arready),               //   input,    width = 1,                                  .arready
  .csr_data_bridge_0_m0_rresp                 (/*csr_rresp*/),             //   input,    width = 2,                          .rresp
  .csr_data_bridge_0_m0_rdata                 (csr_rdata),                 //   input,   width = 32,                                  .rdata
  .csr_data_bridge_0_m0_rvalid                (csr_rvalid),                //   input,    width = 1,                                  .rvalid
  .csr_data_bridge_0_m0_rready                (csr_rready),                //  output,    width = 1,                                  .rready


  .dla_clk_bridge_0_out_clk_clk          (clk_dla),
  .emif_clk_bridge_0_out_clk_clk         (clk_ddr),         //  output,    width = 1,         ddr_usr_clk_bridge_out_clk.clk
  .dla_pll_0_refclk_clk                  (i_clk_hvio_6a_100m),
  .jtag_pll_0_refclk_clk                 (i_clk_hvio_6a_100m),
  .emif_0_ref_clk_0_clk                  (i_ddr4_comp1_refclk_p),
  .reset_handler_reset_n_1_reset_n       (sync_dla_clk_fpga_core_resetn),
  .reset_bridge_0_out_reset_reset_n      (dut_resetn),

  .ed_zero_hw_timer_bridge_m0_clk_clk     (clk_dla),              //ed_zero_hw_timer_bridge_m0_clk.clk
  .ed_zero_hw_timer_bridge_m0_reset_reset (~dut_resetn),          //ed_zero_hw_timer_bridge_m0_reset.reset
  .ed_zero_hw_timer_bridge_m0_waitrequest (1'b0),                 //ed_zero_hw_timer_bridge_m0.waitrequest
  .ed_zero_hw_timer_bridge_m0_readdata    (dla_hw_timer_readdata),//.readdata
  .ed_zero_hw_timer_bridge_m0_readdatavalid (dla_hw_timer_read),  //.readdatavalid, loop back the read data signal
  .ed_zero_hw_timer_bridge_m0_burstcount  (),                     //.burstcount No connected
  .ed_zero_hw_timer_bridge_m0_writedata   (dla_hw_timer_writedata),//.writedata
  .ed_zero_hw_timer_bridge_m0_address     (),                     //.address            ignored
  .ed_zero_hw_timer_bridge_m0_write       (dla_hw_timer_write),   //.write              ignored
  .ed_zero_hw_timer_bridge_m0_read        (dla_hw_timer_read),    //.read               ignored
  .ed_zero_hw_timer_bridge_m0_byteenable  (),                     //.byteenable         ignored
  .ed_zero_hw_timer_bridge_m0_debugaccess ()                     //.debugaccess        ignored
);

dla_cdc_reset_async u_reset_200M (
  .clk(clk_dla),
  .i_async_resetn (i_fpga_core_resetn),
  .o_async_resetn (sync_dla_clk_fpga_core_resetn)
);

endmodule

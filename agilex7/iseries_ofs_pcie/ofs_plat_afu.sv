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

`include "ofs_plat_if.vh"
`include "dla_dma_param.svh"

//
// Top level PIM-based module.
//

module ofs_plat_afu
(
  // All platform wires, wrapped in one interface.
  ofs_plat_if plat_ifc
);

// local parameters
localparam int MAX_DLA_INSTANCES = local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS;
localparam int DDR_BANK_ADDR_W = local_mem_cfg_pkg::LOCAL_MEM_BYTE_ADDR_WIDTH;
localparam int DDR_ADDR_W = $clog2(MAX_DLA_INSTANCES) + DDR_BANK_ADDR_W;
localparam int HOST_ADDR_W = ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES;
localparam int HW_TIMER_WIDTH = 32;
localparam int AXI_ID_IN = 16;
localparam int AXI_ID_OUT = 18;
localparam int DMA_CSR_ADDR_W = 16;

logic sw_reset_n;

// DLA IP wrapper logic clock and reset (all on DDR bank 0 core clock)
logic clk_wrapper, resetn_wrapper;
assign clk_wrapper    = plat_ifc.local_mem.banks[0].clk;
assign resetn_wrapper = plat_ifc.local_mem.banks[0].reset_n;

// DLA IP clock and reset (on OFS user clock)
logic clk_dla, resetn_dla;
assign clk_dla    = plat_ifc.clocks.uClk_usrDiv2.clk;
assign resetn_dla = plat_ifc.clocks.uClk_usrDiv2.reset_n;

// DLA IP DDR clocks and resets
logic clk_ddr[MAX_DLA_INSTANCES];
logic resetn_ddr[MAX_DLA_INSTANCES];
genvar a;
generate
  for (a = 0; a < MAX_DLA_INSTANCES; a = a + 1)
    begin : dla_ip_clocks_resets
      assign clk_ddr[a]    = clk_wrapper;
      assign resetn_ddr[a] = sw_reset_n;
    end
endgenerate

// interrupt signal
logic irq;

// Declare arrays for passing into dla_platform_wrapper
// AXI interfaces for CSR
logic      [C_CSR_AXI_ADDR_WIDTH-1:0] dla_csr_awaddr  [MAX_DLA_INSTANCES];
logic                                 dla_csr_awvalid [MAX_DLA_INSTANCES];
logic                                 dla_csr_awready [MAX_DLA_INSTANCES];
logic      [C_CSR_AXI_DATA_WIDTH-1:0] dla_csr_wdata   [MAX_DLA_INSTANCES];
logic                                 dla_csr_wvalid  [MAX_DLA_INSTANCES];
logic                                 dla_csr_wready  [MAX_DLA_INSTANCES];
logic                                 dla_csr_bvalid  [MAX_DLA_INSTANCES];
logic                                 dla_csr_bready  [MAX_DLA_INSTANCES];
logic      [C_CSR_AXI_ADDR_WIDTH-1:0] dla_csr_araddr  [MAX_DLA_INSTANCES];
logic                                 dla_csr_arvalid [MAX_DLA_INSTANCES];
logic                                 dla_csr_arready [MAX_DLA_INSTANCES];
logic      [C_CSR_AXI_DATA_WIDTH-1:0] dla_csr_rdata   [MAX_DLA_INSTANCES];
logic                                 dla_csr_rvalid  [MAX_DLA_INSTANCES];
logic                                 dla_csr_rready  [MAX_DLA_INSTANCES];

// AXI interfaces for DDR
logic      [C_DDR_AXI_ADDR_WIDTH-1:0] dla_ddr_awaddr  [MAX_DLA_INSTANCES];
logic                           [7:0] dla_ddr_awlen   [MAX_DLA_INSTANCES];
logic                           [2:0] dla_ddr_awsize  [MAX_DLA_INSTANCES];
logic                           [1:0] dla_ddr_awburst [MAX_DLA_INSTANCES];
logic                                 dla_ddr_awvalid [MAX_DLA_INSTANCES];
logic                                 dla_ddr_awready [MAX_DLA_INSTANCES];
logic                 [AXI_ID_IN-1:0] dla_ddr_awid    [MAX_DLA_INSTANCES];
logic      [C_DDR_AXI_DATA_WIDTH-1:0] dla_ddr_wdata   [MAX_DLA_INSTANCES];
logic  [(C_DDR_AXI_DATA_WIDTH/8)-1:0] dla_ddr_wstrb   [MAX_DLA_INSTANCES];
logic                                 dla_ddr_wlast   [MAX_DLA_INSTANCES];
logic                                 dla_ddr_wvalid  [MAX_DLA_INSTANCES];
logic                                 dla_ddr_wready  [MAX_DLA_INSTANCES];
logic                                 dla_ddr_bvalid  [MAX_DLA_INSTANCES];
logic                                 dla_ddr_bready  [MAX_DLA_INSTANCES];
logic [C_DDR_AXI_THREAD_ID_WIDTH-1:0] dla_ddr_arid    [MAX_DLA_INSTANCES];
logic      [C_DDR_AXI_ADDR_WIDTH-1:0] dla_ddr_araddr  [MAX_DLA_INSTANCES];
logic                           [7:0] dla_ddr_arlen   [MAX_DLA_INSTANCES];
logic                           [2:0] dla_ddr_arsize  [MAX_DLA_INSTANCES];
logic                           [1:0] dla_ddr_arburst [MAX_DLA_INSTANCES];
logic                                 dla_ddr_arvalid [MAX_DLA_INSTANCES];
logic                                 dla_ddr_arready [MAX_DLA_INSTANCES];
logic [C_DDR_AXI_THREAD_ID_WIDTH-1:0] dla_ddr_rid     [MAX_DLA_INSTANCES];
logic      [C_DDR_AXI_DATA_WIDTH-1:0] dla_ddr_rdata   [MAX_DLA_INSTANCES];
logic                                 dla_ddr_rvalid  [MAX_DLA_INSTANCES];
logic                                 dla_ddr_rready  [MAX_DLA_INSTANCES];

// signals for wrapper logic
logic [AXI_ID_IN-1:0] mmio_control_awid;
logic [AXI_ID_IN-1:0] mmio_control_bid;
logic [AXI_ID_IN-1:0] mmio_control_arid;
logic [AXI_ID_IN-1:0] mmio_control_rid;

logic [AXI_ID_IN-1:0] dla_ddr_in0_arid;
logic [AXI_ID_IN-1:0] dla_ddr_in0_rid;
logic [AXI_ID_IN-1:0] dla_ddr_in0_bid;
logic [AXI_ID_IN-1:0] dla_ddr_in1_arid;
logic [AXI_ID_IN-1:0] dla_ddr_in1_rid;
logic [AXI_ID_IN-1:0] dla_ddr_in1_bid;
logic [AXI_ID_IN-1:0] dla_ddr_in2_arid;
logic [AXI_ID_IN-1:0] dla_ddr_in2_rid;
logic [AXI_ID_IN-1:0] dla_ddr_in2_bid;
logic [AXI_ID_IN-1:0] dla_ddr_in3_arid;
logic [AXI_ID_IN-1:0] dla_ddr_in3_rid;
logic [AXI_ID_IN-1:0] dla_ddr_in3_bid;
logic                 dla_ddr_in0_rlast;
logic                 dla_ddr_in1_rlast;
logic                 dla_ddr_in2_rlast;
logic                 dla_ddr_in3_rlast;

logic [DMA_CSR_ADDR_W-1:0] dma_csr_awaddr;
logic [DMA_CSR_ADDR_W-1:0] dma_csr_araddr;
logic [AXI_ID_OUT-1:0]     dma_csr_awid;
logic [AXI_ID_OUT-1:0]     dma_csr_bid;
logic [AXI_ID_OUT-1:0]     dma_csr_arid;
logic [AXI_ID_OUT-1:0]     dma_csr_rid;

logic [AXI_ID_IN-1:0] dma_ddr_in0_awid;
logic [AXI_ID_IN-1:0] dma_ddr_in0_bid;
logic [AXI_ID_IN-1:0] dma_ddr_in0_arid;
logic [AXI_ID_IN-1:0] dma_ddr_in0_rid;
logic [AXI_ID_IN-1:0] dma_ddr_in1_awid;
logic [AXI_ID_IN-1:0] dma_ddr_in1_bid;
logic [AXI_ID_IN-1:0] dma_ddr_in1_arid;
logic [AXI_ID_IN-1:0] dma_ddr_in1_rid;
logic [AXI_ID_IN-1:0] dma_ddr_in2_awid;
logic [AXI_ID_IN-1:0] dma_ddr_in2_bid;
logic [AXI_ID_IN-1:0] dma_ddr_in2_arid;
logic [AXI_ID_IN-1:0] dma_ddr_in2_rid;
logic [AXI_ID_IN-1:0] dma_ddr_in3_awid;
logic [AXI_ID_IN-1:0] dma_ddr_in3_bid;
logic [AXI_ID_IN-1:0] dma_ddr_in3_arid;
logic [AXI_ID_IN-1:0] dma_ddr_in3_rid;

logic [AXI_ID_OUT-1:0] mux_ddr_out0_awid;
logic [AXI_ID_OUT-1:0] mux_ddr_out0_bid;
logic [AXI_ID_OUT-1:0] mux_ddr_out0_arid;
logic [AXI_ID_OUT-1:0] mux_ddr_out0_rid;
logic [AXI_ID_OUT-1:0] mux_ddr_out1_awid;
logic [AXI_ID_OUT-1:0] mux_ddr_out1_bid;
logic [AXI_ID_OUT-1:0] mux_ddr_out1_arid;
logic [AXI_ID_OUT-1:0] mux_ddr_out1_rid;
logic [AXI_ID_OUT-1:0] mux_ddr_out2_awid;
logic [AXI_ID_OUT-1:0] mux_ddr_out2_bid;
logic [AXI_ID_OUT-1:0] mux_ddr_out2_arid;
logic [AXI_ID_OUT-1:0] mux_ddr_out2_rid;
logic [AXI_ID_OUT-1:0] mux_ddr_out3_awid;
logic [AXI_ID_OUT-1:0] mux_ddr_out3_bid;
logic [AXI_ID_OUT-1:0] mux_ddr_out3_arid;
logic [AXI_ID_OUT-1:0] mux_ddr_out3_rid;

// HW timer Avalon signals
logic                      dla_hw_timer_start;
logic                      dla_hw_timer_stop;
logic [HW_TIMER_WIDTH-1:0] dla_hw_timer_counter;

logic                      dla_hw_timer_write;
logic                      dla_hw_timer_read;
logic [HW_TIMER_WIDTH-1:0] dla_hw_timer_readdata;
logic [HW_TIMER_WIDTH-1:0] dla_hw_timer_writedata;

// ====================================================================
//
//  Get an AXI-MM host channel connection from the platform.
//
// ====================================================================

// Instance of the PIM's standard AXI memory interface.
ofs_plat_axi_mem_if
#(
  // The PIM provides parameters for configuring a standard host
  // memory DMA AXI memory interface.
  `HOST_CHAN_AXI_MEM_PARAMS,

  // PIM interfaces can be configured to log traffic during
  // simulation. In ASE, see work/log_ofs_plat_host_chan.tsv.
  .LOG_CLASS(ofs_plat_log_pkg::HOST_CHAN),

  // Set the host memory interface's burst count width so it is
  // large enough to request up to 16KB. The PIM will translate
  // large requests into sizes that are legal for the underlying
  // host channel.
  .BURST_CNT_WIDTH($clog2(16384/ofs_plat_host_chan_pkg::DATA_WIDTH_BYTES))
) host_mem();

// Create an copy store the output of the mux 
ofs_plat_axi_mem_if
#(
  // Copy the configuration from host_mem
  `OFS_PLAT_AXI_MEM_IF_REPLICATE_PARAMS(host_mem),
  .LOG_CLASS(ofs_plat_log_pkg::HOST_CHAN)
) host_mem_mux();

assign host_mem_mux.clk = host_mem.clk;
assign host_mem_mux.reset_n = host_mem.reset_n;

// Instance of the PIM's AXI memory lite interface, which will be
// used to implement the AFU's CSR space.
ofs_plat_axi_mem_lite_if
#(
  // The AFU choses the data bus width of the interface and the
  // PIM adjusts the address space to match.
  `HOST_CHAN_AXI_MMIO_PARAMS(64),

  // Log MMIO traffic. (See the same parameter above on host_mem.)
  .LOG_CLASS(ofs_plat_log_pkg::HOST_CHAN)
) mmio64_to_afu();

// Create an copy to store the output for dma
ofs_plat_axi_mem_lite_if
#(
  // Copy the configuration from host_mem
  `OFS_PLAT_AXI_MEM_LITE_IF_REPLICATE_PARAMS(mmio64_to_afu),
  .LOG_CLASS(ofs_plat_log_pkg::HOST_CHAN)
) mmio64_to_afu_dma();

assign mmio64_to_afu_dma.clk = mmio64_to_afu.clk;
assign mmio64_to_afu_dma.reset_n = mmio64_to_afu.reset_n;

// Use the platform-provided module to map the primary host interface
// to AXI-MM. The "primary" interface is the port that includes the
// main OPAE-managed MMIO connection. This primary port is always
// index 0 of plat_ifc.host_chan.ports, indepedent of the platform
// and the native protocol of the host channel. This same module
// name is available both on platforms that expose AXI-S PCIe TLP
// streams to the AFU and on platforms that expose CCI-P.
ofs_plat_host_chan_as_axi_mem_with_mmio
#(
  // The data stream expects read responses in request order.
  // Have the PIM guarantee ordered responses. The PIM will insert
  // a reorder buffer only if read responses are not already ordered
  // by some other component, such as the PCIe SS.
  .SORT_READ_RESPONSES(1),

  // Because the algorithm in this AFU loops read responses back
  // to the host channel as writes, there is a chance for deadlocks
  // if reads and writes share ready/enable logic. No credit for
  // reads can lead to blocked writes and no way to drain pending
  // read responses. Setting BUFFER_READ_RESPONSES causes the PIM
  // to manage buffer slots for all pending read responses. If
  // the PIM has already inserted a reorder buffer the flag is
  // ignored, since the reorder buffer already has this property.
  .BUFFER_READ_RESPONSES(1),

  .ADD_CLOCK_CROSSING(1),
  .ADD_TIMING_REG_STAGES(3)
) primary_axi
(
  .to_fiu(plat_ifc.host_chan.ports[0]),
  .host_mem_to_afu(host_mem),
  .mmio_to_afu(mmio64_to_afu),

  // These ports would be used if the PIM is told to cross to
  // a different clock. In this example, native pClk is used.
  .afu_clk(plat_ifc.local_mem.banks[0].clk),
  .afu_reset_n(plat_ifc.local_mem.banks[0].reset_n)
);

// ====================================================================
//
//  Get local memory from the platform.
//
// ====================================================================

// The choice of interface type for local memory is independent of the
// choice for the host channel. The host channel could be AXI-MM and
// local memory Avalon. In fact, there is no requirement that all banks
// of local memory be mapped to the same interface type. An AFU designer
// who doesn't value his job could choose to map half the banks to
// Avalon and half to AXI within a single AFU.
ofs_plat_axi_mem_if
#(
  `LOCAL_MEM_AXI_MEM_PARAMS_DEFAULT,

  // Log AXI transactions in simulation
  .LOG_CLASS(ofs_plat_log_pkg::LOCAL_MEM)
) local_mem_to_afu[MAX_DLA_INSTANCES]();

ofs_plat_axi_mem_if
#(
  `LOCAL_MEM_AXI_MEM_PARAMS_DEFAULT,

  // Log AXI transactions in simulation
  .LOG_CLASS(ofs_plat_log_pkg::LOCAL_MEM)
) dma_to_local_mem[MAX_DLA_INSTANCES]();

// Map each bank individually
genvar b;
generate
  for (b = 0; b < MAX_DLA_INSTANCES; b = b + 1)
    begin : map_local_mem_banks
      ofs_plat_local_mem_as_axi_mem
      #(
         // Add a clock crossing from bank-specific clock.
        .ADD_CLOCK_CROSSING(1),
        .ADD_TIMING_REG_STAGES(3)
      ) shim
      (
        .to_fiu(plat_ifc.local_mem.banks[b]),
        .to_afu(local_mem_to_afu[b]),

        // Map to the same clock as the AFU's host channel
        // interface. Whatever clock is chosen above in primary_hc
        // will be used here.
        .afu_clk(plat_ifc.local_mem.banks[0].clk),
        .afu_reset_n(plat_ifc.local_mem.banks[0].reset_n)
      );

      assign local_mem_to_afu[b].aw.atop = '0;

      assign dma_to_local_mem[b].clk = plat_ifc.local_mem.banks[0].clk;
      assign dma_to_local_mem[b].reset_n = plat_ifc.local_mem.banks[0].reset_n;

    end
endgenerate

// ====================================================================
//
//  Tie off unused ports.
//
// ====================================================================

// The PIM ties off unused devices, controlled by the AFU indicating
// which devices it is using. This way, an AFU must know only about
// the devices it uses. Tie-offs are thus portable, with the PIM
// managing devices unused by and unknown to the AFU.
ofs_plat_if_tie_off_unused
#(
  // Host channel group 0 port 0 is connected. The mask is a
  // bit vector of indices used by the AFU.
  .HOST_CHAN_IN_USE_MASK(1),

  // All banks are used
  .LOCAL_MEM_IN_USE_MASK(-1)
) tie_off(plat_ifc);

// =========================================================================
//
// Instantiate the dla_afu_hw.tcl PD system
//
// =========================================================================
dla_afu dla_afu_inst (
  .clk_clk       (clk_wrapper),
  .reset_reset_n (resetn_wrapper),                               

  .dla_clk_clk       (clk_dla),
  .dla_reset_reset_n (resetn_dla),

  .sw_reset_reset_n  (sw_reset_n),

  // MMIO Control going in
  // Write channel
  .mmio_control_awvalid (mmio64_to_afu.awvalid),
  .mmio_control_awready (mmio64_to_afu.awready),
  .mmio_control_awaddr  (mmio64_to_afu.aw.addr), 
  .mmio_control_awsize  (mmio64_to_afu.aw.size),
  .mmio_control_awid    (mmio_control_awid),
  .mmio_control_awuser  (mmio64_to_afu.aw.user),

  .mmio_control_wvalid  (mmio64_to_afu.wvalid),
  .mmio_control_wready  (mmio64_to_afu.wready),
  .mmio_control_wdata   (mmio64_to_afu.w.data),
  .mmio_control_wstrb   (mmio64_to_afu.w.strb),
  .mmio_control_wuser   (mmio64_to_afu.w.user),

  .mmio_control_bvalid  (mmio64_to_afu.bvalid),
  .mmio_control_bready  (mmio64_to_afu.bready),
  .mmio_control_bid     (mmio_control_bid),
  .mmio_control_bresp   (mmio64_to_afu.b.resp),
  .mmio_control_buser   (mmio64_to_afu.b.user),

  // Read channel
  .mmio_control_arvalid (mmio64_to_afu.arvalid),
  .mmio_control_arready (mmio64_to_afu.arready),
  .mmio_control_araddr  (mmio64_to_afu.ar.addr),
  .mmio_control_arsize  (mmio64_to_afu.ar.size),
  .mmio_control_arid    (mmio_control_arid),
  .mmio_control_aruser  (mmio64_to_afu.ar.user),

  .mmio_control_rvalid  (mmio64_to_afu.rvalid),
  .mmio_control_rready  (mmio64_to_afu.rready),
  .mmio_control_rdata   (mmio64_to_afu.r.data),
  .mmio_control_rid     (mmio_control_rid),
  .mmio_control_rresp   (mmio64_to_afu.r.resp),
  .mmio_control_ruser   (mmio64_to_afu.r.user),

  // DMA CSR going out
  // Write channel
  .dma_csr_awvalid      (mmio64_to_afu_dma.awvalid),
  .dma_csr_awready      (mmio64_to_afu_dma.awready),
  .dma_csr_awaddr       (dma_csr_awaddr),
  .dma_csr_awprot       (mmio64_to_afu_dma.aw.prot),
  .dma_csr_awsize       (mmio64_to_afu_dma.aw.size),
  .dma_csr_awid         (dma_csr_awid),
  .dma_csr_awuser       (mmio64_to_afu_dma.aw.user),

  .dma_csr_wvalid       (mmio64_to_afu_dma.wvalid),
  .dma_csr_wready       (mmio64_to_afu_dma.wready),
  .dma_csr_wdata        (mmio64_to_afu_dma.w.data),
  .dma_csr_wstrb        (mmio64_to_afu_dma.w.strb),
  .dma_csr_wuser        (mmio64_to_afu_dma.w.user),

  .dma_csr_bvalid       (mmio64_to_afu_dma.bvalid),
  .dma_csr_bready       (mmio64_to_afu_dma.bready),
  .dma_csr_bid          (dma_csr_bid),
  .dma_csr_buser        (mmio64_to_afu_dma.b.user),

  // Read channel
  .dma_csr_arvalid      (mmio64_to_afu_dma.arvalid),
  .dma_csr_arready      (mmio64_to_afu_dma.arready),
  .dma_csr_araddr       (dma_csr_araddr),
  .dma_csr_arprot       (mmio64_to_afu_dma.ar.prot),
  .dma_csr_arid         (dma_csr_arid),
  .dma_csr_arsize       (mmio64_to_afu_dma.ar.size),
  .dma_csr_aruser       (mmio64_to_afu_dma.ar.user),

  .dma_csr_rvalid       (mmio64_to_afu_dma.rvalid),
  .dma_csr_rready       (mmio64_to_afu_dma.rready),
  .dma_csr_rdata        (mmio64_to_afu_dma.r.data),
  .dma_csr_rid          (dma_csr_rid),
  .dma_csr_rresp        (mmio64_to_afu_dma.r.resp),
  .dma_csr_ruser        (mmio64_to_afu_dma.r.user),

  // DLA CSR going out
  // DLA IP 0
  // Write channel
  .dla_csr0_awvalid (dla_csr_awvalid[0]),
  .dla_csr0_awready (dla_csr_awready[0]),
  .dla_csr0_awaddr  (dla_csr_awaddr[0]),

  .dla_csr0_wvalid  (dla_csr_wvalid[0]),
  .dla_csr0_wready  (dla_csr_wready[0]),
  .dla_csr0_wdata   (dla_csr_wdata[0]),

  .dla_csr0_bvalid  (dla_csr_bvalid[0]),
  .dla_csr0_bready  (dla_csr_bready[0]),

  // Read channel
  .dla_csr0_arvalid (dla_csr_arvalid[0]),
  .dla_csr0_arready (dla_csr_arready[0]),
  .dla_csr0_araddr  (dla_csr_araddr[0]),

  .dla_csr0_rvalid  (dla_csr_rvalid[0]),
  .dla_csr0_rready  (dla_csr_rready[0]),
  .dla_csr0_rdata   (dla_csr_rdata[0]),

  // DLA IP 1
  // Write channel
  .dla_csr1_awvalid (dla_csr_awvalid[1]),
  .dla_csr1_awready (dla_csr_awready[1]),
  .dla_csr1_awaddr  (dla_csr_awaddr[1]),

  .dla_csr1_wvalid  (dla_csr_wvalid[1]),
  .dla_csr1_wready  (dla_csr_wready[1]),
  .dla_csr1_wdata   (dla_csr_wdata[1]),

  .dla_csr1_bvalid  (dla_csr_bvalid[1]),
  .dla_csr1_bready  (dla_csr_bready[1]),

  // Read channel
  .dla_csr1_arvalid (dla_csr_arvalid[1]),
  .dla_csr1_arready (dla_csr_arready[1]),
  .dla_csr1_araddr  (dla_csr_araddr[1]),

  .dla_csr1_rvalid  (dla_csr_rvalid[1]),
  .dla_csr1_rready  (dla_csr_rready[1]),
  .dla_csr1_rdata   (dla_csr_rdata[1]),

  // DLA IP 2
  // Write channel
  .dla_csr2_awvalid (dla_csr_awvalid[2]),
  .dla_csr2_awready (dla_csr_awready[2]),
  .dla_csr2_awaddr  (dla_csr_awaddr[2]),

  .dla_csr2_wvalid  (dla_csr_wvalid[2]),
  .dla_csr2_wready  (dla_csr_wready[2]),
  .dla_csr2_wdata   (dla_csr_wdata[2]),

  .dla_csr2_bvalid  (dla_csr_bvalid[2]),
  .dla_csr2_bready  (dla_csr_bready[2]),

  // Read channel
  .dla_csr2_arvalid (dla_csr_arvalid[2]),
  .dla_csr2_arready (dla_csr_arready[2]),
  .dla_csr2_araddr  (dla_csr_araddr[2]),

  .dla_csr2_rvalid  (dla_csr_rvalid[2]),
  .dla_csr2_rready  (dla_csr_rready[2]),
  .dla_csr2_rdata   (dla_csr_rdata[2]),

  // DLA IP 3
  // Write channel
  .dla_csr3_awvalid (dla_csr_awvalid[3]),
  .dla_csr3_awready (dla_csr_awready[3]),
  .dla_csr3_awaddr  (dla_csr_awaddr[3]),

  .dla_csr3_wvalid  (dla_csr_wvalid[3]),
  .dla_csr3_wready  (dla_csr_wready[3]),
  .dla_csr3_wdata   (dla_csr_wdata[3]),

  .dla_csr3_bvalid  (dla_csr_bvalid[3]),
  .dla_csr3_bready  (dla_csr_bready[3]),

  // Read channel
  .dla_csr3_arvalid (dla_csr_arvalid[3]),
  .dla_csr3_arready (dla_csr_arready[3]),
  .dla_csr3_araddr  (dla_csr_araddr[3]),

  .dla_csr3_rvalid  (dla_csr_rvalid[3]),
  .dla_csr3_rready  (dla_csr_rready[3]),
  .dla_csr3_rdata   (dla_csr_rdata[3]),

  // DLA to DDR banks in
  // bank 0
  // Write channel
  .dla_ddr_in0_awvalid (dla_ddr_awvalid[0]),
  .dla_ddr_in0_awready (dla_ddr_awready[0]),
  .dla_ddr_in0_awaddr  ({'0,dla_ddr_awaddr[0]}),
  .dla_ddr_in0_awsize  (dla_ddr_awsize[0]),
  .dla_ddr_in0_awburst (dla_ddr_awburst[0]),
  .dla_ddr_in0_awlen   (dla_ddr_awlen[0]),
  .dla_ddr_in0_awid    (dla_ddr_awid[0]),

  .dla_ddr_in0_wvalid  (dla_ddr_wvalid[0]),
  .dla_ddr_in0_wready  (dla_ddr_wready[0]),
  .dla_ddr_in0_wdata   (dla_ddr_wdata[0]),
  .dla_ddr_in0_wstrb   (dla_ddr_wstrb[0]),
  .dla_ddr_in0_wlast   (dla_ddr_wlast[0]),

  .dla_ddr_in0_bvalid  (dla_ddr_bvalid[0]),
  .dla_ddr_in0_bready  (dla_ddr_bready[0]),
  .dla_ddr_in0_bid     (dla_ddr_in0_bid),

  // Read channel
  .dla_ddr_in0_arvalid (dla_ddr_arvalid[0]),
  .dla_ddr_in0_arready (dla_ddr_arready[0]),
  .dla_ddr_in0_araddr  ({'0,dla_ddr_araddr[0]}),
  .dla_ddr_in0_arsize  (dla_ddr_arsize[0]),
  .dla_ddr_in0_arburst (dla_ddr_arburst[0]),
  .dla_ddr_in0_arid    (dla_ddr_in0_arid),
  .dla_ddr_in0_arlen   (dla_ddr_arlen[0]),

  .dla_ddr_in0_rvalid  (dla_ddr_rvalid[0]),
  .dla_ddr_in0_rready  (dla_ddr_rready[0]),
  .dla_ddr_in0_rdata   (dla_ddr_rdata[0]),
  .dla_ddr_in0_rlast   (dla_ddr_in0_rlast),
  .dla_ddr_in0_rid     (dla_ddr_in0_rid),

  // bank 1
  // Write channel
  .dla_ddr_in1_awvalid (dla_ddr_awvalid[1]),
  .dla_ddr_in1_awready (dla_ddr_awready[1]),
  .dla_ddr_in1_awaddr  ({'0,dla_ddr_awaddr[1]}),
  .dla_ddr_in1_awsize  (dla_ddr_awsize[1]),
  .dla_ddr_in1_awburst (dla_ddr_awburst[1]),
  .dla_ddr_in1_awlen   (dla_ddr_awlen[1]),
  .dla_ddr_in1_awid    (dla_ddr_awid[1]),

  .dla_ddr_in1_wvalid  (dla_ddr_wvalid[1]),
  .dla_ddr_in1_wready  (dla_ddr_wready[1]),
  .dla_ddr_in1_wdata   (dla_ddr_wdata[1]),
  .dla_ddr_in1_wstrb   (dla_ddr_wstrb[1]),
  .dla_ddr_in1_wlast   (dla_ddr_wlast[1]),

  .dla_ddr_in1_bvalid  (dla_ddr_bvalid[1]),
  .dla_ddr_in1_bready  (dla_ddr_bready[1]),
  .dla_ddr_in1_bid     (dla_ddr_in1_bid),

  // Read channel
  .dla_ddr_in1_arvalid (dla_ddr_arvalid[1]),
  .dla_ddr_in1_arready (dla_ddr_arready[1]),
  .dla_ddr_in1_araddr  ({'0,dla_ddr_araddr[1]}),
  .dla_ddr_in1_arsize  (dla_ddr_arsize[1]),
  .dla_ddr_in1_arburst (dla_ddr_arburst[1]),
  .dla_ddr_in1_arid    (dla_ddr_in1_arid),
  .dla_ddr_in1_arlen   (dla_ddr_arlen[1]),

  .dla_ddr_in1_rvalid  (dla_ddr_rvalid[1]),
  .dla_ddr_in1_rready  (dla_ddr_rready[1]),
  .dla_ddr_in1_rdata   (dla_ddr_rdata[1]),
  .dla_ddr_in1_rlast   (dla_ddr_in1_rlast),
  .dla_ddr_in1_rid     (dla_ddr_in1_rid),

  // bank 2
  // Write channel
  .dla_ddr_in2_awvalid (dla_ddr_awvalid[2]),
  .dla_ddr_in2_awready (dla_ddr_awready[2]),
  .dla_ddr_in2_awaddr  ({'0,dla_ddr_awaddr[2]}),
  .dla_ddr_in2_awsize  (dla_ddr_awsize[2]),
  .dla_ddr_in2_awburst (dla_ddr_awburst[2]),
  .dla_ddr_in2_awlen   (dla_ddr_awlen[2]),
  .dla_ddr_in2_awid    (dla_ddr_awid[2]),

  .dla_ddr_in2_wvalid  (dla_ddr_wvalid[2]),
  .dla_ddr_in2_wready  (dla_ddr_wready[2]),
  .dla_ddr_in2_wdata   (dla_ddr_wdata[2]),
  .dla_ddr_in2_wstrb   (dla_ddr_wstrb[2]),
  .dla_ddr_in2_wlast   (dla_ddr_wlast[2]),

  .dla_ddr_in2_bvalid  (dla_ddr_bvalid[2]),
  .dla_ddr_in2_bready  (dla_ddr_bready[2]),
  .dla_ddr_in2_bid     (dla_ddr_in2_bid),

  // Read channel
  .dla_ddr_in2_arvalid (dla_ddr_arvalid[2]),
  .dla_ddr_in2_arready (dla_ddr_arready[2]),
  .dla_ddr_in2_araddr  ({'0,dla_ddr_araddr[2]}),
  .dla_ddr_in2_arsize  (dla_ddr_arsize[2]),
  .dla_ddr_in2_arburst (dla_ddr_arburst[2]),
  .dla_ddr_in2_arid    (dla_ddr_in2_arid),
  .dla_ddr_in2_arlen   (dla_ddr_arlen[2]),

  .dla_ddr_in2_rvalid  (dla_ddr_rvalid[2]),
  .dla_ddr_in2_rready  (dla_ddr_rready[2]),
  .dla_ddr_in2_rdata   (dla_ddr_rdata[2]),
  .dla_ddr_in2_rlast   (dla_ddr_in2_rlast),
  .dla_ddr_in2_rid     (dla_ddr_in2_rid),

  // bank 3
  // Write channel
  .dla_ddr_in3_awvalid (dla_ddr_awvalid[3]),
  .dla_ddr_in3_awready (dla_ddr_awready[3]),
  .dla_ddr_in3_awaddr  ({'0,dla_ddr_awaddr[3]}),
  .dla_ddr_in3_awsize  (dla_ddr_awsize[3]),
  .dla_ddr_in3_awburst (dla_ddr_awburst[3]),
  .dla_ddr_in3_awlen   (dla_ddr_awlen[3]),
  .dla_ddr_in3_awid    (dla_ddr_awid[3]),

  .dla_ddr_in3_wvalid  (dla_ddr_wvalid[3]),
  .dla_ddr_in3_wready  (dla_ddr_wready[3]),
  .dla_ddr_in3_wdata   (dla_ddr_wdata[3]),
  .dla_ddr_in3_wstrb   (dla_ddr_wstrb[3]),
  .dla_ddr_in3_wlast   (dla_ddr_wlast[3]),

  .dla_ddr_in3_bvalid  (dla_ddr_bvalid[3]),
  .dla_ddr_in3_bready  (dla_ddr_bready[3]),
  .dla_ddr_in3_bid     (dla_ddr_in3_bid),

  // Read channel
  .dla_ddr_in3_arvalid (dla_ddr_arvalid[3]),
  .dla_ddr_in3_arready (dla_ddr_arready[3]),
  .dla_ddr_in3_araddr  ({'0,dla_ddr_araddr[3]}),
  .dla_ddr_in3_arsize  (dla_ddr_arsize[3]),
  .dla_ddr_in3_arburst (dla_ddr_arburst[3]),
  .dla_ddr_in3_arid    (dla_ddr_in3_arid),
  .dla_ddr_in3_arlen   (dla_ddr_arlen[3]),

  .dla_ddr_in3_rvalid  (dla_ddr_rvalid[3]),
  .dla_ddr_in3_rready  (dla_ddr_rready[3]),
  .dla_ddr_in3_rdata   (dla_ddr_rdata[3]),
  .dla_ddr_in3_rlast   (dla_ddr_in3_rlast),
  .dla_ddr_in3_rid     (dla_ddr_in3_rid),

  // DMA to DDR banks in
  // bank 0
  // Write channel
  .dma_ddr_in0_awvalid (dma_to_local_mem[0].awvalid),
  .dma_ddr_in0_awready (dma_to_local_mem[0].awready),
  .dma_ddr_in0_awaddr  (dma_to_local_mem[0].aw.addr),
  .dma_ddr_in0_awsize  (dma_to_local_mem[0].aw.size),
  .dma_ddr_in0_awburst (dma_to_local_mem[0].aw.burst),
  .dma_ddr_in0_awid    (dma_ddr_in0_awid),
  .dma_ddr_in0_awlen   (dma_to_local_mem[0].aw.len),
  .dma_ddr_in0_awlock  (dma_to_local_mem[0].aw.lock),
  .dma_ddr_in0_awprot  (dma_to_local_mem[0].aw.prot),
  .dma_ddr_in0_awuser  (dma_to_local_mem[0].aw.user),
  .dma_ddr_in0_awqos   (dma_to_local_mem[0].aw.qos),
  .dma_ddr_in0_awregion(dma_to_local_mem[0].aw.region),
  .dma_ddr_in0_awcache (dma_to_local_mem[0].aw.cache),

  .dma_ddr_in0_wvalid  (dma_to_local_mem[0].wvalid),
  .dma_ddr_in0_wready  (dma_to_local_mem[0].wready),
  .dma_ddr_in0_wdata   (dma_to_local_mem[0].w.data),
  .dma_ddr_in0_wstrb   (dma_to_local_mem[0].w.strb),
  .dma_ddr_in0_wlast   (dma_to_local_mem[0].w.last),
  .dma_ddr_in0_wuser   (dma_to_local_mem[0].w.user),

  .dma_ddr_in0_bvalid  (dma_to_local_mem[0].bvalid),
  .dma_ddr_in0_bready  (dma_to_local_mem[0].bready),
  .dma_ddr_in0_bid     (dma_ddr_in0_bid),
  .dma_ddr_in0_bresp   (dma_to_local_mem[0].b.resp),
  .dma_ddr_in0_buser   (dma_to_local_mem[0].b.user),

  // Read channel
  .dma_ddr_in0_arvalid (dma_to_local_mem[0].arvalid),
  .dma_ddr_in0_arready (dma_to_local_mem[0].arready),
  .dma_ddr_in0_araddr  (dma_to_local_mem[0].ar.addr),
  .dma_ddr_in0_arsize  (dma_to_local_mem[0].ar.size),
  .dma_ddr_in0_arburst (dma_to_local_mem[0].ar.burst),
  .dma_ddr_in0_arid    (dma_ddr_in0_arid),
  .dma_ddr_in0_arlen   (dma_to_local_mem[0].ar.len),
  .dma_ddr_in0_arlock  (dma_to_local_mem[0].ar.lock),
  .dma_ddr_in0_arprot  (dma_to_local_mem[0].ar.prot),
  .dma_ddr_in0_arregion(dma_to_local_mem[0].ar.region),
  .dma_ddr_in0_arcache (dma_to_local_mem[0].ar.cache),
  .dma_ddr_in0_arqos   (dma_to_local_mem[0].ar.qos),
  .dma_ddr_in0_aruser  (dma_to_local_mem[0].ar.user),

  .dma_ddr_in0_rvalid  (dma_to_local_mem[0].rvalid),
  .dma_ddr_in0_rready  (dma_to_local_mem[0].rready),
  .dma_ddr_in0_rlast   (dma_to_local_mem[0].r.last),
  .dma_ddr_in0_rdata   (dma_to_local_mem[0].r.data),
  .dma_ddr_in0_rid     (dma_ddr_in0_rid),
  .dma_ddr_in0_rresp   (dma_to_local_mem[0].r.resp),
  .dma_ddr_in0_ruser   (dma_to_local_mem[0].r.user),

  // bank 1
  // Write channel
  .dma_ddr_in1_awvalid (dma_to_local_mem[1].awvalid),
  .dma_ddr_in1_awready (dma_to_local_mem[1].awready),
  .dma_ddr_in1_awaddr  (dma_to_local_mem[1].aw.addr),
  .dma_ddr_in1_awsize  (dma_to_local_mem[1].aw.size),
  .dma_ddr_in1_awburst (dma_to_local_mem[1].aw.burst),
  .dma_ddr_in1_awid    (dma_ddr_in1_awid),
  .dma_ddr_in1_awlen   (dma_to_local_mem[1].aw.len),
  .dma_ddr_in1_awlock  (dma_to_local_mem[1].aw.lock),
  .dma_ddr_in1_awprot  (dma_to_local_mem[1].aw.prot),
  .dma_ddr_in1_awuser  (dma_to_local_mem[1].aw.user),
  .dma_ddr_in1_awqos   (dma_to_local_mem[1].aw.qos),
  .dma_ddr_in1_awregion(dma_to_local_mem[1].aw.region),
  .dma_ddr_in1_awcache (dma_to_local_mem[1].aw.cache),

  .dma_ddr_in1_wvalid  (dma_to_local_mem[1].wvalid),
  .dma_ddr_in1_wready  (dma_to_local_mem[1].wready),
  .dma_ddr_in1_wdata   (dma_to_local_mem[1].w.data),
  .dma_ddr_in1_wstrb   (dma_to_local_mem[1].w.strb),
  .dma_ddr_in1_wlast   (dma_to_local_mem[1].w.last),
  .dma_ddr_in1_wuser   (dma_to_local_mem[1].w.user),

  .dma_ddr_in1_bvalid  (dma_to_local_mem[1].bvalid),
  .dma_ddr_in1_bready  (dma_to_local_mem[1].bready),
  .dma_ddr_in1_bid     (dma_ddr_in1_bid),
  .dma_ddr_in1_bresp   (dma_to_local_mem[1].b.resp),
  .dma_ddr_in1_buser   (dma_to_local_mem[1].b.user),

  // Read channel
  .dma_ddr_in1_arvalid (dma_to_local_mem[1].arvalid),
  .dma_ddr_in1_arready (dma_to_local_mem[1].arready),
  .dma_ddr_in1_araddr  (dma_to_local_mem[1].ar.addr),
  .dma_ddr_in1_arsize  (dma_to_local_mem[1].ar.size),
  .dma_ddr_in1_arburst (dma_to_local_mem[1].ar.burst),
  .dma_ddr_in1_arid    (dma_ddr_in1_arid),
  .dma_ddr_in1_arlen   (dma_to_local_mem[1].ar.len),
  .dma_ddr_in1_arlock  (dma_to_local_mem[1].ar.lock),
  .dma_ddr_in1_arprot  (dma_to_local_mem[1].ar.prot),
  .dma_ddr_in1_arregion(dma_to_local_mem[1].ar.region),
  .dma_ddr_in1_arcache (dma_to_local_mem[1].ar.cache),
  .dma_ddr_in1_arqos   (dma_to_local_mem[1].ar.qos),
  .dma_ddr_in1_aruser  (dma_to_local_mem[1].ar.user),

  .dma_ddr_in1_rvalid  (dma_to_local_mem[1].rvalid),
  .dma_ddr_in1_rready  (dma_to_local_mem[1].rready),
  .dma_ddr_in1_rlast   (dma_to_local_mem[1].r.last),
  .dma_ddr_in1_rdata   (dma_to_local_mem[1].r.data),
  .dma_ddr_in1_rid     (dma_ddr_in1_rid),
  .dma_ddr_in1_rresp   (dma_to_local_mem[1].r.resp),
  .dma_ddr_in1_ruser   (dma_to_local_mem[1].r.user),

  // bank 2
  // Write channel
  .dma_ddr_in2_awvalid (dma_to_local_mem[2].awvalid),
  .dma_ddr_in2_awready (dma_to_local_mem[2].awready),
  .dma_ddr_in2_awaddr  (dma_to_local_mem[2].aw.addr),
  .dma_ddr_in2_awsize  (dma_to_local_mem[2].aw.size),
  .dma_ddr_in2_awburst (dma_to_local_mem[2].aw.burst),
  .dma_ddr_in2_awid    (dma_ddr_in2_awid),
  .dma_ddr_in2_awlen   (dma_to_local_mem[2].aw.len),
  .dma_ddr_in2_awlock  (dma_to_local_mem[2].aw.lock),
  .dma_ddr_in2_awprot  (dma_to_local_mem[2].aw.prot),
  .dma_ddr_in2_awuser  (dma_to_local_mem[2].aw.user),
  .dma_ddr_in2_awqos   (dma_to_local_mem[2].aw.qos),
  .dma_ddr_in2_awregion(dma_to_local_mem[2].aw.region),
  .dma_ddr_in2_awcache (dma_to_local_mem[2].aw.cache),

  .dma_ddr_in2_wvalid  (dma_to_local_mem[2].wvalid),
  .dma_ddr_in2_wready  (dma_to_local_mem[2].wready),
  .dma_ddr_in2_wdata   (dma_to_local_mem[2].w.data),
  .dma_ddr_in2_wstrb   (dma_to_local_mem[2].w.strb),
  .dma_ddr_in2_wlast   (dma_to_local_mem[2].w.last),
  .dma_ddr_in2_wuser   (dma_to_local_mem[2].w.user),

  .dma_ddr_in2_bvalid  (dma_to_local_mem[2].bvalid),
  .dma_ddr_in2_bready  (dma_to_local_mem[2].bready),
  .dma_ddr_in2_bid     (dma_ddr_in2_bid),
  .dma_ddr_in2_bresp   (dma_to_local_mem[2].b.resp),
  .dma_ddr_in2_buser   (dma_to_local_mem[2].b.user),

  // Read channel
  .dma_ddr_in2_arvalid (dma_to_local_mem[2].arvalid),
  .dma_ddr_in2_arready (dma_to_local_mem[2].arready),
  .dma_ddr_in2_araddr  (dma_to_local_mem[2].ar.addr),
  .dma_ddr_in2_arsize  (dma_to_local_mem[2].ar.size),
  .dma_ddr_in2_arburst (dma_to_local_mem[2].ar.burst),
  .dma_ddr_in2_arid    (dma_ddr_in2_arid),
  .dma_ddr_in2_arlen   (dma_to_local_mem[2].ar.len),
  .dma_ddr_in2_arlock  (dma_to_local_mem[2].ar.lock),
  .dma_ddr_in2_arprot  (dma_to_local_mem[2].ar.prot),
  .dma_ddr_in2_arregion(dma_to_local_mem[2].ar.region),
  .dma_ddr_in2_arcache (dma_to_local_mem[2].ar.cache),
  .dma_ddr_in2_arqos   (dma_to_local_mem[2].ar.qos),
  .dma_ddr_in2_aruser  (dma_to_local_mem[2].ar.user),

  .dma_ddr_in2_rvalid  (dma_to_local_mem[2].rvalid),
  .dma_ddr_in2_rready  (dma_to_local_mem[2].rready),
  .dma_ddr_in2_rlast   (dma_to_local_mem[2].r.last),
  .dma_ddr_in2_rdata   (dma_to_local_mem[2].r.data),
  .dma_ddr_in2_rid     (dma_ddr_in2_rid),
  .dma_ddr_in2_rresp   (dma_to_local_mem[2].r.resp),
  .dma_ddr_in2_ruser   (dma_to_local_mem[2].r.user),

  // bank 3
  // Write channel
  .dma_ddr_in3_awvalid (dma_to_local_mem[3].awvalid),
  .dma_ddr_in3_awready (dma_to_local_mem[3].awready),
  .dma_ddr_in3_awaddr  (dma_to_local_mem[3].aw.addr),
  .dma_ddr_in3_awsize  (dma_to_local_mem[3].aw.size),
  .dma_ddr_in3_awburst (dma_to_local_mem[3].aw.burst),
  .dma_ddr_in3_awid    (dma_ddr_in3_awid),
  .dma_ddr_in3_awlen   (dma_to_local_mem[3].aw.len),
  .dma_ddr_in3_awlock  (dma_to_local_mem[3].aw.lock),
  .dma_ddr_in3_awprot  (dma_to_local_mem[3].aw.prot),
  .dma_ddr_in3_awuser  (dma_to_local_mem[3].aw.user),
  .dma_ddr_in3_awqos   (dma_to_local_mem[3].aw.qos),
  .dma_ddr_in3_awregion(dma_to_local_mem[3].aw.region),
  .dma_ddr_in3_awcache (dma_to_local_mem[3].aw.cache),

  .dma_ddr_in3_wvalid  (dma_to_local_mem[3].wvalid),
  .dma_ddr_in3_wready  (dma_to_local_mem[3].wready),
  .dma_ddr_in3_wdata   (dma_to_local_mem[3].w.data),
  .dma_ddr_in3_wstrb   (dma_to_local_mem[3].w.strb),
  .dma_ddr_in3_wlast   (dma_to_local_mem[3].w.last),
  .dma_ddr_in3_wuser   (dma_to_local_mem[3].w.user),

  .dma_ddr_in3_bvalid  (dma_to_local_mem[3].bvalid),
  .dma_ddr_in3_bready  (dma_to_local_mem[3].bready),
  .dma_ddr_in3_bid     (dma_ddr_in3_bid),
  .dma_ddr_in3_bresp   (dma_to_local_mem[3].b.resp),
  .dma_ddr_in3_buser   (dma_to_local_mem[3].b.user),

  // Read channel
  .dma_ddr_in3_arvalid (dma_to_local_mem[3].arvalid),
  .dma_ddr_in3_arready (dma_to_local_mem[3].arready),
  .dma_ddr_in3_araddr  (dma_to_local_mem[3].ar.addr),
  .dma_ddr_in3_arsize  (dma_to_local_mem[3].ar.size),
  .dma_ddr_in3_arburst (dma_to_local_mem[3].ar.burst),
  .dma_ddr_in3_arid    (dma_ddr_in3_arid),
  .dma_ddr_in3_arlen   (dma_to_local_mem[3].ar.len),
  .dma_ddr_in3_arlock  (dma_to_local_mem[3].ar.lock),
  .dma_ddr_in3_arprot  (dma_to_local_mem[3].ar.prot),
  .dma_ddr_in3_arregion(dma_to_local_mem[3].ar.region),
  .dma_ddr_in3_arcache (dma_to_local_mem[3].ar.cache),
  .dma_ddr_in3_arqos   (dma_to_local_mem[3].ar.qos),
  .dma_ddr_in3_aruser  (dma_to_local_mem[3].ar.user),

  .dma_ddr_in3_rvalid  (dma_to_local_mem[3].rvalid),
  .dma_ddr_in3_rready  (dma_to_local_mem[3].rready),
  .dma_ddr_in3_rlast   (dma_to_local_mem[3].r.last),
  .dma_ddr_in3_rdata   (dma_to_local_mem[3].r.data),
  .dma_ddr_in3_rid     (dma_ddr_in3_rid),
  .dma_ddr_in3_rresp   (dma_to_local_mem[3].r.resp),
  .dma_ddr_in3_ruser   (dma_to_local_mem[3].r.user),

  // internal MUX to DDR banks out
  // bank 0
  // Write channel
  .mux_ddr_out0_awvalid (local_mem_to_afu[0].awvalid),
  .mux_ddr_out0_awready (local_mem_to_afu[0].awready), 
  .mux_ddr_out0_awaddr  (local_mem_to_afu[0].aw.addr),
  .mux_ddr_out0_awsize  (local_mem_to_afu[0].aw.size),
  .mux_ddr_out0_awburst (local_mem_to_afu[0].aw.burst),
  .mux_ddr_out0_awprot  (local_mem_to_afu[0].aw.prot),
  .mux_ddr_out0_awid    (mux_ddr_out0_awid),
  .mux_ddr_out0_awlen   (local_mem_to_afu[0].aw.len),
  .mux_ddr_out0_awlock  (local_mem_to_afu[0].aw.lock),
  .mux_ddr_out0_awcache (local_mem_to_afu[0].aw.cache),
  .mux_ddr_out0_awuser  (local_mem_to_afu[0].aw.user),
  .mux_ddr_out0_awqos   (local_mem_to_afu[0].aw.qos),
  .mux_ddr_out0_awregion(local_mem_to_afu[0].aw.region),

  .mux_ddr_out0_wvalid  (local_mem_to_afu[0].wvalid),
  .mux_ddr_out0_wready  (local_mem_to_afu[0].wready),
  .mux_ddr_out0_wlast   (local_mem_to_afu[0].w.last),
  .mux_ddr_out0_wdata   (local_mem_to_afu[0].w.data),
  .mux_ddr_out0_wstrb   (local_mem_to_afu[0].w.strb),
  .mux_ddr_out0_wuser   (local_mem_to_afu[0].w.user),

  .mux_ddr_out0_bvalid  (local_mem_to_afu[0].bvalid),
  .mux_ddr_out0_bready  (local_mem_to_afu[0].bready),
  .mux_ddr_out0_bid     (mux_ddr_out0_bid),
  .mux_ddr_out0_bresp   (local_mem_to_afu[0].b.resp),
  .mux_ddr_out0_buser   (local_mem_to_afu[0].b.user),

  // Read channel
  .mux_ddr_out0_arvalid (local_mem_to_afu[0].arvalid),
  .mux_ddr_out0_arready (local_mem_to_afu[0].arready),
  .mux_ddr_out0_araddr  (local_mem_to_afu[0].ar.addr),
  .mux_ddr_out0_arsize  (local_mem_to_afu[0].ar.size),
  .mux_ddr_out0_arburst (local_mem_to_afu[0].ar.burst),
  .mux_ddr_out0_arprot  (local_mem_to_afu[0].ar.prot),
  .mux_ddr_out0_arid    (mux_ddr_out0_arid),
  .mux_ddr_out0_arlen   (local_mem_to_afu[0].ar.len),
  .mux_ddr_out0_arlock  (local_mem_to_afu[0].ar.lock),
  .mux_ddr_out0_arregion(local_mem_to_afu[0].ar.region),
  .mux_ddr_out0_arcache (local_mem_to_afu[0].ar.cache),
  .mux_ddr_out0_arqos   (local_mem_to_afu[0].ar.qos),
  .mux_ddr_out0_aruser  (local_mem_to_afu[0].ar.user),

  .mux_ddr_out0_rvalid  (local_mem_to_afu[0].rvalid),
  .mux_ddr_out0_rready  (local_mem_to_afu[0].rready),
  .mux_ddr_out0_rdata   (local_mem_to_afu[0].r.data),
  .mux_ddr_out0_rid     (mux_ddr_out0_rid),
  .mux_ddr_out0_rresp   (local_mem_to_afu[0].r.resp),
  .mux_ddr_out0_rlast   (local_mem_to_afu[0].r.last),
  .mux_ddr_out0_ruser   (local_mem_to_afu[0].r.user),

  // bank 1
  // Write channel
  .mux_ddr_out1_awvalid (local_mem_to_afu[1].awvalid),
  .mux_ddr_out1_awready (local_mem_to_afu[1].awready), 
  .mux_ddr_out1_awaddr  (local_mem_to_afu[1].aw.addr),
  .mux_ddr_out1_awsize  (local_mem_to_afu[1].aw.size),
  .mux_ddr_out1_awburst (local_mem_to_afu[1].aw.burst),
  .mux_ddr_out1_awprot  (local_mem_to_afu[1].aw.prot),
  .mux_ddr_out1_awid    (mux_ddr_out1_awid),
  .mux_ddr_out1_awlen   (local_mem_to_afu[1].aw.len),
  .mux_ddr_out1_awlock  (local_mem_to_afu[1].aw.lock),
  .mux_ddr_out1_awcache (local_mem_to_afu[1].aw.cache),
  .mux_ddr_out1_awuser  (local_mem_to_afu[1].aw.user),
  .mux_ddr_out1_awqos   (local_mem_to_afu[1].aw.qos),
  .mux_ddr_out1_awregion(local_mem_to_afu[1].aw.region),

  .mux_ddr_out1_wvalid  (local_mem_to_afu[1].wvalid),
  .mux_ddr_out1_wready  (local_mem_to_afu[1].wready),
  .mux_ddr_out1_wlast   (local_mem_to_afu[1].w.last),
  .mux_ddr_out1_wdata   (local_mem_to_afu[1].w.data),
  .mux_ddr_out1_wstrb   (local_mem_to_afu[1].w.strb),
  .mux_ddr_out1_wuser   (local_mem_to_afu[1].w.user),

  .mux_ddr_out1_bvalid  (local_mem_to_afu[1].bvalid),
  .mux_ddr_out1_bready  (local_mem_to_afu[1].bready),
  .mux_ddr_out1_bid     (mux_ddr_out1_bid),
  .mux_ddr_out1_bresp   (local_mem_to_afu[1].b.resp),
  .mux_ddr_out1_buser   (local_mem_to_afu[1].b.user),

  // Read channel
  .mux_ddr_out1_arvalid (local_mem_to_afu[1].arvalid),
  .mux_ddr_out1_arready (local_mem_to_afu[1].arready),
  .mux_ddr_out1_araddr  (local_mem_to_afu[1].ar.addr),
  .mux_ddr_out1_arsize  (local_mem_to_afu[1].ar.size),
  .mux_ddr_out1_arburst (local_mem_to_afu[1].ar.burst),
  .mux_ddr_out1_arprot  (local_mem_to_afu[1].ar.prot),
  .mux_ddr_out1_arid    (mux_ddr_out1_arid),
  .mux_ddr_out1_arlen   (local_mem_to_afu[1].ar.len),
  .mux_ddr_out1_arlock  (local_mem_to_afu[1].ar.lock),
  .mux_ddr_out1_arregion(local_mem_to_afu[1].ar.region),
  .mux_ddr_out1_arcache (local_mem_to_afu[1].ar.cache),
  .mux_ddr_out1_arqos   (local_mem_to_afu[1].ar.qos),
  .mux_ddr_out1_aruser  (local_mem_to_afu[1].ar.user),

  .mux_ddr_out1_rvalid  (local_mem_to_afu[1].rvalid),
  .mux_ddr_out1_rready  (local_mem_to_afu[1].rready),
  .mux_ddr_out1_rdata   (local_mem_to_afu[1].r.data),
  .mux_ddr_out1_rid     (mux_ddr_out1_rid),
  .mux_ddr_out1_rresp   (local_mem_to_afu[1].r.resp),
  .mux_ddr_out1_rlast   (local_mem_to_afu[1].r.last),
  .mux_ddr_out1_ruser   (local_mem_to_afu[1].r.user),

  // bank 2
  // Write channel
  .mux_ddr_out2_awvalid (local_mem_to_afu[2].awvalid),
  .mux_ddr_out2_awready (local_mem_to_afu[2].awready), 
  .mux_ddr_out2_awaddr  (local_mem_to_afu[2].aw.addr),
  .mux_ddr_out2_awsize  (local_mem_to_afu[2].aw.size),
  .mux_ddr_out2_awburst (local_mem_to_afu[2].aw.burst),
  .mux_ddr_out2_awprot  (local_mem_to_afu[2].aw.prot),
  .mux_ddr_out2_awid    (mux_ddr_out2_awid),
  .mux_ddr_out2_awlen   (local_mem_to_afu[2].aw.len),
  .mux_ddr_out2_awlock  (local_mem_to_afu[2].aw.lock),
  .mux_ddr_out2_awcache (local_mem_to_afu[2].aw.cache),
  .mux_ddr_out2_awuser  (local_mem_to_afu[2].aw.user),
  .mux_ddr_out2_awqos   (local_mem_to_afu[2].aw.qos),
  .mux_ddr_out2_awregion(local_mem_to_afu[2].aw.region),

  .mux_ddr_out2_wvalid  (local_mem_to_afu[2].wvalid),
  .mux_ddr_out2_wready  (local_mem_to_afu[2].wready),
  .mux_ddr_out2_wlast   (local_mem_to_afu[2].w.last),
  .mux_ddr_out2_wdata   (local_mem_to_afu[2].w.data),
  .mux_ddr_out2_wstrb   (local_mem_to_afu[2].w.strb),
  .mux_ddr_out2_wuser   (local_mem_to_afu[2].w.user),

  .mux_ddr_out2_bvalid  (local_mem_to_afu[2].bvalid),
  .mux_ddr_out2_bready  (local_mem_to_afu[2].bready),
  .mux_ddr_out2_bid     (mux_ddr_out2_bid),
  .mux_ddr_out2_bresp   (local_mem_to_afu[2].b.resp),
  .mux_ddr_out2_buser   (local_mem_to_afu[2].b.user),

  // Read channel
  .mux_ddr_out2_arvalid (local_mem_to_afu[2].arvalid),
  .mux_ddr_out2_arready (local_mem_to_afu[2].arready),
  .mux_ddr_out2_araddr  (local_mem_to_afu[2].ar.addr),
  .mux_ddr_out2_arsize  (local_mem_to_afu[2].ar.size),
  .mux_ddr_out2_arburst (local_mem_to_afu[2].ar.burst),
  .mux_ddr_out2_arprot  (local_mem_to_afu[2].ar.prot),
  .mux_ddr_out2_arid    (mux_ddr_out2_arid),
  .mux_ddr_out2_arlen   (local_mem_to_afu[2].ar.len),
  .mux_ddr_out2_arlock  (local_mem_to_afu[2].ar.lock),
  .mux_ddr_out2_arregion(local_mem_to_afu[2].ar.region),
  .mux_ddr_out2_arcache (local_mem_to_afu[2].ar.cache),
  .mux_ddr_out2_arqos   (local_mem_to_afu[2].ar.qos),
  .mux_ddr_out2_aruser  (local_mem_to_afu[2].ar.user),

  .mux_ddr_out2_rvalid  (local_mem_to_afu[2].rvalid),
  .mux_ddr_out2_rready  (local_mem_to_afu[2].rready),
  .mux_ddr_out2_rdata   (local_mem_to_afu[2].r.data),
  .mux_ddr_out2_rid     (mux_ddr_out2_rid),
  .mux_ddr_out2_rresp   (local_mem_to_afu[2].r.resp),
  .mux_ddr_out2_rlast   (local_mem_to_afu[2].r.last),
  .mux_ddr_out2_ruser   (local_mem_to_afu[2].r.user),

  // bank 3
  // Write channel
  .mux_ddr_out3_awvalid (local_mem_to_afu[3].awvalid),
  .mux_ddr_out3_awready (local_mem_to_afu[3].awready), 
  .mux_ddr_out3_awaddr  (local_mem_to_afu[3].aw.addr),
  .mux_ddr_out3_awsize  (local_mem_to_afu[3].aw.size),
  .mux_ddr_out3_awburst (local_mem_to_afu[3].aw.burst),
  .mux_ddr_out3_awprot  (local_mem_to_afu[3].aw.prot),
  .mux_ddr_out3_awid    (mux_ddr_out3_awid),
  .mux_ddr_out3_awlen   (local_mem_to_afu[3].aw.len),
  .mux_ddr_out3_awlock  (local_mem_to_afu[3].aw.lock),
  .mux_ddr_out3_awcache (local_mem_to_afu[3].aw.cache),
  .mux_ddr_out3_awuser  (local_mem_to_afu[3].aw.user),
  .mux_ddr_out3_awqos   (local_mem_to_afu[3].aw.qos),
  .mux_ddr_out3_awregion(local_mem_to_afu[3].aw.region),

  .mux_ddr_out3_wvalid  (local_mem_to_afu[3].wvalid),
  .mux_ddr_out3_wready  (local_mem_to_afu[3].wready),
  .mux_ddr_out3_wlast   (local_mem_to_afu[3].w.last),
  .mux_ddr_out3_wdata   (local_mem_to_afu[3].w.data),
  .mux_ddr_out3_wstrb   (local_mem_to_afu[3].w.strb),
  .mux_ddr_out3_wuser   (local_mem_to_afu[3].w.user),

  .mux_ddr_out3_bvalid  (local_mem_to_afu[3].bvalid),
  .mux_ddr_out3_bready  (local_mem_to_afu[3].bready),
  .mux_ddr_out3_bid     (mux_ddr_out3_bid),
  .mux_ddr_out3_bresp   (local_mem_to_afu[3].b.resp),
  .mux_ddr_out3_buser   (local_mem_to_afu[3].b.user),

  // Read channel
  .mux_ddr_out3_arvalid (local_mem_to_afu[3].arvalid),
  .mux_ddr_out3_arready (local_mem_to_afu[3].arready),
  .mux_ddr_out3_araddr  (local_mem_to_afu[3].ar.addr),
  .mux_ddr_out3_arsize  (local_mem_to_afu[3].ar.size),
  .mux_ddr_out3_arburst (local_mem_to_afu[3].ar.burst),
  .mux_ddr_out3_arprot  (local_mem_to_afu[3].ar.prot),
  .mux_ddr_out3_arid    (mux_ddr_out3_arid),
  .mux_ddr_out3_arlen   (local_mem_to_afu[3].ar.len),
  .mux_ddr_out3_arlock  (local_mem_to_afu[3].ar.lock),
  .mux_ddr_out3_arregion(local_mem_to_afu[3].ar.region),
  .mux_ddr_out3_arcache (local_mem_to_afu[3].ar.cache),
  .mux_ddr_out3_arqos   (local_mem_to_afu[3].ar.qos),
  .mux_ddr_out3_aruser  (local_mem_to_afu[3].ar.user),

  .mux_ddr_out3_rvalid  (local_mem_to_afu[3].rvalid),
  .mux_ddr_out3_rready  (local_mem_to_afu[3].rready),
  .mux_ddr_out3_rdata   (local_mem_to_afu[3].r.data),
  .mux_ddr_out3_rid     (mux_ddr_out3_rid),
  .mux_ddr_out3_rresp   (local_mem_to_afu[3].r.resp),
  .mux_ddr_out3_rlast   (local_mem_to_afu[3].r.last),
  .mux_ddr_out3_ruser   (local_mem_to_afu[3].r.user),

  // Avalon master for HW timer, for inferring CoreDLA clock frequency from host
  .dla_hw_timer_waitrequest   (1'b0),                   // no backpressure
  .dla_hw_timer_readdata      (dla_hw_timer_readdata),
  .dla_hw_timer_readdatavalid (dla_hw_timer_read),      // respond immediately
  .dla_hw_timer_burstcount    (),                       // output ignored
  .dla_hw_timer_writedata     (dla_hw_timer_writedata),
  .dla_hw_timer_address       (),                       // output ignored
  .dla_hw_timer_write         (dla_hw_timer_write),
  .dla_hw_timer_read          (dla_hw_timer_read),
  .dla_hw_timer_byteenable    (),                       // output ignored
  .dla_hw_timer_debugaccess   ()                        // output ignored
);

// width adaptation of AXI4 ID signals
// output of MUX
assign local_mem_to_afu[0].aw.id = {mux_ddr_out0_awid[17:16],mux_ddr_out0_awid[6:0]};
assign local_mem_to_afu[0].ar.id = {mux_ddr_out0_arid[17:16],mux_ddr_out0_arid[6:0]};
assign mux_ddr_out0_bid         = {local_mem_to_afu[0].b.id[8:7],9'b0,local_mem_to_afu[0].b.id[6:0]}; 
assign mux_ddr_out0_rid         = {local_mem_to_afu[0].r.id[8:7],9'b0,local_mem_to_afu[0].r.id[6:0]};
assign local_mem_to_afu[1].aw.id = {mux_ddr_out1_awid[17:16],mux_ddr_out1_awid[6:0]};
assign local_mem_to_afu[1].ar.id = {mux_ddr_out1_arid[17:16],mux_ddr_out1_arid[6:0]};
assign mux_ddr_out1_bid         = {local_mem_to_afu[1].b.id[8:7],9'b0,local_mem_to_afu[1].b.id[6:0]}; 
assign mux_ddr_out1_rid         = {local_mem_to_afu[1].r.id[8:7],9'b0,local_mem_to_afu[1].r.id[6:0]};
assign local_mem_to_afu[2].aw.id = {mux_ddr_out2_awid[17:16],mux_ddr_out2_awid[6:0]};
assign local_mem_to_afu[2].ar.id = {mux_ddr_out2_arid[17:16],mux_ddr_out2_arid[6:0]};
assign mux_ddr_out2_bid         = {local_mem_to_afu[2].b.id[8:7],9'b0,local_mem_to_afu[2].b.id[6:0]}; 
assign mux_ddr_out2_rid         = {local_mem_to_afu[2].r.id[8:7],9'b0,local_mem_to_afu[2].r.id[6:0]};
assign local_mem_to_afu[3].aw.id = {mux_ddr_out3_awid[17:16],mux_ddr_out3_awid[6:0]};
assign local_mem_to_afu[3].ar.id = {mux_ddr_out3_arid[17:16],mux_ddr_out3_arid[6:0]};
assign mux_ddr_out3_bid         = {local_mem_to_afu[3].b.id[8:7],9'b0,local_mem_to_afu[3].b.id[6:0]}; 
assign mux_ddr_out3_rid         = {local_mem_to_afu[3].r.id[8:7],9'b0,local_mem_to_afu[3].r.id[6:0]};

// DLA IP inputs
assign dla_ddr_in0_arid = {14'b0,dla_ddr_arid[0]};
assign dla_ddr_rid[0] = {dla_ddr_in0_rid[1:0]};
assign dla_ddr_in1_arid = {14'b0,dla_ddr_arid[1]};
assign dla_ddr_rid[1] = {dla_ddr_in1_rid[1:0]};
assign dla_ddr_in2_arid = {14'b0,dla_ddr_arid[2]};
assign dla_ddr_rid[2] = {dla_ddr_in2_rid[1:0]};
assign dla_ddr_in3_arid = {14'b0,dla_ddr_arid[3]};
assign dla_ddr_rid[3] = {dla_ddr_in3_rid[1:0]};
assign dla_ddr_awid[0] = 16'h0000;
assign dla_ddr_awid[1] = 16'h0001;
assign dla_ddr_awid[2] = 16'h0010;
assign dla_ddr_awid[3] = 16'h0011;

// DMA DDR inputs
assign dma_ddr_in0_awid = {7'b0,dma_to_local_mem[0].aw.id};
assign dma_ddr_in0_arid = {7'b0,dma_to_local_mem[0].ar.id};
assign dma_to_local_mem[0].b.id = dma_ddr_in0_bid[8:0];
assign dma_to_local_mem[0].r.id = dma_ddr_in0_rid[8:0];
assign dma_ddr_in1_awid = {7'b0,dma_to_local_mem[1].aw.id};
assign dma_ddr_in1_arid = {7'b0,dma_to_local_mem[1].ar.id};
assign dma_to_local_mem[1].b.id = dma_ddr_in1_bid[8:0];
assign dma_to_local_mem[1].r.id = dma_ddr_in1_rid[8:0];
assign dma_ddr_in2_awid = {7'b0,dma_to_local_mem[2].aw.id};
assign dma_ddr_in2_arid = {7'b0,dma_to_local_mem[2].ar.id};
assign dma_to_local_mem[2].b.id = dma_ddr_in2_bid[8:0];
assign dma_to_local_mem[2].r.id = dma_ddr_in2_rid[8:0];
assign dma_ddr_in3_awid = {7'b0,dma_to_local_mem[3].aw.id};
assign dma_ddr_in3_arid = {7'b0,dma_to_local_mem[3].ar.id};
assign dma_to_local_mem[3].b.id = dma_ddr_in3_bid[8:0];
assign dma_to_local_mem[3].r.id = dma_ddr_in3_rid[8:0];

// DMA CSR inputs
assign mmio64_to_afu_dma.aw.addr = {4'b0,dma_csr_awaddr};
assign mmio64_to_afu_dma.ar.addr = {4'b0,dma_csr_araddr};
assign mmio64_to_afu_dma.aw.id   = dma_csr_awid[0];
assign dma_csr_bid               = {17'b0,mmio64_to_afu_dma.b.id};
assign mmio64_to_afu_dma.ar.id   = dma_csr_arid[10:0];
assign dma_csr_rid               = {7'b0,mmio64_to_afu_dma.r.id};

// MMIO64 CSR inputs
assign mmio_control_awid  = {15'b0,mmio64_to_afu.aw.id};
assign mmio64_to_afu.b.id = mmio_control_bid[0];
assign mmio_control_arid  = {5'b0,mmio64_to_afu.ar.id};
assign mmio64_to_afu.r.id = mmio_control_rid[10:0];

// Mapping of Avalon interface to the HW timer signals
assign dla_hw_timer_start    = dla_hw_timer_write & dla_hw_timer_writedata[0];
assign dla_hw_timer_stop     = dla_hw_timer_write & dla_hw_timer_writedata[1];
assign dla_hw_timer_readdata = dla_hw_timer_counter;

// =========================================================================
//
// Instantiate the DMA 
//
// =========================================================================
dma_top  
#(
  .NUM_LOCAL_MEM_BANKS(MAX_DLA_INSTANCES),
  .DDR_ADDR_W(DDR_ADDR_W),
  .HOST_ADDR_W(HOST_ADDR_W)
) dma_top_inst
(
  .mmio64_to_afu(mmio64_to_afu_dma),
  .host_mem(host_mem_mux),
  .ddr_mem(dma_to_local_mem)
);

// =========================================================================
//
// Instantiate the DLA Wrapper
//
// =========================================================================
dla_platform_wrapper 
#(
  .C_CSR_AXI_ADDR_WIDTH      (C_CSR_AXI_ADDR_WIDTH),
  .C_CSR_AXI_DATA_WIDTH      (C_CSR_AXI_DATA_WIDTH),
  .C_DDR_AXI_ADDR_WIDTH      (C_DDR_AXI_ADDR_WIDTH),
  .C_DDR_AXI_DATA_WIDTH      (C_DDR_AXI_DATA_WIDTH),
  .C_DDR_AXI_BURST_WIDTH     (C_DDR_AXI_BURST_WIDTH),
  .C_DDR_AXI_THREAD_ID_WIDTH (C_DDR_AXI_THREAD_ID_WIDTH),
  .MAX_DLA_INSTANCES         (MAX_DLA_INSTANCES),
  .HW_TIMER_WIDTH            (HW_TIMER_WIDTH),
  .ENABLE_INPUT_STREAMING    (ENABLE_INPUT_STREAMING),
  .AXI_ISTREAM_DATA_WIDTH    (AXI_ISTREAM_DATA_WIDTH),
  .AXI_ISTREAM_FIFO_DEPTH    (AXI_ISTREAM_FIFO_DEPTH),
  .ENABLE_OUTPUT_STREAMER    (ENABLE_OUTPUT_STREAMER),
  .AXI_OSTREAM_DATA_WIDTH    (AXI_OSTREAM_DATA_WIDTH),
  .AXI_OSTREAM_FIFO_DEPTH    (AXI_OSTREAM_FIFO_DEPTH)
) dla_platform_inst
(
  // clocks and resets
  .clk_dla                   (clk_dla),
  .clk_ddr                   (clk_ddr), 
  .clk_pcie                  (clk_wrapper),
  .i_resetn_dla              (sw_reset_n),
  .i_resetn_ddr              (resetn_ddr),
  .i_resetn_pcie             (sw_reset_n),

  // interrupt request, AXI4 stream master without data, runs on pcie clock
  .o_interrupt_level         (irq), 

  // AXI subordinate interfaces for CSR
  .i_csr_arvalid             (dla_csr_arvalid),
  .i_csr_araddr              (dla_csr_araddr),
  .o_csr_arready             (dla_csr_arready),
  .o_csr_rvalid              (dla_csr_rvalid),
  .o_csr_rdata               (dla_csr_rdata),
  .i_csr_rready              (dla_csr_rready),
  .i_csr_awvalid             (dla_csr_awvalid),
  .i_csr_awaddr              (dla_csr_awaddr),
  .o_csr_awready             (dla_csr_awready),
  .i_csr_wvalid              (dla_csr_wvalid),
  .i_csr_wdata               (dla_csr_wdata),
  .o_csr_wready              (dla_csr_wready),
  .o_csr_bvalid              (dla_csr_bvalid),
  .i_csr_bready              (dla_csr_bready), 

  // AXI manager interfaces for DDR
  .o_ddr_arvalid             (dla_ddr_arvalid),
  .o_ddr_araddr              (dla_ddr_araddr),
  .o_ddr_arlen               (dla_ddr_arlen),
  .o_ddr_arsize              (dla_ddr_arsize),
  .o_ddr_arburst             (dla_ddr_arburst),
  .o_ddr_arid                (dla_ddr_arid),
  .i_ddr_arready             (dla_ddr_arready),
  .i_ddr_rvalid              (dla_ddr_rvalid),
  .i_ddr_rdata               (dla_ddr_rdata),
  .i_ddr_rid                 (dla_ddr_rid),
  .o_ddr_rready              (dla_ddr_rready),
  .o_ddr_awvalid             (dla_ddr_awvalid),
  .o_ddr_awaddr              (dla_ddr_awaddr),
  .o_ddr_awlen               (dla_ddr_awlen),
  .o_ddr_awsize              (dla_ddr_awsize),
  .o_ddr_awburst             (dla_ddr_awburst),
  .i_ddr_awready             (dla_ddr_awready),
  .o_ddr_wvalid              (dla_ddr_wvalid),
  .o_ddr_wdata               (dla_ddr_wdata),
  .o_ddr_wstrb               (dla_ddr_wstrb),
  .o_ddr_wlast               (dla_ddr_wlast),
  .i_ddr_wready              (dla_ddr_wready),
  .i_ddr_bvalid              (dla_ddr_bvalid),
  .o_ddr_bready              (dla_ddr_bready),

  // HW timer, for inferring CoreDLA clock frequency from host 
  .i_hw_timer_start          (dla_hw_timer_start),
  .i_hw_timer_stop           (dla_hw_timer_stop),
  .o_hw_timer_counter        (dla_hw_timer_counter)
);

// mux the interrupt into the host memory interface
dla_host_mem_if_mux dla_host_mem_if_mux_inst 
(
  .clk(clk_wrapper),
  .reset(!resetn_wrapper),
  .irq({2'b0,irq,1'b0}),
  .dma_mem_if(host_mem_mux),
  .host_mem_if(host_mem)
);

endmodule

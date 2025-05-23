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

// import dma_pkg::*;

//
// DMA top-level. Take in a pair of AXI-MM interfaces, one for CSRs and
// one for reading and writing host memory.
//
// This engine can be instantiated either from a full-PIM system using
// ofs_plat_afu()
//

module dma_top #(
    parameter NUM_LOCAL_MEM_BANKS = 1,
    parameter DDR_ADDR_W = 35,
    parameter HOST_ADDR_W = 57
)(
    // CSR interface (MMIO on the host)
    ofs_plat_axi_mem_lite_if.to_source mmio64_to_afu,

    // Host memory (DMA)
    ofs_plat_axi_mem_if.to_sink host_mem,
    ofs_plat_axi_mem_if.to_sink ddr_mem[NUM_LOCAL_MEM_BANKS]
);

    // Each interface names its associated clock and reset.
    logic clk;
    assign clk = host_mem.clk;
    logic reset_n;
    assign reset_n = host_mem.reset_n;
    assign src_mem.clk = clk; 
    assign src_mem.reset_n = reset_n; 
    assign dest_mem.clk = clk; 
    assign dest_mem.reset_n = reset_n; 

    // ====================================================================
    //
    // CSR (MMIO) manager. Handle all MMIO reads and writes from the host
    // and share the CSR Map with the DMA Engine and AXI interconnect.
    //
    // ====================================================================

    dma_pkg::t_dma_csr_map dma_csr_map; //RO
    dma_pkg::t_dma_csr_status dma_csr_status;
    dma_pkg::t_dma_csr_status wr_dest_status;
    dma_pkg::t_dma_csr_status rd_src_status;
    dma_pkg::t_dma_csr_status dma_engine_status;
    dma_pkg::t_dma_descriptor dma_descriptor;
    dma_fifo_if #(.DATA_W ($bits(dma_pkg::t_dma_descriptor))) wr_desc_fifo_if();
    dma_fifo_if #(.DATA_W ($bits(dma_pkg::t_dma_descriptor))) rd_desc_fifo_if();
    logic descriptor_fifo_rdack;
    logic descriptor_fifo_not_empty;
    logic descriptor_fifo_not_full;

    always_comb begin
       wr_desc_fifo_if.wr_data                     = dma_csr_map.descriptor;
       wr_desc_fifo_if.wr_en                       = dma_csr_map.descriptor.descriptor_control.go;
       rd_desc_fifo_if.rd_en                       = descriptor_fifo_rdack;
       dma_descriptor                              = rd_desc_fifo_if.rd_data;
       descriptor_fifo_not_empty                   = rd_desc_fifo_if.not_empty;
       dma_csr_status                              = 0;
       dma_csr_status.rsvd_63_30                   = 0;
       dma_csr_status.dma_mode                     = dma_descriptor.descriptor_control.mode;
       dma_csr_status.wr_dest_perf_cntr            = wr_dest_status.wr_dest_perf_cntr;
       dma_csr_status.rd_src_perf_cntr             = rd_src_status.rd_src_perf_cntr;
       dma_csr_status.descriptor_count             = rd_src_status.descriptor_count;
       dma_csr_status.rd_state                     = rd_src_status.rd_state;
       dma_csr_status.wr_state                     = wr_dest_status.wr_state;
       dma_csr_status.rd_resp_enc                  = '0;
       dma_csr_status.rd_rsp_err                   = rd_src_status.rd_rsp_err;
       dma_csr_status.wr_resp_enc                  = '0;
       dma_csr_status.wr_rsp_err                   = wr_dest_status.wr_rsp_err;
       dma_csr_status.stopped_on_error             = wr_dest_status.stopped_on_error | rd_src_status.stopped_on_error; 
       dma_csr_status.resetting                    = '0; 
       dma_csr_status.stopped                      = '0; 
       dma_csr_status.response_fifo_full           = dma_engine_status.response_fifo_full;
       dma_csr_status.response_fifo_empty          = dma_engine_status.response_fifo_empty;
       dma_csr_status.descriptor_fifo_full         = ~wr_desc_fifo_if.not_full;
       dma_csr_status.descriptor_fifo_empty        = ~rd_desc_fifo_if.not_empty;
       dma_csr_status.busy                         = wr_dest_status.busy | rd_src_status.busy;
     end


    csr_mgr #(
    ) csr_mgr_inst (
        .mmio64_to_afu,
        .dma_csr_map,
        .dma_csr_status
    );

    ofs_plat_prim_fifo_bram #(
      .N_DATA_BITS  ($bits(dma_pkg::t_dma_descriptor)),
      .N_ENTRIES    (dma_pkg::DMA_DESCRIPTOR_FIFO_DEPTH)
    ) descriptor_fifo_inst (
      .clk,
      .reset_n,

      .enq_data(wr_desc_fifo_if.wr_data),
      .enq_en(wr_desc_fifo_if.wr_en),
      .notFull(wr_desc_fifo_if.not_full),
      .almostFull(),

      .first(rd_desc_fifo_if.rd_data),
      .deq_en(rd_desc_fifo_if.rd_en & !dma_csr_map.control.stop_descriptors),
      .notEmpty(rd_desc_fifo_if.not_empty)
    );


    // ====================================================================
    //
    // Simplified AXI Interconnect  
    //
    // The dma_ddr_selector and dma_axi_mm_mux work in tandem to act as 
    // a simplified AXI interconnect.  The dma_ddr_selector allows the user
    // to select the ddr back they wish to operate on, and the 
    // dma_axi_mm_mux reroutes the AXI signals to the engine based on the 
    // mode, or direction, of the transfer.
    //  
    // ====================================================================

    ofs_plat_axi_mem_if #(
        // Copy the configuration from host_mem
        `OFS_PLAT_AXI_MEM_IF_REPLICATE_PARAMS(host_mem)
    ) dest_mem();

    ofs_plat_axi_mem_if #(
      `LOCAL_MEM_AXI_MEM_PARAMS_DEFAULT
     ) src_mem();

    ofs_plat_axi_mem_if #(
      // Copy the configuration from ddr_mem
      `LOCAL_MEM_AXI_MEM_PARAMS_DEFAULT
    ) selected_ddr_mem();

    dma_ddr_selector #(
        .NUM_LOCAL_MEM_BANKS (NUM_LOCAL_MEM_BANKS),
        .ADDR_WIDTH(DDR_ADDR_W) 
    ) ddr_selector (
        .descriptor(dma_descriptor),
        .selected_ddr_mem,
        .ddr_mem
     );

    dma_axi_mm_mux #(
    ) dma_axi_mm_mux (
        .clk,
        .reset_n,
        .mode (dma_descriptor.descriptor_control.mode),
        .src_mem,
        .dest_mem,
        .host_mem,
        .ddr_mem(selected_ddr_mem)
    );
    // ====================================================================
    //
    // DMA Engine  
    //
    // ====================================================================
   
    dma_engine #(
      .DDR_ADDR_W(DDR_ADDR_W),
      .HOST_ADDR_W(HOST_ADDR_W)
    ) dma_engine_inst (
        .clk,
        .reset_n,
        .src_mem,
        .dest_mem,
        .descriptor_fifo_not_empty,
        .descriptor_fifo_rdack,
        .descriptor (dma_descriptor),

        // Commands
        .csr_control (dma_csr_map.control),
        .wr_dest_status,
        .rd_src_status,
        .dma_engine_status
    );


endmodule

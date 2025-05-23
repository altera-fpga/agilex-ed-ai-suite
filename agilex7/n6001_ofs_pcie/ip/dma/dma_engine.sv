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

// dma_engine is responsible for servicing each DMA transaction with the information 
// provided by the descriptors. It contains a read and write engine, with a data FIFO 
// in between.  When a descriptor is committed, the read engine dma_read_engine will 
// use the information in the descriptors to issue a read request, where the read 
// data is then written to the data FIFO. The write engine dma_write_engine will use
// the information in the descriptor to read the FIFO and write the data to the 
// destination address. 

module dma_engine #(
    parameter MODE = dma_pkg::STAND_BY,
    parameter DDR_ADDR_W = 35,
    parameter HOST_ADDR_W = 57
   )(
      input  logic  clk,
      input  logic  reset_n,
      input  logic descriptor_fifo_not_empty,
      output logic descriptor_fifo_rdack,
      input  dma_pkg::t_dma_descriptor descriptor,
      ofs_plat_axi_mem_if.to_sink src_mem,
      ofs_plat_axi_mem_if.to_sink dest_mem,

      input  dma_pkg::t_dma_csr_control csr_control,
      output dma_pkg::t_dma_csr_status  wr_dest_status,
      output dma_pkg::t_dma_csr_status  rd_src_status,
      output dma_pkg::t_dma_csr_status  dma_engine_status
   );

   localparam SRC_ADDR_W  = (MODE == dma_pkg::DDR_TO_HOST) ? DDR_ADDR_W : HOST_ADDR_W;
   localparam DEST_ADDR_W = (MODE == dma_pkg::HOST_TO_DDR) ? DDR_ADDR_W : HOST_ADDR_W;
   localparam FIFO_DATA_W = dma_pkg::AXI_MM_DATA_W + 2;

   logic wr_fsm_done;
   dma_fifo_if #(.DATA_W (FIFO_DATA_W)) wr_fifo_if();
   dma_fifo_if #(.DATA_W (FIFO_DATA_W)) rd_fifo_if();


   always_comb begin
       dma_engine_status.response_fifo_full = !wr_fifo_if.not_full;
       dma_engine_status.response_fifo_empty = !rd_fifo_if.not_empty;
   end

   dma_write_engine #(
      .DATA_W (FIFO_DATA_W)
   ) dma_write_engine_inst (
      .clk,
      .reset_n,
      .wr_fsm_done,
      .descriptor_fifo_not_empty,
      .descriptor,
      .wr_dest_status,
      .csr_control,
      .dest_mem,
      .rd_fifo_if
   );
   
   ofs_plat_prim_fifo_bram #(
      .N_DATA_BITS (FIFO_DATA_W),
      .N_ENTRIES   (dma_pkg::DMA_DATA_FIFO_DEPTH)
   ) dma_fifo (
      .clk,
      .reset_n,

      .enq_data   (wr_fifo_if.wr_data),
      .enq_en     (wr_fifo_if.wr_en),
      .notFull    (wr_fifo_if.not_full),
      .almostFull (wr_fifo_if.almost_full),

      // Pop the next command if the read request was sent to the host
      .deq_en   (rd_fifo_if.rd_en),
      .notEmpty (rd_fifo_if.not_empty),
      .first    (rd_fifo_if.rd_data) 
   ); 

   dma_read_engine #(
      .DATA_W (FIFO_DATA_W)
   ) dma_read_engine_inst (
      .clk,
      .reset_n,
      .wr_fsm_done,
      .descriptor,
      .rd_src_status, 
      .descriptor_fifo_not_empty,
      .descriptor_fifo_rdack,
      .src_mem,
      .wr_fifo_if
   );

endmodule // copy_write_engine

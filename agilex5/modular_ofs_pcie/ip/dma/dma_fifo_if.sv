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

interface dma_fifo_if  #(
  parameter DATA_W = dma_pkg::AXI_MM_DATA_W + dma_pkg::SRC_ADDR_W
);

   logic [DATA_W-1:0] wr_data;
   logic [DATA_W-1:0] rd_data;
   logic wr_en;
   logic almost_full;
   logic rd_en;
   logic not_full;
   logic not_empty;

   modport wr_in (
      input wr_en,
      input wr_data,
      output almost_full,
      output not_full
   );

   modport wr_out (
      output wr_en,
      output wr_data,
      input almost_full,
      input  not_full
   );

   modport rd_in (
      input rd_en,
      output not_empty,
      output rd_data  
   );

   modport rd_out (
      output rd_en,
      input not_empty,
      input rd_data  
   );

endinterface : dma_fifo_if


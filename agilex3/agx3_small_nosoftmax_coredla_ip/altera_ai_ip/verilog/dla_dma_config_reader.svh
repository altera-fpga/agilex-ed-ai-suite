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

/*
  This is the packed struct used by the DMA module for the HW to read config values from DDR
*/

typedef struct packed {
  // DO NOT TOUCH ORDER OF FIELDS
  // if you wanted to add/edit configs, you must take into account the order of fpga/dma/dla_dma_csr.sv in the state[STATE_DESCRIPTOR_BIT] block
  // the order here must match there in reverse (system verilog semantics)
  dma_config_reader_loop loop_increment; // address increment on each iteration for each level
  dma_config_reader_loop loop_count;     // number of iterations for each level of loop nesting
  uint32_t token;                        // flag to if readers should wait for a token
  uint32_t base_addr;                    // first address to read from
} dma_config_reader_t;

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
  This is the packed struct used for the DMA module
  More specifically, it is the config layout for the feature_reader aspect of the DMA module
*/

typedef struct packed {
  dma_config_feature_reader_loop loop_increment; // address increment on each iteration for each level
  dma_config_feature_reader_loop loop_count;     // number of iterations for each level of loop nesting
  uint32_t use_lt;                               // flag to indicate if feature reader should do layout transform or not
  uint32_t wait_token;                           // flag to if readers should wait for a token
  // base_addr MUST be at the bottom because it has special add_op instructions.
  // is the first word written for now in order to set the special add_op instructions.
  // other struct field orders can change
  // base addr indicates the first address to read from
  uint32_t base_addr;
} dma_config_feature_reader_t;

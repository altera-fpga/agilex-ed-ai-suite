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
  This is the shared datatype between C++ compiler config generation and output streamer RTL
*/
typedef struct packed {
  uint32_t   valid_bytes_stream_width;    // number of valid bytes for last transfer of one HW pixel, used to drive the tstrb signal
  int16_t    transfers_per_hw_pixel;      // total number of AXI transfers for one pixel in HW (all output channels of one pixel)
  int32_t    total_transfers;             // total number of AXI transfers for a layer given the AXI data width
  int32_t    total_transfers_adjusted;    // total number of AXI transfers for a layer minus the last invalid transactions if any
  int16_t    last_index;                  // index of transaction within a single HW pixel where some valid and invalid elements exist
  uint8_t    last_stream;                 // bool to determine if this is the last stream to generate the tlast signal (mainly for multi-output support)
  int8_t     padding1;                    // padding for 4 byte allignment
  int16_t    padding2;
} output_streamer_config_t;

typedef struct packed {
  int32_t    total_transfers;             // total number of input transactions from xbar to output streamer width adapter
  uint32_t   transfers_per_hw_pixel;      // total number of xbar transfers for one pixel in HW (all output channels of one pixel)
  int32_t    flush_index;                 // index of the last transaction at a given pixel, where we need to flush the width adapter and move to next pixel
  uint8_t    flush_active;
  uint8_t    padding1;
  uint16_t   padding2;
} output_streamer_flush_config_t;

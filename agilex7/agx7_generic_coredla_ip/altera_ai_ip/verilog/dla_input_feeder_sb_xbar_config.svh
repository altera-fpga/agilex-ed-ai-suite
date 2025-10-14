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
  This is the shared datatype between C++ compiler config generation and sb xbar module
  Config layout for sb xbar fpga/input_feeder/rtl/dla_stream_buffer_xbar.sv (does not exist yet)
*/
typedef struct packed {
  uint16_t padding1;      // stream id of current input
  uint8_t padding0;       // whether input data comes from ddr
  uint8_t read_from_xbar; // whether input data comes from xbar
} input_feeder_sb_xbar_config_t;

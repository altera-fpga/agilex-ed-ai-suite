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
  This is the shared datatype between C++ compiler config generation and input feeder in module
  Config layout input side of stream buffer
  fpga/input_feeder/rtl/dla_stream_buffer_manager.sv
*/
typedef struct packed {
  uint8_t stream_id;               // stream id of current input
  uint8_t read_from_ddr;            // whether input data comes from ddr
  uint8_t read_from_xbar;           // whether input data comes from xbar
  uint8_t is_feature_2x_precision; //whether this layer is feature high precision or not
} input_feeder_in_config_t;

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
  This is the shared datatype between C++ compiler config generation and input feeder writer mux module
  Config layout for mux before input feeder
  fpga/input_feeder/rtl/dla_stream_buffer_writer_input_mux.sv
*/
typedef struct packed {
  // TODO, ideally should just be like uint30 for num words minus two, uint1 for read_from_xbar, uint1 for quantize
  uint32_t num_words_minus_two;     // number of input data (-2)
  uint8_t  read_from_xbar;          // whether input data comes from xbar
  uint8_t  quantize;                // whether to pass data through FakeBFP
  uint8_t  is_feature_2x_precision; // is this convolution using a 2x precision "bootstrap" for features?
  uint8_t  read_from_stream;        // whether to read from stream
} input_feeder_writer_mux_config_t;

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
  This is the shared datatype between C++ compiler config generation and input feeder writer addr gen module
  Ensure that all changes are mirrored betweem dla_input_feeder_writer_config.h, .sv, _vc.svh

  For documentation, see file://./../README.md
*/

interface input_feeder_writer_config_if #(
  parameter int NUM_LANES=1
);

import dla_common_pkg::*;

typedef struct packed {
  int32_t  count_words_minus_one;
  int8_t   count_channel_lo_minus_two;          // if read_from_xbar, KVEC_OVER_CVEC otherwise 1
  uint32_t [NUM_LANES-1:0][NUM_LANES-1:0] base_address;                         // base write address in stream buffer for this layer
  int32_t  [NUM_LANES-1:0][NUM_LANES-1:0] height_skip_minus_one;
  uint32_t bounds_channel_minus_one;            // how many channel CVECs in output tensor
  int32_t  [NUM_LANES-1:0][NUM_LANES-1:0] height_size_minus_one;             // height of output tensor
  int32_t  count_depth_minus_two;               // depth of input tensor
  int32_t  count_channel_hi_minus_two;          // how many channel chunks in input tensor, chunk = CVEC for DDR, KVEC for XBAR
  int32_t  count_height_minus_two;              // width of input tensor
  int32_t  count_width_minus_two;               // height of input tensor
  uint8_t  is_feature_2x_precision;             // is this convolution using a 2x precision "bootstrap" for features?
  uint8_t  read_from_xbar;                      // whether input data comes from XBAR
  uint8_t  stream_id;
  int32_t  address_channel_lo_inc;
  int32_t  address_width_inc_channel_lo_reset;
  int32_t  address_height_inc_width_reset;
  int32_t  address_depth_inc_height_reset;
  int32_t  address_channel_hi_inc_depth_reset;
} config_t;

config_t data;
logic valid;
logic pre_valid;
logic ready;

function automatic string to_string(input config_t c);
  string s = "";
  string t;
  t = {"count_words_minus_one               = ", $sformatf("%d",c.count_words_minus_one               ), "\n"}; s = {s, t};
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"height_skip_minus_one[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.height_skip_minus_one[i][j]), "\n"}; s = {s, t};
    end
  end
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"height_size_minus_one[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.height_size_minus_one[i][j]), "\n"}; s = {s, t};
    end
  end
  t = {"address_channel_hi_inc_depth_reset  = ", $sformatf("%d",c.address_channel_hi_inc_depth_reset  ), "\n"}; s = {s, t};
  t = {"address_depth_inc_height_reset      = ", $sformatf("%d",c.address_depth_inc_height_reset      ), "\n"}; s = {s, t};
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"base_address[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.base_address[i][j]), "\n"}; s = {s, t};
    end
  end
  t = {"bounds_channel_minus_one            = ", $sformatf("%d",c.bounds_channel_minus_one            ), "\n"}; s = {s, t};
  t = {"count_depth_minus_two               = ", $sformatf("%d",c.count_depth_minus_two               ), "\n"}; s = {s, t};
  t = {"count_channel_hi_minus_two          = ", $sformatf("%d",c.count_channel_hi_minus_two          ), "\n"}; s = {s, t};
  t = {"count_height_minus_two              = ", $sformatf("%d",c.count_height_minus_two              ), "\n"}; s = {s, t};
  t = {"count_width_minus_two               = ", $sformatf("%d",c.count_width_minus_two               ), "\n"}; s = {s, t};
  for (int i=0; i < NUM_LANES; i++) begin
    for (int j=0; j < NUM_LANES; j++) begin
      t = {"height_size_minus_one[", $sformatf("%d",i), "][", $sformatf("%d",j), "] = ", $sformatf("%d",c.height_size_minus_one[i][j]), "\n"}; s = {s, t};
    end
  end
  t = {"is_feature_2x_precision             = ", $sformatf("%d",c.is_feature_2x_precision             ), "\n"}; s = {s, t};
  t = {"read_from_xbar                      = ", $sformatf("%d",c.read_from_xbar                      ), "\n"}; s = {s, t};
  t = {"stream_id                           = ", $sformatf("%d",c.stream_id                           ), "\n"}; s = {s, t};
  return s;
endfunction

endinterface

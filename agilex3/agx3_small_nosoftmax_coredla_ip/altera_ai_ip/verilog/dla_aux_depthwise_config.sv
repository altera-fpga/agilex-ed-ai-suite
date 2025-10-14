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
  This is the shared datatype between C++ compiler config generation and aux depthwise module
  Ensure that all changes are mirrored to dla_aux_depthwise_config.h
*/

interface aux_depthwise_config_if #(
  parameter int TILE_COUNT,
  parameter int MAX_WINDOW_WIDTH,
  parameter int MAX_WINDOW_HEIGHT
);

import dla_common_pkg::*;

typedef struct packed {
  int32_t  out_channels_minus_2;
  int32_t  out_height_minus_2;
  int32_t  out_width_minus_2;
  int32_t pad_zone_horizontal_upper_bound_counter_minus_2;
  int32_t  pad_zone_vertical_upper_bound_counter_minus_2;

  int32_t  [TILE_COUNT-1:0][MAX_WINDOW_WIDTH-1:0] horiz_pad_zero_upper_bound_counter_minus_2;
  int32_t  [TILE_COUNT-1:0][MAX_WINDOW_WIDTH-1:0] horiz_pad_zero_lower_bound_counter_minus_2;
  int32_t  [TILE_COUNT-1:0][MAX_WINDOW_HEIGHT-1:0] vert_pad_zero_upper_bound_counter_minus_2;
  int32_t  [TILE_COUNT-1:0][MAX_WINDOW_HEIGHT-1:0] vert_pad_zero_lower_bound_counter_minus_2;

  int32_t line_buff_flush_minus_2;
  int32_t  line_buff_wait_fill_minus_2;
  int32_t  feature_almost_ready_minus_2;
  int32_t  tile_channels_over_native_vector_size_minus_2;
  int32_t  stride_vertical_minus_2;
  int32_t  eff_window_height_minus_2;
  int32_t  window_height_minus_2;
  int32_t  tile_height_minus_2;
  int32_t  stride_horizontal_minus_2;
  int32_t  eff_window_width_minus_2;
  int32_t  window_width_minus_2;
  int32_t  tile_width_minus_2;

  int32_t  padding_ignore;
  int32_t  padding_mode;
  int32_t  padding_constant;
  int32_t  dilation_horizontal;
  int32_t  dilation_vertical;

  int32_t  [TILE_COUNT-1:0] tile_horizontal_end;
  int32_t  [TILE_COUNT-1:0] tile_horizontal_start;
  int32_t  [TILE_COUNT-1:0] tile_vertical_end;
  int32_t  [TILE_COUNT-1:0] tile_vertical_start;
  int32_t  tile_channels;
  int32_t  tile_width;
  int32_t  tile_height;
  int32_t  stride_horizontal;
  int32_t  stride_vertical;
  int32_t  window_width;
  int32_t  window_height;
  int32_t  config_id;

} config_t;

config_t data;
logic pre_valid;
logic valid;
logic ready;

modport sender (output data, output pre_valid, output valid, input ready);
modport receiver (input data, input pre_valid, input valid, output ready);

endinterface

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

// This config MUST have the same feilds - both order and size - as the struct
// defined in fpga/layout_transform/dual_inc/dla_layout_transform_config.h
//
// Any changes here should be reflected there!
//
// This config is used to configure the layout transform hardware at runtime.

typedef struct packed {
  uint16_t input_height;
  uint16_t input_width;
  uint16_t input_depth;
  uint16_t stride_height;
  uint16_t stride_width;
  uint16_t stride_depth;
  uint16_t out_pad;
  uint16_t left_pad;
  uint16_t high_pad;
  uint16_t output_w;
  uint16_t output_h;
  uint16_t output_d;
  uint16_t output_channels;
  uint16_t input_channels;
  uint32_t feature_volume;
  uint16_t stride_volume;
  uint16_t channels_incr;
  uint16_t depth_incr;
  uint16_t stride_depth_incr;
  uint16_t stride_height_incr;
  uint16_t output_volume;
  uint16_t output_face_area;
  uint16_t h_overflow;
  uint16_t w_overflow;
  uint16_t w_padding_per_stride;
  uint16_t h_padding_per_stride;
  uint16_t c_step;
  uint16_t w_step;
  uint16_t h_step;
  uint16_t d_step;
  uint16_t w_stride_step;
  uint16_t h_stride_step;
  uint16_t w_inner_step;
  uint16_t h_inner_step;
  int16_t top_full_padding;
  int16_t left_full_padding;

  uint16_t effective_fw;
  uint16_t effective_fh;
  uint16_t stride_w_limit;
  uint16_t stride_h_limit;
  uint16_t final_stride_w_limit;
  uint16_t final_stride_h_limit;

  uint16_t w_end_overhang;

  uint16_t continue_count_cond;
  uint16_t w_nstrides;
  uint16_t h_nstrides;

  lt_bias_scale_loop bias_float;
  lt_bias_scale_loop scale_float;

  uint16_t _padding_;
} layout_transform_config_t;

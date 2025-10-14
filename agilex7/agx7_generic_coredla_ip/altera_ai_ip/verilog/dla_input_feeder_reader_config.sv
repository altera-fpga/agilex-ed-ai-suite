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
  This is the shared datatype between C++ compiler config generation and input feeder reader addr gen module
  Config layout for stream buffer read address and sequencer control signals generation
  Ensure that all changes are mirrored to dla_input_feeder_reader_config.h
*/

interface input_feeder_reader_config_if #(
  parameter int NUM_LANES = 1
);

import dla_common_pkg::*;

typedef struct packed {
  uint8_t  operands_share_filters;   // do operands share filters (false for custom eltwise)
  uint8_t  bypass_conv;              // enable replication (for identity or eltwise filter)
  uint8_t  is_eltwise_mult;          // is eltwise mult
  uint8_t  is_two_operands;          // does the eltwise conv have 2 operands
  uint32_t is_stream_out;            // if the convolution is a stream out convoltion
  uint8_t  is_depth_pool;            // is this convolution for depth pool?
  uint8_t  is_feature_2x_precision;  // is this convolution using a 2x precision "bootstrap" for features?
  uint16_t last_face_vec_size;       // output face size - num face vecs * num interleaved features
  int32_t  init_accum_cycle_cnt;     // shortened_num_cvec*filter_dims[height]*filter_dims[width]
  int32_t  init_filter_width_cnt;    // filter_dims[width]
  int32_t  init_filter_width_addr;   // -pad_low[width]
  int32_t  inc_filter_width_addr;    // dilation[width]
  int32_t  init_filter_height_cnt;   // filter_dims[height]
  int32_t  init_filter_height_addr;  // -pad_low[height]*input_dims[width]
  int32_t  inc_filter_height_addr;   // dilation[height]*input_dims[width]
  int32_t  init_filter_depth_cnt;    // filter_dims[depth]
  int32_t  init_filter_depth_addr;   // -pad_low[depth]*input_dims[height]*input_dims[width]
  int32_t  inc_filter_depth_addr;    // dilation[depth]*input_dims[height]*input_dims[width]
  int32_t  init_broadcast_cvec_cnt;  // shortened_num_cvec
  int32_t  init_cvec_cnt;            // shortened_num_cvec/getBroadcastFactor[channel]
  int32_t  inc_cvec_addr;            // input_dims[width] * input_dims[height] * input_dims[depth]
  int32_t  init_face_vec_cnt;        // output_dims[height]*output_dims[width]*output_dims[depth]/num_interleaved_features
  int32_t  init_kvec_cnt;            // vec_dims[channel] / get_packet_size[channel]
  int32_t  init_kvec_eltwise_mult;   // kvec_over_cvec * num_kvec
  int32_t  inc_kvec_addr;            // input_dims[width] * input_dims[height] * input_dims[depth] * kvec_over_cvec : 0
  int32_t  init_feature_width_cnt;   // output_dims[width]
  int32_t  inc_feature_width_addr;   // stride[width]
  int32_t  init_feature_height_cnt;  // output_dims[height]
  int32_t  inc_feature_height_addr;  // stride[height] * input_dims[width]
  int32_t  init_feature_depth_cnt;   // output_dims[depth]
  int32_t  inc_feature_depth_addr;   // stride[depth] * input_dims[height] * input_dims[width]
  int32_t  addr_offset;              // sb addr offset
  int32_t  limit_addr_width;         // input_dims[width]
  int32_t  limit_addr_channels;      // (input_dims.at(CHANNEL_DIM) / conv_inst->getBroadcastFactors().at(CHANNEL_DIM)) / api_arch_params_.get_c_vector())
                                     //  * input_dims.at(WIDTH_DIM) * input_dims.at(HEIGHT_DIM) * input_dims.at(DEPTH_DIM);
  int32_t  limit_addr_height;        // input_dims[width] * input_dims[height]
  int32_t  [NUM_LANES-1:0] height_start_offsets;             // Start address offset for each lane
  int32_t  [NUM_LANES-1:0] limit_addr_low_height_per_lane;   // Per lane low address limit for height padding
  int32_t  [NUM_LANES-1:0] limit_addr_high_height_per_lane;  // Per lane high address limit for height padding
  int32_t  ddrfree_filter_addr;      // on-chip memory filter address when ddrfree fbs is enabled
  int32_t  ddrfree_bias_scale_addr;  // on-chip memory bias and scale address when ddrfree fbs is enabled
} config_t;

config_t data;
logic pre_valid;
logic valid;
logic ready;

modport sender (output data, output pre_valid, output valid, input ready);
modport receiver (input data, input pre_valid, input valid, output ready);

endinterface

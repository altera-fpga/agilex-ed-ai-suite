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
  This is a virtual class of the input feeder reader addr gen config struct
  This struct is identical to the struct in the interface but since the interface struct cannot be
  used, this virtual class contains it
*/

virtual class input_feeder_reader_config_vc #(
  parameter int NUM_LANES = 1
);

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

static function automatic string to_string(input config_t c);
  string s = "";
  string t;
  t = {"  operands_share_filters       = ", $sformatf("%d",c.operands_share_filters       ), "\n"}; s = {s, t};
  t = {"  bypass_conv                  = ", $sformatf("%d",c.bypass_conv                  ), "\n"}; s = {s, t};
  t = {"  is_eltwise_mult              = ", $sformatf("%d",c.is_eltwise_mult              ), "\n"}; s = {s, t};
  t = {"  is_two_operands              = ", $sformatf("%d",c.is_two_operands              ), "\n"}; s = {s, t};
  t = {"  is_depth_pool                = ", $sformatf("%d",c.is_depth_pool                ), "\n"}; s = {s, t};
  t = {"  is_feature_2x_precision      = ", $sformatf("%d",c.is_feature_2x_precision      ), "\n"}; s = {s, t};
  t = {"  is_stream_out                = ", $sformatf("%d",c.is_stream_out                ), "\n"}; s = {s, t};
  t = {"  last_face_vec_size           = ", $sformatf("%d",c.last_face_vec_size           ), "\n"}; s = {s, t};
  t = {"  init_accum_cycle_cnt         = ", $sformatf("%d",c.init_accum_cycle_cnt         ), "\n"}; s = {s, t};
  t = {"  init_filter_width_cnt        = ", $sformatf("%d",c.init_filter_width_cnt        ), "\n"}; s = {s, t};
  t = {"  init_filter_width_addr       = ", $sformatf("%d",c.init_filter_width_addr       ), "\n"}; s = {s, t};
  t = {"  inc_filter_width_addr        = ", $sformatf("%d",c.inc_filter_width_addr        ), "\n"}; s = {s, t};
  t = {"  init_filter_height_cnt       = ", $sformatf("%d",c.init_filter_height_cnt       ), "\n"}; s = {s, t};
  t = {"  init_filter_height_addr      = ", $sformatf("%d",c.init_filter_height_addr      ), "\n"}; s = {s, t};
  t = {"  inc_filter_height_addr       = ", $sformatf("%d",c.inc_filter_height_addr       ), "\n"}; s = {s, t};
  t = {"  init_filter_depth_cnt        = ", $sformatf("%d",c.init_filter_depth_cnt        ), "\n"}; s = {s, t};
  t = {"  init_filter_depth_addr       = ", $sformatf("%d",c.init_filter_depth_addr       ), "\n"}; s = {s, t};
  t = {"  inc_filter_depth_addr        = ", $sformatf("%d",c.inc_filter_depth_addr        ), "\n"}; s = {s, t};
  t = {"  init_broadcast_cvec_cnt      = ", $sformatf("%d",c.init_broadcast_cvec_cnt      ), "\n"}; s = {s, t};
  t = {"  init_cvec_cnt                = ", $sformatf("%d",c.init_cvec_cnt                ), "\n"}; s = {s, t};
  t = {"  inc_cvec_addr                = ", $sformatf("%d",c.inc_cvec_addr                ), "\n"}; s = {s, t};
  t = {"  init_face_vec_cnt            = ", $sformatf("%d",c.init_face_vec_cnt            ), "\n"}; s = {s, t};
  t = {"  init_kvec_cnt                = ", $sformatf("%d",c.init_kvec_cnt                ), "\n"}; s = {s, t};
  t = {"  init_kvec_eltwise_mult       = ", $sformatf("%d",c.init_kvec_eltwise_mult       ), "\n"}; s = {s, t};
  t = {"  inc_kvec_addr                = ", $sformatf("%d",c.inc_kvec_addr                ), "\n"}; s = {s, t};
  t = {"  init_feature_width_cnt       = ", $sformatf("%d",c.init_feature_width_cnt       ), "\n"}; s = {s, t};
  t = {"  inc_feature_width_addr       = ", $sformatf("%d",c.inc_feature_width_addr       ), "\n"}; s = {s, t};
  t = {"  init_feature_height_cnt      = ", $sformatf("%d",c.init_feature_height_cnt      ), "\n"}; s = {s, t};
  t = {"  inc_feature_height_addr      = ", $sformatf("%d",c.inc_feature_height_addr      ), "\n"}; s = {s, t};
  t = {"  init_feature_depth_cnt       = ", $sformatf("%d",c.init_feature_depth_cnt       ), "\n"}; s = {s, t};
  t = {"  inc_feature_depth_addr       = ", $sformatf("%d",c.inc_feature_depth_addr       ), "\n"}; s = {s, t};
  t = {"  addr_offset                  = ", $sformatf("%d",c.addr_offset                  ), "\n"}; s = {s, t};
  t = {"  limit_addr_width             = ", $sformatf("%d",c.limit_addr_width             ), "\n"}; s = {s, t};
  t = {"  limit_addr_channels          = ", $sformatf("%d",c.limit_addr_channels          ), "\n"}; s = {s, t};
  t = {"  limit_addr_height            = ", $sformatf("%d",c.limit_addr_height            ), "\n"}; s = {s, t};
  t = {"  ddrfree_filter_addr          = ", $sformatf("%d",c.ddrfree_filter_addr       ), "\n"}; s = {s, t};
  t = {"  ddrfree_bias_scale_addr      = ", $sformatf("%d",c.ddrfree_bias_scale_addr   ), "\n"}; s = {s, t};
  for (int lane_idx = 0; lane_idx < 16; lane_idx++) begin
    t = {"  height_start_offsets[", $sformatf("%d",lane_idx), "] = ", $sformatf("%d",c.height_start_offsets[lane_idx]), "\n"}; s = {s, t};
  end
  for (int lane_idx = 0; lane_idx < 16; lane_idx++) begin
    t = {"  limit_addr_low_height_per_lane[", $sformatf("%d",lane_idx), "] = ", $sformatf("%d",c.limit_addr_low_height_per_lane[lane_idx]), "\n"}; s = {s, t};
  end
  for (int lane_idx = 0; lane_idx < 16; lane_idx++) begin
    t = {"  limit_addr_high_height_per_lane[", $sformatf("%d",lane_idx), "] = ", $sformatf("%d",c.limit_addr_high_height_per_lane[lane_idx]), "\n"}; s = {s, t};
  end
  return s;
endfunction

endclass

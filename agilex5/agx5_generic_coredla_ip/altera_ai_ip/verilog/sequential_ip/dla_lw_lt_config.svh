// Copyright 2025 Altera Corporation.
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
// defined in fpga/lightweight_layout_transform/dual_inc/dla_lw_lt_config.h
//
// Any changes here should be reflected there!
//
// This config is used to configure the layout transform hardware at runtime.

typedef struct packed {
    uint32_t feature_volume;
    uint32_t output_volume;
    lw_lt_bias_scale_loop bias_float;
    lw_lt_bias_scale_loop scale_float;
} lw_lt_config_t;

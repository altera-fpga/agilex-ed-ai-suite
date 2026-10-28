// Copyright 2020 Altera Corporation.
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

#ifndef _DLA_AOT_STRUCTS_H_
#define _DLA_AOT_STRUCTS_H_

#include "compiled_result.h"

// Custom type
typedef unsigned char uint8_t;

// All size and offset fields are in bytes.
typedef struct {
  const dla::CompiledResult* compiled_result;
  uint32_t config_buffer_size;
  uint32_t filter_bias_scale_buffer_size;
  uint8_t *input_feature_buffer;
  uint32_t input_feature_buffer_size;
  uint32_t output_feature_buffer_size;
  uint32_t intermediate_feature_buffer_size;
} DLAInput;

typedef struct {
  // Its size is output_feature_buffer_size in DLAInput.
  uint8_t *output_feature_buffer;
} DLAOutput;

#endif    // _DLA_REF_H_

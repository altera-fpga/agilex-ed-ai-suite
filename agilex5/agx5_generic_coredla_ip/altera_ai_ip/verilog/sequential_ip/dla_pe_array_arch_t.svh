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

typedef struct packed {
  uint32_t NUM_LANES;
  uint32_t NUM_PES;
  uint32_t NUM_FEATURES;
  uint32_t NUM_FILTERS;

  uint32_t FEATURE_WIDTH;
  uint32_t FILTER_WIDTH;
  uint32_t FEATURE_EXPONENT_WIDTH;
  uint32_t FEATURE_EXPONENT_BIAS;
  uint32_t FILTER_EXPONENT_WIDTH;
  uint32_t FILTER_EXPONENT_BIAS;
  uint32_t DOT_SIZE;

  dot_mode_t DOT_MODE;
  convert_mode_t CONVERT_MODE;
  accum_mode_t ACCUM_MODE;

  uint32_t DOT_RATIO_DSP;
  uint32_t DOT_RATIO_ALM;
  uint32_t ACCUM_RATIO_DSP;
  uint32_t ACCUM_RATIO_ALM;

  uint32_t NUM_INTERLEAVED_FEATURES;
  uint32_t NUM_INTERLEAVED_FILTERS;

  uint32_t ELTWISE_MULT_CMD_WIDTH;

  uint32_t NUM_RESULT_ID;
  uint32_t RESULT_ID_WIDTH;
  uint32_t NUM_RESULTS_PER_CYCLE;

  uint32_t ENABLE_SCALE;
  uint32_t ENABLE_ELTWISE_MULT;

  uint32_t ENABLE_DDRFREE_FBS;

  uint32_t GROUP_DELAY;

  device_family_t DEVICE_FAMILY;
} pe_array_arch_t;

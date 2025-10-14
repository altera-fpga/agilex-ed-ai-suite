// Copyright 2020-2020 Altera Corporation.
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

// --- dla_pe_array_enums.svh ---
// This file is shared between the C++ model and the RTL. The file is written
// in a format that is compatible with both SystemVerilog and C++. It should
// only contain enums written in a basic style in order to remain compatible.

// These dot modes correspond to how feature and filters will be mapped in the
// DSP and the bitwidth of inputs to be multiplied. PACKAXB refers to packing smaller
// multiplies to one larger multiplier and TENSORAXB refers to the DSP being configured
// to tensor mode and how feature/filter will be shared between the columns.
// PACK1X2_MULT7 will pack 1 feature data with 2 filter data into one 18x18 multiplier.
// TENSOR1X2_MULT8 will share 1 feature data with 2 filter data in 2 columns of multipliers.
// Note: ordering of this enum is used to seed the random input in the PE array module
// accuracy test, which checks accuracy by comparing output to a known good result hash
typedef enum enum_uint32_t {
  DOT_MODE_ALM,
  DOT_MODE_PACK1X1_MULT18,
  DOT_MODE_PACK1X1_MULT9_CHAIN_ADD,
  DOT_MODE_PACK1X1_MULT9_ADDER_TREE,
  DOT_MODE_PACK1X2_MULT7,
  DOT_MODE_PACK2X1_MULT7,
  DOT_MODE_PACK2X2_MULT4,
  DOT_MODE_PACK2X2_MULT4X5,
  DOT_MODE_PACK2X2_MULT4X6,
  DOT_MODE_PACK2X2_MULT5,
  DOT_MODE_PACK2X2_MULT5X4,
  DOT_MODE_PACK2X2_MULT7,
  DOT_MODE_TENSOR1X2_MULT8
} dot_mode_t;

typedef enum enum_uint32_t {
  CONVERT_MODE_NONE,
  CONVERT_MODE_BLOCKFP_TO_FIXED_ALM,
  CONVERT_MODE_BLOCKFP_TO_FP32_ALM,
  CONVERT_MODE_BLOCKFP_TO_FP32_DSP
} convert_mode_t;

typedef enum enum_uint32_t {
  ACCUM_MODE_FIXED_TO_FP32_ALM,
  ACCUM_MODE_FP32_DSP,
  ACCUM_MODE_FIXED
} accum_mode_t;

// alm_dot_adder_type_t is only used on AGX
// Adder tree is set when dot_mode is DOT_MODE_PACK1X1_MULT9_ADDER_TREE
// Mixed adder, when dot_mode is DOT_MODE_PACK1X1_MULT9_CHAIN_ADD
// Mixed adder uses two stages of adder trees then a chain add to
// mimic the hardened adders in INT9 DSP mode
// This enum is not used on S10, A10 or C10
typedef enum enum_uint32_t {
  ADDER_TREE,
  MIXED_ADDER
} alm_dot_adder_type_t;

// TWOS_COMPLEMENT is only used on AGX, to take advantage of the INT9
// DSP mode
// SIGNED_MAG is used on A10, C10, S10 and AGX
typedef enum enum_uint32_t {
  SIGNED_MAGNITUDE,
  TWOS_COMPLEMENT
} datatype_t;

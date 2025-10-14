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

/**
This enum should have the same options and ordering as in `compiled_result/inc/compiled_result.h`
and the same ordering as in the architecture specification in `arch/proto/coredla.proto`
*/

typedef enum enum_uint32_t {
  F16_TO_F16,
  U8_TO_F16,
  U16_TO_F16
} convert_mode_t;

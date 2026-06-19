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

// This file is included in both SystemVerilog and C++ (from dla_constants.h)
// Do not add any System Verilog keywords

localparam int FP16_EXPONENT_WIDTH  = 5;
localparam int FP16_MANTISSA_WIDTH  = 10;
localparam int FP16_EXPONENT_OFFSET = FP16_MANTISSA_WIDTH;
localparam int FP16_MANTISSA_OFFSET = 0;
localparam int FP16_EXPONENT_BIAS   = 15;
localparam int FP16_SIGN_BIT        = FP16_MANTISSA_WIDTH + FP16_EXPONENT_WIDTH;
localparam int FP16_WIDTH           = 16;

localparam int FP32_EXPONENT_WIDTH  = 8;
localparam int FP32_MANTISSA_WIDTH  = 23;
localparam int FP32_EXPONENT_OFFSET = FP32_MANTISSA_WIDTH;
localparam int FP32_MANTISSA_OFFSET = 0;
localparam int FP32_EXPONENT_BIAS   = 127;
localparam int FP32_SIGN_BIT        = FP32_MANTISSA_WIDTH + FP32_EXPONENT_WIDTH;
localparam int FP32_WIDTH           = 32;

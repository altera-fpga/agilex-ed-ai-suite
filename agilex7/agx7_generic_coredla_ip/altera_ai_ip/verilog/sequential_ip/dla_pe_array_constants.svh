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

// --- dla_pe_array_constants.svh ---
// This file is shared between the C++ model and the RTL. The file itself is
// written in SystemVerilog format, however the C++ code also #includes it
// after defining a macro called "localparam", which gets replaced with "static
// const" for the C++ compile. Therefore, this file should only be used to
// define constants using "localparam".

localparam int RESULT_MANTISSA_WIDTH = 10;
localparam int RESULT_EXPONENT_WIDTH = 5;
localparam int RESULT_EXPONENT_BIAS  = 15;
localparam int RESULT_WIDTH          = 1 + RESULT_EXPONENT_WIDTH + RESULT_MANTISSA_WIDTH;

// bias and scale widths
localparam int BIAS_MANTISSA_WIDTH = 10;
localparam int BIAS_EXPONENT_WIDTH = 6;
localparam int BIAS_EXPONENT_BIAS  = 31;
localparam int BIAS_WIDTH = 1 + BIAS_EXPONENT_WIDTH + BIAS_MANTISSA_WIDTH;

localparam int SCALE_MANTISSA_WIDTH = 10;
localparam int SCALE_EXPONENT_WIDTH = 6;
localparam int SCALE_EXPONENT_BIAS  = 31;
localparam int SCALE_WIDTH = 1 + SCALE_EXPONENT_WIDTH + SCALE_MANTISSA_WIDTH;

// 12 bit value from FP16 mantissa (includes implicit 1 and sign bit) can be
// shifted into any of 2**(5 FP16 exponent bits) = 32 positions, except
// exponent 0 and 32 because they are special values, resulting in 30 total
// positions.
localparam int ALM_ACCUM_WIDTH = 12+30;

// FP16 mantissa has 10 fractional bits. The FP16 exponent bias is 15, which
// means the maximum negative exponent is negative 14 (negative 15 would result
// in an exponent value of 0, which is a special case for FP16 and would not
// be used), which therefore adds 14 more fractional bits.
localparam int ALM_ACCUM_FRACTION_WIDTH = 10+14;

// 16 seems like a decent choice, though it might need to be adjusted later
// or made controllable. Currently this must be set to the same value as
// result_width because the accumulator value is just used directly as the
// result value.
localparam int FIXED_ACCUM_WIDTH = 16;

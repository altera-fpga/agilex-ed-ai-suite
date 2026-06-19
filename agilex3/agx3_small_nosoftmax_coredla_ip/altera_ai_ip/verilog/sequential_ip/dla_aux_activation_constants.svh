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

//------------------------------------------------------------------------------------
// This file defines constants used in the aux activation block, and is shared between
// the c model and the rtl, so must contain only constants or simple (cross-compatible)
// derivations.
//------------------------------------------------------------------------------------

//----------------------------------------------------------
// BIT field definitions for compile time activation enables

// enable bit offset locations in activation enable word
localparam int ENABLE_RELU_BIT                     = 0;
localparam int ENABLE_LRELU_BIT                    = 1;
localparam int ENABLE_PRELU_BIT                    = 2;
localparam int ENABLE_CLAMP_BIT                    = 3;
localparam int ENABLE_CONTINUOUS_ACTIVATIONS_BIT   = 4;
localparam int ENABLE_ROUND_CLAMP_BIT              = 8;

localparam int ENABLE_BIT_FIELD_WIDTH              = 9;

// these are to be OR'ed together to create the activation enable param
localparam int ENABLE_RELU_BIT_FLAG                    = 1 << ENABLE_RELU_BIT;                    // 2 ** ENABLE_RELU_BIT;
localparam int ENABLE_LRELU_BIT_FLAG                   = 1 << ENABLE_LRELU_BIT;                   // 2 ** ENABLE_LRELU_BIT;
localparam int ENABLE_PRELU_BIT_FLAG                   = 1 << ENABLE_PRELU_BIT;                   // 2 ** ENABLE_PRELU_BIT;
localparam int ENABLE_CLAMP_BIT_FLAG                   = 1 << ENABLE_CLAMP_BIT;                   // 2 ** ENABLE_CLAMP_BIT;
localparam int ENABLE_CONTINUOUS_ACTIVATIONS_BIT_FLAG  = 1 << ENABLE_CONTINUOUS_ACTIVATIONS_BIT;  // 2 ** ENABLE_CONTINUOUS_ACTIVATIONS_BIT;
localparam int ENABLE_ROUND_CLAMP_BIT_FLAG             = 1 << ENABLE_ROUND_CLAMP_BIT;             // 2 ** ENABLE_ROUND_CLAMP_BIT;

//----------------------------------------------------------
// Definitions for runtime time configuration

// fixed config word
localparam int OPERAND_WIDTH        = 4;
localparam int OPERAND_OFFSET       = 0;

localparam int COUNT_WIDTH          = 16;
localparam int COUNT_OFFSET         = 3;

localparam int PARAM_WIDTH          = 16;
localparam int PARAM_OFFSET_0       = 0;
localparam int PARAM_OFFSET_1       = PARAM_WIDTH;

// Operand definitions for run-time time activation selection
localparam int RELU_OP                   = 0;
localparam int LRELU_OP                  = 1;
localparam int PRELU_OP                  = 2;
localparam int CLAMP_OP                  = 3;
localparam int CONTINUOUS_ACTIVATIONS_OP = 4;
localparam int ROUND_CLAMP_OP            = 8;

//----------------------------------------------------------
// Misc definitions

// Floating Point 16 precision definitions
localparam int FP16_BP_PARAM        = 15360;   // decimal of 0c3C00, which is 1.0 in FP16
localparam int FP16_ZERO_PARAM      = 0;       // decimal of 0c0000, which is 0.0 in FP16

localparam int FP16_MAX_PARAM       = 31743;   // decimal of 0x7BFF, max FP16 value
localparam int FP16_MIN_PARAM       = 64511;   // decimal of 0xFBFF, min FP16 value

//----------------------------------------------------------
// Hardware Latency constants

// DSP latency in 18x18 full fixed point mode (for LReLU/PReLU)
localparam int DLA_DSP_M18X18_FULL_LATENCY_A10 = 3;
localparam int DLA_DSP_M18X18_FULL_LATENCY_C10 = 3;
localparam int DLA_DSP_M18X18_FULL_LATENCY_S10 = 4;
localparam int DLA_DSP_M18X18_FULL_LATENCY_AGX7 = 4;
localparam int DLA_DSP_M18X18_FULL_LATENCY_AGX5 = 4;

// Number of multiplies packed per DSP block
localparam int MULTIPLIES_PER_DSP = 2;

// write to read latency of HLD_FIFO
localparam string DLA_HLD_FIFO_STYLE = "ms";
localparam int DLA_HLD_FIFO_LATENCY_MS = 3;

// latency of CLAMP, ROUNDCLAMP and RELU hardware blocks
localparam int CLAMP_HW_BLOCK_LATENCY = 1;
localparam int RELU_HW_BLOCK_LATENCY = 1;
localparam int ROUND_CLAMP_HW_BLOCK_LATENCY = 4;

// write to read latency of DLA_HLD_RAM
localparam int DLA_HLD_RAM_READ_LATENCY = 2;

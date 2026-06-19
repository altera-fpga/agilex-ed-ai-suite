// Copyright 2022 Altera Corporation.
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

// --- dla_input_feeder_constants.svh ---
// This file is shared between the C++ model and the RTL. The file itself is
// written in SystemVerilog format, however the C++ code also #includes it
// after defining a macro called "localparam", which gets replaced with "static
// const" for the C++ compile. Therefore, this file should only be used to
// define constants using "localparam".

// Feature input mantissa width
localparam int IN_MANTISSA_WIDTH = 10;

// Xbar input data width
localparam int INPUT_DATA_WIDTH = 16;

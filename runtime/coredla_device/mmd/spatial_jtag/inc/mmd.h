// Copyright 2026 Altera Corporation.
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

#ifndef SPATIAL_JTAG_MMD_H
#define SPATIAL_JTAG_MMD_H

#include <cstddef>
#include <cstdint>
#include <vector>

/**
 * Process-wide MMD session API (one device per process).
 *
 * Call connect_to_fpga() before these entry points
 */

/** Pulse the design reset, wait until the DDR windows answer, and put both mSGDMA dispatchers back in the running state. Call this before any DDR access. */
int reset();

/**
 * Loads a block of weights from `weights_data` into device DDR at the given `bank_number` and
 * local DDR address `start_addr`.
 */
int load_weights_buffer(const uint64_t* weights_data,
                        size_t weights_bytes,
                        uint64_t start_addr,
                        uint64_t bank_number);

/** Loads weights from a single bin file named weights_ddr_<bank>_<start>.bin. */
int load_weights_from_file(const char* filepath);

/**
 * Scans a directory for weights_ddr_*.bin files and loads each of them. This is
 * the primary load_weights() entry point. A model whose weights all come from
 * MIF ROMs has no such files, which is not an error.
 */
int load_weights(const char* dir_path);

/**
 * Latency of the last inference in microseconds, from the cycle count the
 * inference timer latched. Reads the achieved kernel clock out of
 * kernel_clk.json, and falls back to reporting cycles when that is missing.
 */
double read_timer_us();

/**
 * Stage `input_data`, run it through the IP and return the result.
 *
 * input_data and output_data must have a whole number of tensors
 */
int run_inference(const std::vector<uint64_t>& input_data, std::vector<uint64_t>& output_data);

#endif  // SPATIAL_JTAG_MMD_H

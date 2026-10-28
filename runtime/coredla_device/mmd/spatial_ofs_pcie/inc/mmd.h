// Copyright (C) 2025 Intel Corporation

#ifndef __SPATIAL_MMD_H__
#define __SPATIAL_MMD_H__

#include <cstddef>
#include <cstdint>
#include <vector>

#include "spatial_port_config.h"

/**
 * Process-wide MMD session API (one device per process).
 * Call connect_to_fpga() before these entry points.
 */

int reset(void);

/**
 * Runs inference. Input packet count is derived from input.size(); output is
 * resized to the scaled design input_packets:output_packets ratio. Returns 0
 * on success.
 */
int run_inference(const std::vector<uint64_t>& input, std::vector<uint64_t>& output);

/**
 * Loads a block of weights into device DDR at the given bank/start address.
 * Transfers larger than MAX_HOST_MEM_SIZE are partitioned automatically.
 */
int load_weights_buffer(const uint64_t* weights_data,
                        size_t weights_bytes,
                        uint64_t start_addr,
                        uint64_t bank_number);

/**
 * Loads weights from a single binary file named weights_ddr_<bank>_<start>.bin.
 */
int load_weights_from_file(const char* filepath);

/**
 * Scans a directory for weights_ddr_*.bin files and loads each of them.
 * This is the primary load_weights() entry point used by Python and the plugin.
 */
int load_weights(const char* dir_path);

#endif  // __SPATIAL_MMD_H__

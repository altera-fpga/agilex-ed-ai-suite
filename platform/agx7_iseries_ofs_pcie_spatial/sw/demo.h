// Copyright 2025 Altera Corporation.
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

#ifndef __SPARK_DEMO_H__
#define __SPARK_DEMO_H__

int spark_demo(
    fpga_handle accel_handle, bool is_ase_sim, ssize_t model_size_bytes);

int reset(
        fpga_handle accel_handle,
        bool is_ase_sim,
        bool verbose);

int run_inference(
        fpga_handle accel_handle,
        bool is_ase_sim,
        const uint64_t *input_data,
        size_t input_words,
        uint64_t *output_data,
        size_t output_words,
        bool verbose);

int load_weights(
        fpga_handle accel_handle,
        bool is_ase_sim,
        const uint64_t *weights_data,
        size_t weights_bytes,
        uint64_t start_addr,
        uint64_t bank_number,
        bool verbose);

#endif // __SPARK_DEMO_H__
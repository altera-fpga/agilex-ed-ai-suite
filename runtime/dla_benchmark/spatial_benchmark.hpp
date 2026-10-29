// Copyright (C) 2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Spatial mode: image classification via MMD.

#ifndef DLA_BENCHMARK_SPATIAL_BENCHMARK_HPP_
#define DLA_BENCHMARK_SPATIAL_BENCHMARK_HPP_

namespace dla_benchmark {

/**
 * @brief Run spatial image classification via MMD.
 *
 * gflags:
 *   -spatial_input   : Required. Input image path (bmp/png/jpg/...).
 *   -spatial_resize  : Optional. Resize to HxW before inference (e.g. 32x32).
 *   -spatial_golden  : Optional. Ground-truth class indices (one int per line).
 *   -spatial_config  : Required. port_config.json path.
 *   -spatial_weights : Optional. Weights directory; if unset, weights are not loaded.
 *   -output_dir      : Optional. Directory for result.txt / accuracy_report.txt.
 *
 * Input pixels and output scores are both float32 after format (encode/decode
 * to the port data width for the MMD wire format). Classification reports
 * class index : score pairs (no label names), matching dla_benchmark top-N.
 */
int run_spatial_benchmark();

}  // namespace dla_benchmark

#endif  // DLA_BENCHMARK_SPATIAL_BENCHMARK_HPP_

// Copyright 2018-2025 Altera Corporation.
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

#pragma once

#include <map>
#include <string>

#include "openvino/runtime/properties.hpp"
#include "openvino/runtime/threading/istreams_executor.hpp"

namespace ov {
namespace template_plugin {

// Configuration holds user-settable properties and resolved executor settings.
struct Configuration {
    Configuration();
    Configuration(const Configuration&) = default;
    Configuration(Configuration&&) = default;
    Configuration& operator=(const Configuration&) = default;
    Configuration& operator=(Configuration&&) = default;

    explicit Configuration(const ov::AnyMap& config,
                           const Configuration& defaultCfg = {},
                           const bool throwOnUnsupported = true);

    ov::Any Get(const std::string& name) const;

    // Plugin configuration parameters

    // Non-negative accelerator device selection (0,1,...)
    int device_id = 0;

    // Path to the port_config.json describing the runtime port geometry (required).
    std::string port_config_path = "";

    // Directory scanned for weights_ddr_*.bin files at model load.
    std::string weights_dir = "dump_files";

    bool perf_count = false;

    // Streams/executor configuration (OV-side concurrency; hardware concurrency remains 1)
    ov::threading::IStreamsExecutor::Config streams_executor_config;
    int streams = 1;
    int threads = 0;
    int threads_per_stream = 0;

    // Generic OV hints; kept for compatibility
    ov::hint::PerformanceMode performance_mode = ov::hint::PerformanceMode::LATENCY;
    uint32_t num_requests = 1;

    bool disable_transformations = false;
    bool exclusive_async_requests = false;

    // Unused in SPATIAL AOT, but kept for OV property compatibility
    ov::element::Type inference_precision = ov::element::dynamic;
    ov::hint::ExecutionMode execution_mode = ov::hint::ExecutionMode::ACCURACY;
    ov::log::Level log_level = ov::log::Level::NO;
    ov::hint::Priority model_priority = ov::hint::Priority::DEFAULT;

    EncryptionCallbacks encryption_callbacks;
};

}  // namespace template_plugin
}  // namespace ov

// Copyright (C) 2018-2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

#include "plugin.hpp"

#include <memory>
#include <openvino/op/ops.hpp>
#include <openvino/op/parameter.hpp>
#include <openvino/op/result.hpp>
#include <openvino/opsets/opset.hpp>
#include <openvino/pass/manager.hpp>
#include <openvino/runtime/internal_properties.hpp>
#include <openvino/runtime/properties.hpp>

namespace {
static constexpr const char* wait_executor_name = "SpatialWaitExecutor";
static constexpr const char* stream_executor_name = "SpatialStreamsExecutor";
static constexpr const char* spatial_exclusive_executor = "SpatialExecutor";
}  // namespace

// Constructor
ov::template_plugin::Plugin::Plugin() {
    set_device_name("SPATIAL");

    // Optional: Create a default wait executor
    m_waitExecutor = get_executor_manager()->get_idle_cpu_streams_executor({wait_executor_name});
}

// Destructor
ov::template_plugin::Plugin::~Plugin() {
    // Clean executors from cache
    get_executor_manager()->clear(stream_executor_name);
    get_executor_manager()->clear(wait_executor_name);
}

// Remote contexts are not used for SPATIAL yet
ov::SoPtr<ov::IRemoteContext> ov::template_plugin::Plugin::create_context(const ov::AnyMap& /*remote_properties*/) const {
    return {};
}

ov::SoPtr<ov::IRemoteContext> ov::template_plugin::Plugin::get_default_context(const ov::AnyMap& /*remote_properties*/) const {
    return {};
}

// Minimal transform manager (no device-specific graph transforms for AOT synthetic model)
void transform_model(const std::shared_ptr<ov::Model>& model) {
    ov::pass::Manager passManager("Plugin:SPATIAL");
    const auto& pass_config = passManager.get_pass_config();
    (void)pass_config;
    passManager.run_passes(model);
}

// Disable JIT compile_model — SPATIAL is AOT-only
std::shared_ptr<ov::ICompiledModel> ov::template_plugin::Plugin::compile_model(
    const std::shared_ptr<const ov::Model>& /*model*/,
    const ov::AnyMap& /*properties*/) const {
    OPENVINO_THROW("SPATIAL plugin: Just-in-time compilation is not supported. Use import_model (AOT).");
}

std::shared_ptr<ov::ICompiledModel> ov::template_plugin::Plugin::compile_model(
    const std::shared_ptr<const ov::Model>& /*model*/,
    const ov::AnyMap& /*properties*/,
    const ov::SoPtr<ov::IRemoteContext>& /*context*/) const {
    OPENVINO_THROW("SPATIAL plugin: Just-in-time compilation is not supported. Use import_model (AOT).");
}

// AOT-only import_model: ignore provided serialized blob, build a synthetic 1-packet model
std::shared_ptr<ov::ICompiledModel> ov::template_plugin::Plugin::import_model(std::istream& model,
                                                                              const ov::AnyMap& properties) const {
    ov::SoPtr<ov::IRemoteContext> context;  // empty context
    return import_model(model, context, properties);
}

std::shared_ptr<ov::ICompiledModel> ov::template_plugin::Plugin::import_model(
    std::istream& /*model*/,
    const ov::SoPtr<ov::IRemoteContext>& context,
    const ov::AnyMap& properties) const {

    // Extract properties and create executor config
    auto fullConfig = Configuration{properties, m_cfg};
    fullConfig.streams_executor_config =
        ov::threading::IStreamsExecutor::Config{stream_executor_name, fullConfig.streams, fullConfig.threads_per_stream};

    // Build a synthetic model: one input and one output (u64) with dynamic 1D shapes
    // Input parameter
    auto param = std::make_shared<ov::op::v0::Parameter>(ov::element::u64, ov::PartialShape{ov::Dimension::dynamic()});
    param->set_friendly_name("spatial_input");
    param->get_output_tensor(0).set_names({"spatial_input"});

    // Use a Convert node (u64->u64 is identity but creates a distinct output tensor)
    // This breaks the direct passthrough so input and output have separate storage
    auto convert = std::make_shared<ov::op::v0::Convert>(param, ov::element::u64);
    convert->set_friendly_name("spatial_transform");
    convert->get_output_tensor(0).set_names({"spatial_output"});

    // Result wraps the convert output (not directly the parameter)
    auto result = std::make_shared<ov::op::v0::Result>(convert);
    result->set_friendly_name("spatial_result");

    auto model = std::make_shared<ov::Model>(ov::ResultVector{result}, ov::ParameterVector{param}, "SPATIAL_AOT");

    // Optional common transforms (no-op for this synthetic graph)
    transform_model(model);

    // Configure executor
    auto streamsExecutorConfig =
        ov::threading::IStreamsExecutor::Config::make_default_multi_threaded(fullConfig.streams_executor_config);
    fullConfig.streams = streamsExecutorConfig.get_streams();
    fullConfig.threads = streamsExecutorConfig.get_threads();
    fullConfig.threads_per_stream = streamsExecutorConfig.get_threads_per_stream();

    auto executor = fullConfig.exclusive_async_requests
        ? get_executor_manager()->get_executor(spatial_exclusive_executor)
        : get_executor_manager()->get_idle_cpu_streams_executor(streamsExecutorConfig);

    // CompiledModel opens the process-wide MMD session (connect / weights / reset)
    auto compiled_model = std::make_shared<CompiledModel>(
        model,
        shared_from_this(),
        context,
        executor,
        fullConfig,
        /*loaded_from_cache=*/false);

    return compiled_model;
}

// Tensor-based import is not used
std::shared_ptr<ov::ICompiledModel> ov::template_plugin::Plugin::import_model(
    const ov::Tensor& /*model*/,
    const ov::AnyMap& /*properties*/) const {
    OPENVINO_NOT_IMPLEMENTED;
}

std::shared_ptr<ov::ICompiledModel> ov::template_plugin::Plugin::import_model(
    const ov::Tensor& /*model*/,
    const ov::SoPtr<ov::IRemoteContext>& /*context*/,
    const ov::AnyMap& /*properties*/) const {
    OPENVINO_NOT_IMPLEMENTED;
}

// Query model: SPATIAL can only support the synthetic node types we construct here.
// For external models, we advertise no support (or minimal pass-through support).
ov::SupportedOpsMap ov::template_plugin::Plugin::query_model(const std::shared_ptr<const ov::Model>& model,
                                                             const ov::AnyMap& properties) const {
    Configuration fullConfig{properties, m_cfg, false};
    OPENVINO_ASSERT(model, "OpenVINO Model is empty!");

    // For general models, return empty support — SPATIAL expects import_model synthetic graph
    ov::SupportedOpsMap res;
    return res;
}

// Properties
void ov::template_plugin::Plugin::set_property(const ov::AnyMap& properties) {
    m_cfg = Configuration{properties, m_cfg};
}

ov::Any ov::template_plugin::Plugin::get_property(const std::string& name, const ov::AnyMap& arguments) const {
    const auto& default_ro_properties = []() {
        std::vector<ov::PropertyName> ro_properties{
            ov::available_devices,
            ov::supported_properties,
            ov::device::full_name,
            ov::device::architecture,
            ov::device::capabilities,
            ov::device::type,
            ov::range_for_async_infer_requests,
            ov::execution_devices};
        return ro_properties;
    };
    const auto& default_rw_properties = []() {
        std::vector<ov::PropertyName> rw_properties{
            ov::device::id,
            ov::enable_profiling,
            ov::hint::performance_mode,
            ov::hint::num_requests,
            ov::hint::inference_precision,
            ov::hint::execution_mode,
            ov::num_streams,
            ov::log::level,
            ov::hint::model_priority,
        };
        return rw_properties;
    };
    if (ov::supported_properties == name) {
        auto ro_properties = default_ro_properties();
        auto rw_properties = default_rw_properties();
        std::vector<ov::PropertyName> supported_properties;
        supported_properties.reserve(ro_properties.size() + rw_properties.size());
        supported_properties.insert(supported_properties.end(), ro_properties.begin(), ro_properties.end());
        supported_properties.insert(supported_properties.end(), rw_properties.begin(), rw_properties.end());
        return supported_properties;
    } else if (ov::internal::supported_properties == name) {
        return decltype(ov::internal::supported_properties)::value_type{
            ov::PropertyName{ov::internal::caching_properties.name(), ov::PropertyMutability::RO},
            ov::PropertyName{ov::internal::exclusive_async_requests.name(), ov::PropertyMutability::RW},
            ov::PropertyName{ov::inference_num_threads.name(), ov::PropertyMutability::RW},
            ov::PropertyName{ov::internal::threads_per_stream.name(), ov::PropertyMutability::RW}};
    } else if (ov::available_devices == name) {
        // Optionally enumerate OPAE tokens; for now, advertise a single logical device
        return decltype(ov::available_devices)::value_type{{"0"}};
    } else if (ov::device::full_name == name) {
        return decltype(ov::device::full_name)::value_type{"Spatial FPGA Device"};
    } else if (ov::device::architecture == name) {
        return decltype(ov::device::architecture)::value_type{get_device_name()};
    } else if (ov::device::type == name) {
        return decltype(ov::device::type)::value_type{ov::device::Type::INTEGRATED};
    } else if (ov::internal::caching_properties == name) {
        return decltype(ov::internal::caching_properties)::value_type{ov::device::architecture};
    } else if (ov::device::capabilities == name) {
        // AOT-only + export/import synthetic model
        return decltype(ov::device::capabilities)::value_type{ov::device::capability::FP32,
                                                              ov::device::capability::EXPORT_IMPORT};
    } else if (ov::execution_devices == name) {
        return decltype(ov::execution_devices)::value_type{get_device_name()};
    } else if (ov::range_for_async_infer_requests == name) {
        return decltype(ov::range_for_async_infer_requests)::value_type{1, 1, 1};
    } else {
        return m_cfg.Get(name);
    }
}

// Plugin entry symbol
static const ov::Version version = {"Custom Build", "Spatial Plugin"};
OV_DEFINE_PLUGIN_CREATE_FUNCTION(ov::template_plugin::Plugin, version)

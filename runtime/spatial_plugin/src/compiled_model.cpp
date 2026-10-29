// Copyright (C) 2018-2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

#include "compiled_model.hpp"

#include <memory>
#include <string>
#include <vector>

#include "async_infer_request.hpp"
#include "openvino/op/util/op_types.hpp"
#include "openvino/runtime/exec_model_info.hpp"
#include "openvino/runtime/properties.hpp"
#include "plugin.hpp"
#include "sync_infer_request.hpp"

#include "fpga.h"
#include "mmd.h"
#include "spatial_port_config.h"

namespace ov {
namespace template_plugin {

CompiledModel::CompiledModel(const std::shared_ptr<ov::Model>& model,
                             const std::shared_ptr<const ov::IPlugin>& plugin,
                             const ov::SoPtr<ov::IRemoteContext>& context,
                             const std::shared_ptr<ov::threading::ITaskExecutor>& task_executor,
                             const Configuration& cfg,
                             bool loaded_from_cache)
    : ov::ICompiledModel(model, plugin, context, task_executor),
      m_cfg(cfg),
      m_model(model),
      m_loaded_from_cache(loaded_from_cache) {
    // Same session setup as spatial_python open_mmd(): port config → connect → weights → reset
    OPENVINO_ASSERT(!m_cfg.port_config_path.empty(),
                    "SPATIAL: port config path is required (set SPATIAL_PORT_CONFIG)");
    OPENVINO_ASSERT(load_port_config(m_cfg.port_config_path.c_str()) == 0,
                    "SPATIAL: failed to load port config from ", m_cfg.port_config_path);

    OPENVINO_ASSERT(connect_to_fpga() == 0, "SPATIAL: connect_to_fpga failed");
    OPENVINO_ASSERT(reset() == 0, "SPATIAL: reset before weight load failed");
    OPENVINO_ASSERT(load_weights(m_cfg.weights_dir.c_str()) == 0,
                    "SPATIAL: failed to load weights from ", m_cfg.weights_dir);
    OPENVINO_ASSERT(reset() == 0, "SPATIAL: reset after weight load failed");
}

CompiledModel::~CompiledModel() {
    disconnect_fpga();
}

std::shared_ptr<ov::ISyncInferRequest> CompiledModel::create_sync_infer_request() const {
    return std::make_shared<InferRequest>(
        std::dynamic_pointer_cast<const CompiledModel>(shared_from_this()));
}

std::shared_ptr<ov::IAsyncInferRequest> CompiledModel::create_infer_request() const {
    auto internal_request = create_sync_infer_request();
    auto plugin = get_template_plugin();
    OPENVINO_ASSERT(plugin, "SPATIAL plugin: get_template_plugin() returned nullptr");
    return std::make_shared<AsyncInferRequest>(
        std::static_pointer_cast<InferRequest>(internal_request),
        get_task_executor(),
        plugin->m_waitExecutor,
        get_callback_executor());
}

void CompiledModel::export_model(std::ostream& model) const {
    OPENVINO_THROW("SPATIAL plugin: export_model not supported for AOT.");
}

std::shared_ptr<const ov::Model> CompiledModel::get_runtime_model() const {
    return m_model;
}

void CompiledModel::set_property(const ov::AnyMap& properties) {
    m_cfg = Configuration(properties, m_cfg, false);
}

ov::Any CompiledModel::get_property(const std::string& name) const {
    if (name == ov::model_name.name()) {
        return ov::Any(m_model->get_friendly_name());
    }
    if (name == ov::supported_properties.name()) {
        std::vector<ov::PropertyName> supported{
            ov::PropertyName(ov::model_name.name(), ov::PropertyMutability::RO),
            ov::PropertyName(ov::supported_properties.name(), ov::PropertyMutability::RO),
            ov::PropertyName(ov::optimal_number_of_infer_requests.name(), ov::PropertyMutability::RO),
        };
        return ov::Any(supported);
    }
    if (name == ov::optimal_number_of_infer_requests.name()) {
        return ov::Any{1u};
    }
    if (name == ov::loaded_from_cache.name()) {
        return ov::Any{m_loaded_from_cache};
    }
    OPENVINO_THROW("SPATIAL plugin: Unsupported property: ", name);
}

void CompiledModel::compile_model(const std::shared_ptr<ov::Model>& model) {
    // SPATIAL AOT: no JIT compilation
}

std::shared_ptr<const Plugin> CompiledModel::get_template_plugin() const {
    return std::dynamic_pointer_cast<const Plugin>(get_plugin());
}

}  // namespace template_plugin
}  // namespace ov

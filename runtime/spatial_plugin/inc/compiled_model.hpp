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

#include <atomic>
#include <memory>
#include <mutex>
#include <string>

#include "config.hpp"
#include "openvino/runtime/icompiled_model.hpp"
#include "openvino/runtime/iinfer_request.hpp"
#include "openvino/runtime/isync_infer_request.hpp"
#include "openvino/runtime/tensor.hpp"

namespace ov {
namespace template_plugin {

class Plugin;
class InferRequest;

/**
 * @class CompiledModel
 * @brief Implementation of compiled model for SPATIAL AOT plugin
 */
class CompiledModel : public ov::ICompiledModel {
 public:
    CompiledModel(const std::shared_ptr<ov::Model>& model,
                  const std::shared_ptr<const ov::IPlugin>& plugin,
                  const ov::SoPtr<ov::IRemoteContext>& context,
                  const std::shared_ptr<ov::threading::ITaskExecutor>& task_executor,
                  const Configuration& cfg,
                  bool loaded_from_cache = false);

    ~CompiledModel() override;

    // Methods from base class ov::ICompiledModel
    void export_model(std::ostream& model) const override;

    std::shared_ptr<const ov::Model> get_runtime_model() const override;

    void set_property(const ov::AnyMap& properties) override;

    ov::Any get_property(const std::string& name) const override;

    std::shared_ptr<ov::IAsyncInferRequest> create_infer_request() const override;

 protected:
    std::shared_ptr<ov::ISyncInferRequest> create_sync_infer_request() const override;

 private:
    friend class InferRequest;
    friend class Plugin;

    // SPATIAL AOT: no JIT compilation; kept for template compatibility
    void compile_model(const std::shared_ptr<ov::Model>& model);
    std::shared_ptr<const Plugin> get_template_plugin() const;

    mutable std::atomic<std::size_t> m_request_id{0};
    Configuration m_cfg;
    std::shared_ptr<ov::Model> m_model;
    const bool m_loaded_from_cache{false};

    // Serializes MMD process-wide session access across InferRequests
    mutable std::mutex m_hw_mutex;
};

}  // namespace template_plugin
}  // namespace ov

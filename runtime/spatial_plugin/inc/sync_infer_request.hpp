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

#include <array>
#include <chrono>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include <openvino/core/node.hpp>
#include <openvino/runtime/isync_infer_request.hpp>
#include <openvino/runtime/ivariable_state.hpp>

namespace ov {
namespace template_plugin {

// forward declaration
class CompiledModel;

// Sync infer request driving SPATIAL AOT hardware via CompiledModel.
class InferRequest : public ov::ISyncInferRequest {
 public:
    explicit InferRequest(const std::shared_ptr<const ov::template_plugin::CompiledModel>& compiled_model);
    ~InferRequest() override;

    // Execute synchronously (calls the SPATIAL run path)
    void infer() override;

    // Variable states (not used by SPATIAL; returns empty or cached states)
    std::vector<ov::SoPtr<ov::IVariableState>> query_state() const override;

    // Profiling info (basic stage timings: preprocess/start/wait/postprocess)
    std::vector<ov::ProfilingInfo> get_profiling_info() const override;

    // Pipeline stages used by AsyncInferRequest implementation
    void infer_preprocess();
    void start_pipeline();
    void wait_pipeline();
    void infer_postprocess();
    void cancel();

    void set_tensors_impl(const ov::Output<const ov::Node> port,
                          const std::vector<ov::SoPtr<ov::ITensor>>& tensors) override;

 private:
    std::shared_ptr<const CompiledModel> get_template_model() const;

    enum { Preprocess, Postprocess, StartPipeline, WaitPipeline, numOfStages };

    // Stage durations for basic profiling
    std::array<std::chrono::duration<float, std::micro>, numOfStages> m_durations{};

    // Backend IO tensors (point to user-provided buffers managed by OV)
    std::vector<ov::Tensor> m_backend_input_tensors;
    std::vector<ov::Tensor> m_backend_output_tensors;

    // Owning executable compiled model (config / MMD session lifetime)
    std::shared_ptr<ov::template_plugin::CompiledModel> m_executable;

    // Evaluation context (not used by SPATIAL but kept for template compatibility)
    ov::EvaluationContext m_eval_context;

    // Variable states cache
    std::vector<ov::SoPtr<ov::IVariableState>> m_variable_states;
};

}  // namespace template_plugin
}  // namespace ov

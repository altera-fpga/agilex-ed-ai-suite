// Copyright (C) 2018-2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

#include "sync_infer_request.hpp"

#include <chrono>
#include <cstring>
#include <memory>
#include <mutex>
#include <string>
#include <vector>

#include "itt.hpp"
#include <openvino/core/except.hpp>
#include <openvino/runtime/make_tensor.hpp>
#include <openvino/runtime/profiling_info.hpp>
#include <openvino/runtime/tensor.hpp>
#include "plugin.hpp"

#include "mmd.h"
#include "compiled_model.hpp"

using Time = std::chrono::high_resolution_clock;

namespace {

void allocate_tensor_impl(ov::SoPtr<ov::ITensor>& tensor,
                          const ov::element::Type& element_type,
                          const ov::Shape& shape) {
    if (!tensor || tensor->get_element_type() != element_type) {
        tensor = ov::make_tensor(element_type, shape);
    } else {
        tensor->set_shape(shape);
    }
}

}  // namespace

// Constructor
ov::template_plugin::InferRequest::InferRequest(const std::shared_ptr<const ov::template_plugin::CompiledModel>& model)
    : ov::ISyncInferRequest(model) {
    auto requestID = std::to_string(get_template_model()->m_request_id.fetch_add(1));
    std::string name = get_template_model()->m_model->get_friendly_name() + "_Req" + requestID;

    m_durations = {};
    m_backend_input_tensors.resize(get_inputs().size());
    m_backend_output_tensors.resize(get_outputs().size());

    for (const auto& input : get_inputs()) {
        allocate_tensor(input, [input](ov::SoPtr<ov::ITensor>& tensor) {
            allocate_tensor_impl(tensor,
                                 input.get_element_type(),
                                 input.get_partial_shape().is_dynamic() ? ov::Shape{0} : input.get_shape());
        });
    }
    for (const auto& output : get_outputs()) {
        allocate_tensor(output, [output](ov::SoPtr<ov::ITensor>& tensor) {
            allocate_tensor_impl(tensor,
                                 output.get_element_type(),
                                 output.get_partial_shape().is_dynamic() ? ov::Shape{0} : output.get_shape());
        });
    }
}

ov::template_plugin::InferRequest::~InferRequest() = default;

void ov::template_plugin::InferRequest::set_tensors_impl(const ov::Output<const ov::Node> port,
                                                         const std::vector<ov::SoPtr<ov::ITensor>>& tensors) {
    for (const auto& input : get_inputs()) {
        if (input == port) {
            m_batched_tensors[input.get_tensor_ptr()] = tensors;
            return;
        }
    }
    OPENVINO_THROW("Cannot find input tensors for port ", port);
}

std::vector<ov::SoPtr<ov::IVariableState>> ov::template_plugin::InferRequest::query_state() const {
    return m_variable_states;
}

std::shared_ptr<const ov::template_plugin::CompiledModel> ov::template_plugin::InferRequest::get_template_model() const {
    auto template_model = std::dynamic_pointer_cast<const ov::template_plugin::CompiledModel>(get_compiled_model());
    OPENVINO_ASSERT(template_model);
    return template_model;
}

void ov::template_plugin::InferRequest::infer() {
    infer_preprocess();
    start_pipeline();
    wait_pipeline();
    infer_postprocess();
}

void ov::template_plugin::InferRequest::infer_preprocess() {
    auto start = Time::now();
    convert_batched_tensors();
    check_tensors();
    auto itensor = get_tensor(get_inputs()[0]);
    m_backend_input_tensors[0] = ov::Tensor(itensor->get_element_type(), itensor->get_shape(), itensor->data());
    m_durations[Preprocess] = Time::now() - start;
}

void ov::template_plugin::InferRequest::start_pipeline() {
    auto start = Time::now();
    std::lock_guard<std::mutex> lock(get_template_model()->m_hw_mutex);

    auto& in_host = m_backend_input_tensors[0];
    const auto* in_ptr = reinterpret_cast<const uint64_t*>(in_host.data());
    std::vector<uint64_t> input(in_ptr, in_ptr + ov::shape_size(in_host.get_shape()));
    std::vector<uint64_t> output;

    OPENVINO_ASSERT(reset() == 0, "FPGA reset failed.");
    OPENVINO_ASSERT(run_inference(input, output) == 0, "FPGA run_inference failed.");

    // MMD sizes the output from the design packet ratio; mirror that into the OV tensor.
    auto otensor = get_tensor(get_outputs()[0]);
    otensor->set_shape(ov::Shape{output.size()});
    std::memcpy(otensor->data(), output.data(), output.size() * sizeof(uint64_t));
    m_backend_output_tensors[0] = ov::Tensor(otensor->get_element_type(), otensor->get_shape(), otensor->data());

    m_durations[StartPipeline] = Time::now() - start;
}

void ov::template_plugin::InferRequest::wait_pipeline() {
    auto start = Time::now();
    m_durations[WaitPipeline] = Time::now() - start;
}

void ov::template_plugin::InferRequest::infer_postprocess() {
    auto start = Time::now();
    m_durations[Postprocess] = Time::now() - start;
}

std::vector<ov::ProfilingInfo> ov::template_plugin::InferRequest::get_profiling_info() const {
    std::vector<ov::ProfilingInfo> info;
    const auto fill_profiling_info = [](const std::string& name,
                                        const std::chrono::duration<float, std::micro>& time) -> ov::ProfilingInfo {
        ov::ProfilingInfo p_info;
        p_info.status = ov::ProfilingInfo::Status::EXECUTED;
        p_info.node_name = name;
        p_info.cpu_time = p_info.real_time = std::chrono::duration_cast<std::chrono::milliseconds>(time);
        return p_info;
    };

    info.emplace_back(fill_profiling_info("input preprocessing", m_durations[Preprocess]));
    info.emplace_back(fill_profiling_info("execution time", m_durations[StartPipeline]));
    info.emplace_back(fill_profiling_info("output postprocessing", m_durations[Postprocess]));
    return info;
}

void ov::template_plugin::InferRequest::cancel() {
    // Synchronous path; no outstanding job to cancel
}

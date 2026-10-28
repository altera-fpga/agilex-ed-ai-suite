// Copyright (C) 2018-2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//

#include "async_infer_request.hpp"

#include "itt.hpp"
#include <openvino/runtime/iinfer_request.hpp>
#include "sync_infer_request.hpp"

namespace ov {
namespace template_plugin {

// AsyncInferRequest: builds pipeline for InferRequest stages.
// For SPATIAL AOT the hardware run is synchronous; we use a single-stage pipeline by default.
AsyncInferRequest::AsyncInferRequest(const std::shared_ptr<ov::template_plugin::InferRequest>& request,
                                     const std::shared_ptr<ov::threading::ITaskExecutor>& task_executor,
                                     const std::shared_ptr<ov::threading::ITaskExecutor>& wait_executor,
                                     const std::shared_ptr<ov::threading::ITaskExecutor>& callback_executor)
    : ov::IAsyncInferRequest(request, task_executor, callback_executor),
      m_wait_executor(wait_executor) {
    // remoteDevice=false -> single-stage pipeline on task_executor
    constexpr const bool remoteDevice = false;

    m_cancel_callback = [request] {
        request->cancel();
    };

    if (remoteDevice) {
        // Two-stage pipeline (start + wait) followed by postprocess
        m_pipeline = {
            {task_executor,
             [this, request] {
                 OV_ITT_SCOPED_TASK(itt::domains::TemplatePlugin,
                                    "TemplatePlugin::AsyncInferRequest::infer_preprocess_and_start_pipeline");
                 request->infer_preprocess();
                 request->start_pipeline();
             }},
            {m_wait_executor,
             [this, request] {
                 OV_ITT_SCOPED_TASK(itt::domains::TemplatePlugin,
                                    "TemplatePlugin::AsyncInferRequest::wait_pipeline");
                 request->wait_pipeline();
             }},
            {task_executor,
             [this, request] {
                 OV_ITT_SCOPED_TASK(itt::domains::TemplatePlugin,
                                    "TemplatePlugin::AsyncInferRequest::infer_postprocess");
                 request->infer_postprocess();
             }}
        };
    } else {
        // Single-stage pipeline: run the whole sync path on task_executor
        m_pipeline = {
            {task_executor,
             [this, request] {
                 OV_ITT_SCOPED_TASK(itt::domains::TemplatePlugin,
                                    "TemplatePlugin::AsyncInferRequest::infer_full_sync");
                 request->infer_preprocess();
                 request->start_pipeline();
                 request->wait_pipeline();
                 request->infer_postprocess();
             }}
        };
    }
}

AsyncInferRequest::~AsyncInferRequest() {
    ov::IAsyncInferRequest::stop_and_wait();
}

void AsyncInferRequest::cancel() {
    ov::IAsyncInferRequest::cancel();
    m_cancel_callback();
}

}  // namespace template_plugin
}  // namespace ov

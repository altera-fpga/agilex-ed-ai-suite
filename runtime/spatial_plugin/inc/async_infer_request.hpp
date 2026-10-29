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

#include <functional>
#include <memory>

#include <openvino/runtime/iasync_infer_request.hpp>
#include <openvino/runtime/iinfer_request.hpp>

#include "sync_infer_request.hpp"

namespace ov {
namespace template_plugin {

// AsyncInferRequest drives the staged pipeline for InferRequest.
// For SPATIAL AOT the pipeline is single-stage by default (all on task_executor).
class AsyncInferRequest : public ov::IAsyncInferRequest {
 public:
    AsyncInferRequest(const std::shared_ptr<InferRequest>& request,
                      const std::shared_ptr<ov::threading::ITaskExecutor>& task_executor,
                      const std::shared_ptr<ov::threading::ITaskExecutor>& wait_executor,
                      const std::shared_ptr<ov::threading::ITaskExecutor>& callback_executor);

    ~AsyncInferRequest() override;

    void cancel() override;

 private:
    std::function<void()> m_cancel_callback;
    std::shared_ptr<ov::threading::ITaskExecutor> m_wait_executor;
};

}  // namespace template_plugin
}  // namespace ov

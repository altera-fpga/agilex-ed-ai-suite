// Copyright 2022 Altera Corporation.
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

/*
  The raw_batch_job, raw_graph_job, and raw_device implement the interfaces
  used by dliaPlugin to mimic a inference flow without actually providing a
  inference. It is used to get the transformed input performed by the dliaPlugin
  upper layers
*/
#include "raw_graph_job.h"
#include "dla_aot_utils.h"
#include <fstream>
#include "dla_defines.h"

unique_ptr<GraphJob> RawGraphJob::MakeUnique(
  const CompiledResult * compiledResult,
  size_t numPipelines,
  int instance,
  uint32_t debugLevel = 0)
{
  return unique_ptr<GraphJob>(new RawGraphJob(compiledResult, numPipelines, instance, debugLevel));
}

RawGraphJob::RawGraphJob(
  const CompiledResult * compiledResult,
  size_t numPipelines,
  int instance,
  uint32_t debugLevel)
{
  assert(numPipelines);
  instance_ = instance;
  debugLevel_ = debugLevel;
  batchJobsRequested_ = 0;
  // input feature buffer size
  // TODO: support multi-input graph
  dlaBuffers_.input_feature_buffer_size =
      compiledResult->get_conv_input_size_in_bytes();
  // input feature buffer to be allocated outside this routine

  // output buffer size
  dlaBuffers_.output_feature_buffer_size =
      compiledResult->get_conv_output_size_in_bytes();

  // intermediate buffer size
  dlaBuffers_.intermediate_feature_buffer_size =
      compiledResult->get_conv_intermediate_size_in_bytes();

  // config and filter buffer size
  size_t num_config_words = compiledResult->get_num_config_words();
  dlaBuffers_.config_buffer_size = num_config_words * CONFIG_WORD_SIZE;
  dlaBuffers_.filter_bias_scale_buffer_size =
      compiledResult->get_total_filter_bias_scale_buffer_size();
  // store a pointer to CompiledResult to use config and filter buffer directly without copying
  dlaBuffers_.compiled_result = compiledResult;
  for(size_t i = 0; i < numPipelines; i++) {
    batchJobs_.push_back(move(RawBatchJob::MakeShared(compiledResult, &dlaBuffers_, instance_, debugLevel_)));
  }

  dlaBuffers_.input_feature_buffer = NULL;
}

std::shared_ptr<BatchJob> RawGraphJob::GetBatchJob() {
  graphJobMutex.lock();
  if(batchJobsRequested_ >= batchJobs_.size()) {
    graphJobMutex.unlock();
    return nullptr;
  }
  auto batchJob = batchJobs_[batchJobsRequested_];
  batchJobsRequested_++;
  graphJobMutex.unlock();
  return batchJob;
}

// Copyright 2020-2023 Altera Corporation.
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
#ifndef RAW_GRAPH_JOB_H
#define RAW_GRAPH_JOB_H

#include <assert.h>
#include <cstdio>
#include <memory>
#include <vector>
#if defined(_WIN32) || defined(_WIN64)
#ifndef NOMINMAX
#define NOMINMAX
#endif
#include <windows.h>
#else
#include <dlfcn.h>
#endif
#include <cstring>
#include <iostream>
#include <string>
#include <thread>
#include "compiled_result.h"

#include "dla_aot_structs.h"
#include "graph_job.h"
#include "raw_batch_job.h"
#include "raw_device.h"
using namespace dla;
/*! RawGraphJob is a DLA compiled graph loaded onto a emulation device
 * Initialized with Emulator Device object
 * RawGraphJob stores arrays filter, bias, config, inputs and outputs
 * It provides handle to "batch job" objects that are used to load input and start DLA for one batch
 */
class RawGraphJob : public GraphJob {
 public:
  static unique_ptr<GraphJob> MakeUnique(const CompiledResult* compiled_result,
                                         size_t numPipelines,
                                         int instance,
                                         uint32_t debugLevel);
  // Returns an unused batch job object
  // If all batch jobs are used, returns null
  // Increments batchJobsRequested_
  // Thread safe
  std::shared_ptr<BatchJob> GetBatchJob();
  RawGraphJob(const GraphJob&) = delete;
  RawGraphJob(RawGraphJob&) = delete;
  RawGraphJob& operator=(const RawGraphJob&) = delete;

 private:
  DLAInput dlaBuffers_;
  vector<shared_ptr<BatchJob>> batchJobs_;
  int instance_;
  uint32_t debugLevel_;
  unsigned int batchJobsRequested_;
  std::mutex graphJobMutex;
  RawGraphJob(const CompiledResult* compiledResult,
              size_t numPipelines,
              int instance,
              uint32_t debugLevel);
};

#endif

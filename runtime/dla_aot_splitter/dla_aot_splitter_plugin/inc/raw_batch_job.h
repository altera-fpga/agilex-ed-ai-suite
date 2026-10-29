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
#ifndef RAW_BATCH_JOB_H
#define RAW_BATCH_JOB_H

#include <assert.h>
#include <cstdio>
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
#include <memory>

#include "batch_job.h"
#include "dla_aot_structs.h"
#include "raw_device.h"

// RawBatchJob represents one batch execution
// Contains functions to start DLA
class RawBatchJob : public BatchJob {
 private:
  const CompiledResult* compiledResult;
  DLAInput* dlaBuffers_;
  DLAOutput output_;
  int instance_;
  uint32_t debugLevel_;
  RawBatchJob(const CompiledResult* compiledResult,
              DLAInput* dlaBuffers,
              int instance,
              uint32_t debugLevel);

 public:
  RawBatchJob(const RawBatchJob&) = delete;
  RawBatchJob(RawBatchJob&) = delete;
  RawBatchJob& operator=(const RawBatchJob&) = delete;
  static shared_ptr<BatchJob> MakeShared(const CompiledResult* compiledResult,
                                         DLAInput* dlaBuffers,
                                         int instance,
                                         uint32_t debugLevel);
  // @param inputArray - ptr to CPU array containing input data tp be copied to DDR
  // blocking function
  void LoadInputFeatureToDDR(void* inputArray) override;
  // Starts DLA by writing to CSR in DLA DMA; the DDR addresses of graph config and input data
  void StartDla() override;
  // @param outputArray - ptr to CPU array where the output data in DDR is copied into
  // outputArray must be allocated by the caller (size >= output_size_ddr)
  // blocking function
  void ReadOutputFeatureFromDDR(void* outputArray) const;
  void ScheduleInputFeature() const {}
};

#endif

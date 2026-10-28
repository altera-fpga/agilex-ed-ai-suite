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

#ifndef BATCH_JOB_H
#define BATCH_JOB_H

#include <cstdint>
#include <string>

class BatchJob {
 public:
  // @param inputArray - ptr to CPU array containing input data to be copied to DDR
  // @param async - if true will start emulator inferences in new threads
  // blocking function
  virtual void LoadInputFeatureToDDR(
    void* inputArray
  #ifdef EMULATOR_DLA_PLUGIN
    , bool async=false
  #endif
  ) = 0;
  // @param outputArray - ptr to CPU array where the output data in DDR is copied into
  // outputArray must be allocated by the caller (size >= output_size_ddr)
  // blocking function
  virtual void ReadOutputFeatureFromDDR(void* outputArray) const = 0;
  virtual void ScheduleInputFeature() const = 0;
  // @param async - if true will start emulator inferences in new threads
  virtual void StartDla(
  #ifdef EMULATOR_DLA_PLUGIN
    bool async=false
  #endif
  ) = 0;
  virtual void SetTraceContext(uint32_t /*trace_id*/, const std::string& /*scope_name*/) {}
  virtual ~BatchJob() {}
  virtual int GetThreadId() const { return 0; }
};

#endif

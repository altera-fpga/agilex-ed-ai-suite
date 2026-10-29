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
#ifndef RAW_DEVICE_H
#define RAW_DEVICE_H

#include <assert.h>
#include <chrono>
#include <cstdio>
#include <cstring>
#include <iostream>
#include <memory>
#include <string>
#include <thread>
#include <vector>
#include <map>
#include "compiled_result.h"
#include "device.h"
using namespace std;
using namespace dla;
class GraphJob;

class RawDevice : public Device {
 public:
  GraphJob* CreateGraphJob(const CompiledResult* compiledResult,
                           size_t numPipelines,
                           int instance,
                           const std::string export_dir,
                           const std::string on_chip_parameters_export_dir);
  // Return number of DLA jobs completed till now
  // Used for debugging
  int GetNumInferencesCompleted(int instance) const override;
  // Must be called when there are no active jobs on DLA
  // Returns the total time taken by DLA jobs on hardware (in milliseconds)
  double GetActiveHWTimeMs(int instance) const override;
  // Must be called when there are no active jobs on DLA
  // Returns the average of time taken per job (in milliseconds)
  // Avg Time per job < Active Time
  double GetAvgHWTimePerJobMs(size_t num_jobs, int instance) const override;
  RawDevice();
  void WaitForDla(int instance,
                  size_t threadId = 0,
                  std::function<bool()> isCancelled = nullptr) override;  // threadId is for debugging purpose only
  std::string SchedulerGetStatus() const override { return ""; }
  bool InitializeScheduler(uint32_t sourceBufferSize,
                           uint32_t dropSourceBuffers,
                           uint32_t numInferenceRequests,
                           const std::string source_fifo_file = "") override {
    return true;
  }
  int GetNumInstances() const override { return numInstances_; }
  int GetSizeCsrDescriptorQueue() const override { return -1; }  // meaningless here
  double GetCoreDlaClockFreq() const override { return -1.0; }   // meaningless here
  std::map<std::string, uint64_t> ReadDebugNetwork(int instance) const override {
    return std::map<std::string, uint64_t>();
  };
  PpnTraceData ReadPpnTrace(int instance, uint32_t num_nodes, uint32_t buffer_num_entries) const override { return {}; };
  uint64_t GetNumInputFeatureMemoryReads(int instance) const override { return 0; };
  uint64_t GetNumFilterMemoryReads(int instance) const override { return 0; };
  uint64_t GetNumOutputFeatureMemoryWrites(int instance) const override { return 0; };
  uint32_t GetInputFeatureChecksum(int instance) const override { return 0; };
  uint32_t GetFilterChecksum(int instance) const override { return 0; };
  uint32_t GetOutputFeatureChecksum(int instance) const override { return 0; };
  uint32_t GetClockCrossingCheck(int instance) const override { return 0; };
  bool HasStreamController() const override { return true; }

 private:
  vector<unique_ptr<GraphJob>> allGraphJobs_;
  int numInstances_;
};

#endif  // REF_DEVCE_H

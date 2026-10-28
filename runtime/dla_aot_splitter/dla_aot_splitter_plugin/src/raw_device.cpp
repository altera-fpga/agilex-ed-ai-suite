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

#include "raw_device.h"
#include "raw_graph_job.h"

unique_ptr<Device> Device::MakeUnique(const std::shared_ptr<const arch_params>&, uint32_t waitForDlaTimeoutSeconds, DLIAPlugin::Configuration&){
  return unique_ptr<Device>(new RawDevice());
}

RawDevice::RawDevice() {
  numInstances_ = 1;
}

GraphJob* RawDevice::CreateGraphJob(const CompiledResult * compiledResult,
  size_t numPipelines,
  int instance,
  const std::string export_dir,
  const std::string on_chip_parameters_export_dir)
{
  (void) export_dir;  // unused in HW runtime. CoreDLA utilizes base pointers, which the SW reference utilizes this variable. We void it here.
  (void) on_chip_parameters_export_dir;
  assert(instance < numInstances_);
  allGraphJobs_.push_back(move(RawGraphJob::MakeUnique(compiledResult, numPipelines, instance, 0)));
  return (allGraphJobs_.back()).get();
}

void RawDevice::WaitForDla(int instance, size_t threadId/* = 0 */, std::function<bool()> isCancelled) {
  //RawDevice does not do any real work. No need to wait
}

int RawDevice::GetNumInferencesCompleted(int instance) const {
  std::cout << "This function, GetNumInferencesCompleted, is not implemented for raw device" << std::endl;
  return 0;
}

double RawDevice::GetActiveHWTimeMs(int instance) const {
  std::cout << "This function, GetActiveHWTimeMs, is not implemented for raw device" << std::endl;
  return 0;
}

double RawDevice::GetAvgHWTimePerJobMs(size_t num_jobs, int instance) const {
  std::cout << "This function, GetAvgHWTimePerJobMs, is not implemented for raw device" << std::endl;
  return 0;
}

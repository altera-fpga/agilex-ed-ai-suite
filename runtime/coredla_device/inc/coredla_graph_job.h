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

#pragma once

#include "compiled_result.h"          //dla::CompiledResult
#include "coredla_batch_job.h"        //BatchJob
#include "device.h"                   //DLA_LOG
#include "device_memory_allocator.h"  //DeviceMemoryAllocator
#include "graph_job.h"                //GraphJob
#include "mmd_wrapper.h"              //MmdWrapper

// TODO:integrate with dla compiler later
//#include "dla_types.h"
//#include "compiled_result_runtime_required_elements.h"

#include <cstdint>  //uint64_t
#include <memory>   //std::unique_ptr
#include <mutex>    //std::mutex
#include <vector>   //std::vector

/*! GraphJob is a DLA compiled graph loaded onto a device
 * Initialized with DlaDevice object
 * GraphJob allocates space in DDR for filter, bias, config, inputs and outputs
 * It provides handle to "batch job" objects that are used to load input and start DLA for one batch
 */

class CoreDlaGraphJob : public GraphJob {
 public:
  // Function to construct and return a unique pointer GraphJob object to the runtime user
  // TODO: Provide DLA compiled result object which will contain all the necessary rutime elements as below
  // @param configFilterBiasBufferSizeDDR - total size of the constants - config, filter and bias
  // @param configFilterBiasBuffer - ptr to one contigous CPU array for config, filter and bias (obtained from DLA
  // compiler's output)
  // @param totalConfigWords - size of config data in words (size of 1 config word is defined in dla_device.h
  // "CONFIG_READER_DATA_BYTES")
  // @param intermediateBufferSizeDDR - size of the buffer space required in DDR for feature data of intermediate layers
  // @param inputSizeDDR - size of one batch input data in DDR. Multiple images in one batch should be contigously
  // placed
  // @param outputSizeDDR - size of one batch output data in DDR
  // @param numPipelines - number of I/O bufffer pairs created for CPU-FPGA pipelining of multiple batch runs
  // @param spStreamControllerComms - optional interface to stream controller
  static std::unique_ptr<GraphJob> MakeUnique(DeviceMemoryAllocator* ddrBufferAllocator,
                                              MmdWrapper* mmdWrapper,
                                              const dla::CompiledResult* compiled_result,
                                              uint64_t numPipelines,
                                              int instance,
                                              std::shared_ptr<StreamControllerComms> spStreamControllerComms);
  // Returns an unused batch job object
  // If all batch jobs are used, returns null
  // Increments batchJobsRequested_
  // Thread safe
  std::shared_ptr<BatchJob> GetBatchJob();
  CoreDlaGraphJob(const GraphJob&) = delete;
  CoreDlaGraphJob(CoreDlaGraphJob&) = delete;
  CoreDlaGraphJob& operator=(const CoreDlaGraphJob&) = delete;

 private:
  uint64_t configFilterBiasBufferSizeDDR_;
  uint64_t intermediateBufferSizeDDR_;
  DeviceMemoryAllocator* ddrBufferAllocator_;
  MmdWrapper* mmdWrapper_;
  std::vector<std::shared_ptr<BatchJob>> batchJobs_;
  unsigned int batchJobsRequested_;
  unsigned int instance_;
  std::mutex graphJobMutex;
  CoreDlaGraphJob(DeviceMemoryAllocator* ddrBufferAllocator,
                  MmdWrapper* mmdWrapper,
                  const dla::CompiledResult* compiledResult,
                  uint64_t numPipelines,
                  int instance,
                  std::shared_ptr<StreamControllerComms> spStreamControllerComms);
};

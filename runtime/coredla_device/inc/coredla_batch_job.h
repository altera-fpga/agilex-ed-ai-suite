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

#include "batch_job.h"    // BatchJob
#include "mmd_wrapper.h"  // MmdWrapper

// TODO:integrate with dla compiler later
// #include "dla_types.h"
// #include "compiled_result_runtime_required_elements.h"

#include <cstdint>  // uint64_t
#include <memory>   // std::unique_ptr

class StreamControllerComms;

// BatchJob represents one batch execution
// Contains input/output address and size in DDR for one batch
// Contains functions to write feature data to DDR, start DLA and read output data from DDR
class CoreDlaBatchJob : public BatchJob {
 private:
  // MMD access is required to handshake with CSR and transfer data between host/device memory
  MmdWrapper* mmdWrapper_;
  int instance_;
  // size and address of graph config data allocated in DDR
  uint64_t totalConfigWords_;
  uint64_t configBaseAddrDDR_;
  // size and address of input and output data allocated in DDR for 1 batch
  uint64_t inputAddrDDR_;
  uint64_t outputAddrDDR_;
  uint64_t inputSizeDDR_;
  uint64_t outputSizeDDR_;
  const bool enableIstream_;
  const bool enableOstream_;
  const bool enable_lt_writeback_;
  const bool enableOnChipParameters_;
  const bool disableExternalMemory_;
  uint64_t lastJobQueueNumber_;

  std::shared_ptr<StreamControllerComms> spStreamControllerComms_;
  const uint32_t post_lt_tensor_size_;

  uint32_t trace_id_ = 0;
  std::string trace_scope_name_;

  CoreDlaBatchJob(MmdWrapper* mmdWrapper,
                  uint64_t totalConfigWords,
                  uint64_t configBaseAddrDDR,
                  uint64_t inputAddrDDR,
                  uint64_t outputAddrDDR,
                  uint64_t inputSizeDDR,
                  uint64_t outputSizeDDR,
                  const bool enableIstream,
                  const bool enableOstream,
                  const bool enable_lt_writeback,
                  const bool enableOnChipParameters,
                  const bool disableExternalMemory,
                  int instance,
                  std::shared_ptr<StreamControllerComms> spStreamControllerComms,
                  uint32_t post_lt_tensor_size);

 public:
  CoreDlaBatchJob(const CoreDlaBatchJob&) = delete;
  CoreDlaBatchJob(CoreDlaBatchJob&) = delete;
  CoreDlaBatchJob& operator=(const CoreDlaBatchJob&) = delete;
  static std::shared_ptr<BatchJob> MakeShared(MmdWrapper* mmdWrapper,
                                              uint64_t totalConfigWords,
                                              uint64_t configBaseAddrDDR,
                                              uint64_t inputAddrDDR,
                                              uint64_t outputAddrDDR,
                                              uint64_t inputSizeDDR,
                                              uint64_t outputSizeDDR,
                                              const bool enableIstream,
                                              const bool enableOstream,
                                              const bool enable_lt_writeback,
                                              const bool enableOnChipParameters,
                                              const bool disableExternalMemory,
                                              int instance,
                                              std::shared_ptr<StreamControllerComms> spStreamControllerComms,
                                              uint32_t post_lt_tensor_size);
  // @param inputArray - ptr to CPU array containing input data tp be copied to DDR
  // blocking function
  void LoadInputFeatureToDDR(void* inputArray) override;
  void ScheduleInputFeature() const override;
  void SetTraceContext(uint32_t trace_id, const std::string& scope_name) override;

  // Starts DLA by writing to CSR in DLA DMA; the DDR addresses of graph config and input data
  void StartDla() override;
  // @param outputArray - ptr to CPU array where the output data in DDR is copied into
  // outputArray must be allocated by the caller (size >= output_size_ddr)
  // blocking function
  void ReadOutputFeatureFromDDR(void* outputArray) const override;
};

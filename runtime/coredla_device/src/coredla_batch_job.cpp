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

#include "coredla_batch_job.h"  //CoreDlaBatchJob
#include "dla_dma_constants.h"  //DLA_DMA_CSR_OFFSET_***
#include "dla_performance_profiler.hpp"
#include "stream_controller_comms.h"
#include <iostream>

static constexpr int CONFIG_READER_DATA_BYTES = 8;

std::shared_ptr<BatchJob> CoreDlaBatchJob::MakeShared(MmdWrapper* mmdWrapper,
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
                                                      uint32_t post_lt_tensor_size) {
  return std::shared_ptr<BatchJob>(new CoreDlaBatchJob(mmdWrapper,
                                                       totalConfigWords,
                                                       configBaseAddrDDR,
                                                       inputAddrDDR,
                                                       outputAddrDDR,
                                                       inputSizeDDR,
                                                       outputSizeDDR,
                                                       enableIstream,
                                                       enableOstream,
                                                       enable_lt_writeback,
                                                       enableOnChipParameters,
                                                       disableExternalMemory,
                                                       instance,
                                                       spStreamControllerComms,
                                                       post_lt_tensor_size));
}
CoreDlaBatchJob::CoreDlaBatchJob(MmdWrapper* mmdWrapper,
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
                                 uint32_t post_lt_tensor_size)
: mmdWrapper_(mmdWrapper)
, instance_(instance)
, totalConfigWords_(totalConfigWords)
, configBaseAddrDDR_(configBaseAddrDDR)
, inputAddrDDR_(inputAddrDDR)
, outputAddrDDR_(outputAddrDDR)
, inputSizeDDR_(inputSizeDDR)
, outputSizeDDR_(outputSizeDDR)
, enableIstream_(enableIstream)
, enableOstream_(enableOstream)
, enable_lt_writeback_(enable_lt_writeback)
, enableOnChipParameters_(enableOnChipParameters)
, disableExternalMemory_(disableExternalMemory)
, lastJobQueueNumber_(0)
, spStreamControllerComms_(spStreamControllerComms)
, post_lt_tensor_size_(post_lt_tensor_size) {
}

// This function must be called by a single thread
// It can be called on a different thread than StartDla or WaitForDla
void CoreDlaBatchJob::LoadInputFeatureToDDR(void* inputArray) {
  mmdWrapper_->enableCSRLogger();
  if (!enableIstream_) {
    mmdWrapper_->WriteToDDR(instance_, inputAddrDDR_, inputSizeDDR_, inputArray);
  }
  mmdWrapper_->disableCSRLogger();
  StartDla();
}

void CoreDlaBatchJob::ScheduleInputFeature() const {
  if (spStreamControllerComms_) {
    // Send message to NIOS-V
    uint64_t configurationSize64 = (totalConfigWords_ / CONFIG_READER_DATA_BYTES) - 2;
    uint32_t configurationBaseAddressDDR = static_cast<uint32_t>(configBaseAddrDDR_);
    uint32_t configurationSize = static_cast<uint32_t>(configurationSize64);
    uint32_t inputAddressDDR = static_cast<uint32_t>(inputAddrDDR_);
    uint32_t outputAddressDDR = static_cast<uint32_t>(outputAddrDDR_);

    Payload<CoreDlaJobPayload> item;
    item._configurationBaseAddressDDR = configurationBaseAddressDDR;
    item._configurationSize = configurationSize;
    item._inputAddressDDR = inputAddressDDR;
    item._outputAddressDDR = outputAddressDDR;

    spStreamControllerComms_->ScheduleItems( { item } );
  }
}

void CoreDlaBatchJob::SetTraceContext(uint32_t trace_id, const std::string& scope_name) {
  trace_id_ = trace_id;
  trace_scope_name_ = scope_name;
}

// This function must be called by a single thread
// It can be called on a different thread than WaitForDla or LoadInputFeatureToDDR
void CoreDlaBatchJob::StartDla() {

  //////////////////////////////////////
  //  Write to CSR to start the FPGA  //
  //////////////////////////////////////
  mmdWrapper_->enableCSRLogger();

  // interrupt mask was already enabled in the DlaDevice constructor
  // If writeback mode is enabled, should write to the CSR to set size and range of buffer space.
  if (enable_lt_writeback_) {
    mmdWrapper_->WriteToCsr(instance_, DLA_DMA_CSR_OFFSET_LT_WB_BASE_ADDR, 0x00);
    mmdWrapper_->WriteToCsr(instance_, DLA_DMA_CSR_OFFSET_LT_WB_FRAME_SIZE, post_lt_tensor_size_);
    mmdWrapper_->WriteToCsr(instance_, DLA_DMA_CSR_OFFSET_LT_WB_ADDR_RANGE, 5 * post_lt_tensor_size_); // 5x buffer size
  }
  // intermediate buffer address was already set when the graph was loaded

  // for ddr need to configure for each inference, nothing to do for ddrfree
  if (!disableExternalMemory_) {
    // base address for config reader
    if (!enableOnChipParameters_) {
      mmdWrapper_->WriteToCsr(instance_, DLA_DMA_CSR_OFFSET_CONFIG_BASE_ADDR, configBaseAddrDDR_);
      // how many words for config reader to read
      // hardware wants the number of words minus 2 since the implementation is a down counter which ends at -1, the sign
      // bit is used to denote the end of the counter range
      mmdWrapper_->WriteToCsr(instance_, DLA_DMA_CSR_OFFSET_CONFIG_RANGE_MINUS_TWO, (totalConfigWords_ / CONFIG_READER_DATA_BYTES) - 2);
    }

    if (enableIstream_) {
      // inform the config reader that only input streaming is enabled
      // will queue a descriptor for ddr with input streaming
      const unsigned int istreamOnlyEnable = 1;
      mmdWrapper_->WriteToCsr(instance_, DLA_CSR_OFFSET_READY_STREAMING_IFACE, istreamOnlyEnable);
    } else {
      // base address for feature reader -- this will trigger one run of DLA
      mmdWrapper_->WriteToCsr(instance_, DLA_DMA_CSR_OFFSET_INPUT_OUTPUT_BASE_ADDR, inputAddrDDR_);
    }
  }
  if (enableIstream_) {
    TRACE_SCOPE_ENTER("StreamInData", trace_id_, 0, trace_scope_name_);
    mmdWrapper_->StreamInData(instance_, inputSizeDDR_);
    TRACE_SCOPE_EXIT("StreamInData", trace_id_, 0, trace_scope_name_);
  }
  if (enableOstream_) {
    // Acquire lock before StreamOutData to prevent race conditions
    // when multiple inference requests are running concurrently.
    // Lock is released in ReadOutputFeatureFromDDR after reading the data.
    TRACE_SCOPE_ENTER("StreamOutData", trace_id_, 0, trace_scope_name_);
    mmdWrapper_->AcquireOstreamLock();
    mmdWrapper_->StreamOutData(instance_);
    TRACE_SCOPE_EXIT("StreamOutData", trace_id_, 0, trace_scope_name_);
  }
  mmdWrapper_->disableCSRLogger();
}

void CoreDlaBatchJob::ReadOutputFeatureFromDDR(void* outputArray) const {
  mmdWrapper_->enableCSRLogger();
  if (enableOstream_) {
    // Read the buffered stream-out data, then release the lock that was
    // acquired in StartDla before StreamOutData.
    mmdWrapper_->GetBufferedStreamOutData(instance_, outputArray);
    mmdWrapper_->ReleaseOstreamLock();
  } else {
    mmdWrapper_->ReadFromDDR(instance_, outputAddrDDR_, outputSizeDDR_, outputArray);
  }
  mmdWrapper_->disableCSRLogger();
}

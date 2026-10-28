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

#include "coredla_device.h"     //CoreDlaDevice
#include "coredla_batch_job.h"  //CoreDlaBatchJob
#include "coredla_graph_job.h"  //CoreDlaBatchJob
#include "dla_numeric_utils.h"
#include "dla_dma_constants.h"  //DLA_DMA_CSR_OFFSET_***
#include "stream_controller_comms.h"

#include <algorithm>  //std::count
#include <cassert>    //assert
#include <chrono>     //std::chrono::seconds
#include <cstddef>    //size_t
#include <cstdlib>    //std::getenv
#ifndef USE_OLD_COREDLA_DEVICE
#include <cinttypes>  //printf formatters
#endif
#include <mutex>      //std::mutex
#include <stdexcept>  //std::runtime_error
#include <string>     //std::string
#include <iostream>   //std::cerr
#include <stdint.h>   //
#include <thread>
#include <cinttypes>
#include <vector>
#include "dla_aligned_allocator.h"

using AlignedVecUint64 = std::vector<uint64_t, aligned_allocator<uint64_t, kMsgDMAMaxBurstBytes>>;

std::unique_ptr<Device> Device::MakeUnique(const std::shared_ptr<const arch_params>&,
                                           uint32_t waitForDlaTimeoutSeconds, DLIAPlugin::Configuration& cfg) {
  try {
    auto ptr =  std::unique_ptr<Device>(new CoreDlaDevice(waitForDlaTimeoutSeconds, cfg.mmdLogging, cfg.jtagPath));
    return ptr;
  } catch (const std::runtime_error& e) {
    std::cerr << "Failed to instantiate an FPGA device due to: " << e.what() << std::endl << std::flush;
  } catch (...) {
    std::cerr << "An unexpected exception occured when instantiating an FPGA device." << std::endl << std::flush;
  }
  return nullptr;
}

void InterruptServiceRoutine(int handle, void* data) {
  InterruptServiceRoutineData* isrData = static_cast<InterruptServiceRoutineData*>(data);
  // clear interrupt status -- write 1 to clear that bit
  constexpr int writeDataToClearInterruptStatus = 3;
  const int numInstances = static_cast<int>(isrData->jobsFinished.size());
  for (int i = 0; i < numInstances; i++) {
    isrData->mmdWrapper->WriteToCsr(i, DLA_DMA_CSR_OFFSET_INTERRUPT_CONTROL, writeDataToClearInterruptStatus);
  }
  for (int i = 0; i < numInstances; i++) {
    isrData->desc_queue_diag[i] = isrData->mmdWrapper->ReadFromCsr(i, DLA_DMA_CSR_OFFSET_DESC_DIAGNOSTICS);
    // ask the csr how many jobs have finished
    uint32_t completionCount =  isrData->mmdWrapper->ReadFromCsr(i, DLA_DMA_CSR_OFFSET_COMPLETION_COUNT);
    // check if the completionCount wraps around (overflow detection) and save this information
    if (isrData->prevCount[i] > completionCount)
      isrData->base_multiplier[i] ++;
    isrData->prevCount[i] = completionCount;
    // we add base_multiplier to account for the fact that a wrap around is actually an increment of 1
    std::unique_lock<std::mutex> isrMutexLock(isrData->isrMutex[i]);
    isrData->jobsFinished[i] = (uint64_t) isrData->base_multiplier[i] * UINT32_MAX + completionCount + isrData->base_multiplier[i];
    isrData->isrCondVar[i].notify_all();
  }
}

CoreDlaDevice::CoreDlaDevice(uint32_t waitForDlaTimeoutSeconds, bool enableLogging, const std::string jtagPath) :
#ifdef AOCL_JTAG_PATH
  mmdWrapper_(jtagPath, enableLogging),
#else
  mmdWrapper_(enableLogging),
#endif
  waitForDlaTimeoutSeconds_(waitForDlaTimeoutSeconds),
  jtagPath_(jtagPath) {
#ifdef COREDLA_RUNTIME_POLLING
  runtimePolling_ = true;
#else
  runtimePolling_ = false;
#endif
  // mmdWrapper_ ctor runs first, which will open a handle to the MMD. Now determine the number of hardware instances
  // by writing a nonzero value to some offset and then reading it back. While trying to enable the interrupt
  // mask, test for this.
  mmdWrapper_.enableCSRLogger();
  numInstances_ = 0;
  for (int i = 0; i < mmdWrapper_.GetMaxInstances(); i++) {
    constexpr uint32_t allInterruptsMask = (1<<DLA_DMA_CSR_INTERRUPT_ERROR_BIT) | (1<<DLA_DMA_CSR_INTERRUPT_DONE_BIT);
    // clear any pending interrupts (there may be pending interrupts from last run), then enable mask for instance count
    mmdWrapper_.WriteToCsr(i, DLA_DMA_CSR_OFFSET_INTERRUPT_CONTROL, allInterruptsMask);
    mmdWrapper_.WriteToCsr(i, DLA_DMA_CSR_OFFSET_INTERRUPT_MASK, allInterruptsMask);
    uint32_t readData = mmdWrapper_.ReadFromCsr(i, DLA_DMA_CSR_OFFSET_INTERRUPT_MASK);
    if (allInterruptsMask == readData) numInstances_ = i + 1;
  }
  LOG_AND_PRINT(Logger::INFO, "numInstances_: %d\n", numInstances_);
  assert(numInstances_ >= 1);

#if defined(USE_AGX7_IDK) || defined(USE_N6001_BOARD) || defined(USE_AGX5_MDK)
  // Currently Reset only works on OFS boards. Team is working on a solution to apply it on all platform.
  // reset DLA IP instances
  for (int i = 0; i < numInstances_; i++) {
    mmdWrapper_.WriteToCsr(i, DLA_DMA_CSR_OFFSET_IP_RESET, 1);
  }
  // sleep for 1ms
  // reset is held for 1024 clock cycles above
  // even at a very low 10 MHz DLA IP clock this would be 1024 * 100ns = 102400ns = 102.4us
  // 1ms should be enough for everything to come back out of reset and be operational
  usleep(1000);
#endif

  jobsWaited_.resize(numInstances_, 0);
  mmdWrapper_.disableCSRLogger();

  uint32_t license = mmdWrapper_.ReadFromCsr(0, DLA_DMA_CSR_OFFSET_LICENSE_FLAG);
  if (license == 0) {
    DLA_LOG("Using unlicensed IP\n");
  }
  else if (license == 1) {
    DLA_LOG("Using licensed IP\n");
  }
  else {
    throw std::runtime_error("Unrecognized license flag");
  }
#ifndef USE_OLD_COREDLA_DEVICE
  startClocksActive.resize(numInstances_, 0);
  startClockAllJobs.resize(numInstances_, 0);
#endif
  startNumInputFeatureMemoryReads.resize(numInstances_, 0);
  startNumFilterMemoryReads.resize(numInstances_, 0);
  startNumOutputFeatureMemoryWrites.resize(numInstances_, 0);

  // Package up the data that interrupt service routine needs
  isrData_.mmdWrapper = &mmdWrapper_;
  isrData_.jobsFinished = std::vector<uint64_t>(numInstances_, 0);
  isrData_.base_multiplier = std::vector<uint32_t>(numInstances_, 0);
  isrData_.prevCount = std::vector<uint32_t>(numInstances_, 0);
  isrData_.desc_queue_diag = std::vector<uint32_t>(numInstances_, 0);
  isrData_.isrMutex = std::vector<std::mutex>(numInstances_);
  isrData_.isrCondVar = std::vector<std::condition_variable>(numInstances_);

  mmdWrapper_.enableCSRLogger();
  if (runtimePolling_) {
    // disable the interrupt mask -- it was originally enabled to determine how many instances were present
    for (int i = 0; i < mmdWrapper_.GetMaxInstances(); i++) {
      constexpr uint32_t disableInterruptMaskValue = 0;
      mmdWrapper_.WriteToCsr(i, DLA_DMA_CSR_OFFSET_INTERRUPT_MASK, disableInterruptMaskValue);
    }
  }
  else {
    // register an interrupt handler
    mmdWrapper_.RegisterISR(&InterruptServiceRoutine, &isrData_);
  }
  mmdWrapper_.disableCSRLogger();

  // Record the current counters
  for(int i=0; i < numInstances_; i++) {
#ifndef USE_OLD_COREDLA_DEVICE
    jobsWaited_[i] = mmdWrapper_.ReadFromCsr(i, DLA_DMA_CSR_OFFSET_COMPLETION_COUNT);
    isrData_.jobsFinished[i] = jobsWaited_[i];

    startClocksActive[i] = GetClocksActive(i);
    startClockAllJobs[i] = GetClocksAllJobs(i);
#endif
    startNumInputFeatureMemoryReads.at(i) = GetNumInputFeatureMemoryReadsTotal(i);
    startNumFilterMemoryReads.at(i) = GetNumFilterMemoryReadsTotal(i);
    startNumOutputFeatureMemoryWrites.at(i) = GetNumOutputFeatureMemoryWritesTotal(i);
  }

  // Allocator needs access to mmd to write to CSR the start address of the shared intermediate buffer allocated in DDR
  ddrAllocator_ = std::unique_ptr<DeviceMemoryAllocator[]>(new DeviceMemoryAllocator[numInstances_]);
  for (int i = 0; i < numInstances_; i++) {
    ddrAllocator_[i].Initialize(mmdWrapper_.GetDDRSizePerInstance(), &mmdWrapper_);
  }

// Choose which data pattern you want, all zeros or all ones can also be useful for IP debug purposes
#define DEBUG_RUNTIME_MEMORY_TEST_PATTERN(ADDR, INDEX) ((ADDR * 12345) + (INDEX * 6789))
  //#define DEBUG_RUNTIME_MEMORY_TEST_PATTERN(ADDR,INDEX) (0)
  //#define DEBUG_RUNTIME_MEMORY_TEST_PATTERN(ADDR,INDEX) (0xffffffffffffffffULL)
  bool run_memory_test = getenv("COREDLA_RUNTIME_MEMORY_TEST") != nullptr;
  if (run_memory_test) {
    // Ensure host can access all of the device memory that is accessible by all CoreDLA instances
    // This is not necessarily the total device memory e.g. only 1 CoreDLA instance but 2 DDR banks
    DLA_LOG("starting memory test with %d instances\n", numInstances_);
    constexpr uint64_t CHUNK_SIZE = 1ULL << 20;  // one address check is 1 MB
    const uint64_t ADDR_LIMIT = mmdWrapper_.GetDDRSizePerInstance();
    int mismatch = 0;
    uint64_t expected;
    AlignedVecUint64 dataVec(CHUNK_SIZE / sizeof(uint64_t));
    uint64_t* data = dataVec.data();
    for (int inst = 0; inst < numInstances_; ++inst) {
      // write to entire fpga ddr
      for (uint64_t addr = 0; addr < ADDR_LIMIT; addr += CHUNK_SIZE) {
        for (uint64_t index = 0; index < CHUNK_SIZE / sizeof(uint64_t); index++)
          data[index] = DEBUG_RUNTIME_MEMORY_TEST_PATTERN(addr, index);
        mmdWrapper_.WriteToDDR(inst, addr, CHUNK_SIZE, data);
      }
      // read back entire fpga ddr and compare to expected
      for (uint64_t addr = 0; addr < ADDR_LIMIT; addr += CHUNK_SIZE) {
        mmdWrapper_.ReadFromDDR(inst, addr, CHUNK_SIZE, data);
        for (uint64_t index = 0; index < CHUNK_SIZE / sizeof(uint64_t); index++) {
          expected = DEBUG_RUNTIME_MEMORY_TEST_PATTERN(addr, index);
          if (data[index] != expected) {
            if (mismatch < 10) {
#if (!defined(USE_OLD_COREDLA_DEVICE) || defined(_WIN32))
              DLA_LOG("memory test mismatch, addr %" PRIu64 ", index %" PRIu64 ", got %" PRIu64 ", expected %" PRIu64
                      "\n",
                      addr,
                      index,
                      data[index],
                      expected);
#else
              DLA_LOG("memory test mismatch, addr %lu, index %lu, got %lu, expected %lu\n",
                      addr,
                      index,
                      data[index],
                      expected);
#endif
            }
            mismatch++;
          }
        }
      }
    }
    DLA_LOG("finished memory test ");
    if (mismatch == 0) {
      DLA_LOG("SUCCESS\n");
    } else {
      DLA_LOG("FAILURE (%d mismatches)\n", mismatch);
    }
  }
}

CoreDlaDevice::~CoreDlaDevice() {
  // Avoid the scenario where some CoreDLA job has been started but something goes wrong
  // in the runtime which causes it to exit, e.g. assertion failure or uncaught exception.
  // CoreDLA will still raise an interrupt when the job finishes, yet the runtime will no
  // longer be able to deal with it. Better to shut off interurpts.
  mmdWrapper_.enableCSRLogger();
  for (int instance = 0; instance < numInstances_; instance++) {
    // MmDWrapper.WriteToCSR might throw exception, and the destructor should not have
    // unhandled exception, so we need to handle exceptions internally
    try {
      mmdWrapper_.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_INTERRUPT_MASK, 0);
    } catch (const std::exception& e) {
      std::cerr << "Failed to shut off the DMA CSR interrupt mask due to " << e.what() << std::endl;
    }
  }
  mmdWrapper_.disableCSRLogger();
}

GraphJob* CoreDlaDevice::CreateGraphJob(const dla::CompiledResult* compiledResult,
#ifndef USE_OLD_COREDLA_DEVICE
                                        size_t numPipelines,
#else
                                        uint64_t numPipelines,
#endif
                                        int instance,
                                        const std::string export_dir,
                                        const std::string on_chip_parameters_export_dir) {
  assert(instance < numInstances_);
  (void) export_dir;  // unused in HW runtime. CoreDLA utilizes base pointers, which the SW emulator utilizes this variable. We void it here.
  allGraphJobs_.push_back(move(
      CoreDlaGraphJob::MakeUnique(&ddrAllocator_[instance], &mmdWrapper_, compiledResult, numPipelines, instance, spStreamControllerComms_)));
  return (allGraphJobs_.back()).get();
}

// This function must be called by a single thread
void CoreDlaDevice::WaitForDla(int instance, size_t threadId, std::function<bool()> isCancelledPredicate) {
  // ISR updates jobsFinished, if not enough jobs have finished then sleep until ISR runs again
  // it is possible that several hardware jobs could finish around the same time
  // by the time software handles the first interrupt, hardware could report that 2 jobs have
  // finished, for example the second time that waitForInterrupt runs, software already tracks
  // that the second job has finished and therefore don't need to sleep waiting for ISR
  std::unique_lock<std::mutex> isrMutexLock(isrData_.isrMutex[instance]);
  uint32_t completionCount = 0;
  bool timedOut = false;
  auto timeoutDuration = std::chrono::seconds(waitForDlaTimeoutSeconds_);

  mmdWrapper_.enableCSRLogger();
  if (runtimePolling_) {
    std::chrono::time_point<std::chrono::system_clock> pollingEndingTime =
        std::chrono::system_clock::now() + timeoutDuration;

    while (isrData_.jobsFinished[instance] == jobsWaited_[instance]) {
      // Update isrData_.jobsFinished[instance] here (polling)
      if (isCancelledPredicate and isCancelledPredicate()) {
        break;
      }

      completionCount = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_COMPLETION_COUNT);
      isrData_.jobsFinished[instance] = completionCount;
      if (std::chrono::system_clock::now() > pollingEndingTime) {
        timedOut = true;
        break;
      }
    }
  } else {
    while (isrData_.jobsFinished[instance] == jobsWaited_[instance]) {
      // isrData_.jobsFinished[instance] is updated in the ISR
      if (std::cv_status::timeout == isrData_.isrCondVar[instance].wait_for(isrMutexLock, timeoutDuration)) {
        timedOut = true;
        break;
      }
    }
  }
  mmdWrapper_.disableCSRLogger();

  if (timedOut) {
    std::string str_poll_vs_int = "interrupt";
    if (runtimePolling_) {
      str_poll_vs_int = "polling";
    }
    std::string timeoutMsg = "WaitForDla " + str_poll_vs_int + " timeout with threadId_" + std::to_string(threadId) + "\n";

    // Timeout has happened if we get here
    timeoutMsg += "If inference on one batch is expected to take more than " +
                  std::to_string(waitForDlaTimeoutSeconds_) +
                  " seconds, then increase WAIT_FOR_DLA_TIMEOUT in dlia_plugin.cpp and "
                  "recompile the runtime.\n";
    DLA_LOG("%s", timeoutMsg.c_str());  // this should always print, even if logging
                                        // verbosity is too low
    LOG(Logger::WARNING, "%s", timeoutMsg.c_str());
    std::string exceptionMsg = "FATAL ERROR: inference on FPGA did not complete";
    exceptionMsg += ", jobs finished " + std::to_string(isrData_.jobsFinished[instance]);
    exceptionMsg += ", jobs waited " + std::to_string(jobsWaited_[instance]);
    throw std::runtime_error(exceptionMsg);
  }

  if ((isrData_.desc_queue_diag[instance] >> DLA_DMA_CSR_DESC_DIAGNOSTICS_OUT_OF_INFERENCES_BIT) & 0x01) {
    std::cerr << "ERROR: Out of free inferences on this IP. " <<
                 "The Altera FPGA AI Suite cannot continue without a license!" << std::endl;
    std::string exceptionMsg = "Inference on FPGA exited with a license error";
    exceptionMsg += ", jobs finished " + std::to_string(isrData_.jobsFinished[instance]);
    exceptionMsg += ", jobs waited " + std::to_string(jobsWaited_[instance]);
    exceptionMsg += "\nPlease check your license. The Altera FPGA AI Suite cannot continue without a license!";
    throw std::runtime_error(exceptionMsg);
  }

  jobsWaited_[instance]++;
}

#ifndef USE_OLD_COREDLA_DEVICE
uint64_t CoreDlaDevice::GetClocksActive(int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t clocksActiveLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_LO);
  uint32_t clocksActiveHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_HI);
  return (((uint64_t)clocksActiveHi) << 32) | clocksActiveLo;
}

double CoreDlaDevice::GetActiveHWTimeMs(int instance) const {
  uint64_t clocksActive = GetClocksActive(instance) - startClocksActive[instance];
  // DDR clock freq is in MHz, so dividing by that would give microseconds, multiply by 1000 to get milliseconds
  return clocksActive / (1000.0 * mmdWrapper_.GetDDRClockFreq());
}
uint64_t CoreDlaDevice::GetClocksAllJobs(int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t clocksAllJobsLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_LO);
  uint32_t clocksAllJobsHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_HI);
  return (((uint64_t)clocksAllJobsHi) << 32) | clocksAllJobsLo;
}

double CoreDlaDevice::GetAvgHWTimePerJobMs(uint64_t num_jobs, int instance) const {
  uint64_t clocksAllJobs = GetClocksAllJobs(instance) - startClockAllJobs[instance];
  // DDR clock freq is in MHz, so dividing by that would give microseconds, multiply by 1000 to get milliseconds
  return clocksAllJobs / (1000.0 * mmdWrapper_.GetDDRClockFreq() * num_jobs);
}
#else
double CoreDlaDevice::GetActiveHWTimeMs(int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t clocksActiveLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_LO);
  uint32_t clocksActiveHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_HI);
  uint64_t clocksActive = (((uint64_t)clocksActiveHi) << 32) | clocksActiveLo;
  // DDR clock freq is in MHz, so dividing by that would give microseconds, multiply by 1000 to get milliseconds
  return clocksActive / (1000.0 * mmdWrapper_.GetDDRClockFreq());
}

double CoreDlaDevice::GetAvgHWTimePerJobMs(uint64_t num_jobs, int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t clocksAllJobsLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_LO);
  uint32_t clocksAllJobsHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_HI);
  uint64_t clocksAllJobs = (((uint64_t)clocksAllJobsHi) << 32) | clocksAllJobsLo;
  // DDR clock freq is in MHz, so dividing by that would give microseconds, multiply by 1000 to get milliseconds
  return clocksAllJobs / (1000.0 * mmdWrapper_.GetDDRClockFreq() * num_jobs);
}
#endif

uint64_t CoreDlaDevice::GetNumInputFeatureMemoryReads(int instance) const {
  return GetNumInputFeatureMemoryReadsTotal(instance) - startNumInputFeatureMemoryReads.at(instance);
}

uint64_t CoreDlaDevice::GetNumFilterMemoryReads(int instance) const {
  return GetNumFilterMemoryReadsTotal(instance) - startNumFilterMemoryReads.at(instance);
}

uint64_t CoreDlaDevice::GetNumOutputFeatureMemoryWrites(int instance) const {
  return GetNumOutputFeatureMemoryWritesTotal(instance) - startNumOutputFeatureMemoryWrites.at(instance);
}

uint64_t CoreDlaDevice::GetNumInputFeatureMemoryReadsTotal(int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t numIFReadsLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_FEATURE_READ_COUNT_LO);
  uint32_t numIFReadsHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_FEATURE_READ_COUNT_HI);
  uint64_t numIFReads = (((uint64_t) numIFReadsHi) << 32) | ((uint64_t) numIFReadsLo);
  return numIFReads;
}

uint64_t CoreDlaDevice::GetNumFilterMemoryReadsTotal(int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t numWeightReadsLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_FILTER_READ_COUNT_LO);
  uint32_t numWeightReadsHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_FILTER_READ_COUNT_HI);
  uint64_t numWeightReads = (((uint64_t) numWeightReadsHi) << 32) | ((uint64_t) numWeightReadsLo);
  return numWeightReads;
}

uint64_t CoreDlaDevice::GetNumOutputFeatureMemoryWritesTotal(int instance) const {
  //Important: To satisfy the anti-rollover feature of the 64-bit counters in the DMA CSR
  //the host must first read the lower 32-bit of the counter,
  //then immediately read the higher 32-bit of the counter
  uint32_t numOFReadsLo = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_OUTPUT_FEATURE_WRITE_COUNT_LO);
  uint32_t numOFReadsHi = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_OUTPUT_FEATURE_WRITE_COUNT_HI);
  uint64_t numOFReads = (((uint64_t) numOFReadsHi) << 32) | ((uint64_t) numOFReadsLo);
  return numOFReads;
}

uint32_t CoreDlaDevice::GetInputFeatureChecksum(int instance) const {
  return mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_FEATURE_READ_CHECKSUM);
}
uint32_t CoreDlaDevice::GetFilterChecksum(int instance) const {
  return mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_FILTER_READ_CHECKSUM);
}
uint32_t CoreDlaDevice::GetOutputFeatureChecksum(int instance) const {
  return mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_OUTPUT_FEATURE_WRITE_CHECKSUM);
}
uint32_t CoreDlaDevice::GetClockCrossingCheck (int instance) const {
  return mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_CLKXING_CHECK);
}

// Read one 32-bit value from the debug network, return value indicates whether read was successful. A read can fail if
// the module number and address have not been implemented. The debug network is fault tolerant to both read requests
// never being accepted as well as read responses never being produced.
bool CoreDlaDevice::ReadDebugCsr(
    uint32_t moduleNum, uint32_t address, int instance, uint32_t& readData, bool verbose) const {
  assert(moduleNum <= 0xff);
  assert(address <= 0xffffff);
  uint32_t addr = ((moduleNum & 0xff) << 24) | (address & 0xffffff);

  // Step 1: send the address that the debug network will use to issue a read request. Writing once to this CSR offset
  // will cause the debug network to issue one read request.
  mmdWrapper_.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_ADDR, addr);

  // Optional step: read back the value sent to CSR, sanity check that it is correct. Note this is all handled
  // internally to the CSR, e.g. the CSR does not go ask the debug network what address it sent.
  uint32_t addrCheck = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_ADDR);
  if (addr != addrCheck) {
    if (verbose) DLA_LOG("ReadDebugCsr addr read back check failed, expected %u, got %u\n", addr, addrCheck);
    return false;
  }

  // Step 2: the debug network should produce a read response which is cached by the CSR. Poll the corresponding status
  // register inside the CSR until this happens, or until the runtime decides to give up and declare the read a failure.
  // Do not throw an exception if the read fails, it is allowed to fail if the runtime is trying to figure out which
  // external debug-capable modules are attached to the debug network. Once the runtime has determined that a module is
  // attached, only then should read failures should cause an exception.
  uint32_t isValid = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_VALID);
  int retry = 5;
  while (!isValid && retry) {
    --retry;
    isValid = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_VALID);
  }
  if (!isValid) {
    if (verbose) DLA_LOG("ReadDebugCsr failed to read at addr %u\n", addr);
    return false;
  }

  // Step 3: runtime has confirmed the CSR has a cached the read response from debug network, now go and get the value.
  readData = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_DATA);
  if (verbose) DLA_LOG("ReadDebugCsr, addr %u, data %u\n", addr, readData);
  return true;
}

// This is a helper function that throws an exception if runtime fails to read from the debug network. This should only
// be called if the runtime has already confirmed that a module is attached to the debug network i.e. a previous read to
// this module number had succeeded.
void ReadDebugNetworkError(int moduleNum, int address, int instance) {
  std::string msg = "ReadDebugNetwork failure, instance " + std::to_string(instance) +
                    ", failed to read at module number " + std::to_string(moduleNum) + " address " +
                    std::to_string(address);
  throw std::runtime_error(msg);
}

// Modules attached to the debug network have a ROM to specify the offset and description of the registers. Traverse
// this ROM, then return a map of key/value pairs, where the key is a human readable string describing what kind of
// information the debug register contains, and the value is the data of the debug register. Note that the runtime must
// completely tranverse the ROM before reading any of the debug register values, and the runtime must read the debug
// register values in the order that they occur inside the ROM. Usually profiling counters are 64-bit values, and since
// there is only a 32-bit read available, it takes more than one read to get all the data. The counters could still be
// updating when the runtime wants to read them, so typically there is a freeze register which can be activated by
// reading from a special address (hardware will see an incoming read request to this address, that is how it knows to
// freeze the counters). The offset for the freeze register will typically go first in the ROM, even if it is not the
// first offset in the address space.
DebugNetworkData CoreDlaDevice::ReadDebugNetwork(int instance) const {
  DebugNetworkData result;
  for (uint32_t moduleNum = 0; moduleNum < 256; moduleNum++) {
    // Read the ROM to get the offsets and descriptions
    std::vector<uint32_t> offset;
    std::vector<std::string> description;
    uint32_t address = 0, readData = 0;
    bool first = true, success = false;
    while (1) {
      // Parse the offset
      success = ReadDebugCsr(moduleNum, address, instance, readData);
      if (!success) {
        // Failure to read is allowed on the very first time, it is assumed that no external debug-capable module is
        // attached to the debug network at this moduleNum
        if (first)
          break;
        else
          ReadDebugNetworkError(moduleNum, address, instance);
      }
      if (!readData) break;  // end of list is indicated with offset = 0
      first = false;
      address += 4;
      offset.push_back(readData);

      // Parse the description string
      std::string str;
      bool endOfStringSeen = false;
      while (!endOfStringSeen) {
        success = ReadDebugCsr(moduleNum, address, instance, readData);
        if (!success) ReadDebugNetworkError(moduleNum, address, instance);
        address += 4;
        for (int i = 0; i < 4; i++) {
          if (readData & 0xff) {
            str += ((char)(readData & 0xff));
            readData >>= 8;
          } else {
            endOfStringSeen = true;
            break;
          }
        }
      }
      description.push_back(str);
    }

    assert(offset.size() == description.size());

    // Read the profiling counters
    for (size_t i = 0; i < offset.size(); i++) {
      address = offset[i];
      success = ReadDebugCsr(moduleNum, address, instance, readData);
      if (!success) ReadDebugNetworkError(moduleNum, address, instance);

      int descriptionOccurenceCnt = result.count(description[i]);
      // Same description name should show up 2 times in maximum
      if (descriptionOccurenceCnt == 2) {
        throw std::runtime_error("More than 2 profiling counter descriptions are the same.");
      } else if (descriptionOccurenceCnt && (address - offset[i - 1] != 4)) {
        // same description existed before
        // check if the two addresses associatede with the same decription are consecutive (offset by 4)
        throw std::runtime_error("Profiling counter addresses with name: " + description[i] + " are not consecutive");
      } else if (std::count(offset.begin(), offset.end(), address) > 1) {
        // same address shows up more than once
        throw std::runtime_error("Duplicate profiling counter address: " + address);
      }

      // Avoid printing special stuff like _Freeze and _Unfreeze
      if (description[i].at(0) != '_') {
        if (descriptionOccurenceCnt) {
          // This key has existed before, concatenate 2 uint32_t into uint64_t
          result[description[i]] |= (((uint64_t)readData) << 32);
        } else {
          result[description[i]] = readData;
        }
      }
    }
  }
  return result;
}

uint32_t EncodePpnReadAddr(uint32_t node_id, uint32_t buf_idx, uint32_t num_nodes, uint32_t buffer_num_entries) {
  // The structure of the address is as follows:
  // the top clog2(NUM_NODES) bits are used for the node id, the bottom clog2(BUFFER_NUM_ENTRIES) bits are used for the buffer index

  const unsigned node_bits = DLA_CLOG2(num_nodes);
  const unsigned buf_bits = DLA_CLOG2(buffer_num_entries);
  // Ensure that the node and buffer index values can fit into their specified bit widths
  const uint32_t node_mask = static_cast<uint32_t>((1ull << node_bits) - 1ull);
  const uint32_t idx_mask = static_cast<uint32_t>((1ull << buf_bits) - 1ull);
  return ((node_id & node_mask) << (32 - node_bits)) | (buf_idx & idx_mask);
}

// Note, we currently require the runtime (with knowledge of the architecture) to ensure that the address is valid.
// For example, reading the input of a node that is not present in the arch will result in a valid response with rcount=0.
// The hardware will not return an error code since the address is technically valid.
bool CoreDlaDevice::ReadPpnCsr(uint32_t ppn_addr, int instance, uint32_t& rcount, uint32_t& start_ts, uint32_t& end_ts,
                             bool verbose) const {

  mmdWrapper_.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_PPN_ADDR, ppn_addr);

  uint32_t valid_word = 0;
  int retry = 50;
  while (retry--) {
    valid_word = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_PPN_VALID_CLEAR);
    if (valid_word != 0) {
      break;
    }
  }

  if (valid_word == 0) {
    if (verbose) DLA_LOG("ReadPpnCsr failed to get valid response at addr %u\n", ppn_addr);
    return false;
  }

  rcount = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_PPN_DATA_COUNT);
  start_ts = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_PPN_DATA_START);
  end_ts = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_PPN_DATA_END);
  if (verbose) DLA_LOG("ReadPpnCsr addr %u rcount %u start %u end %u\n", ppn_addr, rcount, start_ts, end_ts);
  return true;
}

bool CoreDlaDevice::ClearPpnCsr(int instance, bool verbose) const {
  mmdWrapper_.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_PPN_VALID_CLEAR, 1);

  uint32_t valid_word = 0;
  int retry = 50;
  while (retry--) {
    valid_word = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_PPN_VALID_CLEAR);
    if (valid_word != 0) {
      break;
    }
  }

  if (valid_word == 0) {
    if (verbose) DLA_LOG("ClearPpnCsr failed to get acknowledgment\n");
    return false;
  }

  uint32_t rcount = mmdWrapper_.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_PPN_DATA_COUNT);
  if (rcount != 0) {
    if (verbose) DLA_LOG("ClearPpnCsr unexpected rcount %u after clear (expected 0)\n", rcount);
    return false;
  }

  if (verbose) DLA_LOG("ClearPpnCsr succeeded\n");
  return true;
}

PpnTraceData CoreDlaDevice::ReadPpnTrace(int instance, uint32_t num_nodes, uint32_t buffer_num_entries) const {
  PpnTraceData result;
  for (uint32_t node = 0; node < num_nodes; node++) {
    uint32_t addr0 = EncodePpnReadAddr(node, 0, num_nodes, buffer_num_entries);
    uint32_t rcount = 0;
    uint32_t start_ts = 0;
    uint32_t end_ts = 0;
    if (!ReadPpnCsr(addr0, instance, rcount, start_ts, end_ts)) {
      continue;
    }

    // Entry 0: rcount holds the actual entry count (hardware returns remaining_count
    // for buffer_index == 0). A count of 0 means the node is absent or inactive.
    const uint32_t entry_count = rcount;
    if (entry_count == 0) {
      continue;
    }

    result[node].push_back(PpnTraceEntry{0, start_ts, end_ts, {}});

    uint32_t limit = entry_count;

    if (limit > buffer_num_entries) {
      // This is theoretically impossible for the hardware to produce more entries than the buffer can hold, but check just in case.
      DLA_LOG("Warning: entry_count %u exceeds buffer size %u, some entries will not be read\n", entry_count, buffer_num_entries);
    }
    for (uint32_t idx = 1; idx < limit; idx++) {
      uint32_t addr = EncodePpnReadAddr(node, idx, num_nodes, buffer_num_entries);
      if (!ReadPpnCsr(addr, instance, rcount, start_ts, end_ts)) {
        DLA_LOG("Warning: failed to read PPN trace entry for node %u idx %u\n", node, idx);
        break;
      }
      // Entry != 0: rcount holds the live central counter value. Pair it with
      // the host time to create a calibration point for counter-to-wallclock conversion.
      auto host_time = std::chrono::steady_clock::now();
      result[node].push_back(PpnTraceEntry{idx, start_ts, end_ts, CounterToTimePair{rcount, host_time}});
    }
  }

  if (!ClearPpnCsr(instance, false)) {
    DLA_LOG("Warning: failed to clear PPN trace data after readback\n");
  }

  return result;
}

int CoreDlaDevice::GetSizeCsrDescriptorQueue() const { return DLA_DMA_CSR_DESCRIPTOR_QUEUE_LOGICAL_SIZE; }

double CoreDlaDevice::GetCoreDlaClockFreq() const { return mmdWrapper_.GetCoreDlaClockFreq(); }

double CoreDlaDevice::GetDdrClockFreq() const { return mmdWrapper_.GetDDRClockFreq(); }

std::string CoreDlaDevice::SchedulerGetStatus() const {
  if (!spStreamControllerComms_) return "";

  Payload<StatusMessagePayload> statusPayload = spStreamControllerComms_->GetStatus();
  return spStreamControllerComms_->GetStatusString(statusPayload);
}

bool CoreDlaDevice::InitializeScheduler(uint32_t sourceBufferSize,
                                        uint32_t dropSourceBuffers,
                                        uint32_t numInferenceRequests,
                                        const std::string source_fifo_file) {
  // use FIFO file if supported, otherwise try to connect to StreamController
  if (mmdWrapper_.InitIStreamFifo(source_fifo_file)) {
    return true;
  }
  #ifdef AOCL_JTAG_PATH
  spStreamControllerComms_ = std::make_shared<StreamControllerComms>(jtagPath_);
  #else
  spStreamControllerComms_ = std::make_shared<StreamControllerComms>();
  #endif
  if (spStreamControllerComms_->IsPresent()) {
    bool initOK = spStreamControllerComms_->Initialize(sourceBufferSize, dropSourceBuffers, numInferenceRequests);
    return initOK;
  } else {
    spStreamControllerComms_.reset();
    return false;
  }
}

float CoreDlaDevice::GetBoardTemperature() const {
#if defined(USE_DE10_AGILEX)
  float reading{.0};
  size_t sz;
  this->mmdWrapper_.ReadBoardInfo(aocl_mmd_info_t::AOCL_MMD_TEMPERATURE, sizeof(float), &reading, &sz);
  return reading;
#else
  // To be implemented for other devices if needed.
  return 0;
#endif
}

float CoreDlaDevice::GetBoardInputPower() const {
#if defined(USE_DE10_AGILEX)
  float volt{.0}, amp{.0};
  size_t sz;
  this->mmdWrapper_.ReadBoardInfo(aocl_mmd_info_t::AOCL_MMD_POWER_IN_VOLTAGE, sizeof(float), &volt, &sz);   // Unit: mV
  this->mmdWrapper_.ReadBoardInfo(aocl_mmd_info_t::AOCL_MMD_POWER_IN_CURRENT, sizeof(float), &amp, &sz);    // Unit: mA
  return volt * 0.001 * amp * 0.001;
#else
  // To be implemented for other devices if needed.
  return 0;
#endif
}

bool CoreDlaDevice::HasStreamController() const {
  return mmdWrapper_.bIsStreamControllerValid(0);
}

void CoreDlaDevice::OnlineReconfig(const std::string mifs_path) const {
  mmdWrapper_.OnlineReconfig(mifs_path);
}

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

#ifndef DEVICE_H
#define DEVICE_H

#include <chrono>
#include <cstdint>
#include <functional>
#include <map>
#include <memory>
#include <string>
#include <vector>

#include "dla_runtime_log.h"
#include "dla_config.hpp"

using namespace std;
using DebugNetworkData = std::map<std::string, uint64_t>;

// Calibration point mapping a hardware central-counter value to a host-side time_point.
using CounterToTimePair = std::pair<uint32_t, std::chrono::steady_clock::time_point>;

// PPN (performance profiling network) trace slot from CSR readback.
struct PpnTraceEntry {
  uint32_t buffer_index;
  uint32_t start_timestamp;
  uint32_t end_timestamp;
  // Present for entries with buffer_index != 0.  Maps the hardware central counter
  // value (returned in rcount) to the host steady_clock time at the moment of readback.
  CounterToTimePair counter_to_time;
};

// Map of PPN trace entries, keyed by node ID.
using PpnTraceData = std::map<uint32_t, std::vector<PpnTraceEntry>>;

// DLA_DMA_CSR_OFFSET_PPN_VALID_CLEAR: any non-zero value on read means response is latched.
// DLA_DMA_CSR_OFFSET_PPN_DATA_COUNT: full 32-bit rcount is read from its own register.

// Must match PERFORMANCE_PROFILING_NUM_NODES in dla_top.sv.
inline constexpr uint32_t kDlaPpnNumNodes = 6;

// dla log macro
#define DLA_LOG(fmt, ...) printf(fmt, ##__VA_ARGS__);
#define DLA_ERROR(fmt, ...) printf(fmt, ##__VA_ARGS__);

class GraphJob;
class arch_params;
namespace dla {
class CompiledResult;
}
class Device {
 public:

  // Not all arguments of Device::MakeUnique are used by the definitions in derived objects
  // Parameters                       archParams          waitForDlaTimeoutSeconds            cfg
  // CoreDlaDevice::CoreDlaDevice     Not Used            Used                                Used
  // RefDevice::RefDevice             Used                Not Used                            Used
  // RawDevice::RawDevice             Not Used            Not Used                            Not Used

  static unique_ptr<Device> MakeUnique(const std::shared_ptr<const arch_params>& archParams, uint32_t waitForDlaTimeoutSeconds, DLIAPlugin::Configuration& cfg);

  virtual GraphJob* CreateGraphJob(const dla::CompiledResult* compiledResult,
                                   size_t numPipelines,
                                   int instance,
                                   const std::string export_dir,
                                   const std::string on_chip_parameters_export_dir) = 0;
  // Return number of DLA jobs completed till now
  // Used for debugging
  virtual int GetNumInferencesCompleted(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the total time taken by DLA jobs on hardware (in milliseconds)
  virtual double GetActiveHWTimeMs(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the average of time taken per job (in milliseconds)
  // Avg Time per job < Active Time
  virtual double GetAvgHWTimePerJobMs(uint64_t num_jobs, int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the number of memory read made by the input feature reader
  virtual uint64_t GetNumInputFeatureMemoryReads(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the number of memory read made by the filter reader
  virtual uint64_t GetNumFilterMemoryReads(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the number of memory writes made by the output feature writer
  virtual uint64_t GetNumOutputFeatureMemoryWrites(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the checksum of inputs received by DLA DMA on DDR clock in the feature reader
  virtual uint32_t GetInputFeatureChecksum(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the checksum of inputs received by DLA DMA on DDR clock in the filter reader
  virtual uint32_t GetFilterChecksum(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the checksum of outputs received by DLA DMA on DDR clock in the feature writer
  virtual uint32_t GetOutputFeatureChecksum(int instance) const = 0;
  // Must be called when there are no active jobs on DLA
  // Returns the comparisons of above checksums on DDR and DLA clock (0x7 meaning checksums are
  // the same between input/outputs on DDr and DLA clock)
  // Bit order is {input feature checksum, input filter check, output feature check}
  virtual uint32_t GetClockCrossingCheck (int instance) const = 0;
  // Waits for a job to finish on specified instance
  virtual void WaitForDla(int instance, size_t threadId = 0, std::function<bool()> isCancelled = nullptr) = 0;
  virtual int GetNumInstances() const = 0;
  virtual double GetCoreDlaClockFreq() const = 0;
  // DDR interface clock in MHz
  virtual double GetDdrClockFreq() const { return -1.0; }
  virtual int GetSizeCsrDescriptorQueue() const = 0;
  virtual std::string SchedulerGetStatus() const = 0;
  virtual bool InitializeScheduler(uint32_t sourceBufferSize,
                                   uint32_t dropSourceBuffers,
                                   uint32_t numInferenceRequests,
                                   const std::string source_fifo_file="") = 0;
  virtual bool HasStreamController() const = 0;
  virtual DebugNetworkData ReadDebugNetwork(int instance) const = 0;
  // Reads timestamp trace buffers via DMA CSR PPN ports (write ADDR, poll VALID_CLEAR, read START/END/COUNT).
  virtual PpnTraceData ReadPpnTrace(int instance, uint32_t num_nodes, uint32_t buffer_num_entries) const = 0;
  // Query device information. If no override, return 0 by default.
  virtual float GetBoardTemperature() const { return .0; }
  virtual float GetBoardInputPower() const { return .0; }
  // Used for Emulation (reference) Device
  #ifdef EMULATOR_DLA_PLUGIN
  virtual int GetNumThreads() const = 0;
  virtual int SetNumThreads(int numThreads) = 0;
  #endif
  virtual void OnlineReconfig(const std::string mifs_path) const {
    throw std::runtime_error("Online Reconfiguration is not supported on this device.");
  };
  virtual ~Device(){}
};

#endif  // DEVICE_H

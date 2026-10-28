// Copyright 2020 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Intel's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

#pragma once

#include <cstdint>  //uint32_t
#include <mutex>    //std::mutex
#include <string>
#ifndef USE_SYSTEM_CONSOLE
#include "aocl_mmd.h"
#endif

using interrupt_service_routine_signature = void (*)(int handle, void *data);

enum class MmdLogLevel {
  DISABLE,
  ENABLE,
  INTERNAL
};

class MmdWrapper {
 public:
#ifdef AOCL_JTAG_PATH
  MmdWrapper(const std::string& jtag_path, bool enableLog=false);
#else
  MmdWrapper(bool enableLog=false);
#endif
  // Note that ~MmdWrapper() can call std::exit(1) if aocl_mmd_close()
  // fails.  Ideally we would find some way to re-order the code so that it
  // can throw an exception (before calling the destructor) if aocl_mmd_close()
  // fails.
  ~MmdWrapper();

  // class cannot be copied
  MmdWrapper(const MmdWrapper &) = delete;
  MmdWrapper &operator=(const MmdWrapper &) = delete;

  // Register a function to run as the interrupt service routine
  void RegisterISR(interrupt_service_routine_signature func, void *data) const;

  // 32-bit handshake with each CSR
  void WriteToCsr(int instance, uint32_t addr, uint32_t data) const;
  uint32_t ReadFromCsr(int instance, uint32_t addr) const;

  // Copy data between host and device memory
  void WriteToDDR(int instance, uint64_t addr, uint64_t length, const void *data) const;
  void ReadFromDDR(int instance, uint64_t addr, uint64_t length, void *data) const;

  // Needs the data to have been already buffered so that it can be streamed over
  bool InitIStreamFifo(const std::string& fifo_file) const;
  int SetOStreamOutputShape(uint64_t channels, uint64_t height, uint64_t width, uint64_t c_vec) const;
  void GetBufferedStreamOutData(int instance, void* data) const;
  void StreamInData(int instance, uint64_t length) const;
  void StreamOutData(int instance) const;
  void OnlineReconfig(const std::string& mifs_path) const;

  // Lock/unlock for output streaming operations.
  // When multiple inference requests are in flight, the caller must:
  //   1. Call AcquireOstreamLock() before StreamOutData()
  //   2. Call ReleaseOstreamLock() after GetBufferedStreamOutData()
  // This ensures the stream-out and read operations are atomic.
  void AcquireOstreamLock() const;
  void ReleaseOstreamLock() const;

  // If the mmd layer supports accesses to the STREAM CONTROLLER
  bool bIsStreamControllerValid(int instance) const;

  // 32-bit handshake with each Stream Controller CSR
  void WriteToStreamController(int instance, uint32_t addr, uint64_t length, const void *data) const;
  void ReadFromStreamController(int instance, uint32_t addr, uint64_t length, void *data) const;

  // Provide read-only access to board-specific constants
  int GetMaxInstances() const { return maxInstances_; }
  uint64_t GetDDRSizePerInstance() const { return ddrSizePerInstance_; }
  double GetCoreDlaClockFreq() const { return coreDlaClockFreq_; }
  double GetDDRClockFreq() const { return ddrClockFreq_; }

  // (linqiaol) CSR logging control. Only useful for hostless EDs for now
  void enableCSRLogger();
  void disableCSRLogger();

#if defined(ENABLE_QUERY_DEVICE_INFO)
  // Query board information through board information interface.
  // Returns 0 on success, negative value on error.
  // requested_info_id - the requested information ID
  // param_value_size - the actual reading type size: sizeof(*reading), e.g. sizeof(float)
  // reading - pointer to the variable that will receive the requested info.
  // bytes_read - receives the number of bytes of data actually read
  int ReadBoardInfo(aocl_mmd_info_t requested_info_id, size_t param_value_size, void *reading, size_t *bytes_read) const;
#endif

 private:
  int handle_;
  int maxInstances_;
  uint64_t ddrSizePerInstance_;
  double coreDlaClockFreq_;
  double ddrClockFreq_;
  MmdLogLevel logLevel_;

  // Mutex to protect output streaming operations.
  // Ensures that StreamOutData and GetBufferedStreamOutData are atomic
  // when multiple inference requests are running concurrently.
  mutable std::mutex ostream_mutex_;
};

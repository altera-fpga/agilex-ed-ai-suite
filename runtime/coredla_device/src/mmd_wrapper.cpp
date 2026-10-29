// Copyright 2020-2023 Intel Corporation.
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

#include "mmd_wrapper.h"
#include "aocl_mmd.h"           // aocl_mmd_***
#include "dla_dma_constants.h"  // DLA_DMA_CSR_OFFSET_***

#include <cassert>    // assert
#include <cstddef>    // size_t
#include <iostream>   // std::cerr
#include <stdexcept>  // std::runtime_error
#include <string>     // std::string

// All board variants must obey the CoreDLA CSR spec, which says that all access must be
// - 32 bits in size
// - address must be 4 byte aligned
// - within the address range, CSR size is 2048 bytes
constexpr uint64_t DLA_CSR_ALIGNMENT = 4;
constexpr uint64_t DLA_CSR_SIZE = 2048;

// assert(status == 0) is removed by the c++ processor when compiling in release mode
// this is a handy workaround for suppressing the compiler warning about an unused variable
template <class T>
void suppress_warning_unused_varible(const T &) {}

#ifdef AOCL_JTAG_PATH
MmdWrapper::MmdWrapper(const std::string& jtag_path, bool enableLog) {
#else
MmdWrapper::MmdWrapper(bool enableLog) {
#endif
  // Open the MMD
  constexpr size_t MAX_BOARD_NAMES_LEN = 4096;
  char name[MAX_BOARD_NAMES_LEN];
  size_t sz;
  int status = aocl_mmd_get_offline_info(AOCL_MMD_BOARD_NAMES, MAX_BOARD_NAMES_LEN, name, &sz);
  if (status) {
    std::string msg = "Failed to query a board name from MMD. Perhaps no FPGA device is available?";
    throw std::runtime_error(msg);
  }
  #ifdef AOCL_JTAG_PATH
  int handle = aocl_mmd_open(name, jtag_path.c_str());
  #else
  int handle = aocl_mmd_open(name);
  #endif
  if (handle < 0) {
    std::string msg = "Failed to open MMD";
    throw std::runtime_error(msg);
  }
  handle_ = handle;

  // Query some board-specific information from the MMD. Some values can be hardcoded constants
  // where different boards have different constants, e.g. capacity of FPGA DDR. Others values may
  // be determined experimentally e.g. start and stop a counter with a known duration in between to
  // measure the clk_dla frequency.
  maxInstances_ = dla_mmd_get_max_num_instances();
  ddrSizePerInstance_ = dla_mmd_get_ddr_size_per_instance();
  coreDlaClockFreq_ = dla_mmd_get_coredla_clock_freq(handle_);

  // On DE10 Agilex boards with GCC 8.3.0, we noticed that the clock frequency was being read as 0,
  // around 50% of the time, and around 10% of the time on GCC 9.2.0, causing failures on perf_est
  // tests. This retry loop will recall the function until the coreDlaClockFreq is non zero, or
  // it exhausts 10 retries.
  // We have no idea why this happens currently, but it typically passes by the second try.
  int clockFreqRetries = 10;
  while (coreDlaClockFreq_ == 0 && clockFreqRetries > 0) {
    coreDlaClockFreq_ = dla_mmd_get_coredla_clock_freq(handle_);
    clockFreqRetries--;
  }
  ddrClockFreq_ = dla_mmd_get_ddr_clock_freq();
  logLevel_ = enableLog ? MmdLogLevel::ENABLE : MmdLogLevel::DISABLE;
}

MmdWrapper::~MmdWrapper() {
  // Close the MMD
  int status = aocl_mmd_close(handle_);
  if (status) {
    // Avoid throwning an exception from a Destructor.  We are ultimately
    // part of a (virtual) OpenVINO destructor, so we should follow the
    // noexcept(true) that it advertises.  Perhaps we can close the mmd
    // as a separate step prior to destruction to make signaling errors
    // easier?
    std::cerr << "Failed to close MMD" << std::endl;
    std::cerr << "Error status " << status << std::endl;
    std::exit(1);
  }
}

void MmdWrapper::RegisterISR(interrupt_service_routine_signature func, void *data) const {
  #ifdef COREDLA_RUNTIME_POLLING
    throw std::runtime_error("MmdWrapper::RegisterISR: Interrupts are not supported when COREDLA_RUNTIME_POLLING is set");
  #else
  // register an interrupt handler
  int status = aocl_mmd_set_interrupt_handler(handle_, func, data);
  if (status) {
    std::string msg = "Failed to register an interrupt handler with MMD";
    throw std::runtime_error(msg);
  }
  #endif
}

void MmdWrapper::WriteToCsr(int instance, uint32_t addr, uint32_t data) const {
  assert(instance >= 0 && instance < maxInstances_);
  assert(addr + sizeof(uint32_t) <= DLA_CSR_SIZE);
  assert(addr % DLA_CSR_ALIGNMENT == 0);
  int status = dla_mmd_csr_write(handle_, instance, addr, &data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

uint32_t MmdWrapper::ReadFromCsr(int instance, uint32_t addr) const {
  assert(instance >= 0 && instance < maxInstances_);
  assert(addr + sizeof(uint32_t) <= DLA_CSR_SIZE);
  assert(addr % DLA_CSR_ALIGNMENT == 0);
  uint32_t data;
  int status = dla_mmd_csr_read(handle_, instance, addr, &data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
  return data;
}

void MmdWrapper::WriteToDDR(int instance, uint64_t addr, uint64_t length, const void *data) const {
  assert(instance >= 0 && instance < maxInstances_);
  assert(addr + length <= ddrSizePerInstance_);
  int status = dla_mmd_ddr_write(handle_, instance, addr, length, data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

void MmdWrapper::ReadFromDDR(int instance, uint64_t addr, uint64_t length, void *data) const {
  assert(instance >= 0 && instance < maxInstances_);
  assert(addr + length <= ddrSizePerInstance_);
  int status = dla_mmd_ddr_read(handle_, instance, addr, length, data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

#ifdef AOCL_STREAMING
bool MmdWrapper::InitIStreamFifo(const std::string& fifo_file) const {
  int status = dla_mmd_istream_init_fifo(handle_, fifo_file.c_str());
  assert(status == 0);
  suppress_warning_unused_varible(status);
  return true; // return true if supported, even if there is an error
}

int MmdWrapper::SetOStreamOutputShape(uint64_t channels, uint64_t height, uint64_t width, uint64_t c_vec) const {
  int size = dla_mmd_ostream_set_output_shape(handle_, channels, height, width, c_vec);
  assert(size >= 0);
  return size;
}

void MmdWrapper::GetBufferedStreamOutData(int instance, void* data) const {
  assert(instance >= 0 && instance < maxInstances_);
  int status = dla_mmd_ostream_read(handle_, instance, data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

void MmdWrapper::StreamInData(int instance, uint64_t length) const {
  assert(instance >= 0 && instance < maxInstances_);
  int status = dla_mmd_istream(handle_, instance, length);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

void MmdWrapper::StreamOutData(int instance) const {
  assert(instance >= 0 && instance < maxInstances_);
  int status = dla_mmd_ostream_stream(handle_, instance);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

void MmdWrapper::OnlineReconfig(const std::string& mifs_path) const {
  int status = dla_mmd_online_reconfig(handle_, mifs_path.c_str());
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

void MmdWrapper::AcquireOstreamLock() const {
  ostream_mutex_.lock();
}

void MmdWrapper::ReleaseOstreamLock() const {
  ostream_mutex_.unlock();
}

#else
bool MmdWrapper::InitIStreamFifo(const std::string& fifo_file) const {
  return false;
}
int MmdWrapper::SetOStreamOutputShape(uint64_t channels, uint64_t height, uint64_t width, uint64_t c_vec) const {
  return -1;
}
void MmdWrapper::GetBufferedStreamOutData(int instance, void* data) const {}
void MmdWrapper::StreamInData(int instance, uint64_t length) const {}
void MmdWrapper::StreamOutData(int instance) const {}
void MmdWrapper::OnlineReconfig(const std::string& mifs_path) const {}
void MmdWrapper::AcquireOstreamLock() const {}
void MmdWrapper::ReleaseOstreamLock() const {}
#endif // AOCL_STREAMING

void MmdWrapper::enableCSRLogger() {
  // Non-hostless MMD currently does not support CSR logging
  // This function is required by the system-console runtime
  // This is just a placeholder
}

void MmdWrapper::disableCSRLogger() {
  // Non-hostless MMD currently does not support CSR logging
  // This function is required by the system-console runtime
  // This is just a placeholder
}

#if defined(ENABLE_QUERY_DEVICE_INFO)
int MmdWrapper::ReadBoardInfo(aocl_mmd_info_t requested_info_id, size_t param_value_size, void *reading, size_t *bytes_read) const {
  int err = aocl_mmd_get_info(handle_, requested_info_id, param_value_size, reading, bytes_read);
  if (err) {
    std::cerr << "aocl_mmd_get_info: Failed to query board information." << std::endl;
  }
  return err;
}
#endif

#ifndef STREAM_CONTROLLER_ACCESS
// Stream controller access is not supported by the platform abstraction
bool MmdWrapper::bIsStreamControllerValid(int instance) const { return false; }

// 32-bit handshake with each Stream Controller CSR
void MmdWrapper::WriteToStreamController(int instance, uint32_t addr, uint64_t length, const void *data) const {
  assert(false);
}

void MmdWrapper::ReadFromStreamController(int instance, uint32_t addr, uint64_t length, void *data) const {
  assert(false);
}
#else
// If the mmd layer supports accesses to the Stream Controller
bool MmdWrapper::bIsStreamControllerValid(int instance) const {
  assert(instance >= 0 && instance < maxInstances_);
  bool status = dla_is_stream_controller_valid(handle_, instance);
  return status;
}

// 32-bit handshake with each Stream Controller CSR
void MmdWrapper::WriteToStreamController(int instance, uint32_t addr, uint64_t length, const void *data) const {
  assert(instance >= 0 && instance < maxInstances_);
  assert(addr % sizeof(uint32_t) == 0);
  assert(length % sizeof(uint32_t) == 0);
  int status = dla_mmd_stream_controller_write(handle_, instance, addr, length, data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}

void MmdWrapper::ReadFromStreamController(int instance, uint32_t addr, uint64_t length, void *data) const {
  assert(instance >= 0 && instance < maxInstances_);
  assert(addr % sizeof(uint32_t) == 0);
  assert(length % sizeof(uint32_t) == 0);
  int status = dla_mmd_stream_controller_read(handle_, instance, addr, length, data);
  assert(status == 0);
  suppress_warning_unused_varible(status);
}
#endif

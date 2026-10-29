// (c) 1992-2024 Intel Corporation.
// Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words
// and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.
// and/or other countries. Other marks and brands may be claimed as the property
// of others. See Trademarks on intel.com for full list of Intel trademarks or
// the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera)
// Your use of Intel Corporation's design tools, logic functions and other
// software and tools, and its AMPP partner logic functions, and any output
// files any of the foregoing (including device programming or simulation
// files), and any associated documentation or information are expressly subject
// to the terms and conditions of the Altera Program License Subscription
// Agreement, Intel MegaCore Function License Agreement, or other applicable
// license agreement, including, without limitation, that your use is for the
// sole purpose of programming logic devices manufactured by Intel and sold by
// Intel or its authorized distributors.  Please refer to the applicable
// agreement for further details.

#ifndef KERNEL_INTERRUPT_H_
#define KERNEL_INTERRUPT_H_

#include <opae/fpga.h>

#include <atomic>
#include <chrono>
#include <mutex>
#include <thread>

#include "aocl_mmd.h"

namespace intel_opae_mmd {

class KernelInterrupt final {
 public:
  KernelInterrupt(fpga_handle fpga_handle_arg, int mmd_handle);
  ~KernelInterrupt();

  void enable_interrupts();
  void disable_interrupts();
  void set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void *user_data);

  KernelInterrupt(const KernelInterrupt &) = delete;
  KernelInterrupt &operator=(const KernelInterrupt &) = delete;
  KernelInterrupt(KernelInterrupt &&) = delete;
  KernelInterrupt &operator=(KernelInterrupt &&) = delete;

 private:
  static void set_member_for_interrupts();

  void notify_work_thread();
  void wait_for_event();
  void work_thread();

  static bool enable_thread;

  std::mutex m_mutex;
  std::unique_ptr<std::thread> m_work_thread;
  std::atomic<bool> m_work_thread_active;
  int m_eventfd;
  aocl_mmd_interrupt_handler_fn m_kernel_interrupt_fn;
  void *m_kernel_interrupt_user_data;
  fpga_handle m_fpga_handle;
  int m_mmd_handle;
  fpga_event_handle m_event_handle;
};

};  // namespace intel_opae_mmd

#endif  // KERNEL_INTERRUPT_H_

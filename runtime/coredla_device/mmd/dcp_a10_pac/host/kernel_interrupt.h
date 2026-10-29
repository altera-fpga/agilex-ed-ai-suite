/* (C) 1992-2017 Intel Corporation.                             */
/* Intel, the Intel logo, Intel, MegaCore, NIOS II, Quartus and TalkBack words     */
/* and logos are trademarks of Intel Corporation or its subsidiaries in the U.S.   */
/* and/or other countries. Other marks and brands may be claimed as the property   */
/* of others. See Trademarks on intel.com for full list of Intel trademarks or     */
/* the Trademarks & Brands Names Database (if Intel) or See www.Intel.com/legal (if Altera)  */
/* Your use of Intel Corporation's design tools, logic functions and other         */
/* software and tools, and its AMPP partner logic functions, and any output        */
/* files any of the foregoing (including device programming or simulation          */
/* files), and any associated documentation or information are expressly subject   */
/* to the terms and conditions of the Altera Program License Subscription          */
/* Agreement, Intel MegaCore Function License Agreement, or other applicable       */
/* license agreement, including, without limitation, that your use is for the      */
/* sole purpose of programming logic devices manufactured by Intel and sold by     */
/* Intel or its authorized distributors.  Please refer to the applicable           */
/* agreement for further details.                                                  */

#ifndef _KERNEL_INTERRUPT_H
#define _KERNEL_INTERRUPT_H

#include <opae/fpga.h>

#include <atomic>
#include <thread>

#include "aocl_mmd.h"

namespace intel_opae_mmd {

class eventfd_wrapper;

class KernelInterrupt final {
 public:
  KernelInterrupt(fpga_handle fpga_handle_arg, int mmd_handle);
  ~KernelInterrupt();

  bool initialized() { return m_initialized; }

  void set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void* user_data);
  void yield();
  static bool yield_is_enabled();

  void enable_interrupts();
  void disable_interrupts();

 private:
#ifndef DLA_MMD  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
  void set_interrupt_mask(uint32_t intr_mask);
#endif
  void run_kernel_interrupt_fn();
  bool poll_interrupt(int poll_timeout_arg);

  static void interrupt_polling_thread(KernelInterrupt& obj);

  bool m_initialized;
  eventfd_wrapper* m_eventfd_wrapper;

  std::thread* m_thread;

  aocl_mmd_interrupt_handler_fn m_kernel_interrupt_fn;
  void* m_kernel_interrupt_user_data;

  fpga_handle m_fpga_handle;
  int m_mmd_handle;

  fpga_event_handle m_event_handle;

  // not used and not implemented
  KernelInterrupt(KernelInterrupt& other);
  KernelInterrupt& operator=(const KernelInterrupt& other);
};  // class KernelInterrupt

};  // namespace intel_opae_mmd

#endif  // _KERNEL_INTERRUPT_H

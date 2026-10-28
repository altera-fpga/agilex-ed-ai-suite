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

#ifndef _MMD_DMA_H
#define _MMD_DMA_H

#pragma push_macro("_GNU_SOURCE")
#undef _GNU_SOURCE
#define _GNU_SOURCE
#include <sched.h>
#pragma pop_macro("_GNU_SOURCE")

#include <opae/fpga.h>

#include <mutex>

#include "aocl_mmd.h"
#include "dma_work_thread.h"
#include "fpga_dma.h"

namespace intel_opae_mmd {

class eventfd_wrapper;

class mmd_dma final {
 public:
  mmd_dma(fpga_handle fpga_handle_arg,
          int mmd_handle,
          uint64_t dfh_offset_arg,
          uint64_t ase_bbb_addr_arg,
          int interrupt_num_arg);
  ~mmd_dma();

  bool initialized() { return m_initialized; }

  fpga_result read_memory(aocl_mmd_op_t op, uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result write_memory(aocl_mmd_op_t op, const uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result do_dma(dma_work_item &item);

  void set_status_handler(aocl_mmd_status_handler_fn fn, void *user_data);

  // used after reconfigation
  void reinit_dma();

  void bind_to_node(void);

 private:
  // Helper functions
  fpga_result enqueue_dma(dma_work_item &item);
  fpga_result read_memory(uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result write_memory(const uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result read_memory_mmio(uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result write_memory_mmio(const uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result write_memory_mmio_unaligned(const uint64_t *host_addr, size_t dev_addr, size_t size);
  fpga_result read_memory_mmio_unaligned(void *host_addr, size_t dev_addr, size_t size);

  void event_update_fn(aocl_mmd_op_t op, int status);

  bool m_initialized;

  dma_work_thread *m_dma_work_thread;
  std::mutex m_dma_op_mutex;

  aocl_mmd_status_handler_fn m_status_handler_fn;
  void *m_status_handler_user_data;

  fpga_handle m_fpga_handle;
  int m_mmd_handle;

  uint64_t dfh_offset;
  int interrupt_num;
  fpga_dma_handle dma_h;
  uint64_t msgdma_bbb_base_addr;
  uint64_t ase_bbb_base_addr;

  // not used and not implemented
  mmd_dma(mmd_dma &other);
  mmd_dma &operator=(const mmd_dma &other);
};  // class mmd_dma

};  // namespace intel_opae_mmd

#endif  // _MMD_DMA_H

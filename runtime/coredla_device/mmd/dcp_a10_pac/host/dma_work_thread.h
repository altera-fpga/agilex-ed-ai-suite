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

#ifndef _DMA_WORK_THREAD_H
#define _DMA_WORK_THREAD_H

#include <opae/fpga.h>

#include <mutex>
#include <queue>
#include <thread>

#include "aocl_mmd.h"

namespace intel_opae_mmd {

// forward class definitions
class eventfd_wrapper;
class mmd_dma;

class dma_work_item {
 public:
  aocl_mmd_op_t op;
  uint64_t *rd_host_addr;
  const uint64_t *wr_host_addr;
  size_t dev_addr;
  size_t size;
};

class dma_work_thread final {
 public:
  dma_work_thread(mmd_dma &mmd_dma_arg);
  ~dma_work_thread();

  bool initialized() { return m_initialized; }

  int enqueue_dma(dma_work_item &item);
  int do_dma(dma_work_item &item);

 private:
  static void work_thread(dma_work_thread &obj);

  bool m_initialized;

  eventfd_wrapper *m_thread_wake_event;
  std::thread *m_thread;
  std::mutex m_work_queue_mutex;
  std::queue<dma_work_item> m_work_queue;

  mmd_dma &m_mmd_dma;

  // not used and not implemented
  dma_work_thread(dma_work_thread &other);
  dma_work_thread &operator=(const dma_work_thread &other);
};  // class dma_work_thread

};  // namespace intel_opae_mmd

#endif  // _DMA_WORK_THREAD_H

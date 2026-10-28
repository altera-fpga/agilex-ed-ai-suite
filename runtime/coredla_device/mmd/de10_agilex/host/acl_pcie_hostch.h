#ifndef ACL_PCIE_HOSTCH_H
#define ACL_PCIE_HOSTCH_H

/* (c) 1992-2021 Intel Corporation.                             */
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

/* ===- acl_pcie_hostch.h  -------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file declares the class to handle Linux-specific DMA operations.           */
/* The actual implementation of the class lives in the acl_pcie_dma_linux.cpp      */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

#ifdef DLA_MMD
#include <cstddef>  //size_t
#if defined(LINUX)
typedef int fpga_handle;
#else
#include <opae/fpga.h>
#endif
#endif

class ACL_PCIE_DEVICE;
class ACL_PCIE_MM_IO_MGR;
class ACL_PCIE_TIMER;
class ACL_PCIE_DMA;

class ACL_PCIE_HOSTCH {
 public:
  ACL_PCIE_HOSTCH(fpga_handle handle, ACL_PCIE_MM_IO_MGR *io, ACL_PCIE_DEVICE *pcie, ACL_PCIE_DMA *dma);

  ~ACL_PCIE_HOSTCH();

  // Initialize host channel specified by name, and return handle to it
  int create_hostchannel(char *name, size_t queue_depth, int direction);

  // Destroy host channel specified by channel handle
  // return 0 on success and negative otherwise
  int destroy_hostchannel(int channel);

  // Provide pointer to user with pointer to write and read to host channel
  // IP with. Pointer is pointer to MMD circular buffer, that's pre-pinned.
  // Address of this pre-pinned memory is transferred to IP during create
  void *get_buffer(size_t *buffer_size, int channel, int *status);

  // Acknowledge from user that send_size bytes of data has be written to
  // or read from host channel MMD buffer, that's provided by the channel
  // handle. This will move end index for push channel, and front index for
  // pull channel
  size_t ack_buffer(size_t send_size, int channel, int *status);

 private:
  ACL_PCIE_HOSTCH &operator=(const ACL_PCIE_HOSTCH &) { return *this; }

  ACL_PCIE_HOSTCH(const ACL_PCIE_HOSTCH &src) {}

  // Host Channel version of programmed device
  unsigned int get_hostch_version();

  // Helper functions to see if the thread that updates
  // host channel IP with user's buffer updates, is still running
  int launch_sync_thread();
  int sync_thread();
  void destroy_sync_thread();

  fpga_handle m_handle;
  ACL_PCIE_DEVICE *m_pcie;
  ACL_PCIE_MM_IO_MGR *m_io;
  ACL_PCIE_DMA *m_dma;

  ACL_PCIE_TIMER *m_timer;
  int m_use_timer;

  // Host Channel valid
  // If channel is open, equal to 1
  int m_hostch_push_valid;
  int m_hostch_pull_valid;

  // Input Queue
  // Write data into circular buffer in MMD, that host channel
  // can read from
  void *m_push_queue;
  size_t m_push_queue_local_end_p;
  size_t m_push_queue_size;

  // Information to track input queue
  void *m_pull_queue;
  size_t m_pull_queue_local_front_p;
  size_t m_pull_queue_size;
  size_t m_pull_queue_available;

  // Shared front and end pointer with driver
  // Circular buffer in MMD that the host channel IP can
  // write into. Host will then read from it
  size_t *m_pull_queue_pointer;
  size_t *m_push_queue_pointer;

  size_t *m_pull_queue_front_p;
  size_t *m_pull_queue_end_p;
  size_t *m_push_queue_front_p;
  size_t *m_push_queue_end_p;

  // User space memory that Linux kernel space has write
  // access to. Since the MMD buffer is circular, whenever
  // user writes to reads from it, the index for end and front
  // changes, respectively. This needs to be sent to host channel IP
  // and the thread in driver handles that. However, this thread will
  // die after 1ms of inactivity to free up the CPU. When it does that,
  // it will write to m_sync_thread with value of 0, so that MMD knows to
  // launch it again, for subsequent get_buffer and ack_buffer calls.
  int m_sync_thread_valid;
  size_t *m_sync_thread;
};

void acl_aligned_malloc(void **result, size_t size);
void acl_aligned_free(void *ptr);

#endif  // ACL_PCIE_HOSTCH_H

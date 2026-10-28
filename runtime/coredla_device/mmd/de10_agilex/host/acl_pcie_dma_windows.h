#ifndef ACL_PCIE_DMA_WINDOWS_H
#define ACL_PCIE_DMA_WINDOWS_H

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

/* ===- acl_pcie_dma_windows.h  --------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file declares the class to handle Windows-specific DMA operations.         */
/* The actual implementation of the class lives in the acl_pcie_dma_windows.cpp      */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
// TODO: update DMA related stuff and add wsid

#if defined(WINDOWS)

#include "hw_host_channel.h"
#include "hw_pcie_dma.h"

#include <windows.h>
#include <queue>

class ACL_PCIE_DEVICE;
class ACL_PCIE_MM_IO_MGR;
class ACL_PCIE_TIMER;

typedef struct _PAGE_INFO {
  ULONG64 pPhysicalAddr;
  UINT32 dwBytes;
} PAGE_INFO, *PPAGE_INFO;

typedef struct _DMA_PAGE {
  sg_element *Page;
  DWORD dwPages;
  UINT64 WsId;
} DMA_PAGE, *PDMA_PAGE;

typedef struct _QUEUE_STRUCT {
  UINT64 WsId;
  PVOID SGListPtr;

} QUEUE_STRUCT, *PQUEUE_STRUCT;

class ACL_PCIE_DMA {
 public:
  ACL_PCIE_DMA(fpga_handle Handle, ACL_PCIE_MM_IO_MGR *io, ACL_PCIE_DEVICE *pcie);
  ~ACL_PCIE_DMA();

  bool is_idle() { return m_idle; };
  void stall_until_idle() {
    while (!is_idle()) yield();
  };

  // Called by acl_pcie_device to check dma interrupt status
  int check_dma_interrupt(unsigned int *dma_update);

  // Perform operations required when a DMA interrupt comes
  void service_interrupt();

  // Relinquish the CPU to let any other thread to run
  // Return 0 since there is no useful work to be performed here
  int yield();

  // Transfer data between host and device
  // This function returns right after the transfer is scheduled
  // Return 0 on success
  int read_write(void *host_addr, size_t dev_addr, size_t bytes, aocl_mmd_op_t e, bool reading);

  // the callback function to be scheduled inside the interrupt handler
  friend void CALLBACK myWorkCallback(PTP_CALLBACK_INSTANCE instance, void *context, PTP_WORK work);

  // Seperate function to unpin memory
  friend void CALLBACK myWorkUnpinCallback(PTP_CALLBACK_INSTANCE instance, void *context, PTP_WORK work);

  // Seperate function to pin memory
  friend void CALLBACK myWorkPinCallback(PTP_CALLBACK_INSTANCE instance, void *context, PTP_WORK work);

  // Host channel functions
  int hostch_create(void *user_addr, void *buf_pointer, size_t size, int reading);
  int hostch_destroy(int reading);
  void hostch_thread_sync(void *m_sync_thread);

 private:
  ACL_PCIE_DMA &operator=(const ACL_PCIE_DMA &) { return *this; }

  ACL_PCIE_DMA(const ACL_PCIE_DMA &src) {}

  struct PINNED_MEM {
    sg_element *next_page;
    DWORD pages_rem;
    sg_element *dma_page;  // Pointer to the original array
    UINT64 WsId;
    PVOID UsrVa;
  };

  struct HOSTCH_DESC {
    size_t buffer_size;
    unsigned int loop_counter;

    // Host channel valid
    // If channel is open, equal to 1
    int push_valid;
    int pull_valid;

    // User memory circular buffer
    void *user_rd_buffer;
    void *user_wr_buffer;

    // Array of physical addresses of locked hostch pages
    HOSTCH_TABLE *push_page_table;
    HOSTCH_TABLE *pull_page_table;

    DMA_PAGE push_page_table_addr;
    DMA_PAGE pull_page_table_addr;

    // Physical address of the page table
    DMA_ADDR push_page_table_bus_addr;
    DMA_ADDR pull_page_table_bus_addr;

    PINNED_MEM m_hostch_rd_mem;
    PINNED_MEM m_hostch_wr_mem;

    // User memory circular buffer front and end pointers
    size_t *user_rd_front_pointer;
    size_t *user_rd_end_pointer;
    size_t *user_wr_front_pointer;
    size_t *user_wr_end_pointer;

    DMA_ADDR user_rd_front_pointer_bus_addr;
    DMA_ADDR user_wr_end_pointer_bus_addr;

    PINNED_MEM m_hostch_rd_pointer;
    PINNED_MEM m_hostch_wr_pointer;

    // Keep track of push end pointer
    size_t rd_buf_end_pointer;

    // Keep track of pull front pointer
    size_t wr_buf_front_pointer;

    // User and driver thread synchronizer
    int thread_sync_valid;
    size_t *user_thread_sync;
    DMA_ADDR user_thread_sync_bus_addr;
    PINNED_MEM m_sync_thread_pointer;
  };

  // function to be scheduled to execute whenever an interrupt arrived
  bool update(bool force_update = false);

  // Helper functions
  inline void *compute_address(void *base, uintptr_t offset);
  void set_read_desc(DMA_ADDR source, UINT64 dest, UINT32 ctl_dma_len);
  void set_write_desc(UINT64 source, DMA_ADDR dest, UINT32 ctl_dma_len);
  void set_desc_table_header();
  void send_dma_desc();
  void check_last_id(UINT32 *last_id);
  void pin_memory(PINNED_MEM *new_mem, bool prepin);
  void unpin_memory(PINNED_MEM *old_mem);
  void wait_finish();
  void unpin_from_queue();
  void prepin_memory();

  void set_immediate_desc(DMA_DESC_ENTRY *desc, UINT64 addr, UINT32 data, UINT32 id);
  void add_extra_dma_desc();
  // Hostchannel helper function
  void hostch_start(int channel);
  int hostch_push_update();
  int hostch_pull_update();
  int hostch_buffer_lock(void *addr, size_t len, PINNED_MEM *new_mem);
  void poll_wait();
  void set_hostch_page_entry(HOSTCH_ENTRY *page_entry, UINT64 page_addr, UINT32 page_num);
  void setup_dma_desc();
  void spin_loop_ns(UINT64 wait_ns);

  // From environment variable
  int m_use_polling;

  // The dma object we are currently building transactions for
  PINNED_MEM m_active_mem;
  PINNED_MEM m_pre_pinned_mem;
  PINNED_MEM m_done_mem;

  // Hostchannel Struct
  HOSTCH_DESC hostch_data;

  // The transaction we are currently working on
  DMA_DESC_TABLE *m_table_virt_addr;
  DMA_PAGE m_table_dma_addr;
  DMA_ADDR m_table_dma_phys_addr;
  DMA_DESC_ENTRY *m_active_descriptor;

  size_t m_last_pinned_size;
  void *m_last_pinned_addr;

  // Signal to stop multiple pre-pinning from running
  bool m_prepinned;

  // Local copy of last transfer id. Read once when DMA transfer starts
  UINT32 m_last_id;

  // variables for the read/write request
  aocl_mmd_op_t m_event;
  size_t m_dev_addr;
  void *m_host_addr;
  size_t m_bytes;
  size_t m_bytes_sent;
  size_t m_bytes_rem;
  bool m_read;
  bool m_idle;
  bool m_interrupt_disabled;

  fpga_handle m_handle;
  ACL_PCIE_DEVICE *m_pcie;
  ACL_PCIE_MM_IO_MGR *m_io;
  ACL_PCIE_TIMER *m_timer;

  // variables needed for the threadpool and works that submitted to it
  TP_CALLBACK_ENVIRON m_callback_env;
  PTP_POOL m_threadpool;
  PTP_WORK m_work;

  // This variable is accessed by the callback function defined in acl_pcie_dma_windows.cpp
  // This semaphore is intended to keep at most 1 work in queued (not running)
  HANDLE m_workqueue_semaphore;

  // Seperate thread to unpin

  std::queue<QUEUE_STRUCT> m_dma_unpin_pending;

  TP_CALLBACK_ENVIRON m_unpin_callback_env;
  PTP_POOL m_unpin_threadpool;
  PTP_WORK m_unpin_work;

  // Separate thread to pre-pin

  TP_CALLBACK_ENVIRON m_pin_callback_env;
  PTP_POOL m_pin_threadpool;
  PTP_WORK m_pin_work;
};

#endif  // WINDOWS

#endif  // ACL_PCIE_DMA_WINDOWS_H

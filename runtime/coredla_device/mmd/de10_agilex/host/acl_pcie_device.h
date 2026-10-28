#ifndef ACL_PCIE_DEVICE_H
#define ACL_PCIE_DEVICE_H

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

/* ===- acl_pcie_device.h  -------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file declares the class to handle operations on a single device.           */
/* The actual implementation of the class lives in the acl_pcie_device.cpp         */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// Forward declaration for classes used by ACL_PCIE_DEVICE
class ACL_PCIE_DMA;
class ACL_PCIE_CONFIG;
class ACL_PCIE_MM_IO_MGR;
class ACL_PCIE_HOSTCH;

#if defined(LINUX)
typedef int fpga_handle;
#else
#include <opae/fpga.h>
#endif  // LINUX

#ifdef DLA_MMD
// CoreDLA runtime assumes host/device transfers are thread safe
#include <mutex>
// don't assume opencl has been installed
typedef int cl_int;
#endif

// Encapsulates the functionality of an ACL device connected to the host
// through a PCI express bus.
class ACL_PCIE_DEVICE {
 public:
  ACL_PCIE_DEVICE(int dev_num, const char *name, int handle, int user_signal_number);
  ~ACL_PCIE_DEVICE();
  ACL_PCIE_DEVICE(const ACL_PCIE_DEVICE&) = delete;
  ACL_PCIE_DEVICE& operator= (const ACL_PCIE_DEVICE&) = delete;

  bool is_valid() { return m_device != INVALID_HANDLE_VALUE; };
  bool is_initialized() { return m_initialized; };
  bool is_being_programmed() { return m_being_programmed; };

  // Perform operations required when an interrupt is received for this device
  void service_interrupt(unsigned int irq_type_flag = 0);
  // This function can be used for triggering a fake device exception for
  void test_trigger_device_interrupt();

  // The callback function set by "set_status_handler"
  // It's used to notify/update the host whenever an event is finished
  void event_update_fn(aocl_mmd_op_t op, int status);

  // Called by the host program when there are spare cycles
  int yield();

  // Memory I/O
  // return 0 on success
  int write_block(aocl_mmd_op_t e, aocl_mmd_interface_t mmd_interface, void *host_addr, size_t dev_addr, size_t size);
  int read_block(aocl_mmd_op_t e, aocl_mmd_interface_t mmd_interface, void *host_addr, size_t dev_addr, size_t size);
  int copy_block(aocl_mmd_op_t e, aocl_mmd_interface_t mmd_interface, size_t src, size_t dst, size_t size);

  // Create channel. return handle to channel on success, negative otherwise
  int create_hostchannel(char *name, size_t queue_depth, int direction);

  // return 0 on success
  int destroy_channel(int channel);

  // return pointer that user can write to for write channel, and read from for read channel
  void *hostchannel_get_buffer(size_t *buffer_size, int channel, int *status);

  // return the size in bytes of the amount of buffer that was acknlowedged to channel
  size_t hostchannel_ack_buffer(size_t send_size, int channel, int *status);

  // Set kernel, device interrupts and event update callbacks
  // return 0 on success
  int set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void *user_data);
  int set_device_interrupt(aocl_mmd_device_interrupt_handler_fn fn, void *user_data);
  int set_status_handler(aocl_mmd_status_handler_fn fn, void *user_data);

  // Query PCIe information of the device
  char *get_dev_pcie_info() { return m_info.pcie_info_str; };

  // Query on-die temperature sensor, if available
  bool get_ondie_temp_slow_call(cl_int *temp);

  // Query Terasic board sensors.
  bool get_terasic_sensor_reading(acl_sensor_addr_t sensor, cl_int *reading);

  // Shared memory manipulation functions
  void *shared_mem_alloc(size_t size, unsigned long long *device_ptr_out);
  void shared_mem_free(void *host_ptr, size_t size);

  // Reprogram the device with given binary file
  // return 0 on success
#ifdef DLA_MMD
  int pause_and_save_pcie();
  int restore_and_resume_pcie();
  int reprogram_sof(const char *sof_filename, const bool skipSaveRestore = false);
#else
  int reprogram(void *data, size_t data_size, int program_mode);
#endif

 private:
  // Helper routines for interrupts
  // return 0 on success, negative on error
  int mask_irqs();
  int unmask_irqs();
  int unmask_kernel_irq();
  int disable_interrupts();
  int enable_interrupts(int user_signal_number);
  int get_interrupt_type(unsigned int *kernel_update, unsigned int *dma_update, unsigned int irq_type_flag);
#if defined(WINDOWS)
  void enable_msi(bool enable);
#endif  // WINDOWS

  // Helper routines for read or write operations
  // return 0 on success, negative on error (except for the "incr_ptrs" routine)
  int read_write_block(aocl_mmd_op_t e, void *host_addr, size_t dev_addr, size_t size, bool reading);
  int read_write_block_bar(void *host_addr, size_t dev_addr, size_t size, bool reading);
  int read_write_small_size(void *host_addr, size_t dev_addr, size_t size, bool reading);
  int set_segment(size_t addr);
  void incr_ptrs(void **host, size_t *dev, size_t *counter, size_t incr);
  int does_base_periph_match_new_periph(struct acl_pkg_file *pkg, const char *dev_name);

  // Helper routines for simple functionality test
  // return 0 on success, negative on error
  int version_id_test();
  int wait_for_uniphy();
  int pr_base_id_test(unsigned int pr_import_version);
  int deassert_pr_reset();
  int quartus_ver_test(char *pkg_qversion_str);
  int check_kernel_region_status();

  // Write a random value to cade_id register, do a read to confirm the write
  // Use the random value to find the JTAG cable for that board
  // Return 0 on ad_cable,ad_device_index if cable not found
  void find_jtag_cable(char *ad_cable, char *ad_device_index);

#ifndef DLA_MMD
  // Performs PR reprogramming if possible, and returns different statuses on
  // PR Hash, JTAG programming, RBF or Hash Presence
  // Returns 0 on success, 1 on reprogram fail
  int pr_reprogram(struct acl_pkg_file *pkg,
                   const char *SOFNAME,
                   int *rbf_or_hash_not_provided,
                   int *hash_mismatch,
                   unsigned *use_jtag_programming,
                   int *quartus_compile_version_mismatch);
#endif

  // Kernel interrupt handler and event update callbacks
  aocl_mmd_interrupt_handler_fn kernel_interrupt;
  void *kernel_interrupt_user_data;
  aocl_mmd_device_interrupt_handler_fn device_interrupt;
  void *device_interrupt_user_data;
  aocl_mmd_status_handler_fn event_update;
  void *event_update_user_data;
  int m_user_signal_number;

  ACL_PCIE_MM_IO_MGR *m_io;
  ACL_PCIE_DMA *m_dma;
  ACL_PCIE_HOSTCH *m_hostch;
  ACL_PCIE_CONFIG *m_config;

  static const int MAX_NAME_LENGTH = 32;
  int m_handle;
  char m_name[MAX_NAME_LENGTH];
  fpga_handle m_device;
  ACL_PCIE_DEVICE_DESCRIPTION m_info;

  bool m_use_dma_for_big_transfers;
  bool m_mmd_irq_handler_enable;
  bool m_initialized;
  bool m_being_programmed;
  bool m_skip_quartus_version_check;

  // IRQ acknowledgement commands in the KMD
  static const unsigned int NUM_ACK_CMDS = 3;
#if defined(WINDOWS)
  fpga_event_handle *dev_event_handle;
#endif  // WINDOWS

  // For the host, memory is segmented.  This stores the last used segment
  // ID so we don't needlessly update it in hardware
  UINT64 m_segment;

#ifdef DLA_MMD
  std::mutex m_dma_mutex;
#endif
};

#endif  // ACL_PCIE_DEVICE_H

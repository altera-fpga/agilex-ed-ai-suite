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

#ifndef MMD_DEVICE_H
#define MMD_DEVICE_H

#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <string>

#include <opae/fpga.h>

#include <uuid/uuid.h>

#include "aocl_mmd.h"
#include "mmd_dma.h"
#include "mmd_helper.h"

#include "kernel_interrupt.h"

// Tune delay for simulation or HW. Eventually delay
// should be removed for HW, may still be needed for ASE simulation
#ifdef SIM
#define DELAY_MULTIPLIER 100
#else
#define DELAY_MULTIPLIER 1
#endif

// Most AOCL_MMD_CALL functions return negative number in case of error,
// MMD_AOCL_ERR is used to indicate an error from the MMD that is being
// returned to the runtime.  Simply set to -2 for now since neither interface
// defines a meaning to return codes for errors.
#define MMD_AOCL_ERR -1

// NOTE: some of the code relies on invalid handle returning -1
// future TODO eliminate dependency on specific error values
#define MMD_INVALID_PARAM -1

// Our diagnostic script relies on handle values < -1 to determine when
// a valid device is present but a functioning ASP is not loaded.
#define MMD_ASP_NOT_LOADED -2
#define MMD_ASP_INIT_FAILED -3

// Delay settings
#define MMIO_DELAY()
#define YIELD_DELAY() usleep(1 * DELAY_MULTIPLIER)

#define ASP_NAME "ofs_"

#define SVM_MMD_MPF 0x24000

#define SVM_DDR_OFFSET 0x1000000000000
#define PCI_DDR_OFFSET 0

enum {
  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
  AOCL_IRQ_POLLING_BASE = 0x0100,  // CSR to polling interrupt status
  AOCL_IRQ_MASKING_BASE = 0x0108,  // CSR to set/unset interrupt mask
  AOCL_MMD_KERNEL = 0,
  AOCL_MMD_MEMORY = 1,
  AOCL_MMD_DLA_CSR = 2,
};

enum AfuStatu { MMD_INVALID_ID = 0, MMD_ASP, MMD_AFU };

class Device final {
 public:
  Device(uint64_t);
  Device(const Device &) = delete;
  Device &operator=(const Device &) = delete;
  ~Device();

  static bool parse_board_name(const char *board_name, uint64_t &obj_id);

  int get_mmd_handle() { return mmd_handle; }
  uint64_t get_fpga_obj_id() { return fpga_obj_id; }
  std::string get_dev_name() { return mmd_dev_name; }
  std::string get_bdf();
  float get_temperature();

  bool initialize_asp();
  void set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void *user_data);
  void set_status_handler(aocl_mmd_status_handler_fn fn, void *user_data);
  void event_update_fn(aocl_mmd_op_t op, int status);
  bool asp_loaded();

  int read_block(aocl_mmd_op_t op, int mmd_interface, void *host_addr, size_t dev_addr, size_t size);
  int write_block(aocl_mmd_op_t op, int mmd_interface, const void *host_addr, size_t dev_addr, size_t size);

 private:
  static int next_mmd_handle;

  int mmd_handle;
  uint64_t fpga_obj_id;
  std::string mmd_dev_name;
  intel_opae_mmd::KernelInterrupt *kernel_interrupt_thread;
  aocl_mmd_status_handler_fn event_update;
  void *event_update_user_data;

  std::string fpga_numa_node;
  bool enable_set_numa;
  bool fme_sysfs_temp_initialized;
  void initialize_fme_sysfs();
  void initialize_local_cpus_sysfs();
  bool find_dma_dfh_offsets();

  uint8_t bus;
  uint8_t device;
  uint8_t function;

  bool afu_initialized;
  bool asp_initialized;
  bool mmio_is_mapped;

  fpga_properties filter;
  fpga_token mmio_token;
  fpga_handle mmio_handle;
  fpga_token fme_token;
  fpga_guid guid;
  intel_opae_mmd::mmd_dma *mmd_dma;
  std::mutex m_dma_mutex;

  // Helper functions
  int read_mmio(void *host_addr, size_t dev_addr, size_t size);
  int write_mmio(const void *host_addr, size_t dev_addr, size_t size);
};

#endif  // MMD_DEVICE_H

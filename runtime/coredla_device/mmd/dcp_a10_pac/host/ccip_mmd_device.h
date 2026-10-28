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

#ifndef _CCIP_MMD_DEVICE_H
#define _CCIP_MMD_DEVICE_H

#include <limits.h>
#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

#include <string>

#pragma push_macro("_GNU_SOURCE")
#undef _GNU_SOURCE
#define _GNU_SOURCE
#include <sched.h>
#pragma pop_macro("_GNU_SOURCE")

#include <opae/fpga.h>
#include <uuid/uuid.h>

#include "aocl_mmd.h"
#include "kernel_interrupt.h"
#include "mmd_dma.h"

// Tune delay for simulation or HW. Eventually delay
// should be removed for HW, may still be needed for ASE simulation
#ifdef SIM
#define DELAY_MULTIPLIER 100
#else
#define DELAY_MULTIPLIER 1
#endif

// Most AOCL_MMD_CALL functions return negative number in case of error,
// CCIP_MMD_AOCL_ERR is used to indicate an error from the MMD that is being
// returned to the runtime.  Simply set to -2 for now since neither interface
// defines a meaning to return codes for errors.
#define CCIP_MMD_AOCL_ERR -1

// NOTE: some of the code relies on invalid handle returning -1
// future TODO eliminate dependency on specific error values
#define CCIP_MMD_INVALID_PARAM -1

// Our diagnostic script relies on handle values < -1 to determine when
// a valid device is present but a functioning BSP is not loaded.
#define CCIP_MMD_BSP_NOT_LOADED -2
#define CCIP_MMD_BSP_INIT_FAILED -3

// Delay settings
// TODO: Figure out why these delays are needed and
// have requirement removed (at least for HW)
#define MMIO_DELAY()
#define YIELD_DELAY() usleep(1 * DELAY_MULTIPLIER)
#define OPENCL_SW_RESET_DELAY() usleep(5000 * DELAY_MULTIPLIER)
#define AFU_RESET_DELAY() usleep(20000 * DELAY_MULTIPLIER)

#define KERNEL_SW_RESET_BASE (AOCL_MMD_KERNEL + 0x30)

#define DCP_OPENCL_BSP_AFU_ID "63B3779B-8BDD-4F03-9CEB-0301181D6AEF"

#define BSP_NAME "pac_"

// LOG ERRORS
#define CCIP_MMD_ERR_LOGGING 1
#ifdef CCIP_MMD_ERR_LOGGING
#define LOG_ERR(...) fprintf(stderr, __VA_ARGS__)
#else
#define LOG_ERR(...)
#endif

// debugging
#ifdef DEBUG
#define DEBUG_PRINT(...) fprintf(stderr, __VA_ARGS__)
#else
#define DEBUG_PRINT(...)
#endif

#ifdef DEBUG_MEM
#define DCP_DEBUG_MEM(...) fprintf(stderr, __VA_ARGS__)
#else
#define DCP_DEBUG_MEM(...)
#endif

enum {
#ifndef DLA_MMD                    // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
  AOCL_IRQ_POLLING_BASE = 0x0100,  // CSR to polling interrupt status
  AOCL_IRQ_MASKING_BASE = 0x0108,  // CSR to set/unset interrupt mask
  AOCL_MMD_KERNEL = 0x4000,        /* Control interface into kernel interface */
#else
  AOCL_MMD_KERNEL = 0,  // CoreDLA completely removes the Opencl kernel interface, repurposed for CSRs
#endif
  AOCL_MMD_MEMORY = 0x100000 /* Data interface to device memory */
};

enum AfuStatu { CCIP_MMD_INVALID_ID = 0, CCIP_MMD_BSP, CCIP_MMD_AFU };

class CcipDevice final {
 public:
  CcipDevice(uint64_t);
  CcipDevice(const CcipDevice &) = delete;
  CcipDevice &operator=(const CcipDevice &) = delete;
  ~CcipDevice();

  static std::string get_board_name(std::string prefix, uint64_t obj_id);
  static bool parse_board_name(const char *board_name, uint64_t &obj_id);

  int get_mmd_handle() { return mmd_handle; }
  uint64_t get_fpga_obj_id() { return fpga_obj_id; }
  std::string get_dev_name() { return mmd_dev_name; }
  std::string get_bdf();
  float get_temperature();
  bool initialize_bsp();
  void set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void *user_data);
  void set_status_handler(aocl_mmd_status_handler_fn fn, void *user_data);
  int yield();
  void event_update_fn(aocl_mmd_op_t op, int status);
  bool bsp_loaded();

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

  // HACK: use the sysfs path to read temperature value and NUMA node
  // this should be replaced with OPAE call once that is
  // available
  std::string fme_sysfs_temp_path;
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
  bool bsp_initialized;
  bool mmio_is_mapped;

  fpga_handle afc_handle;
  fpga_properties filter;
  fpga_token afc_token;
  uint64_t dma_ch0_dfh_offset;
  uint64_t dma_ch1_dfh_offset;
  uint64_t dma_ase_dfh_offset;
  intel_opae_mmd::mmd_dma *dma_host_to_fpga;
  intel_opae_mmd::mmd_dma *dma_fpga_to_host;

  char *mmd_copy_buffer;

  // Helper functions
  fpga_result read_mmio(void *host_addr, size_t dev_addr, size_t size);
  fpga_result write_mmio(const void *host_addr, size_t dev_addr, size_t size);
};

#endif  // _CCIP_MMD_DEVICE_H

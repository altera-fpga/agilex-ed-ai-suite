#ifndef ACL_PCIE_CONFIG_H
#define ACL_PCIE_CONFIG_H

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

/* ===- acl_pcie_config.h  -------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file declares the class to handle functions that program the FPGA.         */
/* The actual implementation of the class lives in the acl_pcie_config.cpp,        */
/* so look there for full documentation.                                           */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

#ifdef DLA_MMD
#include <cstddef>  //size_t
#endif

// Forward declaration for classes used by ACL_PCIE_DEVICE
class ACL_PCIE_DMA;
class ACL_PCIE_DEVICE;
class ACL_PCIE_MM_IO_MGR;

#define PCIE_AER_CAPABILITY_ID ((DWORD)0x0001)
#define PCIE_AER_UNCORRECTABLE_STATUS_OFFSET ((DWORD)0x4)
#define PCIE_AER_UNCORRECTABLE_MASK_OFFSET ((DWORD)0x8)
#define PCIE_AER_CORRECTABLE_STATUS_OFFSET ((DWORD)0x10)
#define PCIE_AER_SURPRISE_DOWN_BIT ((DWORD)(1 << 5))

// The size of the char array that holds the name of autodetect JTAG cable and device index
#define AD_CABLE_SIZE 10

#if defined(LINUX)
typedef int fpga_handle;
#else
#include <opae/fpga.h>
#endif  // LINUX

class ACL_PCIE_CONFIG {
 public:
  ACL_PCIE_CONFIG(fpga_handle handle, ACL_PCIE_MM_IO_MGR *io, ACL_PCIE_DEVICE *pcie, ACL_PCIE_DMA *dma);
  ~ACL_PCIE_CONFIG();

  // Change the core only via PCIe, using an in-memory image of the core.rbf
  // This is supported only for Stratix V and newer devices.
  // Return 0 on success.
  int program_core_with_PR_file_a10(char *core_bitstream, size_t core_rbf_len);
  int program_core_with_PR_file_s10(char *core_bitstream, size_t core_rbf_len, char *pll_config_str);

  // Program the FPGA using a given SOF file
  // Input filename, autodetect cable, autodetect device index
  // Return 0 on success.
  int program_with_SOF_file(const char *filename, const char *ad_cable, const char *ad_device_index);

  // Look up CADEID using ISSP
  // Return TRUE with cable value in ad_cable, ad_device_index if cable found
  // Otherwise return FALSE
  bool find_cable_with_ISSP(unsigned int cade_id, char *ad_cable, char *ad_device_index);

  // Functions to save/load control registers from PCI Configuration Space
  // Return 0 on success.
  int save_pci_control_regs();
  int load_pci_control_regs();

  // Functions to query the PCI related information
  // Use NULL as input for the info that you don't care about
  // Return 0 on success.
  int query_pcie_info(unsigned int *pcie_gen, unsigned int *pcie_num_lanes, char *pcie_slot_info_str);

  // Windows-specific code to control AER, and retrain the link
  int enable_AER_and_retrain_link_windows(void);
  int disable_AER_windows(void);

  // Platform agnostic sleep (in seconds)
  void wait_seconds(unsigned seconds);

 private:
  ACL_PCIE_CONFIG &operator=(const ACL_PCIE_CONFIG &) { return *this; }

  ACL_PCIE_CONFIG(const ACL_PCIE_CONFIG &src) {}

  fpga_handle m_handle;
  ACL_PCIE_MM_IO_MGR *m_io;
  ACL_PCIE_DEVICE *m_pcie;
  ACL_PCIE_DMA *m_dma;
#if defined(WINDOWS)
  fpga_guid *FpgaCmd;
#endif  // WINDOWS
};

#endif  // ACL_PCIE_CONFIG_H

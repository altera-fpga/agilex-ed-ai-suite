// (c) 1992-2021 Intel Corporation.
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

/* ===- acl_pcie_config.cpp  ------------------------------------------ C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the class to handle functions that program the FPGA.       */
/* The declaration of the class lives in the acl_pcie_config.h.                    */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "acl_pcie_config.h"
#include "acl_pcie.h"

// other header files inside MMD driver
#include "acl_pcie_debug.h"
#if defined(WINDOWS)
#include "acl_pcie_dma_windows.h"
#endif  // WINDOWS

// other standard header files
#include <stdlib.h>
#include <string.h>
#include <iostream>
#include <sstream>
#if defined(WINDOWS)
#include <process.h>
#endif  // WINDOWS

#if defined(LINUX)
#include <unistd.h>
#endif  // LINUX

#if defined(WINDOWS)
#define FREEZE_STATUS_OFFSET 0
#define FREEZE_CTRL_OFFSET 4
#define FREEZE_VERSION_OFFSET 12
#define FREEZE_BRIDGE_SUPPORTED_VERSION 0xad000003

#define FREEZE_REQ 1
#define RESET_REQ 2
#define UNFREEZE_REQ 4

#define FREEZE_REQ_DONE 1
#define UNFREEZE_REQ_DONE 2

#define ALT_PR_DATA_OFST 0x00
#define ALT_PR_CSR_OFST 0x04
#define ALT_PR_VER_OFST 0x08

#define ALT_PR_CSR_PR_START 1
#define ALT_PR_CSR_STATUS_SFT 1
#define ALT_PR_CSR_STATUS_MSK (7 << ALT_PR_CSR_STATUS_SFT)
#define ALT_PR_CSR_STATUS_NRESET (0 << ALT_PR_CSR_STATUS_SFT)
#define ALT_PR_CSR_STATUS_BUSY (1 << ALT_PR_CSR_STATUS_SFT)
#define ALT_PR_CSR_STATUS_PR_IN_PROG (2 << ALT_PR_CSR_STATUS_SFT)
#define ALT_PR_CSR_STATUS_PR_SUCCESS (3 << ALT_PR_CSR_STATUS_SFT)
#define ALT_PR_CSR_STATUS_PR_ERR (4 << ALT_PR_CSR_STATUS_SFT)

#define ACL_DMA_PR_ALIGNMENT_BYTES 4096

#define PLL_OFFSET_VERSION_ID 0x000
#define PLL_OFFSET_ROM 0x400
#define PLL_OFFSET_RECONFIG_CTRL_S10 0x800
#define PLL_OFFSET_COUNTER 0x100
#define PLL_OFFSET_RESET 0x110
#define PLL_OFFSET_LOCK 0x120

#define PLL_M_HIGH_REG_S10 0x104
#define PLL_M_LOW_REG_S10 0x107
#define PLL_M_BYPASS_ENABLE_REG_S10 0x105
#define PLL_M_EVEN_DUTY_ENABLE_REG_S10 0x106

#define PLL_N_HIGH_REG_S10 0x100
#define PLL_N_LOW_REG_S10 0x102
#define PLL_N_BYPASS_ENABLE_REG_S10 0x101
#define PLL_N_EVEN_DUTY_ENABLE_REG_S10 0x101

#define PLL_C0_HIGH_REG_S10 0x11B
#define PLL_C0_LOW_REG_S10 0x11E
#define PLL_C0_BYPASS_ENABLE_REG_S10 0x11C
#define PLL_C0_EVEN_DUTY_ENABLE_REG_S10 0x11D

#define PLL_C1_HIGH_REG_S10 0x11F
#define PLL_C1_LOW_REG_S10 0x122
#define PLL_C1_BYPASS_ENABLE_REG_S10 0x120
#define PLL_C1_EVEN_DUTY_ENABLE_REG_S10 0x121

#define PLL_LF_REG_S10 0x10A

#define PLL_CP1_REG_S10 0x101
#define PLL_CP2_REG_S10 0x10D

#define PLL_REQUEST_CAL_REG_S10 0x149
#define PLL_ENABLE_CAL_REG_S10 0x14A
#endif  // WINDOWS

#ifndef DLA_MMD
#include "acl_check_sys_cmd.h"
#include "pkg_editor.h"
#endif

// MAX size of line read from pipe-ing the output of find_jtag_cable.tcl to MMD
#define READ_SIZE 1024
// MAX size of command passed to system for invoking find_jtag_cable.tcl from MMD
#define SYSTEM_CMD_SIZE 4 * 1024

// Function to install the signal handler for Ctrl-C
// Implemented inside acl_pcie.cpp
extern int install_ctrl_c_handler(int ingore_sig);

ACL_PCIE_CONFIG::ACL_PCIE_CONFIG(fpga_handle Handle, ACL_PCIE_MM_IO_MGR *io, ACL_PCIE_DEVICE *pcie, ACL_PCIE_DMA *dma) {
  m_handle = Handle;
  m_io = io;
  m_pcie = pcie;
  m_dma = dma;

#if defined(WINDOWS)
  fpga_result result = FPGA_OK;
  UINT32 NumCmds = 0;
  FpgaCmd = NULL;

  // Get the number of supported commands
  result = fpgaGetSupportedCommands(Handle, NULL, &NumCmds);
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return, "fpgaGetSupportedCommands failed in ACL_PCIE_CONFIG().\n");

  // Allocate memory for the guid array based on NumCmds
  FpgaCmd = (fpga_guid *)malloc(NumCmds * sizeof(fpga_guid));

  if (FpgaCmd == NULL) {
    throw std::bad_alloc();
  }

  ACL_PCIE_ERROR_IF(FpgaCmd == NULL, return, "malloc failed in ACL_PCIE_CONFIG().\n");

  // Populate the guid array
  result = fpgaGetSupportedCommands(Handle, FpgaCmd, &NumCmds);
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return, "fpgaGetSupportedCommands failed in ACL_PCIE_CONFIG().\n");
#endif  // WINDOWS

  return;
}

ACL_PCIE_CONFIG::~ACL_PCIE_CONFIG() {
#if defined(WINDOWS)
  // Free the guid array
  if (FpgaCmd) {
    free(FpgaCmd);
    FpgaCmd = NULL;
  }
#endif
}

// Change the kernel region using PR only via PCIe, using an in-memory image of the core.rbf
// For Linux, the actual implementation of PR is inside the kernel mode driver.
// Return 0 on success.
int ACL_PCIE_CONFIG::program_core_with_PR_file_a10(char *core_bitstream, size_t core_rbf_len) {
  int pr_result = 1;  // set to default - failure

  ACL_PCIE_ERROR_IF(core_bitstream == NULL, return 1, "core_bitstream is an NULL pointer.\n");
  ACL_PCIE_ERROR_IF(core_rbf_len < 1000000, return 1, "size of core rbf file is suspiciously small.\n");

#if defined(WINDOWS)
  int i;
  uint32_t version;
  UINT32 to_send, status;
  UINT32 *data;
  fpga_result result;

  /* Get version ID */
  result = fpgaReadMMIO32(m_handle, ACL_VERSIONID_BAR, ACL_VERSIONID_OFFSET, &version);
  ACL_PCIE_DEBUG_MSG(":: VERSION_ID is 0x%08X\n", (int)version);

  /* Check if PR is supported */
  if (version < (unsigned int)ACL_PR_PIO_VERSIONID) {
    ACL_PCIE_DEBUG_MSG(":: Currently programmed image does not support PR\n");
    pr_result = 1;
    return pr_result;
  }

  ACL_PCIE_DEBUG_MSG(":: OK to proceed with PR!\n");

  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + 4, &status);
  ACL_PCIE_DEBUG_MSG(":: Reading 0x%08X from PR IP status register\n", (int)status);
  ACL_PCIE_ASSERT(result == FPGA_OK, "fpgaReadMMIO32 failed.\n");

  to_send = 0x00000001;
  ACL_PCIE_DEBUG_MSG(":: Writing 0x%08X to PR IP status register\n", (int)to_send);
  result = fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + 4, to_send);
  ACL_PCIE_ASSERT(result == FPGA_OK, "fpgaWriteMMIO32 failed.\n");

  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + 4, &status);
  ACL_PCIE_ASSERT(result == FPGA_OK, "fpgaReadMMIO32 failed.\n");
  ACL_PCIE_DEBUG_MSG(":: Reading 0x%08X from PR IP status register\n", (int)status);

  if ((status != 0x10) && (status != 0x0)) {
    ACL_PCIE_ERROR_IF(1, return 1, ":: PR IP not in an usable state.\n");
  }

  data = (UINT32 *)core_bitstream;
  ACL_PCIE_DEBUG_MSG(":: Writing %d bytes of bitstream file to PR IP at BAR %d, OFFSET 0x%08X\n",
                     (int)core_rbf_len,
                     (int)ACL_PRCONTROLLER_BAR,
                     (int)ACL_PRCONTROLLER_OFFSET);
  for (i = 0; i < (int)core_rbf_len / 4; i++) {
    result = fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET, data[i]);
    ACL_PCIE_ASSERT(result == FPGA_OK, "fpgaWriteMMIO32 failed.\n");
  }

  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET, &status);
  ACL_PCIE_DEBUG_MSG(":: Reading 0x%08X from PR IP data register\n", (int)status);
  ACL_PCIE_ASSERT(result == FPGA_OK, "fpgaReadMMIO32 failed.\n");

  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + 4, &status);
  ACL_PCIE_DEBUG_MSG(":: Reading 0x%08X from PR IP status register\n", (int)status);
  ACL_PCIE_ASSERT(result == FPGA_OK, "fpgaReadMMIO32 failed.\n");

  if (status == 0x14) {
    ACL_PCIE_DEBUG_MSG(":: PR done!: 0x%08X\n", (int)status);
    pr_result = 0;
  } else {
    ACL_PCIE_DEBUG_MSG(":: PR error!: 0x%08X\n", (int)status);
    pr_result = 1;
  }

  ACL_PCIE_DEBUG_MSG(":: PR completed!\n");

#endif  // WINDOWS
#if defined(LINUX)
  struct acl_cmd cmd_pr = {ACLPCI_CMD_BAR, ACLPCI_CMD_DO_PR, NULL, NULL, 0, 0};

  cmd_pr.user_addr = core_bitstream;
  cmd_pr.size = core_rbf_len;

  pr_result = read(m_handle, &cmd_pr, sizeof(cmd_pr));

#endif  // LINUX

  return pr_result;
}

// Change the kernel region using PR only via PCIe, using an in-memory image of the core.rbf
// For Linux, the actual implementation of PR is inside the kernel mode driver.
// Return 0 on success.
int ACL_PCIE_CONFIG::program_core_with_PR_file_s10(char *core_bitstream, size_t core_rbf_len, char *pll_config_str) {
  int pr_result = 1;  // set to default - failure
#if defined(WINDOWS)
  uint32_t pll_config_array[8] = {0};
#else
  int pll_config_array[8] = {0};
#endif  // WINDOWS
  std::stringstream converter(pll_config_str);

  ACL_PCIE_ERROR_IF(core_bitstream == NULL, return 1, "core_bitstream is an NULL pointer.\n");
  ACL_PCIE_ERROR_IF(core_rbf_len < 1000000, return 1, "size of core rbf file is suspiciously small.\n");

  /* parse PLL string */
  converter >> pll_config_array[0] >> pll_config_array[1] >> pll_config_array[2] >> pll_config_array[3] >>
      pll_config_array[4] >> pll_config_array[5] >> pll_config_array[6] >> pll_config_array[7];
  if (converter.fail() == true) {
    ACL_PCIE_ERROR_IF(1, return 1, "PLL configuration string requires 8 integer elements\n");
  };

#if defined(WINDOWS)
  int i, j, k, result, count, chunk_num, frames;
  size_t offset;
  uint32_t to_send, status;
  uint32_t version;
  uint32_t *data;
  uint32_t pll_freq_khz, pll_m, pll_n, pll_c0, pll_c1, pll_lf, pll_cp, pll_rc;
  uint32_t pll_m_high, pll_m_low, pll_m_bypass_enable, pll_m_even_duty_enable;
  uint32_t pll_n_high, pll_n_low, pll_n_bypass_enable, pll_n_even_duty_enable;
  uint32_t pll_c0_high, pll_c0_low, pll_c0_bypass_enable, pll_c0_even_duty_enable;
  uint32_t pll_c1_high, pll_c1_low, pll_c1_bypass_enable, pll_c1_even_duty_enable;
  uint32_t pll_cp1, pll_cp2;
  uint32_t pll_byte;

  /* Get version ID */
  result = fpgaReadMMIO32(m_handle, ACL_VERSIONID_BAR, ACL_VERSIONID_OFFSET, &version);
  ACL_PCIE_DEBUG_MSG(":: VERSION_ID is 0x%08X\n", (int)version);

  /* Check if PR is supported */
  if (version < (unsigned int)ACL_PR_PIO_VERSIONID) {
    ACL_PCIE_DEBUG_MSG(":: Currently programmed image does not support PR\n");
    pr_result = 1;
    return pr_result;
  }

  ACL_PCIE_DEBUG_MSG(":: OK to proceed with PR!\n");

  /* freeze bridge */
  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_VERSION_OFFSET, &status);
  ACL_PCIE_DEBUG_MSG(":: Freeze bridge version is 0x%08X\n", (int)status);

  result = fpgaReadMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_STATUS_OFFSET, &status);
  ACL_PCIE_DEBUG_MSG(":: Freeze bridge status is 0x%08X\n", (int)status);

  ACL_PCIE_DEBUG_MSG(":: Asserting region freeze\n");
  fpgaWriteMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_CTRL_OFFSET, FREEZE_REQ);
  Sleep(1);

  result = fpgaReadMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_STATUS_OFFSET, &status);
  ACL_PCIE_DEBUG_MSG(":: Freeze bridge status is 0x%08X\n", (int)status);

  ACL_PCIE_DEBUG_MSG(":: PR Beginning\n");

  /* PR IP write initialisation */
  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_VER_OFST, &status);
  ACL_PCIE_DEBUG_MSG(":: ALT_PR_VER_OFST version is 0x%08X\n", (int)status);

  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, &status);
  ACL_PCIE_DEBUG_MSG(":: ALT_PR_CSR_OFST status is 0x%08X\n", (int)status);

  to_send = ALT_PR_CSR_PR_START;
  ACL_PCIE_DEBUG_MSG(":: Starting PR by writing 0x%08X to ALT_PR_CSR_OFST\n", (int)to_send);
  fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, to_send);

  /* Wait for PR to be in progress */
  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, &status);
  i = 0;
  while (status != ALT_PR_CSR_STATUS_PR_IN_PROG) {
    Sleep(1);
    i++;
    result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, &status);
  };
  ACL_PCIE_DEBUG_MSG(":: PR IP initialization took %d ms, ALT_PR_CSR_OFST status is 0x%08X\n", i, (int)status);

  // ---------------------------------------------------------------
  // Legacy PR using PIO
  // ---------------------------------------------------------------
  if ((version >= (unsigned int)ACL_PR_PIO_VERSIONID) && (version < (unsigned int)ACL_PR_DMA_VERSIONID)) {
    /* PR IP write bitstream */
    MemoryBarrier();
    data = (UINT32 *)core_bitstream;
    count = (int)core_rbf_len;
    ACL_PCIE_DEBUG_MSG(":: Size of PR RBF is 0x%08X\n", (int)count);

    /* Write out the complete 32-bit chunks */
    /* Wait for a designated amount of time between 4K chunks */
    i = 0;
    j = 0;
    chunk_num = 0;
    while (count >= 4) {
      fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_DATA_OFST, data[i]);
      i++;
      j++;
      count = count - 4;
      if (j >= 1024) {
        chunk_num++;
        j = 0;
        Sleep(1);
      }
    }
    ACL_PCIE_DEBUG_MSG(":: Number of 4K chunks written: %d\n", (int)chunk_num);
    ACL_PCIE_DEBUG_MSG(":: Number of bytes in PR bitstream remaining: %d\n", (int)count);

    /* Write out remaining non 32-bit chunks */
    to_send = data[i];
    switch (count) {
      case 3:
        to_send = to_send & 0x00ffffff;
        fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_DATA_OFST, to_send);
        break;
      case 2:
        to_send = to_send & 0x0000ffff;
        fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_DATA_OFST, to_send);
        break;
      case 1:
        to_send = to_send & 0x000000ff;
        fpgaWriteMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_DATA_OFST, to_send);
        break;
      case 0:
        break;
      default:
        /* This will never happen */
        return 1;
    }
  }

  // ---------------------------------------------------------------
  // PR using DMA
  // ---------------------------------------------------------------
  if (version >= (unsigned int)ACL_PR_DMA_VERSIONID) {
    /* PR IP write bitstream */
    MemoryBarrier();
    ACL_PCIE_DEBUG_MSG(":: Size of PR RBF is 0x%08X, initiating DMA transfer to PR IP\n", (int)core_rbf_len);

    /* Write PR bitstream using DMA */
    frames = (int)core_rbf_len / ACL_DMA_PR_ALIGNMENT_BYTES;
    ACL_PCIE_DEBUG_MSG(
        ":: PR bitstream will be sent in %d Byte frames, a total of %d frames\n", ACL_DMA_PR_ALIGNMENT_BYTES, frames);

    // sending in 4kB frames
    for (k = 0; k < frames; k++) {
      offset = (size_t)k * ACL_DMA_PR_ALIGNMENT_BYTES;
      void *host_addr_new = reinterpret_cast<void *>(core_bitstream + offset);
      size_t dev_addr_new = ACL_PCIE_PR_DMA_OFFSET;

      status = (uint32_t)m_dma->read_write(host_addr_new, dev_addr_new, ACL_DMA_PR_ALIGNMENT_BYTES, NULL, false);

      while (!m_dma->is_idle()) {
        ACL_PCIE_DEBUG_MSG(":: DMA still in progress...\n");
      }
    }
  }

  // Wait for PR complete
  MemoryBarrier();
  result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, &status);
  ACL_PCIE_DEBUG_MSG(":: ALT_PR_CSR_OFST status is 0x%08X\n", (int)status);
  i = 0;
  // wait till we get a PR_SUCCESS, or PR_ERROR, or a 1 second timeout
  while (status != ALT_PR_CSR_STATUS_PR_SUCCESS && status != ALT_PR_CSR_STATUS_PR_ERR && i < 100000) {
    Sleep(100);
    i++;
    result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, &status);
    ACL_PCIE_DEBUG_MSG(":: ALT_PR_CSR_OFST status is 0x%08X\n", (int)status);
  };

  if (status == ALT_PR_CSR_STATUS_PR_SUCCESS) {
    /* dynamically reconfigure IOPLL for kernel clock */
    /* read kernel clock generation version ID */
    result = fpgaReadMMIO32(
        m_handle, ACL_PCIE_KERNELPLL_RECONFIG_BAR, ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_VERSION_ID, &status);
    ACL_PCIE_DEBUG_MSG(":: Kernel clock generator version ID is 0x%08X\n", (int)status);

    /* extract PLL settings from PLL configuration array */
    pll_freq_khz = pll_config_array[0];
    pll_m = pll_config_array[1];
    pll_n = pll_config_array[2];
    pll_c0 = pll_config_array[3];
    pll_c1 = pll_config_array[4];
    pll_lf = pll_config_array[5];
    pll_cp = pll_config_array[6];
    pll_rc = pll_config_array[7];

    ACL_PCIE_DEBUG_MSG(":: PLL settings are %d %d %d %d %d %d %d %d\n",
                       pll_freq_khz,
                       pll_m,
                       pll_n,
                       pll_c0,
                       pll_c1,
                       pll_lf,
                       pll_cp,
                       pll_rc);

    // Measure kernel clock frequency
    fpgaWriteMMIO32(
        m_handle, ACL_PCIE_KERNELPLL_RECONFIG_BAR, ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_COUNTER, 0);
    Sleep(1000);
    result = fpgaReadMMIO32(
        m_handle, ACL_PCIE_KERNELPLL_RECONFIG_BAR, ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_COUNTER, &status);
    ACL_PCIE_DEBUG_MSG(":: Before reconfig, kernel clock set to %d Hz\n", (int)status);

    // extract all PLL parameters
    pll_m_high = (pll_m >> 8) & 0xFF;
    pll_m_low = pll_m & 0xFF;
    pll_m_bypass_enable = (pll_m >> 16) & 0x01;
    pll_m_even_duty_enable = (pll_m >> 17) & 0x01;

    pll_n_high = (pll_n >> 8) & 0xFF;
    pll_n_low = pll_n & 0xFF;
    pll_n_bypass_enable = (pll_n >> 16) & 0x01;
    pll_n_even_duty_enable = (pll_n >> 17) & 0x01;

    pll_c0_high = (pll_c0 >> 8) & 0xFF;
    pll_c0_low = pll_c0 & 0xFF;
    pll_c0_bypass_enable = (pll_c0 >> 16) & 0x01;
    pll_c0_even_duty_enable = (pll_c0 >> 17) & 0x01;

    pll_c1_high = (pll_c1 >> 8) & 0xFF;
    pll_c1_low = pll_c1 & 0xFF;
    pll_c1_bypass_enable = (pll_c1 >> 16) & 0x01;
    pll_c1_even_duty_enable = (pll_c1 >> 17) & 0x01;

    pll_lf = (pll_lf >> 6) & 0xFF;

    pll_cp = pll_cp & 0xFF;
    pll_cp1 = pll_cp & 0x07;
    pll_cp2 = (pll_cp >> 3) & 0x07;

    pll_rc = pll_rc & 0x03;

    /* read and write PLL settings */
    to_send = pll_m_high;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_M_HIGH_REG_S10,
                  &to_send,
                  1);
    to_send = pll_m_low;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_M_LOW_REG_S10,
                  &to_send,
                  1);
    to_send = pll_m_bypass_enable;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_M_BYPASS_ENABLE_REG_S10,
                  &to_send,
                  1);
    to_send = (pll_m_even_duty_enable << 7);
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_M_EVEN_DUTY_ENABLE_REG_S10,
                  &to_send,
                  1);

    to_send = pll_n_high;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_N_HIGH_REG_S10,
                  &to_send,
                  1);
    to_send = pll_n_low;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_N_LOW_REG_S10,
                  &to_send,
                  1);
    to_send = (pll_n_even_duty_enable << 7) | (pll_cp1 << 4) | pll_n_bypass_enable;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_N_BYPASS_ENABLE_REG_S10,
                  &to_send,
                  1);

    to_send = pll_c0_high;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C0_HIGH_REG_S10,
                  &to_send,
                  1);
    to_send = pll_c0_low;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C0_LOW_REG_S10,
                  &to_send,
                  1);
    to_send = pll_c0_bypass_enable;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C0_BYPASS_ENABLE_REG_S10,
                  &to_send,
                  1);
    to_send = (pll_c0_even_duty_enable << 7);
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C0_EVEN_DUTY_ENABLE_REG_S10,
                  &to_send,
                  1);

    to_send = pll_c1_high;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C1_HIGH_REG_S10,
                  &to_send,
                  1);
    to_send = pll_c1_low;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C1_LOW_REG_S10,
                  &to_send,
                  1);
    to_send = pll_c1_bypass_enable;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C1_BYPASS_ENABLE_REG_S10,
                  &to_send,
                  1);
    to_send = (pll_c1_even_duty_enable << 7);
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_C1_EVEN_DUTY_ENABLE_REG_S10,
                  &to_send,
                  1);

    to_send = (pll_cp2 << 5);
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_CP2_REG_S10,
                  &to_send,
                  1);

    to_send = (pll_lf << 3) | (pll_rc << 1);
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_LF_REG_S10,
                  &to_send,
                  1);

    // start PLL calibration
    /* read/modify/write the request calibration */
    ACL_PCIE_DEBUG_MSG(":: Requesting PLL calibration\n");
    result = fpgaReadMmio(m_handle,
                          ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                          ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_REQUEST_CAL_REG_S10,
                          &pll_byte,
                          1);
    to_send = pll_byte | 0x40;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_REQUEST_CAL_REG_S10,
                  &to_send,
                  1);
    /* write 0x03 to enable calibration interface */
    to_send = 0x03;
    fpgaWriteMmio(m_handle,
                  ACL_PCIE_KERNELPLL_RECONFIG_BAR,
                  ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_RECONFIG_CTRL_S10 + PLL_ENABLE_CAL_REG_S10,
                  &to_send,
                  1);
    ACL_PCIE_DEBUG_MSG(":: PLL calibration done\n");

    // Measure kernel clock frequency
    fpgaWriteMMIO32(
        m_handle, ACL_PCIE_KERNELPLL_RECONFIG_BAR, ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_COUNTER, 0);
    Sleep(1000);
    result = fpgaReadMMIO32(
        m_handle, ACL_PCIE_KERNELPLL_RECONFIG_BAR, ACL_PCIE_KERNELPLL_RECONFIG_OFFSET + PLL_OFFSET_COUNTER, &status);
    ACL_PCIE_DEBUG_MSG(":: After reconfig, kernel clock set to %d Hz\n", (int)status);

    /* assert reset */
    MemoryBarrier();
    ACL_PCIE_DEBUG_MSG(":: Asserting region reset\n");
    fpgaWriteMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_CTRL_OFFSET, RESET_REQ);
    Sleep(10);

    /* unfreeze bridge */
    MemoryBarrier();
    result =
        fpgaReadMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_VERSION_OFFSET, &status);
    ACL_PCIE_DEBUG_MSG(":: Freeze bridge version is 0x%08X\n", (int)status);

    result =
        fpgaReadMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_STATUS_OFFSET, &status);
    ACL_PCIE_DEBUG_MSG(":: Freeze bridge status is 0x%08X\n", (int)status);

    ACL_PCIE_DEBUG_MSG(":: Removing region freeze\n");
    fpgaWriteMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_CTRL_OFFSET, UNFREEZE_REQ);
    Sleep(1);

    ACL_PCIE_DEBUG_MSG(":: Checking freeze bridge status\n");
    result =
        fpgaReadMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_STATUS_OFFSET, &status);
    ACL_PCIE_DEBUG_MSG(":: Freeze bridge status is 0x%08X\n", (int)status);

    /* deassert reset */
    MemoryBarrier();
    ACL_PCIE_DEBUG_MSG(":: Deasserting region reset\n");
    fpgaWriteMMIO32(m_handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET + FREEZE_CTRL_OFFSET, 0);

    MemoryBarrier();
    result = fpgaReadMMIO32(m_handle, ACL_PRCONTROLLER_BAR, ACL_PRCONTROLLER_OFFSET + ALT_PR_CSR_OFST, &status);
    ACL_PCIE_DEBUG_MSG(":: Reading 0x%08X from PR IP status register\n", (int)status);
    if (status == 0x6) {
      ACL_PCIE_DEBUG_MSG(":: PR done! Status is 0x%08X\n", (int)status);
      pr_result = 0;
    } else {
      ACL_PCIE_DEBUG_MSG(":: PR error! Status is 0x%08X\n", (int)status);
      pr_result = 1;
    }
  } else {
    ACL_PCIE_DEBUG_MSG(":: PR error! Status is 0x%08X\n", (int)status);
    pr_result = 1;
  }

  ACL_PCIE_DEBUG_MSG(":: PR completed!\n");

#endif  // WINDOWS
#if defined(LINUX)
  struct acl_cmd cmd_pr = {ACLPCI_CMD_BAR, ACLPCI_CMD_DO_PR, NULL, NULL, 0, 0};

  cmd_pr.user_addr = core_bitstream;
  cmd_pr.size = core_rbf_len;
  cmd_pr.device_addr = pll_config_array;

  pr_result = read(m_handle, &cmd_pr, sizeof(cmd_pr));

#endif  // LINUX

  return pr_result;
}

// Windows specific code to disable PCIe advanced error reporting on the
// upstream port.
// No-op in Linux because save_pcie_control_regs() has already disabled
// AER on the upstream port.
// Returns 0 on success
int ACL_PCIE_CONFIG::disable_AER_windows(void) {
  fpga_result result = FPGA_OK;

#if defined(WINDOWS)
  // IOCTL call to disable AER in kernel mode
  result = fpgaProcessDeviceCmd(m_handle, GUID_TO_FPGA_GUID(GUID_PCI_OPENCL_DISABLE_AER), NULL, NULL, 0);
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return -1, "fpgaProcessDeviceCmd failed when disabling AER.\n");
#endif  // WINDOWS
  return result;
}

// Windows specific code to enable PCIe advanced error reporting on the
// upstream port.
// No-op in Linux because load_pcie_control_regs() has already enabled
// AER on the upstream port.
// Returns 0 on success
int ACL_PCIE_CONFIG::enable_AER_and_retrain_link_windows(void) {
  fpga_result result = FPGA_OK;

#if defined(WINDOWS)
  // IOCTL call to enable AER and retrain link in kernel mode
  result = fpgaProcessDeviceCmd(m_handle, GUID_TO_FPGA_GUID(GUID_PCI_OPENCL_ENABLE_AER_RETRAIN_LINK), NULL, NULL, 0);
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return -1, "fpgaProcessDeviceCmd failed when enabling AER.\n");
#endif  // WINDOWS
  return result;
}

// Program the FPGA using a given SOF file
// Quartus is needed for this, because,
//   quartus_pgm is used to program the board through USB blaster
// For Linux, when the kernel driver is asked to save/load_pcie_control_regs(),
//   it will also disable/enable the aer on the upstream, so no need to
//   implement those here.
// NOTE: This function only works with single device machines - if there
// are multiple cards (and multiple USB-blasters) in the system, it doesn't
// properly determine which card is which.  Only the first device will be
// programmed.
// Return 0 on success.
int ACL_PCIE_CONFIG::program_with_SOF_file(const char *filename, const char *ad_cable, const char *ad_device_index) {
  const int MAX_ATTEMPTS = 3;
  int program_failed = 1;
  int status;
  bool use_cable_autodetect = true;

  // If ad_cable value is "0", either JTAG cable autodetect failed or not
  // supported, then use the default value
  if (strcmp(ad_cable, "0") == 0) use_cable_autodetect = false;

  const char *cable = getenv("ACL_PCIE_JTAG_CABLE");
  if (!cable) {
    if (use_cable_autodetect) {
      cable = ad_cable;
      ACL_PCIE_DEBUG_MSG("setting Cable to autodetect value %s\n", cable);
    } else {
      cable = "1";
      ACL_PCIE_DEBUG_MSG("setting Cable to default value %s\n", cable);
    }
  }

  const char *device_index = getenv("ACL_PCIE_JTAG_DEVICE_INDEX");
  if (!device_index) {
    if (use_cable_autodetect) {
      device_index = ad_device_index;
      ACL_PCIE_DEBUG_MSG("setting Device Index to autodetect value %s\n", device_index);
    } else {
      device_index = "1";
      ACL_PCIE_DEBUG_MSG("setting Device Index to default value %s\n", device_index);
    }
  }

  char cmd[4 * 1024];
#ifdef DLA_MMD
#if defined(WINDOWS)
  if ((ACL_PCIE_DEBUG | 0) >= VERBOSITY_DEFAULT) {
    snprintf(cmd, sizeof(cmd), "quartus_pgm -c %s -m jtag -o \"P;%s@%s\"", cable, filename, device_index);
  } else {
    snprintf(cmd, sizeof(cmd), "quartus_pgm -c %s -m jtag -o \"P;%s@%s\" > nul 2>&1", cable, filename, device_index);
  }
#else
  snprintf(cmd, sizeof(cmd), "quartus_pgm -c %s -m jtag -o \"P;%s@%s\" 2>&1 >/dev/null", cable, filename, device_index);
#endif
  ACL_PCIE_INFO("Executing \"%s\"\n", cmd);
#else
#if defined(WINDOWS)
  snprintf(
      cmd, sizeof(cmd), "aocl do quartus_pgm -c %s -m jtag -o \"P;%s@%s\" > nul 2>&1", cable, filename, device_index);
#endif
#if defined(LINUX)
  snprintf(cmd,
           sizeof(cmd),
           "aocl do quartus_pgm -c %s -m jtag -o \"P;%s@%s\" 2>&1 >/dev/null",
           cable,
           filename,
           device_index);
#endif
  ACL_PCIE_DEBUG_MSG("Executing \"%s\"\n", cmd);
#endif

  // Disable AER
  status = disable_AER_windows();
  ACL_PCIE_ERROR_IF(status, return -1, "Failed to disable AER on Windows before programming SOF.\n");

  // Set the program to ignore the ctrl-c signal
  // This setting will be inherited by the system() function call below,
  // so that the quartus_pgm call won't be interrupt by the ctrl-c signal.
  install_ctrl_c_handler(1 /* ignore the signal */);

  // Program FPGA by executing the command
#ifndef DLA_MMD
  ACL_PCIE_ASSERT(system_cmd_is_valid(cmd), "Invalid system() function parameter: %s\n", cmd);
#endif
  for (int attempts = 0; attempts < MAX_ATTEMPTS && program_failed; attempts++) {
    if (attempts > 0) {
      ACL_PCIE_INFO("Execution failed.  Will try again in case the error was transient.\n");
    }
    program_failed = system(cmd);
#if defined(WINDOWS)
    Sleep(2000);
#endif  // WINDOWS
#if defined(LINUX)
    sleep(2);
#endif  // LINUX
  }

  // Restore the original custom ctrl-c signal handler
  install_ctrl_c_handler(0 /* use the custom signal handler */);

  // Enable AER
  status = enable_AER_and_retrain_link_windows();
  ACL_PCIE_ERROR_IF(status, return -1, "Failed to enable AER and retrain link on Windows after programming SOF.\n");

  return program_failed;
}

bool ACL_PCIE_CONFIG::find_cable_with_ISSP(unsigned int cade_id, char *ad_cable, char *ad_device_index) {
  FILE *fp;
  int status;
  char line_in[READ_SIZE];
  bool found_cable = false;

  char cmd[SYSTEM_CMD_SIZE];
  const char *aocl_boardpkg_root = getenv("AOCL_BOARD_PACKAGE_ROOT");
  if (!aocl_boardpkg_root) {
    ACL_PCIE_INFO("AOCL_BOARD_PACKAGE_ROOT not set!!!");
    return false;
  }

  snprintf(cmd, sizeof(cmd), "aocl do quartus_stp -t %s/scripts/find_jtag_cable.tcl %X", aocl_boardpkg_root, cade_id);
  ACL_PCIE_DEBUG_MSG("executing \"%s\"\n", cmd);

  // Open PIPE to tcl script
#ifndef DLA_MMD
  ACL_PCIE_ASSERT(system_cmd_is_valid(cmd), "Invalid popen() function parameter: %s\n", cmd);
#endif
#if defined(WINDOWS)
  fp = _popen(cmd, "r");
#endif  // WINDOWS
#if defined(LINUX)
  fp = popen(cmd, "r");
#endif  // LINUX

  if (fp == NULL) {
    ACL_PCIE_INFO("Couldn't open fp file\n");
  } else {
    // Read everyline and look for matching string from tcl script
    while (fgets(line_in, READ_SIZE, fp) != NULL) {
      ACL_PCIE_DEBUG_MSG("%s", line_in);
      const char str_match_cable[] = "Matched Cable:";
      const char str_match_dev_name[] = "Device Name:@";
      const char str_match_end[] = ":";
      // parsing the string and extracting the cable/index value
      // from the output of find_jtag_cable.tcl script
      char *pos_cable = strstr(line_in, str_match_cable);
      if (pos_cable) {
        found_cable = true;
        // find the sub-string locations in the line
        char *pos_dev_name = strstr(line_in, str_match_dev_name);
        if (pos_dev_name) {
          char *pos_end =
              strstr(pos_dev_name + strnlen(str_match_dev_name, sizeof(str_match_dev_name)), str_match_end);  // Find the last ":"
          if (pos_end) {
            // calculate the cable/index string size
            size_t i_cable_str_len = pos_dev_name - pos_cable - strnlen(str_match_cable, sizeof(str_match_cable));
            size_t i_dev_index_str_len = pos_end - pos_dev_name - strnlen(str_match_dev_name, sizeof(str_match_dev_name));
            // extract the cable/index value from the line
            snprintf(ad_cable,
                     AD_CABLE_SIZE,
                     "%.*s",
                     (int)i_cable_str_len,
                     pos_cable + strnlen(str_match_cable, sizeof(str_match_cable)));
            snprintf(ad_device_index,
                     AD_CABLE_SIZE,
                     "%.*s",
                     (int)i_dev_index_str_len,
                     pos_dev_name + strnlen(str_match_dev_name, sizeof(str_match_dev_name)));
            ACL_PCIE_DEBUG_MSG("JTAG Autodetect device found Cable:%s, Device Index:%s\n", ad_cable, ad_device_index);
            break;
          }
        }
      }
    }

#if defined(WINDOWS)
    status = _pclose(fp);
#endif  // WINDOWS
#if defined(LINUX)
    status = pclose(fp);
#endif  // LINUX

    if (status == -1) {
      /* Error reported by pclose() */
      ACL_PCIE_INFO("Couldn't close find_cable_with_ISSP file\n");
    } else {
      /* Use macros described under wait() to inspect `status' in order
       *        to determine success/failure of command executed by popen()
       *        */
    }
  }

  if (!found_cable) {
    ACL_PCIE_INFO("Autodetect Cable not found!!\n");
  }

  return found_cable;
}

// Functions to save/load control registers form PCI Configuration Space
// This saved registers are used to restore the PCIe link after reprogramming
// through methods other than PR
// For Windows, the register values are stored in this class, and do
//   nothing else
// For Linux, the register values are stored inside the kernel driver,
//   And, it will disable the interrupt and the aer on the upstream,
//   when the save_pci_control_regs() function is called. They will
//   be enable when load_pci_control_regs() is called.
// Return 0 on success
int ACL_PCIE_CONFIG::save_pci_control_regs() {
  int save_failed = 1;

#if defined(WINDOWS)
  fpga_result result = FPGA_OK;

  // IOCTL call to save PCI control register
  result = fpgaProcessDeviceCmd(m_handle, GUID_TO_FPGA_GUID(GUID_PCI_OPENCL_SAVE_PCI_CTRL_REG), NULL, NULL, 0);
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return -1, "fpgaProcessDeviceCmd failed when saving PCI Control registers.\n");

  save_failed = (result == FPGA_OK) ? (0) : (-1);
#endif  // WINDOWS
#if defined(LINUX)
  struct acl_cmd cmd_save = {ACLPCI_CMD_BAR, ACLPCI_CMD_SAVE_PCI_CONTROL_REGS, NULL, NULL, 0, 0};
  save_failed = read(m_handle, &cmd_save, 0);
#endif  // LINUX

  return save_failed;
}

int ACL_PCIE_CONFIG::load_pci_control_regs() {
  int load_failed = 1;
#if defined(WINDOWS)

  fpga_result result = FPGA_OK;
  // IOCTL call to load PCI control register
  result = fpgaProcessDeviceCmd(m_handle, GUID_TO_FPGA_GUID(GUID_PCI_OPENCL_LOAD_PCI_CTRL_REG), NULL, NULL, 0);
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return -1, "fpgaProcessDeviceCmd failed when loading PCI Control registers.\n");

  load_failed = (result == FPGA_OK) ? (0) : (-1);
#endif  // WINDOWS
#if defined(LINUX)
  struct acl_cmd cmd_load = {ACLPCI_CMD_BAR, ACLPCI_CMD_LOAD_PCI_CONTROL_REGS, NULL, NULL, 0, 0};
  load_failed = read(m_handle, &cmd_load, 0);
#endif  // LINUX

  return load_failed;
}

// Functions to query the PCI related information
// Use NULL as input for the info that you don't care about
// Return 0 on success.
int ACL_PCIE_CONFIG::query_pcie_info(unsigned int *pcie_gen, unsigned int *pcie_num_lanes, char *pcie_slot_info_str) {
  int status = 0;
#if defined(WINDOWS)
  fpga_result result = FPGA_OK;
  // IOCTL call to obtain PCIe gen information
  result = fpgaProcessDeviceCmd(
      m_handle, GUID_TO_FPGA_GUID(GUID_PCI_OPENCL_GET_PCI_GEN), NULL, pcie_gen, sizeof(unsigned int));
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return -1, "fpgaProcessDeviceCmd failed when finding PCI device gen info.\n");

  result = fpgaProcessDeviceCmd(
      m_handle, GUID_TO_FPGA_GUID(GUID_PCI_OPENCL_GET_PCI_LANES), NULL, pcie_num_lanes, sizeof(unsigned int));
  ACL_PCIE_ERROR_IF(result != FPGA_OK, return -1, "fpgaProcessDeviceCmd failed when finding PCI device lanes info.\n");

  status = (result == FPGA_OK) ? (0) : (-1);
#endif  // WINDOWS
#if defined(LINUX)
  struct acl_cmd driver_cmd;

  if (pcie_gen != NULL) {
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_GET_PCI_GEN;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = pcie_gen;
    driver_cmd.size = sizeof(*pcie_gen);
    status |= read(m_handle, &driver_cmd, sizeof(driver_cmd));
  }

  if (pcie_num_lanes != NULL) {
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_GET_PCI_NUM_LANES;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = pcie_num_lanes;
    driver_cmd.size = sizeof(*pcie_num_lanes);
    status |= read(m_handle, &driver_cmd, sizeof(driver_cmd));
  }

  if (pcie_slot_info_str != NULL) {
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_GET_PCI_SLOT_INFO;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = pcie_slot_info_str;
    driver_cmd.size = sizeof(pcie_slot_info_str);
    status |= read(m_handle, &driver_cmd, sizeof(driver_cmd));
  }
#endif  // LINUX
  return status;
}

void ACL_PCIE_CONFIG::wait_seconds(unsigned seconds) {
#if defined(WINDOWS)
  Sleep(seconds * 1000);
#endif  // WINDOWS

#if defined(LINUX)
  sleep(seconds);
#endif  // LINUX
}

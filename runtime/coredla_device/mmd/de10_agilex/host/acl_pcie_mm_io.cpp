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

/* ===- acl_pcie_mm_io.cpp  ------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the class to handle memory mapped IO over PCIe.            */
/* The declaration of the class lives in the acl_pcie_mm_io.h.                     */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "acl_pcie_mm_io.h"
#include "acl_pcie.h"

// other header files inside MMD driver
#include "acl_pcie_debug.h"

// other standard header files
#include <string.h>

#if defined(LINUX)
#include <unistd.h>  // template
#endif               // LINUX

ACL_PCIE_MM_IO_DEVICE::ACL_PCIE_MM_IO_DEVICE(
    fpga_handle handle, DWORD bar, KPTR device_offset, const char *name, bool diff_endian) {
  ACL_PCIE_ASSERT(handle != INVALID_HANDLE_VALUE, "passed in an invalid handle when creating mm_io object.\n");

#if defined(WINDOWS)
  strncpy_s(m_name, MAX_NAME_LENGTH - 1, name, (MAX_NAME_LENGTH - 1));
#else
  strncpy(m_name, name, (MAX_NAME_LENGTH - 1));
#endif
  m_name[(MAX_NAME_LENGTH - 1)] = '\0';

  m_handle = handle;
  m_bar = bar;
  m_offset = device_offset;
  m_diff_endian = diff_endian;

  ACL_PCIE_DEBUG_MSG(":: [%s] Init: Bar " DWORD_FMT_U ", Total offset 0x%zu, diff_endian is %d \n",
                     m_name,
                     m_bar,
                     (size_t)m_offset,
                     m_diff_endian ? 1 : 0);
}

ACL_PCIE_MM_IO_DEVICE::~ACL_PCIE_MM_IO_DEVICE() {}

#if defined(LINUX)
// Helper functions to implement all other read/write functions
template <typename T>
DWORD linux_read(fpga_handle device, DWORD bar, KPTR address, T *data) {
  struct acl_cmd driver_cmd;
  driver_cmd.bar_id = bar;
  driver_cmd.command = ACLPCI_CMD_DEFAULT;
  driver_cmd.device_addr = reinterpret_cast<void *>(address);
  driver_cmd.user_addr = data;
  driver_cmd.size = sizeof(*data);
  // function invoke linux_read will not write to global memory.
  // So is_diff_endian is always false
  driver_cmd.is_diff_endian = 0;

  return read(device, &driver_cmd, sizeof(driver_cmd));
}

template <typename T>
DWORD linux_write(fpga_handle device, DWORD bar, KPTR address, T data) {
  struct acl_cmd driver_cmd;
  driver_cmd.bar_id = bar;
  driver_cmd.command = ACLPCI_CMD_DEFAULT;
  driver_cmd.device_addr = reinterpret_cast<void *>(address);
  driver_cmd.user_addr = &data;
  driver_cmd.size = sizeof(data);
  // function invoke linux_write will not write to global memory.
  // So is_diff_endian is always false
  driver_cmd.is_diff_endian = 0;

  return write(device, &driver_cmd, sizeof(driver_cmd));
}
#endif  // LINUX

int ACL_PCIE_MM_IO_DEVICE::read8(size_t addr, UINT8 *data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  status = fpgaReadMmio(m_handle, m_bar, bar_addr, (PVOID)data, sizeof(UINT8));
#endif  // WINDOWS
#if defined(LINUX)
  status = linux_read(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Read 8 bits from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Read 8 bits (0x%x) from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             *data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::write8(size_t addr, UINT8 data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  status = fpgaWriteMmio(m_handle, m_bar, bar_addr, (PVOID)&data, sizeof(UINT8));
#endif  // WINDOWS
#if defined(LINUX)
  status = linux_write(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Writing 8 bits to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Wrote 8 bits (0x%x) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::read16(size_t addr, UINT16 *data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  status = fpgaReadMmio(m_handle, m_bar, bar_addr, (PVOID)data, sizeof(UINT16));
#endif  // WINDOWS
#if defined(LINUX)
  status = linux_read(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Read 16 bits from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Read 16 bits (0x%x) from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             *data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::write16(size_t addr, UINT16 data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  status = fpgaWriteMmio(m_handle, m_bar, bar_addr, (PVOID)&data, sizeof(UINT16));
#endif  // WINDOWS
#if defined(LINUX)
  status = linux_write(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Writing 16 bits to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Wrote 16 bits (0x%x) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::read32(size_t addr, UINT32 *data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  status = fpgaReadMMIO32(m_handle, m_bar, bar_addr, data);
#endif  // WINDOWS
#if defined(LINUX)
  status = linux_read(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Read 32 bits from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Read 32 bits (0x%x) from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             *data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::write32(size_t addr, UINT32 data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  status = fpgaWriteMMIO32(m_handle, m_bar, bar_addr, data);
#endif  // WINDOWS
#if defined(LINUX)
  status = linux_write(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Writing 32 bits to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Wrote 32 bits (0x%x) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::read64(size_t addr, UINT64 *data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  // Original code had a 32-bit Read
  status = fpgaReadMmio(m_handle, m_bar, bar_addr, data, 8);

#endif  // WINDOWS
#if defined(LINUX)
  status = linux_read(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Read 64 bits from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Read 64 bits (0x%llx) from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             *data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::write64(size_t addr, UINT64 data) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);
#if defined(WINDOWS)
  // Original code had a 32-bit Write
  status = fpgaWriteMmio(m_handle, m_bar, bar_addr, (void *)&data, 8);

#endif  // WINDOWS
#if defined(LINUX)
  status = linux_write(m_handle, m_bar, bar_addr, data);
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Writing 64 bits to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    bar_addr,
                    (size_t)bar_addr);
  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Wrote 64 bits (0x%llx) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                             m_name,
                             data,
                             addr,
                             (size_t)bar_addr);

  return 0;  // success
}

int ACL_PCIE_MM_IO_DEVICE::write_block(size_t addr, size_t size, void *src) {
  fpga_result status;
  KPTR bar_addr = convert_to_bar_addr(addr);

  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Writing block (" SIZE_FMT_U " bytes) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X
                             " with offset)\n",
                             m_name,
                             size,
                             addr,
                             (size_t)bar_addr);

#if defined(WINDOWS)
  DWORD FP_size = static_cast<DWORD>(size);
  size_t alignment_size = size % 4;
  DWORD FP_alignment_size = static_cast<DWORD>(alignment_size);
  // 32-bit MMIO Write
  status = fpgaWriteMmio(m_handle, m_bar, bar_addr, src, FP_size - FP_alignment_size);
  if (alignment_size) {
    void *alignment_addr = compute_address(src, size - alignment_size);
    KPTR alignment_bar_addr = bar_addr + size - alignment_size;
    status = fpgaWriteMmio(m_handle, m_bar, alignment_bar_addr, alignment_addr, FP_alignment_size);
  }

#endif  // WINDOWS
#if defined(LINUX)
  // Can't use templated linux_write here because *src doesn't give you the size to read.
  struct acl_cmd driver_cmd {};
  driver_cmd.bar_id = m_bar;
  driver_cmd.device_addr = reinterpret_cast<void *>(bar_addr);
  driver_cmd.user_addr = src;
  driver_cmd.size = size;
  // Notify the driver if the host and device's memory have different endianess.
  driver_cmd.is_diff_endian = m_diff_endian ? 1 : 0;
  status = write(m_handle, &driver_cmd, sizeof(driver_cmd));
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Writing block (" SIZE_FMT_U " bytes) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    size,
                    addr,
                    (size_t)bar_addr);
  return 0;  // success
}

inline void *ACL_PCIE_MM_IO_DEVICE::compute_address(void *base, uintptr_t offset) {
  uintptr_t p = reinterpret_cast<uintptr_t>(base);
  return reinterpret_cast<void *>(p + offset);
}

int ACL_PCIE_MM_IO_DEVICE::read_block(size_t addr, size_t size, void *dst) {
  DWORD status;
  KPTR bar_addr = convert_to_bar_addr(addr);

  ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_PCIE,
                             ":::::: [%s] Reading block (" SIZE_FMT_U " bytes) from 0x" SIZE_FMT_X " (0x" SIZE_FMT_X
                             " with offset)\n",
                             m_name,
                             size,
                             addr,
                             (size_t)bar_addr);

#if defined(WINDOWS)
  DWORD FP_size = static_cast<DWORD>(size);
  size_t alignment_size = size % 4;
  DWORD FP_alignment_size = static_cast<DWORD>(alignment_size);
  // 32-bit MMIO Read
  status = fpgaReadMmio(m_handle, m_bar, bar_addr, dst, FP_size - FP_alignment_size);
  if (alignment_size) {
    void *alignment_addr = compute_address(dst, size - alignment_size);
    KPTR alignment_bar_addr = bar_addr + size - alignment_size;
    status |= fpgaReadMmio(m_handle, m_bar, alignment_bar_addr, alignment_addr, FP_alignment_size);
  }

#endif  // WINDOWS
#if defined(LINUX)
  // Can't use templated linux_write here because *src doesn't give you the size to read.
  struct acl_cmd driver_cmd;
  driver_cmd.bar_id = m_bar;
  driver_cmd.device_addr = reinterpret_cast<void *>(bar_addr);
  driver_cmd.user_addr = dst;
  driver_cmd.size = size;
  // Notify the driver if the host and device's memory have different endianess.
  driver_cmd.is_diff_endian = m_diff_endian ? 1 : 0;
  status = read(m_handle, &driver_cmd, sizeof(driver_cmd));
#endif  // LINUX

  ACL_PCIE_ERROR_IF(status != FPGA_OK,
                    return -1,
                    "[%s] Reading block (" SIZE_FMT_U " bytes) to 0x" SIZE_FMT_X " (0x" SIZE_FMT_X " with offset)\n",
                    m_name,
                    size,
                    addr,
                    (size_t)bar_addr);
  return 0;  // success
}

ACL_PCIE_MM_IO_MGR::ACL_PCIE_MM_IO_MGR(fpga_handle handle)
    : mem(NULL),
      pcie_cra(NULL),
      window(NULL),
      version(NULL),
      pr_base_id(NULL),
      pr_region_ctrl(NULL),
      quartus_ver(NULL),
      cade_id(NULL),
      uniphy_status(NULL),
      uniphy_reset(NULL),
      kernel_if(NULL),
      pll(NULL),
      temp_sensor(NULL),
      hostch_ver(NULL) {
  ACL_PCIE_ASSERT(handle != INVALID_HANDLE_VALUE, "passed in an invalid device when creating mm_io_mgr.\n");

  // This is the PCIe's interface for directly accessing memory (which is
  // significantly slower than using DMA).  This view of memory is segmented
  // so that the size of this address space can be smaller than the amount of
  // physical device memory.  The window interface controls which region of
  // physical memory this interface currently maps to.
  // The last flag indicate if the device on both side of transferring have
  // different endianess.
#ifdef ACL_BIG_ENDIAN
  mem = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PCI_GLOBAL_MEM_BAR, (KPTR)ACL_PCIE_MEMWINDOW_BASE, "GLOBAL-MEM", true);
#else
  mem = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PCI_GLOBAL_MEM_BAR, (KPTR)ACL_PCIE_MEMWINDOW_BASE, "GLOBAL-MEM", false);
#endif

  // This is the CRA port of our PCIe controller.  Used for configuring
  // interrupts and things like that.
  pcie_cra = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PCI_CRA_BAR, ACL_PCI_CRA_OFFSET, "PCIE-CRA");

  // This interface sets the high order address bits for the PCIe's direct
  // memory accesses via "mem" (above).
  window = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PCIE_MEMWINDOW_BAR, ACL_PCIE_MEMWINDOW_CRA, "MEMWINDOW");

  // DMA interfaces
  dma = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PCIE_DMA_INTERNAL_BAR, ACL_PCIE_DMA_INTERNAL_CTR_BASE, "DMA-CTR");

  // Version ID check
  version = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_VERSIONID_OFFSET, "VERSION");

  // PR base ID check
  pr_base_id = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PRBASEID_BAR, ACL_PRBASEID_OFFSET, "PRBASEID");

  // PR region controller
  pr_region_ctrl = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PRREGIONFREEZE_BAR, ACL_PRREGIONFREEZE_OFFSET, "PRREGIONCTRL");

  // Quartus Version
  quartus_ver = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_QUARTUSVER_BAR, ACL_QUARTUSVER_OFFSET, "QUARTUS-VERSION");

  // Quartus Version
  hostch_ver = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_HOSTCH_VERSION_BAR, ACL_HOSTCH_VERSION_OFFSET, "HOSTCH-VERSION");

  // Cable auto detect ID
  cade_id = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_CADEID_BAR, ACL_CADEID_OFFSET, "CADEID");

  // Uniphy Status
  uniphy_status = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_UNIPHYSTATUS_BAR, ACL_UNIPHYSTATUS_OFFSET, "UNIPHYSTATUS");

  // Uniphy Reset
  uniphy_reset = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_UNIPHYRESET_BAR, ACL_UNIPHYRESET_OFFSET, "UNIPHYRESET");

  // Kernel interface
  // The DLA BSP eliminates the kernel interface present in the original PR Terasic BSP
  // We reuse the kernel_if object here to simplify the DLA-specific changes required
#ifdef DLA_MMD
  kernel_if = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_KERNEL_CSR_BAR, ACL_DLA_CSR_OFFSET, "KERNEL");
#else
  kernel_if = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_KERNEL_CSR_BAR, ACL_KERNEL_CSR_OFFSET, "KERNEL");
#endif // DLA_MMD

  // PLL interface
  pll = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_PCIE_KERNELPLL_RECONFIG_BAR, ACL_PCIE_KERNELPLL_RECONFIG_OFFSET, "PLL");

  // temperature sensor
#ifdef ACL_PCIE_HAS_TEMP_SENSOR
  temp_sensor = new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_TEMP_SENSOR_ADDRESS, "TEMP-SENSOR");
#endif
  
  // 12V input voltage.
  board_info_sensors[ACL_PCIE_POWER_IN_VOLT_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_POWER_IN_VOLT_SENSOR_ADDRESS, "POWER-IN-VOL-SENSOR");
  // Current of the 12V input.
  board_info_sensors[ACL_PCIE_POWER_IN_CURR_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_POWER_IN_CURR_SENSOR_ADDRESS, "POWER-IN-CURR-SENSOR");
  // Core voltage of the first power channel.
  board_info_sensors[ACL_PCIE_CORE_VOLT1_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_CORE_VOLT1_SENSOR_ADDRESS, "CORE-VOL1-SENSOR");
  // Current of the first power channel.
  board_info_sensors[ACL_PCIE_CORE_CURR1_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_CORE_CURR1_SENSOR_ADDRESS, "CORE-CURR1-SENSOR");
  // Core voltage of the second power channel.
  board_info_sensors[ACL_PCIE_CORE_VOLT2_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_CORE_VOLT2_SENSOR_ADDRESS, "CORE-VOL2-SENSOR");
  // Current of the second power channel.
  board_info_sensors[ACL_PCIE_CORE_CURR2_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_CORE_CURR2_SENSOR_ADDRESS, "CORE-CURR2-SENSOR");
  // Speed of the first fan.
  board_info_sensors[ACL_PCIE_FAN_SPEED1_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_FAN_SPEED1_SENSOR_ADDRESS, "FAN-SPEED1-SENSOR");
  // Speed of the second fan.
  board_info_sensors[ACL_PCIE_FAN_SPEED2_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_FAN_SPEED2_SENSOR_ADDRESS, "FAN-SPPED2-SENSOR");
  // Core FPGA temperature of the development board.
  board_info_sensors[ACL_PCIE_FPGA_TEMP_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_FPGA_TEMP_SENSOR_ADDRESS, "FPGA-TEMP-SENSOR");
  // First ambient temperature of the development board.
  board_info_sensors[ACL_PCIE_BOARD_TEMP1_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_BOARD_TEMP1_SENSOR_ADDRESS, "BOARD-TEMP1-SENSOR");
  // Second ambient temperature of the development board.
  board_info_sensors[ACL_PCIE_BOARD_TEMP2_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_BOARD_TEMP2_SENSOR_ADDRESS, "BOARD-TEMP2-SENSOR");
  // Temperature of the E-TILE transceiver in the FPGA.
  board_info_sensors[ACL_PCIE_ETILE_TEMP_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_ETILE_TEMP_SENSOR_ADDRESS, "ETILE-TEMP-SENSOR");
  // Temperature of the P-TILE transceiver in the FPGA.
  board_info_sensors[ACL_PCIE_PTILE_TEMP_SENSOR_ADDRESS] =
      new ACL_PCIE_MM_IO_DEVICE(handle, ACL_VERSIONID_BAR, ACL_PCIE_PTILE_TEMP_SENSOR_ADDRESS, "PTILE-TEMP-SENSOR");
}

ACL_PCIE_MM_IO_MGR::~ACL_PCIE_MM_IO_MGR() {
  if (mem) {
    delete mem;
    mem = NULL;
  }
  if (pcie_cra) {
    delete pcie_cra;
    pcie_cra = NULL;
  }
  if (window) {
    delete window;
    window = NULL;
  }
  if (version) {
    delete version;
    version = NULL;
  }
  if (pr_base_id) {
    delete pr_base_id;
    pr_base_id = NULL;
  }
  if (pr_region_ctrl) {
    delete pr_region_ctrl;
    pr_region_ctrl = NULL;
  }
  if (quartus_ver) {
    delete quartus_ver;
    quartus_ver = NULL;
  }
  if (cade_id) {
    delete cade_id;
    cade_id = NULL;
  }
  if (uniphy_status) {
    delete uniphy_status;
    uniphy_status = NULL;
  }
  if (uniphy_reset) {
    delete uniphy_reset;
    uniphy_reset = NULL;
  }
  if (kernel_if) {
    delete kernel_if;
    kernel_if = NULL;
  }
  if (pll) {
    delete pll;
    pll = NULL;
  }
  if (temp_sensor) {
    delete temp_sensor;
    temp_sensor = NULL;
  }
  if (hostch_ver) {
    delete hostch_ver;
    hostch_ver = NULL;
  }
  if (dma) {
    delete dma;
    dma = NULL;
  }
  // Clean up terasic board information sensor map.
  for (auto &sensor : board_info_sensors) {
    auto *handle = sensor.second;
    if (handle) {
      delete handle;
    }
  }
}

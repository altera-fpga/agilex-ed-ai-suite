#ifndef ACL_PCIE_H
#define ACL_PCIE_H

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

/* ===- acl_pcie.h  --------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file defines macros and types that are used inside the MMD driver          */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

#ifndef ACL_PCIE_EXPORT
#define ACL_PCIE_EXPORT __declspec(dllimport)
#endif

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#ifdef DLA_MMD
#include <cstdint>
#else
#include <CL/cl_platform.h>
#endif
#include "aocl_mmd.h"
#include "hw_pcie_constants.h"

#define MMD_VERSION AOCL_MMD_VERSION_STRING

#ifdef DLA_MMD
#include "version.h"
#else
#include <version.h>
#endif

#define KERNEL_DRIVER_VERSION_EXPECTED ACL_DRIVER_VERSION

#if defined(_WIN32) || defined(_WIN64)
// Need DWORD, UINT32, etc.
// But windows.h spits out a lot of spurious warnings.
#pragma warning(push)
#pragma warning(disable : 4668)
#include <windows.h>
#pragma warning(pop)

// OPAE header files
#include <initguid.h>
#include <opae/fpga.h>
#include "fpga_cmd_guids.h"

#define INVALID_DEVICE (NULL)

// define for the format string for DWORD type
#define DWORD_FMT_U "%lu"
#define DWORD_FMT_X "%lx"
#define DWORD_FMT_4X "%04lX"

// define for the format string for size_t type
#ifdef _WIN64
#define SIZE_FMT_U "%zu"
#define SIZE_FMT_X "%zx"
#else
#define SIZE_FMT_U "%Iu"
#define SIZE_FMT_X "%Ix"
#endif

typedef ULONG64 KPTR;
typedef UINT64 DMA_ADDR;
#endif  // WINDOWS

#if defined(LINUX)
typedef uintptr_t KPTR;
typedef int fpga_handle;
typedef unsigned int fpga_result;
#define FPGA_OK 0

typedef unsigned int DWORD;
typedef unsigned long long QWORD;
typedef char INT8;
typedef unsigned char UINT8;
typedef int16_t INT16;
typedef uint16_t UINT16;
typedef int INT32;
typedef unsigned int UINT32;
typedef long long INT64;
typedef unsigned long long UINT64;

#define INVALID_HANDLE_VALUE ((int)(-1))

// Linux driver-specific exports
#include "pcie_linux_driver_exports.h"

#define INVALID_DEVICE (-1)
#define WD_STATUS_SUCCESS 0

// define for the format string for DWORD type
#define DWORD_FMT_U "%u"
#define DWORD_FMT_X "%x"
#define DWORD_FMT_4X "%04X"

// define for the format string for size_t type
#define SIZE_FMT_U "%zu"
#define SIZE_FMT_X "%zx"

#endif  // LINUX

#define MAX_NAME_SIZE (1204)

typedef enum {
  AOCL_MMD_KERNEL = ACL_MMD_KERNEL_HANDLE,  // Control interface into kernel interface
  AOCL_MMD_MEMORY = ACL_MMD_MEMORY_HANDLE,  // Data interface to device memory
  AOCL_MMD_PLL = ACL_MMD_PLL_HANDLE,        // Interface for reconfigurable PLL
  AOCL_MMD_HOSTCH = ACL_MMD_HOSTCH_HANDLE
} aocl_mmd_interface_t;

// Describes the properties of key components in a standard ACL device
#define PCIE_INFO_STR_LEN 1024
#define PCIE_SLOT_INFO_STR_LEN 128

struct ACL_PCIE_DEVICE_DESCRIPTION {
  DWORD vendor_id;
  DWORD device_id;
  char pcie_slot_info_str[PCIE_SLOT_INFO_STR_LEN];
  char pcie_info_str[PCIE_INFO_STR_LEN];
  bool interrupt_valid;
  UINT32 interrupt_data;
  UINT64 interrupt_addr;
};

typedef int acl_sensor_addr_t;

#define ACL_PCIE_ASSERT(COND, ...)                        \
  do {                                                    \
    if (!(COND)) {                                        \
      printf("\nMMD FATAL: %s:%d: ", __FILE__, __LINE__); \
      printf(__VA_ARGS__);                                \
      fflush(stdout);                                     \
      assert(0);                                          \
    }                                                     \
  } while (0)

#define ACL_PCIE_ERROR_IF(COND, NEXT, ...) \
  do {                                     \
    if (COND) {                            \
      printf("\nMMD ERROR: " __VA_ARGS__); \
      fflush(stdout);                      \
      NEXT;                                \
    }                                      \
  } while (0)

#define ACL_PCIE_INFO(...)             \
  do {                                 \
    printf("MMD INFO : " __VA_ARGS__); \
    fflush(stdout);                    \
  } while (0)

// Define the flag of program
#define ACL_PCIE_PROGRAM_PR 1
#define ACL_PCIE_PROGRAM_JTAG 0

#endif  // ACL_PCIE_H

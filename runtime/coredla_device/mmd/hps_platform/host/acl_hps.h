#ifndef ACL_HPS_H
#define ACL_HPS_H

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

/* ===- acl_hps.h  --------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) HPS MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file defines macros and types that are used inside the MMD driver          */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

#ifndef ACL_HPS_EXPORT
#define ACL_HPS_EXPORT __declspec(dllimport)
#endif

#define MMD_VERSION AOCL_MMD_VERSION_STRING

#include <assert.h>
#include <stddef.h>
#include <stdio.h>
#ifdef DLA_MMD
#include <cstdint>
#endif
#include "aocl_mmd.h"

#include "hps_types.h"

#if defined(WINDOWS)
#error Currently not available for windows
#endif

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

#define HPS_ASSERT(COND, ...)                        \
  do {                                                    \
    if (!(COND)) {                                        \
      printf("\nMMD FATAL: %s:%d: ", __FILE__, __LINE__); \
      printf(__VA_ARGS__);                                \
      fflush(stdout);                                     \
      assert(0);                                          \
    }                                                     \
  } while (0)

#define HPS_ERROR_IF(COND, NEXT, ...) \
  do {                                     \
    if (COND) {                            \
      printf("\nMMD ERROR: " __VA_ARGS__); \
      fflush(stdout);                      \
      NEXT;                                \
    }                                      \
  } while (0)

#define HPS_INFO(...)             \
  do {                                 \
    printf("MMD INFO : " __VA_ARGS__); \
    fflush(stdout);                    \
  } while (0)

#endif  // ACL_HPS_H

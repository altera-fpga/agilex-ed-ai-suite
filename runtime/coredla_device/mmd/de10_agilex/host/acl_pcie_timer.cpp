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

/* ===- acl_pcie_timer.cpp  ------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the class to query the host's system timer.                */
/* The declaration of the class lives in the acl_pcie_timer.h                      */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "acl_pcie_timer.h"
#include "acl_pcie.h"

// other standard header files
#include <fstream>

ACL_PCIE_TIMER::ACL_PCIE_TIMER() : m_ticks_per_second(0) {
#if defined(WINDOWS)
  // Cache the performance counter frequency
  LARGE_INTEGER li;
  QueryPerformanceFrequency(&li);
  m_ticks_per_second = li.QuadPart;

  ACL_PCIE_ASSERT(m_ticks_per_second != 0, "m_ticks_per_second == 0!\n");
#endif  // WINDOWS
}

ACL_PCIE_TIMER::~ACL_PCIE_TIMER() {}

cl_ulong ACL_PCIE_TIMER::get_time_ns() {
#if defined(WINDOWS)
  const INT64 NS_PER_S = 1000000000;
  LARGE_INTEGER li;

  QueryPerformanceCounter(&li);
  INT64 ticks = li.QuadPart;
  double seconds = ticks / (double)m_ticks_per_second;

  return static_cast<cl_ulong>(seconds * NS_PER_S + 0.5);
#endif  // WINDOWS
#if defined(LINUX)
  struct timespec a;
  const cl_ulong NS_PER_S = 1000000000;
  clock_gettime(CLOCK_REALTIME, &a);

  return static_cast<cl_ulong>(a.tv_nsec) + static_cast<cl_ulong>(a.tv_sec * NS_PER_S);
#endif  // LINUX
}

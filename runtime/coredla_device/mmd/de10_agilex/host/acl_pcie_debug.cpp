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

/* ===- acl_pcie_debug.cpp  ------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

#include "acl_pcie_debug.h"
#include <stdio.h>
#include <stdlib.h>

int ACL_PCIE_DEBUG = 0;
int ACL_PCIE_WARNING = 1;  // turn on the warning message by default

int ACL_PCIE_DEBUG_FLASH_DUMP_BOOT_SECTOR = 0;

void set_mmd_debug() {
  char* mmd_debug_var = getenv("ACL_PCIE_DEBUG");
  if (mmd_debug_var) {
    char* endptr = NULL;
    long parsed_count;
    parsed_count = strtol(mmd_debug_var, &endptr, 10);
    if (endptr == mmd_debug_var  // no valid characters
        || *endptr               // an invalid character
        || (parsed_count < 0 || parsed_count >= (long)VERBOSITY_EVERYTHING)) {
      // malformed string, do nothing
    } else {
      ACL_PCIE_DEBUG = (int)parsed_count;
      printf("\n:: MMD DEBUG LEVEL set to %d\n", ACL_PCIE_DEBUG);
    }
  }

  char* hal_debug_dump_flash_bootsect = getenv("ACL_PCIE_DEBUG_FLASH_DUMP_BOOT_SECTOR");
  if (hal_debug_dump_flash_bootsect) ACL_PCIE_DEBUG_FLASH_DUMP_BOOT_SECTOR = atoi(hal_debug_dump_flash_bootsect);
}

void set_mmd_warn_msg() {
  char* mmd_warn_var = getenv("ACL_PCIE_WARNING");
  if (mmd_warn_var) {
    ACL_PCIE_WARNING = atoi(mmd_warn_var);
  }
}

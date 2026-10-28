#ifndef HPS_TYPES_H_
#define HPS_TYPES_H_

/* (c) 1992-2021 Intel Corporation.                                                */
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

/* ===- hps_types.h  -------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Useful HPS Types                                        */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file contains useful type definition                                       */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
#include <vector>
#include <string>

#define SUCCESS (0)
#define FAILURE (1)

typedef std::vector<std::string> board_names;

typedef enum {
  HPS_MMD_COREDLA_CSR_HANDLE = 1, // COREDLA CSR Interface
  HPS_MMD_MEMORY_HANDLE = 2,      // Device Memory transfers
  HPS_MMD_STREAM_CONTROLLER_HANDLE = 3   // Stream Controller Interface
} hps_mmd_interface_t;

#endif // HPS_TYPES_H_

// Copyright 2021-2023 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// The purpose of this utility is to full-chip program an FPGA using JTAG.
// Avoid calling quartus_pgm directly since programming an FPGA means the PCIe
// device disappears from the CPU's perspective, first need to mask the surprise
// down error. The newly added function aocl_mmd_program_sof is basically the
// same as the existing one from the mmd but without trying to handshake with
// some registers that no longer exist in the CoreDLA version of the DE10
// Agilex BSP.

#include <stdlib.h>
#include <fstream>  // ifstream
#include <iostream>
#include <stdexcept>  // std::runtime_error
#include <string>     // std::string
#include "aocl_mmd.h"

// helper functions
bool file_exists(std::string filename) {
  std::ifstream f(filename.c_str());
  return f.good();
}

bool string_ends_with(std::string str, std::string suffix) {
  return str.size() >= suffix.size() && 0 == str.compare(str.size() - suffix.size(), suffix.size(), suffix);
}

// wrapper around mmd functions to reprogram the fpga
int reprogram(std::string sof_filename) {
  // open the mmd
  constexpr size_t MAX_BOARD_NAMES_LEN = 4096;
  char name[MAX_BOARD_NAMES_LEN];
  size_t sz;
  int status = aocl_mmd_get_offline_info(AOCL_MMD_BOARD_NAMES, MAX_BOARD_NAMES_LEN, name, &sz);
  if (status) {
    std::string msg = "Failed to query a board name from MMD. Perhaps no FPGA device is available?";
    throw std::runtime_error(msg);
  }
  int handle = aocl_mmd_open(name);
  if (handle < 0) {
    std::string msg = "Failed to open MMD";
    throw std::runtime_error(msg);
  }

  char *COREDLA_JTAG_PID = getenv("COREDLA_JTAG_PID");
  bool skipSaveRestore = false;
  if (COREDLA_JTAG_PID) {
    skipSaveRestore = true;
  }

  // reprogram the fpga using a sof file
  // BEWARE this invalidates the handle from the MMD
  status = aocl_mmd_program_sof(handle, sof_filename.c_str(), skipSaveRestore);
  if (status) {
    std::string msg = "Failed to reprogram the FPGA";
    throw std::runtime_error(msg);
  }

  return aocl_mmd_close(handle);
}

int main(int argc, char **argv) {
  try {
    // use the first command line arg as the sof filename
    if (argc != 2) {
      std::string msg = "usage: fpga_jtag_reprogram </path/to/sof/filename.sof>";
      throw std::runtime_error(msg);
    }

    // check that file exists
    std::string sof_filename = argv[1];
    if (!file_exists(sof_filename)) {
      std::string msg = "Error: cannot open file " + sof_filename;
      throw std::runtime_error(msg);
    }

    // check that file name ends in .sof
    if (!string_ends_with(sof_filename, ".sof")) {
      std::string msg = "Error: file name does not end with .sof";
      throw std::runtime_error(msg);
    }

    // reprogram the fpga using jtag
    int exitcode = reprogram(argv[1]);
    return exitcode;
  } catch (std::runtime_error &e) {
    std::cerr << e.what() << std::endl;
    return -1;
  }
}

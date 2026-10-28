// Copyright 2026 Altera Corporation.
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

#include "fpga.h"

#include <cstdlib>
#include <fstream>
#include <iostream>
#include <stdexcept>
#include <string>

namespace {

// Polling a status register from C++ would cost one System Console round trip per
// attempt. Doing the retry loop inside Tcl keeps it to one round trip per wait.
const char kTclFunctions[] = R"tcl(
proc poll_register {master_path register_addr register_val_assert timeout_count} {
  set register_val 0
  while {$timeout_count > 0} {
    set register_val [master_read_32 $master_path $register_addr 1]
    if {$register_val == $register_val_assert} {
      break
    }
    set timeout_count [expr {$timeout_count - 1}]
    after 10
  }
  return $register_val
}
)tcl";

// One session per process, so the C ABI needs no handle
JtagSession* g_session = nullptr;

}  // namespace

JtagSession::JtagSession(const std::string& jtag_glob)
    : SystemConsoleWrapper(), jtag_glob_(jtag_glob) {
  // Write `kTclFunctions` into a .tcl file and source it from the system-console process.
  // This is the same flow as the streaming mmd
  auto tcl_path = temp_dir().append("spatial_jtag_functions.tcl");
  std::ofstream tcl_file(tcl_path.string());
  if (!tcl_file) {
    throw std::runtime_error(
        "failed to open temporary file for writing system-console functions");
  }
  tcl_file << kTclFunctions << std::endl;
  tcl_file.close();
  send_command("source", tcl_path.string());

  master_path_ = claim_service("master", jtag_glob_, "\"\"");
}

JtagSession::~JtagSession() {
  try {
    send_command("close_service master", master_path_);
    if (!claimed_issp_.empty()) {
      send_command("close_service issp", claimed_issp_);
    }
  } catch (const std::exception& e) {
    std::cerr << "Warning: failed to close JTAG services: " << e.what() << std::endl;
  }
}

void JtagSession::assert_reset() {
  if (claimed_issp_.empty()) {
    claimed_issp_ = claim_service("issp", jtag_glob_, " mylib");
  }
  // The source drives the design's active low global reset
  send_command("issp_write_source_data", claimed_issp_, "0x0");
  send_command("issp_write_source_data", claimed_issp_, "0x1");
}

uint32_t JtagSession::poll_register(uint32_t address, uint32_t expected,
                                    unsigned timeout_count) {
  // poll_register is sourced in the system console process on construction
  auto result = send_command("poll_register", master_path_, address, expected,
                             timeout_count);
  return static_cast<uint32_t>(
      std::stoul(remove_non_alphanumeric(result), nullptr, 16));
}

JtagSession* spatial_jtag_session() { return g_session; }

int connect_to_fpga(void) {
  if (g_session != nullptr) {
    std::cerr << "connect_to_fpga: session already open" << std::endl;
    return -1;
  }

  const char* glob = std::getenv("SPATIAL_JTAG_PATH");
  const std::string jtag_glob = (glob != nullptr && *glob != '\0') ? glob : "*";

  try {
    g_session = new JtagSession(jtag_glob);
  } catch (const std::exception& e) {
    std::cerr << "connect_to_fpga: " << e.what() << std::endl;
    g_session = nullptr;
    return -1;
  }
  return 0;
}

int disconnect_fpga(void) {
  if (g_session == nullptr) {
    return 0;
  }
  delete g_session;
  g_session = nullptr;
  return 0;
}

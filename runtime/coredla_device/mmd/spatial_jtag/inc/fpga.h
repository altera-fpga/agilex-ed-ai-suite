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

#ifndef SPATIAL_JTAG_FPGA_H
#define SPATIAL_JTAG_FPGA_H

#include "system_console_wrapper.h"

#include <cstdint>
#include <string>

/**
 * Opens the process-wide JTAG session, claiming the first Avalon master whose
 * service path matches the glob in $SPATIAL_JTAG_PATH, or every path when that
 * is unset. Only one device per process is supported.
 *
 * @return 0 on success, non-zero on failure.
 */
int connect_to_fpga();

/**
 * Closes the session opened by connect_to_fpga()
 *
 * @return 0 on success, non-zero on failure.
 */
int disconnect_fpga();

// Board is controlled through system console via. JTAG. The premise is same
// as the streaming mmd: spawn a process running system console and pipe
// commands into it
class JtagSession : public SystemConsoleWrapper {
 public:
  // Claims the Avalon master matching `jtag_glob` and sources the polling
  // helper into the system console process
  explicit JtagSession(const std::string& jtag_glob);
  ~JtagSession();

  std::string& master_path() { return master_path_; }

  // Pulse the active low global reset
  void assert_reset();

  // Spin on `address` until it reads `expected`, or until `timeout_count` run out.
  uint32_t poll_register(uint32_t address, uint32_t expected, unsigned timeout_count);

 private:
  std::string jtag_glob_;
  std::string master_path_;
  std::string claimed_issp_;
};

// The open session, or nullptr before connect_to_fpga() has succeeded
JtagSession* spatial_jtag_session();

#endif  // SPATIAL_JTAG_FPGA_H

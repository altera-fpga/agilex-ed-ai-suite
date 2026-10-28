// (c) 1992-2024 Intel Corporation.
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

#ifndef MMD_HELPER_H
#define MMD_HELPER_H

#include <opae/fpga.h>
#include <stdarg.h>

inline void MMD_DEBUG(const char *format, ...) {
  if (std::getenv("MMD_ENABLE_DEBUG")) {
    va_list arglist;
    va_start(arglist, format);
    vprintf(format, arglist);
    va_end(arglist);
    fflush(stdout);
  }
}

namespace mmd_helper {

int read_mmio(fpga_handle mmio_handle, void *host_addr, size_t mmio_addr, size_t size);
int write_mmio(fpga_handle mmio_handle, const void *host_addr, size_t mmio_addr, size_t size);

};  // namespace mmd_helper

#endif  // MMD_HELPER_H

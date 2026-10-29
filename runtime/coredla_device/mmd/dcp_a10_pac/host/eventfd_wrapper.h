/* (C) 1992-2017 Intel Corporation.                             */
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

#ifndef _EVENTFD_WRAPPER_H
#define _EVENTFD_WRAPPER_H

#include <sys/eventfd.h>
#include <unistd.h>

namespace intel_opae_mmd {

// simple wrapper class for managing eventfd objects
class eventfd_wrapper final {
 public:
  eventfd_wrapper() {
    m_initialized = false;
    // Note: EFD_SEMAPHORE and EFD_NONBLOCK are not set
    // The implementation of functions using eventfd assumes that
    m_fd = eventfd(0, 0);
    if (m_fd < 0) {
      fprintf(stderr, "eventfd : %s", strerror(errno));
      return;
    }

    m_initialized = true;
  }

  ~eventfd_wrapper() {
    if (m_initialized) {
      if (close(m_fd) < 0) {
        fprintf(stderr, "eventfd : %s", strerror(errno));
      }
    }
  }

  bool notify(uint64_t count) {
    ssize_t res = write(m_fd, &count, sizeof(count));
    if (res < 0) {
      fprintf(stderr, "eventfd : %s", strerror(errno));
      return false;
    }
    return true;
  }

  int get_fd() { return m_fd; }
  bool initialized() { return m_initialized; }

 private:
  // not used and not implemented
  eventfd_wrapper(eventfd_wrapper& other);
  eventfd_wrapper& operator=(const eventfd_wrapper& other);

  // member varaibles
  int m_fd;
  int m_initialized;
};  // class eventfd_wrapper

};  // namespace intel_opae_mmd

#endif  // _EVENTFD_WRAPPER_H

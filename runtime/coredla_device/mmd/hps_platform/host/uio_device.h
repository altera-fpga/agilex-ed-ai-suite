#ifndef UIO_DEVICE_H_
#define UIO_DEVICE_H_

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

/* ===- uio_device.h  ------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         uio device access functions                             */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the functions used access the uio device objects           */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
#include <vector>
#include <string>
#include <string.h>
#include <memory>
#include <thread>
#include <mutex>
#include <sys/eventfd.h>
#include <unistd.h>

#include "aocl_mmd.h"
#include "hps_types.h"

// simple wrapper class for managing eventfd objects
class eventfd_object final {
 public:
  eventfd_object() {
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

  ~eventfd_object() {
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
  eventfd_object(eventfd_object& other);
  eventfd_object& operator=(const eventfd_object& other);

  // member varaibles
  int m_fd;
  int m_initialized;
};  // class eventfd_object
typedef std::shared_ptr<eventfd_object> eventfd_object_ptr;

#ifndef RUNTIME_POLLING
class uio_interrupt final {
  public:
    uio_interrupt(const int fd, const int mmd_handle);
    ~uio_interrupt();
    bool initialized() { return _pThread != nullptr; }; // If the thread is not created then must be invalid
    int set_interrupt_handler(aocl_mmd_interrupt_handler_fn fn, void* user_data);

  private:
    bool is_irq_available(); // Checks that the interrupt has been mapped into userspace
    bool enable_irq();  // Enables UIO Irq handling
    bool disable_irq(); // Disabled UIO Irq handling

    static void work_thread(uio_interrupt &obj);
    void run_thread(); // Function which handles waiting for interrupts

    uio_interrupt() = delete;
    uio_interrupt(uio_interrupt const&) = delete;
    void operator=(uio_interrupt const&) = delete;

    int get_mmd_handle() {return _mmd_handle; };

    std::thread *_pThread = {nullptr}; // Pointer to a thread object for waiting for interrupts
    int _device_fd = {-1}; // /dev/uio* device pointer
    int _mmd_handle = {-1}; // handle to the parent mmd_device
    eventfd_object_ptr _spShutdown_event = {nullptr}; // Shutdown thread event object

    aocl_mmd_interrupt_handler_fn _interrupt_fn = {nullptr};
    void                          *_interrupt_fn_user_data = {nullptr};
};
typedef std::shared_ptr<uio_interrupt> uio_interrupt_ptr;
#endif

class uio_device
{
public:
  uio_device(std::string &name, const int mmd_handle, const bool bEnableIrq=false);
  ~uio_device();

  uint32_t read(const uint32_t reg);
  void write(const uint32_t reg, const uint32_t value);

  int read_block(void *host_addr, size_t offset, size_t size);
  int write_block(const void *host_addr, size_t offset, size_t size);
  int set_interrupt_handler(aocl_mmd_interrupt_handler_fn fn, void* user_data);

  bool bValid();

private:
  bool map_region( std::string &name, const uint32_t index );
  void unmap_region();

  uio_device() = delete;
  uio_device(uio_device const&) = delete;
  void operator=(uio_device const &) = delete;

  int _mmd_handle; // Handle to the parent mmd device
  int _fd = {-1}; // File pointer to UIO - Used to indicate the the uio_device is valid
  uint64_t _size;   // Size of the mmapped region
  uint64_t _offset; // Offset of the first register
  uint8_t *_pBase; // Base of the mmapped region

  uint32_t *_pPtr; // The first register
#ifndef RUNTIME_POLLING
  bool _bIrqEnabled; // Indicates that we tried to create with IRQ
  uio_interrupt_ptr _spInterrupt; // Object to handle UIO Interrupts
#endif
};
typedef std::shared_ptr<uio_device> uio_device_ptr;

extern board_names uio_get_devices(const std::string name, const int max_devices);
extern std::string uio_get_device(const std::string prefix, const int32_t index);

#endif // UIO_DEVICE_H_

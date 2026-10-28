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

#include <poll.h>
#include <stdexcept>
#include <stdlib.h>
#include <thread>

#include "ccip_mmd_device.h"
#include "eventfd_wrapper.h"
#include "kernel_interrupt.h"

using namespace intel_opae_mmd;

// if ENABLE_OPENCL_KERNEL_INTERRUPTS is set at compile time, interrupts will
// be enabled.
#define ENABLE_OPENCL_KERNEL_INTERRUPTS

// if ENABLE_OPENCL_KERNEL_POLLING_THREAD is set at compile time, a thread will
// replace yield and the thread will call runtime call back

// DLA runtime assumes interrupt service routing will run on its own (instead of runtime yielding to MMD) when hardware
// interrupts
#ifdef DLA_MMD
#define ENABLE_OPENCL_KERNEL_POLLING_THREAD
#endif

// ccip interrupt line that is used for kernel
#define MMD_KERNEL_INTERRUPT_LINE_NUM 1

KernelInterrupt::KernelInterrupt(fpga_handle fpga_handle_arg, int mmd_handle)
    : m_initialized(false),
      m_eventfd_wrapper(NULL),
      m_thread(NULL),
      m_kernel_interrupt_fn(NULL),
      m_kernel_interrupt_user_data(NULL),
      m_fpga_handle(fpga_handle_arg),
      m_mmd_handle(mmd_handle),
      m_event_handle(0) {
  enable_interrupts();
}

KernelInterrupt::~KernelInterrupt() { disable_interrupts(); }

void KernelInterrupt::disable_interrupts() {
  // kill the thread
  if (m_thread) {
    // send message to thread to end it
    m_eventfd_wrapper->notify(1);

    // join with thread until it ends
    m_thread->join();

    delete m_thread;
    m_thread = NULL;
  }

  if (m_eventfd_wrapper) {
    delete m_eventfd_wrapper;
    m_eventfd_wrapper = NULL;
  }

  if (m_event_handle) {
    fpga_result res;
#ifdef ENABLE_OPENCL_KERNEL_INTERRUPTS
    res = fpgaUnregisterEvent(m_fpga_handle, FPGA_EVENT_INTERRUPT, m_event_handle);
    if (res != FPGA_OK) {
      fprintf(stderr, "error fpgaUnregisterEvent");
    }
#endif

    res = fpgaDestroyEventHandle(&m_event_handle);
    if (res != FPGA_OK) {
      fprintf(stderr, "error fpgaDestroyEventHandle");
    }
  }

  // disable opencl kernel interrupts
#ifndef DLA_MMD  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
  set_interrupt_mask(0x00000000);
#endif

  m_initialized = false;
}

void KernelInterrupt::enable_interrupts() {
  m_eventfd_wrapper = new eventfd_wrapper();
  if (!m_eventfd_wrapper->initialized()) return;

#ifdef ENABLE_OPENCL_KERNEL_POLLING_THREAD
  m_thread = new std::thread(interrupt_polling_thread, std::ref(*this));
#endif

  fpga_result res;
  // Create event
  res = fpgaCreateEventHandle(&m_event_handle);
  if (res != FPGA_OK) {
    fprintf(stderr, "error creating event handle");
    return;
  }

#ifdef ENABLE_OPENCL_KERNEL_INTERRUPTS
  // Register user interrupt with event handle
  res = fpgaRegisterEvent(m_fpga_handle, FPGA_EVENT_INTERRUPT, m_event_handle, MMD_KERNEL_INTERRUPT_LINE_NUM);
  if (res != FPGA_OK) {
    fprintf(stderr, "error registering event");
    res = fpgaDestroyEventHandle(&m_event_handle);
    return;
  }

  // enable opencl kernel interrupts
#ifndef DLA_MMD  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
  set_interrupt_mask(0x00000001);
#endif
#endif

  m_initialized = true;
}

#ifndef DLA_MMD  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)
void KernelInterrupt::set_interrupt_mask(uint32_t intr_mask) {
  fpga_result res;
  res = fpgaWriteMMIO32(m_fpga_handle, 0, AOCL_IRQ_MASKING_BASE, intr_mask);
  if (res != FPGA_OK) {
    fprintf(stderr, "Error fpgaWriteMMIO32: %d\n", res);
    return;
  }
}
#endif

void KernelInterrupt::interrupt_polling_thread(KernelInterrupt& obj) {
  bool thread_is_active = true;
  while (thread_is_active) {
#ifdef ENABLE_OPENCL_KERNEL_INTERRUPTS
    const int timeout = -1;
#else
    const int timeout = 0;
    usleep(100);
#endif
    thread_is_active = obj.poll_interrupt(timeout);
  }
}

bool KernelInterrupt::poll_interrupt(int poll_timeout_arg) {
  fpga_result fpga_res;

  int res;
  // get eventfd handles
  int intr_fd;
  fpga_res = fpgaGetOSObjectFromEventHandle(m_event_handle, &intr_fd);
  if (fpga_res != FPGA_OK) {
    fprintf(stderr, "error getting event file handle");
    return false;
  }
  int thread_signal_fd = m_eventfd_wrapper->get_fd();

  struct pollfd pollfd_arr[2];
  pollfd_arr[0].fd = intr_fd;
  pollfd_arr[0].events = POLLIN;
  pollfd_arr[0].revents = 0;
  pollfd_arr[1].fd = thread_signal_fd;
  pollfd_arr[1].events = POLLIN;
  pollfd_arr[1].revents = 0;
  res = poll(pollfd_arr, 2, poll_timeout_arg);
  if (res < 0) {
    fprintf(stderr, "Poll error errno = %s\n", strerror(errno));
    return false;
  } else if (res > 0 && pollfd_arr[0].revents == POLLIN) {
    uint64_t count;
    ssize_t bytes_read = read(intr_fd, &count, sizeof(count));
    if (bytes_read > 0) {
      DEBUG_PRINT("Poll success. Return=%d count=%lu\n", res, count);
    } else {
      // TODO: remove exit call. Revist this when fixing kernel interrupts
      throw std::runtime_error("Error: poll failed: " + std::string(bytes_read < 0 ? strerror(errno) : "zero bytes read"));
    }
  } else if (res > 0 && pollfd_arr[1].revents == POLLIN) {
    uint64_t count;
    ssize_t bytes_read = read(thread_signal_fd, &count, sizeof(count));
    if (bytes_read > 0) {
      DEBUG_PRINT("Poll success. Return=%d count=%lu\n", res, count);
    } else {
      // TODO: remove exit call. Revist this when fixing kernel interrupts
      throw std::runtime_error("Error: poll failed: " + std::string(bytes_read < 0 ? strerror(errno) : "zero bytes read"));
    }
    return false;
  } else {
    // no event fd event happened
#ifdef ENABLE_OPENCL_KERNEL_INTERRUPTS
    return false;
#endif
  }

#ifdef DLA_MMD
  run_kernel_interrupt_fn();
#else  // IRQ offsets no longer exist in DLA hardware (removed from board.qsys)

  // probobly not required for interrupt polling but we poll the interrupt
  // csr line to make sure an interrupt was actually triggered
  uint32_t irqval = 0;
  fpga_res = fpgaReadMMIO32(m_fpga_handle, 0, AOCL_IRQ_POLLING_BASE, &irqval);
  if (fpga_res != FPGA_OK) {
    fprintf(stderr, "Error fpgaReadMMIO32: %d\n", fpga_res);
    return false;
  }

  DEBUG_PRINT("irqval: %u\n", irqval);
  if (irqval) run_kernel_interrupt_fn();

#ifdef ENABLE_OPENCL_KERNEL_INTERRUPTS
  // workaround for fb:530016
  // check if irq line is still high and generate another interrupt event
  fpga_res = fpgaReadMMIO32(m_fpga_handle, 0, AOCL_IRQ_POLLING_BASE, &irqval);
  if (fpga_res != FPGA_OK) {
    fprintf(stderr, "Error fpgaReadMMIO32: %d\n", fpga_res);
    return false;
  }

  // signal intr event fd
  if (irqval) {
    DEBUG_PRINT("CRITICAL WARNING: irqval has not been cleared by aocl runtime\n");
    uint64_t count = 1;
    ssize_t res = write(intr_fd, &count, sizeof(count));
    if (res < 0) {
      fprintf(stderr, "eventfd : %s", strerror(errno));
      return false;
    }
  }
#endif
#endif

  return true;
}

bool KernelInterrupt::yield_is_enabled() {
#ifdef ENABLE_OPENCL_KERNEL_POLLING_THREAD
  return false;
#else
  return true;
#endif
}

void KernelInterrupt::yield() {
#ifdef ENABLE_OPENCL_KERNEL_POLLING_THREAD
  usleep(0);
#else
  poll_interrupt(0);
#endif
}

void KernelInterrupt::run_kernel_interrupt_fn() {
  if (m_kernel_interrupt_fn) {
    m_kernel_interrupt_fn(m_mmd_handle, m_kernel_interrupt_user_data);
  } else {
    fprintf(stderr, "m_kernel_interrupt_fn is NULL.  No interrupt handler set!\n");
  }
}

void KernelInterrupt::set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void* user_data) {
  m_kernel_interrupt_fn = fn;
  m_kernel_interrupt_user_data = user_data;
}

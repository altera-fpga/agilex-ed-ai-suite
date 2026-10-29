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

#include "dma_work_thread.h"
#include <assert.h>
#include <poll.h>
#include <stdlib.h>
#include <string.h>
#include <cstdint>
#include <iostream>
#include <thread>
#include "ccip_mmd_device.h"
#include "eventfd_wrapper.h"
#include "mmd_dma.h"

using namespace intel_opae_mmd;

dma_work_thread::dma_work_thread(mmd_dma &mmd_dma_arg)
    : m_initialized(false),
      m_thread_wake_event(NULL),
      m_thread(NULL),
      m_work_queue_mutex(),
      m_work_queue(),
      m_mmd_dma(mmd_dma_arg) {
  m_thread_wake_event = new eventfd_wrapper();
  if (!m_thread_wake_event->initialized()) return;

  m_thread = new std::thread(work_thread, std::ref(*this));

  m_initialized = true;
}

dma_work_thread::~dma_work_thread() {
  // kill the thread
  if (m_thread) {
    // send message to thread to end it
    m_thread_wake_event->notify(UINT64_MAX - 1);

    // join with thread until it ends
    m_thread->join();

    delete m_thread;
    m_thread = NULL;
  }

  if (m_thread_wake_event) {
    delete m_thread_wake_event;
    m_thread_wake_event = NULL;
  }

  m_initialized = false;
}

void dma_work_thread::work_thread(dma_work_thread &obj) {
  int res;

  // get eventfd handle
  int thread_signal_fd = obj.m_thread_wake_event->get_fd();

  struct pollfd pollfd_setup;
  while (1) {
    pollfd_setup.fd = thread_signal_fd;
    pollfd_setup.events = POLLIN;
    pollfd_setup.revents = 0;
    res = poll(&pollfd_setup, 1, -1);
    if (res < 0) {
      fprintf(stderr, "Poll error errno = %s\n", strerror(errno));
    } else if (res > 0 && pollfd_setup.revents == POLLIN) {
      uint64_t count_work_items = 0;
      ssize_t bytes_read = read(thread_signal_fd, &count_work_items, sizeof(count_work_items));
      if (bytes_read > 0) {
        DEBUG_PRINT("Poll success. Return=%d count=%lu\n", res, count);
      } else {
        // TODO: the MMD should not exit.  But I have a different branch
        // I'm working on that will change synchronization to use
        // condition variable instead of eventfd in synchronization
        // within the same process.  Will remove this exit() call at
        // when PR for that change is submitted.
        fprintf(stderr, "Error: poll failed: %s\n", bytes_read < 0 ? strerror(errno) : "zero bytes read");
        exit(-1);
      }

      // Ensure count is in proper range
      const unsigned long MAX_WORK_ITEMS = 1000000000;
      if (count_work_items > MAX_WORK_ITEMS && count_work_items != (UINT64_MAX - 1)) {
          fprintf(stderr, "Error: poll value is out of range");
          exit(-1);
      }

      obj.m_work_queue_mutex.lock();
      if (obj.m_work_queue.empty() && count_work_items == UINT64_MAX - 1) {
        // The maximum value of count is set when there is no work left
        // The work queue must also be empty
        // This thread can break out of the loop
        obj.m_work_queue_mutex.unlock();
        break;
      }

      std::queue<dma_work_item> items;
      for (uint64_t i = 0; i < count_work_items; i++) {
        // Check if there are enough jobs in the work queue as requested (count)
        if (obj.m_work_queue.empty()) {
          fprintf(stderr, "Poll error. Not enough tasks in queue.");
          exit(-1);
        }
        dma_work_item item = obj.m_work_queue.front();
        items.push(item);
        obj.m_work_queue.pop();
      }
      obj.m_work_queue_mutex.unlock();

      while (!items.empty()) {
        dma_work_item item = items.front();
        obj.do_dma(item);
        items.pop();
      }
    }
  }
}

int dma_work_thread::enqueue_dma(dma_work_item &item) {
  if (item.op) {
    m_work_queue_mutex.lock();
    m_work_queue.push(item);
    m_work_queue_mutex.unlock();
    // send message to thread to wake it
    // setting count to 1 as only 1 job is pushed to the work queue
    m_thread_wake_event->notify(1);
    return 0;
  } else {
    // if op is not specified, it is a blocking operation and we don't use
    // the thread
    return do_dma(item);
  }
}

int dma_work_thread::do_dma(dma_work_item &item) { return m_mmd_dma.do_dma(item); }

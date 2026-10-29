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

/* ===- acl_pcie_hostch.cpp  ------------------------------------------ C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the class to handle Linux-specific DMA operations.         */
/* The declaration of the class lives in the acl_pcie_dma_linux.h                  */
/* The actual implementation of DMA operation is inside the Linux kernel driver.   */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "acl_pcie_hostch.h"
#include "acl_pcie.h"

// other header files inside MMD driver
#include "acl_pcie_debug.h"
#include "acl_pcie_device.h"
#include "acl_pcie_mm_io.h"
#include "acl_pcie_timer.h"
#include "hw_host_channel.h"

// other standard header files
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <iostream>

#if defined(LINUX)
#include <unistd.h>
#endif  // LINUX
#if defined(WINDOWS)
#include "acl_pcie_dma_windows.h"
#endif  // WINDOWS

void acl_aligned_malloc(void **result, size_t size) {
#if defined(LINUX)
  int posix_success;
  *result = NULL;
  posix_success = posix_memalign(result, PAGE_SIZE, size);
  ACL_PCIE_ASSERT(posix_success == 0, "posix_memalign has failed.\n");
#endif  // LINUX
#if defined(WINDOWS)
  *result = _aligned_malloc(size, PAGE_SIZE);
#endif  // WINDOWS
}

void acl_aligned_free(void *ptr) {
#if defined(LINUX)
  free(ptr);
#endif  // LINUX
#if defined(WINDOWS)
  _aligned_free(ptr);
#endif  // WINDOWS
}

ACL_PCIE_HOSTCH::ACL_PCIE_HOSTCH(fpga_handle handle, ACL_PCIE_MM_IO_MGR *io, ACL_PCIE_DEVICE *pcie, ACL_PCIE_DMA *dma)
    : m_push_queue(NULL),
      m_push_queue_local_end_p(0),
      m_push_queue_size(0),
      m_pull_queue(NULL),
      m_pull_queue_local_front_p(0),
      m_pull_queue_size(0),
      m_pull_queue_available(0),
      m_pull_queue_pointer(NULL),
      m_push_queue_pointer(NULL),
      m_pull_queue_front_p(NULL),
      m_pull_queue_end_p(NULL),
      m_push_queue_front_p(NULL),
      m_push_queue_end_p(NULL),
      m_sync_thread(NULL) {
  ACL_PCIE_ASSERT(handle != INVALID_HANDLE_VALUE, "passed in an invalid device when creating dma object.\n");
  ACL_PCIE_ASSERT(io != NULL, "passed in an empty pointer for io when creating dma object.\n");
  ACL_PCIE_ASSERT(pcie != NULL, "passed in an empty pointer for pcie when creating dma object.\n");
  ACL_PCIE_ASSERT(dma != NULL, "passed in an empty pointer for dma when creating dma object.\n");

  m_handle = handle;
  m_pcie = pcie;
  m_io = io;
  m_dma = dma;
  m_timer = new ACL_PCIE_TIMER();

  // Set the valid for all the channels and helper function that checks status of driver thread
  // to 0
  m_hostch_push_valid = 0;
  m_hostch_pull_valid = 0;
  m_sync_thread_valid = 0;

  const char *dma_timer = getenv("ACL_PCIE_DMA_TIMER");
  if (dma_timer)
    m_use_timer = 1;
  else
    m_use_timer = 0;
}

ACL_PCIE_HOSTCH::~ACL_PCIE_HOSTCH() {
  // If push channel (channel 0) is valid, reset its IP and unpin the MMD buffer
  if (m_hostch_push_valid) {
#if defined(LINUX)
    struct acl_cmd driver_cmd;
    int bytes_read;
    // Save the device id for the selected board
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_HOSTCH_DESTROY_RD;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = NULL;
    driver_cmd.size = 0;
    bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
    ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
    m_dma->hostch_destroy(ACL_HOST_CHANNEL_0_ID);
#endif  // WINDOWS

    if (m_push_queue) {
      acl_aligned_free(m_push_queue);
      m_push_queue = NULL;
    }

    if (m_push_queue_pointer) {
      acl_aligned_free(m_push_queue_pointer);
      m_push_queue_pointer = NULL;
    }

    m_hostch_push_valid = 0;
  }

  // If pull channel (channel 1) is valid, reset its IP and unpin the MMD buffer
  if (m_hostch_pull_valid) {
#if defined(LINUX)
    struct acl_cmd driver_cmd;
    int bytes_read;
    // Save the device id for the selected board
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_HOSTCH_DESTROY_WR;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = NULL;
    driver_cmd.size = 0;
    bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
    ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
    m_dma->hostch_destroy(ACL_HOST_CHANNEL_1_ID);
#endif  // WINDOWS

    if (m_pull_queue) {
      acl_aligned_free(m_pull_queue);
      m_pull_queue = NULL;
    }

    if (m_pull_queue_pointer) {
      acl_aligned_free(m_pull_queue_pointer);
      m_pull_queue_pointer = NULL;
    }

    m_hostch_pull_valid = 0;
  }

  if (m_timer) {
    delete m_timer;
    m_timer = NULL;
  }
}

// Get host channel version of currently programmed device
unsigned int ACL_PCIE_HOSTCH::get_hostch_version() {
  // Make sure version is not what you expect
  unsigned int version = ACL_VERSIONID ^ 1;
  unsigned int hostch_version = ACL_HOSTCH_ZERO_CHANNELS ^ 1;

  // Read device version
  m_io->version->read32(0, &version);

  if (!ACL_HOSTCH_ENABLE) {
    return ACL_HOSTCH_ZERO_CHANNELS;
  }

  // Read hostchannel version
  m_io->hostch_ver->read32(0, &hostch_version);

  return hostch_version;
}

// Function to check that the driver thread that update host channel IP with
// user's updates to MMD buffer's end and front index, is still running.
// Ack call will call sync_thread() if driver thread has timed out.
// Linux kernel space driver thread is set to timeout in 1ms
// if there hasn't been any changes to circular buffer pointer from the host.
int ACL_PCIE_HOSTCH::launch_sync_thread() {
  if (m_sync_thread_valid == 0) {
    acl_aligned_malloc((void **)&m_sync_thread, sizeof(size_t));

    if (m_sync_thread == NULL) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Internal buffer memory allocation failed.\n");
      return -1;
    }

#if defined(LINUX)
    // Save the device id for the selected board
    struct acl_cmd driver_cmd;
    int bytes_read;
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_HOSTCH_THREAD_SYNC;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = m_sync_thread;
    driver_cmd.size = 0;
    bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
    ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
    m_dma->hostch_thread_sync(m_sync_thread);
#endif  // WINDOWS

    m_sync_thread_valid = 1;
  } else {
    return 1;
  }
  return 0;
}

int ACL_PCIE_HOSTCH::sync_thread() {
  if (m_sync_thread_valid && (*m_sync_thread == 0)) {
#if defined(LINUX)
    // Save the device id for the selected board
    struct acl_cmd driver_cmd;
    int bytes_read;
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_HOSTCH_THREAD_SYNC;
    driver_cmd.device_addr = NULL;
    driver_cmd.user_addr = NULL;
    driver_cmd.size = 0;
    bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
    ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
    m_dma->hostch_thread_sync(NULL);
#endif  // WINDOWS

    return 0;
  }
  return 1;
}

// This is called only when there aren't any host channels open
// m_sync_thread is unpinned as part of destroy call to driver. Now free it.
void ACL_PCIE_HOSTCH::destroy_sync_thread() {
  if (m_sync_thread_valid) {
    if (m_sync_thread != NULL) acl_aligned_free(m_sync_thread);

    m_sync_thread_valid = 0;
    m_sync_thread = NULL;
  }
}

// Create host channel. Allocate circular buffer and pin it.
// Then set channel to valid.
int ACL_PCIE_HOSTCH::create_hostchannel(char *name, size_t queue_depth, int direction) {
  int status;
  unsigned int hostch_version;

  hostch_version = get_hostch_version();
  ACL_PCIE_DEBUG_MSG_VERBOSE(
      VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel version read was %u\n", hostch_version);

  // Check if channel name user wants to open exists
  if ((strnlen(name, MAX_NAME_SIZE) == strnlen(ACL_HOST_CHANNEL_0_NAME, sizeof(ACL_HOST_CHANNEL_0_NAME))) &&
      (strncmp(ACL_HOST_CHANNEL_0_NAME, name, strnlen(ACL_HOST_CHANNEL_0_NAME, sizeof(ACL_HOST_CHANNEL_0_NAME))) == 0)) {
    int channel = ACL_HOST_CHANNEL_0_ID;
    // Check if hostchannel version is one that has ACL_HOST_CHANNEL_0_ID
    if (hostch_version != ACL_HOSTCH_TWO_CHANNELS) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX,
                                 ":::: [HOST CHANNEL] Host Channel %s does not exist in currently programmed device.\n",
                                 ACL_HOST_CHANNEL_0_NAME);
      return ERROR_INVALID_CHANNEL;
    }

    // check if the direction for the channel is correct
    if (direction != ACL_HOST_CHANNEL_0_WRITE) return ERROR_INCORRECT_DIRECTION;

    // Check if channel was already opened previously
    if (m_hostch_push_valid) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel '%s' already open\n", ACL_HOST_CHANNEL_0_NAME);
      return ERROR_CHANNEL_PREVIOUSLY_OPENED;
    }

    // Make sure the channel depth is at most 1MB, power-of-2, and divisible by page_size
    size_t queue_depth_upper_pow2 = (size_t)pow(2, ceil(log((double)queue_depth) / log(2.)));
    size_t channel_depth = (queue_depth_upper_pow2 >= HOSTCH_MAX_BUF_SIZE)
                               ? HOSTCH_MAX_BUF_SIZE
                               : queue_depth_upper_pow2 & (HOSTCH_MAX_BUF_SIZE - PAGE_SIZE);

    // Make sure the channel depth is at least 4KB
    if (!channel_depth) channel_depth = PAGE_SIZE;

    // Create circular buffer for push
    acl_aligned_malloc(&m_push_queue, channel_depth);

    if (m_push_queue == NULL) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Internal buffer memory allocation failed.\n");
      return -1;
    }

    // Create buffer to hold front and end pointer for the circular buffer
    acl_aligned_malloc((void **)&m_push_queue_pointer, sizeof(size_t) * 2);

    if (m_push_queue_pointer == NULL) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Internal buffer memory allocation failed.\n");
      acl_aligned_free(m_push_queue);
      return -1;
    }

    // Set parameters for the push channel
    m_push_queue_size = channel_depth;
    m_push_queue_local_end_p = 0;

    m_push_queue_front_p = m_push_queue_pointer;
    m_push_queue_end_p = (m_push_queue_pointer + 1);

    *m_push_queue_front_p = 0;
    *m_push_queue_end_p = 0;

    // sync_thread() used to check if kernel thread is still running when user has additional data available.
    status = launch_sync_thread();
    if (status == -1) {
      acl_aligned_free(m_push_queue);
      acl_aligned_free(m_push_queue_pointer);
      return -1;
    }

#if defined(LINUX)
    struct acl_cmd driver_cmd;
    int bytes_read;
    // Send the pointers for the 2 buffers to driver, along with queue size
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_HOSTCH_CREATE_RD;
    driver_cmd.device_addr = m_push_queue_pointer;
    driver_cmd.user_addr = m_push_queue;
    driver_cmd.size = channel_depth;
    bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
    ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
    m_dma->hostch_create(m_push_queue, m_push_queue_pointer, channel_depth, channel);
#endif  // WINDOWS

    m_hostch_push_valid = 1;
    return channel;
  } else if ((strnlen(name, MAX_NAME_SIZE) == strnlen(ACL_HOST_CHANNEL_1_NAME, sizeof(ACL_HOST_CHANNEL_1_NAME))) &&
             (strncmp(ACL_HOST_CHANNEL_1_NAME, name, strnlen(ACL_HOST_CHANNEL_1_NAME, sizeof(ACL_HOST_CHANNEL_1_NAME))) == 0)) {
    int channel = ACL_HOST_CHANNEL_1_ID;

    // Check if hostchannel version is one that has ACL_HOST_CHANNEL_1_ID
    if (hostch_version != ACL_HOSTCH_TWO_CHANNELS) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX,
                                 ":::: [HOST CHANNEL] Host Channel %s does not exist in currently programmed device.\n",
                                 ACL_HOST_CHANNEL_1_NAME);
      return ERROR_INVALID_CHANNEL;
    }

    // Check if direction is correct
    if (direction != ACL_HOST_CHANNEL_1_WRITE) return ERROR_INCORRECT_DIRECTION;

    // Make sure the channel depth is at most 1MB, power-of-2, and divisible by page_size
    size_t queue_depth_upper_pow2 = (size_t)pow(2, ceil(log((double)queue_depth) / log(2.)));
    size_t channel_depth = (queue_depth_upper_pow2 >= HOSTCH_MAX_BUF_SIZE)
                               ? HOSTCH_MAX_BUF_SIZE
                               : queue_depth_upper_pow2 & (HOSTCH_MAX_BUF_SIZE - PAGE_SIZE);

    // Make sure the circular buffer is at least 4KB
    if (!channel_depth) channel_depth = PAGE_SIZE;

    // Check if pull channel was previously opened
    if (m_hostch_pull_valid) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel '%s' already open\n", ACL_HOST_CHANNEL_1_NAME);
      return ERROR_CHANNEL_PREVIOUSLY_OPENED;
    }

    // Create circular buffer
    acl_aligned_malloc(&m_pull_queue, channel_depth);

    if (m_pull_queue == NULL) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Internal buffer memory allocation failed.\n");
      return -1;
    }

    // Create buffer to hold front and end pointer of the circular buffer
    acl_aligned_malloc((void **)&m_pull_queue_pointer, sizeof(size_t) * 2);

    if (m_pull_queue_pointer == NULL) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Internal buffer memory allocation failed.\n");
      acl_aligned_free(m_pull_queue);
      return -1;
    }

    // Set pull channel parameters
    m_pull_queue_size = channel_depth;
    m_pull_queue_available = 0;
    m_pull_queue_local_front_p = 0;

    m_pull_queue_front_p = m_pull_queue_pointer;
    m_pull_queue_end_p = (m_pull_queue_pointer + 1);

    *m_pull_queue_front_p = 0;
    *m_pull_queue_end_p = 0;

    // sync_thread() used to check if kernel thread is dead or alive when user pulls data
    status = launch_sync_thread();
    if (status == -1) {
      acl_aligned_free(m_pull_queue);
      acl_aligned_free(m_pull_queue_pointer);
      return -1;
    }

#if defined(LINUX)
    // Send the pointers for the 2 buffers to driver, along with queue size, and initiate IP
    struct acl_cmd driver_cmd;
    int bytes_read;
    driver_cmd.bar_id = ACLPCI_CMD_BAR;
    driver_cmd.command = ACLPCI_CMD_HOSTCH_CREATE_WR;
    driver_cmd.device_addr = m_pull_queue_pointer;
    driver_cmd.user_addr = m_pull_queue;
    driver_cmd.size = channel_depth;
    bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
    ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
    m_dma->hostch_create(m_pull_queue, m_pull_queue_pointer, channel_depth, channel);
#endif  // WINDOWS

    m_hostch_pull_valid = 1;
    return channel;
  } else {
    ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Channel does not exist.\n");
    return ERROR_INVALID_CHANNEL;
  }
}

// Destroy Channel. Unlock all buffer, and set channel to invalid.
int ACL_PCIE_HOSTCH::destroy_hostchannel(int channel) {
  if (channel == ACL_HOST_CHANNEL_0_ID) {
    if (m_hostch_push_valid) {
      // set pull IP to reset and unlock all buffers
#if defined(LINUX)
      struct acl_cmd driver_cmd;
      int bytes_read;
      driver_cmd.bar_id = ACLPCI_CMD_BAR;
      driver_cmd.command = ACLPCI_CMD_HOSTCH_DESTROY_RD;
      driver_cmd.device_addr = NULL;
      driver_cmd.user_addr = NULL;
      driver_cmd.size = 0;
      bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
      ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
      m_dma->hostch_destroy(channel);
#endif  // WINDOWS

      if (m_push_queue) {
        acl_aligned_free(m_push_queue);
        m_push_queue = NULL;
      }
      if (m_push_queue_pointer) {
        acl_aligned_free(m_push_queue_pointer);
        m_push_queue_pointer = NULL;
      }

      m_hostch_push_valid = 0;
      if (m_hostch_pull_valid == 0) {
        destroy_sync_thread();
      }
      return 0;
    } else {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel %s is not open.\n", ACL_HOST_CHANNEL_0_NAME);
      return ERROR_CHANNEL_CLOSED;
    }
  } else if (channel == ACL_HOST_CHANNEL_1_ID) {
    if (m_hostch_pull_valid) {
#if defined(LINUX)
      // set push IP to reset and unlock all buffers
      struct acl_cmd driver_cmd;
      int bytes_read;
      driver_cmd.bar_id = ACLPCI_CMD_BAR;
      driver_cmd.command = ACLPCI_CMD_HOSTCH_DESTROY_WR;
      driver_cmd.device_addr = NULL;
      driver_cmd.user_addr = NULL;
      driver_cmd.size = 0;
      bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
      ACL_PCIE_ASSERT(bytes_read != -1, "error reading driver command.\n");
#endif  // LINUX
#if defined(WINDOWS)
      m_dma->hostch_destroy(channel);
#endif  // WINDOWS

      if (m_pull_queue) {
        acl_aligned_free(m_pull_queue);
        m_pull_queue = NULL;
      }

      if (m_pull_queue_pointer) {
        acl_aligned_free(m_pull_queue_pointer);
        m_pull_queue_pointer = NULL;
      }

      m_hostch_pull_valid = 0;

      if (m_hostch_push_valid == 0) {
        destroy_sync_thread();
      }

      return 0;
    } else {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel %s is not open.\n", ACL_HOST_CHANNEL_1_NAME);
      return ERROR_CHANNEL_CLOSED;
    }
  } else {
    ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Channel with ID %i does not exist.\n", channel);
  }

  return ERROR_INVALID_CHANNEL;
}

// Call for user to get pointer to location in circular buffer
// User can then write data or read data from the buffer, depending on direction.
void *ACL_PCIE_HOSTCH::get_buffer(size_t *buffer_size, int channel, int *status) {
  // Check if channel exists
  if (channel == ACL_HOST_CHANNEL_0_ID) {
    // Check if channel was created
    if (m_hostch_push_valid == 0) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel %s is not open.\n", ACL_HOST_CHANNEL_0_NAME);
      *status = ERROR_CHANNEL_CLOSED;
      *buffer_size = 0;
      return NULL;
    }
    *status = 0;

    char *temp_input_queue = (char *)m_push_queue;

    size_t push_queue_end, push_queue_front;

    // m_push_queue_front_p is directly updated by host channel IP
    // through write over Txs. Save value in local variable,
    // so it doesn't get modified in middle of get_buffer call
    push_queue_end = *m_push_queue_end_p;
    push_queue_front = *m_push_queue_front_p;

    // Calculate available free space in host to device push buffer
    size_t push_buf_avail;
    if (push_queue_end > push_queue_front)
      push_buf_avail = m_push_queue_size - push_queue_end + push_queue_front - 32;
    else if (push_queue_end < push_queue_front)
      push_buf_avail = push_queue_front - push_queue_end - 32;
    else
      push_buf_avail = m_push_queue_size - 32;

    // Calculate how much of the free space is before loop around and after loop around
    size_t cont_push = (m_push_queue_size > m_push_queue_local_end_p + push_buf_avail)
                           ? push_buf_avail
                           : m_push_queue_size - m_push_queue_local_end_p;
    size_t loop_push = (m_push_queue_size > m_push_queue_local_end_p + push_buf_avail)
                           ? 0
                           : (m_push_queue_local_end_p + push_buf_avail - m_push_queue_size);

    // Return to user the pointer to circular buffer for
    // space that's available without loop around
    if (cont_push > 0) {
      *buffer_size = cont_push;
      return temp_input_queue + m_push_queue_local_end_p;
    } else if (loop_push > 0) {
      *buffer_size = loop_push;
      return temp_input_queue;
    } else {
      *status = 0;
      *buffer_size = 0;

      // See if the driver thread is still running
      sync_thread();

      return NULL;
    }
  } else if (channel == ACL_HOST_CHANNEL_1_ID) {
    if (m_hostch_pull_valid == 0) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel %s is not open.\n", ACL_HOST_CHANNEL_1_NAME);
      *status = ERROR_CHANNEL_CLOSED;
      *buffer_size = 0;
      return NULL;
    }
    *status = 0;

    char *temp_output_queue = (char *)m_pull_queue;

    size_t pull_queue_end, pull_queue_front;

    // m_pull_queue_end_p is directly updated by host channel IP
    // through write over Txs. Save value in local variable,
    // so it doesn't get modified in middle of get_buffer call
    pull_queue_end = *m_pull_queue_end_p;
    pull_queue_front = *m_pull_queue_front_p;

    // Calculate available new data in device to host pull buffer
    if (pull_queue_end > pull_queue_front)
      m_pull_queue_available = pull_queue_end - pull_queue_front;
    else if (pull_queue_end < pull_queue_front)
      m_pull_queue_available = m_pull_queue_size - pull_queue_front + pull_queue_end;
    else
      m_pull_queue_available = 0;

    // Calculate how much of the data is before loop around and after loop around
    size_t cont_pull = (m_pull_queue_size > m_pull_queue_local_front_p + m_pull_queue_available)
                           ? m_pull_queue_available
                           : (m_pull_queue_size - m_pull_queue_local_front_p);
    size_t loop_pull = (m_pull_queue_size > m_pull_queue_local_front_p + m_pull_queue_available)
                           ? 0
                           : (m_pull_queue_local_front_p + m_pull_queue_available - m_pull_queue_size);

    // Return to user the pointer to circular buffer for
    // data that's available without loop around
    if (cont_pull > 0) {
      *buffer_size = cont_pull;
      return temp_output_queue + m_pull_queue_local_front_p;
    } else if (loop_pull > 0) {
      *buffer_size = loop_pull;
      return temp_output_queue;
    } else {
      *buffer_size = 0;

      // See if the driver thread is still running
      sync_thread();

      return NULL;
    }
  } else {
    ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Channel with ID %i does not exist.\n", channel);
    *status = ERROR_INVALID_CHANNEL;
    *buffer_size = 0;
    return NULL;
  }
}

// User has acknowledged the buffer, meaning data was written to or read from the buffter.
// Hand off to API using end pointer if push channel, and front pointer if pull channel.
size_t ACL_PCIE_HOSTCH::ack_buffer(size_t send_size, int channel, int *status) {
  if (channel == ACL_HOST_CHANNEL_0_ID) {
    if (m_hostch_push_valid == 0) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel %s is not open.\n", ACL_HOST_CHANNEL_0_NAME);
      *status = ERROR_CHANNEL_CLOSED;
      return 0;
    }
    *status = 0;

    size_t push_queue_end, push_queue_front;

    // Same calculations as get buffer call to see how much
    // space is available in MMD circular buffer
    push_queue_end = *m_push_queue_end_p;
    push_queue_front = *m_push_queue_front_p;

    size_t push_buf_avail;
    if (push_queue_end > push_queue_front)
      push_buf_avail = m_push_queue_size - push_queue_end + push_queue_front - 32;
    else if (push_queue_end < push_queue_front)
      push_buf_avail = push_queue_front - push_queue_end - 32;
    else
      push_buf_avail = m_push_queue_size - 32;

    // Check to see if user wants to send more than the space available in buffer
    // Chose lesser of the two to send
    size_t user_words = send_size / 32;
    size_t current_push = ((user_words * 32) > push_buf_avail) ? push_buf_avail : (user_words * 32);

    // User can't write back to beginning of MMD buffer, since they can't loop around from the pointer
    // they got from get_buffer. Only send up to the end of MMD circular buffer to host channel IP
    size_t cont_push = (m_push_queue_size > m_push_queue_local_end_p + current_push)
                           ? current_push
                           : (m_push_queue_size - m_push_queue_local_end_p);

    // Update the end index that the driver thread will read, to write the update to host channel IP
    // and loop around
    m_push_queue_local_end_p =
        (m_push_queue_local_end_p + current_push >= m_push_queue_size) ? 0 : m_push_queue_local_end_p + current_push;
    *m_push_queue_end_p = m_push_queue_local_end_p;

    // See if the driver thread is still running
    sync_thread();

    return cont_push;
  } else if (channel == ACL_HOST_CHANNEL_1_ID) {
    if (m_hostch_pull_valid == 0) {
      ACL_PCIE_DEBUG_MSG_VERBOSE(
          VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Host Channel %s is not open.\n", ACL_HOST_CHANNEL_1_NAME);
      *status = ERROR_CHANNEL_CLOSED;
      return 0;
    }
    *status = 0;

    size_t driver_pulled;

    size_t pull_queue_end, pull_queue_front;

    // Same calculations as get buffer call to see how much
    // data is available in MMD circular buffer
    pull_queue_end = *m_pull_queue_end_p;
    pull_queue_front = *m_pull_queue_front_p;

    if (pull_queue_end > pull_queue_front)
      m_pull_queue_available = pull_queue_end - pull_queue_front;
    else if (pull_queue_end < pull_queue_front)
      m_pull_queue_available = m_pull_queue_size - pull_queue_front + pull_queue_end;
    else
      m_pull_queue_available = 0;

    // Check to see if user read more than the data available in buffer
    // Chose lesser of the two to tell the user how much was actually
    // freed up for host channel IP to write to.
    driver_pulled = (send_size > m_pull_queue_available) ? m_pull_queue_available : send_size;

    // User can't loop around and read from the beginning of MMD buffer
    // Tell the host channel IP that the buffer is free, only up to the end of the circular buffer
    size_t cont_pull = (m_pull_queue_size > m_pull_queue_local_front_p + driver_pulled)
                           ? driver_pulled
                           : (m_pull_queue_size - m_pull_queue_local_front_p);

    // Update the front index that the driver thread will read, to write the update to host channel IP
    // and loop around
    m_pull_queue_local_front_p = (m_pull_queue_local_front_p + driver_pulled >= m_pull_queue_size)
                                     ? 0
                                     : m_pull_queue_local_front_p + driver_pulled;
    *m_pull_queue_front_p = m_pull_queue_local_front_p;

    // See if the driver thread is still running
    sync_thread();

    return cont_pull;
  } else {
    ACL_PCIE_DEBUG_MSG_VERBOSE(VERBOSITY_BLOCKTX, ":::: [HOST CHANNEL] Channel with ID %i does not exist.\n", channel);
    *status = ERROR_INVALID_CHANNEL;
    return 0;
  }
}

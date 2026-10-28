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

/* ===- acl_pcie_dma_linux.cpp  --------------------------------------- C++ -*-=== */
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

#if defined(LINUX)

// common and its own header files
#include "acl_pcie_dma_linux.h"
#include "acl_pcie.h"

// other header files inside MMD driver
#include "acl_pcie_device.h"
#include "acl_pcie_mm_io.h"

// other standard header files
#include <stdio.h>
#include <sys/time.h>
#include <unistd.h>

ACL_PCIE_DMA::ACL_PCIE_DMA(fpga_handle dev, ACL_PCIE_MM_IO_MGR *io, ACL_PCIE_DEVICE *pcie) {
  ACL_PCIE_ASSERT(dev != INVALID_DEVICE, "passed in an invalid device when creating dma object.\n");
  ACL_PCIE_ASSERT(io != NULL, "passed in an empty pointer for io when creating dma object.\n");
  ACL_PCIE_ASSERT(pcie != NULL, "passed in an empty pointer for pcie when creating dma object.\n");

  m_handle = dev;
  m_pcie = pcie;
  m_io = io;
  m_event = NULL;
}

ACL_PCIE_DMA::~ACL_PCIE_DMA() {
  struct acl_cmd driver_cmd = {ACLPCI_CMD_BAR, ACLPCI_CMD_DMA_STOP, NULL, NULL, 0, 0};
  int bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));
  ACL_PCIE_ASSERT(bytes_read != -1, "failed to read driver command \n");
}

bool ACL_PCIE_DMA::is_idle() {
  unsigned int result = 0;
  int bytes_read;
  struct acl_cmd driver_cmd;
  driver_cmd.bar_id = ACLPCI_CMD_BAR;
  driver_cmd.command = ACLPCI_CMD_GET_DMA_IDLE_STATUS;
  driver_cmd.device_addr = NULL;
  driver_cmd.user_addr = &result;
  driver_cmd.size = sizeof(result);
  bytes_read = read(m_handle, &driver_cmd, sizeof(driver_cmd));

  return (bytes_read != -1 && result != 0);
}

// Perform operations required when a DMA interrupt comes
// For Linux,
//    All of the DMA related interrupts are handled inside the kernel driver,
//    so when MMD gets a signal from the kernel driver indicating DMA is finished,
//    it only needs to call the event_update_fn when it's needed.
void ACL_PCIE_DMA::service_interrupt() {
  if (m_event) {
    // Use a temporary variable to save the event data and reset m_event
    // before calling event_update_fn to avoid race condition that the main
    // thread may start a new DMA transfer before this work-thread is able to
    // reset the m_event.
    // therefore, an assertion is implemented here, as defensively preventing
    // sending interrupt signals incorrectly.
    ACL_PCIE_ASSERT(
        this->is_idle(),
        "The dma is still in running, cannot service an interrupt to invoke another read/write operation\n");
    aocl_mmd_op_t temp_event = m_event;
    m_event = NULL;

    m_pcie->event_update_fn(temp_event, 0);
  }
}

// relinquish the CPU to let any other thread to run
// return 0 since there is no useful work to be performed here
int ACL_PCIE_DMA::yield() {
  usleep(0);
  return 0;
}

// Transfer data between host and device
// This function returns right after the transfer is scheduled
// Return 0 on success
int ACL_PCIE_DMA::read_write(void *host_addr, size_t dev_addr, size_t bytes, aocl_mmd_op_t e, bool reading) {
  // Currently dma cannot operate multiple read/write the same time.
  // This means the read/write should be executed if and only if the dma is idle.
  // Otherwise, it would cause assertion failure in the kernel space of the OS,
  // which result in hanging, and even kernel panic and machine frozen as worst case.
  // An assertion is implemented here, as defensively preventing race condition or incorrect sending of signal.
  ACL_PCIE_ASSERT(this->is_idle(),
                  "The dma is still in running, cannot perform another %s operation concurrently.\n",
                  reading ? "read" : "write");

  m_event = e;

  // There are two scenarios of the read/write operation
  // 1. the referred event is NULL, MMD would be stalled and keep polling the DMA until it is idle.
  // 2. the referred event is valid, MMD would return immediately, runtime will wait for
  //    the DMA service interrupt signal to update the status of the read/write operation.
  //
  // Therefore, the dma service interrupt is expected only when the event is valid.
  struct acl_cmd driver_cmd {};
  driver_cmd.bar_id = ACLPCI_DMA_BAR;
  driver_cmd.command = m_event ? ACLPCI_CMD_DMA_SERVICE_SIGNAL : ACLPCI_CMD_DMA_NO_SIGNAL;
  driver_cmd.device_addr = reinterpret_cast<void *>(dev_addr);
  driver_cmd.user_addr = host_addr;
  driver_cmd.size = bytes;
  if (reading) {
    if (read(m_handle, &driver_cmd, sizeof(driver_cmd)) == -1) return -1;  // reading failed
  } else {
    if (write(m_handle, &driver_cmd, sizeof(driver_cmd)) == -1) return -1;
  }
  return 0;  // success
}

#endif  // LINUX

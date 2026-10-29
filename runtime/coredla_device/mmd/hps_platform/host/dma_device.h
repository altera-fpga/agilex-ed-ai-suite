#ifndef DMA_DEVICE_H_
#define DMA_DEVICE_H_

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

/* ===- dma_device.h  ------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         dma device access functions                             */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the functions used access the dma device objects           */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
#include <vector>
#include <string>
#include <memory>

#include "hps_types.h"

class dma_device
{
public:
  dma_device(std::string &name);
  ~dma_device();

  int read_block(void *host_addr, size_t offset, size_t size);
  int write_block(const void *host_addr, size_t offset, size_t size);

  bool bValid() { return _pFile != nullptr; };
private:

  dma_device() = delete;
  dma_device(dma_device const&) = delete;
  void operator=(dma_device const &) = delete;

  FILE *_pFile = {nullptr}; // File pointer to UIO - Used to indicate the the uio_device is valid
};
typedef std::shared_ptr<dma_device> dma_device_ptr;

#endif // DMA_DEVICE_H_

#ifndef MMD_DEVICE_H_
#define MMD_DEVICE_H_

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

/* ===- mmd_device.h  ------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         mmd device access functions                             */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the functions used access the mmd device object            */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
#include <memory>
#include <string>

#include "hps_types.h"
#include "dma_device.h"
#include "uio_device.h"

#include "aocl_mmd.h"

// LOG ERRORS
#define MMD_ERR_LOGGING 1
#ifdef MMD_ERR_LOGGING
#define LOG_ERR(...) fprintf(stderr, __VA_ARGS__)
#else
#define LOG_ERR(...)
#endif

class mmd_device {
public:
  mmd_device(std::string name, const int mmd_handle);

  bool bValid() { return _spCoredlaDevice && _spCoredlaDevice->bValid() && _spDmaDevice && _spDmaDevice->bValid(); };
  bool bStreamControllerValid() { return _spCoredlaDevice && _spStreamControllerDevice && _spStreamControllerDevice->bValid(); };
  int write_block(aocl_mmd_op_t op, int mmd_interface, const void *host_addr, size_t offset, size_t size);
  int read_block(aocl_mmd_op_t op, int mmd_interface, void *host_addr, size_t offset, size_t size);

  int set_interrupt_handler(aocl_mmd_interrupt_handler_fn fn, void *user_data);
private:
  int32_t extract_index(const std::string name);

  mmd_device() = delete;
  mmd_device(mmd_device const&) = delete;
  void operator=(mmd_device const &) = delete;
  std::string _name;

  uio_device_ptr _spCoredlaDevice;
  uio_device_ptr _spStreamControllerDevice;
  dma_device_ptr _spDmaDevice;
  int            _mmd_handle;
};

typedef std::shared_ptr<mmd_device> mmd_device_ptr;

extern board_names mmd_get_devices(const int max_fpga_devices);

#endif // MMD_DEVICE_H_

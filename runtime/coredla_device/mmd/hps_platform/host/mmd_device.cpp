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

#include "mmd_device.h"

// Defined names of the UIO Nodes
#define UIO_COREDLA_PREFIX "coredla"
#define STREAM_CONTROLLER_PREFIX "stream_controller"

// Defined name of the msgdma device
#define DMA_DEVICE_PREFIX "/dev/msgdma_coredla"
#define UIO_DEVICE_PREFIX "uio"

board_names mmd_get_devices(const int max_fpga_devices)
{
    return uio_get_devices(UIO_COREDLA_PREFIX, max_fpga_devices);
}


/////////////////////////////////////////////////////////
mmd_device::mmd_device(std::string name, const int mmd_handle)
: _name(name), _mmd_handle(mmd_handle) {
    _spCoredlaDevice = std::make_shared<uio_device>(name, _mmd_handle, true);
    int32_t index = extract_index(_name);
    if( (index >= 0) && _spCoredlaDevice && _spCoredlaDevice->bValid() )
    {
        std::string dma_name(DMA_DEVICE_PREFIX);
        dma_name += std::to_string(index);
        _spDmaDevice = std::make_shared<dma_device>(dma_name);

        if( (_spDmaDevice==nullptr) || (!_spDmaDevice->bValid()) ) {
            _spDmaDevice = nullptr;
            return;
        }
        std::string stream_controller_name = uio_get_device(STREAM_CONTROLLER_PREFIX, index);
        if( !stream_controller_name.empty() ) {
            // Create a uio_device but don't attach any interrupt support as the stream controller
            // does not require interrupts
            _spStreamControllerDevice = std::make_shared<uio_device>(stream_controller_name, _mmd_handle, false);
            if( _spStreamControllerDevice && !_spStreamControllerDevice->bValid() ) {
                // The stream controller does not exist
                _spStreamControllerDevice = nullptr;
            }
        }
    }
}

int mmd_device::read_block(aocl_mmd_op_t op, int mmd_interface, void *host_addr, size_t offset, size_t size)
{
    if( op ) {
        LOG_ERR("op not support : %s\n", __func__ );
        return FAILURE;
    }
    if( mmd_interface == HPS_MMD_MEMORY_HANDLE ) {
        return _spDmaDevice->read_block(host_addr, offset, size);
    } else if( mmd_interface == HPS_MMD_COREDLA_CSR_HANDLE ) {
        return _spCoredlaDevice->read_block(host_addr, offset, size);
    } else if( mmd_interface == HPS_MMD_STREAM_CONTROLLER_HANDLE ) {
        if ( _spStreamControllerDevice ) {
            return _spStreamControllerDevice->read_block(host_addr, offset, size);
        }
    }

    return FAILURE;
}

int mmd_device::write_block(aocl_mmd_op_t op, int mmd_interface, const void *host_addr, size_t offset, size_t size)
{
     if( op ) {
        LOG_ERR("op not support : %s\n", __func__ );
        return FAILURE;
    }
    if( mmd_interface == HPS_MMD_MEMORY_HANDLE ) {
        return _spDmaDevice->write_block(host_addr, offset, size);
    } else if ( mmd_interface == HPS_MMD_COREDLA_CSR_HANDLE ) {
        return _spCoredlaDevice->write_block(host_addr, offset, size);
    } else if ( mmd_interface == HPS_MMD_STREAM_CONTROLLER_HANDLE ) {
        if( _spStreamControllerDevice ) {
            return _spStreamControllerDevice->write_block(host_addr, offset, size);
        }
    }
    return FAILURE;
}

int mmd_device::set_interrupt_handler(aocl_mmd_interrupt_handler_fn fn, void *user_data) {
    if( _spCoredlaDevice ) {
        return _spCoredlaDevice->set_interrupt_handler(fn, user_data);
    }
    return FAILURE;
}

// Returns the index of a uio device
// If index cannot be found then returns -1
int mmd_device::extract_index(const std::string name) {
    std::string prefix(UIO_DEVICE_PREFIX);

  if (name.length() <= prefix.length() && name.compare(0, prefix.length(), prefix)) {
    LOG_ERR("Error parsing device name '%s'\n", name.c_str());
    return -1;
  }

  std::string device_num_str = name.substr(prefix.length());
  int32_t index = std::stoi(device_num_str, 0, 10);
  return index;
}

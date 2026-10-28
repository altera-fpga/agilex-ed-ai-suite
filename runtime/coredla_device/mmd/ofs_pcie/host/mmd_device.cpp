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

#include <assert.h>
#include <numa.h>

#include <inttypes.h>
#include <string.h>
#include <unistd.h>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <sstream>

#include "mmd_device.h"
#include "mmd_helper.h"

int Device::next_mmd_handle{1};

/**
 * The Device object is created for each device/board opened and
 * it has methods to interact with fpga device.
 * The entry point for Device is in DeviceMapManager Class
 * which maintains mapping between device names and handles.
 * Device Object is foundation for interacting with device.
 */
Device::Device(uint64_t obj_id)
    : fpga_obj_id(obj_id),
      kernel_interrupt_thread(NULL),
      event_update(NULL),
      event_update_user_data(NULL),
      enable_set_numa(false),
      fme_sysfs_temp_initialized(false),
      bus(0),
      device(0),
      function(0),
      afu_initialized(false),
      asp_initialized(false),
      mmio_is_mapped(false),
      filter(NULL),
      mmio_token(NULL),
      mmio_handle(NULL),
      fme_token(NULL),
      guid(),
      mmd_dma(NULL) {
  // Note that this constructor is not thread-safe because next_mmd_handle
  // is shared between all class instances
  MMD_DEBUG("DEBUG LOG : Constructing Device object\n");

  mmd_handle = next_mmd_handle;
  if (next_mmd_handle == std::numeric_limits<int>::max())
    next_mmd_handle = 1;
  else
    next_mmd_handle++;

  fpga_properties filter = NULL;
  uint32_t num_matches;
  fpga_result r;

  // Set up a filter that will search for an accelerator
  fpgaGetProperties(NULL, &filter);
  fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);

  // Add the desired UUID to the filter
  uuid_parse(I_DK_AFU_ID, guid);
  fpgaPropertiesSetGUID(filter, guid);

  // Do the search across the available FPGA contexts
  num_matches = 1;
  fpgaEnumerate(&filter, 1, &mmio_token, 1, &num_matches);

  fpgaPropertiesGetParent(filter, &fme_token);

  // Not needed anymore so we destroy the filter
  fpgaDestroyProperties(&filter);

  if (num_matches < 1) {
    throw std::runtime_error(std::string("Cannot find accelerator"));
  }

  // Open accelerator
  r = fpgaOpen(mmio_token, &mmio_handle, 0);
  assert(FPGA_OK == r);

  // While the token is available, check whether it is for HW
  // or for ASE simulation.
  fpga_properties accel_props;
  uint16_t vendor_id, dev_id;
  fpgaGetProperties(mmio_token, &accel_props);
  fpgaPropertiesGetVendorID(accel_props, &vendor_id);
  fpgaPropertiesGetDeviceID(accel_props, &dev_id);

  afu_initialized = true;
  MMD_DEBUG("DEBUG LOG : Done constructing Device object\n");
}

/** Return true if board name parses correctly, false if it does not
 *  Return the parsed object_id in obj_id as an [out] parameter
 */
bool Device::parse_board_name(const char *board_name_str, uint64_t &obj_id) {
  MMD_DEBUG("DEBUG LOG : Parsing board name\n");
  std::string prefix(ASP_NAME);
  std::string board_name(board_name_str);

  obj_id = 0;
  if (board_name.length() <= prefix.length() && board_name.compare(0, prefix.length(), prefix)) {
    MMD_DEBUG("DEBUG LOG : Error parsing device name '%s'\n", board_name_str);
    return false;
  }

  std::string device_num_str = board_name.substr(prefix.length());
  obj_id = std::stol(device_num_str, 0, 16);

  // Assume that OPAE does not use 0 as a valid object ID. This is true for now
  // but relies somewhat on an implementaion dependent feature.
  assert(obj_id > 0);
  return true;
}

/** initialize_asp() function is used in aocl_mmd_open() API
 *  It resets AFC and reinitializes DMA, Kernel Interrupts if in use
 */
bool Device::initialize_asp() {
  MMD_DEBUG("DEBUG LOG : Initializing ASP ... \n");
  if (asp_initialized) {
    MMD_DEBUG("DEBUG LOG : ASP already initialized \n");
    return true;
  }

  fpga_result res = fpgaMapMMIO(mmio_handle, 0, NULL);
  if (res != FPGA_OK) {
    MMD_DEBUG("Error mapping MMIO space: %s\n", fpgaErrStr(res));
    return false;
  }
  mmio_is_mapped = true;

  // DMA performance is heavily dependent on the memcpy operation that transfers
  // data from user allocated buffer to the pinned buffer that is used for
  // DMA.  On some machines with multiple NUMA nodes it is critical for
  // performance that the pinned buffer is located on the NUMA node as the
  // threads that performs the DMA operation.
  //
  // The performance also improves slighlty if the DMA threads are on the same
  // NUMA node as the FPGA PCI device.
  //
  // This code pins memory allocation to occur from FPGA NUMA node prior to
  // initializing the DMA buffers.  It also pins all threads in the process
  // to run on this same node.
  struct bitmask *mask = NULL;
  if (enable_set_numa) {
    mask = numa_parse_nodestring(fpga_numa_node.c_str());
    numa_set_membind(mask);
    int ret = numa_run_on_node_mask_all(mask);
    if (ret < 0) {
      fprintf(stderr, " Error setting NUMA node mask\n");
    }
  }

  MMD_DEBUG("DEBUG LOG : Initializing HOST -> FPGA DMA channel \n");

  mmd_dma = new intel_opae_mmd::mmd_dma(mmio_handle, mmd_handle);
  if (!mmd_dma->initialized()) {
    MMD_DEBUG("DEBUG LOG : Error initializing DMA channel \n");
    delete mmd_dma;
    return false;
  }

  // Turn off membind restriction in order to allow future allocation to
  // occur on different NUMA nodes if needed.  Hypothesis is that only
  // the pinned buffers are performance critical for the memcpy. Other
  // allocations in the process can occur on other NUMA nodes if needed.
  if (enable_set_numa) {
    numa_set_membind(numa_nodes_ptr);
    numa_free_nodemask(mask);
  }

// Do not enable interrupt if polling mode is enabled in the DLA runtime.
#ifndef COREDLA_RUNTIME_POLLING
  try {
    kernel_interrupt_thread = new intel_opae_mmd::KernelInterrupt(mmio_handle, mmd_handle);
  } catch (const std::system_error &e) {
    std::cerr << "Error initializing kernel interrupt thread: " << e.what() << e.code() << std::endl;
    return false;
  } catch (const std::exception &e) {
    std::cerr << "Error initializing kernel interrupt thread: " << e.what() << std::endl;
    return false;
  }
#endif

  asp_initialized = true;
  MMD_DEBUG("DEBUG LOG : ASP Initialized ! \n");
  return asp_initialized;
}

/** Device Class Destructor implementation
 *  Properly releasing and free-ing memory
 *  part of best coding practices and help
 *  with stable system performance and
 *  helps reduce bugs
 */
Device::~Device() {
  MMD_DEBUG("DEBUG LOG : Destructing Device object \n");
  int num_errors = 0;

  if (kernel_interrupt_thread != nullptr) {
    delete kernel_interrupt_thread;
    kernel_interrupt_thread = NULL;
  }

  if (mmd_dma) {
    delete mmd_dma;
    mmd_dma = NULL;
  }

  if (mmio_is_mapped) {
    if (fpgaUnmapMMIO(mmio_handle, 0)) {
      MMD_DEBUG("DEBUG LOG :  fpgaUnmapMMIO failed\n");
      num_errors++;
    }
  }

  if (mmio_handle) {
    if (fpgaClose(mmio_handle) != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG :  fpgaClose mmio_handle failed\n");
      num_errors++;
    }
  }

  if (mmio_token) {
    if (fpgaDestroyToken(&mmio_token) != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG :  fpgaDestroyToken mmio_token failed\n");
      num_errors++;
    }
  }

  if (filter) {
    if (fpgaDestroyProperties(&filter) != FPGA_OK) {
      MMD_DEBUG("DEBUG LOG :  fpgaDestroyProperties filter failed\n");
      num_errors++;
    }
  }

  if (num_errors > 0) {
    MMD_DEBUG("DEBUG LOG : Error freeing resources in Device destructor\n");
  }
}

/** asp_loaded() function which checks if asp is loaded on board
 *  it is used in aocl_mmd_open() API
 */
bool Device::asp_loaded() {
  fpga_guid pci_guid;
  fpga_guid afu_guid;
  fpga_properties prop;
  fpga_result res;

  if (uuid_parse(I_DK_AFU_ID, pci_guid) < 0) {
    MMD_DEBUG("DEBUG LOG : Error parsing guid\n");
    return false;
  }

  res = fpgaGetProperties(mmio_token, &prop);
  if (res != FPGA_OK) {
    MMD_DEBUG("DEBUG LOG : Error reading properties: %s \n", fpgaErrStr(res));
    fpgaDestroyProperties(&prop);
    return false;
  }

  if (!mmio_token) {
    fpgaDestroyProperties(&prop);
    MMD_DEBUG("DEBUG LOG : Error reading the mmio_token\n");
    return false;
  }

  res = fpgaPropertiesGetGUID(prop, &afu_guid);
  if (res != FPGA_OK) {
    MMD_DEBUG("DEBUG LOG : Error reading GUID \n");
    fpgaDestroyProperties(&prop);
    return false;
  }

  fpgaDestroyProperties(&prop);
  if (uuid_compare(pci_guid, afu_guid) == 0) {
    MMD_DEBUG("DEBUG LOG : asp loaded : true \n");
    return true;
  } else {
    MMD_DEBUG("DEBUG LOG : asp loaded : false \n");
    return false;
  }
}

/** get_bdf() function is called
 *  in aocl_mmd_get_info() API
 */
std::string Device::get_bdf() {
  std::ostringstream bdf;
  bdf << std::setfill('0') << std::setw(2) << std::hex << unsigned(bus) << ":" << std::setfill('0') << std::setw(2)
      << std::hex << unsigned(device) << "." << std::hex << unsigned(function);

  return bdf.str();
}

/** get_temperature() function is called
 *  in aocl_mmd_get_info() API
 *  We currently use hardcoded paths to retrieve temperature information
 *  We will replace with OPAE APIs in future
 */
float Device::get_temperature() {
  if (std::getenv("MMD_ENABLE_DEBUG")) {
    MMD_DEBUG("DEBUG LOG : Reading temperature ... \n");
  }
  float temp = 0;
  fpga_object obj;
  const char *name;
  name = "dfl_dev.*/spi_master/spi*/spi*.*/*-hwmon.*.auto/hwmon/hwmon*/temp1_input";
  fpga_result res;
  res = fpgaTokenGetObject(fme_token, name, &obj, FPGA_OBJECT_GLOB);
  if (res != FPGA_OK) {
    MMD_DEBUG("DEBUG LOG : Error reading temperature monitor from BMC :");
    MMD_DEBUG(" %s \n", fpgaErrStr(res));
    temp = -999;
    return temp;
  }

  uint64_t value = 0;
  fpgaObjectRead64(obj, &value, FPGA_OBJECT_SYNC);
  fpgaDestroyObject(&obj);
  temp = value / 1000;
  return temp;
}

/** set_kernel_interrupt() function is used in aocl_mmd_set_interrupt_handler() API
 */
void Device::set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void *user_data) {
  MMD_DEBUG("DEBUG LOG : Device::set_kernel_interrupt() \n");
  if (kernel_interrupt_thread) {
    kernel_interrupt_thread->set_kernel_interrupt(fn, user_data);
  }
}

/** set_kernel_interrupt() function is used in aocl_mmd_set_status_handler() API
 */
void Device::set_status_handler(aocl_mmd_status_handler_fn fn, void *user_data) {
  MMD_DEBUG("DEBUG LOG : Device::set_status_handler() \n");
  event_update = fn;
  event_update_user_data = user_data;
}

/** event_update_fn() is used in read_block(), write_block(), copy_block() functions
 *  OPAE provides event API for handling asynchronous events sucj as errors and interrupts
 *  under the hood those are used
 */
void Device::event_update_fn(aocl_mmd_op_t op, int status) {
  MMD_DEBUG("DEBUG LOG : Device::event_update_fn() \n");
  event_update(mmd_handle, event_update_user_data, op, status);
}

/** read_block() is used in aocl_mmd_read() API
 *  as name suggests its used for fpga->host DMA and MMIO transfers
 */
int Device::read_block(aocl_mmd_op_t op, int mmd_interface, void *host_addr, size_t offset, size_t size) {
  MMD_DEBUG("DEBUG LOG : Device::read_block()\n");
  int res;

  // The mmd_interface is defined as the base address of the MMIO write.  Access
  // to memory requires special functionality.  Otherwise do direct MMIO read.

  if (mmd_interface == AOCL_MMD_MEMORY) {
    std::unique_lock<std::mutex> dma_mutex_lock(m_dma_mutex);
    MMD_DEBUG("DEBUG LOG : Using DMA to read block\n");
    res = mmd_dma->fpga_to_host(host_addr, (uint64_t)offset, size);
  } else if (mmd_interface == AOCL_MMD_DLA_CSR) {
    assert(size == 4);  // DLA CSR read should be always size ==4 as of 2024.2
    MMD_DEBUG("DEBUG LOG : Using MMIO to read block in the DLA CSR space\n");
    res = read_mmio(host_addr, offset, size);
  } else {
    MMD_DEBUG("DEBUG LOG : Using MMIO to read block\n");
    res = read_mmio(host_addr, mmd_interface + offset, size);

    if (op) {
      this->event_update_fn(op, res);
    }
  }
  return res;
}

/** write_block() is used in aocl_mmd_write() API
 *  as name suggests its used for DMA and MMIO transfers
 */
int Device::write_block(aocl_mmd_op_t op, int mmd_interface, const void *host_addr, size_t offset, size_t size) {
  MMD_DEBUG("DEBUG LOG : Device::write_block()\n");
  int res;

  // The mmd_interface is defined as the base address of the MMIO write.  Access
  // to memory requires special functionality.  Otherwise do direct MMIO write
  if (mmd_interface == AOCL_MMD_MEMORY) {
    std::unique_lock<std::mutex> dma_mutex_lock(m_dma_mutex);
    MMD_DEBUG("DEBUG LOG : Using DMA to write block\n");
    res = mmd_dma->host_to_fpga(host_addr, (uint64_t)offset, size);
  } else if (mmd_interface == AOCL_MMD_DLA_CSR) {
    assert(size == 4); // DLA CSR read should be always size ==4 as of 2024.2
    MMD_DEBUG("DEBUG LOG : Using MMIO to read block in the DLA CSR space\n");
    res = write_mmio(host_addr, offset, size);
  } else {
    MMD_DEBUG("DEBUG LOG : Using MMIO to write block\n");
    res = write_mmio(host_addr, mmd_interface + offset, size);
    if (op) {
      this->event_update_fn(op, res);
    }
  }

  return res;
}

/** read_mmio() is used in read_block() function
 *  it uses OPAE APIs fpgaReadMMIO64() and fpgaReadMMIO32()
 */
int Device::read_mmio(void *host_addr, size_t mmio_addr, size_t size) {
  return mmd_helper::read_mmio(mmio_handle, host_addr, mmio_addr, size);
}

/** write_mmio() is used in write_block() function
 *  it uses OPAE APIs fpgaWriteMMIO64() and fpgaWriteMMIO32()
 */
int Device::write_mmio(const void *host_addr, size_t mmio_addr, size_t size) {
  return mmd_helper::write_mmio(mmio_handle, host_addr, mmio_addr, size);
}

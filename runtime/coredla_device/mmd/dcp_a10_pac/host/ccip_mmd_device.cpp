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

#include <assert.h>
#include <numa.h>

#include <unistd.h>
#include <fstream>
#include <iomanip>
#include <iostream>
#include <limits>
#include <sstream>

#include <safe_string/safe_string.h>
#include "memcpy_s_fast.h"

#include "ccip_mmd_device.h"

// TODO: better encapsulation of afu_bbb_util functions
#include "afu_bbb_util.h"

#define MMD_COPY_BUFFER_SIZE (1024 * 1024)

#define MEM_WINDOW_BBB_GUID "72347537-7821-4125-442a-472d4b615064"
#define MEM_WINDOW_BBB_SIZE 8192

#define MSGDMA_BBB_GUID "ef82def7-f6ec-40fc-a914-9a35bace01ea"
#define MSGDMA_BBB_SIZE 256

#define NULL_DFH_BBB_GUID "da1182b1-b344-4e23-90fe-6aab12a0132f"
#define BSP_AFU_GUID "96ef4230-dafa-cb5f-18b7-9ffa2ee54aa0"

using namespace intel_opae_mmd;

int CcipDevice::next_mmd_handle{1};

std::string CcipDevice::get_board_name(std::string prefix, uint64_t obj_id) {
  std::ostringstream stream;
  stream << prefix << std::setbase(16) << obj_id;
  return stream.str();
}

CcipDevice::CcipDevice(uint64_t obj_id)
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
      bsp_initialized(false),
      mmio_is_mapped(false),
      afc_handle(NULL),
      filter(NULL),
      afc_token(NULL),
      dma_ch0_dfh_offset(0),
      dma_ch1_dfh_offset(0),
      dma_ase_dfh_offset(0),
      dma_host_to_fpga(NULL),
      dma_fpga_to_host(NULL),
      mmd_copy_buffer(NULL) {
  // Note that this constructor is not thread-safe because next_mmd_handle
  // is shared between all class instances
  mmd_handle = next_mmd_handle;
  if (next_mmd_handle == std::numeric_limits<int>::max())
    next_mmd_handle = 1;
  else
    next_mmd_handle++;

  mmd_copy_buffer = (char *)malloc(MMD_COPY_BUFFER_SIZE);
  if (mmd_copy_buffer == NULL) {
    throw std::runtime_error(std::string("malloc failed for mmd_copy_buffer"));
  }

  fpga_result res = FPGA_OK;
  uint32_t num_matches;

  res = fpgaGetProperties(NULL, &filter);
  if (res != FPGA_OK) {
    throw std::runtime_error(std::string("Error creating properties object: ") + std::string(fpgaErrStr(res)));
  }

  res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
  if (res != FPGA_OK) {
    throw std::runtime_error(std::string("Error setting object type: ") + std::string(fpgaErrStr(res)));
  }

  res = fpgaPropertiesSetObjectID(filter, obj_id);
  if (res != FPGA_OK) {
    throw std::runtime_error(std::string("Error setting object ID: ") + std::string(fpgaErrStr(res)));
  }

  res = fpgaEnumerate(&filter, 1, &afc_token, 1, &num_matches);
  if (res != FPGA_OK) {
    throw std::runtime_error(std::string("Error enumerating AFCs: ") + std::string(fpgaErrStr(res)));
  }

  if (num_matches < 1) {
    res = fpgaDestroyProperties(&filter);
    throw std::runtime_error("AFC not found");
  }

  res = fpgaOpen(afc_token, &afc_handle, 0);
  if (res != FPGA_OK) {
    throw std::runtime_error(std::string("Error opening AFC: ") + std::string(fpgaErrStr(res)));
  }

  fpga_properties prop = nullptr;
  res = fpgaGetProperties(afc_token, &prop);
  if (res != FPGA_OK) {
    throw std::runtime_error(std::string("Error reading properties: ") + std::string(fpgaErrStr(res)));
  }

  if (prop) {
    res = fpgaPropertiesGetBus(prop, &bus);
    if (res != FPGA_OK) {
      throw std::runtime_error(std::string("Error reading bus: ") + std::string(fpgaErrStr(res)));
    }
    res = fpgaPropertiesGetDevice(prop, &device);
    if (res != FPGA_OK) {
      throw std::runtime_error(std::string("Error reading device: ") + std::string(fpgaErrStr(res)));
    }
    res = fpgaPropertiesGetFunction(prop, &function);
    if (res != FPGA_OK) {
      throw std::runtime_error(std::string("Error reading function: ") + std::string(fpgaErrStr(res)));
    }
    fpgaDestroyProperties(&prop);
  }

  initialize_fme_sysfs();

  mmd_dev_name = get_board_name(BSP_NAME, obj_id);
  afu_initialized = true;
}

// Return true if board name parses correctly, false if it does not
// Return the parsed object_id in obj_id as an [out] parameter
bool CcipDevice::parse_board_name(const char *board_name_str, uint64_t &obj_id) {
  std::string prefix(BSP_NAME);
  std::string board_name(board_name_str);

  obj_id = 0;
  if (board_name.length() <= prefix.length() && board_name.compare(0, prefix.length(), prefix)) {
    LOG_ERR("Error parsing device name '%s'\n", board_name_str);
    return false;
  }

  std::string device_num_str = board_name.substr(prefix.length());
  obj_id = std::stol(device_num_str, 0, 16);

  // Assume that OPAE does not use 0 as a valid object ID. This is true for now
  // but relies somewhat on an implementaion dependent feature.
  assert(obj_id > 0);
  return true;
}

// Read information directly from sysfs.  This is non-portable and relies on
// paths set in driver (will not interoperate between DFH driver in up-stream
// kernel and Intel driver distributed with PAC cards).  In the future hopefully
// OPAE can provide SDK to read this information
void CcipDevice::initialize_fme_sysfs() {
  const int MAX_LEN = 250;
  char temp_fmepath[MAX_LEN];
  char numa_path[MAX_LEN];

  // HACK: currently ObjectID is constructed using its lower 20 bits
  // as the device minor number.  The device minor number also matches
  // the device ID in sysfs.  This is a simple way to construct a path
  // to the device FME using information that is already available (object_id).
  // Eventually this code should be replaced with a direct call to OPAE C API,
  // but API does not currently expose the device temperature.
  int dev_num = 0xFFFFF & fpga_obj_id;

  // Path to temperature value
  snprintf(temp_fmepath,
           MAX_LEN,
           "/sys/class/fpga/intel-fpga-dev.%d/intel-fpga-fme.%d/thermal_mgmt/temperature",
           dev_num,
           dev_num);
  // Path to NUMA node
  snprintf(numa_path, MAX_LEN, "/sys/class/fpga/intel-fpga-dev.%d/device/numa_node", dev_num);

  // Try to open the sysfs file. If open succeeds then set as initialized
  // to be able to read temperature in future.  If open fails then not
  // initalized and skip attempt to read temperature in future.
  FILE *tmp;
  tmp = fopen(temp_fmepath, "r");
  if (tmp) {
    fme_sysfs_temp_path = std::string(temp_fmepath);
    fme_sysfs_temp_initialized = true;
    fclose(tmp);
  }

  // Read NUMA node and set value for future use. If not available set to -1
  // and disable use of NUMA setting
  std::ifstream sysfs_numa_node(numa_path, std::ifstream::in);
  if (sysfs_numa_node.is_open()) {
    sysfs_numa_node >> fpga_numa_node;
    sysfs_numa_node.close();
    if (std::stoi(fpga_numa_node) >= 0) {
      enable_set_numa = true;
    } else {
      enable_set_numa = false;
    }
  } else {
    enable_set_numa = false;
    fpga_numa_node = "-1";
  }
}

bool CcipDevice::find_dma_dfh_offsets() {
  uint64_t dfh_offset = 0;
  uint64_t next_dfh_offset = 0;
  if (find_dfh_by_guid(afc_handle, MSGDMA_BBB_GUID, &dfh_offset, &next_dfh_offset)) {
    dma_ch0_dfh_offset = dfh_offset;
    DEBUG_PRINT("DMA CH1 offset: 0x%lX\t GUID: %s\n", dma_ch0_dfh_offset, MSGDMA_BBB_GUID);
  } else {
    fprintf(stderr, "Error initalizing DMA: Cannot find DMA channel 0 DFH offset\n");
    return false;
  }

  dfh_offset += next_dfh_offset;
  if (find_dfh_by_guid(afc_handle, MSGDMA_BBB_GUID, &dfh_offset, &next_dfh_offset)) {
    dma_ch1_dfh_offset = dfh_offset;
    DEBUG_PRINT("DMA CH2 offset: 0x%lX\t GUID: %s\n", dma_ch1_dfh_offset, MSGDMA_BBB_GUID);
  } else {
    fprintf(stderr, "Error initalizing DMA. Cannot find DMA channel 2 DFH offset\n");
    return false;
  }

  dfh_offset = 0;
  if (find_dfh_by_guid(afc_handle, MEM_WINDOW_BBB_GUID, &dfh_offset, &next_dfh_offset)) {
    dma_ase_dfh_offset = dfh_offset;
    DEBUG_PRINT("DMA ASE offset: 0x%lX\t GUID: %s\n", dma_ase_dfh_offset, MEM_WINDOW_BBB_GUID);
  } else {
    fprintf(stderr, "Error initalizing DMA. Cannot find ASE DFH offset\n");
    return false;
  }

  assert(dma_ch0_dfh_offset != 0);
  assert(dma_ch1_dfh_offset != 0);
  assert(dma_ase_dfh_offset != 0);
  assert(dma_ch0_dfh_offset != dma_ch1_dfh_offset);

  return true;
}

bool CcipDevice::initialize_bsp() {
  if (bsp_initialized) {
    return true;
  }

  fpga_result res = fpgaMapMMIO(afc_handle, 0, NULL);
  if (res != FPGA_OK) {
    LOG_ERR("Error mapping MMIO space: %s\n", fpgaErrStr(res));
    return false;
  }
  mmio_is_mapped = true;

  /* Reset AFC */
  res = fpgaReset(afc_handle);
  if (res != FPGA_OK) {
    LOG_ERR("Error resetting AFC: %s\n", fpgaErrStr(res));
    return false;
  }
  AFU_RESET_DELAY();

  // DMA performance is heavily dependent on the memcpy operation that transfers
  // data from user allocated buffer to the pinned buffer that is used for
  // DMA.  On some machines with multiple NUMA nodes it is critical for performance
  // that the pinned buffer is located on the NUMA node as the threads that
  // performs the DMA operation.
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

  find_dma_dfh_offsets();

  const int dma_ch0_interrupt_num = 0;  // DMA channel 0 hardcoded to interrupt 0
  dma_host_to_fpga = new mmd_dma(afc_handle, mmd_handle, dma_ch0_dfh_offset, dma_ase_dfh_offset, dma_ch0_interrupt_num);
  if (!dma_host_to_fpga->initialized()) {
    LOG_ERR("Error initializing mmd dma\n");
    delete dma_host_to_fpga;
    return false;
  }

  const int dma_ch1_interrupt_num = 2;  // DMA channel 1 hardcoded to interrupt 2
  dma_fpga_to_host = new mmd_dma(afc_handle, mmd_handle, dma_ch1_dfh_offset, dma_ase_dfh_offset, dma_ch1_interrupt_num);
  if (!dma_fpga_to_host->initialized()) {
    fprintf(stderr, "Error initializing mmd dma\n");
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

  kernel_interrupt_thread = new KernelInterrupt(afc_handle, mmd_handle);

  if (!kernel_interrupt_thread->initialized()) {
    LOG_ERR("Error initializing kernel interrupts\n");
    delete kernel_interrupt_thread;
    return false;
  }

  bsp_initialized = true;
  return bsp_initialized;
}

CcipDevice::~CcipDevice() {
  int num_errors = 0;
  if (mmd_copy_buffer) {
    free(mmd_copy_buffer);
    mmd_copy_buffer = NULL;
  }

  if (kernel_interrupt_thread) {
    delete kernel_interrupt_thread;
    kernel_interrupt_thread = NULL;
  }

  if (dma_host_to_fpga) {
    delete dma_host_to_fpga;
    dma_host_to_fpga = NULL;
  }

  if (dma_fpga_to_host) {
    delete dma_fpga_to_host;
    dma_fpga_to_host = NULL;
  }

  if (mmio_is_mapped) {
    if (fpgaUnmapMMIO(afc_handle, 0)) num_errors++;
  }

  if (afc_handle) {
    if (fpgaClose(afc_handle) != FPGA_OK) num_errors++;
  }

  if (afc_token) {
    if (fpgaDestroyToken(&afc_token) != FPGA_OK) num_errors++;
  }

  if (filter) {
    if (fpgaDestroyProperties(&filter) != FPGA_OK) num_errors++;
  }

  if (num_errors > 0) {
    DEBUG_PRINT("Error freeing resources in destructor\n");
  }
}

int CcipDevice::yield() {
  if (kernel_interrupt_thread) kernel_interrupt_thread->yield();
  return 0;
}

bool CcipDevice::bsp_loaded() {
  fpga_guid dcp_guid;
  fpga_guid afu_guid;
  fpga_properties prop;
  fpga_result res;

  if (uuid_parse(DCP_OPENCL_BSP_AFU_ID, dcp_guid) < 0) {
    LOG_ERR("Error parsing guid '%s'\n", DCP_OPENCL_BSP_AFU_ID);
    return false;
  }

  res = fpgaGetProperties(afc_token, &prop);
  if (res != FPGA_OK) {
    LOG_ERR("Error reading properties: %s\n", fpgaErrStr(res));
    fpgaDestroyProperties(&prop);
    return false;
  }

  res = fpgaPropertiesGetGUID(prop, &afu_guid);
  if (res != FPGA_OK) {
    LOG_ERR("Error reading GUID\n");
    fpgaDestroyProperties(&prop);
    return false;
  }

  fpgaDestroyProperties(&prop);
  if (uuid_compare(dcp_guid, afu_guid) == 0) {
    return true;
  } else {
    return false;
  }
}

std::string CcipDevice::get_bdf() {
  std::ostringstream bdf;
  bdf << std::setfill('0') << std::setw(2) << unsigned(bus) << ":" << std::setfill('0') << std::setw(2)
      << unsigned(device) << "." << unsigned(function);

  return bdf.str();
}

float CcipDevice::get_temperature() {
  float temp = 0;
  if (fme_sysfs_temp_initialized) {
    std::ifstream sysfs_temp(fme_sysfs_temp_path, std::ifstream::in);
    sysfs_temp >> temp;
    sysfs_temp.close();
  }
  return temp;
}

void CcipDevice::set_kernel_interrupt(aocl_mmd_interrupt_handler_fn fn, void *user_data) {
  if (kernel_interrupt_thread) {
    kernel_interrupt_thread->set_kernel_interrupt(fn, user_data);
  }
}

void CcipDevice::set_status_handler(aocl_mmd_status_handler_fn fn, void *user_data) {
  event_update = fn;
  event_update_user_data = user_data;
  dma_host_to_fpga->set_status_handler(fn, user_data);
  dma_fpga_to_host->set_status_handler(fn, user_data);
}

void CcipDevice::event_update_fn(aocl_mmd_op_t op, int status) {
  event_update(mmd_handle, event_update_user_data, op, status);
}

int CcipDevice::read_block(aocl_mmd_op_t op, int mmd_interface, void *host_addr, size_t offset, size_t size) {
  fpga_result res;

  // The mmd_interface is defined as the base address of the MMIO write.  Access
  // to memory requires special functionality.  Otherwise do direct MMIO read of
  // base address + offset
  if (mmd_interface == AOCL_MMD_MEMORY) {
    res = dma_fpga_to_host->read_memory(op, static_cast<uint64_t *>(host_addr), offset, size);
  } else {
    res = read_mmio(host_addr, mmd_interface + offset, size);

    if (op) {
      // TODO: check what status value should really be instead of just using 0
      // Also handle case when op is NULL
      this->event_update_fn(op, 0);
    }
  }

  if (res != FPGA_OK) {
    LOG_ERR("fpgaReadMMIO error: %s\n", fpgaErrStr(res));
    return -1;
  } else {
    return 0;
  }
}

int CcipDevice::write_block(aocl_mmd_op_t op, int mmd_interface, const void *host_addr, size_t offset, size_t size) {
  fpga_result res;

  // The mmd_interface is defined as the base address of the MMIO write.  Access
  // to memory requires special functionality.  Otherwise do direct MMIO write
  if (mmd_interface == AOCL_MMD_MEMORY) {
    res = dma_host_to_fpga->write_memory(op, static_cast<const uint64_t *>(host_addr), offset, size);
  } else {
    res = write_mmio(host_addr, mmd_interface + offset, size);

    if (op) {
      // TODO: check what 'status' value should really be.  Right now just
      // using 0 as was done in previous CCIP MMD.  Also handle case if op is NULL
      this->event_update_fn(op, 0);
    }
  }

  // TODO: check what status values aocl wants and also parse the result
  if (res != FPGA_OK) {
    LOG_ERR("fpgaWriteMMIO error: %s\n", fpgaErrStr(res));
    return -1;
  } else {
    return 0;
  }
}

fpga_result CcipDevice::read_mmio(void *host_addr, size_t mmio_addr, size_t size) {
  fpga_result res = FPGA_OK;

  DCP_DEBUG_MEM("read_mmio start: %p\t %lx\t %lu\n", host_addr, mmio_addr, size);

  // HACK: need extra delay for opencl sw reset
  if (mmio_addr == KERNEL_SW_RESET_BASE) OPENCL_SW_RESET_DELAY();

  uint64_t *host_addr64 = static_cast<uint64_t *>(host_addr);
  while (size >= 8) {
    res = fpgaReadMMIO64(afc_handle, 0, mmio_addr, host_addr64);
    if (res != FPGA_OK) return res;
    host_addr64 += 1;
    mmio_addr += 8;
    size -= 8;
  }

  uint32_t *host_addr32 = reinterpret_cast<uint32_t *>(host_addr64);
  while (size >= 4) {
    res = fpgaReadMMIO32(afc_handle, 0, mmio_addr, host_addr32);
    if (res != FPGA_OK) return res;
    host_addr32 += 1;
    mmio_addr += 4;
    size -= 4;
  }

  if (size > 0) {
    uint32_t read_data;
    res = fpgaReadMMIO32(afc_handle, 0, mmio_addr, &read_data);
    if (res != FPGA_OK) return res;
    memcpy_s_fast(host_addr32, size, &read_data, size);
  }

  return res;
}

fpga_result CcipDevice::write_mmio(const void *host_addr, size_t mmio_addr, size_t size) {
  fpga_result res = FPGA_OK;

  DEBUG_PRINT("write_mmio\n");

  // HACK: need extra delay for opencl sw reset
  if (mmio_addr == KERNEL_SW_RESET_BASE) OPENCL_SW_RESET_DELAY();

  const uint64_t *host_addr64 = static_cast<const uint64_t *>(host_addr);
  while (size >= 8) {
    res = fpgaWriteMMIO64(afc_handle, 0, mmio_addr, *host_addr64);
    if (res != FPGA_OK) return res;
    host_addr64 += 1;
    mmio_addr += 8;
    size -= 8;
  }

  const uint32_t *host_addr32 = reinterpret_cast<const uint32_t *>(host_addr64);
  while (size > 0) {
    uint32_t tmp_data32 = 0;
    size_t chunk_size = (size >= 4) ? 4 : size;
    memcpy_s_fast(&tmp_data32, sizeof(tmp_data32), host_addr32, chunk_size);
    res = fpgaWriteMMIO32(afc_handle, 0, mmio_addr, tmp_data32);
    if (res != FPGA_OK) return res;
    host_addr32 += 1;
    mmio_addr += chunk_size;
    size -= chunk_size;
  }

  return res;
}

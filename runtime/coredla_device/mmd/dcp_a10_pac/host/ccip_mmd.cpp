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

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <zlib.h>

#include <cassert>
#include <iomanip>
#include <iostream>
#include <map>
#include <sstream>

#ifdef DLA_MMD
#include <chrono>
#include <thread>
#endif

#include <safe_string/safe_string.h>
#include "memcpy_s_fast.h"

#include "aocl_mmd.h"
#include "ccip_mmd_device.h"

using namespace intel_opae_mmd;

#define ACL_DCP_ERROR_IF(COND, NEXT, ...)  \
  do {                                     \
    if (COND) {                            \
      printf("\nMMD ERROR: " __VA_ARGS__); \
      fflush(stdout);                      \
      NEXT;                                \
    }                                      \
  } while (0)

#define ACL_PKG_SECTION_DCP_GBS_GZ ".acl.gbs.gz"

// If the MMD is loaded dynamically, destructors in the MMD will execute before the destructors in the runtime
// upon program termination. The DeviceMapManager guards accesses to the device/handle maps to make sure
// the runtime doesn't get to reference them after MMD destructors have been called.
// Destructor makes sure that all devices are closed at program termination regardless of what the runtime does.
// Implemented as a singleton.
class DeviceMapManager final {
 public:
  typedef std::map<int, CcipDevice*> t_handle_to_dev_map;
  typedef std::map<uint64_t, int> t_id_to_handle_map;

  static const int SUCCESS = 0;
  static const int FAILURE = -1;

  // Returns handle and device pointer to the device with the specified name
  // Creates a new entry for this device if it doesn't already exist
  // Return 0 on success, -1 on failure
  int get_or_create_device(const char* board_name, int* handle, CcipDevice** device);

  // Return obj id based on BSP name.
  uint64_t id_from_name(const char* board_name);

  // Return MMD handle based on obj id. Returned value is negative if board doesn't exist
  inline int handle_from_id(uint64_t obj_id);

  // Return pointer to CCIP device based on MMD handle. Returned value is null if board doesn't exist
  CcipDevice* device_from_handle(int handle);

  // Closes specified device if it exists
  void close_device_if_exists(int handle);

  // Returns a reference to the class singleton
  static DeviceMapManager& get_instance() {
    static DeviceMapManager instance;
    return instance;
  }

  DeviceMapManager(DeviceMapManager const&) = delete;
  void operator=(DeviceMapManager const&) = delete;
  ~DeviceMapManager() {
    // delete all allocated CcipDevice* entries
    while (handle_to_dev_map->size() > 0) {
      int handle = handle_to_dev_map->begin()->first;
      aocl_mmd_close(handle);
    }
    delete handle_to_dev_map;
    delete id_to_handle_map;
    handle_to_dev_map = nullptr;
    id_to_handle_map = nullptr;
  }

 private:
  DeviceMapManager() {
    handle_to_dev_map = new t_handle_to_dev_map();
    id_to_handle_map = new t_id_to_handle_map();
  }
  t_handle_to_dev_map* handle_to_dev_map = nullptr;
  t_id_to_handle_map* id_to_handle_map = nullptr;
};
static DeviceMapManager& device_manager = DeviceMapManager::get_instance();

int DeviceMapManager::get_or_create_device(const char* board_name, int* handle, CcipDevice** device) {
  int _handle = CCIP_MMD_INVALID_PARAM;
  CcipDevice* _device = nullptr;

  if (id_to_handle_map == nullptr || handle_to_dev_map == nullptr) {
    return DeviceMapManager::FAILURE;
  }

  uint64_t obj_id = id_from_name(board_name);
  if (id_to_handle_map->count(obj_id) == 0) {
    try {
      _device = new CcipDevice(obj_id);
      _handle = _device->get_mmd_handle();
      id_to_handle_map->insert({obj_id, _handle});
      handle_to_dev_map->insert({_handle, _device});
    } catch (std::runtime_error& e) {
      LOG_ERR("%s\n", e.what());
      delete _device;
      return DeviceMapManager::FAILURE;
    }
  } else {
    _handle = id_to_handle_map->at(obj_id);
    _device = handle_to_dev_map->at(_handle);
  }

  (*handle) = _handle;
  (*device) = _device;
  return DeviceMapManager::SUCCESS;
}

uint64_t DeviceMapManager::id_from_name(const char* board_name) {
  uint64_t obj_id = 0;
  if (CcipDevice::parse_board_name(board_name, obj_id)) {
    return obj_id;
  } else {
    // TODO: add error hanlding for DeviceMapManager (make sure 0 is marked as invalid device)
    return 0;
  }
}

inline int DeviceMapManager::handle_from_id(uint64_t obj_id) {
  int handle = CCIP_MMD_INVALID_PARAM;
  if (id_to_handle_map) {
    auto it = id_to_handle_map->find(obj_id);
    if (it != id_to_handle_map->end()) {
      handle = it->second;
    }
  }
  return handle;
}

CcipDevice* DeviceMapManager::device_from_handle(int handle) {
  CcipDevice* dev = nullptr;
  if (handle_to_dev_map) {
    auto it = handle_to_dev_map->find(handle);
    if (it != handle_to_dev_map->end()) {
      return it->second;
    }
  }
  return dev;
}

void DeviceMapManager::close_device_if_exists(int handle) {
  if (handle_to_dev_map) {
    if (handle_to_dev_map->count(handle) > 0) {
      CcipDevice* dev = handle_to_dev_map->at(handle);
      uint64_t obj_id = dev->get_fpga_obj_id();
      delete dev;
      handle_to_dev_map->erase(handle);
      id_to_handle_map->erase(obj_id);
    }
  }
}

// Interface for checking if AFU has BSP loaded
bool ccip_mmd_bsp_loaded(const char* name) {
  uint64_t obj_id = device_manager.id_from_name(name);
  if (!obj_id) {
    return false;
  }

  int handle = device_manager.handle_from_id(obj_id);
  if (handle > 0) {
    CcipDevice* dev = device_manager.device_from_handle(handle);
    if (dev)
      return dev->bsp_loaded();
    else
      return false;
  } else {
    bool bsp_loaded = false;
    try {
      CcipDevice dev(obj_id);
      bsp_loaded = dev.bsp_loaded();
    } catch (std::runtime_error& e) {
      LOG_ERR("%s\n", e.what());
      return false;
    }
    return bsp_loaded;
  }
}

static int get_offline_num_acl_boards(bool bsp_only = true) {
  fpga_guid dcp_guid;
  fpga_result res = FPGA_OK;
  uint32_t num_matches = 0;
  bool ret_err = false;
  fpga_properties filter = NULL;

  if (uuid_parse(DCP_OPENCL_BSP_AFU_ID, dcp_guid) < 0) {
    LOG_ERR("Error parsing guid '%s'\n", DCP_OPENCL_BSP_AFU_ID);
    ret_err = true;
    goto out;
  }

  res = fpgaGetProperties(NULL, &filter);
  if (res != FPGA_OK) {
    LOG_ERR("Error creating properties object: %s\n", fpgaErrStr(res));
    ret_err = true;
    goto out;
  }

  if (bsp_only) {
    res = fpgaPropertiesSetGUID(filter, dcp_guid);
    if (res != FPGA_OK) {
      LOG_ERR("Error setting GUID: %s\n", fpgaErrStr(res));
      ret_err = true;
      goto out;
    }
  }

  res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
  if (res != FPGA_OK) {
    LOG_ERR("Error setting object type: %s\n", fpgaErrStr(res));
    ret_err = true;
    goto out;
  }

  res = fpgaEnumerate(&filter, 1, NULL, 0, &num_matches);
  if (res != FPGA_OK) {
    LOG_ERR("Error enumerating AFCs: %s\n", fpgaErrStr(res));
    ret_err = true;
    goto out;
  }

out:
  if (filter) fpgaDestroyProperties(&filter);

  if (ret_err) {
    return CCIP_MMD_AOCL_ERR;
  } else {
    return num_matches;
  }
}

bool static get_offline_board_names(std::string& boards, bool bsp_only = true) {
  fpga_guid dcp_guid;
  fpga_result res = FPGA_OK;
  uint32_t num_matches = 0;
  fpga_properties filter = nullptr;
  fpga_properties prop = nullptr;
  std::ostringstream board_name;
  fpga_token* toks = nullptr;
  uint64_t obj_id;
  bool success = true;

  if (uuid_parse(DCP_OPENCL_BSP_AFU_ID, dcp_guid) < 0) {
    LOG_ERR("Error parsing guid '%s'\n", DCP_OPENCL_BSP_AFU_ID);
    success = false;
    goto cleanup;
  }

  res = fpgaGetProperties(NULL, &filter);
  if (res != FPGA_OK) {
    LOG_ERR("Error creating properties object: %s\n", fpgaErrStr(res));
    success = false;
    goto cleanup;
  }

  res = fpgaPropertiesSetObjectType(filter, FPGA_ACCELERATOR);
  if (res != FPGA_OK) {
    LOG_ERR("Error setting object type: %s\n", fpgaErrStr(res));
    success = false;
    goto cleanup;
  }

  if (bsp_only) {
    res = fpgaPropertiesSetGUID(filter, dcp_guid);
    if (res != FPGA_OK) {
      LOG_ERR("Error setting GUID: %s\n", fpgaErrStr(res));
      success = false;
      goto cleanup;
    }
  }
  res = fpgaEnumerate(&filter, 1, NULL, 0, &num_matches);
  if (res != FPGA_OK) {
    LOG_ERR("Error enumerating AFCs: %s\n", fpgaErrStr(res));
    success = false;
    goto cleanup;
  }

  toks = static_cast<fpga_token*>(calloc(num_matches, sizeof(fpga_token)));
  if (toks == NULL) {
    LOG_ERR("Error allocating memory\n");
    success = false;
    goto cleanup;
  }

  res = fpgaEnumerate(&filter, 1, toks, num_matches, &num_matches);
  if (res != FPGA_OK) {
    LOG_ERR("Error enumerating AFCs: %s\n", fpgaErrStr(res));
    success = false;
    goto cleanup;
  }

  for (unsigned int i = 0; i < num_matches; i++) {
    if (prop) fpgaDestroyProperties(&prop);
    res = fpgaGetProperties(toks[i], &prop);
    if (res == FPGA_OK) {
      res = fpgaPropertiesGetObjectID(prop, &obj_id);
      if (res != FPGA_OK) {
        LOG_ERR("Error reading object ID: %s\n", fpgaErrStr(res));
        success = false;
        break;
      }
      boards.append(CcipDevice::get_board_name(BSP_NAME, obj_id));
      if (i < num_matches - 1) boards.append(";");
    } else {
      success = false;
      LOG_ERR("Error reading properties: %s\n", fpgaErrStr(res));
    }
  }

cleanup:
  if (prop) {
    fpgaDestroyProperties(&prop);
  }
  if (filter) {
    fpgaDestroyProperties(&filter);
  }
  if (toks) {
    for (unsigned i = 0; i < num_matches; i++) {
      if (toks[i]) {
        fpgaDestroyToken(&toks[i]);
      }
    }
    free(toks);
  }

  return success;
}

int aocl_mmd_yield(int handle) {
  DEBUG_PRINT("* Called: aocl_mmd_yield\n");
  YIELD_DELAY();

  CcipDevice* dev = device_manager.device_from_handle(handle);
  assert(dev);
  if (dev) {
    return dev->yield();
  }

  return 0;
}

// Macros used for acol_mmd_get_offline_info and aocl_mmd_get_info
#define RESULT_INT(X)                                  \
  {                                                    \
    *((int*)param_value) = X;                          \
    if (param_size_ret) *param_size_ret = sizeof(int); \
  }
#define RESULT_STR(X)                                                        \
  do {                                                                       \
    unsigned Xlen = strlen(X) + 1;                                           \
    unsigned Xcpylen = (param_value_size <= Xlen) ? param_value_size : Xlen; \
    memcpy_s_fast((void*)param_value, param_value_size, X, Xcpylen);         \
    if (param_size_ret) *param_size_ret = Xcpylen;                           \
  } while (0)

int aocl_mmd_get_offline_info(aocl_mmd_offline_info_t requested_info_id,
                              size_t param_value_size,
                              void* param_value,
                              size_t* param_size_ret) {
  // aocl_mmd_get_offline_info can be called many times by the runtime
  // and it is expensive to query the system.  Only compute values first
  // time aocl_mmd_get_offline_info called future iterations use saved results
  static bool initialized = false;
  static int mem_type_info;
  static int num_acl_boards;
  static std::string boards;
  static bool success;

  if (!initialized) {
    mem_type_info = (int)AOCL_MMD_PHYSICAL_MEMORY;
    num_acl_boards = get_offline_num_acl_boards();
    success = get_offline_board_names(boards, true);
    initialized = true;
  }

  switch (requested_info_id) {
    case AOCL_MMD_VERSION:
      RESULT_STR(AOCL_MMD_VERSION_STRING);
      break;
    case AOCL_MMD_NUM_BOARDS: {
      if (num_acl_boards >= 0) {
        RESULT_INT(num_acl_boards);
      } else {
        return CCIP_MMD_AOCL_ERR;
      }
      break;
    }
    case AOCL_MMD_VENDOR_NAME:
      RESULT_STR("Intel Corp");
      break;
    case AOCL_MMD_BOARD_NAMES: {
      if (success) {
        RESULT_STR(boards.c_str());
      } else {
        return CCIP_MMD_AOCL_ERR;
      }
      break;
    }
    case AOCL_MMD_VENDOR_ID:
      RESULT_INT(0);
      break;
    case AOCL_MMD_USES_YIELD:
      RESULT_INT(KernelInterrupt::yield_is_enabled());
      break;
    case AOCL_MMD_MEM_TYPES_SUPPORTED:
      RESULT_INT(mem_type_info);
      break;
  }

  return 0;
}

int ccip_mmd_get_offline_board_names(size_t param_value_size, void* param_value, size_t* param_size_ret) {
  std::string boards;
  bool success = get_offline_board_names(boards, false);
  if (success) {
    RESULT_STR(boards.c_str());
  } else {
    RESULT_INT(-1);
  }

  return 0;
}

int aocl_mmd_get_info(
    int handle, aocl_mmd_info_t requested_info_id, size_t param_value_size, void* param_value, size_t* param_size_ret) {
  DEBUG_PRINT("called aocl_mmd_get_info\n");
  CcipDevice* dev = device_manager.device_from_handle(handle);
  if (dev == NULL) return 0;

  assert(param_value);
  switch (requested_info_id) {
    case AOCL_MMD_BOARD_NAME: {
      std::ostringstream board_name;
      board_name << "Intel PAC Platform"
                 << " (" << dev->get_dev_name() << ")";
      RESULT_STR(board_name.str().c_str());
      break;
    }
    case AOCL_MMD_NUM_KERNEL_INTERFACES:
      RESULT_INT(1);
      break;
    case AOCL_MMD_KERNEL_INTERFACES:
      RESULT_INT(AOCL_MMD_KERNEL);
      break;
#ifdef SIM
    case AOCL_MMD_PLL_INTERFACES:
      RESULT_INT(-1);
      break;
#else
    case AOCL_MMD_PLL_INTERFACES:
      RESULT_INT(-1);
      break;
#endif
    case AOCL_MMD_MEMORY_INTERFACE:
      RESULT_INT(AOCL_MMD_MEMORY);
      break;
    case AOCL_MMD_PCIE_INFO: {
      RESULT_STR(dev->get_bdf().c_str());
      break;
    }
    case AOCL_MMD_BOARD_UNIQUE_ID:
      RESULT_INT(0);
      break;
    case AOCL_MMD_TEMPERATURE: {
      if (param_value_size == sizeof(float)) {
        float* ptr = static_cast<float*>(param_value);
        *ptr = dev->get_temperature();
        if (param_size_ret) *param_size_ret = sizeof(float);
      }
      break;
    }
    case AOCL_MMD_CONCURRENT_READS:
      RESULT_INT(1);
      break;
    case AOCL_MMD_CONCURRENT_WRITES:
      RESULT_INT(1);
      break;
    case AOCL_MMD_CONCURRENT_READS_OR_WRITES:
      RESULT_INT(2);
      break;
    // Undefined MMD characteristics.
    default:
      return -1;
  }
  return 0;
}

#undef RESULT_INT
#undef RESULT_STR

int aocl_mmd_set_interrupt_handler(int handle, aocl_mmd_interrupt_handler_fn fn, void* user_data) {
  CcipDevice* dev = device_manager.device_from_handle(handle);
  if (dev) {
    dev->set_kernel_interrupt(fn, user_data);
  } else {
    return CCIP_MMD_AOCL_ERR;
  }
  return 0;
}

int aocl_mmd_set_status_handler(int handle, aocl_mmd_status_handler_fn fn, void* user_data) {
  CcipDevice* dev = device_manager.device_from_handle(handle);
  if (dev) dev->set_status_handler(fn, user_data);
  // TODO: handle error condition if dev null
  return 0;
}

// Host to device-global-memory write
int aocl_mmd_write(int handle, aocl_mmd_op_t op, size_t len, const void* src, int mmd_interface, size_t offset) {
  DCP_DEBUG_MEM("\n- aocl_mmd_write: %d\t %p\t %lu\t %p\t %d\t %lu\n", handle, op, len, src, mmd_interface, offset);
  CcipDevice* dev = device_manager.device_from_handle(handle);
  if (dev)
    return dev->write_block(op, mmd_interface, src, offset, len);
  else
    return -1;
  // TODO: handle error condition if dev null
}

int aocl_mmd_read(int handle, aocl_mmd_op_t op, size_t len, void* dst, int mmd_interface, size_t offset) {
  DCP_DEBUG_MEM("\n+ aocl_mmd_read: %d\t %p\t %lu\t %p\t %d\t %lu\n", handle, op, len, dst, mmd_interface, offset);
  CcipDevice* dev = device_manager.device_from_handle(handle);
  if (dev)
    return dev->read_block(op, mmd_interface, dst, offset, len);
  else
    return -1;
  // TODO: handle error condition if dev null
}

int aocl_mmd_open(const char* name) {
  DEBUG_PRINT("Opening device: %s\n", name);

  uint64_t obj_id = device_manager.id_from_name(name);
  if (!obj_id) {
    return CCIP_MMD_INVALID_PARAM;
  }

  int handle;
  CcipDevice* dev = nullptr;
  if (device_manager.get_or_create_device(name, &handle, &dev) != DeviceMapManager::SUCCESS) {
    delete dev;
    return CCIP_MMD_AOCL_ERR;
  }

  assert(dev);
  if (dev->bsp_loaded()) {
    if (!dev->initialize_bsp()) {
      LOG_ERR("Error initializing bsp\n");
      return CCIP_MMD_BSP_INIT_FAILED;
    }
  } else {
    return CCIP_MMD_BSP_NOT_LOADED;
  }

  return handle;
}

int aocl_mmd_close(int handle) {
  device_manager.close_device_if_exists(handle);

  return 0;
}

// CoreDLA modifications
// To support multiple different FPGA boards, anything board specific must be implemented in a
// board-specific MMD instead of the CoreDLA runtime layer.
#ifdef DLA_MMD
// Query functions to get board-specific values
AOCL_MMD_CALL int dla_mmd_get_max_num_instances() { return 2; }
AOCL_MMD_CALL uint64_t dla_mmd_get_ddr_size_per_instance() { return 1ULL << 32; }
AOCL_MMD_CALL double dla_mmd_get_ddr_clock_freq() { return 266.666667; }  // MHz

// Helper functions for the wrapper functions around CSR and DDR
uint64_t dla_get_raw_csr_address(int instance, uint64_t addr) { return 0x38000 + (0x1000 * instance) + addr; }
uint64_t dla_get_raw_ddr_address(int instance, uint64_t addr) { return (1ULL << 32) * instance + addr; }

// Wrappers around CSR and DDR reads and writes to abstract away board-specific offsets
AOCL_MMD_CALL int dla_mmd_csr_write(int handle, int instance, uint64_t addr, const uint32_t* data) {
  return aocl_mmd_write(handle, NULL, sizeof(uint32_t), data, AOCL_MMD_KERNEL, dla_get_raw_csr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_csr_read(int handle, int instance, uint64_t addr, uint32_t* data) {
  return aocl_mmd_read(handle, NULL, sizeof(uint32_t), data, AOCL_MMD_KERNEL, dla_get_raw_csr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_ddr_write(int handle, int instance, uint64_t addr, uint64_t length, const void* data) {
  return aocl_mmd_write(handle, NULL, length, data, AOCL_MMD_MEMORY, dla_get_raw_ddr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_ddr_read(int handle, int instance, uint64_t addr, uint64_t length, void* data) {
  return aocl_mmd_read(handle, NULL, length, data, AOCL_MMD_MEMORY, dla_get_raw_ddr_address(instance, addr));
}

// Get the PLL clock frequency in MHz, returns a negative value if there is an error
AOCL_MMD_CALL double dla_mmd_get_coredla_clock_freq(int handle) {
  constexpr uint64_t hw_timer_address = 0x37000;
  const uint32_t start_bit = 1;
  const uint32_t stop_bit = 2;

  // Send the start command to the hardware counter
  std::chrono::high_resolution_clock::time_point time_before = std::chrono::high_resolution_clock::now();
  int status = aocl_mmd_write(handle, NULL, sizeof(uint32_t), &start_bit, AOCL_MMD_KERNEL, hw_timer_address);
  assert(status == 0);

  // Unlikely to sleep for exactly 10 milliseconds, but it doesn't matter since we use a high resolution clock to
  // determine the amount of time between the start and stop commands for the hardware counter
  std::this_thread::sleep_for(std::chrono::milliseconds(10));

  // Send the stop command to the hardware counter
  std::chrono::high_resolution_clock::time_point time_after = std::chrono::high_resolution_clock::now();
  status = aocl_mmd_write(handle, NULL, sizeof(uint32_t), &stop_bit, AOCL_MMD_KERNEL, hw_timer_address);
  assert(status == 0);

  // Read back the value of the counter
  uint32_t counter = 0;
  status = aocl_mmd_read(handle, NULL, sizeof(uint32_t), &counter, AOCL_MMD_KERNEL, hw_timer_address);
  assert(status == 0);

  // Calculate the clock frequency of the counter, which is running on clk_dla
  double elapsed_seconds = std::chrono::duration_cast<std::chrono::duration<double>>(time_after - time_before).count();
  return 1.0e-6 * counter / elapsed_seconds;  // 1.0e-6 is to convert to MHz
}

#endif

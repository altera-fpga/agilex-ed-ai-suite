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

/* ===- HPS.cpp  ------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) HPS MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the functions that are defined in aocl_mmd.h               */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "acl_hps.h"

// other standard header files
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include <memory>
#include <map>
#include <sstream>
#include <string>
#include <utility>

#include "mmd_device.h"

#ifdef DLA_MMD
#include <chrono>
#include <thread>
#endif

#if defined(LINUX)
#include <fcntl.h>
#include <semaphore.h>
#include <signal.h>
#include <unistd.h>
#endif  // LINUX

#define MAX_HPS_FPGA_DEVICES (1)


#ifndef DLA_MMD
// static helper functions
static bool blob_has_elf_signature(void *data, size_t data_size);
#endif


// Function to return the number of boards installed in the system
unsigned int get_offline_num_boards() {
  board_names names = mmd_get_devices(MAX_HPS_FPGA_DEVICES);
  return (unsigned int)names.size();
}

// Get information about the board using the enum aocl_mmd_offline_info_t for
// offline info (called without a handle), and the enum aocl_mmd_info_t for
// info specific to a certain board.
#define RESULT_INT(X)                                  \
  {                                                    \
    *((int *)param_value) = X;                         \
    if (param_size_ret) *param_size_ret = sizeof(int); \
  }
#define RESULT_UNSIGNED(X)                                  \
  {                                                         \
    *((unsigned *)param_value) = X;                         \
    if (param_size_ret) *param_size_ret = sizeof(unsigned); \
  }
#define RESULT_SIZE_T(X)                                  \
  {                                                       \
    *((size_t *)param_value) = X;                         \
    if (param_size_ret) *param_size_ret = sizeof(size_t); \
  }
#if defined(WINDOWS)
#define RESULT_STR(X)                                                                                         \
  do {                                                                                                        \
    size_t Xlen = strnlen(X, MAX_NAME_SIZE) + 1;                                                              \
    memcpy_s((void *)param_value, param_value_size, X, (param_value_size <= Xlen) ? param_value_size : Xlen); \
    if (param_size_ret) *param_size_ret = Xlen;                                                               \
  } while (0)
#else
#define RESULT_STR(X)                                                                     \
  do {                                                                                    \
    size_t Xlen = strnlen(X, MAX_NAME_SIZE) + 1;                                          \
    memcpy((void *)param_value, X, (param_value_size <= Xlen) ? param_value_size : Xlen); \
    if (param_size_ret) *param_size_ret = Xlen;                                           \
  } while (0)
#endif
#define ACL_VENDOR_NAME "Intel"
int aocl_mmd_get_offline_info(aocl_mmd_offline_info_t requested_info_id,
                              size_t param_value_size,
                              void *param_value,
                              size_t *param_size_ret) {
  unsigned int num_boards;
  switch (requested_info_id) {
    case AOCL_MMD_VERSION:
      RESULT_STR(MMD_VERSION);
      break;
    case AOCL_MMD_NUM_BOARDS: {
      num_boards = MAX_HPS_FPGA_DEVICES;
      RESULT_INT((int)num_boards);
      break;
    }
    case AOCL_MMD_BOARD_NAMES: {
      // Retrieve all the CoreDLA cores in the system
      board_names names = mmd_get_devices(MAX_HPS_FPGA_DEVICES);
      // Construct a list of all possible devices supported by this MMD layer
      std::ostringstream board;
      auto name = names.begin();
      while(name != names.end() )
      {
        board << *name;
        name++;
        if( name != names.end() )
        {
          board << ";";
        }
      }

      RESULT_STR(board.str().c_str());
      break;
    }
    case AOCL_MMD_VENDOR_NAME: {
      RESULT_STR(ACL_VENDOR_NAME);
      break;
    }
    case AOCL_MMD_VENDOR_ID:
      RESULT_INT(0);
      break;
    case AOCL_MMD_USES_YIELD:
      RESULT_INT(0); /* TODO: Can we yield? */
      break;
    case AOCL_MMD_MEM_TYPES_SUPPORTED:
      RESULT_INT(AOCL_MMD_PHYSICAL_MEMORY); /* TODO: Confirm this is the right memory type */
      break;
  }
  return 0;
}

// If the MMD is loaded dynamically, destructors in the MMD will execute before the destructors in the runtime
// upon program termination. The DeviceMapManager guards accesses to the device/handle maps to make sure
// the runtime doesn't get to reference them after MMD destructors have been called.
// Destructor makes sure that all devices are closed at program termination regardless of what the runtime does.
// Implemented as a singleton.
class DeviceMapManager final {
public:
  typedef std::map<int, mmd_device_ptr> map_handle_to_dev_t;
  ~DeviceMapManager()
  {
  }

  int add_device(const char *name)
  {
    int handle = idx++;

    mmd_device_ptr spDevice = std::make_shared<mmd_device>(name, handle);
    if( spDevice->bValid() )
    {
      auto it = handle_to_dev.find(handle);
      HPS_ERROR_IF( it != handle_to_dev.end(), return FAILURE, "Error: Handle already used.\n" );
      handle_to_dev.insert({handle, spDevice});
      return handle;
    }
    return FAILURE;
  }

  mmd_device_ptr get_device(const int handle)
  {
    auto it = handle_to_dev.find(handle);
    HPS_ERROR_IF( it == handle_to_dev.end(), return nullptr, "Error: Invalid handle.\n" );
    return it->second;
  }

  bool remove_device(const int handle)
  {
    auto it = handle_to_dev.find(handle);
    HPS_ERROR_IF( it == handle_to_dev.end(), return false, "Error: Handle does not exist.\n" );
    handle_to_dev.erase(it);
    return true;
  }

  DeviceMapManager()
  {
  }
private:
  map_handle_to_dev_t handle_to_dev = {};
  int                 idx = {0};
};
static DeviceMapManager _gDeviceMapManager;

int aocl_mmd_get_info(
  int handle, aocl_mmd_info_t requested_info_id, size_t param_value_size, void *param_value, size_t *param_size_ret) {
  HPS_ERROR_IF(true,
                    return FAILURE,
                    "aocl_mmd_get_info not supported on platform. \n");
}

#undef RESULT_INT
#undef RESULT_STR


// Open and initialize the named device.
int AOCL_MMD_CALL aocl_mmd_open(const char *name) {
  return _gDeviceMapManager.add_device(name);
}

// Close an opened device, by its handle.
int AOCL_MMD_CALL aocl_mmd_close(int handle) {
  if ( _gDeviceMapManager.remove_device(handle) )
    return SUCCESS;
  return FAILURE;
}

// Set the interrupt handler for the opened device.
int AOCL_MMD_CALL aocl_mmd_set_interrupt_handler(int handle, aocl_mmd_interrupt_handler_fn fn, void *user_data) {
  mmd_device_ptr spDevice = _gDeviceMapManager.get_device(handle);
  if( nullptr == spDevice ) {
    return FAILURE;
  }
  return spDevice->set_interrupt_handler(fn, user_data);
}

// Set the device interrupt handler for the opened device.
int AOCL_MMD_CALL aocl_mmd_set_device_interrupt_handler(int handle,
                                                        aocl_mmd_device_interrupt_handler_fn fn,
                                                        void *user_data) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  return -1;
}

// Set the operation status handler for the opened device.
int AOCL_MMD_CALL aocl_mmd_set_status_handler(int handle, aocl_mmd_status_handler_fn fn, void *user_data) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
 return -1;
}

// Called when the host is idle and hence possibly waiting for events to be
// processed by the device
int AOCL_MMD_CALL aocl_mmd_yield(int handle)
{
      printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  return -1;
}

// Read, write and copy operations on a single interface.
int AOCL_MMD_CALL aocl_mmd_read(int handle, aocl_mmd_op_t op, size_t len, void *dst, int mmd_interface, size_t offset) {
  mmd_device_ptr spDevice = _gDeviceMapManager.get_device(handle);
  if( nullptr == spDevice ) {
    return FAILURE;
  }
  return spDevice->read_block(op, mmd_interface, dst, offset, len);
}

int AOCL_MMD_CALL
aocl_mmd_write(int handle, aocl_mmd_op_t op, size_t len, const void *src, int mmd_interface, size_t offset) {
  mmd_device_ptr spDevice = _gDeviceMapManager.get_device(handle);
  if( nullptr == spDevice ) {
    return FAILURE;
  }
  return spDevice->write_block(op, mmd_interface, src, offset, len);
}

int AOCL_MMD_CALL
aocl_mmd_copy(int handle, aocl_mmd_op_t op, size_t len, int mmd_interface, size_t src_offset, size_t dst_offset) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return -1;
}

// Initialize host channel specified in channel_name
int AOCL_MMD_CALL aocl_mmd_hostchannel_create(int handle, char *channel_name, size_t queue_depth, int direction) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return -1;
}

// reset the host channel specified with channel handle
int AOCL_MMD_CALL aocl_mmd_hostchannel_destroy(int handle, int channel) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return -1;
}

// Get the pointer to buffer the user can write/read from the kernel with
AOCL_MMD_CALL void *aocl_mmd_hostchannel_get_buffer(int handle, int channel, size_t *buffer_size, int *status) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return NULL;
}

// Acknolwedge from the user that they have written/read send_size amount of buffer obtained from get_buffer
size_t AOCL_MMD_CALL aocl_mmd_hostchannel_ack_buffer(int handle, int channel, size_t send_size, int *status) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return -1;
}

#ifdef DLA_MMD
// Reprogram the device given the sof file name
int AOCL_MMD_CALL aocl_mmd_program_sof(int handle, const char *sof_filename) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* We don't support reprogramming the SOF on a HPS device */
  return -1;
}
#else
// Reprogram the device based on the program mode
int AOCL_MMD_CALL aocl_mmd_program(int handle, void *data, size_t data_size, aocl_mmd_program_mode_t program_mode) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* We don't support reprogramming the SOF on a HPS device */
  return -1;
}
#endif
// Shared memory allocator
AOCL_MMD_CALL void *aocl_mmd_shared_mem_alloc(int handle, size_t size, unsigned long long *device_ptr_out) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return NULL;
}

// Shared memory de-allocator
AOCL_MMD_CALL void aocl_mmd_shared_mem_free(int handle, void *host_ptr, size_t size) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  /* Not called by CoreDLA, so not implementing */
  return;
}

#ifndef DLA_MMD
// This function checks if the input data has an ELF-formatted blob.
// Return true when it does.
static bool blob_has_elf_signature(void *data, size_t data_size) {
  bool result = false;
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  if (data && data_size > 4) {
    unsigned char *cdata = (unsigned char *)data;
    const unsigned char elf_signature[4] = {0177, 'E', 'L', 'F'};  // Little endian
    result = (cdata[0] == elf_signature[0]) && (cdata[1] == elf_signature[1]) && (cdata[2] == elf_signature[2]) &&
             (cdata[3] == elf_signature[3]);
  }
  return result;
}
#endif

// Return a positive number when single device open. Otherwise, return -1
AOCL_MMD_CALL int get_open_handle() {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  return -1;
}

AOCL_MMD_CALL void *aocl_mmd_host_alloc(int *handles,
                                        size_t num_devices,
                                        size_t size,
                                        size_t alignment,
                                        aocl_mmd_mem_properties_t *properties,
                                        int *error) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  // Not supported on this BSP
  return NULL;
}

AOCL_MMD_CALL int aocl_mmd_free(void *mem) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  // Not supported on this BSP
  return 0;
}

AOCL_MMD_CALL void *aocl_mmd_device_alloc(
    int handle, size_t size, size_t alignment, aocl_mmd_mem_properties_t *properties, int *error) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  // Not supported on this BSP
  return NULL;
}

AOCL_MMD_CALL void *aocl_mmd_shared_alloc(
    int handle, size_t size, size_t alignment, aocl_mmd_mem_properties_t *properties, int *error) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  // Not supported on this BSP
  return NULL;
}

AOCL_MMD_CALL int aocl_mmd_shared_migrate(int handle, void *shared_ptr, size_t size, aocl_mmd_migrate_t destination) {
    printf("%s:%s:%d\n", __FILE__, __PRETTY_FUNCTION__, __LINE__);
  // Not supported on this BSP
  return 0;
}

#ifdef DLA_MMD
// Query functions to get board-specific values
AOCL_MMD_CALL int dla_mmd_get_max_num_instances()
{
  return 1;
}

AOCL_MMD_CALL uint64_t dla_mmd_get_ddr_size_per_instance() {
#if defined HPS_AGX3
  return 1ULL << 31; // 2GB DDR
#elif defined HPS_AGX5
  return 1ULL << 32; // 4GB DDR
#else
  return 1ULL << 29; // 512MB DDR - need to revisit for Agilex 7 and S10 - HW is set for 1GB
#endif
}

// AGX7 HPS board uses 333.3325 MHz (1333.33/4) for the DLA DDR Clock
// AGX5 HPS board uses 200 MHz
// All other boards use 266.666667 MHz (1066.66666/4)
AOCL_MMD_CALL double dla_mmd_get_ddr_clock_freq() {
#if defined HPS_AGX7
  return 333.332500;
#elif defined HPS_AGX5
  return 200;
#else
  return 266.666667;
#endif
}  // MHz

// Helper functions for the wrapper functions around CSR and DDR
uint64_t dla_get_raw_csr_address(int instance, uint64_t addr) {
  return (0x1000 * instance) + addr;
}
uint64_t dla_get_raw_ddr_address(int instance, uint64_t addr) {
  return addr;
}

// Wrappers around CSR and DDR reads and writes to abstract away board-specific offsets
AOCL_MMD_CALL int dla_mmd_csr_write(int handle, int instance, uint64_t addr, const uint32_t *data) {
  return aocl_mmd_write(
      handle, NULL, sizeof(uint32_t), data, HPS_MMD_COREDLA_CSR_HANDLE, dla_get_raw_csr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_csr_read(int handle, int instance, uint64_t addr, uint32_t *data) {
  return aocl_mmd_read(
      handle, NULL, sizeof(uint32_t), data, HPS_MMD_COREDLA_CSR_HANDLE, dla_get_raw_csr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_ddr_write(int handle, int instance, uint64_t addr, uint64_t length, const void *data) {
  return aocl_mmd_write(handle, NULL, length, data, HPS_MMD_MEMORY_HANDLE, dla_get_raw_ddr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_ddr_read(int handle, int instance, uint64_t addr, uint64_t length, void *data) {
  return aocl_mmd_read(handle, NULL, length, data, HPS_MMD_MEMORY_HANDLE, dla_get_raw_ddr_address(instance, addr));
}

#ifdef STREAM_CONTROLLER_ACCESS
AOCL_MMD_CALL bool dla_is_stream_controller_valid(int handle, int instance) {
  mmd_device_ptr spDevice = _gDeviceMapManager.get_device(handle);
  if( nullptr == spDevice ) {
    return FAILURE;
  }
  return spDevice->bStreamControllerValid();
}

AOCL_MMD_CALL int dla_mmd_stream_controller_write(int handle, int instance, uint64_t addr, uint64_t length, const void *data) {
  return aocl_mmd_write(handle, NULL, length, data, HPS_MMD_STREAM_CONTROLLER_HANDLE, addr);
}

AOCL_MMD_CALL int dla_mmd_stream_controller_read(int handle, int instance, uint64_t addr, uint64_t length, void* data) {
  return aocl_mmd_read(
      handle, NULL, length, data, HPS_MMD_STREAM_CONTROLLER_HANDLE, addr);
}
#endif

AOCL_MMD_CALL double dla_mmd_get_coredla_clock_freq(int handle) {
#if defined HPS_AGX7 || defined HPS_AGX3
  return 400;
#elif defined HPS_AGX5
  return 300;
#else
  return 200;
#endif
}

#endif

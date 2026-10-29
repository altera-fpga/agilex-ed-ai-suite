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

/* ===- acl_pcie.cpp  ------------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         Intel(R) OpenCL MMD Driver                                */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the functions that are defined in aocl_mmd.h               */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "acl_pcie.h"

// other header files inside MMD driver
#include "acl_pcie_debug.h"
#include "acl_pcie_device.h"
#include "hw_pcie_constants.h"
#ifndef DLA_MMD
#include "acl_check_sys_cmd.h"
#endif

// other standard header files
#include <stdarg.h>
#include <stdlib.h>
#include <string.h>

#include <map>
#include <sstream>
#include <string>
#include <utility>

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

// MAX size of line read from pipe-ing the output of system call to MMD
#define BUF_SIZE 1024
// MAX size of command passed to system for invoking system call from MMD
#define SYSTEM_CMD_SIZE 4 * 1024

#ifndef DLA_MMD
// static helper functions
static bool blob_has_elf_signature(void *data, size_t data_size);
#endif

// global variables used for handling multi-devices and its helper functions
// Use a DeviceMapManager to manage a heap-allocated map for storing device information
// instead of using a static global map because of a segmentation fault which occurs in
// the following situation:
// 1) Host program contains a global variable which calls clReleaseContext in its destructor.
//    When the program ends the global goes out of scope and the destructor is called.
// 2) clReleaseContext calls a function in the MMD library which modifies the static global map in
//    the MMD library.
// In this situation it was discovered that the destructor of the static global map is called before
// the destructor of the global in the host program, thus resulting in a segmentation fault when
// clReleaseContext calls a function that modifies the internal map after it has been destroyed.
// Using a heap-allocated map avoids this issue as the lifetime of the map persists until it is
// deleted or the process is completely terminated.
class DeviceMapManager {
 public:
  typedef std::pair<const std::string, ACL_PCIE_DEVICE *> DeviceInfo;
  typedef std::map<int, DeviceInfo> DeviceMap;

  static inline bool empty() { return !s_device_map; }

  // Returns the underlying device map. The map must not be empty when this is called.
  static inline const DeviceMap &get_device_map() {
    ACL_PCIE_ASSERT(s_device_map, "no devices are open  -- aborting\n");
    return *s_device_map;
  }

  // Returns the device info associated with the given handle. The handle must exist.
  static inline const DeviceInfo &get_pcie_device_info(int handle) { return get_device_it_for_handle(handle)->second; }

  // Returns the device associated with the given handle. The handle must exist.
  static inline ACL_PCIE_DEVICE *get_pcie_device(int handle) { return get_pcie_device_info(handle).second; }

  // Adds a device with the specified name for the given handle. If a device with the same handle already exists
  // it is discarded first. The caller must ensure they don't associate the same device with multiple handles.
  static inline void add_pcie_device_handle(int handle, const std::string &name, ACL_PCIE_DEVICE *dev) {
    // To avoid memory leaks ensure that only this function ever allocates a new device map because
    // we only ever delete the map when the size of the map goes from non-empty to empty.
    if (!s_device_map) s_device_map = new DeviceMap();

    if (s_device_map->count(handle)) discard_pcie_device_handle(handle);
    s_device_map->insert(std::pair<int, DeviceInfo>(handle, DeviceInfo(name, dev)));
  }

  // Removes the device associated with the given handle. The handle must exist.
  static inline void discard_pcie_device_handle(int handle) {
    DeviceMap::iterator it = get_device_it_for_handle(handle);

    delete it->second.second;
    s_device_map->erase(it);
    if (s_device_map->empty()) {
      // From a functional perspective the map can remain allocated for
      // the entire lifetime the MMD is loaded but there
      // is no other good place to clean it up except here.
      delete s_device_map;
      s_device_map = NULL;
    }
  }

  // Removes all devices.
  static inline void discard_all_pcie_device_handles() {
    if (!s_device_map) return;

    for (DeviceMapManager::DeviceMap::iterator it = s_device_map->begin(); it != s_device_map->end(); ++it) {
      delete it->second.second;
    }

    delete s_device_map;
    s_device_map = NULL;
  }

  // Returns true if any device is currently being programmed.
  static inline bool is_any_device_being_programmed() {
    if (!s_device_map) return false;

    for (DeviceMap::iterator it = s_device_map->begin(); it != s_device_map->end(); ++it) {
      if (it->second.second->is_being_programmed()) {
        return true;
      }
    }
    return false;
  }

 private:
  static inline DeviceMap::iterator get_device_it_for_handle(int handle) {
    ACL_PCIE_ASSERT(s_device_map, "can't find handle %d -- aborting\n", handle);
    DeviceMap::iterator it = s_device_map->find(handle);
    ACL_PCIE_ASSERT(it != s_device_map->end(), "can't find handle %d -- aborting\n", handle);
    return it;
  }

  static DeviceMap *s_device_map;
};
DeviceMapManager::DeviceMap *DeviceMapManager::s_device_map = NULL;

static int test_device_exception_signal_number = 63;

// Functions for handling interrupts or signals for multiple devices
// This functions are used inside the ACL_PCIE_DEVICE class
#if defined(WINDOWS)
void pcie_interrupt_handler(void *data) {
  ACL_PCIE_DEVICE *device = static_cast<ACL_PCIE_DEVICE *>(data);
  device->service_interrupt();
}

BOOL ctrl_c_handler(DWORD fdwCtrlType) {
  if (fdwCtrlType != CTRL_C_EVENT) return FALSE;

  if (DeviceMapManager::is_any_device_being_programmed()) {
    ACL_PCIE_INFO("The device is still being programmed, cannot terminate at this point.\n");
    return TRUE;
  }

  // On Windows, the signal handle function is executed by another thread,
  // so we cannot simply free all the open devices.
  // Just exit when received a ctrl-c event, the OS will take care of the clean-up.
  exit(1);
}
#endif  // WINDOWS
#if defined(LINUX)
// On Linux, driver will send a SIG_INT_NOTIFY *signal* to notify about an interrupt.
void pcie_linux_signal_handler(int sig, siginfo_t *info, void *unused) {
  // test_device_exception_signal_number is reserved for device exception testing
  if (sig == test_device_exception_signal_number) {
    ACL_PCIE_ERROR_IF(DeviceMapManager::get_device_map().empty(),
                      return,
                      "No devices available to trigger test_device_exception_signal_number on.\n");
    // Pick the last (most recent) handle for device exception testing
    unsigned int handle = DeviceMapManager::get_device_map().rbegin()->first;
    DeviceMapManager::get_pcie_device(handle)->test_trigger_device_interrupt();
  } else {
    // the last bit indicates the DMA completion
    unsigned int irq_type_flag = info->si_int & 0x1;
    // other bits shows the handle value of the device that sent the interrupt
    unsigned int handle = info->si_int >> 1;
    if (DeviceMapManager::empty() || !DeviceMapManager::get_device_map().count(handle)) {
      ACL_PCIE_DEBUG_MSG(":: received an unknown handle %d in signal handler, ignore this.\n", handle);
      return;
    }

    DeviceMapManager::get_pcie_device(handle)->service_interrupt(irq_type_flag);
  }
}

void ctrl_c_handler(int sig_num) {
  if (DeviceMapManager::is_any_device_being_programmed()) {
    ACL_PCIE_INFO("The device is still being programmed, cannot terminate at this point.\n");
    return;
  }

  // Free all the resource allocated for open devices before exiting the program.
  // It also notifies the kernel driver about the termination of the program,
  // so that the kernel driver won't try to talk to any user-allocated memory
  // space (mainly for the DMA) after the program exit.
  DeviceMapManager::discard_all_pcie_device_handles();
  exit(1);
}

void abort_signal_handler(int sig_num) {
  DeviceMapManager::discard_all_pcie_device_handles();
  exit(1);
}

int allocate_and_register_linux_signal_number_helper(int pid) {
  char buffer[4096], *locOfSigCgt;
  FILE *fp;
  int bytes_read, status, ret = -1;
  unsigned long long sigmask = 0;
  struct sigaction sigusr {}, sigabrt {};

  snprintf(buffer, sizeof(buffer), "/proc/%d/status", pid);
  fp = fopen(buffer, "rb");
  ACL_PCIE_ERROR_IF(fp == NULL, return -1, "Unable to open file %s\n", buffer);
  bytes_read = fread(buffer, sizeof(buffer[0]), sizeof(buffer) - 1, fp);
  fclose(fp);
  buffer[bytes_read] = 0;                   // null terminate the string
  locOfSigCgt = strstr(buffer, "SigCgt:");  // returns null if can't find, shouldn't happen
  ACL_PCIE_ERROR_IF(locOfSigCgt == NULL, return -1, "Did not find SigCgt: for PID %d\n", pid);
  sscanf(locOfSigCgt + 7, "%llx", &sigmask);

  // Find an unused signal number
  for (int i = SIGRTMAX; i >= SIGRTMIN; i--) {
    if (!((sigmask >> (i - 1)) & 1)) {
      ret = i;
      break;
    }
  }
  ACL_PCIE_ERROR_IF(ret == -1, return -1, "Unable to find an unused signal number\n");

  // Enable if driver is using signals to communicate with the host.
  sigusr.sa_sigaction = pcie_linux_signal_handler;
  sigusr.sa_flags = SA_SIGINFO;
  status = sigaction(ret, &sigusr, NULL);
  if (getenv("ACL_MMD_TEST_INTELFPGA")) {
    ACL_PCIE_ERROR_IF(((sigmask >> (test_device_exception_signal_number - 1)) & 1),
                      return -1,
                      "Signal number %i cannot be occupied\n",
                      test_device_exception_signal_number);
    status = sigaction(test_device_exception_signal_number, &sigusr, NULL);
  }
  ACL_PCIE_ERROR_IF(status != 0, return -1, "sigaction failed with status %d, signal number %d\n", status, ret);

  // Install signal handler for SIGABRT from assertions in the upper layers
  sigabrt.sa_handler = abort_signal_handler;
  sigemptyset(&sigabrt.sa_mask);
  sigabrt.sa_flags = 0;
  status = sigaction(SIGABRT, &sigabrt, NULL);
  ACL_PCIE_ERROR_IF(status != 0, return -1, "sigaction failed with status %d, signal number %d\n", status, SIGABRT);

  // if it makes it here, the user got an unused signal number and we installed all signal handlers
  return ret;
}

// returns an unused signal number, -1 means ran into some error
int allocate_and_register_linux_signal_number(pthread_mutex_t *mutex) {
  int pid = getpid();
  int err = pthread_mutex_lock(mutex);
  ACL_PCIE_ERROR_IF(err != 0, return -1, "pthread_mutex_lock error %d\n", err);

  // this has multiple return points, put in separate function so that we don't bypass releasing the mutex
  int ret = allocate_and_register_linux_signal_number_helper(pid);

  err = pthread_mutex_unlock(mutex);
  ACL_PCIE_ERROR_IF(err != 0, return -1, "pthread_mutex_unlock error %d\n", err);

  return ret;
}
#endif  // LINUX

// Function to install the signal handler for Ctrl-C
// If ignore_sig != 0, the ctrl-c signal will be ignored by the program
// If ignore_sig  = 0, the custom signal handler (ctrl_c_handler) will be used
int install_ctrl_c_handler(int ingore_sig) {
#if defined(WINDOWS)
  SetConsoleCtrlHandler((ingore_sig ? NULL : (PHANDLER_ROUTINE)ctrl_c_handler), TRUE);
#endif  // WINDOWS
#if defined(LINUX)
  struct sigaction sig;
  sig.sa_handler = (ingore_sig ? SIG_IGN : ctrl_c_handler);
  sigemptyset(&sig.sa_mask);
  sig.sa_flags = 0;
  sigaction(SIGINT, &sig, NULL);
#endif  // LINUX

  return 0;
}

// Function to return the number of boards installed in the system
unsigned int get_offline_num_boards() {
  unsigned int num_boards = 0;

  // These are for reading/parsing the environment variable
  const char *override_count_string = 0;
  long parsed_count;
  char *endptr;

// Windows MMD will try to open all the devices
#if defined(WINDOWS)
  fpga_result result;
  fpga_properties filter = NULL;

  result = fpgaGetProperties(NULL, &filter);
  if (result != FPGA_OK) {
    num_boards = ACL_MAX_DEVICE;
    ACL_PCIE_ERROR_IF(1, goto End, "failed to get properties.\n");
  }

  result = fpgaPropertiesSetObjectType(filter, FPGA_DEVICE);
  if (result != FPGA_OK) {
    num_boards = ACL_MAX_DEVICE;

    if (filter != NULL) fpgaDestroyProperties(&filter);

    ACL_PCIE_ERROR_IF(1, goto End, "failed to set object type.\n");
  }

  result = fpgaPropertiesSetVendorID(filter, ACL_PCI_INTELFPGA_VENDOR_ID);
  if (result != FPGA_OK) {
    num_boards = ACL_MAX_DEVICE;

    if (filter != NULL) fpgaDestroyProperties(&filter);

    ACL_PCIE_ERROR_IF(1, goto End, "failed to set vendor ID.\n");
  }

  result = fpgaEnumerate(&filter, 1, NULL, 1, &num_boards);
  if (result != FPGA_OK) {
    num_boards = ACL_MAX_DEVICE;

    if (filter != NULL) fpgaDestroyProperties(&filter);

    ACL_PCIE_ERROR_IF(1, goto End, "failed to scan for the PCI device.\n");
  }

  if (filter != NULL) fpgaDestroyProperties(&filter);

  if (num_boards == 0) {
    num_boards = ACL_MAX_DEVICE;
  }

End:
#endif  // WINDOWS

// Linux MMD will look into the number of devices
#if defined(LINUX)
  FILE *fp;
  char str_line_in[BUF_SIZE];
  char str_board_pkg_name[BUF_SIZE];
  char str_cmd[SYSTEM_CMD_SIZE];

  snprintf(str_board_pkg_name, sizeof(str_board_pkg_name), "acl%s", ACL_BOARD_PKG_NAME);
  snprintf(str_cmd, sizeof(str_cmd), "ls /sys/class/aclpci_%s 2>/dev/null", ACL_BOARD_PKG_NAME);

#ifndef DLA_MMD
  ACL_PCIE_ASSERT(system_cmd_is_valid(str_cmd), "Invalid popen() function parameter: %s\n", str_cmd);
#endif
  fp = popen(str_cmd, "r");

  if (fp == NULL) {
    ACL_PCIE_INFO("Couldn't open pipe stream\n");
    return false;
  }
  // Read every line from output
  while (fgets(str_line_in, BUF_SIZE, fp) != NULL) {
    if (strncmp(str_board_pkg_name, str_line_in, strnlen(str_board_pkg_name, sizeof(str_board_pkg_name))) == 0) {
      num_boards++;
    }
  }

  pclose(fp);

#endif  // LINUX

  override_count_string = getenv("CL_OVERRIDE_NUM_DEVICES_INTELFPGA");
  if (override_count_string) {
    endptr = 0;
    parsed_count = strtol(override_count_string, &endptr, 10);
    if (endptr == override_count_string  // no valid characters
        || *endptr                       // an invalid character
        || (parsed_count < 0 || parsed_count >= (long)ACL_MAX_DEVICE)) {
      // malformed override string, do nothing
    } else {
      // Was ok.
      num_boards = (unsigned int)parsed_count;
    }
  }

  return num_boards;
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
#define RESULT_STR(X)                                                                      \
  do {                                                                                     \
    *((char*)param_value) = '\0';                                                          \
    strncat((char*)param_value, X, param_value_size - 1);                                  \
    ((char*)param_value)[param_value_size - 1] = '\0';                                     \
    if (param_size_ret) *param_size_ret = strnlen((char*)param_value, param_value_size-1); \
  } while (0)

int aocl_mmd_get_offline_info(aocl_mmd_offline_info_t requested_info_id,
                              size_t param_value_size,
                              void *param_value,
                              size_t *param_size_ret) {
  // It might be helpful to cache the info if function aocl_mmd_get_offline_info is called frequently.
  unsigned int num_boards;
  switch (requested_info_id) {
    case AOCL_MMD_VERSION:
      RESULT_STR(MMD_VERSION);
      break;
    case AOCL_MMD_NUM_BOARDS: {
      num_boards = get_offline_num_boards();
      RESULT_INT((int)num_boards);
      break;
    }
    case AOCL_MMD_BOARD_NAMES: {
      // Construct a list of all possible devices supported by this MMD layer
      std::ostringstream boards;
      num_boards = get_offline_num_boards();
      for (unsigned i = 0; i < num_boards; i++) {
        boards << "acl" << ACL_BOARD_PKG_NAME << i;
        if (i < num_boards - 1) boards << ";";
      }
      RESULT_STR(boards.str().c_str());
      break;
    }
    case AOCL_MMD_VENDOR_NAME: {
      RESULT_STR(ACL_VENDOR_NAME);
      break;
    }
    case AOCL_MMD_VENDOR_ID:
      RESULT_INT(ACL_PCI_INTELFPGA_VENDOR_ID);
      break;
    case AOCL_MMD_USES_YIELD:
      RESULT_INT(0);
      break;
    case AOCL_MMD_MEM_TYPES_SUPPORTED:
      RESULT_INT(AOCL_MMD_PHYSICAL_MEMORY);
      break;
  }
  return 0;
}

int aocl_mmd_get_info(
    int handle, aocl_mmd_info_t requested_info_id, size_t param_value_size, void *param_value, size_t *param_size_ret) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(!pcie_dev->is_initialized(),
                    return -1,
                    "aocl_mmd_get_info failed due to the target device (handle %d) is not properly initialized.\n",
                    handle);

  switch (requested_info_id) {
    case AOCL_MMD_BOARD_NAME: {
      std::ostringstream board_name;
      board_name << ACL_BOARD_NAME << " (" << DeviceMapManager::get_pcie_device_info(handle).first << ")";
      RESULT_STR(board_name.str().c_str());
      break;
    }
    case AOCL_MMD_NUM_KERNEL_INTERFACES:
      RESULT_INT(1);
      break;
    case AOCL_MMD_KERNEL_INTERFACES:
      RESULT_INT(AOCL_MMD_KERNEL);
      break;
    case AOCL_MMD_PLL_INTERFACES:
      RESULT_INT(AOCL_MMD_PLL);
      break;
    case AOCL_MMD_MEMORY_INTERFACE:
      RESULT_INT(AOCL_MMD_MEMORY);
      break;
    case AOCL_MMD_PCIE_INFO:
      RESULT_STR(pcie_dev->get_dev_pcie_info());
      break;
    case AOCL_MMD_CONCURRENT_READS:
      RESULT_INT(1);
      break;
    case AOCL_MMD_CONCURRENT_WRITES:
      RESULT_INT(1);
      break;
    case AOCL_MMD_CONCURRENT_READS_OR_WRITES:
      RESULT_INT(1);
      break;
    case AOCL_MMD_MIN_HOST_MEMORY_ALIGNMENT:
      RESULT_SIZE_T(0);
      break;
    case AOCL_MMD_HOST_MEM_CAPABILITIES:
      RESULT_UNSIGNED(0);
      break;
    case AOCL_MMD_SHARED_MEM_CAPABILITIES:
      RESULT_UNSIGNED(0);
      break;
    case AOCL_MMD_DEVICE_MEM_CAPABILITIES:
      RESULT_UNSIGNED(0);
      break;
    case AOCL_MMD_HOST_MEM_CONCURRENT_GRANULARITY:
      RESULT_SIZE_T(0);
      break;
    case AOCL_MMD_SHARED_MEM_CONCURRENT_GRANULARITY:
      RESULT_SIZE_T(0);
      break;
    case AOCL_MMD_DEVICE_MEM_CONCURRENT_GRANULARITY:
      RESULT_SIZE_T(0);
      break;

    case AOCL_MMD_TEMPERATURE: {
      float *r;
      int temp;
      pcie_dev->get_ondie_temp_slow_call(&temp);
      r = (float *)param_value;
      *r = ACL_PCIE_TEMP_FORMULA;
      if (param_size_ret) *param_size_ret = sizeof(float);
      break;
    }

    // Query Terasic board information IP sensors
    case AOCL_MMD_POWER_IN_VOLTAGE:
    case AOCL_MMD_POWER_IN_CURRENT:
    case AOCL_MMD_CORE_VOLTAGE_CHANNEL1:
    case AOCL_MMD_CORE_CURRENT_CHANNEL1:
    case AOCL_MMD_CORE_VOLTAGE_CHANNEL2:
    case AOCL_MMD_CORE_CURRENT_CHANNLE2:
    case AOCL_MMD_FAN_SPEED1:
    case AOCL_MMD_FAN_SPEED2: {
      int temp;
      pcie_dev->get_terasic_sensor_reading(static_cast<acl_sensor_addr_t>(requested_info_id), &temp);
      float *r = (float *)param_value;
      *r= (float) temp;
      if (param_size_ret) *param_size_ret = sizeof(float);
      break;
    }
    case AOCL_MMD_FPGA_CORE_TEMPERATURE:
    case AOCL_MMD_BOARD_AMBIENT_TEMPERATURE1:
    case AOCL_MMD_BOARD_AMBIENT_TEMPERATURE2:
    case AOCL_MMD_ETILE_TEMPERATURE:
    case AOCL_MMD_PTILE_TEMPERATURE: {
      int temp;
      pcie_dev->get_terasic_sensor_reading(static_cast<acl_sensor_addr_t>(requested_info_id), &temp);
      float *r = (float *)param_value;
      *r = ACL_PCIE_TEMP_FORMULA;
      if (param_size_ret) *param_size_ret = sizeof(float);
      break;
    }

    // currently not supported
    case AOCL_MMD_BOARD_UNIQUE_ID:
      return -1;
    
    // Undefined MMD characteristics.
    default:
      return -1;
  }
  return 0;
}

#undef RESULT_INT
#undef RESULT_STR

// Open and initialize the named device.
int AOCL_MMD_CALL aocl_mmd_open(const char *name) {
  static int signal_handler_installed = 0;
  static int unique_id = 0;
  int dev_num = -1;
  static int user_signal_number = -1;
#if defined(LINUX)
  static pthread_mutex_t linux_signal_arb_mutex =
      PTHREAD_MUTEX_INITIALIZER;  // initializes as unlocked, static = no cleanup needed

  if (sscanf(name, "acl" ACL_BOARD_PKG_NAME "%d", &dev_num) != 1) {
    return -1;
  }
#endif  // LINUX

#if defined(WINDOWS)
  if (sscanf_s(name, "acl" ACL_BOARD_PKG_NAME "%d", &dev_num) != 1) {
    return -1;
  }
#endif
  if (dev_num < 0 || dev_num >= ACL_MAX_DEVICE) {
    return -1;
  }
  if (++unique_id <= 0) {
    unique_id = 1;
  }

  ACL_PCIE_ASSERT(DeviceMapManager::empty() || DeviceMapManager::get_device_map().count(unique_id) == 0,
                  "unique_id %d is used before.\n",
                  unique_id);

  if (signal_handler_installed == 0) {
#if defined(LINUX)
    user_signal_number = allocate_and_register_linux_signal_number(&linux_signal_arb_mutex);
    if (user_signal_number == -1) return -1;
#endif  // LINUX

    install_ctrl_c_handler(0 /* use the custom signal handler */);
    signal_handler_installed = 1;
  }

  ACL_PCIE_DEVICE *pcie_dev = NULL;

  try {
    pcie_dev = new ACL_PCIE_DEVICE(dev_num, name, unique_id, user_signal_number);
  }

  // Catch any memory allocation failures
  catch (std::bad_alloc &) {
    delete pcie_dev;
    return -1;
  }

  if (!pcie_dev->is_valid()) {
    delete pcie_dev;
    return -1;
  }

  DeviceMapManager::add_pcie_device_handle(unique_id, name, pcie_dev);
  if (pcie_dev->is_initialized()) {
    return unique_id;
  } else {
    // Perform a bitwise-not operation to the unique_id if the device
    // do not pass the initial test. This negative unique_id indicates
    // a fail to open the device, but still provide actual the unique_id
    // to allow reprogram executable to get access to the device and
    // reprogram the board when the board is not usable.
    return ~unique_id;
  }
}

// Close an opened device, by its handle.
int AOCL_MMD_CALL aocl_mmd_close(int handle) {
  DeviceMapManager::discard_pcie_device_handle(handle);

  return 0;
}

// Set the interrupt handler for the opened device.
int AOCL_MMD_CALL aocl_mmd_set_interrupt_handler(int handle, aocl_mmd_interrupt_handler_fn fn, void *user_data) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(
      !pcie_dev->is_initialized(),
      return -1,
      "aocl_mmd_set_interrupt_handler failed due to the target device (handle %d) is not properly initialized.\n",
      handle);

  return pcie_dev->set_kernel_interrupt(fn, user_data);
}

// Set the device interrupt handler for the opened device.
int AOCL_MMD_CALL aocl_mmd_set_device_interrupt_handler(int handle,
                                                        aocl_mmd_device_interrupt_handler_fn fn,
                                                        void *user_data) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(
      !pcie_dev->is_initialized(),
      return -1,
      "aocl_mmd_set_interrupt_handler failed due to the target device (handle %d) is not properly initialized.\n",
      handle);

  return pcie_dev->set_device_interrupt(fn, user_data);
}

// Set the operation status handler for the opened device.
int AOCL_MMD_CALL aocl_mmd_set_status_handler(int handle, aocl_mmd_status_handler_fn fn, void *user_data) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(
      !pcie_dev->is_initialized(),
      return -1,
      "aocl_mmd_set_status_handler failed due to the target device (handle %d) is not properly initialized.\n",
      handle);

  return pcie_dev->set_status_handler(fn, user_data);
}

// Called when the host is idle and hence possibly waiting for events to be
// processed by the device
int AOCL_MMD_CALL aocl_mmd_yield(int handle) { return DeviceMapManager::get_pcie_device(handle)->yield(); }

// Read, write and copy operations on a single interface.
int AOCL_MMD_CALL aocl_mmd_read(int handle, aocl_mmd_op_t op, size_t len, void *dst, int mmd_interface, size_t offset) {
  void *host_addr = dst;
  size_t dev_addr = offset;

  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(!pcie_dev->is_initialized(),
                    return -1,
                    "aocl_mmd_read failed due to the target device (handle %d) is not properly initialized.\n",
                    handle);

  return pcie_dev->read_block(op, (aocl_mmd_interface_t)mmd_interface, host_addr, dev_addr, len);
}

int AOCL_MMD_CALL
aocl_mmd_write(int handle, aocl_mmd_op_t op, size_t len, const void *src, int mmd_interface, size_t offset) {
  void *host_addr = const_cast<void *>(src);
  size_t dev_addr = offset;

  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(!pcie_dev->is_initialized(),
                    return -1,
                    "aocl_mmd_write failed due to the target device (handle %d) is not properly initialized.\n",
                    handle);

  return pcie_dev->write_block(op, (aocl_mmd_interface_t)mmd_interface, host_addr, dev_addr, len);
}

int AOCL_MMD_CALL
aocl_mmd_copy(int handle, aocl_mmd_op_t op, size_t len, int mmd_interface, size_t src_offset, size_t dst_offset) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(!pcie_dev->is_initialized(),
                    return -1,
                    "aocl_mmd_copy failed due to the target device (handle %d) is not properly initialized.\n",
                    handle);

  return pcie_dev->copy_block(op, (aocl_mmd_interface_t)mmd_interface, src_offset, dst_offset, len);
}

// Initialize host channel specified in channel_name
int AOCL_MMD_CALL aocl_mmd_hostchannel_create(int handle, char *channel_name, size_t queue_depth, int direction) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(
      !pcie_dev->is_initialized(),
      return -1,
      "aocl_mmd_create_hostchannel failed due to the target device (handle %d) is not properly initialized.\n",
      handle);

  return pcie_dev->create_hostchannel(channel_name, queue_depth, direction);
}

// reset the host channel specified with channel handle
int AOCL_MMD_CALL aocl_mmd_hostchannel_destroy(int handle, int channel) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(
      !pcie_dev->is_initialized(),
      return -1,
      "aocl_mmd_create_hostchannel failed due to the target device (handle %d) is not properly initialized.\n",
      handle);

  return pcie_dev->destroy_channel(channel);
}

// Get the pointer to buffer the user can write/read from the kernel with
AOCL_MMD_CALL void *aocl_mmd_hostchannel_get_buffer(int handle, int channel, size_t *buffer_size, int *status) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(!pcie_dev->is_initialized(),
                    return NULL,
                    "aocl_mmd_read failed due to the target device (handle %d) is not properly initialized.\n",
                    handle);

  return pcie_dev->hostchannel_get_buffer(buffer_size, channel, status);
}

// Acknolwedge from the user that they have written/read send_size amount of buffer obtained from get_buffer
size_t AOCL_MMD_CALL aocl_mmd_hostchannel_ack_buffer(int handle, int channel, size_t send_size, int *status) {
  ACL_PCIE_DEVICE *pcie_dev = DeviceMapManager::get_pcie_device(handle);
  ACL_PCIE_ERROR_IF(
      !pcie_dev->is_initialized(), *status = -1;
      return 0, "aocl_mmd_read failed due to the target device (handle %d) is not properly initialized.\n", handle);

  return pcie_dev->hostchannel_ack_buffer(send_size, channel, status);
}

#ifdef DLA_MMD

AOCL_MMD_CALL int aocl_mmd_save_pcie(int handle)
{
  auto ret = DeviceMapManager::get_pcie_device(handle)->pause_and_save_pcie();
  if (ret) {
    return -1;
  }
  return 0;
}
AOCL_MMD_CALL int aocl_mmd_restore_pcie(int handle)
{
  auto ret = DeviceMapManager::get_pcie_device(handle)->restore_and_resume_pcie();
  if (ret) {
    return -1;
  }
  return 0;
}
// Reprogram the device given the sof file name
int AOCL_MMD_CALL aocl_mmd_program_sof(int handle, const char *sof_filename, const bool skipSaveRestore) {
  if (DeviceMapManager::get_pcie_device(handle)->reprogram_sof(sof_filename, skipSaveRestore))
  {
    return -1;
  }
  return 0;
}
#else
// Reprogram the device based on the program mode
int AOCL_MMD_CALL aocl_mmd_program(int handle, void *data, size_t data_size, aocl_mmd_program_mode_t program_mode) {
  // assuming the an ELF-formatted blob.
  if (!blob_has_elf_signature(data, data_size)) {
    ACL_PCIE_DEBUG_MSG("ad hoc fpga bin\n");
    return -1;
  }

  // program the device based on the certain mode
  if (program_mode & AOCL_MMD_PROGRAM_PRESERVE_GLOBAL_MEM) {
    if (DeviceMapManager::get_pcie_device(handle)->reprogram(data, data_size, ACL_PCIE_PROGRAM_PR)) return -1;
    return handle;
  } else {
    if (DeviceMapManager::get_pcie_device(handle)->reprogram(data, data_size, ACL_PCIE_PROGRAM_JTAG)) return -1;
    // Re-open the device to reinitialize hardware
    const std::string device_name = DeviceMapManager::get_pcie_device_info(handle).first;
    DeviceMapManager::discard_pcie_device_handle(handle);

    return aocl_mmd_open(device_name.c_str());
  }
}
#endif
// Shared memory allocator
AOCL_MMD_CALL void *aocl_mmd_shared_mem_alloc(int handle, size_t size, unsigned long long *device_ptr_out) {
  return DeviceMapManager::get_pcie_device(handle)->shared_mem_alloc(size, device_ptr_out);
}

// Shared memory de-allocator
AOCL_MMD_CALL void aocl_mmd_shared_mem_free(int handle, void *host_ptr, size_t size) {
  DeviceMapManager::get_pcie_device(handle)->shared_mem_free(host_ptr, size);
}

#ifndef DLA_MMD
// This function checks if the input data has an ELF-formatted blob.
// Return true when it does.
static bool blob_has_elf_signature(void *data, size_t data_size) {
  bool result = false;
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
  if (DeviceMapManager::empty() || DeviceMapManager::get_device_map().size() != 1) {
    return -1;
  }
  return DeviceMapManager::get_device_map().begin()->first;
}

AOCL_MMD_CALL void *aocl_mmd_host_alloc(int *handles,
                                        size_t num_devices,
                                        size_t size,
                                        size_t alignment,
                                        aocl_mmd_mem_properties_t *properties,
                                        int *error) {
  // Not supported on this BSP
  return NULL;
}

AOCL_MMD_CALL int aocl_mmd_free(void *mem) {
  // Not supported on this BSP
  return 0;
}

AOCL_MMD_CALL void *aocl_mmd_device_alloc(
    int handle, size_t size, size_t alignment, aocl_mmd_mem_properties_t *properties, int *error) {
  // Not supported on this BSP
  return NULL;
}

AOCL_MMD_CALL void *aocl_mmd_shared_alloc(
    int handle, size_t size, size_t alignment, aocl_mmd_mem_properties_t *properties, int *error) {
  // Not supported on this BSP
  return NULL;
}

AOCL_MMD_CALL int aocl_mmd_shared_migrate(int handle, void *shared_ptr, size_t size, aocl_mmd_migrate_t destination) {
  // Not supported on this BSP
  return 0;
}

#ifdef DLA_MMD
// Query functions to get board-specific values
AOCL_MMD_CALL int dla_mmd_get_max_num_instances() { return 4; }
AOCL_MMD_CALL uint64_t dla_mmd_get_ddr_size_per_instance() { return 1ULL << 32; }
AOCL_MMD_CALL double dla_mmd_get_ddr_clock_freq() { return 333.333333; }  // MHz

// Helper functions for the wrapper functions around CSR and DDR
uint64_t dla_get_raw_csr_address(int instance, uint64_t addr) { return 0x38000 + (0x1000 * instance) + addr; }
uint64_t dla_get_raw_ddr_address(int instance, uint64_t addr) { return (1ULL << 33) * instance + addr; }

// Wrappers around CSR and DDR reads and writes to abstract away board-specific offsets
AOCL_MMD_CALL int dla_mmd_csr_write(int handle, int instance, uint64_t addr, const uint32_t *data) {
  return aocl_mmd_write(
      handle, NULL, sizeof(uint32_t), data, ACL_MMD_KERNEL_HANDLE, dla_get_raw_csr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_csr_read(int handle, int instance, uint64_t addr, uint32_t *data) {
  return aocl_mmd_read(
      handle, NULL, sizeof(uint32_t), data, ACL_MMD_KERNEL_HANDLE, dla_get_raw_csr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_ddr_write(int handle, int instance, uint64_t addr, uint64_t length, const void *data) {
  return aocl_mmd_write(handle, NULL, length, data, ACL_MMD_MEMORY_HANDLE, dla_get_raw_ddr_address(instance, addr));
}
AOCL_MMD_CALL int dla_mmd_ddr_read(int handle, int instance, uint64_t addr, uint64_t length, void *data) {
  return aocl_mmd_read(handle, NULL, length, data, ACL_MMD_MEMORY_HANDLE, dla_get_raw_ddr_address(instance, addr));
}

// Get the PLL clock frequency in MHz, returns a negative value if there is an error
AOCL_MMD_CALL double dla_mmd_get_coredla_clock_freq(int handle) {
  constexpr uint64_t hw_timer_address = 0x37000;
  const uint32_t start_bit = 1;
  const uint32_t stop_bit = 2;

  // Send the start command to the hardware counter
  std::chrono::high_resolution_clock::time_point time_before = std::chrono::high_resolution_clock::now();
  int status = aocl_mmd_write(handle, NULL, sizeof(uint32_t), &start_bit, ACL_MMD_KERNEL_HANDLE, hw_timer_address);
  assert(status == 0);

  // Unlikely to sleep for exactly 10 milliseconds, but it doesn't matter since we use a high resolution clock to
  // determine the amount of time between the start and stop commands for the hardware counter
  std::this_thread::sleep_for(std::chrono::milliseconds(10));

  // Send the stop command to the hardware counter
  std::chrono::high_resolution_clock::time_point time_after = std::chrono::high_resolution_clock::now();
  status = aocl_mmd_write(handle, NULL, sizeof(uint32_t), &stop_bit, ACL_MMD_KERNEL_HANDLE, hw_timer_address);
  assert(status == 0);

  // Read back the value of the counter
  uint32_t counter = 0;
  status = aocl_mmd_read(handle, NULL, sizeof(uint32_t), &counter, ACL_MMD_KERNEL_HANDLE, hw_timer_address);
  assert(status == 0);

  // Calculate the clock frequency of the counter, which is running on clk_dla
  double elapsed_seconds = std::chrono::duration_cast<std::chrono::duration<double>>(time_after - time_before).count();
  return 1.0e-6 * counter / elapsed_seconds;  // 1.0e-6 is to convert to MHz
}

#endif

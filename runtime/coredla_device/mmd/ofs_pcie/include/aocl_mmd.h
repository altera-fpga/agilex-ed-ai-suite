// Copyright 2022 Intel Corporation
// SPDX-License-Identifier: MIT

#ifndef AOCL_MMD_H
#define AOCL_MMD_H

/* TODO: this file comes from OpenCL SDK and should be formatted there first */
/* clang-format off */

#ifdef __cplusplus
#include <cstddef>  //size_t
#include <cstdint>
#else
#include <stddef.h> //size_t
#include <stdint.h>
#endif

#ifdef __cplusplus
extern "C" {
#endif

/* Support for memory mapped ACL devices.
 *
 * Typical API lifecycle, from the perspective of the caller.
 *
 *    1. aocl_mmd_open must be called first, to provide a handle for further
 *    operations.
 *
 *    2. The interrupt and status handlers must be set.
 *
 *    3. Read and write operations are performed.
 *
 *    4. aocl_mmd_close may be called to shut down the device. No further
 *    operations are permitted until a subsequent aocl_mmd_open call.
 *
 * aocl_mmd_get_offline_info can be called anytime including before
 * open. aocl_mmd_get_info can be called anytime between open and close.
 */

// #ifndef AOCL_MMD_CALL
// #if defined(_WIN32)
// #define AOCL_MMD_CALL __declspec(dllimport)
// #else
// #define AOCL_MMD_CALL
// #endif
// #endif

#ifndef AOCL_MMD_CALL
#if defined(_WIN32)
#define AOCL_MMD_CALL __declspec(dllimport)
#else
#define AOCL_MMD_CALL __attribute__((visibility ("default")))
#endif
#endif

#ifndef WEAK
#if defined(_WIN32)
#define WEAK
#else
#define WEAK __attribute__((weak))
#endif
#endif

/* The MMD API's version - the runtime expects this string when
 * AOCL_MMD_VERSION is queried. This changes only if the API has changed */
#define AOCL_MMD_VERSION_STRING "20.3"

/* Memory types that can be supported - bitfield. Other than physical memory
 * these types closely align with the OpenCL SVM types.
 *
 * AOCL_MMD_PHYSICAL_MEMORY - The vendor interface includes IP to communicate
 * directly with physical memory such as DDR, QDR, etc.
 *
 * AOCL_MMD_SVM_COARSE_GRAIN_BUFFER - The vendor interface includes support for
 * caching SVM pointer data and requires explicit function calls from the user
 * to synchronize the cache between the host processor and the FPGA. This level
 * of SVM is not currently supported by Altera except as a subset of
 * SVM_FINE_GAIN_SYSTEM support.
 *
 * AOCL_MMD_SVM_FINE_GRAIN_BUFFER - The vendor interface includes support for
 * caching SVM pointer data and requires additional information from the user
 * and/or host runtime that can be collected during pointer allocation in order
 * to synchronize the cache between the host processor and the FPGA. Once this
 * additional data is provided for an SVM pointer, the vendor interface handles
 * cache synchronization between the host processor & the FPGA automatically.
 * This level of SVM is not currently supported by Altera except as a subset
 * of SVM_FINE_GRAIN_SYSTEM support.
 *
 * AOCL_MMD_SVM_FINE_GRAIN_SYSTEM - The vendor interface includes support for
 * caching SVM pointer data and does not require any additional information to
 * synchronize the cache between the host processor and the FPGA. The vendor
 * interface handles cache synchronization between the host processor & the
 * FPGA automatically for all SVM pointers. This level of SVM support is
 * currently under development by Altera and some features may not be fully
 * supported.
 */
#define AOCL_MMD_PHYSICAL_MEMORY (1 << 0)
#define AOCL_MMD_SVM_COARSE_GRAIN_BUFFER (1 << 1)
#define AOCL_MMD_SVM_FINE_GRAIN_BUFFER (1 << 2)
#define AOCL_MMD_SVM_FINE_GRAIN_SYSTEM (1 << 3)

/* program modes - bitfield
 *
 * AOCL_MMD_PROGRAM_PRESERVE_GLOBAL_MEM - preserve contents of global memory
 * when this bit is set to 1. If programming can't occur without preserving
 * global memory contents, the program function must fail, in which case the
 * runtime may re-invoke program with this bit set to 0, allowing programming
 * to occur even if doing so destroys global memory contents.
 *
 * more modes are reserved for stacking on in the future
 */
#define AOCL_MMD_PROGRAM_PRESERVE_GLOBAL_MEM (1 << 0)
typedef int aocl_mmd_program_mode_t;


typedef void* aocl_mmd_op_t;

typedef struct {
   unsigned lo; /* 32 least significant bits of time value. */
   unsigned hi; /* 32 most significant bits of time value. */
} aocl_mmd_timestamp_t;


/* Defines the set of characteristics that can be probed about the board before
 * opening a device. The type of data returned by each is specified in
 * parentheses in the adjacent comment.
 *
 * AOCL_MMD_NUM_BOARDS and AOCL_MMD_BOARD_NAMES
 *   These two fields can be used to implement multi-device support. The MMD
 *   layer may have a list of devices it is capable of interacting with, each
 *   identified with a unique name. The length of the list should be returned
 *   in AOCL_MMD_NUM_BOARDS, and the names of these devices returned in
 *   AOCL_MMD_BOARD_NAMES. The OpenCL runtime will try to call aocl_mmd_open
 *   for each board name returned in AOCL_MMD_BOARD_NAMES.
 */
typedef enum {
   AOCL_MMD_VERSION = 0,       /* Version of MMD (char*)*/
   AOCL_MMD_NUM_BOARDS = 1,    /* Number of candidate boards (int)*/
   AOCL_MMD_BOARD_NAMES = 2,   /* Names of boards available delimiter=; (char*)*/
   AOCL_MMD_VENDOR_NAME = 3,   /* Name of vendor (char*) */
   AOCL_MMD_VENDOR_ID = 4,     /* An integer ID for the vendor (int) */
   AOCL_MMD_USES_YIELD = 5,    /* 1 if yield must be called to poll hw (int) */
   /* The following can be combined in a bit field:
    * AOCL_MMD_PHYSICAL_MEMORY, AOCL_MMD_SVM_COARSE_GRAIN_BUFFER, AOCL_MMD_SVM_FINE_GRAIN_BUFFER, AOCL_MMD_SVM_FINE_GRAIN_SYSTEM.
    * Prior to 14.1, all existing devices supported physical memory and no types of SVM memory, so this
    * is the default when this operation returns '0' for board MMDs with a version prior to 14.1
    */
   AOCL_MMD_MEM_TYPES_SUPPORTED = 6,
} aocl_mmd_offline_info_t;


/** Possible capabilities to return from AOCL_MMD_*_MEM_CAPABILITIES query */
/**
 * If not set allocation function is not supported, even if other capabilities are set.
 */
#define AOCL_MMD_MEM_CAPABILITY_SUPPORTED      (1 << 0)
/**
 *   Supports atomic access to the memory by either the host or device.
 */
#define AOCL_MMD_MEM_CAPABILITY_ATOMIC         (1 << 1)
/**
 * Supports concurrent access to the memory either by host or device if the
 * accesses are not on the same block. Block granularity is defined by
 * AOCL_MMD_*_MEM_CONCURRENT_GRANULARITY., blocks are aligned to this
 * granularity
 */
#define AOCL_MMD_MEM_CAPABILITY_CONCURRENT     (1 << 2)
/**
 * Memory can be accessed by multiple devices at the same time.
 */
#define AOCL_MMD_MEM_CAPABILITY_P2P            (1 << 3)


/* Defines the set of characteristics that can be probed about the board after
 * opening a device. This can involve communication to the device
 *
 * AOCL_MMD_NUM_KERNEL_INTERFACES - The number of kernel interfaces, usually 1
 *
 * AOCL_MMD_KERNEL_INTERFACES - the handle for each kernel interface.
 * param_value will have size AOCL_MMD_NUM_KERNEL_INTERFACES * sizeof int
 *
 * AOCL_MMD_PLL_INTERFACES - the handle for each pll associated with each
 * kernel interface. If a kernel interface is not clocked by acl_kernel_clk
 * then return -1
 *
 * */
typedef enum {
   AOCL_MMD_NUM_KERNEL_INTERFACES = 1,  /* Number of Kernel interfaces (int) */
   AOCL_MMD_KERNEL_INTERFACES = 2,      /* Kernel interface (int*) */
   AOCL_MMD_PLL_INTERFACES = 3,         /* Kernel clk handles (int*) */
   AOCL_MMD_MEMORY_INTERFACE = 4,       /* Global memory handle (int) */
   AOCL_MMD_TEMPERATURE = 5,            /* Temperature measurement (float) */
   AOCL_MMD_PCIE_INFO = 6,              /* PCIe information (char*) */
   AOCL_MMD_BOARD_NAME = 7,             /* Name of board (char*) */
   AOCL_MMD_BOARD_UNIQUE_ID = 8,        /* Unique ID of board (int) */
   AOCL_MMD_CONCURRENT_READS = 9,       /* # of parallel reads; 1 is serial*/
   AOCL_MMD_CONCURRENT_WRITES = 10,     /* # of parallel writes; 1 is serial*/
   AOCL_MMD_CONCURRENT_READS_OR_WRITES = 11, /* total # of concurrent operations read + writes*/
   AOCL_MMD_MIN_HOST_MEMORY_ALIGNMENT = 12,  /* Min alignment that the ASP supports for host allocations (size_t) */
   AOCL_MMD_HOST_MEM_CAPABILITIES = 13,      /* Capabilities of aocl_mmd_host_alloc() (unsigned int)*/
   AOCL_MMD_SHARED_MEM_CAPABILITIES = 14,    /* Capabilities of aocl_mmd_shared_alloc (unsigned int)*/
   AOCL_MMD_DEVICE_MEM_CAPABILITIES = 15,    /* Capabilities of aocl_mmd_device_alloc (unsigned int)*/
   AOCL_MMD_HOST_MEM_CONCURRENT_GRANULARITY = 16,   /*(size_t)*/
   AOCL_MMD_SHARED_MEM_CONCURRENT_GRANULARITY = 17, /*(size_t)*/
   AOCL_MMD_DEVICE_MEM_CONCURRENT_GRANULARITY = 18, /*(size_t)*/
} aocl_mmd_info_t;

typedef struct {
   unsigned long long int exception_type;
   void *user_private_info;
   size_t user_cb;
}aocl_mmd_interrupt_info;

typedef void (*aocl_mmd_interrupt_handler_fn)( int handle, void* user_data );
typedef void (*aocl_mmd_device_interrupt_handler_fn)( int handle, aocl_mmd_interrupt_info* data_in, void* user_data );
typedef void (*aocl_mmd_status_handler_fn)( int handle, void* user_data, aocl_mmd_op_t op, int status );


/* Get information about the board using the enum aocl_mmd_offline_info_t for
 * offline info (called without a handle), and the enum aocl_mmd_info_t for
 * info specific to a certain board.
 * Arguments:
 *
 *   requested_info_id - a value from the aocl_mmd_offline_info_t enum
 *
 *   param_value_size - size of the param_value field in bytes. This should
 *     match the size of the return type expected as indicated in the enum
 *     definition. For example, the AOCL_MMD_TEMPERATURE returns a float, so
 *     the param_value_size should be set to sizeof(float) and you should
 *     expect the same number of bytes returned in param_size_ret.
 *
 *   param_value - pointer to the variable that will receive the returned info
 *
 *   param_size_ret - receives the number of bytes of data actually returned
 *
 * Returns: a negative value to indicate error.
 */
AOCL_MMD_CALL int aocl_mmd_get_offline_info(
    aocl_mmd_offline_info_t requested_info_id,
    size_t param_value_size,
    void* param_value,
    size_t* param_size_ret ) WEAK;

AOCL_MMD_CALL int aocl_mmd_get_info(
    int handle,
    aocl_mmd_info_t requested_info_id,
    size_t param_value_size,
    void* param_value,
    size_t* param_size_ret ) WEAK;

/* Open and initialize the named device.
 *
 * The name is typically one specified by the AOCL_MMD_BOARD_NAMES offline
 * info.
 *
 * Arguments:
 *    name - open the board with this name (provided as a C-style string,
 *           i.e. NUL terminated ASCII.)
 *
 * Returns: the non-negative integer handle for the board, otherwise a
 * negative value to indicate error. Upon receiving the error, the OpenCL
 * runtime will proceed to open other known devices, hence the MMD mustn't
 * exit the application if an open call fails.
 */
AOCL_MMD_CALL int aocl_mmd_open(const char *name) WEAK;

/* Close an opened device, by its handle.
 * Returns: 0 on success, negative values on error.
 */
AOCL_MMD_CALL int aocl_mmd_close(int handle) WEAK;

/* Set the interrupt handler for the opened device.
 * The interrupt handler is called whenever the client needs to be notified
 * of an asynchronous event signaled by the device internals.
 * For example, the kernel has completed or is stalled.
 *
 * Important: Interrupts from the kernel must be ignored until this handler is
 * set
 *
 * Arguments:
 *   fn - the callback function to invoke when a kernel interrupt occurs
 *   user_data - the data that should be passed to fn when it is called.
 *
 * Returns: 0 if successful, negative on error
 */
AOCL_MMD_CALL int aocl_mmd_set_interrupt_handler( int handle, aocl_mmd_interrupt_handler_fn fn, void* user_data ) WEAK;

/* Set the operation status handler for the opened device.
 * The operation status handler is called with
 *    status 0 when the operation has completed successfully.
 *    status negative when the operation completed with errors.
 *
 * Arguments:
 *   fn - the callback function to invoke when a status update is to be
 *   performed.
 *   user_data - the data that should be passed to fn when it is called.
 *
 * Returns: 0 if successful, negative on error
 */
AOCL_MMD_CALL int aocl_mmd_set_status_handler( int handle, aocl_mmd_status_handler_fn fn, void* user_data ) WEAK;

/* Read, write and copy operations on a single interface.
 * If op is NULL
 *    - Then these calls must block until the operation is complete.
 *    - The status handler is not called for this operation.
 *
 * If op is non-NULL, then:
 *    - These may be non-blocking calls
 *    - The status handler must be called upon completion, with status 0
 *    for success, and a negative value for failure.
 *
 * Arguments:
 *   op - the operation object used to track this operations progress
 *
 *   len - the size in bytes to transfer
 *
 *   src - the host buffer being read from
 *
 *   dst - the host buffer being written to
 *
 *   mmd_interface - the handle to the interface being accessed. E.g. To
 *   access global memory this handle will be whatever is returned by
 *   aocl_mmd_get_info when called with AOCL_MMD_MEMORY_INTERFACE.
 *
 *   offset/src_offset/dst_offset - the byte offset within the interface that
 *   the transfer will begin at.
 *
 * The return value is 0 if the operation launch was successful, and
 * negative otherwise.
 */
AOCL_MMD_CALL int aocl_mmd_read(
      int handle,
      aocl_mmd_op_t op,
      size_t len,
      void* dst,
      int mmd_interface, size_t offset) WEAK;
AOCL_MMD_CALL int aocl_mmd_write(
      int handle,
      aocl_mmd_op_t op,
      size_t len,
      const void* src,
      int mmd_interface, size_t offset ) WEAK;

/** Error values*/
#define AOCL_MMD_ERROR_SUCCESS                 0
#define AOCL_MMD_ERROR_INVALID_HANDLE         -1
#define AOCL_MMD_ERROR_OUT_OF_MEMORY          -2
#define AOCL_MMD_ERROR_UNSUPPORTED_ALIGNMENT  -3
#define AOCL_MMD_ERROR_UNSUPPORTED_PROPERTY   -4
#define AOCL_MMD_ERROR_INVALID_POINTER        -5
#define AOCL_MMD_ERROR_INVALID_MIGRATION_SIZE -6

// CoreDLA modifications
// To support multiple different FPGA boards, anything board specific must be implemented in a
// board-specific MMD instead of the CoreDLA runtime layer.
#ifdef DLA_MMD
// Query functions to get board-specific values
AOCL_MMD_CALL int dla_mmd_get_max_num_instances() WEAK;
AOCL_MMD_CALL uint64_t dla_mmd_get_ddr_size_per_instance() WEAK;
AOCL_MMD_CALL double dla_mmd_get_ddr_clock_freq() WEAK;

// Wrappers around CSR and DDR reads and writes to abstract away board-specific offsets
AOCL_MMD_CALL int dla_mmd_csr_write(int handle, int instance, uint64_t addr, const uint32_t* data) WEAK;
AOCL_MMD_CALL int dla_mmd_csr_read(int handle, int instance, uint64_t addr, uint32_t* data) WEAK;
AOCL_MMD_CALL int dla_mmd_ddr_write(int handle, int instance, uint64_t addr, uint64_t length, const void* data) WEAK;
AOCL_MMD_CALL int dla_mmd_ddr_read(int handle, int instance, uint64_t addr, uint64_t length, void* data) WEAK;
AOCL_MMD_CALL int dla_mmd_istream_write(int handle, int instance, uint64_t length, const void* data) WEAK;
AOCL_MMD_CALL int dla_mmd_istream_stream(int handle, int instance) WEAK;
AOCL_MMD_CALL int dla_mmd_ostream_stream(int handle, int instance, uint64_t length) WEAK;
AOCL_MMD_CALL int dla_mmd_ostream_read(int handle, int instance, void* data) WEAK;

// Get the clk_dla PLL clock frequency in MHz, returns a negative value if there is an error
AOCL_MMD_CALL double dla_mmd_get_coredla_clock_freq(int handle) WEAK;

#endif

#ifdef __cplusplus
}
#endif

/* clang-format on */
#endif

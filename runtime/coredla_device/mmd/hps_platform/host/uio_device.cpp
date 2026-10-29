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

/* ===- uio_device.cpp  ----------------------------------------------- C++ -*-=== */
/*                                                                                 */
/*                         uio device access functions                             */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */
/*                                                                                 */
/* This file implements the functions used access the uio device objects           */
/*                                                                                 */
/* ===-------------------------------------------------------------------------=== */

// common and its own header files
#include "uio_device.h"
#include <unistd.h>
#include <glob.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>
#include <poll.h>

#include <cinttypes>
#include <memory.h>

//////////////////////////////////////////////////////
#define UIO_BASE_NAME "uio*"
#define UIO_BASE_PATH "/sys/class/uio/"
#define UIO_BASE_SEARCH UIO_BASE_PATH UIO_BASE_NAME
#define UIO_MAX_PATH (256)

#define ERR(format, ...) \
fprintf(stderr, "%s:%u **ERROR** : " format, \
    __FILE__, __LINE__,  ##__VA_ARGS__)

//////////////////////////////////////////////////////
#define MAX_NAME (20)
bool uio_read_sysfs_uint64(const char *device_name, const char *sysfs_name, uint64_t &value)
{
       FILE *fp;
    char param_path[UIO_MAX_PATH];

    if( snprintf(param_path, sizeof(param_path), "%s/%s", device_name, sysfs_name) < 0 )
    {
        ERR("Path too long. %s, %s\n", device_name, sysfs_name);
        return false;
    }

    fp = fopen(param_path, "r");
    if( !fp )
    {
        ERR("Failed to fopen - %s\n", param_path);
        return false;
    }

    if( fscanf(fp, "%" PRIx64, &value) != 1 )
    {
        ERR("Failed fscanf - %s\n", param_path);
        fclose(fp);
        return false;
    }

    fclose(fp);
    return true;
}

bool uio_read_sysfs_string(const char *uio_path, const char *sysfs_name, std::string &result)
{
    char uio_name[MAX_NAME];
    FILE *fp;
    char param_path[UIO_MAX_PATH];

    if( snprintf(param_path, sizeof(param_path), "%s/%s", uio_path, sysfs_name) < 0 )
    {
        ERR("Path too long. %s, %s\n", uio_path, sysfs_name);
        return false;
    }

    fp = fopen(param_path, "r");
    if( !fp )
    {
        ERR("Failed to fopen - %s\n", param_path);
        return false;
    }

    int num_read = fread(uio_name, 1, MAX_NAME, fp);
    if( num_read <= 0 )
    {
        ERR("Failed to read name - %s\n", param_path);
        fclose(fp);
        return false;
    }

    uio_name[num_read-1] = '\0'; // Terminate
    result = std::string(uio_name);
    fclose(fp);

    return true;
}

std::string uio_get_device(const std::string prefix, const int32_t index)
{
  glob_t globbuf = {0};
  std::string uio_name;

  int glob_res = glob(UIO_BASE_SEARCH, GLOB_NOSORT, NULL, &globbuf);
  if( (glob_res == 0) && (globbuf.gl_pathc) )
  {
    std::string device_name;
    device_name = prefix + std::to_string(index);

    for( size_t i=0; i<globbuf.gl_pathc; i++ )
    {
      std::string name;
      uio_read_sysfs_string(globbuf.gl_pathv[i], "name", name);

      if( name.find(device_name) != std::string::npos )
      {
        // We will return just the device name without the UIO_BASE_PATH
        std::string name = std::string(globbuf.gl_pathv[i]);
        uio_name = name.substr(sizeof(UIO_BASE_PATH)-1);
      }
    }
   }
   return uio_name;
}

board_names uio_get_devices(const std::string device_name, const int max_devices)
{
  board_names names;
  int device = 0;

  glob_t globbuf = {0};

  int glob_res = glob(UIO_BASE_SEARCH, GLOB_NOSORT, NULL, &globbuf);
  if( (glob_res == 0) && (globbuf.gl_pathc) )
  {
    for( size_t i=0; (i<globbuf.gl_pathc) && (device < max_devices); i++ )
    {
      std::string name;
      uio_read_sysfs_string(globbuf.gl_pathv[i], "name", name);

      if( name.find(device_name) != std::string::npos )
      {
        // We will return just the device name without the UIO_BASE_PATH
        std::string name = std::string(globbuf.gl_pathv[i]);
        name = name.substr(sizeof(UIO_BASE_PATH)-1);
        names.push_back(name);
        device++;
      }
    }
   }
   return names;
}

//////////////////////////////////////////////////////////////
uio_device::uio_device(std::string &name, const int mmd_handle, const bool bEnableIRQ)
: _mmd_handle(mmd_handle)
{
    // Map the first address space
    if ( !map_region(name, 0) ) {
        ERR("Failed to map region 0 on %s\n", name.c_str());
        return;
    }
#ifndef RUNTIME_POLLING
    if( bEnableIRQ ) {
        _spInterrupt = std::make_shared<uio_interrupt>(_fd, _mmd_handle);
        if( !_spInterrupt->initialized() ) {
            _spInterrupt = nullptr; // If the uio_interrupt failed to initialize then delete
        }
        _bIrqEnabled = bEnableIRQ;
    }
#endif
}

bool uio_device::bValid() {
    bool bValid = (_fd >=0);
#ifndef RUNTIME_POLLING // If we're not polling check that the interrupt handling is working
    if( _bIrqEnabled ) {
        bValid |= (_spInterrupt != nullptr);
    }
#endif
    return bValid;
};

uio_device::~uio_device()
{
#ifndef RUNTIME_POLLING
    _spInterrupt = nullptr; // Shutdown the interrupt handler
#endif
    unmap_region();
}

uint32_t uio_device::read(const uint32_t reg)
{
    // NOT YET IMPLEMENTED
    return 0;
}

void uio_device::write(const uint32_t reg, const uint32_t value)
{
    // NOT YET IMPLEMENTED
    return;
}

// Copies the block of data from the FPGA to the host
// memcpy is not used as this can cause multiple transfers of the AXI bus depending
// on the implementation of memcpy
int  uio_device::read_block(void *host_addr, size_t offset, size_t size)
{
    // Support for only 32bit aligned transfers
    if( (offset % sizeof(uint32_t)) || (size % sizeof(uint32_t)) ){
        return FAILURE;
    }

    // Transfer the data in 32bit chunks
    volatile const uint32_t *pDeviceMem32 = reinterpret_cast<volatile const uint32_t*>(reinterpret_cast<uint8_t*>(_pPtr) + offset);
    uint32_t *host_addr32 = reinterpret_cast<uint32_t *>(host_addr);
    while (size >= sizeof(uint32_t)) {
        *host_addr32++ = *pDeviceMem32++;
        size -= sizeof(uint32_t);
    }

    return SUCCESS;
}

// Copies the block of data from the host to the FPGA
// memcpy is not used as this can cause multiple transfers of the AXI bus depending
// on the implementation of memcpy
int  uio_device::write_block(const void *host_addr, size_t offset, size_t size)
{
    // Support for only 32bit aligned transfers
    if( (offset % sizeof(uint32_t)) || (size % sizeof(uint32_t)) ){
        return FAILURE;
    }

    // Transfer the remaining 32bits of data
    volatile uint32_t *pDeviceMem32 = reinterpret_cast<volatile uint32_t*>(reinterpret_cast<uint8_t*>(_pPtr) + offset);
    const uint32_t *host_addr32 = reinterpret_cast<const uint32_t*>(host_addr);
    while( size >= sizeof(uint32_t) ) {
        *pDeviceMem32++ = *host_addr32++;
        size -= sizeof(uint32_t);
    }
    return SUCCESS;
}

int uio_device::set_interrupt_handler(aocl_mmd_interrupt_handler_fn fn, void* user_data) {
#ifndef RUNTIME_POLLING
    if( _spInterrupt ) {
        return _spInterrupt->set_interrupt_handler(fn, user_data);
    }
#endif
    return FAILURE;
}

/////////////////////////////////////////////////////////////////
void uio_device::unmap_region()
{
    if( _pBase )
    {
        munmap(_pBase, _size);
        _pBase = nullptr;
    }

    if( _fd >= 0 )
    {
        close(_fd);
        _fd = -1;
    }
}

bool uio_device::map_region( std::string &name, const uint32_t index)
{
    char map_path[UIO_MAX_PATH];

    std::string uio_params_path(UIO_BASE_PATH);
    uio_params_path += name;

    // char device_path[UIO_MAX_PATH];
    // const char *p;

    if( snprintf(map_path, sizeof(map_path), "maps/map%d/size", index ) < 0 )
    {
        ERR("Failed to make map addr name.\n");
        return false;
    }
    if( !uio_read_sysfs_uint64(uio_params_path.c_str(), map_path, _size) )
    {
        ERR("Failed to read size\n");
        return false;
    }
    // Make sure that the size doesn't exceed 32bits, as this will fail the mapping
    // call on 32bit systems
    if( _size > UINT32_MAX ) {
        ERR("Invalid size value\n");
        return false;
    }

    if( snprintf(map_path, sizeof(map_path), "maps/map%d/offset", index ) < 0 )
    {
        ERR("Failed to make map offset name.\n");
        return false;
    }
    if( !uio_read_sysfs_uint64(uio_params_path.c_str(), map_path, _offset) )
    {
        ERR("Failed to read offset\n");
        return false;
    }

    std::string uio_dev_path("/dev/");
    uio_dev_path += name;

    _fd = open(uio_dev_path.c_str(), O_RDWR );
    if( _fd < 0 )
    {
        ERR("Failed to open - %s\n", uio_dev_path.c_str());
        return false;
    }
    // Map the region into userspace
    // The base of the region is the page_size offset of the index
    uint32_t page_size = (uint32_t)sysconf(_SC_PAGESIZE);

    _pBase = (uint8_t*)mmap(NULL, (size_t)_size, PROT_READ|PROT_WRITE, MAP_SHARED, _fd, (off_t) (index * page_size));
    if( _pBase == MAP_FAILED )
    {
        ERR("Failed to map uio region.\n");
        close(_fd);
        _fd = -1;
        return false;
    }
    // CST base address is at _pBase + _offset
    _pPtr = (uint32_t*)(_pBase + _offset);

    return true;
};

#ifndef RUNTIME_POLLING
///////////////////////////////////////////////////////////////////////////////////
uio_interrupt::uio_interrupt(const int fd, const int mmd_handle)
: _device_fd(fd), _mmd_handle(mmd_handle) {
    if( is_irq_available() ) {
        // Create a eventfd_object to be used for shutting down the work_thread
        _spShutdown_event = std::make_shared<eventfd_object>();
        if( _spShutdown_event->initialized() ) {
            _pThread = new std::thread(work_thread, std::ref(*this));
        } else {
            _spShutdown_event = nullptr;
        }
    } else {
        ERR("No device interrupt found.\n");
    }
}

uio_interrupt::~uio_interrupt() {
    // kill the thread
    if (_pThread && _spShutdown_event) {
        // send message to thread to end it
        _spShutdown_event->notify(1);

        // join with thread until it ends
        _pThread->join();

        delete _pThread;
        _pThread = NULL;

        _spShutdown_event = nullptr;
    }
}

bool uio_interrupt::is_irq_available() {
    // Disable the interrupt handling, this will fail if the IRQ has not been setup correctly.
    // For example devicetree is incorrect.
    return disable_irq();
}

bool uio_interrupt::enable_irq() {
    // Enable interrupts from the device
    uint32_t info = 1;
    ssize_t nb = write(_device_fd, &info, sizeof(info));
    if( nb != (ssize_t)sizeof(info) ) {
        ERR( "Failed in enable CoreDLA Interrupt = %s\n", strerror(errno));
        return false;
    }
    return true;
}

bool uio_interrupt::disable_irq() {
    // Enable interrupts from the device
    uint32_t info = 0;
    ssize_t nb = write(_device_fd, &info, sizeof(info));
    if( nb != (ssize_t)sizeof(info) ) {
        ERR( "Failed in disable CoreDLA Interrupt = %s\n", strerror(errno));
        return false;
    }
    return true;
}

void uio_interrupt::work_thread(uio_interrupt& obj) {
    obj.run_thread();
}

#define UIO_INTERRUPT_TIMEOUT (-1)
void uio_interrupt::run_thread() {
    while( true ) {
        // Need to re-enable the UIO interrupt handling as UIO disables the IRQ each time it is fired
        if ( !enable_irq() ) {
            exit(-1);
        }
        // Poll for the shutdown_event and uio interrupt
        struct pollfd pollfd_arr[2];
        pollfd_arr[0].fd = _spShutdown_event->get_fd();
        pollfd_arr[0].events = POLLIN;
        pollfd_arr[0].revents = 0;
        pollfd_arr[1].fd = _device_fd;
        pollfd_arr[1].events = POLLIN;
        pollfd_arr[1].revents = 0;

        int res = poll(pollfd_arr, 2, UIO_INTERRUPT_TIMEOUT);
        if (res < 0) {
            ERR( "Poll error errno = %s\n", strerror(errno));
            exit(-1);
        } else if (res > 0 && pollfd_arr[0].revents == POLLIN) {
            uint64_t count;
            ssize_t bytes_read = read(pollfd_arr[0].fd, &count, sizeof(count));
            if (bytes_read > 0) {
                break; // We've been asked to shutdown
            } else {
                ERR( "Error: poll failed: %s\n", bytes_read < 0 ? strerror(errno) : "zero bytes read");
                exit(-1);
            }
        } else if (res > 0 && pollfd_arr[1].revents == POLLIN) {
            uint32_t count;
            ssize_t bytes_read = read(pollfd_arr[1].fd, &count, sizeof(count));
            if (bytes_read > 0) {
                if( _interrupt_fn ) { // Run the callback to the application
                    _interrupt_fn(get_mmd_handle(), _interrupt_fn_user_data );
                }
            } else {
                ERR( "Error: poll failed: %s\n", bytes_read < 0 ? strerror(errno) : "zero bytes read");
                exit(-1);
            }
        }
    }
    // Disable interrupt handling in UIO
    if( !disable_irq() ){
        exit(-1);
    }
}

int uio_interrupt::set_interrupt_handler(aocl_mmd_interrupt_handler_fn fn, void* user_data) {
  _interrupt_fn = fn;
  _interrupt_fn_user_data = user_data;
  return SUCCESS;
}
#endif

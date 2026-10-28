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

// common and its own header files
#include "dma_device.h"
#include <unistd.h>
#include <glob.h>
#include <sys/mman.h>
#include <fcntl.h>
#include <stdio.h>

#include <memory.h>

// Copied from Linux driver: /drivers/dma/altera-msgdma.c
#define MSGDMA_DESC_NUM 1024

// Same page size as used in /meta-altera-fpga-coredla/recipes-drivers/msgdma-userio/files/msgdma_userio_chr.c
#define PAGE_SIZE 4096

//////////////////////////////////////////////////////

#define ERR(format, ...) \
printf("%s:%u() **ERROR** : " format, \
    __func__, __LINE__,  ##__VA_ARGS__)

//////////////////////////////////////////////////////
dma_device::dma_device(std::string &name)
{
    _pFile = fopen(name.c_str(), "r+");
    if( _pFile == nullptr )
    {
        ERR("dma_device::dma_device failed to open %s\n", name.c_str());
        return;
    }

    // Turn off buffering
    setvbuf(_pFile, NULL, _IONBF, 0);
}

dma_device::~dma_device()
{
    if( _pFile )
    {
        fclose(_pFile);
        _pFile = NULL;
    }
}

int  dma_device::read_block(void *host_addr, size_t offset, size_t size)
{
    // Use 32bit seek as DDR memory current < 32bits
    if( fseek(_pFile, (uint32_t)offset, SEEK_SET) != 0 ) {
        return FAILURE;
    }

    size_t read_size = fread(host_addr, 1, size, _pFile);
    return (read_size == size) ? SUCCESS : FAILURE;
}

int  dma_device::write_block(const void *host_addr, size_t offset, size_t size)
{
    // The MSGDMA driver only supports a maximum of 1024 x 4096 = 4MBytes in the worst case scenario,
    // in the event that the virtual buffer is fully fragmented. As the buffer gets more fragmented it's
    // possible to run out of DMA descriptors. To prevent this, slice the data into 4MB chunks.

    // chunk_size is chosen based on the size of a page (12 bits) and default number of descriptors (1024).
    // The descriptor count is reduced by 1 since if the host_addr is not aligned to a page then an extra page
    // will be added at the end. This would then increase the descriptor count by 1.
    size_t chunk_size = PAGE_SIZE * (MSGDMA_DESC_NUM - 1);
    size_t write_size = 0;

    // Use 32bit seek as DDR memory current < 32bits
    if( fseek(_pFile, (uint32_t)offset, SEEK_SET) != 0 ) {
        return FAILURE;
    }

    for (size_t host_addr_offset = 0; host_addr_offset < size; host_addr_offset += chunk_size) {
        size_t current_size = chunk_size;

        // If the current address is within one chunk_size from the end of the data, set current_size
        // to the bytes left to send
        if (size - host_addr_offset < chunk_size) {
            current_size = size - host_addr_offset;
        }

        size_t current_write_size = fwrite((uint8_t *)host_addr + host_addr_offset, 1, current_size, _pFile);

        if (current_write_size != current_size) {
            return FAILURE;
        }

        write_size += current_write_size;
    }

    return (write_size == size) ? SUCCESS : FAILURE;
}

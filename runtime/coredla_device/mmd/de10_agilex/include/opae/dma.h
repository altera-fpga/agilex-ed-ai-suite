// Copyright(c) 2017 - 2019, Intel Corporation
//
// Redistribution  and  use  in source  and  binary  forms,  with  or  without
// modification, are permitted provided that the following conditions are met:
//
// * Redistributions of  source code  must retain the  above copyright notice,
//   this list of conditions and the following disclaimer.
// * Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// * Neither the name  of Intel Corporation  nor the names of its contributors
//   may be used to  endorse or promote  products derived  from this  software
//   without specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING,  BUT NOT LIMITED TO,  THE
// IMPLIED WARRANTIES OF  MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED.  IN NO EVENT  SHALL THE COPYRIGHT OWNER  OR CONTRIBUTORS BE
// LIABLE  FOR  ANY  DIRECT,  INDIRECT,  INCIDENTAL,  SPECIAL,  EXEMPLARY,  OR
// CONSEQUENTIAL  DAMAGES  (INCLUDING,  BUT  NOT LIMITED  TO,  PROCUREMENT  OF
// SUBSTITUTE GOODS OR SERVICES;  LOSS OF USE,  DATA, OR PROFITS;  OR BUSINESS
// INTERRUPTION)  HOWEVER CAUSED  AND ON ANY THEORY  OF LIABILITY,  WHETHER IN
// CONTRACT,  STRICT LIABILITY,  OR TORT  (INCLUDING NEGLIGENCE  OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE,  EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

/**
 * @file dma.h
 * @brief Functions to acquire, release, and reset OPAE FPGA DMA resources
 */

#ifndef __DMA_ACCESS_H__
#define __DMA_ACCESS_H__

#include <opae/types.h>

BEGIN_C_DECL

/*
*  The DMA driver supports host to FPGA, FPGA to host
*  and FPGA to FPGA transfers. The FPGA interface can
*  be streaming or memory-mapped. Streaming interfaces
*  are not currently
*  supported.
*/
typedef enum {
    HOST_TO_FPGA_MM = 0,
    FPGA_TO_HOST_MM,
    FPGA_TO_FPGA_MM,
    FPGA_MAX_TRANSFER_TYPE,
}fpga_dma_transfer;


typedef enum
{
    DMA_OPEN = 1,
    DMA_BUSY,
    DMA_CLOSED
}fpga_dma_status;

/*
 * Dma handle in user space that will be populated during fpgaDmaOpen call.
 */
typedef struct _fpga_dma_handle
{
    //
    // Stores the handle to the fpga that was opened after fpgaOpen
    //
    fpga_handle fpga_h;

    //
    // Stores the current status of the DMA AFC
    // Set to the following values:
    // DMA_OPEN - After call to fpgaDmaOpen() and when fpgaDmaTransferSync() exits
    // DMA_BUSY - When fpgaDmaTransferSync() is called
    //
    uint64_t dma_status;
}dma_handle, *fpga_dma_handle;



/**
*
* Opens a handle to DMA
* Sets the status of DMA engine to DMA_OPEN
* @param[in]  handle   Handle to previously opened FPGA object
* @param[in]  dma_h    DMA handle allocated by the user
* @returns             FPGA_OK on success. FPGA_INVALID_PARAM if handle does
*                      not refer to an acquired resource.
*
*/
__FPGA_API__
fpga_result
fpgaDmaOpen(
    fpga_handle      handle,
    fpga_dma_handle  *dma_h
);

/**
*
* Closes a handle to DMA
* Sets the status of DMA engine to DMA_CLOSED
* @param[in]  handle   Handle to previously opened FPGA object
* @param[in]  dma_h    DMA handle allocated by the user
* @returns             FPGA_OK on success. FPGA_INVALID_PARAM if handle does
*                      not refer to an acquired resource.
*
*/
__FPGA_API__
fpga_result
fpgaDmaClose(
    fpga_dma_handle     dma_h
);


/**
*
* Performs a synchronous DMA transfer between FPGA and host memory.
*
* @param[in]  handle   Handle to previously opened FPGA object
* @param[in]  dst      Destination address for the data transfer
* @param[in]  src      Source address for the data transfer
* @param[in]  count    Length of data to be transferred from src to dst
* @param[in]  flag     Flag to indicate nature of data transfer. Flag types =
                       HOST_TO_FPGA_MM and FPGA_TO_HOST_MM.
* @returns             FPGA_OK on success. FPGA_INVALID_PARAM if handle does
*                      not refer to an acquired resource or to a resoure that
*                      cannot be reset. FPGA_EXCEPTION if an internal error
*                      occurred while trying to access the handle or resetting
*                      the resource.
*/
__FPGA_API__
fpga_result
fpgaDmaTransferSync(
    fpga_dma_handle handle,
    ULONG64         dst,
    ULONG64         src,
    ULONG64         count,
    ULONG64         flag
);

END_C_DECL

#endif // __DMA_ACCESS_H__

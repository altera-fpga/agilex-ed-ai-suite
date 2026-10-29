// Copyright 2017-2020 Intel Corporation.
//
// This software and the related documents are Intel copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Intel's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// This is derived from OPAE + OpenCL PAC BSP

/**
 * \fpga_dma.h
 * \brief FPGA DMA BBB API Header
 *
 * Known Limitations
 * - Supports only synchronous (blocking) transfers
 */

#ifndef __FPGA_DMA_H__
#define __FPGA_DMA_H__

#include <opae/fpga.h>

//#define DEBUG_MEM 1
//#define FPGA_DMA_DEBUG 1
#define SKIP_FPGA2HOST_IRQ 1
#ifdef SKIP_FPGA2HOST_IRQ
#define FPGA2HOST_IRQ_REQ false
#else
#define FPGA2HOST_IRQ_REQ true
#endif

#ifdef __cplusplus
extern "C" {
#endif

/*
 * The DMA driver supports host to FPGA, FPGA to host and FPGA
 * to FPGA transfers. The FPGA interface can be streaming
 * or memory-mapped. Streaming interfaces are not currently
 * supported.
 */
typedef enum {
  HOST_TO_FPGA_MM = 0,  // Memory mapped FPGA interface
  FPGA_TO_HOST_MM,      // Memory mapped FPGA interface
  FPGA_TO_FPGA_MM,      // Memory mapped FPGA interface
  FPGA_MAX_TRANSFER_TYPE,
} fpga_dma_transfer_t;

typedef struct _dma_handle_t *fpga_dma_handle;

// Callback for asynchronous DMA transfers
typedef void (*fpga_dma_transfer_cb)(void *context);

/**
 * fpgaDmaOpen
 *
 * @brief           Open a handle to DMA BBB.
 *                  Scans the device feature chain looking for a DMA BBB.
 *
 * @param[in]  fpga Handle to the FPGA AFU object obtained via fpgaOpen()
 * @param[in]  dma_base to DMA channel DFH
 * @param[in]  interrupt_num interrupt number assigned to DMA channel
 * @param[out] dma  DMA object handle
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaDmaChannelOpen(fpga_handle fpga, uint64_t dma_base, int interrupt_num, fpga_dma_handle *dma);

/**
 * fpgaDmaTransferSync
 *
 * @brief             Perform a blocking copy of 'count' bytes from memory area pointed
 *                    by src to memory area pointed by dst where fpga_dma_transfer_t specifies the
 *                    type of memory transfer.
 * @param[in] dma     Handle to the FPGA DMA object
 * @param[in] dst     Address of the destination buffer
 * @param[in] src     Address of the source buffer
 * @param[in] count   Size in bytes
 * @param[in] type    Must be one of the following values:
 *                    HOST_TO_FPGA_MM - Copy data from host memory to memory mapped FPGA interface.
 *                                      User must specify valid src and dst.
 *                    FPGA_TO_HOST_MM - Copy data from memory mapped FPGA interface to host memory
 *                                      User must specify valid src and dst.
 *                    FPGA_TO_FPGA_MM - Copy data between memory mapped FPGA interfaces
 *                                      User must specify valid src and dst.
 * @return fpga_result FPGA_OK on success, return code otherwise
 *
 */
fpga_result fpgaDmaTransferSync(
    fpga_dma_handle dma, uint64_t dst, uint64_t src, size_t count, fpga_dma_transfer_t type);

/**
 * fpgaDmaTransferAsync (Not supported)
 *
 * @brief             Perform a non-blocking copy of 'count' bytes from memory area pointed
 *                    by src to memory area pointed by dst where fpga_dma_transfer_t specifies the
 *                    type of memory transfer.
 * @param[in] dma     Handle to the FPGA DMA object
 * @param[in] dst     Address of the destination buffer
 * @param[in] src     Address of the source buffer
 * @param[in] count   Size in bytes
 * @param[in] type    Must be one of the following values:
 *                    HOST_TO_FPGA_MM - Copy data from host memory to memory mapped FPGA interface.
 *                                      User must specify valid src and dst.
 *                    FPGA_TO_HOST_MM - Copy data from memory mapped FPGA interface to host memory
 *                                      User must specify valid src and dst.
 *                    FPGA_TO_FPGA_MM - Copy data between memory mapped FPGA interfaces
 *                                      User must specify valid src and dst.
 * @param[in] cb      Callback to invoke when DMA transfer is complete
 * @param[in] context Pointer to define user-defined context
 * @return fpga_result FPGA_OK on success, return code otherwise
 *
 */
fpga_result fpgaDmaTransferAsync(fpga_dma_handle dma,
                                 uint64_t dst,
                                 uint64_t src,
                                 size_t count,
                                 fpga_dma_transfer_t type,
                                 fpga_dma_transfer_cb cb,
                                 void *context);

/**
 * fpgaDmaClose
 *
 * @brief           Close the DMA BBB handle.
 *
 * @param[in] dma   DMA object handle
 * @returns         FPGA_OK on success, return code otherwise
 */
fpga_result fpgaDmaClose(fpga_dma_handle dma);

#ifdef __cplusplus
}
#endif

#endif  // __FPGA_DMA_H__

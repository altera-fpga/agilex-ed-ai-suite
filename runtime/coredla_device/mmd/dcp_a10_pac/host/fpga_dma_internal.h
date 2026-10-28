// Copyright 2018-2020 Intel Corporation.
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
 * \fpga_dma_internal.h
 * \brief FPGA DMA BBB Internal Header
 */

#ifndef __FPGA_DMA_INT_H__
#define __FPGA_DMA_INT_H__

#include <opae/fpga.h>
#include "x86-sse2.h"

#ifdef CHECK_DELAYS
#pragma message "Compiled with -DCHECK_DELAYS.  Not to be used in production"
#endif

#ifdef FPGA_DMA_DEBUG
#pragma message "Compiled with -DFPGA_DMA_DEBUG.  Not to be used in production"
#endif

#ifndef max
#define max(a, b)           \
  ({                        \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a > _b ? _a : _b;      \
  })
#endif

#ifndef min
#define min(a, b)           \
  ({                        \
    __typeof__(a) _a = (a); \
    __typeof__(b) _b = (b); \
    _a < _b ? _a : _b;      \
  })
#endif

#define FPGA_DMA_TIMEOUT_MSEC (5000)

#define QWORD_BYTES 8
#define DWORD_BYTES 4
#define IS_ALIGNED_DWORD(addr) (addr % 4 == 0)
#define IS_ALIGNED_QWORD(addr) (addr % 8 == 0)

#define FPGA_DMA_UUID_H 0xef82def7f6ec40fc
#define FPGA_DMA_UUID_L 0xa9149a35bace01ea
#define FPGA_DMA_WF_MAGIC_NO 0x5772745F53796E63ULL
#define FPGA_DMA_HOST_MASK 0x2000000000000
#define FPGA_DMA_WF_HOST_MASK 0x3000000000000
#define FPGA_DMA_WF_ROM_MAGIC_NO_MASK 0x1000000000000

#define AFU_DFH_REG 0x0
#define AFU_DFH_NEXT_OFFSET 16
#define AFU_DFH_EOL_OFFSET 40
#define AFU_DFH_TYPE_OFFSET 60

// BBB Feature ID (refer CCI-P spec)
#define FPGA_DMA_BBB 0x2

// Feature ID for DMA BBB
#define FPGA_DMA_BBB_FEATURE_ID 0x765

// DMA Register offsets from base
#define FPGA_DMA_CSR 0x40
#define FPGA_DMA_DESC 0x60
#define FPGA_DMA_ADDR_SPAN_EXT_CNTL 0x200
#define FPGA_DMA_ADDR_SPAN_EXT_DATA 0x1000

#define DMA_ADDR_SPAN_EXT_WINDOW (4 * 1024)
#define DMA_ADDR_SPAN_EXT_WINDOW_MASK ((uint64_t)(DMA_ADDR_SPAN_EXT_WINDOW - 1))

#define FPGA_DMA_MASK_32_BIT 0xFFFFFFFF

#define FPGA_DMA_CSR_BUSY (1 << 0)
#define FPGA_DMA_DESC_BUFFER_EMPTY 0x2
#define FPGA_DMA_DESC_BUFFER_FULL 0x4

#define FPGA_DMA_ALIGN_BYTES 64
#define IS_DMA_ALIGNED(addr) (addr % FPGA_DMA_ALIGN_BYTES == 0)

#define CSR_BASE(dma_handle) ((uint64_t)dma_handle->dma_csr_base)
#define ASE_DATA_BASE(dma_handle) ((uint64_t)dma_handle->dma_ase_data_base)
#define ASE_CNTL_BASE(dma_handle) ((uint64_t)dma_handle->dma_ase_cntl_base)
#define HOST_MMIO_32_ADDR(dma_handle, offset) \
  ((volatile uint32_t *)((uint64_t)(dma_handle)->mmio_va + (uint64_t)(offset)))
#define HOST_MMIO_64_ADDR(dma_handle, offset) \
  ((volatile uint64_t *)((uint64_t)(dma_handle)->mmio_va + (uint64_t)(offset)))
#define HOST_MMIO_32(dma_handle, offset) (*HOST_MMIO_32_ADDR(dma_handle, offset))
#define HOST_MMIO_64(dma_handle, offset) (*HOST_MMIO_64_ADDR(dma_handle, offset))

#define CSR_STATUS(dma_h) (CSR_BASE(dma_h) + offsetof(msgdma_csr_t, status))
#define CSR_CONTROL(dma_h) (CSR_BASE(dma_h) + offsetof(msgdma_csr_t, ctrl))

// Granularity of DMA transfer (maximum bytes that can be packed
// in a single descriptor).This value must match configuration of
// the DMA IP. Larger transfers will be broken down into smaller
// transactions.
#define FPGA_DMA_BUF_SIZE (1024 * 1024 * 2UL)
#define FPGA_DMA_BUF_ALIGN_SIZE FPGA_DMA_BUF_SIZE

// Convenience macros

#ifdef FPGA_DMA_DEBUG
#define debug_print(fmt, ...)                                \
  do {                                                       \
    if (FPGA_DMA_DEBUG) {                                    \
      fprintf(stderr, "%s (%d) : ", __FUNCTION__, __LINE__); \
      fprintf(stderr, fmt, ##__VA_ARGS__);                   \
    }                                                        \
  } while (0)
#define error_print(fmt, ...)                              \
  do {                                                     \
    fprintf(stderr, "%s (%d) : ", __FUNCTION__, __LINE__); \
    fprintf(stderr, fmt, ##__VA_ARGS__);                   \
    err_cnt++;                                             \
  } while (0)
#else
#define debug_print(...)
#define error_print(...)
#endif

#define FPGA_DMA_MAX_BUF 2

typedef struct __attribute__((__packed__)) {
  uint64_t dfh;
  uint64_t feature_uuid_lo;
  uint64_t feature_uuid_hi;
} dfh_feature_t;

typedef union {
  uint64_t reg;
  struct {
    uint64_t feature_type : 4;
    uint64_t reserved_8 : 8;
    uint64_t afu_minor : 4;
    uint64_t reserved_7 : 7;
    uint64_t end_dfh : 1;
    uint64_t next_dfh : 24;
    uint64_t afu_major : 4;
    uint64_t feature_id : 12;
  } bits;
} dfh_reg_t;

struct _dma_handle_t {
  fpga_handle fpga_h;
  uint32_t mmio_num;
  uint64_t mmio_va;
  uint64_t cur_ase_page;
  uint64_t dma_base;
  uint64_t dma_offset;
  uint64_t dma_csr_base;
  uint64_t dma_desc_base;
  uint64_t dma_ase_cntl_base;
  uint64_t dma_ase_data_base;
  // Interrupt event handle
  fpga_event_handle eh;
  // magic number buffer
  volatile uint64_t *magic_buf;
  uint64_t magic_iova;
  uint64_t magic_wsid;
  uint64_t *dma_buf_ptr[FPGA_DMA_MAX_BUF];
  uint64_t dma_buf_wsid[FPGA_DMA_MAX_BUF];
  uint64_t dma_buf_iova[FPGA_DMA_MAX_BUF];
};

typedef union {
  uint32_t reg;
  struct {
    uint32_t tx_channel : 8;
    uint32_t generate_sop : 1;
    uint32_t generate_eop : 1;
    uint32_t park_reads : 1;
    uint32_t park_writes : 1;
    uint32_t end_on_eop : 1;
    uint32_t reserved_1 : 1;
    uint32_t transfer_irq_en : 1;
    uint32_t early_term_irq_en : 1;
    uint32_t trans_error_irq_en : 8;
    uint32_t early_done_en : 1;
    uint32_t reserved_2 : 6;
    uint32_t go : 1;
  };
} msgdma_desc_ctrl_t;

typedef struct __attribute__((__packed__)) {
  // 0x0
  uint32_t rd_address;
  // 0x4
  uint32_t wr_address;
  // 0x8
  uint32_t len;
  // 0xC
  uint16_t seq_num;
  uint8_t rd_burst_count;
  uint8_t wr_burst_count;
  // 0x10
  uint16_t rd_stride;
  uint16_t wr_stride;
  // 0x14
  uint32_t rd_address_ext;
  // 0x18
  uint32_t wr_address_ext;
  // 0x1c
  msgdma_desc_ctrl_t control;
} msgdma_ext_desc_t;

typedef union {
  uint32_t reg;
  struct {
    uint32_t busy : 1;
    uint32_t desc_buf_empty : 1;
    uint32_t desc_buf_full : 1;
    uint32_t rsp_buf_empty : 1;
    uint32_t rsp_buf_full : 1;
    uint32_t stopped : 1;
    uint32_t resetting : 1;
    uint32_t stopped_on_errror : 1;
    uint32_t stopped_on_early_term : 1;
    uint32_t irq : 1;
    uint32_t reserved : 22;
  } st;
} msgdma_status_t;

typedef union {
  uint32_t reg;
  struct {
    uint32_t stop_dispatcher : 1;
    uint32_t reset_dispatcher : 1;
    uint32_t stop_on_error : 1;
    uint32_t stopped_on_early_term : 1;
    uint32_t global_intr_en_mask : 1;
    uint32_t stop_descriptors : 1;
    uint32_t rsvd : 22;
  } ct;
} msgdma_ctrl_t;

typedef union {
  uint32_t reg;
  struct {
    uint32_t rd_fill_level : 16;
    uint32_t wr_fill_level : 16;
  } fl;
} msgdma_fill_level_t;

typedef union {
  uint32_t reg;
  struct {
    uint32_t rsp_fill_level : 16;
    uint32_t rsvd : 16;
  } rsp;
} msgdma_rsp_level_t;

typedef union {
  uint32_t reg;
  struct {
    uint32_t rd_seq_num : 16;
    uint32_t wr_seq_num : 16;
  } seq;
} msgdma_seq_num_t;

typedef struct __attribute__((__packed__)) {
  // 0x0
  msgdma_status_t status;
  // 0x4
  msgdma_ctrl_t ctrl;
  // 0x8
  msgdma_fill_level_t fill_level;
  // 0xc
  msgdma_rsp_level_t rsp;
  // 0x10
  msgdma_seq_num_t seq_num;
} msgdma_csr_t;

#endif  // __FPGA_DMA_INT_H__

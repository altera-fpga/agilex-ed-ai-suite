// Copyright 2023 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

//the numbers below are byte addresses, must be a multiple of 4 since each access is 32 bits
static const uint32_t DLA_DMA_CSR_OFFSET_INTERRUPT_CONTROL      = 512; //0x200
static const uint32_t DLA_DMA_CSR_OFFSET_INTERRUPT_MASK         = 516;
static const uint32_t DLA_DMA_CSR_OFFSET_CONFIG_BASE_ADDR       = 528; //0x210
static const uint32_t DLA_DMA_CSR_OFFSET_CONFIG_RANGE_MINUS_TWO = 532;
static const uint32_t DLA_DMA_CSR_OFFSET_INPUT_OUTPUT_BASE_ADDR = 536;
static const uint32_t DLA_DMA_CSR_OFFSET_DESC_DIAGNOSTICS       = 540;
static const uint32_t DLA_DMA_CSR_OFFSET_INTERMEDIATE_BASE_ADDR = 544; //0x220
static const uint32_t DLA_DMA_CSR_OFFSET_COMPLETION_COUNT       = 548;
static const uint32_t DLA_DMA_CSR_OFFSET_LT_WB_BASE_ADDR        = 560;
static const uint32_t DLA_DMA_CSR_OFFSET_LT_WB_FRAME_SIZE       = 564;
static const uint32_t DLA_DMA_CSR_OFFSET_LT_WB_ADDR_RANGE       = 568;
static const uint32_t DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_LO       = 576; //0x240
static const uint32_t DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_HI       = 580;
static const uint32_t DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_LO     = 584;
static const uint32_t DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_HI     = 588;
static const uint32_t DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_ADDR     = 592; //0x250
static const uint32_t DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_VALID    = 596;
static const uint32_t DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_DATA     = 600;

static const uint32_t DLA_DMA_CSR_OFFSET_PPN_ADDR               = 664; // 0x298
static const uint32_t DLA_DMA_CSR_OFFSET_PPN_VALID_CLEAR        = 668; // 0x29C - write any value to clear all PPN trace data, read to poll on valid
static const uint32_t DLA_DMA_CSR_OFFSET_PPN_DATA_START         = 672;
static const uint32_t DLA_DMA_CSR_OFFSET_PPN_DATA_END           = 676;
static const uint32_t DLA_DMA_CSR_OFFSET_PPN_DATA_COUNT         = 680; // 0x2A8 - full 32-bit rcount

//bit positions in interrupt control and mask
static const uint32_t DLA_DMA_CSR_INTERRUPT_ERROR_BIT = 0;
static const uint32_t DLA_DMA_CSR_INTERRUPT_DONE_BIT  = 1;

//bit positions in descriptor diagnostic
static const uint32_t DLA_DMA_CSR_DESC_DIAGNOSTICS_OVERFLOW_BIT    = 0;
static const uint32_t DLA_DMA_CSR_DESC_DIAGNOSTICS_ALMOST_FULL_BIT = 1;
static const uint32_t DLA_DMA_CSR_DESC_DIAGNOSTICS_OUT_OF_INFERENCES_BIT = 2;

//descriptor queue
//runtime knows how many jobs it has enqueued and how many jobs have finished
//runtime is responsible for not overflowing the descriptor queue, it must limit the number of outstanding jobs queued in hardware
static const uint32_t DLA_DMA_CSR_DESCRIPTOR_QUEUE_LOGICAL_SIZE  = 64;   //max number of jobs that runtime can enqueue
static const uint32_t DLA_DMA_CSR_DESCRIPTOR_QUEUE_WORDS_PER_JOB = 9;    //how many words in the queue are needed to enqueue 1 job (4 addr-gen + 5 intercept including spatial kernel)
static const uint32_t DLA_DMA_CSR_DESCRIPTOR_QUEUE_PHYSICAL_SIZE = DLA_DMA_CSR_DESCRIPTOR_QUEUE_LOGICAL_SIZE * DLA_DMA_CSR_DESCRIPTOR_QUEUE_WORDS_PER_JOB; //number of words in the hardware queue

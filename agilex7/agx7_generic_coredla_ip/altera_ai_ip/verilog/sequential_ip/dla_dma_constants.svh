// Copyright 2020 Altera Corporation.
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

// This is a header file for specifying DMA constants that need to be consistent between
// hardware and software.
//
// WARNING: DO NOT CHANGE THE SYNTAX OF THIS FILE
//
// The syntax is meant to work natively for hardware, and in software "localparam" is replaced
// by "constexpr". It is simpler to avoid hexadecimal numbers because the prefix syntax is
// different, hardware uses "32'h" where software uses 0x.



///////////////////
//  DLA DMA CSR  //
///////////////////

//the numbers below are byte addresses, must be a multiple of 4 since each access is 32 bits
localparam int DLA_DMA_CSR_OFFSET_INTERRUPT_CONTROL             = 512; //0x200
localparam int DLA_DMA_CSR_OFFSET_INTERRUPT_MASK                = 516;
localparam int DLA_DMA_CSR_OFFSET_CONFIG_BASE_ADDR              = 528; //0x210
localparam int DLA_DMA_CSR_OFFSET_CONFIG_RANGE_MINUS_TWO        = 532;
localparam int DLA_DMA_CSR_OFFSET_INPUT_OUTPUT_BASE_ADDR        = 536;
localparam int DLA_DMA_CSR_OFFSET_DESC_DIAGNOSTICS              = 540;
localparam int DLA_DMA_CSR_OFFSET_INTERMEDIATE_BASE_ADDR        = 544; //0x220
localparam int DLA_DMA_CSR_OFFSET_COMPLETION_COUNT              = 548;
localparam int DLA_DMA_CSR_OFFSET_IP_RESET                      = 552;
localparam int DLA_CSR_OFFSET_READY_STREAMING_IFACE             = 556; //0x22c
localparam int DLA_DMA_CSR_OFFSET_LT_WB_BASE_ADDR               = 560;
localparam int DLA_DMA_CSR_OFFSET_LT_WB_FRAME_SIZE              = 564;
localparam int DLA_DMA_CSR_OFFSET_LT_WB_ADDR_RANGE              = 568;

localparam int DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_LO              = 576; //0x240
localparam int DLA_DMA_CSR_OFFSET_CLOCKS_ACTIVE_HI              = 580;
localparam int DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_LO            = 584;
localparam int DLA_DMA_CSR_OFFSET_CLOCKS_ALL_JOBS_HI            = 588;
localparam int DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_ADDR            = 592; //0x250
localparam int DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_VALID           = 596;
localparam int DLA_DMA_CSR_OFFSET_DEBUG_NETWORK_DATA            = 600;
localparam int DLA_DMA_CSR_OFFSET_LICENSE_FLAG                  = 608; //0x260
localparam int DLA_DMA_CSR_OFFSET_INPUT_FEATURE_READ_COUNT_LO   = 612;
localparam int DLA_DMA_CSR_OFFSET_INPUT_FEATURE_READ_COUNT_HI   = 616;
localparam int DLA_DMA_CSR_OFFSET_INPUT_FILTER_READ_COUNT_LO    = 620;
localparam int DLA_DMA_CSR_OFFSET_INPUT_FILTER_READ_COUNT_HI    = 624;
localparam int DLA_DMA_CSR_OFFSET_OUTPUT_FEATURE_WRITE_COUNT_LO = 628;
localparam int DLA_DMA_CSR_OFFSET_OUTPUT_FEATURE_WRITE_COUNT_HI = 632;
localparam int DLA_DMA_CSR_OFFSET_CORE_CLOCKS_ACTIVE_LO         = 636; // 0x27c
localparam int DLA_DMA_CSR_OFFSET_CORE_CLOCKS_ACTIVE_HI         = 640; // 0x280
localparam int DLA_DMA_CSR_OFFSET_START_CORE_STREAMING          = 644; // 0x284

localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_0             = 768; // 0x300
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_1             = 772; // 0x304
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_2             = 776; // 0x308
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_3             = 780; // 0x30C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_4             = 784; // 0x310
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_5             = 788; // 0x314
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_6             = 792; // 0x318
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_7             = 796; // 0x31C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_8             = 800; // 0x320
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_9             = 804; // 0x324
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_10            = 808; // 0x328
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_11            = 812; // 0x32C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_12            = 816; // 0x330
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_13            = 820; // 0x334
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_14            = 824; // 0x338
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_15            = 828; // 0x33C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_16            = 832; // 0x340
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_17            = 836; // 0x344
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_18            = 840; // 0x348
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_19            = 844; // 0x34C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_20            = 848; // 0x350
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_21            = 852; // 0x354
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_22            = 856; // 0x358
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_23            = 860; // 0x35C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_24            = 864; // 0x360
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_25            = 868; // 0x364
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_26            = 872; // 0x368
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_27            = 876; // 0x36C
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_28            = 880; // 0x370
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_29            = 884; // 0x374
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_30            = 888; // 0x378
localparam int DLA_DMA_CSR_OFFSET_FBS_FILTER_DATA_31            = 892; // 0x37C
localparam int DLA_DMA_CSR_OFFSET_FBS_CONF_UPDATE_CONTROL       = 896; // 0x380

//bit positions in interrupt control and mask
localparam int DLA_DMA_CSR_INTERRUPT_ERROR_BIT = 0;
localparam int DLA_DMA_CSR_INTERRUPT_DONE_BIT  = 1;

//bit positions in descriptor diagnostic
localparam int DLA_DMA_CSR_DESC_DIAGNOSTICS_OVERFLOW_BIT    = 0;
localparam int DLA_DMA_CSR_DESC_DIAGNOSTICS_ALMOST_FULL_BIT = 1;
localparam int DLA_DMA_CSR_DESC_DIAGNOSTICS_OUT_OF_INFERENCES_BIT = 2;

//descriptor queue
//runtime knows how many jobs it has enqueued and how many jobs have finished
//runtime is responsible for not overflowing the descriptor queue, it must limit the number of outstanding jobs queued in hardware
localparam int DLA_DMA_CSR_DESCRIPTOR_QUEUE_LOGICAL_SIZE  = 64;   //max number of jobs that runtime can enqueue
localparam int DLA_DMA_CSR_DESCRIPTOR_QUEUE_WORDS_PER_JOB = 8;    //how many words in the queue are needed to enqueue 1 job
localparam int DLA_DMA_CSR_DESCRIPTOR_QUEUE_PHYSICAL_SIZE = DLA_DMA_CSR_DESCRIPTOR_QUEUE_LOGICAL_SIZE * DLA_DMA_CSR_DESCRIPTOR_QUEUE_WORDS_PER_JOB; //number of words in the hardware queue

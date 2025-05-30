// Copyright 2024 Altera Corporation.
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

// This is a package file used for keeping all of the data structures and 
// parameters for the DMA Core
`include "ofs_plat_if.vh"

package dma_pkg;
  `define NUM_RD_FSM_STATES 6
  `define NUM_WR_FSM_STATES 6
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
  //
  // Parameters
  //
  // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

  localparam DMA_DATA_FIFO_DEPTH = 32;
  localparam DMA_DESCRIPTOR_FIFO_DEPTH = 16;
  localparam DMA_DESCRIPTOR_FIFO_DEPTH_ENCODED = 
    (DMA_DESCRIPTOR_FIFO_DEPTH == 8)    ? 0 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 16)   ? 1 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 32)   ? 2 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 64)   ? 3 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 128)  ? 4 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 256)  ? 5 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 512)  ? 6 :
    (DMA_DESCRIPTOR_FIFO_DEPTH == 1024) ? 7 : 'X; // 'X for undefined cases
  
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
    //
    // CSR
    //
    // +++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

    // =========================================================================
    //
    // DMA Configuration/Settings 
    //
    // =========================================================================
    localparam ENABLED  = 1; 
    localparam DISABLED = 0; 
    localparam NOT_SUPPORTED = '0;
    localparam ENABLE_ERROR = 1;

    // =========================================================================
    //
    // CSR Indices.  Each CSR is 64 Bits wide. 
    //
    // =========================================================================

    localparam DMA_DFH                = 5'h0;   // R
    localparam DMA_GUID_L             = 5'h1;   // R
    localparam DMA_GUID_H             = 5'h2;   // R
    localparam DMA_RSVD_1             = 5'h3;   // -
    localparam DMA_RSVD_2             = 5'h4;   // -
    localparam DMA_SRC_ADDR           = 5'h5;   // R/W
    localparam DMA_DEST_ADDR          = 5'h6;   // R/W
    localparam DMA_LENGTH             = 5'h7;   // R/W
    localparam DMA_DESCRIPTOR_CONTROL = 5'h8;   // R/W
    localparam DMA_STATUS             = 5'h9;   // R
    localparam DMA_CONTROL            = 5'hA;   // R/W
    localparam DMA_WR_RE_FILL_LEVEL   = 5'hB;   // R
    localparam DMA_RESP_FILL_LEVEL    = 5'hC;   // R
    localparam DMA_WR_RE_SEQ_NUM      = 5'hD;   // R
    localparam DMA_CONFIG_1           = 5'hE;   // R
    localparam DMA_CONFIG_2           = 5'hF;   // R
    localparam DMA_TYPE_VERSION       = 5'h10;  // R
    localparam DMA_RD_SRC_PERF_CNTR   = 5'h11;  // R
    localparam DMA_WR_DEST_PERF_CNTR  = 5'h12;  // R

    localparam DMA_CSR_REG_W  = 64;
    localparam DMA_CSR_USED_W = 32;
    
    // =========================================================================
    //
    // Header Definitions
    //
    // =========================================================================

    typedef struct packed {
      logic [DMA_CSR_REG_W-1:0] dfh;
      logic [DMA_CSR_REG_W-1:0] guid_l;
      logic [DMA_CSR_REG_W-1:0] guid_h;
      logic [DMA_CSR_REG_W-1:0] rsvd_1;
      logic [DMA_CSR_REG_W-1:0] rsvd_2;
    } t_dma_header;

    // =========================================================================
    //
    // Descriptor Definitions
    //
    // =========================================================================

    // Addresses/offsets:
    localparam int MAX_DLA_INSTANCES = local_mem_cfg_pkg::LOCAL_MEM_NUM_BANKS;
    localparam int DDR_BANK_ADDR_W = local_mem_cfg_pkg::LOCAL_MEM_BYTE_ADDR_WIDTH;
    localparam int DDR_ADDR_W = $clog2(MAX_DLA_INSTANCES) + DDR_BANK_ADDR_W;
    localparam int HOST_ADDR_W = ofs_plat_host_chan_pkg::ADDR_WIDTH_BYTES;
    localparam SRC_ADDR_W = (HOST_ADDR_W > DDR_ADDR_W) ? HOST_ADDR_W : DDR_ADDR_W; //choose the larger address width so we support both directions
    localparam DEST_ADDR_W = SRC_ADDR_W;
    localparam LENGTH_W = 20;
    localparam AXI_MM_DATA_W = 512;
    localparam AXI_LEN_W = 8; // n6001: 8; d5005: 5
    localparam AXI_MM_DATA_W_BYTES = AXI_MM_DATA_W / 8;
    localparam DDR_DATA_W = AXI_MM_DATA_W;
    localparam HOST_DATA_W = AXI_MM_DATA_W;
    localparam PERF_CNTR_W = LENGTH_W;

    typedef enum logic [1:0] {
        OKAY,
        EXOKAY,
        SLVERR,
        DECERR
    } e_resp_enc;

    typedef enum logic [1:0] {
       BURST_FIXED,
       BURST_INCR,
       BURST_WRAP,
       BURST_RESERVED
    } e_axi_burst_type;

    typedef enum logic [1:0] {
       STAND_BY,
       HOST_TO_DDR, 
       DDR_TO_HOST, 
       DDR_TO_DDR
    } e_dma_mode;

    typedef struct packed{
      logic       go;                           // 31    - When asserted, the contents of the descriptor 
                                                //         are committed and are sent to the descriptor engine, 
                                                //         where it will be serviced by the DMA Engine
      logic [2:0] rsvd_30_28;                   // 30:28
      e_dma_mode  mode;                         // 27:26 - Mode, or direction, of transfer.  
                                                //         Options are
                                                //         0:Nominal
                                                //         1:DDR_TO_HOST
                                                //         2:HOST_TO_DDR 
                                                //         3:DDR_TO_DDR (not supported)
      logic [25:0] rsvd_25_0;                   // 25:0
    } t_dma_descriptor_control;

    typedef struct packed{
        logic [SRC_ADDR_W-1:0] src_addr;
        logic [DEST_ADDR_W-1:0] dest_addr;
        logic [LENGTH_W-1:0] length;
        t_dma_descriptor_control descriptor_control;
    } t_dma_descriptor;

    // =========================================================================
    //
    // Register Definitions
    //
    // =========================================================================
    typedef struct packed {
      logic [PERF_CNTR_W-1:0]  wr_dest_clk_cnt;
      logic [PERF_CNTR_W-1:0]  wr_dest_valid_cnt;
    } t_wr_dest_perf_cntr; 

    typedef struct packed {
      logic [PERF_CNTR_W-1:0]  rd_src_clk_cnt;
      logic [PERF_CNTR_W-1:0]  rd_src_valid_cnt;                          
    } t_rd_src_perf_cntr;

    typedef struct packed {
      t_wr_dest_perf_cntr wr_dest_perf_cntr;
      t_rd_src_perf_cntr  rd_src_perf_cntr;
      logic [35:0]  rsvd_63_30;
      logic [1:0] dma_mode;                                           // 33:32
      logic [$clog2(DMA_DESCRIPTOR_FIFO_DEPTH)-1:0] descriptor_count; // 31:28
      logic [`NUM_RD_FSM_STATES-1:0] rd_state;                        // 27:22
      logic [`NUM_WR_FSM_STATES-1:0] wr_state;                        // 21:16
      logic [1:0]  rd_resp_enc;                                       // 15:14
      logic        rd_rsp_err;                                        // 13 
      logic [1:0]  wr_resp_enc;                                       // 12:11
      logic        wr_rsp_err;                                        // 10
      logic        rsvd_9;                                            // 9
      logic        rsvd_8;                                            // 8
      logic        stopped_on_error;                                  // 7
      logic        resetting;                                         // 6
      logic        stopped;                                           // 5
      logic        response_fifo_full;                                // 4
      logic        response_fifo_empty;                               // 3
      logic        descriptor_fifo_full;                              // 2
      logic        descriptor_fifo_empty;                             // 1
      logic        busy;                                              // 0
    } t_dma_csr_status;

    typedef struct packed {
      logic [25:0] rsvd_31_6;                    // 31:6
      logic        stop_descriptors;             // 5
      logic        rsvd_4;                       // 4
      logic        rsvd_3;                       // 3
      logic        stop_on_error;                // 2
      logic        reset_dispatcher;             // 1
      logic        stop_dispatcher;              // 0
    } t_dma_csr_control;

    typedef struct packed {
      logic [15:0] write;  // 31-16
      logic [15:0] read;   // 15-0
    } t_dma_csr_wr_re_fill_level;

    typedef struct packed {
      logic [15:0] rsvd_31_16;      // 31-16
      logic [15:0] resp; // 15-0 
    } t_dma_csr_resp_fill_level;

    typedef struct packed {
      logic [15:0] write;  // 31-16
      logic [15:0] read;   // 15-0
    } t_dma_csr_seq_num;

    typedef struct packed {
      logic [4:0] max_byte;               // 31:27
      logic [3:0] max_burst_count;        // 26:23
      logic [2:0] error_width;            // 22:20
      logic       error_enable;           // 19
      logic       enhanced_features;      // 18
      logic [2:0] descriptor_fifo_depth;  // 15:13
      logic [2:0] data_width;             // 12:10
      logic [3:0] data_fifo_depth;        // 9:6
      logic [2:0] channel_width;          // 5:3
      logic       channel_enable;         // 2
      logic       burst_wrapping_support; // 1
      logic       burst_enable;           // 0
    } t_dma_csr_config1;

    typedef struct packed {
      logic [8:0]  clk_speed_mhz;               // 31:23
      logic [1:0]  transfer_type;               // 22:21
      logic [1:0]  response_port;               // 20:19
      logic        programmable_burst_enable;   // 18
      logic        prefetcher_enable;           // 17
      logic        packet_enable;               // 16
      logic [14:0] max_stride;                  // 15:1
      logic        stride_enable;               // 0
    } t_dma_csr_config2;

    typedef struct packed {
      logic [15:0] rsvd;    // 31-16
      logic [7:0]  component_type;    // 15-8
      logic [7:0]  version; // 7-0 
    } t_dma_csr_info;

    typedef struct packed {
      t_dma_header               header;
      t_dma_descriptor           descriptor;
      t_dma_csr_status           status;
      t_dma_csr_control          control;
      t_dma_csr_wr_re_fill_level wr_re_fill_level;
      t_dma_csr_resp_fill_level  resp_fill_level;
      t_dma_csr_seq_num          seq_num;
      t_dma_csr_config1          config1;
      t_dma_csr_config2          config2;
      t_dma_csr_info             info;
    } t_dma_csr_map;

endpackage : dma_pkg

// Copyright 2020-2022 Altera Corporation.
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


// This is the top level module for coreDLA DMA.
//
// This module includes the following:
// - CSR (which contains interrupt generating logic as well as descriptor queue)
// - config reader (which provides input data to config network)
// - filter reader (which provides input data to filter caches)
// - feature reader (which provides input data to stream buffers)
// - DDR arbitration of the readers
// - feature writer (which accepts output data to write to DDR)
//
// The FD and a highly illustrative design review are available at:
// https://sharepoint.amr.ith.intel.com/sites/DLA/Shared%20Documents/Forms/AllItems.aspx?RootFolder=%2Fsites%2FDLA%2FShared%20Documents%2FcoreDLA%2FFDs%5FTest%5FPlans%2FDMA%5FFD
//
// Outside of coreDLA DMA, one still needs to arbitrate DDR between PCIe and DLA.
// All interfaces of coreDLA DMA are AXI, which means if the outside world favors
// AvalonMM then the conversion of interfaces must be done outside of coreDLA.
// The testbench uses AXI BFMs for DDR and PCIe, inside these bus functional models
// are synthesizable code that converts between AXI and Avalon and then uses an
// Avalon BFM.
//
// DMA IP depends on other IP blocks, which are listed below:
// - dla/fpga/hld_lsu/rtl
// - dla/fpga/hld_fifo/rtl
// - dla/fpga/acl_dcfifo/rtl
// - dla/fpga/acl_reset_handler/rtl
//
// Not all AXI ports have been implemented. The following assumptions have been made:
// - id can be assumed to be 0 if not provided (only arid on the ddr interface is provided because there are 3 readers)
// - burst length is limited to 2**DDR_BURST_WIDTH words in a burst even through the signal width is 8 (as per the axi4 spec)
// - lock is not used (no atomic access), encoded as 2'b00
// - cache is not used, device non-bufferable is encoded as 4'b0000
// - prot is not used, no need to protect against illegal transactions, encode as 3'b000
// - qos is not used, encode as 4'b0000 to indicate no participation in any quality of service scheme
// - region is not used, no need for multiple regions, encode as 4'b0000
// - user sideband signals are not used
// - if wstrb (byte enable) is not provided, assume all bytes are updated during a write, encode as all ones
// - response value is ignored for both reads and writes, status assumed to be okay, encoded as 2'h00
// - read last (last word in a burst) value is ignored since number of words in each burst is tracked internally
// - low power interface signals are not used
//
// Unrelated to the AXI spec itself, beware of the following restrictions on the AXI interfaces:
// - all addresses are word aligned (required by AvalonMM, not required by AXI)
//   - csr is a slave, it expects the master to produce such transactions
//   - ddr is a master, this simplification can be exploited by the slave e.g. an AXI to AvalonMM converter
// - bursts will never cross a burst boundary, e.g. if max burst size is 1024 bytes, no burst will ever cross a 1024 byte boundary
//
// This module will internally bias in favour of writes to DDR rather than reads.  This is a performance optimization
// for the IP core.  The readers in the core will happily continue reading even if the compute engine is stalled due
// to a full output fifo, so it is believed that keeping the (expensive) output fifo empty is more important than
// pre-loading the input buffers (which tend to be large anyways in order to avoid DDR reads entirely).  (Limited
// anecdotal evidence supports this hypothesis, as well).
//
// Note that the CoreDLA IP has never been tested without the write-over-read priority.  It is not impossible that
// there is a subtle hidden functional requirement for this prioritization (but it seems unlikely except in the
// case of an extreme imbalance against writes).
//

`resetall
`undefineall
`default_nettype none
`include "dla_acl_parameter_assert.svh"

module dla_dma import dla_dma_pkg::*; #(
    parameter int CSR_ADDR_WIDTH,               //width of the byte address signal, determines CSR address space size, e.g. 11 bit address = 2048 bytes, the largest size that uses only 1 M20K
    parameter int CSR_DATA_BYTES,               //width of the CSR data path, typically 4 bytes
    parameter int CONFIG_ADDR_WIDTH,            //width of the configuration RAM memory write address in DDR-free mode.
    parameter int CONFIG_DATA_BYTES,            //data width of the config network output port, typically 4 bytes
    parameter int CONFIG_READER_DATA_BYTES,     //data width of the config network input port, typically 8 bytes
    parameter int FILTER_READER_DATA_BYTES,     //data width of the filter reader, typically a whole DDR word (assuming block floating point, C_VECTOR=16 so 4 filter words packed into 1 DDR word)
    parameter int FEATURE_READER_DATA_BYTES,    //data width of the feature reader, typically half of a DDR word for C_VECTOR=16 (assuming FP16 or smaller)
    parameter int FEATURE_WRITER_DATA_BYTES,    //data width of the feature writer, typically half of a DDR word for C_VECTOR=16 (assuming FP16 or smaller)
    parameter int DDR_ADDR_WIDTH,               //width of all byte address signals to global memory, 32 would allow 4 GB of addressable memory
    parameter int DDR_BURST_WIDTH,              //internal width of the axi burst length signal, typically 4, max number of words in a burst = 2**DDR_BURST_WIDTH
    parameter int DDR_DATA_BYTES,               //width of the global memory data path, must be a power of 2, typically 64 bytes
    parameter int DDR_READ_ID_WIDTH,            //width of the AXI ID signal for DDR reads, must be 2 since there are 3 read masters
    parameter int DDR_WRITE_ID_WIDTH,           //width of the AXI ID signal for DDR writes, must be between 1 and 8. Used by CoreDLA to improve write efficiency since EMIF on AGX5 can reorder writes with different IDs, but not with the same ID.

    parameter bit ENABLE_INPUT_STREAMING,
    parameter bit ENABLE_OUTPUT_STREAMING,

    // Parameters useful for scratchpad online configuration
    parameter int SCRATCHPAD_MEM_ADDR_WIDTH,
    parameter int SCRATCHPAD_DATA_WIDTH,
    parameter bit DISABLE_DDR,

    parameter dla_common_pkg::device_family_t DEVICE, //enumerated device value, required for dma writer
    parameter dla_lt_pkg::lt_arch_t LT_ARCH = '{default:0},        // the arch for the dedicated layout transform (if it exists)
    parameter dla_lw_lt_pkg::lw_lt_arch_t LW_LT_ARCH = '{LW_LT_ENABLED:0,
                                                        CONFIG_BYTES:0,
                                                        CVEC:0,
                                                        AXI_WIDTH:0,
                                                        CHANNELS:0,
                                                        CONV_MODE:dla_lt_pkg::convert_mode_t'(0),
                                                        DEVICE:dla_common_pkg::device_family_t'(0),
                                                        ENABLE_IN_BIAS_SCALE:0,
                                                        PIXEL_EXIT_FIFO_DEPTH:0
                                                    },
    parameter bit ENABLE_ON_CHIP_PARAMETERS,    // Whether configs and filters are on-chip, meaning config reader and filter reader can be disabled
    parameter int LAYOUT_TRANSFORM_WRITEBACK_MODE = 0,
    //derived parameters and constants
    localparam int AXI_BURST_LENGTH_WIDTH = 8,  //width of the axi burst length signal as per the axi4 spec
    localparam int AXI_BURST_SIZE_WIDTH = 3,    //width of the axi burst size signal as per the axi4 spec
    localparam int AXI_BURST_TYPE_WIDTH = 2     //width of the axi burst type signal as per the axi4 spec
) (
    input  wire                                     clk_ddr,
    input  wire                                     clk_dla,
    input  wire                                     clk_pcie,
    input  wire                                     i_resetn_async,     //active low reset that has NOT been synchronized to any clock

    //interrupt request, AXI4 stream master without data, runs on pcie clock
    output logic                                    o_interrupt_level,

    //dla can report an error to dma csr by asserting this for one clock cycle, runs on ddr clock
    input  wire                                     i_token_error,

    //CSR can request a reset of the DLA IP by asserting this signal (held until reset), runs on ddr clock
    output logic                                    o_request_ip_reset,

    input wire                                      i_stream_started, //indicates that the first word of the input stream is being read this cycle
    input wire                                      i_stream_done, //indcates that the output streamer is done writing the output feature

    //Output streamer license and status signals.
    input wire                                      i_ostream_is_licensed,
    input wire                                      i_ostream_stream_error,

    // Indicates when input feeder received the first word (aka input streamer sent the first word)
    // and xbar sent the last word (aka output streamer received the last word)
    input wire                                      i_stream_received_first_word,
    input wire                                      i_stream_sent_last_word,

    //CSR, AXI4 lite slave, runs on ddr clock
    input  wire                                     i_csr_arvalid,
    input  wire                [CSR_ADDR_WIDTH-1:0] i_csr_araddr,
    output logic                                    o_csr_arready,
    output logic                                    o_csr_rvalid,
    output logic             [8*CSR_DATA_BYTES-1:0] o_csr_rdata,
    input  wire                                     i_csr_rready,
    input  wire                                     i_csr_awvalid,
    input  wire                [CSR_ADDR_WIDTH-1:0] i_csr_awaddr,
    output logic                                    o_csr_awready,
    input  wire                                     i_csr_wvalid,
    input  wire              [8*CSR_DATA_BYTES-1:0] i_csr_wdata,
    output logic                                    o_csr_wready,
    output logic                                    o_csr_bvalid,
    input  wire                                     i_csr_bready,

    //config reader data, AXI4 stream master, runs on dla clock
    output logic                                    o_config_reader_valid,
    output logic   [8*CONFIG_READER_DATA_BYTES-1:0] o_config_reader_data,
    input  wire                                     i_config_reader_ready,

    // Config intercept interface for on-chip parameter mode (from CSR descriptor queue to config network)
    // These signals pass runtime address offsets to dla_ddrfree_config_data_read
    output logic                                    o_on_chip_param_intercept_config_valid,
    output logic          [8*CONFIG_DATA_BYTES-1:0] o_on_chip_param_intercept_config_data,
    input  wire                                     i_on_chip_param_intercept_config_ready,

    //config for filter reader, AXI4 stream slave, runs on ddr clock
    input  wire                                     i_config_filter_reader_valid,
    input  wire           [8*CONFIG_DATA_BYTES-1:0] i_config_filter_reader_data,
    output logic                                    o_config_filter_reader_ready,

    //filter reader data, AXI4 stream master, runs on dla clock
    output logic                                    o_filter_reader_valid,
    output logic   [8*FILTER_READER_DATA_BYTES-1:0] o_filter_reader_data,
    input  wire                                     i_filter_reader_ready,

    //config for feature reader, AXI4 stream slave, runs on ddr clock
    input  wire                                     i_config_feature_reader_valid,
    input  wire           [8*CONFIG_DATA_BYTES-1:0] i_config_feature_reader_data,
    output logic                                    o_config_feature_reader_ready,

    //config for layout transform
    input wire                                      i_config_lt_reader_valid,
    input wire            [8*CONFIG_DATA_BYTES-1:0] i_config_lt_reader_data,
    output logic                                    o_config_lt_reader_ready,

    //feature reader data, AXI4 stream master, runs on dla clock
    output logic                                    o_feature_reader_valid,
    output logic  [8*FEATURE_READER_DATA_BYTES-1:0] o_feature_reader_data,
    input  wire                                     i_feature_reader_ready,

    //config for feature writer, AXI4 stream slave, runs on ddr clock
    input  wire                                     i_config_feature_writer_valid,
    input  wire           [8*CONFIG_DATA_BYTES-1:0] i_config_feature_writer_data,
    output logic                                    o_config_feature_writer_ready,

    //feature writer data, AXI4 stream slave, runs on ddr clock
    input  wire                                     i_feature_writer_valid,
    input  wire   [8*FEATURE_WRITER_DATA_BYTES-1:0] i_feature_writer_data,
    output logic                                    o_feature_writer_ready,

    //debug network AXI-4 lite interface, read request and read response channels, runs on dla_clock
    output logic                                    o_debug_network_arvalid,
    output logic             [8*CSR_DATA_BYTES-1:0] o_debug_network_araddr,
    input  wire                                     i_debug_network_arready,
    input  wire                                     i_debug_network_rvalid,
    input  wire              [8*CSR_DATA_BYTES-1:0] i_debug_network_rdata,
    output logic                                    o_debug_network_rready,

    //CSR to scratchpad interface, only useful for ddr-free online configuration
    scratchpad_update_if.sender                     o_scratchpad_update_if,
    output logic                                    o_scratchpad_write_en,

    //CSR to instruction module interface, only useful for ddr-free online configuration
    configuration_update_if.sender                  o_config_update_if,

    //LT writeback data
    input  wire                            i_lt_wb_awvalid,
    input  wire       [DDR_ADDR_WIDTH-1:0] i_lt_wb_awaddr,
    input  wire      [DDR_BURST_WIDTH-1:0] i_lt_wb_awlen,
    output logic                           o_lt_wb_awready,
    input  wire                            i_lt_wb_wvalid,
    input  wire     [8*DDR_DATA_BYTES-1:0] i_lt_wb_wdata,
    input  wire       [DDR_DATA_BYTES-1:0] i_lt_wb_wstrb,
    input  wire                            i_lt_wb_wlast,
    output logic                           o_lt_wb_wready,
    output logic                           o_lt_wb_bvalid,
    input  wire                            i_lt_wb_bready,

    //outgoing LT data, AXI4 stream master, runs on ddr clock
    output logic                            o_lw_tb_read_last, // indicates that the last word of the read has been initiated

    output logic [DDR_ADDR_WIDTH-1:0] o_wb_base_addr,
    output logic [DDR_ADDR_WIDTH-1:0] o_wb_frame_size,
    output logic [DDR_ADDR_WIDTH-1:0] o_wb_addr_range,
    output logic o_wb_start, //acts as a valid signal for the base and range signals, and starts the memory manager

    input wire [DDR_ADDR_WIDTH-1:0] i_read_addr,
    input wire i_read_addr_valid,
    output logic o_read_addr_ready,

    //global memory, AXI4 master, runs on ddr clock
    output logic                                    o_ddr_arvalid,
    output logic               [DDR_ADDR_WIDTH-1:0] o_ddr_araddr,
    output logic       [AXI_BURST_LENGTH_WIDTH-1:0] o_ddr_arlen,
    output logic         [AXI_BURST_SIZE_WIDTH-1:0] o_ddr_arsize,
    output logic         [AXI_BURST_TYPE_WIDTH-1:0] o_ddr_arburst,
    output logic            [DDR_READ_ID_WIDTH-1:0] o_ddr_arid,
    input  wire                                     i_ddr_arready,
    input  wire                                     i_ddr_rvalid,
    input  wire              [8*DDR_DATA_BYTES-1:0] i_ddr_rdata,
    input  wire             [DDR_READ_ID_WIDTH-1:0] i_ddr_rid,
    output logic                                    o_ddr_rready,
    output logic                                    o_ddr_awvalid,
    output logic               [DDR_ADDR_WIDTH-1:0] o_ddr_awaddr,
    output logic       [AXI_BURST_LENGTH_WIDTH-1:0] o_ddr_awlen,
    output logic         [AXI_BURST_SIZE_WIDTH-1:0] o_ddr_awsize,
    output logic         [AXI_BURST_TYPE_WIDTH-1:0] o_ddr_awburst,
    output logic           [DDR_WRITE_ID_WIDTH-1:0] o_ddr_awid,
    input  wire                                     i_ddr_awready,
    output logic                                    o_ddr_wvalid,
    output logic             [8*DDR_DATA_BYTES-1:0] o_ddr_wdata,
    output logic               [DDR_DATA_BYTES-1:0] o_ddr_wstrb,
    output logic                                    o_ddr_wlast,
    input  wire                                     i_ddr_wready,
    input  wire                                     i_ddr_bvalid,
    output logic                                    o_ddr_bready,
    output logic                                    o_core_streaming_active,
    output logic                                    o_streaming_active,
    output logic                                    o_done_write
);

    /////////////////////////////////
    //  Parameter legality checks  //
    /////////////////////////////////
    //do not allow number of words per burst to exceed the axi spec (even through the LSU will behave just fine)
    `DLA_ACL_PARAMETER_ASSERT(DDR_BURST_WIDTH <= AXI_BURST_LENGTH_WIDTH)

    //id width on the ddr interface is a parameter instead of localparam only so that if the value changes,
    //then it can be changed in one place instead all everywhere the signal width is used
    //3 readers requires
    `DLA_ACL_PARAMETER_ASSERT(DDR_READ_ID_WIDTH == 2)

    //Keeping the write ID between 1 and 8 to keep the counter sufficiently small.
    `DLA_ACL_PARAMETER_ASSERT(DDR_WRITE_ID_WIDTH >= 1 && DDR_WRITE_ID_WIDTH <= 8)

    //data width is limited by the axi spec
    `DLA_ACL_PARAMETER_ASSERT(DDR_DATA_BYTES >= 1 && DDR_DATA_BYTES <= 128)

    //load-store units require a power of 2 width for the global memory interface
    `DLA_ACL_PARAMETER_ASSERT(DDR_DATA_BYTES == 2**$clog2(DDR_DATA_BYTES))


    ///////////////
    //  Signals  //
    ///////////////

    //reset
    logic                           ddr_sclrn;

    //feature writer reports it is done, goes to csr and feature reader
    logic                           token_done_csr, token_done_reader;

    logic                           writer_license_flag;
    logic                           writer_error;

    //csr to config reader or to ddrfree config network (langsu: latter is not implemented yet)
    logic [8*CONFIG_DATA_BYTES-1:0] csr_config_data;
    logic                           csr_config_valid, csr_config_for_intercept, csr_config_ready;

    //lsu to read arb
    logic                           lsu_ddr_arvalid [NUM_READERS-1:0];
    logic      [DDR_ADDR_WIDTH-1:0] lsu_ddr_araddr  [NUM_READERS-1:0];
    logic     [DDR_BURST_WIDTH-1:0] lsu_ddr_arlen   [NUM_READERS-1:0];
    logic                           lsu_ddr_arready [NUM_READERS-1:0];
    logic                           lsu_ddr_rvalid  [NUM_READERS-1:0];
    logic    [8*DDR_DATA_BYTES-1:0] lsu_ddr_rdata   [NUM_READERS-1:0];
    logic                           lsu_ddr_rready  [NUM_READERS-1:0];

    //favor writes over reads for ddr; see the comment block by the
    //combinational logic associated with these signals for the explanation
    //of their naming.
    logic                           dma_prevcycle_read_not_acknowledged;
    logic                           write_overrides_read;
    logic                           rawp_ddr_awvalid, rawp_ddr_wvalid;
    logic                           rawf_ddr_awready, rawf_ddr_wready;
    logic                           rawp_ddr_arvalid;
    logic                           rawf_ddr_arready;

    //axi spec requires a signal width of 8 for burst length
    logic     [DDR_BURST_WIDTH-1:0] raw_ddr_arlen;
    logic     [DDR_BURST_WIDTH-1:0] raw_ddr_awlen;

    //used to backpressure ddrfree config network read
    logic                           streaming_reload;
    logic                           lt_param_error;

    logic                                    dla_awvalid;
    logic               [DDR_ADDR_WIDTH-1:0] dla_awaddr;
    logic       [AXI_BURST_LENGTH_WIDTH-1:0] dla_awlen;
    logic         [AXI_BURST_SIZE_WIDTH-1:0] dla_awsize;
    logic         [AXI_BURST_TYPE_WIDTH-1:0] dla_awburst;
    logic                                    dla_awready;
    logic                                    dla_wvalid;
    logic             [8*DDR_DATA_BYTES-1:0] dla_wdata;
    logic               [DDR_DATA_BYTES-1:0] dla_wstrb;
    logic                                    dla_wlast;
    logic                                    dla_wready;
    logic                                    dla_bvalid;
    logic                                    dla_bready;

    //Small counter used for counting up DDR AXI Write IDs for successive writes.
    logic               [DDR_WRITE_ID_WIDTH-1:0] write_id_counter;

    //Scratchpad online configuration signals
    scratchpad_update_if #(
        .ADDR_WIDTH(SCRATCHPAD_MEM_ADDR_WIDTH),
        .DATA_WIDTH(SCRATCHPAD_DATA_WIDTH)
    )  scratchpad_dcfifo_write_if();
    scratchpad_update_if #(
        .ADDR_WIDTH(SCRATCHPAD_MEM_ADDR_WIDTH),
        .DATA_WIDTH(SCRATCHPAD_DATA_WIDTH)
    )  scratchpad_dcfifo_read_if();
    logic               csr_scratchpad_write_valid, csr_scratchpad_write_ready;
    localparam SCRATCHPAD_DCFIFO_DATA_WIDTH = SCRATCHPAD_MEM_ADDR_WIDTH + SCRATCHPAD_DATA_WIDTH + 1;

    //Configuration online configuration signals
    //For interfacing with the DCFIFO
    configuration_update_if #(
        .ADDR_WIDTH                     (CONFIG_ADDR_WIDTH),
        .DATA_WIDTH                     (CONFIG_READER_DATA_BYTES * 8)
    ) csr_config_dcfifo_write_if ();
    logic csr_config_dcfifo_write_ready;
    localparam CONFIG_DCFIFO_WIDTH = CONFIG_ADDR_WIDTH + CONFIG_READER_DATA_BYTES * 8;

    /////////////////////////////
    //  Reset Synchronization  //
    /////////////////////////////

    dla_reset_handler_simple #(
        .USE_SYNCHRONIZER   (RESET_USE_SYNCHRONIZER),
        .PIPE_DEPTH         (RESET_PIPE_DEPTH),
        .NUM_COPIES         (RESET_NUM_COPIES)
    )
    ddr_reset_synchronizer
    (
        .clk                (clk_ddr),
        .i_resetn           (i_resetn_async),
        .o_sclrn            (ddr_sclrn)
    );



    ///////////
    //  CSR  //
    ///////////

    //includes register interface for host control as well as interrupt
    //contains the descriptor queue for providing work to the config reader

    dla_dma_csr #(
        .CSR_ADDR_WIDTH             (CSR_ADDR_WIDTH),
        .CSR_DATA_BYTES             (CSR_DATA_BYTES),
        .CONFIG_ADDR_WIDTH          (CONFIG_ADDR_WIDTH),
        .CONFIG_DATA_BYTES          (CONFIG_DATA_BYTES),
        .CONFIG_READER_DATA_BYTES   (CONFIG_READER_DATA_BYTES),
        .ENABLE_INPUT_STREAMING     (ENABLE_INPUT_STREAMING),
        .ENABLE_OUTPUT_STREAMING    (ENABLE_OUTPUT_STREAMING),
        .ENABLE_ON_CHIP_PARAMETERS  (ENABLE_ON_CHIP_PARAMETERS),
        .DISABLE_DDR                (DISABLE_DDR),
        .DEVICE_FAMILY              (DEVICE),
        .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
        .LAYOUT_TRANSFORM_WRITEBACK_MODE (LAYOUT_TRANSFORM_WRITEBACK_MODE)
    )
    csr
    (
        .clk_ddr                      (clk_ddr),
        .clk_pcie                     (clk_pcie),
        .clk_dla                      (clk_dla),
        .i_sclrn_ddr                  (ddr_sclrn),
        .i_resetn_async               (i_resetn_async),
        .i_token_done                 (token_done_csr | (i_stream_done & ENABLE_OUTPUT_STREAMING)),
        .i_token_stream_started       (i_stream_started),
        .i_token_error                (i_token_error | lt_param_error),
        .i_stream_received_first_word (i_stream_received_first_word),
        .i_stream_sent_last_word      (i_stream_sent_last_word),
        .i_license_flag               (writer_license_flag & i_ostream_is_licensed),
        .i_token_out_of_inferences    (writer_error | i_ostream_stream_error),

        .o_wb_base_addr               (o_wb_base_addr),
        .o_wb_frame_size              (o_wb_frame_size),
        .o_wb_addr_range              (o_wb_addr_range),
        .o_wb_start                   (o_wb_start),

        .i_input_feature_rvalid       (lsu_ddr_rvalid[FEATURE_READER_ID]),
        .i_input_feature_rready       (lsu_ddr_rready[FEATURE_READER_ID]),
        .i_input_filter_rvalid        (lsu_ddr_rvalid[FILTER_READER_ID]),
        .i_input_filter_rready        (lsu_ddr_rready[FILTER_READER_ID]),
        .i_output_feature_wvalid      (rawp_ddr_wvalid),
        .i_output_feature_wready      (rawf_ddr_wready),
        .o_interrupt_level            (o_interrupt_level),
        .o_config_valid               (csr_config_valid),
        .o_config_data                (csr_config_data),
        .o_config_for_intercept       (csr_config_for_intercept),
        .i_config_ready               (csr_config_ready),
        .o_debug_network_arvalid      (o_debug_network_arvalid),
        .o_debug_network_araddr       (o_debug_network_araddr),
        .i_debug_network_arready      (i_debug_network_arready),
        .i_debug_network_rvalid       (i_debug_network_rvalid),
        .i_debug_network_rdata        (i_debug_network_rdata),
        .o_debug_network_rready       (o_debug_network_rready),
        .i_csr_arvalid                (i_csr_arvalid),
        .i_csr_araddr                 (i_csr_araddr),
        .o_csr_arready                (o_csr_arready),
        .o_csr_rvalid                 (o_csr_rvalid),
        .o_csr_rdata                  (o_csr_rdata),
        .i_csr_rready                 (i_csr_rready),
        .i_csr_awvalid                (i_csr_awvalid),
        .i_csr_awaddr                 (i_csr_awaddr),
        .o_csr_awready                (o_csr_awready),
        .i_csr_wvalid                 (i_csr_wvalid),
        .i_csr_wdata                  (i_csr_wdata),
        .o_csr_wready                 (o_csr_wready),
        .o_csr_bvalid                 (o_csr_bvalid),
        .i_csr_bready                 (i_csr_bready),
        .i_scratchpad_write_ready     (csr_scratchpad_write_ready),
        .o_scratchpad_write_enable    (csr_scratchpad_write_valid),
        .o_scratchpad_update          (scratchpad_dcfifo_write_if),
        .o_configuration_update       (csr_config_dcfifo_write_if),
        .i_config_update_write_ready  (csr_config_dcfifo_write_ready),
        .o_request_ip_reset           (o_request_ip_reset),
        .o_core_streaming_active      (o_core_streaming_active),
        .o_streaming_active           (o_streaming_active)
    );



    /////////////////////
    //  Config reader  //
    /////////////////////

    //the config interface of the generic dma reader comes from the descriptor queue inside the csr
    //output data interface of the generic dma reader serves as the input for the config network

    if (!ENABLE_ON_CHIP_PARAMETERS && !DISABLE_DDR) begin
        // When parameters and not on-chip and DDR is enabled, instantiate config reader
        dla_dma_reader #(
            .READER_WRITER_SEL          (CONFIG_READER_ID),
            .IS_CONFIG_READER           (1),
            .NUM_DIMENSIONS             (CONFIG_READER_NUM_DIMENSIONS),
            .CONFIG_DATA_BYTES          (CONFIG_DATA_BYTES),
            .READER_DATA_BYTES          (CONFIG_READER_DATA_BYTES),
            .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
            .DDR_DATA_BYTES             (DDR_DATA_BYTES),
            .DDR_BURST_WIDTH            (DDR_BURST_WIDTH),
            .LT_ARCH                    (LT_ARCH),
            .DEVICE                     (DEVICE)
        )
        config_reader
        (
            .clk_ddr                    (clk_ddr),
            .clk_dla                    (clk_dla),
            .i_sclrn_ddr                (ddr_sclrn),
            .i_resetn_async             (i_resetn_async),
            .i_config_valid             (csr_config_valid),
            .i_config_data              (csr_config_data),
            .i_config_for_intercept     (csr_config_for_intercept),
            .o_config_ready             (csr_config_ready),  // config reader is ready to receive data from csr
            .i_token_can_start          (1'b0), //config data is read only, there is no data dependency that would prevent the config reader from starting
            .o_reader_valid             (o_config_reader_valid),  // config data read is valid
            .o_reader_data              (o_config_reader_data),   // config data read from reader
            .i_reader_ready             (i_config_reader_ready),  // config network is ready to receive config data
            .o_ddr_arvalid              (lsu_ddr_arvalid[CONFIG_READER_ID]),
            .o_ddr_araddr               (lsu_ddr_araddr [CONFIG_READER_ID]),
            .o_ddr_arlen                (lsu_ddr_arlen  [CONFIG_READER_ID]),
            .i_ddr_arready              (lsu_ddr_arready[CONFIG_READER_ID]),
            .i_ddr_rvalid               (lsu_ddr_rvalid [CONFIG_READER_ID]),
            .i_ddr_rdata                (lsu_ddr_rdata  [CONFIG_READER_ID]),
            .o_ddr_rready               (lsu_ddr_rready [CONFIG_READER_ID])
        );
    end else begin
        // Indicate config_reader is ready to receive data, but we don't care.
        assign lsu_ddr_rready [CONFIG_READER_ID] = 1'b0;
        // we don't care if read addr to arbitar is valid or not
        assign lsu_ddr_arvalid[CONFIG_READER_ID] = 1'b0;
        // Don't care. config_network doesn't check valid to start ddrfree config read
        assign o_config_reader_valid = 1'b0;

        if (!ENABLE_ON_CHIP_PARAMETERS) begin
            // Parameters are not on-chip and external memory is disabled. This shouldn't happen.
            `DLA_ACL_PARAMETER_ASSERT_MESSAGE(0, "DDR cannot be disabled when parameters are not on-chip");
        end
    end

    // DDR-free + on-chip parameter mode: pass CSR config signals to config network for intercept
    // Add clock domain crossing from DDR clock to DLA clock
    // Only needed when DDR exists — the intercept pipeline injects DDR base address
    // offsets into config words. When DDR is disabled, ROM addresses are absolute
    // and no injection is required.
    if (ENABLE_ON_CHIP_PARAMETERS && !DISABLE_DDR) begin
        localparam int INTERCEPT_DCFIFO_WIDTH = 8*CONFIG_DATA_BYTES;
        localparam int INTERCEPT_DCFIFO_DEPTH = 32;  // Use entire MLAB
        localparam int INTERCEPT_DCFIFO_ALMOST_FULL_CUTOFF = 4;

        logic intercept_dcfifo_stall;
        logic intercept_dcfifo_read_empty;
        logic [INTERCEPT_DCFIFO_WIDTH-1:0] intercept_dcfifo_read_data;

        // CSR ready when DCFIFO can accept data for intercept config words
        // Non-intercept config words (for address gen) are ignored in DDR-free mode
        assign csr_config_ready = csr_config_for_intercept ? ~intercept_dcfifo_stall : 1'b1;

        dla_acl_dcfifo #(
            .WIDTH                      (INTERCEPT_DCFIFO_WIDTH),
            .DEPTH                      (INTERCEPT_DCFIFO_DEPTH),
            .ALMOST_FULL_CUTOFF         (INTERCEPT_DCFIFO_ALMOST_FULL_CUTOFF)
        )
        intercept_config_clock_crosser
        (
            .async_resetn               (i_resetn_async),

            // Write side - DDR clock domain (from CSR)
            .wr_clock                   (clk_ddr),
            .wr_req                     (csr_config_valid & csr_config_for_intercept & ~intercept_dcfifo_stall),
            .wr_data                    (csr_config_data),
            .wr_full                    (),
            .wr_almost_full             (intercept_dcfifo_stall),

            // Read side - DLA clock domain (to config network)
            .rd_clock                   (clk_dla),
            .rd_empty                   (intercept_dcfifo_read_empty),
            .rd_data                    (intercept_dcfifo_read_data),
            .rd_ack                     (i_on_chip_param_intercept_config_ready & ~intercept_dcfifo_read_empty),
            .rd_almost_empty            (),
            .wr_read_update_for_ccb     ()
        );

        assign o_on_chip_param_intercept_config_valid = ~intercept_dcfifo_read_empty;
        assign o_on_chip_param_intercept_config_data  = intercept_dcfifo_read_data;
    end else begin
        assign o_on_chip_param_intercept_config_valid = 1'b0;
        assign o_on_chip_param_intercept_config_data  = '0;
        if (ENABLE_ON_CHIP_PARAMETERS) begin
            // On-chip parameters with DDR disabled: no intercept needed, always accept CSR config words
            assign csr_config_ready = 1'b1;
        end
    end


    /////////////////////
    //  Filter reader  //
    /////////////////////

    if (!ENABLE_ON_CHIP_PARAMETERS && !DISABLE_DDR) begin
        dla_dma_reader #(
            .READER_WRITER_SEL          (FILTER_READER_ID),
            .IS_CONFIG_READER           (0),
            .NUM_DIMENSIONS             (FILTER_READER_NUM_DIMENSIONS),
            .CONFIG_DATA_BYTES          (CONFIG_DATA_BYTES),
            .READER_DATA_BYTES          (FILTER_READER_DATA_BYTES),
            .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
            .DDR_DATA_BYTES             (DDR_DATA_BYTES),
            .DDR_BURST_WIDTH            (DDR_BURST_WIDTH),
            .LT_ARCH                    (LT_ARCH),
            .DEVICE                     (DEVICE)
        )
        filter_reader
        (
            .clk_ddr                    (clk_ddr),
            .clk_dla                    (clk_dla),
            .i_sclrn_ddr                (ddr_sclrn),
            .i_resetn_async             (i_resetn_async),
            .i_config_valid             (i_config_filter_reader_valid),
            .i_config_data              (i_config_filter_reader_data),
            .i_config_for_intercept     (1'b0), //since this is not the config reader, all config data goes to the address generator
            .o_config_ready             (o_config_filter_reader_ready), // filter reader module is ready to receive config data from config network
            .i_token_can_start          (1'b0), //filter data is read only, there is no data dependency that would prevent the filter reader from starting
            .o_reader_valid             (o_filter_reader_valid),
            .o_reader_data              (o_filter_reader_data),
            .i_reader_ready             (i_filter_reader_ready),
            .o_ddr_arvalid              (lsu_ddr_arvalid[FILTER_READER_ID]),
            .o_ddr_araddr               (lsu_ddr_araddr [FILTER_READER_ID]),
            .o_ddr_arlen                (lsu_ddr_arlen  [FILTER_READER_ID]),
            .i_ddr_arready              (lsu_ddr_arready[FILTER_READER_ID]),
            .i_ddr_rvalid               (lsu_ddr_rvalid [FILTER_READER_ID]),
            .i_ddr_rdata                (lsu_ddr_rdata  [FILTER_READER_ID]),
            .o_ddr_rready               (lsu_ddr_rready [FILTER_READER_ID])
        );
    end else begin
        // Indicate filter_reader is ready to receive data, but we don't care.
        assign lsu_ddr_rready [FILTER_READER_ID] = 1'b0;
        // we don't care if read addr to arbitar is valid or not
        assign lsu_ddr_arvalid[FILTER_READER_ID] = 1'b0;
        // Don't care. Sequencer ignores this
        assign o_filter_reader_valid = 1'b0;
        // Indicate filter reader is ready to receive configs,
        // so that config network fifo pops filter reader configs out.
        // We don't really use them because we don't have any filter_reader
        assign o_config_filter_reader_ready = 1'b1;
    end


    //////////////////////
    //  Feature reader  //
    //////////////////////

    if (!DISABLE_DDR) begin
        dla_dma_reader #(
            .READER_WRITER_SEL          (FEATURE_READER_ID),
            .IS_CONFIG_READER           (0),
            .DO_LAYOUT_TRANSFORM        ((LW_LT_ARCH.LW_LT_ENABLED | LT_ARCH.ENABLE_LT) & ~ENABLE_INPUT_STREAMING & ~LAYOUT_TRANSFORM_WRITEBACK_MODE),
            .NUM_DIMENSIONS             (FEATURE_READER_NUM_DIMENSIONS),
            .CONFIG_DATA_BYTES          (CONFIG_DATA_BYTES),
            .READER_DATA_BYTES          (FEATURE_READER_DATA_BYTES),
            .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
            .DDR_DATA_BYTES             (DDR_DATA_BYTES),
            .DDR_BURST_WIDTH            (DDR_BURST_WIDTH),
            .LT_ARCH                    (LT_ARCH),
            .LW_LT_ARCH                 (LW_LT_ARCH),
            .DEVICE                     (DEVICE),
            .LAYOUT_TRANSFORM_WRITEBACK_MODE (LAYOUT_TRANSFORM_WRITEBACK_MODE)
        )
        feature_reader
        (
            .clk_ddr                    (clk_ddr),
            .clk_dla                    (clk_dla),
            .i_sclrn_ddr                (ddr_sclrn),
            .i_resetn_async             (i_resetn_async),
            .i_config_valid             (i_config_feature_reader_valid),
            .i_config_data              (i_config_feature_reader_data),
            .i_config_for_intercept     (1'b0), //since this is not the config reader, all config data goes to the address generator
            .o_config_ready             (o_config_feature_reader_ready),
            .i_config_lt_valid          (i_config_lt_reader_valid),
            .i_config_lt_data           (i_config_lt_reader_data),
            .o_config_lt_ready          (o_config_lt_reader_ready),
            .i_token_can_start          (token_done_reader),
            .o_reader_valid             (o_feature_reader_valid),
            .o_reader_data              (o_feature_reader_data),
            .i_reader_ready             (i_feature_reader_ready),
            .o_ddr_arvalid              (lsu_ddr_arvalid[FEATURE_READER_ID]),
            .o_ddr_araddr               (lsu_ddr_araddr [FEATURE_READER_ID]),
            .o_ddr_arlen                (lsu_ddr_arlen  [FEATURE_READER_ID]),
            .i_ddr_arready              (lsu_ddr_arready[FEATURE_READER_ID]),
            .i_ddr_rvalid               (lsu_ddr_rvalid [FEATURE_READER_ID]),
            .i_ddr_rdata                (lsu_ddr_rdata  [FEATURE_READER_ID]),
            .o_ddr_rready               (lsu_ddr_rready [FEATURE_READER_ID]),
            .o_param_error              (lt_param_error),

            //layout transformed data that gets written back to DDR if writeback mode is enabled
            .o_read_last                (o_lw_tb_read_last),

            //external buffer manager injects read address to the feature reader
            .i_wb_read_addr_valid       (i_read_addr_valid),
            .i_wb_read_addr             (i_read_addr),
            .o_wb_read_addr_ready       (o_read_addr_ready)
        );
    end else begin
        // Indicate feature_reader is ready to receive data, but we don't care.
        assign lsu_ddr_rready [FEATURE_READER_ID] = 1'b0;
        // we don't care if read addr to arbiter is valid or not
        assign lsu_ddr_arvalid[FEATURE_READER_ID] = 1'b0;
        // Don't care. Sequencer ignores this
        assign o_feature_reader_valid = 1'b0;
        // Indicate feature reader is ready to receive configs,
        // so that config network fifo pops feature reader configs out.
        assign o_config_feature_reader_ready = 1'b1;
        assign o_config_lt_reader_ready = 1'b1;
        assign lt_param_error = 1'b0;
        assign o_lw_tb_read_last = 1'b0;
        assign o_read_addr_ready = 1'b0;
    end



    ///////////////////////////////////////////////////////////////////////////
    //  Arbitrate read requests and steer read data for all DLA DMA readers  //
    ///////////////////////////////////////////////////////////////////////////

    //note there is another DDR arbiter between PCIe and DLA that lives outside of DLA

    if (!DISABLE_DDR) begin
        dla_dma_read_arb #(
            .NUM_PORTS                  (NUM_READERS),
            .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
            .DDR_BURST_WIDTH            (DDR_BURST_WIDTH),
            .DDR_DATA_BYTES             (DDR_DATA_BYTES),
            .DEVICE_FAMILY              (DEVICE)
        )
        read_arb
        (
            .clk                        (clk_ddr),
            .i_sclrn                    (ddr_sclrn),

            // Read requests from config, filter, and feature readers
            .i_lsu_arvalid              (lsu_ddr_arvalid),
            .i_lsu_araddr               (lsu_ddr_araddr),
            .i_lsu_arlen                (lsu_ddr_arlen),
            .o_lsu_arready              (lsu_ddr_arready),

            // Read address to the external world; tagged with an arid
            .o_ddr_arvalid              (rawp_ddr_arvalid),
            .o_ddr_araddr               (o_ddr_araddr),
            .o_ddr_arlen                (raw_ddr_arlen),
            .o_ddr_arid                 (o_ddr_arid),
            .i_ddr_arready              (rawf_ddr_arready),

            // Read data from external world
            .i_ddr_rvalid               (i_ddr_rvalid),
            .i_ddr_rdata                (i_ddr_rdata),
            .i_ddr_rid                  (i_ddr_rid),
            .o_ddr_rready               (o_ddr_rready),

            // Read data config, filter, and feature readers
            .o_lsu_rvalid               (lsu_ddr_rvalid),
            .o_lsu_rdata                (lsu_ddr_rdata),
            .i_lsu_rready               (lsu_ddr_rready)
        );
    end else begin
        // Tie off read arbiter outputs when DDR is disabled
        assign rawp_ddr_arvalid = 1'b0;
        assign o_ddr_araddr = '0;
        assign raw_ddr_arlen = '0;
        assign o_ddr_arid = '0;
        assign o_ddr_rready = 1'b0;
        for (genvar i = 0; i < NUM_READERS; i++) begin : gen_lsu_tieoff
            assign lsu_ddr_arready[i] = 1'b0;
            assign lsu_ddr_rvalid[i] = 1'b0;
            assign lsu_ddr_rdata[i] = '0;
        end
    end

    if (!DISABLE_DDR) begin : gen_write_arb_and_priority
        if (LAYOUT_TRANSFORM_WRITEBACK_MODE) begin
            // Must arbitrate between DLA's feature writes and the layout transform writeback
            dla_dma_write_arb #(
                .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
                .DDR_DATA_BYTES             (DDR_DATA_BYTES),
                .DDR_BURST_WIDTH            (DDR_BURST_WIDTH)
            ) dma_write_arb (
                .clk(clk_ddr),
                .i_sclrn(ddr_sclrn),

                // Interface A
                .i_m0_awid(0),
                .i_m0_awaddr(i_lt_wb_awaddr),
                .i_m0_awlen(i_lt_wb_awlen),
                .i_m0_awvalid(i_lt_wb_awvalid),
                .o_m0_awready(o_lt_wb_awready),
                .i_m0_wdata(i_lt_wb_wdata),
                .i_m0_wlast(i_lt_wb_wlast),
                .i_m0_wvalid(i_lt_wb_wvalid),
                .o_m0_wready(o_lt_wb_wready),
                .o_m0_bvalid(o_lt_wb_bvalid),
                .i_m0_bready(i_lt_wb_bready),

                // Interface B
                .i_m1_awid(1),
                .i_m1_awaddr(dla_awaddr),
                .i_m1_awlen(dla_awlen),
                .i_m1_awvalid(dla_awvalid),
                .o_m1_awready(dla_awready),
                .i_m1_wdata(dla_wdata),
                .i_m1_wlast(dla_wlast),
                .i_m1_wvalid(dla_wvalid),
                .o_m1_wready(dla_wready),
                .o_m1_bvalid(dla_bvalid),
                .i_m1_bready(dla_bready),

                // Output interface
                .o_s_awaddr(o_ddr_awaddr),
                .o_s_awlen(raw_ddr_awlen),
                .o_s_awvalid(rawp_ddr_awvalid),
                .i_s_awready(rawf_ddr_awready),
                .o_s_wdata(o_ddr_wdata),
                .o_s_wlast(o_ddr_wlast),
                .o_s_wvalid(rawp_ddr_wvalid),
                .i_s_wready(rawf_ddr_wready),
                .i_s_bvalid(i_ddr_bvalid),
                .o_s_bready(o_ddr_bready)
            );
            assign o_ddr_wstrb = (1 << DDR_DATA_BYTES) - 1; // all bytes are valid
        end else begin
            assign rawp_ddr_awvalid = dla_awvalid;
            assign o_ddr_awaddr = dla_awaddr;
            assign raw_ddr_awlen = dla_awlen;
            assign dla_awready = rawf_ddr_awready;
            assign rawp_ddr_wvalid = dla_wvalid;
            assign o_ddr_wdata = dla_wdata;
            assign o_ddr_wstrb = dla_wstrb;
            assign o_ddr_wlast = dla_wlast;
            assign dla_wready = rawf_ddr_wready;
            assign dla_bvalid = i_ddr_bvalid;
            assign o_ddr_bready = dla_bready;
        end

        // Prioritize writes over reads; believed to improve performance.
        //
        // We do a couple things here:
        // 1) If the prev cycle was an unacknowledged read (arvalid HIGH *and* arready LOW), then
        //    we must keep the read request outstanding.  In this case, block any writes (by
        //    forcing awvalid, wvalid, awready, and wready to LOW).
        // 2) Otherwise, if there is a write request, then block a read request if a new request
        //    has been made (do this by forcing arready and arvalid to LOW).  (Note that we
        //    do not touch rready or rvalid, since if data happens to arrive, then there is
        //    no reason not to accept it if we can).
        // 3) Lastly, allow a read request through (if any).
        //
        // rawp_ -- these are the internal signals prior to our forcing logic.
        // rawf_ -- these are the internal signals after our forcing logic.
        //
        // Where the forcing logic drives directly to the external world, we simply use the
        // external signal name.
        //

        // 1: Block writes, if necessary.
        //
        // If the previous cycle was a read (whether an acknowledged read or an unacknowledged read),
        // then neither o_ddr_awvalid nor o_ddr_wvalid were HIGH.
        // Therefore it is okay to keep them forced to LOW, regardless of rawp_ddr_awvalid/rawp_ddr_wvalid.
        assign o_ddr_awvalid = rawp_ddr_awvalid & ~dma_prevcycle_read_not_acknowledged;
        assign o_ddr_wvalid = rawp_ddr_wvalid & ~dma_prevcycle_read_not_acknowledged;
        assign rawf_ddr_awready = i_ddr_awready & ~dma_prevcycle_read_not_acknowledged;
        assign rawf_ddr_wready = i_ddr_wready & ~dma_prevcycle_read_not_acknowledged;

        // 2: Is a write going to over-ride today's read request?
        //
        // Note that if dma_prevcycle_read_not_acknowledged is HIGH, then both o_ddr_awvalid
        // and o_ddr_wvalid will already be forced LOW by the logic above, so
        // "write_overrides_read" can never happen if the previous cycle was an unacknowledged
        // read.
        assign write_overrides_read = o_ddr_awvalid | o_ddr_wvalid;

        assign o_ddr_arvalid = rawp_ddr_arvalid & ~write_overrides_read;
        assign rawf_ddr_arready = i_ddr_arready & ~write_overrides_read;

        //axi spec requires a signal width of 8 for burst length
        assign o_ddr_arlen = { {(AXI_BURST_LENGTH_WIDTH-DDR_BURST_WIDTH){1'h0}}, raw_ddr_arlen };

        //tie off constant axi signals
        assign o_ddr_arsize = $clog2(DDR_DATA_BYTES);   //burst size is always maximal, e.g. all bytes within a word should be transferred
        assign o_ddr_arburst = 2'h1;                    //burst type is incrementing, this value comes from the axi spec

        // If the previous cycle was an unacknowledged read, then we must continue to assert arvalid
        // until it is acknowledged by arready.  We are not allowed to randomly deassert arvalid.  Use
        // dma_prevcycle_read_not_acknowledged to track this condition.
        always_ff @(posedge clk_ddr) begin
            dma_prevcycle_read_not_acknowledged <= o_ddr_arvalid & ~i_ddr_arready;

            if (~ddr_sclrn) begin
                // If we are in reset, then o_ddr_arvalid will be LOW since the read_arb
                // is in reset as well (forcing rawp_ddr_arvalid to LOW).  The read_arb
                // shares our reset, namely ddr_sclrn.  This means that we can safely
                // reset to ~dma_prevcycle_read_not_acknowledged.
                //
                // We can make no assumption about i_ddr_arready while in reset.
                dma_prevcycle_read_not_acknowledged <= 1'b0;
            end
        end
    end else begin : gen_disable_ddr_write_tieoff
        // Tie off all DDR write interface signals when DDR is disabled
        assign o_ddr_awvalid = 1'b0;
        assign o_ddr_awaddr = '0;
        assign o_ddr_awlen = '0;
        assign o_ddr_wvalid = 1'b0;
        assign o_ddr_wdata = '0;
        assign o_ddr_wstrb = '0;
        assign o_ddr_wlast = 1'b0;
        assign o_ddr_bready = 1'b0;
        assign o_ddr_arvalid = 1'b0;
        assign o_ddr_arlen = '0;
        assign o_ddr_arsize = '0;
        assign o_ddr_arburst = '0;
        // Tie off layout transform writeback signals
        assign o_lt_wb_awready = 1'b0;
        assign o_lt_wb_wready = 1'b0;
        assign o_lt_wb_bvalid = 1'b0;
        // Tie off internal signals to avoid undriven warnings
        assign dla_awready = 1'b0;
        assign dla_wready = 1'b0;
        assign dla_bvalid = 1'b0;
        assign rawf_ddr_awready = 1'b0;
        assign rawf_ddr_wready = 1'b0;
        assign rawf_ddr_arready = 1'b0;
    end

    //////////////////////
    //  Feature writer  //
    //////////////////////

    if (!DISABLE_DDR) begin
        dla_dma_writer #(
            .READER_WRITER_SEL          (FEATURE_WRITER_ID),
            .NUM_DIMENSIONS             (FEATURE_WRITER_NUM_DIMENSIONS),
            .CONFIG_DATA_BYTES          (CONFIG_DATA_BYTES),
            .WRITER_DATA_BYTES          (FEATURE_WRITER_DATA_BYTES),
            .DDR_ADDR_WIDTH             (DDR_ADDR_WIDTH),
            .DDR_DATA_BYTES             (DDR_DATA_BYTES),
            .DDR_BURST_WIDTH            (DDR_BURST_WIDTH),
            .DEVICE                     (DEVICE)
        )
        feature_writer
        (
            .clk_ddr                    (clk_ddr),
            .i_sclrn_ddr                (ddr_sclrn),
            .i_resetn_async             (i_resetn_async),
            .i_config_valid             (i_config_feature_writer_valid),
            .i_config_data              (i_config_feature_writer_data),
            .o_config_ready             (o_config_feature_writer_ready),
            .o_token_done_csr           (token_done_csr),
            .o_token_done_reader        (token_done_reader),
            .o_token_done_write         (o_done_write),
            .o_license_flag             (writer_license_flag),
            .o_writer_err               (writer_error),
            .i_writer_valid             (i_feature_writer_valid),
            .i_writer_data              (i_feature_writer_data),
            .o_writer_ready             (o_feature_writer_ready),

            .o_ddr_awvalid              (dla_awvalid),
            .o_ddr_awaddr               (dla_awaddr),
            .o_ddr_awlen                (dla_awlen),
            .i_ddr_awready              (dla_awready),
            .o_ddr_wvalid               (dla_wvalid),
            .o_ddr_wdata                (dla_wdata),
            .o_ddr_wstrb                (dla_wstrb),
            .o_ddr_wlast                (dla_wlast),
            .i_ddr_wready               (dla_wready),
            .i_ddr_bvalid               (dla_bvalid),
            .o_ddr_bready               (dla_bready)
        );

        //axi spec requires a signal width of 8 for burst length
        assign o_ddr_awlen = { {(AXI_BURST_LENGTH_WIDTH-DDR_BURST_WIDTH){1'h0}}, raw_ddr_awlen };

        //tie off constant axi signals, use the same settings as read address channel
        assign o_ddr_awsize =  o_ddr_arsize;
        assign o_ddr_awburst = o_ddr_arburst;
    end else begin
        // Tie off feature writer outputs when DDR is disabled
        assign o_config_feature_writer_ready = 1'b1;
        assign o_feature_writer_ready = 1'b1;
        assign token_done_csr = 1'b0;
        assign token_done_reader = 1'b0;
        assign o_done_write = 1'b0;
        assign writer_license_flag = 1'b1;
        assign writer_error = 1'b0;
        assign dla_awvalid = 1'b0;
        assign dla_awaddr = '0;
        assign dla_awlen = '0;
        assign dla_wvalid = 1'b0;
        assign dla_wdata = '0;
        assign dla_wstrb = '0;
        assign dla_wlast = 1'b0;
        assign dla_bready = 1'b0;
        assign o_ddr_awsize = '0;
        assign o_ddr_awburst = '0;
    end

    // Counter logic for generating write IDs for the feature writer.  Since the feature writer is the only writer, we can keep this logic simple and just count up for each write.
    always_ff @(posedge clk_ddr) begin
        if (~ddr_sclrn) begin
            write_id_counter <= '0;
        end
        else if (o_ddr_awvalid & i_ddr_awready) begin
            write_id_counter <= write_id_counter + 1;
        end
    end
    assign o_ddr_awid = write_id_counter;
    /////////////////////////////////////////////////////////
    //  Filter Bias Scale Scratchpad Online Configuration  //
    /////////////////////////////////////////////////////////

    if (~ENABLE_ON_CHIP_PARAMETERS) begin
        assign o_scratchpad_write_en = 1'b0;
        assign o_scratchpad_update_if.data.is_filter = 1'b0;
        assign o_scratchpad_update_if.data.addr = '0;
        assign o_scratchpad_update_if.data.data = '0;
        assign csr_scratchpad_write_ready = 1'b1;
        assign o_config_update_if.data.data = '0;
        assign o_config_update_if.data.addr = '0;
        assign o_config_update_if.valid = 1'b0;
        assign csr_config_dcfifo_write_ready = 1'b1;
    end
    else begin
        localparam int DCFIFO_DEPTH = 32;              //dcfifo is RAM-based, may as well use an entire MLAB
        localparam int DCFIFO_ALMOST_FULL_CUTOFF = 0;
        logic          scratchpad_dcfifo_stall, scratchpad_dcfifo_read_empty;
        assign         csr_scratchpad_write_ready = ~scratchpad_dcfifo_stall;
        assign         o_scratchpad_write_en = ~scratchpad_dcfifo_read_empty;
        assign         o_scratchpad_update_if.data = scratchpad_dcfifo_read_if.data;
        dla_acl_dcfifo #(
            .WIDTH                      (SCRATCHPAD_DCFIFO_DATA_WIDTH),
            .DEPTH                      (DCFIFO_DEPTH),
            .ALMOST_FULL_CUTOFF         (DCFIFO_ALMOST_FULL_CUTOFF)
        )
        scratchpad_update_clock_crosser
        (
            .async_resetn               (i_resetn_async),   //reset synchronization is handled internally

            //write side
            .wr_clock                   (clk_ddr),
            .wr_req                     (csr_scratchpad_write_valid),
            .wr_data                    (scratchpad_dcfifo_write_if.data),
            .wr_full                    (),
            .wr_almost_full             (scratchpad_dcfifo_stall),

            //read side
            .rd_clock                   (clk_dla),
            .rd_empty                   (scratchpad_dcfifo_read_empty),
            .rd_data                    (scratchpad_dcfifo_read_if.data),
            .rd_ack                     (1'b1),
            .rd_almost_empty            (),
            .wr_read_update_for_ccb     ()
        );


        logic          config_dcfifo_stall, config_dcfifo_read_empty;
        assign         csr_config_dcfifo_write_ready = ~config_dcfifo_stall;
        assign         o_config_update_if.valid = ~config_dcfifo_read_empty;
        dla_acl_dcfifo #(
            .WIDTH                      (CONFIG_DCFIFO_WIDTH),
            .DEPTH                      (DCFIFO_DEPTH),
            .ALMOST_FULL_CUTOFF         (DCFIFO_ALMOST_FULL_CUTOFF)
        )
        config_update_clock_crosser
        (
            .async_resetn               (i_resetn_async),   //reset synchronization is handled internally

            //write side
            .wr_clock                   (clk_ddr),
            .wr_req                     (csr_config_dcfifo_write_if.valid),
            .wr_data                    (csr_config_dcfifo_write_if.data),
            .wr_full                    (),
            .wr_almost_full             (config_dcfifo_stall),

            //read side
            .rd_clock                   (clk_dla),
            .rd_empty                   (config_dcfifo_read_empty),
            .rd_data                    (o_config_update_if.data),
            .rd_ack                     (1'b1),
            .rd_almost_empty            (),
            .wr_read_update_for_ccb     ()
        );
    end

endmodule

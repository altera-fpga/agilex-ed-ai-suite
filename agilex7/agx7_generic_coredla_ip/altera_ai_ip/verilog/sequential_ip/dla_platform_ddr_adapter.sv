// Copyright 2020-2025 Altera Corporation.
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

// IMPORTANT: some shortcuts have been taken since read LSUs never backpressure
// read response data and write LSUs never backpressure writeack.
//
// Minimal refactor: decouple AW and W handshakes (allow AW to be accepted
// before first W). Other logic intentionally left unchanged.

`resetall
`undefineall
`default_nettype none

module dla_platform_ddr_adapter #(
    parameter int DDR_ADDR_WIDTH,               //width of all byte address signals to global memory, 32 would allow 4 GB of addressable memory
    parameter int DDR_BURST_WIDTH,              //internal width of the axi burst length signal, typically 4, max number of words in a burst = 2**DDR_BURST_WIDTH
    parameter int DDR_DATA_BYTES,               //width of the global memory data path, typically 64 bytes
    parameter int DDR_READ_ID_WIDTH,            //width of the axi id signal for reads, need enough bits to uniquely identify which master a request came from

    //derived parameters and constants
    localparam int AXI_BURST_LENGTH_WIDTH = 8,  //width of the axi burst length signal as per the axi4 spec
    localparam int AXI_BURST_SIZE_WIDTH = 3,    //width of the axi burst size signal as per the axi4 spec
    localparam int AXI_BURST_TYPE_WIDTH = 2     //width of the axi burst type signal as per the axi4 spec
) (
    input  wire                                 clk_ddr,
    input  wire                                 i_resetn_async,     // active low async reset

    // DLA DMA DDR AXI master (ddr clock)
    // Read address channel
    input  wire                                 i_ddr_axi_arvalid,
    input  wire            [DDR_ADDR_WIDTH-1:0] i_ddr_axi_araddr,
    input  wire    [AXI_BURST_LENGTH_WIDTH-1:0] i_ddr_axi_arlen,
    input  wire      [AXI_BURST_SIZE_WIDTH-1:0] i_ddr_axi_arsize,   // not consumed
    input  wire      [AXI_BURST_TYPE_WIDTH-1:0] i_ddr_axi_arburst,  // not consumed
    input  wire         [DDR_READ_ID_WIDTH-1:0] i_ddr_axi_arid,
    output logic                                o_ddr_axi_arready,

    // Read data channel
    output logic                                o_ddr_axi_rvalid,
    output logic         [8*DDR_DATA_BYTES-1:0] o_ddr_axi_rdata,
    output logic        [DDR_READ_ID_WIDTH-1:0] o_ddr_axi_rid,
    input  wire                                 i_ddr_axi_rready,   // assumed not backpressured

    // Write address channel
    input  wire                                 i_ddr_axi_awvalid,
    input  wire            [DDR_ADDR_WIDTH-1:0] i_ddr_axi_awaddr,
    input  wire    [AXI_BURST_LENGTH_WIDTH-1:0] i_ddr_axi_awlen,
    input  wire      [AXI_BURST_SIZE_WIDTH-1:0] i_ddr_axi_awsize,   // not consumed
    input  wire      [AXI_BURST_TYPE_WIDTH-1:0] i_ddr_axi_awburst,  // not consumed
    output logic                                o_ddr_axi_awready,

    // Write data channel
    input  wire                                 i_ddr_axi_wvalid,
    input  wire          [8*DDR_DATA_BYTES-1:0] i_ddr_axi_wdata,
    input  wire            [DDR_DATA_BYTES-1:0] i_ddr_axi_wstrb,
    input  wire                                 i_ddr_axi_wlast,
    output logic                                o_ddr_axi_wready,

    // Write response
    output logic                                o_ddr_axi_bvalid,
    input  wire                                 i_ddr_axi_bready,

    // Avalon slave side toward DLA/PCIe arbiter (ddr clock)
    output logic                                o_ddr_avm_write,
    output logic                                o_ddr_avm_read,
    output logic           [DDR_ADDR_WIDTH-1:0] o_ddr_avm_address,
    output logic         [8*DDR_DATA_BYTES-1:0] o_ddr_avm_writedata,
    output logic           [DDR_DATA_BYTES-1:0] o_ddr_avm_byteenable,
    output logic            [DDR_BURST_WIDTH:0] o_ddr_avm_burstcount,
    input  wire                                 i_ddr_avm_waitrequest,
    input  wire                                 i_ddr_avm_readdatavalid,
    input  wire          [8*DDR_DATA_BYTES-1:0] i_ddr_avm_readdata
);

    ///////////////
    //  Signals  //
    ///////////////

    // reset
    logic                           ddr_sclrn;

    // convert axi to avalon
    logic                           can_set_avm_request, inside_write_burst, last_write_in_burst, done_write_burst;
    logic     [DDR_BURST_WIDTH-1:0] remaining_write_words;

    // AXI ID for read request tracking
    logic                           axi_id_fifo_full, axi_id_fifo_rdack;
    logic     [DDR_BURST_WIDTH-1:0] axi_len;
    logic   [DDR_READ_ID_WIDTH-1:0] axi_id;
    logic                           inside_read_burst;
    logic     [DDR_BURST_WIDTH-1:0] remaining_read_words;

    // New (minimal refactor) write handshake helpers
    logic                           waiting_first_w;
    logic     [DDR_ADDR_WIDTH-1:0]  aw_addr_hold;
    logic [AXI_BURST_LENGTH_WIDTH-1:0] aw_len_hold;

    /////////////////////////////
    //  Reset Synchronization  //
    /////////////////////////////

    dla_reset_handler_simple #(
        .USE_SYNCHRONIZER   (1),
        .PIPE_DEPTH         (3),
        .NUM_COPIES         (1)
    )
    ddr_reset_synchronizer
    (
        .clk                (clk_ddr),
        .i_resetn           (i_resetn_async),
        .o_sclrn            (ddr_sclrn)
    );

    ///////////////////////////
    //  Backpressure to AXI  //
    ///////////////////////////

    // Original comment:
    // - Statically favor writes over reads
    // - Previously enforced AW + first W together; now decoupled
    //
    // New rules:
    //   o_ddr_axi_awready: accept AW when not inside a burst and not already waiting for first W
    //   o_ddr_axi_wready : asserted while waiting for first W or inside a burst
    //   o_ddr_axi_arready: only when not in / preparing a write burst (write priority retained)

    assign o_ddr_axi_awready = can_set_avm_request & ~inside_write_burst & ~waiting_first_w;
    assign o_ddr_axi_wready  = can_set_avm_request & (waiting_first_w | inside_write_burst);
    assign o_ddr_axi_arready = can_set_avm_request &
                               ~inside_write_burst &
                               ~waiting_first_w &
                               ~i_ddr_axi_awvalid &        // give write address priority if present
                               ~axi_id_fifo_full;

    /////////////////////////////
    //  Convert AXI to Avalon  //
    /////////////////////////////

    assign can_set_avm_request = (~o_ddr_avm_read & ~o_ddr_avm_write) | ~i_ddr_avm_waitrequest;

    always_ff @(posedge clk_ddr) begin
        done_write_burst <= o_ddr_avm_write & ~i_ddr_avm_waitrequest & last_write_in_burst;

        if (~i_ddr_avm_waitrequest) begin
            // transaction accepted, clear request (can be reasserted same cycle below)
            o_ddr_avm_read  <= 1'b0;
            o_ddr_avm_write <= 1'b0;
        end

        if (can_set_avm_request) begin
            if (~inside_write_burst) begin
                // Case A: already waiting for first W beat (address captured previously)
                if (waiting_first_w) begin
                    if (i_ddr_axi_wvalid && o_ddr_axi_wready) begin
                        // First W beat arrives
                        o_ddr_avm_write      <= 1'b1;
                        o_ddr_avm_address    <= aw_addr_hold;
                        o_ddr_avm_burstcount <= {1'b0, aw_len_hold} + 1;
                        o_ddr_avm_writedata  <= i_ddr_axi_wdata;
                        o_ddr_avm_byteenable <= i_ddr_axi_wstrb;
                        if (aw_len_hold == 0) begin
                            // single-beat burst completes immediately
                            last_write_in_burst  <= 1'b1;
                            waiting_first_w      <= 1'b0;
                        end else begin
                            last_write_in_burst     <= 1'b0;
                            inside_write_burst      <= 1'b1;
                            waiting_first_w         <= 1'b0;
                            remaining_write_words   <= aw_len_hold[DDR_BURST_WIDTH-1:0];
                        end
                    end
                end
                // Case B: accept a new AW (with or without first W)
                else if (i_ddr_axi_awvalid && o_ddr_axi_awready) begin
                    aw_addr_hold <= i_ddr_axi_awaddr;
                    aw_len_hold  <= i_ddr_axi_awlen;
                    if (i_ddr_axi_wvalid && o_ddr_axi_wready) begin
                        // AW and first W together (legacy fast path)
                        o_ddr_avm_write      <= 1'b1;
                        o_ddr_avm_address    <= i_ddr_axi_awaddr;
                        o_ddr_avm_burstcount <= {1'b0, i_ddr_axi_awlen} + 1;
                        o_ddr_avm_writedata  <= i_ddr_axi_wdata;
                        o_ddr_avm_byteenable <= i_ddr_axi_wstrb;
                        if (i_ddr_axi_awlen == 0) begin
                            last_write_in_burst <= 1'b1;
                        end else begin
                            last_write_in_burst   <= 1'b0;
                            inside_write_burst    <= 1'b1;
                            remaining_write_words <= i_ddr_axi_awlen[DDR_BURST_WIDTH-1:0];
                        end
                    end else begin
                        // Need to wait for first data beat later
                        waiting_first_w <= 1'b1;
                    end
                end
                // Case C: read burst (only if no pending write)
                else if (i_ddr_axi_arvalid && o_ddr_axi_arready) begin
                    o_ddr_avm_read      <= 1'b1;
                    o_ddr_avm_address   <= i_ddr_axi_araddr;
                    o_ddr_avm_burstcount<= {1'b0, i_ddr_axi_arlen} + 1;
                end
            end
            else begin
                // Inside multi-beat write burst (subsequent beats)
                if (i_ddr_axi_wvalid && o_ddr_axi_wready) begin
                    o_ddr_avm_write      <= 1'b1;
                    // address & burstcount unchanged for remaining beats
                    o_ddr_avm_writedata  <= i_ddr_axi_wdata;
                    o_ddr_avm_byteenable <= i_ddr_axi_wstrb;
                    remaining_write_words <= remaining_write_words - 1;
                    last_write_in_burst   <= 1'b0;
                    if (remaining_write_words == 1) begin
                        inside_write_burst  <= 1'b0;
                        last_write_in_burst <= 1'b1;
                    end
                end
            end
        end

        if (~ddr_sclrn) begin
            o_ddr_avm_write      <= 1'b0;
            o_ddr_avm_read       <= 1'b0;
            inside_write_burst   <= 1'b0;
            waiting_first_w      <= 1'b0;
            aw_addr_hold         <= '0;
            aw_len_hold          <= '0;
        end
    end

    /////////////////////
    //  AXI write ack  //
    /////////////////////

    // ASSUMPTION: no AXI writeack backpressure
    // FUTURE WORK: writeack needs to come from after arbitration with PCIe
    assign o_ddr_axi_bvalid = done_write_burst;

    ////////////////////////////////////////
    //  AXI ID for read request tracking  //
    ////////////////////////////////////////

    // ASSUMPTION: no AXI read data backpressure

    localparam int MAX_OUTSTANDING_READ_BURSTS = 2048;  // may map to M20K

    dla_hld_fifo #(
        .WIDTH                      (DDR_BURST_WIDTH + DDR_READ_ID_WIDTH),
        .DEPTH                      (MAX_OUTSTANDING_READ_BURSTS),
        .ASYNC_RESET                (0),
        .SYNCHRONIZE_RESET          (0),
        .STYLE                      ("ll"), //FIXME in real hardware can get away with STYLE = "ms" since read latency is large
        .DEVICE_FAMILY              (dla_common_pkg::DEVICE_S10)
    )
    axi_id_fifo
    (
        .clock                      (clk_ddr),
        .resetn                     (ddr_sclrn),

        .i_valid                    (i_ddr_axi_arvalid & o_ddr_axi_arready),
        .i_data                     ({i_ddr_axi_arlen[DDR_BURST_WIDTH-1:0], i_ddr_axi_arid}),
        .o_stall                    (axi_id_fifo_full),

        .o_valid                    (),
        .o_data                     ({axi_len, axi_id}),
        .i_stall                    (~axi_id_fifo_rdack)
    );

    assign o_ddr_axi_rvalid = i_ddr_avm_readdatavalid;
    assign o_ddr_axi_rdata  = i_ddr_avm_readdata;
    assign o_ddr_axi_rid    = axi_id;  // updates to this value controlled by fifo read ack

    // fifo read ack asserts at the end of the read burst
    assign axi_id_fifo_rdack = i_ddr_avm_readdatavalid &
                               ((~inside_read_burst) ? (axi_len == 0) : (remaining_read_words == 1));

    // repeater -- id provided once per burst, but needs to be supplied to every word of read data
    always_ff @(posedge clk_ddr) begin
        if (i_ddr_avm_readdatavalid) begin
            if (~inside_read_burst) begin
                remaining_read_words <= axi_len;
                if (axi_len != 0) inside_read_burst <= 1'b1;    // multi-word read burst
            end
            else begin
                remaining_read_words <= remaining_read_words - 1;
                if (remaining_read_words == 1) inside_read_burst <= 1'b0;
            end
        end

        if (~ddr_sclrn) begin
            inside_read_burst <= 1'b0;
        end
    end

endmodule

// Copyright 2020-2020 Altera Corporation.
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


// This module belongs outside of coreDLA, it converts the PCIe AvalonMM interface
// (on PCIe clock) into the DMA CSR AXI interface (on DDR clock). No bursts, and
// it is assumed byte enables are tied to 1.
//
// IMPORTANT: some shortcuts have been taken since the DLA DMA CSR only accepts
// AXI write data and AXI write address channels together. We don't support the
// scenario where one write channel has been accepted but not the other (which
// would require shutting off the valid for the channel that was accepted).

`resetall
`undefineall
`default_nettype none

module dla_platform_csr_adapter #(
    parameter int CSR_DATA_BYTES,       //typically 4 bytes
    parameter int CSR_ADDR_WIDTH        //typically 12 bits, all addresses are byte addresses
) (
    input  wire                         clk_ddr,
    input  wire                         clk_pcie,
    input  wire                         i_resetn_async,     //active low reset that has NOT been synchronized to any clock

    //PCIe AVM slave, runs on pcie clock
    input  wire                         i_csr_avm_write,
    input  wire                         i_csr_avm_read,
    input  wire    [CSR_ADDR_WIDTH-1:0] i_csr_avm_address,
    input  wire  [8*CSR_DATA_BYTES-1:0] i_csr_avm_writedata,
    output logic                        o_csr_avm_waitrequest,
    output logic [8*CSR_DATA_BYTES-1:0] o_csr_avm_readdata,
    output logic                        o_csr_avm_readdatavalid,

    //DMA CSR AXI master, runs on ddr clock
    output logic                        o_csr_axi_arvalid,
    output logic   [CSR_ADDR_WIDTH-1:0] o_csr_axi_araddr,
    input  wire                         i_csr_axi_arready,
    input  wire                         i_csr_axi_rvalid,
    input  wire  [8*CSR_DATA_BYTES-1:0] i_csr_axi_rdata,
    output logic                        o_csr_axi_rready,
    output logic                        o_csr_axi_awvalid,
    output logic   [CSR_ADDR_WIDTH-1:0] o_csr_axi_awaddr,
    input  wire                         i_csr_axi_awready,
    output logic                        o_csr_axi_wvalid,
    output logic [8*CSR_DATA_BYTES-1:0] o_csr_axi_wdata,
    input  wire                         i_csr_axi_wready,
    input  wire                         i_csr_axi_bvalid,
    output logic                        o_csr_axi_bready
);

    localparam int DCFIFO_DEPTH = 32;   //dcfifo is RAM-based, may as well use an entire MLAB



    ///////////////
    //  Signals  //
    ///////////////

    //clock cross and convert Avalon to AXI
    logic                           avm_request_fifo_is_write, avm_request_fifo_empty, avm_request_fifo_rdack;
    logic      [CSR_ADDR_WIDTH-1:0] avm_address;
    logic    [8*CSR_DATA_BYTES-1:0] avm_writedata;

    //convert AXI response into Avalon and move into PCIe clock
    logic                           not_csr_axi_rready, not_csr_avm_readdatavalid;



    /////////////////////////////////////////////
    //  Clock cross and convert Avalon to AXI  //
    /////////////////////////////////////////////

    dla_acl_dcfifo #(
        .WIDTH                      (1 + CSR_ADDR_WIDTH + 8*CSR_DATA_BYTES),
        .DEPTH                      (DCFIFO_DEPTH)
    )
    clock_cross_avm_request
    (
        .async_resetn               (i_resetn_async),       //reset synchronization is handled internally

        //write side
        .wr_clock                   (clk_pcie),
        .wr_req                     (i_csr_avm_write | i_csr_avm_read),
        .wr_data                    ({i_csr_avm_write, i_csr_avm_address, i_csr_avm_writedata}),
        .wr_full                    (o_csr_avm_waitrequest),

        //read side
        .rd_clock                   (clk_ddr),
        .rd_empty                   (avm_request_fifo_empty),
        .rd_data                    ({avm_request_fifo_is_write, o_csr_axi_awaddr, o_csr_axi_wdata}),
        .rd_ack                     (avm_request_fifo_rdack)
    );

    //same address for read and write
    assign o_csr_axi_araddr = o_csr_axi_awaddr;

    //read request
    assign o_csr_axi_arvalid = ~avm_request_fifo_empty & ~avm_request_fifo_is_write;

    //write request simplication: CSR inside DLA DMA only accepts both write addr and write data together, don't need to use the consumed registers strategy from HLD
    assign o_csr_axi_awvalid = ~avm_request_fifo_empty &  avm_request_fifo_is_write;
    assign o_csr_axi_wvalid = o_csr_axi_awvalid;

    //read ack the clock crossing fifo if read request or write request was accepted by CSR
    assign avm_request_fifo_rdack = (o_csr_axi_arvalid & i_csr_axi_arready) | (o_csr_axi_awvalid & i_csr_axi_awready);



    /////////////////////////////////////////////////////////////////
    //  Convert AXI response into Avalon and move into PCIe clock  //
    /////////////////////////////////////////////////////////////////

    //Avalon does not expect a response for writes, ignore i_csr_axi_bvalid
    assign o_csr_axi_bready = 1'b1;

    //clock crossing fifo ports have opposite polarity of ready/valid
    assign o_csr_axi_rready = ~not_csr_axi_rready;
    assign o_csr_avm_readdatavalid = ~not_csr_avm_readdatavalid;

    dla_acl_dcfifo #(
        .WIDTH                      (8*CSR_DATA_BYTES),
        .DEPTH                      (DCFIFO_DEPTH)
    )
    clock_cross_axi_response
    (
        .async_resetn               (i_resetn_async),       //reset synchronization is handled internally

        //write side
        .wr_clock                   (clk_ddr),
        .wr_req                     (i_csr_axi_rvalid),
        .wr_data                    (i_csr_axi_rdata),
        .wr_full                    (not_csr_axi_rready),

        //read side
        .rd_clock                   (clk_pcie),
        .rd_empty                   (not_csr_avm_readdatavalid),
        .rd_data                    (o_csr_avm_readdata),
        .rd_ack                     (1'b1)  //fifo protects itself from underflow, Avalon does not allow backpressure of read response
    );

endmodule

// Copyright 2025 Altera Corporation.
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

`timescale 1 ps / 1 ps
module msgdma2axi4 #(
	parameter DATA_WIDTH       = 256,
	parameter ADDR_WIDTH       = 37,
	parameter ENABLE_S0_READ   = 1,
	parameter ENABLE_S1_WRITE  = 1,
	parameter MAX_BURST_COUNT  = 256
	) (
		// Clock and Reset
		input  wire         clk,                   //      clk.clk
		input  wire         reset,                 //    reset.reset

		// Avalon MM read agent
		input  wire [ADDR_WIDTH-1:0]    s0_read_address,       //  s0_read.address
		input  wire                     s0_read_read,          //         .read
		input  wire [DATA_WIDTH/8-1:0]  s0_read_byteenable,    //         .byteenable
		output wire [DATA_WIDTH-1:0]    s0_read_readdata,      //         .readdata
		output wire                     s0_read_waitrequest,   //         .waitrequest
		output wire                     s0_read_readdatavalid, //         .readdatavalid
		input  wire [BURSTCOUNT_WIDTH-1:0] s0_read_burstcount,    //         .burstcount

		// Avalon MM write agent
		input  wire [ADDR_WIDTH-1:0]    s1_write_address,      // s1_write.address
		input  wire                     s1_write_write,        //         .write
		input  wire [DATA_WIDTH/8-1:0]  s1_write_byteenable,   //         .byteenable
		input  wire [DATA_WIDTH-1:0]    s1_write_writedata,    //         .writedata
		output wire                     s1_write_waitrequest,  //         .waitrequest
		input  wire [BURSTCOUNT_WIDTH-1:0] s1_write_burstcount,   //         .burstcount

		// AXI4 manager
		output wire [ADDR_WIDTH-1:0]    m0_araddr,             //       m0.araddr
		output wire [1:0]               m0_arburst,            //         .arburst
		output wire [3:0]               m0_arcache,            //         .arcache
		output wire                     m0_arid,               //         .arid
		output wire [7:0]               m0_arlen,              //         .arlen
		output wire                     m0_arlock,             //         .arlock
		output wire [2:0]               m0_arprot,             //         .arprot
		input  wire                     m0_arready,            //         .arready
		output wire [2:0]               m0_arsize,             //         .arsize
		output wire                     m0_arvalid,            //         .arvalid
		output wire [ADDR_WIDTH-1:0]    m0_awaddr,             //         .awaddr
		output wire [1:0]               m0_awburst,            //         .awburst
		output wire [3:0]               m0_awcache,            //         .awcache
		output wire                     m0_awid,               //         .awid
		output wire [7:0]               m0_awlen,              //         .awlen
		output wire                     m0_awlock,             //         .awlock
		output wire [2:0]               m0_awprot,             //         .awprot
		input  wire                     m0_awready,            //         .awready
		output wire [2:0]               m0_awsize,             //         .awsize
		output wire                     m0_awvalid,            //         .awvalid
		input  wire                     m0_bid,                //         .bid
		output wire                     m0_bready,             //         .bready
		input  wire [1:0]               m0_bresp,              //         .bresp
		input  wire                     m0_bvalid,             //         .bvalid
		input  wire [DATA_WIDTH-1:0]    m0_rdata,              //         .rdata
		input  wire                     m0_rid,                //         .rid
		input  wire                     m0_rlast,              //         .rlast
		output wire                     m0_rready,             //         .rready
		input  wire [1:0]               m0_rresp,              //         .rresp
		input  wire                     m0_rvalid,             //         .rvalid
		output wire [DATA_WIDTH-1:0]    m0_wdata,              //         .wdata
		output wire                     m0_wlast,              //         .wlast
		input  wire                     m0_wready,             //         .wready
		output wire [DATA_WIDTH/8-1:0]  m0_wstrb,              //         .wstrb
		output wire                     m0_wvalid              //         .wvalid
	);

reg       wr_command_phase;
localparam integer BURSTCOUNT_WIDTH = $clog2(MAX_BURST_COUNT) + 1;

reg [BURSTCOUNT_WIDTH-1:0] wr_burstcount;

always @ (posedge clk or posedge reset) begin
if(reset) begin
	wr_command_phase <= 1'b1;
	wr_burstcount <= {BURSTCOUNT_WIDTH{1'b0}};
end else begin
	if (ENABLE_S1_WRITE) begin
		if(m0_awvalid & m0_awready) begin
			wr_command_phase <= 1'b0;
			wr_burstcount <= s1_write_burstcount;
		end

		if(m0_wvalid & m0_wready) begin
			if(wr_burstcount == {{(BURSTCOUNT_WIDTH-1){1'b0}},1'b1}) begin
				wr_command_phase <= 1'b1;
			end
			wr_burstcount <= wr_burstcount - {{(BURSTCOUNT_WIDTH-1){1'b0}},1'b1};
		end
	end else begin
		wr_command_phase <= 1'b1;
		wr_burstcount <= {BURSTCOUNT_WIDTH{1'b0}};
	end
end
end

initial begin
  if (DATA_WIDTH % 8 != 0) $fatal(1, "DATA_WIDTH must be multiple of 8");
  if ((DATA_WIDTH/8 & ((DATA_WIDTH/8)-1)) != 0) $fatal(1, "Bytes/beat must be power of 2");
  if (MAX_BURST_COUNT < 2) $fatal(1, "MAX_BURST_COUNT must be at least 2");
  if ((MAX_BURST_COUNT & (MAX_BURST_COUNT-1)) != 0) $fatal(1, "MAX_BURST_COUNT must be a power of 2");
  if (MAX_BURST_COUNT > 256) $fatal(1, "MAX_BURST_COUNT above 256 is not supported without AXI burst splitting");
end

localparam [2:0] AXI_SIZE = $clog2(DATA_WIDTH/8);

assign s0_read_readdata      = ENABLE_S0_READ  ? m0_rdata : {DATA_WIDTH{1'b0}};
assign s0_read_readdatavalid = ENABLE_S0_READ  ? m0_rvalid : 1'b0;
assign s0_read_waitrequest   = ENABLE_S0_READ  ? ~m0_arready : 1'b0;

assign s1_write_waitrequest  = ENABLE_S1_WRITE ? (wr_command_phase | ~m0_wready | (wr_burstcount == {BURSTCOUNT_WIDTH{1'b0}})) : 1'b0;

assign m0_araddr  = ENABLE_S0_READ  ? s0_read_address : {ADDR_WIDTH{1'b0}};
assign m0_arburst = 2'b01;
assign m0_arcache = 4'b0000;
assign m0_arid    = 1'b0;
assign m0_arlen   = ENABLE_S0_READ  ? ({{(8-BURSTCOUNT_WIDTH){1'b0}}, s0_read_burstcount} - 8'd1) : 8'h00;
assign m0_arlock  = 1'b0;
assign m0_arprot  = 3'b011;
assign m0_arsize  = AXI_SIZE;
assign m0_arvalid = ENABLE_S0_READ  ? s0_read_read : 1'b0;

assign m0_awaddr  = ENABLE_S1_WRITE ? s1_write_address : {ADDR_WIDTH{1'b0}};
assign m0_awburst = 2'b01;
assign m0_awcache = 4'b0000;
assign m0_awid    = 1'b0;
assign m0_awlen   = ENABLE_S1_WRITE ? ({{(8-BURSTCOUNT_WIDTH){1'b0}}, s1_write_burstcount} - 8'd1) : 8'h00;
assign m0_awlock  = 1'b0;
assign m0_awprot  = 3'b011;
assign m0_awsize  = AXI_SIZE;
assign m0_awvalid = ENABLE_S1_WRITE ? (s1_write_write & wr_command_phase) : 1'b0;

assign m0_bready = ENABLE_S1_WRITE ? 1'b1 : 1'b0;
assign m0_rready = ENABLE_S0_READ  ? 1'b1 : 1'b0;

assign m0_wstrb  = ENABLE_S1_WRITE ? s1_write_byteenable : {(DATA_WIDTH/8){1'b0}};
assign m0_wdata  = ENABLE_S1_WRITE ? s1_write_writedata  : {DATA_WIDTH{1'b0}};
assign m0_wlast  = ENABLE_S1_WRITE ? ((wr_burstcount == {{(BURSTCOUNT_WIDTH-1){1'b0}},1'b1}) ? 1'b1 : 1'b0) : 1'b0;
assign m0_wvalid = ENABLE_S1_WRITE ? (s1_write_write & ~wr_command_phase & (wr_burstcount > {BURSTCOUNT_WIDTH{1'b0}})) : 1'b0;

endmodule

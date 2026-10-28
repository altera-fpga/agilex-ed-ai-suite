// Copyright 2015-2020 Altera Corporation.
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

`resetall
`undefineall
`default_nettype none

module intel_layout_transform_shim #(
  parameter  DATA_WIDTH =  24
  ) (

  input   wire                  clk,
  input   wire                  rst,

  input   wire                           i_stream_in_tvalid,
  input   wire  [DATA_WIDTH - 1 : 0]     i_stream_in_tdata,
  input   wire                           i_stream_in_tuser,
  input   wire                           i_stream_in_tlast,
  output  logic                          o_stream_in_tready,

  output  logic                          o_stream_out_tvalid,
  output  logic  [DATA_WIDTH - 1 : 0]    o_stream_out_tdata,
  output  logic                          o_stream_out_tuser,
  output  logic                          o_stream_out_tlast,
  input   wire                           i_stream_out_tready
);

logic                       din_ready_int;
logic                       dout_valid_int;
logic  [DATA_WIDTH - 1 : 0] tdata_reg;
logic                       tlast_reg;
logic                       tuser_reg;

logic                       din_ready_raw;
logic                       dout_valid_raw;

assign dout_valid_raw = i_stream_in_tvalid || (dout_valid_int && (~din_ready_int || ~i_stream_out_tready));
assign din_ready_raw = i_stream_out_tready || (din_ready_int && (~dout_valid_int || ~i_stream_in_tvalid));

  always @ (posedge clk) begin
    if (rst) begin
      o_stream_in_tready <= 1'b1;
      o_stream_out_tvalid <= 1'b0;
      din_ready_int <= 1'b1;
      dout_valid_int <= 1'b0;
    end else begin
      o_stream_in_tready <= din_ready_raw;
      o_stream_out_tvalid <= dout_valid_raw;
      din_ready_int <= din_ready_raw;
      dout_valid_int <= dout_valid_raw;
    end
  end

  // =======================================================================
  // One deep FIFO
  // =======================================================================
  always @ (posedge clk) begin
    if (din_ready_int) begin
      tdata_reg <= i_stream_in_tdata;
      tlast_reg <= i_stream_in_tlast;
      tuser_reg <= i_stream_in_tuser;
    end
    if (i_stream_out_tready || ~dout_valid_int) begin
      if (~din_ready_int) begin
        o_stream_out_tdata <= tdata_reg;
        o_stream_out_tuser <= tuser_reg;
        o_stream_out_tlast <= tlast_reg;
      end else begin
        o_stream_out_tdata <= i_stream_in_tdata;
        o_stream_out_tuser <= i_stream_in_tuser;
        o_stream_out_tlast <= i_stream_in_tlast;
      end
    end
  end


endmodule



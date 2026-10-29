// Copyright 2015-2023 Altera Corporation.
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

module intel_layout_transform #(
  parameter FAMILY = "Arria 10",
  parameter BIG_ENDIAN = 0,
  parameter IN_AXIS_WIDTH = 32, // Sample_Size
  parameter IN_SAMPLE_PLANES = 3,
  parameter IN_SAMPLE_PLANE_BITS  = 8,

  parameter OUT_AXIS_WIDTH = 16
 )
 (
  input  wire                                  clk, // 1 Clock Domain
  input  wire                                  rst, // Synchronous

  input  wire [7:0]                            i_config_awaddr,
  input  wire                                  i_config_awvalid,
  output logic                                 o_config_awready,
  input  wire [31:0]                           i_config_wdata,
  output logic                                 o_config_wready,
  input  wire                                  i_config_wvalid,
  input  wire [3:0]                            i_config_wstrb,
  output logic [1:0]                           o_config_bresp,
  output logic                                 o_config_bvalid,
  input  wire                                  i_config_bready,
  output logic [31:0]                          o_config_rdata,
  output logic [1:0]                           o_config_rresp,
  output logic                                 o_config_rvalid,
  input  wire                                  i_config_rready,
  input  wire [7:0]                            i_config_araddr,
  input  wire                                  i_config_arvalid,
  output logic                                 o_config_arready,
  input  wire [2:0]                            i_config_awprot,
  input  wire [2:0]                            i_config_arprot,

  output logic                                 o_stream_in_tready,
  input  wire [IN_AXIS_WIDTH-1:0]              i_stream_in_tdata,
  input  wire                                  i_stream_in_tvalid,
  input  wire                                  i_stream_in_tuser,
  input  wire                                  i_stream_in_tlast,

  input  wire                                  i_stream_out_tready,
  output logic [OUT_AXIS_WIDTH-1:0]            o_stream_out_tdata,
  output logic                                 o_stream_out_tvalid,
  output logic                                 o_stream_out_tuser,
  output logic                                 o_stream_out_tlast

  );

localparam L_SAMPLE_WIDTH = IN_SAMPLE_PLANES*IN_SAMPLE_PLANE_BITS;

logic [L_SAMPLE_WIDTH-1:0]       i_stream_in_tdata_packed;

logic [32*IN_SAMPLE_PLANES-1:0]  csr_variance;
logic [32*IN_SAMPLE_PLANES-1:0]  csr_mean;
logic                            csr_rst;
logic [4:0]                      csr_c_vector;

logic [L_SAMPLE_WIDTH-1:0]       o_lt_in_tdata;
logic                            o_lt_in_tvalid;
logic                            o_lt_in_tuser;
logic                            o_lt_in_tlast;
logic                            i_lt_in_tready;

logic [OUT_AXIS_WIDTH-1:0]       i_lt_out_tdata;
logic                            i_lt_out_tvalid;
logic                            i_lt_out_tuser;
logic                            i_lt_out_tlast;
logic                            o_lt_out_tready;

  // Discard any padding. e.g. RGB24 in a 32Bit Word
  assign i_stream_in_tdata_packed = i_stream_in_tdata[L_SAMPLE_WIDTH-1:0];

  // ===============================================================
  // CSR interface
  // ===============================================================
  intel_layout_transform_csr #(
    .IN_SAMPLE_PLANES       (IN_SAMPLE_PLANES),
    .IN_SAMPLE_PLANE_BITS   (IN_SAMPLE_PLANE_BITS)
  ) i_csr
  (

    .clk                    (clk),
    .rst                    (rst),

    .i_axi_awaddr           (i_config_awaddr),
    .i_axi_awvalid          (i_config_awvalid),
    .o_axi_awready          (o_config_awready),
    .i_axi_wdata            (i_config_wdata),
    .i_axi_wvalid           (i_config_wvalid),
    .o_axi_wready           (o_config_wready),
    .o_axi_bresp            (o_config_bresp),
    .o_axi_bvalid           (o_config_bvalid),
    .i_axi_bready           (i_config_bready),
    .i_axi_araddr           (i_config_araddr),
    .i_axi_arvalid          (i_config_arvalid),
    .o_axi_arready          (o_config_arready),
    .o_axi_rdata            (o_config_rdata),
    .o_axi_rresp            (o_config_rresp),
    .o_axi_rvalid           (o_config_rvalid),
    .i_axi_rready           (i_config_rready),

    .csr_variance           (csr_variance),
    .csr_mean               (csr_mean),
    .csr_rst                (csr_rst),
    .csr_c_vector           (csr_c_vector)
  );

  // ===============================================================
  // Input Timing Decouple Shim
  // ===============================================================
  intel_layout_transform_shim #(
    .DATA_WIDTH              (L_SAMPLE_WIDTH)
  ) i_in_shim (

    .clk                  (clk),
    .rst                  (csr_rst),

    .i_stream_in_tvalid   (i_stream_in_tvalid),
    .i_stream_in_tdata    (i_stream_in_tdata_packed),
    .i_stream_in_tuser    (i_stream_in_tuser),
    .i_stream_in_tlast    (i_stream_in_tlast),
    .o_stream_in_tready   (o_stream_in_tready),

    .o_stream_out_tvalid  (o_lt_in_tvalid),
    .o_stream_out_tdata   (o_lt_in_tdata),
    .o_stream_out_tuser   (o_lt_in_tuser),
    .o_stream_out_tlast   (o_lt_in_tlast),
    .i_stream_out_tready  (i_lt_in_tready)
  );

  // ===============================================================
  // Layout Transform
  // ===============================================================
  intel_layout_transform_core #(
    .FAMILY                 (FAMILY),
    .BIG_ENDIAN             (BIG_ENDIAN),
    .IN_WIDTH               (L_SAMPLE_WIDTH),
    .IN_SAMPLE_PLANES       (IN_SAMPLE_PLANES),
    .IN_SAMPLE_PLANE_BITS   (IN_SAMPLE_PLANE_BITS),
    .OUT_WIDTH              (OUT_AXIS_WIDTH)

  ) i_core (

    .clk                  (clk),
    .rst                  (csr_rst),

    .csr_variance         (csr_variance),
    .csr_mean             (csr_mean),
    .csr_c_vector         (csr_c_vector),

    .i_stream_in_tvalid   (o_lt_in_tvalid),
    .i_stream_in_tdata    (o_lt_in_tdata),
    .i_stream_in_tuser    (o_lt_in_tuser),
    .i_stream_in_tlast    (o_lt_in_tlast),
    .o_stream_in_tready   (i_lt_in_tready),

    .o_stream_out_tvalid  (i_lt_out_tvalid),
    .o_stream_out_tdata   (i_lt_out_tdata),
    .o_stream_out_tuser   (i_lt_out_tuser),
    .o_stream_out_tlast   (i_lt_out_tlast),
    .i_stream_out_tready  (o_lt_out_tready)
  );


  // ===============================================================
  // Output Timing Decouple Shim
  // ===============================================================
  intel_layout_transform_shim  #(
    .DATA_WIDTH              (OUT_AXIS_WIDTH)
  ) i_out_shim (

    .clk                  (clk),
    .rst                  (csr_rst),

    .i_stream_in_tvalid   (i_lt_out_tvalid),
    .i_stream_in_tdata    (i_lt_out_tdata),
    .i_stream_in_tuser    (i_lt_out_tuser),
    .i_stream_in_tlast    (i_lt_out_tlast),
    .o_stream_in_tready   (o_lt_out_tready),

    .o_stream_out_tvalid  (o_stream_out_tvalid),
    .o_stream_out_tdata   (o_stream_out_tdata),
    .o_stream_out_tuser   (o_stream_out_tuser),
    .o_stream_out_tlast   (o_stream_out_tlast),
    .i_stream_out_tready  (i_stream_out_tready)
  );

endmodule

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

module intel_layout_transform_csr #(
  parameter IN_SAMPLE_PLANES = 3,
  parameter IN_SAMPLE_PLANE_BITS  = 8
)
(

  input  wire                            clk,
  input  wire                            rst,

  input  wire  [7:0]                     i_axi_awaddr,
  input  wire                            i_axi_awvalid,
  output logic                           o_axi_awready,
  input  wire  [31:0]                    i_axi_wdata,
  input  wire                            i_axi_wvalid,
  output logic                           o_axi_wready,
  output logic [1:0]                     o_axi_bresp,
  output logic                           o_axi_bvalid,
  input  wire                            i_axi_bready,
  input  wire  [7:0]                     i_axi_araddr,
  input  wire                            i_axi_arvalid,
  output logic                           o_axi_arready,
  output logic [31:0]                    o_axi_rdata,
  output logic [1:0]                     o_axi_rresp,
  output logic                           o_axi_rvalid,
  input  wire                            i_axi_rready,

  output logic [32*IN_SAMPLE_PLANES-1:0] csr_variance,
  output logic [32*IN_SAMPLE_PLANES-1:0] csr_mean,
  output logic [4:0]                     csr_c_vector,
  output logic                           csr_rst

);

logic tfr_idle;
logic tfr_req;
logic tfr_rnw;
logic tfr_done;

// Control Plane Interface.
logic                        csr_write;
logic                        csr_read;
logic [5:0]                  csr_address;
logic [31:0]                 csr_writedata;
logic [31:0]                 csr_readdata;

logic [5:0]  c_vector;
logic [31:0] variance[IN_SAMPLE_PLANES-1:0];
logic [31:0] mean[IN_SAMPLE_PLANES-1:0];

  always_comb begin
    csr_variance = 'b0;
    csr_mean = 'b0;
    for(int i=0; i<IN_SAMPLE_PLANES;i++) begin
      csr_variance[i*32+:32] = variance[i];
      csr_mean[i*32+:32]     = mean[i];
    end
  end

  // =======================================================================
  // CPU ReadBack interface
  // =======================================================================
  always_comb
  begin
    case (csr_address)
      8'h00 : // Control
        csr_readdata = {31'b0,csr_rst};
      8'h01 : // C-Vec
        csr_readdata = {26'b0,c_vector};
      default :
        csr_readdata = 32'hffffffff;
    endcase
  end

  // =======================================================================
  // CPU Write interface
  // =======================================================================
  always_ff @(posedge clk)
  begin
    csr_c_vector <= c_vector - 1'b1;

    // Register 0 = Control
    if (rst) begin
      csr_rst <= 1'b1;
      c_vector <= 'b0;
    end else if (csr_address[5:4] == 2'b00) begin
      if (csr_write && csr_address[3:0] == 4'h0) begin
        csr_rst <= csr_writedata[0];
      end

      if (csr_write && csr_address[3:0] == 4'h1) begin
        c_vector <= csr_writedata[5:0];
      end
    end

    // Register 16..31 is Variances (upto 16 planes max)
    if (csr_write && csr_address[5:4] == 2'b01 && csr_address[3:0] < IN_SAMPLE_PLANES) begin
      variance[csr_address[3:0]] <= csr_writedata;
    end

    // Register 32..47 is Variances (upto 16 planes max)
    if (csr_write && csr_address[5:4] == 2'b10 && csr_address[3:0] < IN_SAMPLE_PLANES) begin
      mean[csr_address[3:0]] <= csr_writedata;
    end
  end

  assign tfr_req = ((i_axi_awvalid & i_axi_wvalid ) | i_axi_arvalid) & tfr_idle;
  assign tfr_rnw = i_axi_arvalid;

  // =======================================================================
  // CPU interface , writes take precedence over reads.
  // =======================================================================
  assign o_axi_awready = tfr_req & ~tfr_rnw;
  assign o_axi_wready  = tfr_req & ~tfr_rnw;
  assign o_axi_arready = tfr_req &  tfr_rnw;

  assign o_axi_bresp = 2'b00;
  assign o_axi_rresp = 2'b00;

  assign tfr_done = ((o_axi_rvalid & i_axi_rready) | (o_axi_bvalid & i_axi_bready)) & ~tfr_idle;

  always_ff @(posedge clk)
  begin
    if (rst) begin
      tfr_idle <= 1'b1;
    end else if (tfr_req) begin
      tfr_idle <= 1'b0;
    end else if (tfr_done) begin
      tfr_idle <= 1'b1;
    end

    if (tfr_req) begin
      csr_address    <=  tfr_rnw ? i_axi_araddr[7:2] : i_axi_awaddr[7:2];
      csr_writedata  <=  i_axi_wdata;
    end

    if (tfr_req) begin
      csr_write      <= ~tfr_rnw;
      csr_read       <=  tfr_rnw;
    end else begin
      csr_write <= 1'b0;
      csr_read  <= 1'b0;
    end

    if (csr_write) begin
      o_axi_bvalid <= 1'b1;
    end else if (i_axi_bready | tfr_idle) begin
      o_axi_bvalid <= 1'b0;
    end

    if (csr_read & ~o_axi_rvalid) begin
      o_axi_rvalid <= 1'b1;
      o_axi_rdata  <= csr_readdata;
    end else if (i_axi_rready | tfr_idle) begin
      o_axi_rvalid <= 1'b0;
    end
  end

endmodule


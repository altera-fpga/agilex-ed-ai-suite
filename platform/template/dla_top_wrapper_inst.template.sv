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

  dla_top_wrapper_{ARCH_NAME} dla_top_inst_{DLA_INST} (
    // Clock and reset ports
    .i_ddr_aclk                     (clk_ddr[{DDR_BANK}]),
    .i_axi_aclk                     (clk_axi[{DDR_BANK}]),
    .i_dla_clk                      (clk_dla),
    .i_irq_clk                      (clk_pcie),
    .i_dla_resetn                   (resetn_async),

    // Interrupt stream interface without data port
    .o_interrupt_level              (dla_dma_interrupt_level[{DLA_INST}]),

    // AXI slave interface connected to PCIE
    .s_axi4l_csr_arvalid            (i_csr_arvalid[{DLA_INST}]),
    .s_axi4l_csr_araddr             (i_csr_araddr[{DLA_INST}]),
    .s_axi4l_csr_arready            (o_csr_arready[{DLA_INST}]),
    .s_axi4l_csr_rvalid             (o_csr_rvalid[{DLA_INST}]),
    .s_axi4l_csr_rdata              (o_csr_rdata[{DLA_INST}]),
    .s_axi4l_csr_rready             (i_csr_rready[{DLA_INST}]),
    .s_axi4l_csr_awvalid            (i_csr_awvalid[{DLA_INST}]),
    .s_axi4l_csr_awaddr             (i_csr_awaddr[{DLA_INST}]),
    .s_axi4l_csr_awready            (o_csr_awready[{DLA_INST}]),
    .s_axi4l_csr_wvalid             (i_csr_wvalid[{DLA_INST}]),
    .s_axi4l_csr_wdata              (i_csr_wdata[{DLA_INST}]),
    .s_axi4l_csr_wready             (o_csr_wready[{DLA_INST}]),
    .s_axi4l_csr_bvalid             (o_csr_bvalid[{DLA_INST}]),
    .s_axi4l_csr_bready             (i_csr_bready[{DLA_INST}]),

    // AXI Master interface connected to DDR
    .m_axi4_ddr_arvalid             (o_ddr_arvalid[{DLA_INST}]),
    .m_axi4_ddr_araddr              (o_ddr_araddr[{DLA_INST}]),
    .m_axi4_ddr_arlen               (o_ddr_arlen[{DLA_INST}]),
    .m_axi4_ddr_arsize              (o_ddr_arsize[{DLA_INST}]),
    .m_axi4_ddr_arburst             (o_ddr_arburst[{DLA_INST}]),
    .m_axi4_ddr_arid                (o_ddr_arid[{DLA_INST}]),
    .m_axi4_ddr_arready             (i_ddr_arready[{DLA_INST}]),
    .m_axi4_ddr_rvalid              (i_ddr_rvalid[{DLA_INST}]),
    .m_axi4_ddr_rdata               (i_ddr_rdata[{DLA_INST}]),
    .m_axi4_ddr_rid                 (i_ddr_rid[{DLA_INST}]),
    .m_axi4_ddr_rready              (o_ddr_rready[{DLA_INST}]),
    .m_axi4_ddr_awvalid             (o_ddr_awvalid[{DLA_INST}]),
    .m_axi4_ddr_awaddr              (o_ddr_awaddr[{DLA_INST}]),
    .m_axi4_ddr_awlen               (o_ddr_awlen[{DLA_INST}]),
    .m_axi4_ddr_awsize              (o_ddr_awsize[{DLA_INST}]),
    .m_axi4_ddr_awid                (o_ddr_awid[{DLA_INST}]),
    .m_axi4_ddr_awburst             (o_ddr_awburst[{DLA_INST}]),
    .m_axi4_ddr_awready             (i_ddr_awready[{DLA_INST}]),
    .m_axi4_ddr_wvalid              (o_ddr_wvalid[{DLA_INST}]),
    .m_axi4_ddr_wdata               (o_ddr_wdata[{DLA_INST}]),
    .m_axi4_ddr_wstrb               (o_ddr_wstrb[{DLA_INST}]),
    .m_axi4_ddr_wlast               (o_ddr_wlast[{DLA_INST}]),
    .m_axi4_ddr_wready              (i_ddr_wready[{DLA_INST}]),
    .m_axi4_ddr_bvalid              (i_ddr_bvalid[{DLA_INST}]),
    .m_axi4_ddr_bready              (o_ddr_bready[{DLA_INST}]),

    // AXI-s input signals
    .s_axi4st_rx_istream_tvalid     (i_istream_axi_t_valid[{DLA_INST}]),
    .s_axi4st_rx_istream_tready     (o_istream_axi_t_ready[{DLA_INST}]),
    .s_axi4st_rx_istream_tdata      (i_istream_axi_t_data[{DLA_INST}]),
    .s_axi4st_rx_istream_tlast      (1'b0),
    .s_axi4st_rx_istream_tuser      ('0),

    // AXI-s output signals
    .m_axi4st_tx_ostream_tvalid     (o_ostream_axi_t_valid[{DLA_INST}]),
    .m_axi4st_tx_ostream_tready     (i_ostream_axi_t_ready[{DLA_INST}]),
    .m_axi4st_tx_ostream_tlast      (o_ostream_axi_t_last[{DLA_INST}]),
    .m_axi4st_tx_ostream_tdata      (o_ostream_axi_t_data[{DLA_INST}]),
    .m_axi4st_tx_ostream_tstrb      (o_ostream_axi_t_strb[{DLA_INST}])
  );

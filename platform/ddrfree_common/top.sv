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

// This is the top level module for the streaming example design on the 
// I-series dev-kit.  

`default_nettype none

module top (
    input  wire        clk_sys_100m_p // System clock, 100MHz
    
    // EMIF pins
    `ifdef ENABLE_LT_DDR4_WRITEBACK
   ,input  wire        mem_ddr4_mem_ref_clk,   
    output wire        mem_ddr4_mem_cke,
    output wire        mem_ddr4_mem_odt,
    output wire        mem_ddr4_mem_cs_n,
    output wire [16:0] mem_ddr4_mem_a,        
    output wire [ 1:0] mem_ddr4_mem_ba,
    output wire [ 1:0] mem_ddr4_mem_bg,
    output wire        mem_ddr4_mem_act_n,
    output wire        mem_ddr4_mem_par,
    inout  wire	[31:0] mem_ddr4_mem_dq,
    inout  wire [ 3:0] mem_ddr4_mem_dqs_t,
    inout  wire [ 3:0] mem_ddr4_mem_dqs_c,
    input  wire        mem_ddr4_mem_alert_n,
    inout  wire [ 3:0] mem_ddr4_mem_dbi_n,
    output wire        mem_ddr4_ck_mem_ck_t,
    output wire        mem_ddr4_ck_mem_ck_c,
    output wire        mem_ddr4_reset_n_mem_reset_n,
    input  wire        mem_ddr4_mem_oct_oct_rzqin
    `endif	

    );

    `include "dla_dma_param.svh"
    `include "dla_acl_parameter_assert.svh"

    // Assert statments to ensure architecture file has input/output streaming enabled
    localparam int IS_STREAMING_SUPPORTED = 1;
    `DLA_ACL_PARAMETER_ASSERT_MESSAGE(((ENABLE_OUTPUT_STREAMER == IS_STREAMING_SUPPORTED) && (ENABLE_INPUT_STREAMING == IS_STREAMING_SUPPORTED)), "This example design only supports input/output streaming")
    
    // Assert statments to ensure architecture file has DDR disabled (except when LT DDR4 writeback is enabled)
    `ifdef ENABLE_LT_DDR4_WRITEBACK
    localparam int IS_DDR_DISABLED = 0;  // DDR is enabled for layout transform writeback
    `else
    localparam int IS_DDR_DISABLED = 1;  // DDR is disabled for pure ddrfree designs
    `endif
    `DLA_ACL_PARAMETER_ASSERT_MESSAGE((IS_DDR_DISABLED == DISABLE_DDR), "This example design does not contain a EMIF subsystem and is considered ddrfree.")

    // Assert statments to ensure architecture file uses 128 bit streaming data width
    localparam int ED_OUTPUT_STREAMING_DATA_WIDTH = 128;
    `DLA_ACL_PARAMETER_ASSERT_MESSAGE(((ED_OUTPUT_STREAMING_DATA_WIDTH == AXI_OSTREAM_DATA_WIDTH)), "This example design only supports output streaming data width of 128 bits")
    `DLA_ACL_PARAMETER_ASSERT_MESSAGE((AXI_ISTREAM_DATA_WIDTH % 8 == 0), "This example design only supports input streaming data width that is a multiple of 8 bits")    
    `DLA_ACL_PARAMETER_ASSERT_MESSAGE((!(LAYOUT_TRANSFORM_ENABLE && (AXI_ISTREAM_DATA_WIDTH != 128))),
        "In this design, if LAYOUT_TRANSFORM_ENABLE is set, then the input streaming data width must be 128 bits.")
    `DLA_ACL_PARAMETER_ASSERT_MESSAGE((!(LIGHTWEIGHT_LAYOUT_TRANSFORM_ENABLE && (AXI_ISTREAM_DATA_WIDTH != 96))),
        "In this design, if LIGHTWEIGHT_LAYOUT_TRANSFORM_ENABLE is set, then the input streaming data width must be 96 bits.")

    // Maximum coreDLA instances. Traditional ED's set this to # of 
    // DDR banks. This ED is ddrfree and is currently capped at 1 in the dla_build_example_design.py
    localparam int MAX_DLA_INSTANCES = 4;

    // Assuming a few hundred MHz, a free running 32-bit counter won't overflow within 1 second
    localparam int HW_TIMER_WIDTH = 32;

    // Global resetn signal from System Sources IP
    // More information regarding reset can be found in documentation
    logic global_resetn;
    logic global_pll_resetn;

    logic resetn_ddr    [MAX_DLA_INSTANCES];
    logic i_resetn_axi  [MAX_DLA_INSTANCES];
    
    // Using a system probe IP for resets
    // Instantiated in board.qsys
    logic system_source;

    // Reset release instantaited in board.qsys
    logic done_reset_n;

    // LT DDR4 writeback logic
    `ifdef ENABLE_LT_DDR4_WRITEBACK
    logic         local_mem_ctrl_ready_reset_n [MAX_DLA_INSTANCES];
    logic [ 32:0] local_mem_awaddr [MAX_DLA_INSTANCES];
    logic [ 31:0] local_mem_awaddr_temp [MAX_DLA_INSTANCES];
    logic [  1:0] local_mem_awburst [MAX_DLA_INSTANCES];
    logic [  6:0] local_mem_awid [MAX_DLA_INSTANCES];
    logic [  7:0] local_mem_awlen [MAX_DLA_INSTANCES];
    logic         local_mem_awlock [MAX_DLA_INSTANCES];
    logic [  3:0] local_mem_awqos [MAX_DLA_INSTANCES];
    logic [  2:0] local_mem_awsize [MAX_DLA_INSTANCES];
    logic         local_mem_awvalid [MAX_DLA_INSTANCES];
    logic [ 13:0] local_mem_awuser [MAX_DLA_INSTANCES];
    logic [  2:0] local_mem_awprot [MAX_DLA_INSTANCES];
    logic         local_mem_awready [MAX_DLA_INSTANCES];
    logic [ 32:0] local_mem_araddr [MAX_DLA_INSTANCES];
    logic [ 31:0] local_mem_araddr_temp [MAX_DLA_INSTANCES];
    logic [  1:0] local_mem_arburst [MAX_DLA_INSTANCES];
    logic [  6:0] local_mem_arid [MAX_DLA_INSTANCES];
    logic [  1:0] local_mem_arid_temp [MAX_DLA_INSTANCES];
    logic [  7:0] local_mem_arlen [MAX_DLA_INSTANCES];
    logic         local_mem_arlock [MAX_DLA_INSTANCES];
    logic [  3:0] local_mem_arqos [MAX_DLA_INSTANCES];
    logic [  2:0] local_mem_arsize [MAX_DLA_INSTANCES];
    logic         local_mem_arvalid [MAX_DLA_INSTANCES];
    logic [ 13:0] local_mem_aruser [MAX_DLA_INSTANCES];
    logic [  2:0] local_mem_arprot [MAX_DLA_INSTANCES];
    logic         local_mem_arready [MAX_DLA_INSTANCES];
    logic [255:0] local_mem_wdata [MAX_DLA_INSTANCES];
    logic [ 31:0] local_mem_wstrb [MAX_DLA_INSTANCES];
    logic         local_mem_wlast [MAX_DLA_INSTANCES];
    logic         local_mem_wvalid [MAX_DLA_INSTANCES];
    logic         local_mem_wready [MAX_DLA_INSTANCES];
    logic         local_mem_bready [MAX_DLA_INSTANCES];
    logic [  6:0] local_mem_bid [MAX_DLA_INSTANCES];
    logic [  1:0] local_mem_bresp [MAX_DLA_INSTANCES];
    logic         local_mem_bvalid [MAX_DLA_INSTANCES];
    logic         local_mem_rready [MAX_DLA_INSTANCES];
    logic [255:0] local_mem_rdata [MAX_DLA_INSTANCES];
    logic [  6:0] local_mem_rid [MAX_DLA_INSTANCES];
    logic [  1:0] local_mem_rid_temp [MAX_DLA_INSTANCES];
    logic         local_mem_rlast [MAX_DLA_INSTANCES];
    logic [  1:0] local_mem_rresp [MAX_DLA_INSTANCES];
    logic         local_mem_rvalid [MAX_DLA_INSTANCES];
    `endif

    // PLL clocking signals
    logic iopll_lock;
    // 550 MHz PLL generated clk
    logic kernel_clk;
    // 100MHz PLL generated clk
    logic sys_pll_clk;

    // Active low global resets
    assign global_resetn = system_source & ~done_reset_n;
    assign global_pll_resetn = global_resetn & iopll_lock;

    //dla csr axi interfaces
    logic        [C_CSR_AXI_ADDR_WIDTH-1:0] dla_csr_awaddr              [MAX_DLA_INSTANCES];
    logic                                   dla_csr_awvalid             [MAX_DLA_INSTANCES];
    logic                                   dla_csr_awready             [MAX_DLA_INSTANCES];
    logic        [C_CSR_AXI_DATA_WIDTH-1:0] dla_csr_wdata               [MAX_DLA_INSTANCES];
    logic                                   dla_csr_wvalid              [MAX_DLA_INSTANCES];
    logic                                   dla_csr_wready              [MAX_DLA_INSTANCES];
    logic                                   dla_csr_bvalid              [MAX_DLA_INSTANCES];
    logic                                   dla_csr_bready              [MAX_DLA_INSTANCES];
    logic        [C_CSR_AXI_ADDR_WIDTH-1:0] dla_csr_araddr              [MAX_DLA_INSTANCES];
    logic                                   dla_csr_arvalid             [MAX_DLA_INSTANCES];
    logic                                   dla_csr_arready             [MAX_DLA_INSTANCES];
    logic        [C_CSR_AXI_DATA_WIDTH-1:0] dla_csr_rdata               [MAX_DLA_INSTANCES];
    logic                                   dla_csr_rvalid              [MAX_DLA_INSTANCES];
    logic                                   dla_csr_rready              [MAX_DLA_INSTANCES];

    // Ingress Streaming interface
    logic   [AXI_ISTREAM_DATA_WIDTH-1:0]    ingress_st_data_big_endian  [MAX_DLA_INSTANCES];
    logic   [AXI_ISTREAM_DATA_WIDTH-1:0]    dla_ingress_st_data         [MAX_DLA_INSTANCES];
    logic                                   dla_ingress_st_valid        [MAX_DLA_INSTANCES];  
    logic                                   dla_ingress_st_ready        [MAX_DLA_INSTANCES];

    // Egress Streaming interface
    logic   [AXI_OSTREAM_DATA_WIDTH-1:0]    dla_egress_axi_st_data      [MAX_DLA_INSTANCES];
    logic   [AXI_OSTREAM_DATA_WIDTH-1:0]    dla_egress_avalon_st_data   [MAX_DLA_INSTANCES];
    logic                                   dla_egress_st_valid         [MAX_DLA_INSTANCES];
    logic                                   dla_egress_st_ready         [MAX_DLA_INSTANCES];
    logic   [AXI_OSTREAM_DATA_WIDTH/8-1:0]  dla_egress_axi_st_strb      [MAX_DLA_INSTANCES];
    logic                                   dla_egress_axi_st_last      [MAX_DLA_INSTANCES];
    logic                                   bridge_avst_valid           [MAX_DLA_INSTANCES];
    logic                                   bridge_avst_ready           [MAX_DLA_INSTANCES];

    //hw timer, for inferring CoreDLA clock frequency from host
    // Avalon interface from system console
    logic                                   dla_hw_timer_write;
    logic                                   dla_hw_timer_read;
    logic             [HW_TIMER_WIDTH-1:0]  dla_hw_timer_readdata;
    logic             [HW_TIMER_WIDTH-1:0]  dla_hw_timer_writedata;
    logic                                   dla_hw_timer_start;
    logic                                   dla_hw_timer_stop;
    logic              [HW_TIMER_WIDTH-1:0] dla_hw_timer_counter;

    //mapping of avalon interface to the hw timer signals
    assign dla_hw_timer_start = dla_hw_timer_write & dla_hw_timer_writedata[0];
    assign dla_hw_timer_stop = dla_hw_timer_write & dla_hw_timer_writedata[1];
    assign dla_hw_timer_readdata = dla_hw_timer_counter;

    // Ingress side: system console reads/writes in little endian. mSGDMA reads/writes in big endian. 
    // Performing big endian -> little endian conversion on the ingress streaming side. 
    always_comb begin
        for (int i = 0; i < AXI_ISTREAM_DATA_WIDTH; i = i + 8) begin
            dla_ingress_st_data[0][i +: 8] = ingress_st_data_big_endian[0][AXI_ISTREAM_DATA_WIDTH-1-i -: 8];
        end
    end

    // Egress side: pack AXI-Stream (with TSTRB byte enables) into Avalon-ST
    axi_st_to_avalon_st_bridge #(
        .DATA_WIDTH (AXI_OSTREAM_DATA_WIDTH)
    ) egress_bridge_inst (
        .clk        (sys_pll_clk),
        .resetn     (global_pll_resetn),
        .axi_tdata  (dla_egress_axi_st_data   [0]),
        .axi_tstrb  (dla_egress_axi_st_strb   [0]),
        .axi_tvalid (dla_egress_st_valid       [0]),
        .axi_tready (dla_egress_st_ready       [0]),
        .axi_tlast  (dla_egress_axi_st_last    [0]),
        .avst_data  (dla_egress_avalon_st_data [0]),
        .avst_valid (bridge_avst_valid         [0]),
        .avst_ready (bridge_avst_ready         [0])
    );

    // This qsys system is where ingress/egress streaming takes place.
    // Also contains system console avalon manager and additionally has some 
    // PLL and reset logic.
    board board_inst (
        .clk_clk                        ( clk_sys_100m_p               ),
        
        // Avalon master for hw timer, for inferring CoreDLA clock frequency from host
        .dla_hw_timer_waitrequest       ( 1'b0                         ),  // no backpressure
        .dla_hw_timer_readdata          ( dla_hw_timer_readdata        ),
        .dla_hw_timer_readdatavalid     ( dla_hw_timer_read            ),  //respond immediately
        .dla_hw_timer_burstcount        (                              ),  //output ignored             
        .dla_hw_timer_writedata         ( dla_hw_timer_writedata       ),
        .dla_hw_timer_address           (                              ),  //output ignored
        .dla_hw_timer_write             ( dla_hw_timer_write           ),
        .dla_hw_timer_read              ( dla_hw_timer_read            ),
        .dla_hw_timer_byteenable        (                              ),  //output ignored
        .dla_hw_timer_debugaccess       (                              ),  //output ignored
        
        // JTAG CSR master for IP0
        .csr_axi_bridge_0_m0_awaddr     ( dla_csr_awaddr           [0] ),
        .csr_axi_bridge_0_m0_awprot     (                              ),  // this output is ignored
        .csr_axi_bridge_0_m0_awvalid    ( dla_csr_awvalid          [0] ),
        .csr_axi_bridge_0_m0_awready    ( dla_csr_awready          [0] ),
        .csr_axi_bridge_0_m0_wdata      ( dla_csr_wdata            [0] ),
        .csr_axi_bridge_0_m0_wstrb      (                              ),  // this output is ignored
        .csr_axi_bridge_0_m0_wlast      (                              ),  // this output is ignored
        .csr_axi_bridge_0_m0_wvalid     ( dla_csr_wvalid           [0] ),
        .csr_axi_bridge_0_m0_wready     ( dla_csr_wready           [0] ),
        .csr_axi_bridge_0_m0_bvalid     ( dla_csr_bvalid           [0] ),
        .csr_axi_bridge_0_m0_bready     ( dla_csr_bready           [0] ),
        .csr_axi_bridge_0_m0_araddr     ( dla_csr_araddr           [0] ),
        .csr_axi_bridge_0_m0_arprot     (                              ),  // this output is ignored
        .csr_axi_bridge_0_m0_arvalid    ( dla_csr_arvalid          [0] ),
        .csr_axi_bridge_0_m0_arready    ( dla_csr_arready          [0] ),
        .csr_axi_bridge_0_m0_rdata      ( dla_csr_rdata            [0] ),
        .csr_axi_bridge_0_m0_rvalid     ( dla_csr_rvalid           [0] ),
        .csr_axi_bridge_0_m0_rready     ( dla_csr_rready           [0] ),
        
        // JTAG CSR master for IP1
        .csr_axi_bridge_1_m0_awaddr     ( dla_csr_awaddr           [1] ),
        .csr_axi_bridge_1_m0_awprot     (                              ),  // this output is ignored
        .csr_axi_bridge_1_m0_awvalid    ( dla_csr_awvalid          [1] ),
        .csr_axi_bridge_1_m0_awready    ( dla_csr_awready          [1] ),
        .csr_axi_bridge_1_m0_wdata      ( dla_csr_wdata            [1] ),
        .csr_axi_bridge_1_m0_wstrb      (                              ),  // this output is ignored
        .csr_axi_bridge_1_m0_wlast      (                              ),  // this output is ignored
        .csr_axi_bridge_1_m0_wvalid     ( dla_csr_wvalid           [1] ),
        .csr_axi_bridge_1_m0_wready     ( dla_csr_wready           [1] ),
        .csr_axi_bridge_1_m0_bvalid     ( dla_csr_bvalid           [1] ),
        .csr_axi_bridge_1_m0_bready     ( dla_csr_bready           [1] ),
        .csr_axi_bridge_1_m0_araddr     ( dla_csr_araddr           [1] ),
        .csr_axi_bridge_1_m0_arprot     (                              ),  // this output is ignored
        .csr_axi_bridge_1_m0_arvalid    ( dla_csr_arvalid          [1] ),
        .csr_axi_bridge_1_m0_arready    ( dla_csr_arready          [1] ),
        .csr_axi_bridge_1_m0_rdata      ( dla_csr_rdata            [1] ),
        .csr_axi_bridge_1_m0_rvalid     ( dla_csr_rvalid           [1] ),
        .csr_axi_bridge_1_m0_rready     ( dla_csr_rready           [1] ),

        // JTAG CSR master for IP2
        .csr_axi_bridge_2_m0_awaddr     ( dla_csr_awaddr           [2] ),
        .csr_axi_bridge_2_m0_awprot     (                              ),  // this output is ignored
        .csr_axi_bridge_2_m0_awvalid    ( dla_csr_awvalid          [2] ),
        .csr_axi_bridge_2_m0_awready    ( dla_csr_awready          [2] ),
        .csr_axi_bridge_2_m0_wdata      ( dla_csr_wdata            [2] ),
        .csr_axi_bridge_2_m0_wstrb      (                              ),  // this output is ignored
        .csr_axi_bridge_2_m0_wlast      (                              ),  // this output is ignored
        .csr_axi_bridge_2_m0_wvalid     ( dla_csr_wvalid           [2] ),
        .csr_axi_bridge_2_m0_wready     ( dla_csr_wready           [2] ),
        .csr_axi_bridge_2_m0_bvalid     ( dla_csr_bvalid           [2] ),
        .csr_axi_bridge_2_m0_bready     ( dla_csr_bready           [2] ),
        .csr_axi_bridge_2_m0_araddr     ( dla_csr_araddr           [2] ),
        .csr_axi_bridge_2_m0_arprot     (                              ),  // this output is ignored
        .csr_axi_bridge_2_m0_arvalid    ( dla_csr_arvalid          [2] ),
        .csr_axi_bridge_2_m0_arready    ( dla_csr_arready          [2] ),
        .csr_axi_bridge_2_m0_rdata      ( dla_csr_rdata            [2] ),
        .csr_axi_bridge_2_m0_rvalid     ( dla_csr_rvalid           [2] ),
        .csr_axi_bridge_2_m0_rready     ( dla_csr_rready           [2] ),

        // JTAG CSR master for IP3
        .csr_axi_bridge_3_m0_awaddr     ( dla_csr_awaddr           [3] ),
        .csr_axi_bridge_3_m0_awprot     (                              ),  // this output is ignored
        .csr_axi_bridge_3_m0_awvalid    ( dla_csr_awvalid          [3] ),
        .csr_axi_bridge_3_m0_awready    ( dla_csr_awready          [3] ),
        .csr_axi_bridge_3_m0_wdata      ( dla_csr_wdata            [3] ),
        .csr_axi_bridge_3_m0_wstrb      (                              ),  // this output is ignored
        .csr_axi_bridge_3_m0_wlast      (                              ),  // this output is ignored
        .csr_axi_bridge_3_m0_wvalid     ( dla_csr_wvalid           [3] ),
        .csr_axi_bridge_3_m0_wready     ( dla_csr_wready           [3] ),
        .csr_axi_bridge_3_m0_bvalid     ( dla_csr_bvalid           [3] ),
        .csr_axi_bridge_3_m0_bready     ( dla_csr_bready           [3] ),
        .csr_axi_bridge_3_m0_araddr     ( dla_csr_araddr           [3] ),
        .csr_axi_bridge_3_m0_arprot     (                              ),  // this output is ignored
        .csr_axi_bridge_3_m0_arvalid    ( dla_csr_arvalid          [3] ),
        .csr_axi_bridge_3_m0_arready    ( dla_csr_arready          [3] ),
        .csr_axi_bridge_3_m0_rdata      ( dla_csr_rdata            [3] ),
        .csr_axi_bridge_3_m0_rvalid     ( dla_csr_rvalid           [3] ),
        .csr_axi_bridge_3_m0_rready     ( dla_csr_rready           [3] ),

        // Streaming interface
        .egress_st_data                 ( dla_egress_avalon_st_data[0] ),
        .egress_st_valid                ( bridge_avst_valid        [0] ),
        .egress_st_ready                ( bridge_avst_ready        [0] ),
        .ingress_st_data                ( ingress_st_data_big_endian[0]),
        .ingress_st_valid               ( dla_ingress_st_valid     [0] ),
        .ingress_st_ready               ( dla_ingress_st_ready     [0] ),
        
        // PLL lock and clk
        .iopll_locked_export            ( iopll_lock                   ),
        .kernel_clk_clk                 ( kernel_clk                   ),
        .sys_pll_clk_clk                ( sys_pll_clk                  ),
        
        // Resets
        .resetn_reset_n                 ( global_resetn                ),
        .pll_resetn_in_reset_n          ( global_pll_resetn            ), 
        .done_resetn_ninit_done         ( done_reset_n                 ),
        .source_source                  ( system_source                )
    );

    // Reset of hostless design is conducted through global_pll_resetn (system_source)
   `ifdef ENABLE_LT_DDR4_WRITEBACK	 
    assign resetn_ddr[0] = local_mem_ctrl_ready_reset_n[0];
    assign resetn_ddr[1] = local_mem_ctrl_ready_reset_n[0];
    assign resetn_ddr[2] = local_mem_ctrl_ready_reset_n[0];
    assign resetn_ddr[3] = local_mem_ctrl_ready_reset_n[0];

    assign i_resetn_axi[0] = local_mem_ctrl_ready_reset_n[0];
    assign i_resetn_axi[1] = local_mem_ctrl_ready_reset_n[0];
    assign i_resetn_axi[2] = local_mem_ctrl_ready_reset_n[0];
    assign i_resetn_axi[3] = local_mem_ctrl_ready_reset_n[0];
    `else
    assign resetn_ddr[0] = 1'b1;
    assign resetn_ddr[1] = 1'b1;
    assign resetn_ddr[2] = 1'b1;
    assign resetn_ddr[3] = 1'b1;

    assign i_resetn_axi[0] = 1'b1;
    assign i_resetn_axi[1] = 1'b1;
    assign i_resetn_axi[2] = 1'b1;
    assign i_resetn_axi[3] = 1'b1;
    `endif

    // wrapper around dla_top + dla_platform_adaptor
    dla_platform_wrapper #(
        .C_CSR_AXI_ADDR_WIDTH           (C_CSR_AXI_ADDR_WIDTH),
        .C_CSR_AXI_DATA_WIDTH           (C_CSR_AXI_DATA_WIDTH),
        .C_DDR_AXI_ADDR_WIDTH           (C_DDR_AXI_ADDR_WIDTH),
        .C_DDR_AXI_DATA_WIDTH           (C_DDR_AXI_DATA_WIDTH),
        .C_DDR_AXI_BURST_WIDTH          (C_DDR_AXI_BURST_WIDTH),
        .C_DDR_AXI_READ_ID_WIDTH      (C_DDR_AXI_READ_ID_WIDTH),
        .C_DDR_AXI_WRITE_ID_WIDTH     (C_DDR_AXI_WRITE_ID_WIDTH),
        .MAX_DLA_INSTANCES              (MAX_DLA_INSTANCES),
        .HW_TIMER_WIDTH                 (HW_TIMER_WIDTH), 
        .ENABLE_INPUT_STREAMING         (ENABLE_INPUT_STREAMING),
        .AXI_ISTREAM_DATA_WIDTH         (AXI_ISTREAM_DATA_WIDTH),
        .AXI_ISTREAM_FIFO_DEPTH         (AXI_ISTREAM_FIFO_DEPTH),
        .ENABLE_OUTPUT_STREAMER         (ENABLE_OUTPUT_STREAMER),
        .AXI_OSTREAM_DATA_WIDTH         (AXI_OSTREAM_DATA_WIDTH),
        .AXI_OSTREAM_FIFO_DEPTH         (AXI_OSTREAM_FIFO_DEPTH)
    )
    dla_platform_inst
    (
        // clocks and resets
        .clk_dla                        (kernel_clk),
        .clk_ddr                        ({sys_pll_clk, sys_pll_clk, sys_pll_clk, sys_pll_clk}),
        .clk_pcie                       (sys_pll_clk),
        .clk_axi                        ({sys_pll_clk, sys_pll_clk, sys_pll_clk, sys_pll_clk}),
        .i_resetn_dla                   (global_pll_resetn),
        .i_resetn_ddr                   (resetn_ddr),
        .i_resetn_axi                   (i_resetn_axi),
        .i_resetn_pcie                  ('1),

        //interrupt request, AXI4 stream master without data, runs on pcie clock
        .o_interrupt_level              (),

        // AXI-Streaming
        .i_istream_axi_t_valid          (dla_ingress_st_valid),
        .o_istream_axi_t_ready          (dla_ingress_st_ready),
        .i_istream_axi_t_data           (dla_ingress_st_data),

        // Egress Streaming
        .o_ostream_axi_t_valid          (dla_egress_st_valid),
        .i_ostream_axi_t_ready          (dla_egress_st_ready),
        .o_ostream_axi_t_last           (dla_egress_axi_st_last),
        .o_ostream_axi_t_data           (dla_egress_axi_st_data), 
        .o_ostream_axi_t_strb           (dla_egress_axi_st_strb),

        // AXI interface for LT DDR4 writeback
        `ifdef ENABLE_LT_DDR4_WRITEBACK
        .i_ddr_awready (local_mem_awready),
        .o_ddr_awvalid (local_mem_awvalid),
        .o_ddr_awaddr  (local_mem_awaddr_temp),
        .o_ddr_awlen   (local_mem_awlen),
        .o_ddr_awsize  (local_mem_awsize),
        .o_ddr_awburst (local_mem_awburst),

        .i_ddr_wready  (local_mem_wready),
        .o_ddr_wvalid  (local_mem_wvalid),
        .o_ddr_wdata   (local_mem_wdata),
        .o_ddr_wstrb   (local_mem_wstrb),
        .o_ddr_wlast   (local_mem_wlast),

        .o_ddr_bready  (local_mem_bready),
        .i_ddr_bvalid  (local_mem_bvalid),

        .i_ddr_arready (local_mem_arready),
        .o_ddr_arvalid (local_mem_arvalid),
        .o_ddr_araddr  (local_mem_araddr_temp),
        .o_ddr_arlen   (local_mem_arlen),
        .o_ddr_arsize  (local_mem_arsize),
        .o_ddr_arburst (local_mem_arburst),
        .o_ddr_arid    (local_mem_arid_temp),

        .o_ddr_rready  (local_mem_rready),
        .i_ddr_rvalid  (local_mem_rvalid),
        .i_ddr_rdata   (local_mem_rdata),
        .i_ddr_rid     (local_mem_rid_temp),
        `endif

        //AXI slave interfaces for CSR
        .i_csr_arvalid                  (dla_csr_arvalid),
        .i_csr_araddr                   (dla_csr_araddr),
        .o_csr_arready                  (dla_csr_arready),
        .o_csr_rvalid                   (dla_csr_rvalid),
        .o_csr_rdata                    (dla_csr_rdata),
        .i_csr_rready                   (dla_csr_rready),
        .i_csr_awvalid                  (dla_csr_awvalid),
        .i_csr_awaddr                   (dla_csr_awaddr),
        .o_csr_awready                  (dla_csr_awready),
        .i_csr_wvalid                   (dla_csr_wvalid),
        .i_csr_wdata                    (dla_csr_wdata),
        .o_csr_wready                   (dla_csr_wready),
        .o_csr_bvalid                   (dla_csr_bvalid),
        .i_csr_bready                   (dla_csr_bready),
        
        //hw timer, for inferring CoreDLA clock frequency from host
        .i_hw_timer_start               (dla_hw_timer_start),
        .i_hw_timer_stop                (dla_hw_timer_stop),
        .o_hw_timer_counter             (dla_hw_timer_counter)
    );

    // EMIF
    `ifdef ENABLE_LT_DDR4_WRITEBACK

    // DLA IP only supports 32-bit addressing
    assign local_mem_awaddr[0] = {1'b0,local_mem_awaddr_temp[0]};
    assign local_mem_awaddr[1] = {1'b0,local_mem_awaddr_temp[1]};
    assign local_mem_awaddr[2] = {1'b0,local_mem_awaddr_temp[2]};
    assign local_mem_awaddr[3] = {1'b0,local_mem_awaddr_temp[3]};
    assign local_mem_araddr[0] = {1'b0,local_mem_araddr_temp[0]};
    assign local_mem_araddr[1] = {1'b0,local_mem_araddr_temp[1]};
    assign local_mem_araddr[2] = {1'b0,local_mem_araddr_temp[2]};
    assign local_mem_araddr[3] = {1'b0,local_mem_araddr_temp[3]};

    // DLA IP AXI ID signals are only 2 bit
    assign local_mem_arid[0] = {5'b0,local_mem_arid_temp[0]};
    assign local_mem_arid[1] = {5'b0,local_mem_arid_temp[1]};
    assign local_mem_arid[2] = {5'b0,local_mem_arid_temp[2]};
    assign local_mem_arid[3] = {5'b0,local_mem_arid_temp[3]};
    assign local_mem_rid_temp[0] = local_mem_rid[0][1:0];
    assign local_mem_rid_temp[1] = local_mem_rid[1][1:0];
    assign local_mem_rid_temp[2] = local_mem_rid[2][1:0];
    assign local_mem_rid_temp[3] = local_mem_rid[3][1:0];

    emif emif_inst (
        // clocks and resets
        .iopll_0_refclk_clk              (clk_sys_100m_p),

      	// EMIF pins 
      	.mem_ddr4_mem_ref_clk            (mem_ddr4_mem_ref_clk),      
      	.mem_ddr4_mem_cke                (mem_ddr4_mem_cke),
      	.mem_ddr4_mem_odt                (mem_ddr4_mem_odt),
        .mem_ddr4_mem_cs_n               (mem_ddr4_mem_cs_n),
        .mem_ddr4_mem_a                  (mem_ddr4_mem_a),
        .mem_ddr4_mem_ba                 (mem_ddr4_mem_ba),
        .mem_ddr4_mem_bg                 (mem_ddr4_mem_bg),
        .mem_ddr4_mem_act_n              (mem_ddr4_mem_act_n),
        .mem_ddr4_mem_par                (mem_ddr4_mem_par),
        .mem_ddr4_mem_dq                 (mem_ddr4_mem_dq),
        .mem_ddr4_mem_dqs_t              (mem_ddr4_mem_dqs_t),
        .mem_ddr4_mem_dqs_c              (mem_ddr4_mem_dqs_c),
        .mem_ddr4_mem_alert_n            (mem_ddr4_mem_alert_n),
        .mem_ddr4_mem_dbi_n              (mem_ddr4_mem_dbi_n),
        .mem_ddr4_ck_mem_ck_t            (mem_ddr4_ck_mem_ck_t),
        .mem_ddr4_ck_mem_ck_c            (mem_ddr4_ck_mem_ck_c),
        .mem_ddr4_reset_n_mem_reset_n    (mem_ddr4_reset_n_mem_reset_n),
        .mem_ddr4_mem_oct_oct_rzqin      (mem_ddr4_mem_oct_oct_rzqin),
	
        // AXI4 interface
        .local_mem_clock_in_clk          (sys_pll_clk),
        .local_mem_ctrl_ready_reset_n    (local_mem_ctrl_ready_reset_n[0]),
        .local_mem_awaddr                (local_mem_awaddr[0]),
        .local_mem_awburst               (local_mem_awburst[0]),
        .local_mem_awid                  (local_mem_awid[0]),
        .local_mem_awlen                 (local_mem_awlen[0]),
        .local_mem_awlock                (local_mem_awlock[0]),
        .local_mem_awqos                 (local_mem_awqos[0]),
        .local_mem_awsize                (local_mem_awsize[0]),
        .local_mem_awvalid               (local_mem_awvalid[0]),
        .local_mem_awuser                (local_mem_awuser[0]),
        .local_mem_awprot                (local_mem_awprot[0]),
        .local_mem_awready               (local_mem_awready[0]),
        .local_mem_araddr                (local_mem_araddr[0]),
        .local_mem_arburst               (local_mem_arburst[0]),
        .local_mem_arid                  (local_mem_arid[0]),
        .local_mem_arlen                 (local_mem_arlen[0]),
        .local_mem_arlock                (local_mem_arlock[0]),
        .local_mem_arqos                 (local_mem_arqos[0]),
        .local_mem_arsize                (local_mem_arsize[0]),
        .local_mem_arvalid               (local_mem_arvalid[0]),
        .local_mem_aruser                (local_mem_aruser[0]),
        .local_mem_arprot                (local_mem_arprot[0]),
        .local_mem_arready               (local_mem_arready[0]),
        .local_mem_wdata                 (local_mem_wdata[0]),
        .local_mem_wstrb                 (local_mem_wstrb[0]),
        .local_mem_wlast                 (local_mem_wlast[0]),
        .local_mem_wvalid                (local_mem_wvalid[0]),
        .local_mem_wready                (local_mem_wready[0]),
        .local_mem_bready                (local_mem_bready[0]),
        .local_mem_bid                   (local_mem_bid[0]),
        .local_mem_bresp                 (local_mem_bresp[0]),
        .local_mem_bvalid                (local_mem_bvalid[0]),
        .local_mem_rready                (local_mem_rready[0]),
        .local_mem_rdata                 (local_mem_rdata[0]),
        .local_mem_rid                   (local_mem_rid[0]),
        .local_mem_rlast                 (local_mem_rlast[0]),
        .local_mem_rresp                 (local_mem_rresp[0]),
        .local_mem_rvalid                (local_mem_rvalid[0])
    );
    `endif	    

endmodule

`default_nettype wire

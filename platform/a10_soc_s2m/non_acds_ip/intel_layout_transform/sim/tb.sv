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

`timescale 1ps/1ps

module tb #(
parameter FAMILY = "Arria 10",
parameter IN_SAMPLE_PLANES = 3,
parameter IN_SAMPLE_PLANE_BITS  = 8,
parameter IN_SAMPLE_SIZE = 32,

parameter IN_AXIS_WIDTH = IN_SAMPLE_SIZE,
parameter OUT_AXIS_WIDTH = 64,

parameter FLOW_INPUT_RATE = 98,   // ingress flow Rate in Percentage 1-100
parameter FLOW_OUTPUT_RATE = 100, // egreess flow Rate in Percentage 1-100

parameter FILE_CVEC = 16,
parameter FILE_XSIZE = 224,
parameter FILE_YSIZE = 224,

parameter FILE_INNAME = "./test_image.raw",
parameter FILE_INSIZE  = FILE_XSIZE*FILE_YSIZE*(IN_SAMPLE_SIZE/8),

parameter FILE_OUTNAME = "./test_image_cvec16.out",
parameter FILE_OUTSIZE = FILE_XSIZE*FILE_YSIZE*FILE_CVEC*2 // FP16 = 2Bytes.
);


logic [7:0]                input_data  [FILE_INSIZE];
logic [7:0]                output_data [FILE_OUTSIZE];

logic                      clk = 1'b0;
logic                      rst = 1'b1;

logic [7:0]                awaddr;
logic                      awvalid = 1'b0;
logic                      awready;
logic [31:0]               wdata;
logic                      wready;
logic                      wvalid = 1'b0;
logic [3:0]                wstrb;
logic [1:0]                bresp;
logic                      bvalid;
logic                      bready;
logic [31:0]               rdata;
logic [1:0]                rresp;
logic                      rvalid;
logic                      rready = 'b1;
logic [7:0]                araddr;
logic                      arvalid='b0;
logic                      arready;
logic [2:0]                awprot;
logic [2:0]                arprot;

logic [IN_AXIS_WIDTH-1:0]  i_stream_in_tdata  = 'bz;
logic                      i_stream_in_tvalid = 'b0;
logic                      i_stream_in_tuser  = 'b0;
logic                      i_stream_in_tlast  = 'b0;
logic                      o_stream_in_tready;

logic [OUT_AXIS_WIDTH-1:0] o_stream_out_tdata;
logic                      o_stream_out_tvalid;
logic                      o_stream_out_tlast;
logic                      o_stream_out_tuser;
logic                      i_stream_out_tready = 1'b1;

logic start = 1'b0;

task f_axi_wr  (input [31:0]  addr,
                input [31:0]  data);

logic w;

  awvalid <= 'b0;
  wvalid <= 'b0;
  bready <= 'b0;
  wdata <= 'bx;
  awaddr <= 'b0;
  @(posedge clk);
  awaddr <= {addr,2'b00};
  awvalid <= 'b1;

  for(int i=0;i<3;i++) begin
    @(posedge clk);
    if (awready) begin
      i = 3;
    end
  end
  w = awready;
  if (awready) begin
    awaddr <= 'b0;
    awvalid <= 'b0;
  end 
  @(posedge clk);
  wvalid <= 'b1;
  wdata <= data;
  do
    @(posedge clk);
  while (~(wready & (w || awready ))); 

  awaddr <= 'b0;
  awvalid <= 'b0;
  wvalid <= 'b0;
  do 
    @(posedge clk);
  while (~bvalid);
  bready <= 'b1;
  @(posedge clk);
  bready <= 'b0;

endtask;

`define C_CMDS 2+3+3

integer count;
integer i;
logic [31:0] cmd [0:2*(`C_CMDS)-1] = {
  8'd0, 32'h0,
  8'd1, FILE_CVEC,

  8'h20, 32'hc2cfe148,
  8'h21, 32'hc2e98f5c,
  8'h22, 32'hc2f75c29,

  8'h10, 32'h3f800000,
  8'h11, 32'h3f800000,
  8'h12, 32'h3f800000

  };
  
  
  int f_raw,f_lt,status;
  
  // =======================================================================
  // File Loaders, Testbench Startup.
  // =======================================================================
  initial
  begin
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    rst = 1'b0;
    @(posedge clk);
    @(posedge clk);
    @(posedge clk);
    f_raw = $fopen(FILE_INNAME,"rb");
    if (!f_raw) begin
      $error("Unable to open input file ?");
      $stop;
    end
    f_lt  = $fopen(FILE_OUTNAME,"rb");
    if (!f_lt) begin
      $error("Unable to open output file ?");
      $stop;
    end
    status = $fread(input_data,f_raw);
    if (status != FILE_INSIZE) begin
      $error("Input file Size was not as expected!");
      $stop;
    end
    status = $fread(output_data,f_lt);
    if (status != FILE_OUTSIZE) begin
      $error("Input file Size was not as expected!");
      $stop;
    end
  end

  always
    #2000 clk <= ~clk;


  // =======================================================================
  // CSR Configure after reset.
  // =======================================================================
  always @(posedge clk) begin
    if (rst) begin
      count <= `C_CMDS;
      i = 0;
    end else if (count) begin
      f_axi_wr(cmd[i*2+0],cmd[i*2+1]);
      i++; 
      count--;                                          
    end else begin
      start <= 1'b1;
    end 
  end
  
  logic [16:0] x,y;
  int r,b;

  // =======================================================================
  // Input File Streamer
  // =======================================================================
  always @(posedge clk) begin
    if (~start) begin // Wait for CSR's to be programmmed.
      x <=1; y <=1;
      r = 0;
    end else begin
      if (start && ~count && o_stream_in_tready) begin
        i_stream_in_tuser  <= 1'b0;
        i_stream_in_tlast  <= 1'b0;
        i_stream_in_tvalid <= 1'b0;
        if ($urandom_range(0,100) >= FLOW_INPUT_RATE) begin
          b = 0;
          for (int p=0;p<IN_SAMPLE_PLANES;p++) begin
            if (x <= FILE_XSIZE && y <= FILE_YSIZE) begin
              i_stream_in_tvalid <= 1'b1;
            end
            if (x == FILE_XSIZE) begin
              i_stream_in_tlast <= 1'b1;
            end
            if (x == 1 && y == 1) begin
              i_stream_in_tuser <= 1'b1;
            end 

            i_stream_in_tdata[(p*IN_SAMPLE_PLANE_BITS)+:IN_SAMPLE_PLANE_BITS] <= input_data[r];
            b+=IN_SAMPLE_PLANE_BITS;

            if (x <= FILE_XSIZE && y <= FILE_YSIZE) begin
              r++;
            end
          end
          if (x<=(FILE_XSIZE+5)) begin // Mimic some quiet time as end of line
            x++;
          end else begin
            x = 1;
            $display("Sent Line %d",y);
            if (y<(FILE_YSIZE+5)) begin // Mimic some quiet time at end of picture
              y++;
            end else begin
              y = 1;
              r = 0;
            end
          end
          while(b < IN_SAMPLE_SIZE) begin
            b+=IN_SAMPLE_PLANE_BITS;
            if (x <= FILE_XSIZE && y <= FILE_YSIZE) begin
              r++;
            end
          end 
        end
      end       
    end
  end
    
  // =======================================================================
  // 
  // =======================================================================
    intel_layout_transform #(
     .FAMILY                   (FAMILY),
     .BIG_ENDIAN               (0),
     .IN_AXIS_WIDTH            (IN_AXIS_WIDTH),
     .IN_SAMPLE_PLANES         (IN_SAMPLE_PLANES),
     .IN_SAMPLE_PLANE_BITS     (IN_SAMPLE_PLANE_BITS),
     .OUT_AXIS_WIDTH           (OUT_AXIS_WIDTH)
    )
    i_dut (
		.clk                  (clk),
		.rst                  (rst),
        
		.i_config_awaddr      (awaddr),
		.i_config_awvalid     (awvalid),
		.o_config_awready     (awready),
		.i_config_wdata       (wdata),
		.o_config_wready      (wready),
		.i_config_wvalid      (wvalid),
		.i_config_wstrb       (wstrb),
		.o_config_bresp       (bresp),
		.o_config_bvalid      (bvalid),
		.i_config_bready      (bready),
		.o_config_rdata       (rdata),
		.o_config_rresp       (rresp),
		.o_config_rvalid      (rvalid),
		.i_config_rready      (rready),
		.i_config_araddr      (araddr),
		.i_config_arvalid     (arvalid),
		.o_config_arready     (arready),
		.i_config_awprot      (awprot),
		.i_config_arprot      (arprot),
        
		.i_stream_in_tdata    (i_stream_in_tdata),
		.i_stream_in_tvalid   (i_stream_in_tvalid),
		.i_stream_in_tuser    (i_stream_in_tuser),
		.i_stream_in_tlast    (i_stream_in_tlast),
		.o_stream_in_tready   (o_stream_in_tready),
        
		.o_stream_out_tdata   (o_stream_out_tdata),
		.o_stream_out_tvalid  (o_stream_out_tvalid),
        .o_stream_out_tlast   (o_stream_out_tlast),
		.o_stream_out_tuser   (o_stream_out_tuser),
		.i_stream_out_tready  (i_stream_out_tready)
	  );

  int c;

  // =======================================================================
  // Output Checker
  // =======================================================================
  always @(posedge clk) begin
    i_stream_out_tready <= $urandom_range(0,100) >= FLOW_OUTPUT_RATE;
    
    if (o_stream_out_tvalid && i_stream_out_tready) begin
      for (int p=0;p<(OUT_AXIS_WIDTH/8);p++) begin
        if (o_stream_out_tdata[(p*IN_SAMPLE_PLANE_BITS)+:IN_SAMPLE_PLANE_BITS] !== output_data[c]) begin
          $error("Data Mismatch %t ps : Expected %02x : Got %02x : byte-lane=%d",
            $time,
            output_data[c],
            o_stream_out_tdata[(p*IN_SAMPLE_PLANE_BITS)+:IN_SAMPLE_PLANE_BITS],
            p);  
            $stop;            
        end else begin
`ifdef LOG        
          $display("Data Good %t ps : Expected %02x : Got %02x : byte-lane=%d",
            $time,
            output_data[c],
            o_stream_out_tdata[(p*IN_SAMPLE_PLANE_BITS)+:IN_SAMPLE_PLANE_BITS],
            p);  
`endif
          c++;
        end 
      end
    end
    
    if (c >= FILE_OUTSIZE) begin
      $display("Test Complete");
      $stop;
    end 
  end


endmodule



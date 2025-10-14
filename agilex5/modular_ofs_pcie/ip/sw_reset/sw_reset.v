// Copyright 2024 Altera Corporation.
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

module sw_reset
#( 
  parameter WIDTH=32,
  parameter LOG2_RESET_CYCLES=8
)
(
   input clk,
   input resetn,

   // Slave port
   input slave_address,  // Word address
   input [WIDTH-1:0] slave_writedata,
   input slave_read,
   input slave_write,
   input [WIDTH/8-1:0] slave_byteenable,
   output slave_readdata,
   output slave_waitrequest,

   output reg       sw_reset_n_out
);

reg       sw_reset_n_out_r;
reg       sw_reset_n_out_r2;

reg [LOG2_RESET_CYCLES:0] reset_count;
initial  // Power up condition 
    reset_count <= {LOG2_RESET_CYCLES+1{1'b0}};
always@(posedge clk or negedge resetn)
  if (!resetn)
    reset_count <= {LOG2_RESET_CYCLES+1{1'b0}};
  else if (slave_write)
    reset_count <= {LOG2_RESET_CYCLES+1{1'b0}};
  else if (!reset_count[LOG2_RESET_CYCLES])
    reset_count <= reset_count + 2'b01;

always@(posedge clk)
  sw_reset_n_out = sw_reset_n_out_r;

// Allow additional stages to get to global clock buffers.
always@(posedge clk) sw_reset_n_out_r2 = reset_count[LOG2_RESET_CYCLES];
always@(posedge clk) sw_reset_n_out_r = sw_reset_n_out_r2;

assign slave_waitrequest = !reset_count[LOG2_RESET_CYCLES];
assign slave_readdata = sw_reset_n_out;
  
endmodule


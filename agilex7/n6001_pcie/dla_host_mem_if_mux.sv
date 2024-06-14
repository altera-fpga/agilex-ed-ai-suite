// Copyright 2024-2025 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you (LICENSE.md or "License"). Unless the License provides
// otherwise, you may not use, modify, copy, publish, distribute, disclose or
// transmit this software or the related documents without Altera's prior
// written permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

// This module will multiplex the host_mem_if's write-channel between the write
// DMA module and the DLA IP's IRQs.
// An IRQ is generated 
// An out-of-band AVMM signal, wr_user, is used to indicate an interrupt to the
// PIM. Setting the appropriate bit (
// wr_user[ofs_plat_host_chan_avalon_mem_pkg::HC_AVALON_UFLAG_INTERRUPT]) will 
// cause the PIM to insert an IRQ on the FIM/PIM interface. 
// The PIM/FIM supports 4 IRQs from the AFU, and are indicated on the 
// wr.addr[1:0] bits. wr_write must be set and aw.len needs to be
// set to 1. 

module dla_host_mem_if_mux 
(
  input clk,
  input reset,

  input [3:0] irq,
    
  // to host memory
  ofs_plat_axi_mem_if.to_sink host_mem_if,
    
  // from DMA IP
  ofs_plat_axi_mem_if.to_source dma_mem_if
);

  logic [3:0] irq_d;
  logic [3:0] irq_pending;
  logic [3:0] set_irq_pending;
  logic [3:0] clear_irq_pending;

  logic [9:0] burst_counter;
  logic load_burst_counter;
  logic enable_burst_counter;
  logic [1:0] pending_irq_id;
  logic send_irq_data;

  // pipeline and duplicate the reset signal
  parameter RESET_PIPE_DEPTH = 4;
  logic [RESET_PIPE_DEPTH-1:0] rst_pipe;
  logic rst_local;
  always_ff @(posedge clk) begin
    {rst_local,rst_pipe}  <= {rst_pipe[RESET_PIPE_DEPTH-1:0], 1'b0};
    if (reset) begin
      rst_local <= '1;
      rst_pipe  <= '1;
    end
  end

  // The dma_mem_if/host_mem_if signals are directly connected with no manipulation.
  always_comb begin
    // AXI read interface signals
    host_mem_if.arvalid = dma_mem_if.arvalid;
    dma_mem_if.arready  = host_mem_if.arready;

    host_mem_if.ar.id     = dma_mem_if.ar.id;
    host_mem_if.ar.addr   = dma_mem_if.ar.addr;
    host_mem_if.ar.len    = dma_mem_if.ar.len;
    host_mem_if.ar.size   = dma_mem_if.ar.size;
    host_mem_if.ar.burst  = dma_mem_if.ar.burst;
    host_mem_if.ar.lock   = dma_mem_if.ar.lock;
    host_mem_if.ar.cache  = dma_mem_if.ar.cache;
    host_mem_if.ar.prot   = dma_mem_if.ar.prot;
    host_mem_if.ar.user   = dma_mem_if.ar.user;
    host_mem_if.ar.qos    = dma_mem_if.ar.qos;
    host_mem_if.ar.region = dma_mem_if.ar.region;

    dma_mem_if.rvalid  = host_mem_if.rvalid;
    host_mem_if.rready = dma_mem_if.rready;

    dma_mem_if.r.id   = host_mem_if.r.id;
    dma_mem_if.r.data = host_mem_if.r.data;
    dma_mem_if.r.resp = host_mem_if.r.resp;
    dma_mem_if.r.last = host_mem_if.r.last;
    dma_mem_if.r.user = host_mem_if.r.user;
  end

  // latch the incoming rising edge of the IRQ inputs; ignore the level after it has been latched
  // because it will take some time for sw to clear it.
  genvar i;
  generate
    for (i=0; i<4; i++) begin : irq_handling
        
      always_ff @(posedge clk) begin
         if (rst_local)
           irq_d[i] <= 'b0;
         else 
           irq_d[i] <= irq[i];
        end
        
        always_ff @(posedge clk) begin
          if (rst_local)
            irq_pending[i] <= 'b0;
          else begin
            case ({set_irq_pending[i], clear_irq_pending[i]})
              2'b01: irq_pending[i] <= 1'b0;
              2'b10: irq_pending[i] <= 1'b1;
              2'b11: irq_pending[i] <= 1'b1; // weird but possible to have the IRQ cleared and re-set on same clock
              default: irq_pending[i] <= irq_pending[i];
            endcase
          end
        end
        
        // rising edge of the IRQ sets the pending flag
        assign set_irq_pending[i] = irq[i] & ~irq_d[i];
        
        // clear the pending flag once we've sent the IRQ data on aw interface
        assign clear_irq_pending[i] = send_irq_data & (pending_irq_id == i);
        
    end : irq_handling
  endgenerate

  assign pending_irq_id = irq_pending[0] ? 2'b00 :
                          irq_pending[1] ? 2'b01 :
                          irq_pending[2] ? 2'b10 : 2'b11;

  assign send_irq_data = |irq_pending & (burst_counter == 'b0) & host_mem_if.awready & host_mem_if.wready;

  // awready and wready is a combination of the awready and wready signal 
  // from the host/PIM and the IRQ-write.
  assign dma_mem_if.awready = host_mem_if.awready & !send_irq_data;
  assign dma_mem_if.wready  = host_mem_if.wready  & !send_irq_data;

  // switch the aw signals between IRQ and dma_mem_if based on the send_irq_data signal
  always_comb begin
    // AXI write interface signals
    host_mem_if.awvalid   = send_irq_data ? 1'b1                 : dma_mem_if.awvalid;
    host_mem_if.aw.id     = send_irq_data ?  'b0                 : dma_mem_if.aw.id;
    host_mem_if.aw.addr   = send_irq_data ? {'0, pending_irq_id} : dma_mem_if.aw.addr;
    host_mem_if.aw.len    = send_irq_data ?  'b0                 : dma_mem_if.aw.len;
    host_mem_if.aw.size   = send_irq_data ? 3'b110               : dma_mem_if.aw.size;
    host_mem_if.aw.burst  = send_irq_data ? 2'b01                : dma_mem_if.aw.burst;
    host_mem_if.aw.lock   = dma_mem_if.aw.lock;
    host_mem_if.aw.cache  = dma_mem_if.aw.cache;
    host_mem_if.aw.prot   = dma_mem_if.aw.prot;
    host_mem_if.aw.user   = '0;
    host_mem_if.aw.qos    = dma_mem_if.aw.qos;
    host_mem_if.aw.region = dma_mem_if.aw.region;

    host_mem_if.wvalid  = send_irq_data ? 1'b1 : dma_mem_if.wvalid;
    host_mem_if.w.data  = send_irq_data ?  'b0 : dma_mem_if.w.data;
    host_mem_if.w.strb  = send_irq_data ?  'b1 : dma_mem_if.w.strb;
    host_mem_if.w.last  = send_irq_data ? 1'b1 : dma_mem_if.w.last;
    host_mem_if.w.user  = '0;

    dma_mem_if.bvalid  = host_mem_if.bvalid;
    host_mem_if.bready = dma_mem_if.bready;
    dma_mem_if.b.id    = host_mem_if.b.id;
    dma_mem_if.b.resp  = host_mem_if.b.resp;
    dma_mem_if.b.user  = host_mem_if.b.user;
    
    if (send_irq_data) begin
        host_mem_if.aw.user[ofs_plat_host_chan_axi_mem_pkg::HC_AXI_UFLAG_INTERRUPT] = 1'b1;
        host_mem_if.w.user[ofs_plat_host_chan_axi_mem_pkg::HC_AXI_UFLAG_INTERRUPT] = 1'b1;
    end
  end

  // need to track the wr_write bursts to ensure we don't send an IRQ in the middle of a burst
  assign load_burst_counter = (burst_counter == 'b0) & (dma_mem_if.awvalid) & !send_irq_data;
  assign enable_burst_counter = (burst_counter != 'b0) & (dma_mem_if.wvalid) & host_mem_if.wready;

  always_ff @(posedge clk) begin
    if (rst_local)
      burst_counter <= 'b0;
    else if (load_burst_counter)
      burst_counter <= dma_mem_if.aw.len;
    else if (enable_burst_counter && (burst_counter != '0))
      burst_counter <= burst_counter - 1'b1;
  end

endmodule : dla_host_mem_if_mux

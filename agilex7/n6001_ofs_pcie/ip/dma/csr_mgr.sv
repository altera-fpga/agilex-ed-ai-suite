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

`include "ofs_plat_if.vh"
`include "afu_json_info.vh"

//
// Simple CSR manager. Export the required device feature header and some
// command registers for triggering host memory reads and writes. The
// number of registers managed here is quite small and throughput
// of reads doesn't affect performance, so the CSR interface is not
// pipelined.
//

//
// Read registers (64 bits, byte address is offset * 8):
//

import dma_pkg::*;

module csr_mgr #(
)(
    // CSR interface (MMIO on the host)
    ofs_plat_axi_mem_lite_if.to_source mmio64_to_afu,

    input  t_dma_csr_status dma_csr_status, //status    
    output t_dma_csr_map    dma_csr_map   //control, descriptor, etc
);
    // Each interface names its associated clock and reset.
    logic clk;
    assign clk = mmio64_to_afu.clk;
    logic reset_n;
    assign reset_n = mmio64_to_afu.reset_n;


    // =========================================================================
    //
    //   CSR (MMIO) handling with AXI lite.
    //
    // =========================================================================

    
    //
    // The AXI lite interface is defined in
    // $OPAE_PLATFORM_ROOT/hw/lib/build/platform/ofs_plat_if/rtl/base_ifcs/axi/ofs_plat_axi_mem_lite_if.sv.
    // It contains fields defined by the AXI standard, though organized
    // slightly unusually. Instead of being a flat data structure, the
    // payload for each bus is a struct. The name of the AXI field is the
    // concatenation of the struct instance and field. E.g., AWADDR is
    // aw.addr. The use of structs makes it easier to bulk copy or bulk
    // initialize the full payload of a bus.
    //

    //
    // A valid AFU must implement a device feature list, starting at MMIO
    // address 0.  Every entry in the feature list begins with 5 64-bit
    // words: a device feature header, two AFU UUID words and two reserved
    // words.
    //

    // 64 bit device feature header where the type [63:60] is 0x1 (AFU) and [40] is set (EOL)
    assign dma_csr_map.header.dfh = 'h1000010000000000;

    // The AFU ID is a unique ID for a given program.  Here we generated
    // one with the "uuidgen" program and stored it in the AFU's JSON file.
    // ASE and synthesis setup scripts automatically invoke afu_json_mgr
    // to extract the UUID into afu_json_info.vh.
    logic [127:0] afu_id = `AFU_ACCEL_UUID;
    assign dma_csr_map.header.guid_l = afu_id[63:0];
    assign dma_csr_map.header.guid_h = afu_id[127:64];

    assign dma_csr_map.header.rsvd_1 = 'hDEAD_BEEF_ABCD_EF01;
    assign dma_csr_map.header.rsvd_2 = 'hBADD_C0DE_FEDC_BA10;


    // Read only fixed register assignments
    assign dma_csr_map.status.wr_dest_perf_cntr             = dma_csr_status.wr_dest_perf_cntr;
    assign dma_csr_map.status.rd_src_perf_cntr              = dma_csr_status.rd_src_perf_cntr;
    assign dma_csr_map.status.rsvd_63_30                    ='b0;
    assign dma_csr_map.status.dma_mode                      = dma_csr_status.dma_mode;
    assign dma_csr_map.status.descriptor_count              = dma_csr_status.descriptor_count;  
    assign dma_csr_map.status.rd_state                      = dma_csr_status.rd_state;
    assign dma_csr_map.status.wr_state                      = dma_csr_status.wr_state;
    assign dma_csr_map.status.rd_resp_enc                   = NOT_SUPPORTED;   
    assign dma_csr_map.status.rd_rsp_err                    = dma_csr_status.rd_rsp_err;   
    assign dma_csr_map.status.wr_resp_enc                   = NOT_SUPPORTED;   
    assign dma_csr_map.status.wr_rsp_err                    = dma_csr_status.wr_rsp_err;   
    assign dma_csr_map.status.rsvd_9                        = NOT_SUPPORTED;
    assign dma_csr_map.status.rsvd_8                        = NOT_SUPPORTED;
    assign dma_csr_map.status.stopped_on_error              = dma_csr_status.stopped_on_error;   
    assign dma_csr_map.status.resetting                     = dma_csr_map.control.reset_dispatcher;
    assign dma_csr_map.status.stopped                       = dma_csr_map.control.stop_dispatcher;   
    assign dma_csr_map.status.response_fifo_full            = dma_csr_status.response_fifo_full;   
    assign dma_csr_map.status.response_fifo_empty           = dma_csr_status.response_fifo_empty;   
    assign dma_csr_map.status.descriptor_fifo_full          = dma_csr_status.descriptor_fifo_full;
    assign dma_csr_map.status.descriptor_fifo_empty         = dma_csr_status.descriptor_fifo_empty;
    assign dma_csr_map.status.busy                          = dma_csr_status.busy;

    assign dma_csr_map.config1.max_byte                 = 'b0;  
    assign dma_csr_map.config1.max_burst_count          = 'b0;  
    assign dma_csr_map.config1.error_width              = 'b0;  
    assign dma_csr_map.config1.error_enable             = 'b0;  
    assign dma_csr_map.config1.enhanced_features        = ENABLE_ERROR;  
    assign dma_csr_map.config1.descriptor_fifo_depth    = DMA_DESCRIPTOR_FIFO_DEPTH_ENCODED;
    assign dma_csr_map.config1.data_width               = AXI_MM_DATA_W;  
    assign dma_csr_map.config1.data_fifo_depth          = DMA_DATA_FIFO_DEPTH;  
    assign dma_csr_map.config1.channel_width            = 'b0;  
    assign dma_csr_map.config1.channel_enable           = 'b0;  
    assign dma_csr_map.config1.burst_wrapping_support   = ENABLED;  
    assign dma_csr_map.config1.burst_enable             = ENABLED;  
 
    assign dma_csr_map.config2.clk_speed_mhz                = 400;  //400MHz clk
    assign dma_csr_map.config2.transfer_type                = 'b0;  
    assign dma_csr_map.config2.response_port                = 'b0;  
    assign dma_csr_map.config2.programmable_burst_enable    = 'b0;  
    assign dma_csr_map.config2.prefetcher_enable            = NOT_SUPPORTED;  
    assign dma_csr_map.config2.packet_enable                = NOT_SUPPORTED;   
    assign dma_csr_map.config2.max_stride                   = NOT_SUPPORTED;  
    assign dma_csr_map.config2.stride_enable                = NOT_SUPPORTED;  
   

    // Use a copy of the MMIO interface as registers.
    ofs_plat_axi_mem_lite_if #(
        // PIM-provided macro to replicate identically sized instances of an
        // AXI lite interface.
        `OFS_PLAT_AXI_MEM_LITE_IF_REPLICATE_PARAMS(mmio64_to_afu)
    ) mmio64_reg();

    // Is a CSR read request active this cycle? The test is simple because
    // the mmio64_reg.arvalid can only be set when the read response fifo
    // is empty.
    logic is_csr_read;
    assign is_csr_read = mmio64_reg.arvalid;

    // Is a CSR write request active this cycle?
    logic is_csr_write;
    assign is_csr_write = mmio64_reg.awvalid && mmio64_reg.wvalid;


    //
    // Receive MMIO read requests
    //

    // Ready for new request iff read request and response registers are empty
    assign mmio64_to_afu.arready = !mmio64_reg.arvalid && !mmio64_reg.rvalid;

    always_ff @(posedge clk) begin
        if (is_csr_read) begin
            // Current read request was handled
            mmio64_reg.arvalid <= 1'b0;
        end
        else if (mmio64_to_afu.arvalid && mmio64_to_afu.arready) begin
            // Receive new read request
            mmio64_reg.arvalid <= 1'b1;
            mmio64_reg.ar <= mmio64_to_afu.ar;
        end

        if (!reset_n) begin
            mmio64_reg.arvalid <= 1'b0;
        end
    end

    //
    // Decode register read addresses and respond with data.
    //
    assign mmio64_to_afu.rvalid = mmio64_reg.rvalid;
    assign mmio64_to_afu.r = mmio64_reg.r;

    always_ff @(posedge clk) begin
        if (is_csr_read) begin
            // New read response
            mmio64_reg.rvalid <= 1'b1;

            mmio64_reg.r <= '0;
            // The unique transaction ID matches responses to requests
            mmio64_reg.r.id <= mmio64_reg.ar.id;
            // Return user flags from request
            mmio64_reg.r.user <= mmio64_reg.ar.user;

            // AXI addresses are always in byte address space. Ignore the
            // low 3 bits to index 64 bit CSRs. Ignore high bits and let the
            // address space wrap.
            case (mmio64_reg.ar.addr[7:3])
              DMA_DFH:                 mmio64_reg.r.data <= dma_csr_map.header.dfh;
              DMA_GUID_L:              mmio64_reg.r.data <= dma_csr_map.header.guid_l;
              DMA_GUID_H:              mmio64_reg.r.data <= dma_csr_map.header.guid_h;
              DMA_RSVD_1:              mmio64_reg.r.data <= dma_csr_map.header.rsvd_1;
              DMA_RSVD_2:              mmio64_reg.r.data <= dma_csr_map.header.rsvd_2;

              DMA_SRC_ADDR:            mmio64_reg.r.data <= dma_csr_map.descriptor.src_addr;
              DMA_DEST_ADDR:           mmio64_reg.r.data <= dma_csr_map.descriptor.dest_addr;
              DMA_LENGTH:              mmio64_reg.r.data <= dma_csr_map.descriptor.length;
              DMA_DESCRIPTOR_CONTROL:  mmio64_reg.r.data <= dma_csr_map.descriptor.descriptor_control;
              
              DMA_STATUS:              mmio64_reg.r.data <= dma_csr_map.status;
              DMA_CONTROL:             mmio64_reg.r.data <= dma_csr_map.control;
              DMA_WR_RE_FILL_LEVEL:    mmio64_reg.r.data <= dma_csr_map.wr_re_fill_level;
              DMA_RESP_FILL_LEVEL:     mmio64_reg.r.data <= dma_csr_map.resp_fill_level;
              DMA_WR_RE_SEQ_NUM:       mmio64_reg.r.data <= dma_csr_map.seq_num;
              DMA_CONFIG_1:            mmio64_reg.r.data <= dma_csr_map.config1;
              DMA_CONFIG_2:            mmio64_reg.r.data <= dma_csr_map.config2;
              DMA_TYPE_VERSION:        mmio64_reg.r.data <= dma_csr_map.info;
              DMA_RD_SRC_PERF_CNTR:    mmio64_reg.r.data <= dma_csr_map.status.rd_src_perf_cntr;
              DMA_WR_DEST_PERF_CNTR:   mmio64_reg.r.data <= dma_csr_map.status.wr_dest_perf_cntr;
            endcase

        end else if (mmio64_to_afu.rready) begin
            // If a read response was pending, it completed
            mmio64_reg.rvalid <= 1'b0;
        end

        if (!reset_n) begin
            dma_csr_map.wr_re_fill_level <= 'b0;
            dma_csr_map.resp_fill_level  <= 'b0;
            dma_csr_map.seq_num          <= 'b0;
            dma_csr_map.info             <= 'b0;
            mmio64_reg.rvalid            <= 1'b0;
        end
    end


    //
    // CSR write handling.  Host software must tell the AFU the memory address
    // to which it should be writing.  The address is set by writing a CSR.
    //

    // Ready for new request iff write request register is empty. For simplicity,
    // not pipelined.
    assign mmio64_to_afu.awready = !mmio64_reg.awvalid && !mmio64_reg.bvalid;
    assign mmio64_to_afu.wready  = !mmio64_reg.wvalid && !mmio64_reg.bvalid;

    // Register incoming writes, waiting for both an address and a payload.
    always_ff @(posedge clk) begin
        if (is_csr_write) begin
            // Current write request was handled
            mmio64_reg.awvalid <= 1'b0;
            mmio64_reg.wvalid <= 1'b0;
        end else begin
            // Receive new write address
            if (mmio64_to_afu.awvalid && mmio64_to_afu.awready) begin
                mmio64_reg.awvalid <= 1'b1;
                mmio64_reg.aw <= mmio64_to_afu.aw;
            end

            // Receive new write data
            if (mmio64_to_afu.wvalid && mmio64_to_afu.wready)  begin
                mmio64_reg.wvalid <= 1'b1;
                mmio64_reg.w <= mmio64_to_afu.w;
            end
        end

        if (!reset_n) begin
            mmio64_reg.awvalid <= 1'b0;
            mmio64_reg.wvalid <= 1'b0;
        end
    end

    // Generate a CSR write response once both address and data have arrived
    assign mmio64_to_afu.bvalid = mmio64_reg.bvalid;
    assign mmio64_to_afu.b = mmio64_reg.b;

    always_ff @(posedge clk) begin
        if (is_csr_write) begin
            // New write response
            mmio64_reg.bvalid <= 1'b1;

            mmio64_reg.b <= '0;
            mmio64_reg.b.id <= mmio64_reg.aw.id;
            mmio64_reg.b.user <= mmio64_reg.aw.user;
        end else if (mmio64_to_afu.bready) begin
            // If a write response was pending it completed
            mmio64_reg.bvalid <= 1'b0;
        end

        if (!reset_n) begin
            mmio64_reg.bvalid <= 1'b0;
        end
    end


    //
    // Decode CSR writes into dma engine commands.
    //
    always_ff @(posedge clk) begin
        // There is no flow control on the module's outgoing read/write command
        // ports. If a request was trigger in the last cycle, it was sent.

        if (dma_csr_map.descriptor.descriptor_control.go) begin //make sure descriptor fifo is not full?
            dma_csr_map.descriptor.descriptor_control.go <= 'b0;
        end

        if (is_csr_write) begin
            // AXI addresses are always in byte address space. Ignore the
            // low 3 bits to index 64 bit CSRs. Ignore high bits and let the
            // address space wrap.
            case (mmio64_reg.aw.addr[7:3])
              DMA_SRC_ADDR:           dma_csr_map.descriptor.src_addr           <= mmio64_reg.w.data[$bits(dma_csr_map.descriptor.src_addr)-1 : 0];
              DMA_DEST_ADDR:          dma_csr_map.descriptor.dest_addr          <= mmio64_reg.w.data[$bits(dma_csr_map.descriptor.dest_addr)-1 : 0];
              DMA_LENGTH:             dma_csr_map.descriptor.length             <= mmio64_reg.w.data[$bits(dma_csr_map.descriptor.length)-1 : 0];
              DMA_DESCRIPTOR_CONTROL: dma_csr_map.descriptor.descriptor_control <= mmio64_reg.w.data[$bits(dma_csr_map.descriptor.descriptor_control)-1 : 0];
              DMA_CONTROL:            dma_csr_map.control                       <= mmio64_reg.w.data[$bits(dma_csr_map.control)-1 : 0];
            endcase
        end

 
        if (!reset_n) begin
            dma_csr_map.descriptor.src_addr           <= 'b0;
            dma_csr_map.descriptor.dest_addr          <= 'b0;
            dma_csr_map.descriptor.length             <= 'b0;
            dma_csr_map.descriptor.descriptor_control <= 'b0;
            dma_csr_map.control                       <= 'b0;
        end
    end

    // synthesis translate_off
    always_ff @(posedge clk) begin
        if (is_csr_read && reset_n) begin
            $display("CSR_MGR: Read addr 0x%0h",
                     mmio64_reg.ar.addr);
        end else if  (mmio64_to_afu.rready & mmio64_to_afu.rvalid & reset_n) begin
            $display("\tCSR_MGR: Read Data: 0x%0h",  mmio64_to_afu.r.data);
        end 

        if (is_csr_write && reset_n) begin
            $display("CSR_MGR: Write addr 0x%0h, %0s req comletion",
                    { mmio64_reg.aw.addr[$bits(mmio64_reg.aw.addr)-1 : 1], 1'b0 },
                    (mmio64_reg.aw.addr[0] ? "with" : "without"));
            $display("\tCSR_MGR: Write Data: 0x%0h", mmio64_reg.w.data);
        end
    end
    // synthesis translate_on

endmodule

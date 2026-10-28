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


`include "ofs_plat_if.vh"
`include "afu_json_info.vh"

//
// Simple CSR manager. Export the required device feature header and some
// command registers for triggering host memory reads and writes.
//
//
// Read registers (64 bits, byte address is offset * 8):
//
//   0: Device feature header (DFH)
//   1: AFU_ID_L
//   2: AFU_ID_L
//   3: DFH_RSVD0
//   4: DFH_RSVD1
//   5: Platform information
//    [31:16] Maximum number of bursts
//	  [15:0]  Maximum burst length
//   6: AI Reset - set to 1 to enable reset, only valid 1 clock cycle
//  
//  Read Engine registers
//   7: Read Engine Destination: [0] - 0: batch, 1: weights
//   8: Read engine num_bytes: number of bytes to read per request. 
//      This must be set before writing an address to register 9. 
//      The value is calculated by engine for num_lines-1 to match
//      AXI-MM encoding.
//  9: Read start address. When this is written, the number of lines currently
//      in register 8 will be read, starting with the incoming address. The
//      host must rate limit requests so that there are fewer than the maximum
//      permitted number of requests in flight (read register 5).
//
//  Write Engine registers
//  10: Write engine num_bytes. The same as register 8, but for the write stream.
//  11: Write start address. The same protocol as register 9.
//  12: Completion Status Buffer Address

module csr_mgr
  #(
    parameter MAX_REQS_IN_FLIGHT = 32,
    parameter DIN_BUS_SIZE = 4,
    parameter MAX_BURST_SIZE  = 8192
    )
   (
    // CSR interface (MMIO on the host)
    ofs_plat_axi_mem_lite_if.to_source mmio64_to_afu,

    // Read engine control - initiate a read of num_lines from addr when enable is set.
    // Flow control is the host's responsibility, given the maximum number of
    // requests in flight and the host's knowledge of the number of uncompleted
    // commands.
    output spark_afu_pkg::t_rd_cmd   rd_cmd,
    input  spark_afu_pkg::t_rd_state rd_state,

    // Write engine control - initiate a write of num_lines from addr when enable is set.
    // Write data comes from a read. For a given read/write pair, num_lines must match.
    output spark_afu_pkg::t_wr_cmd   wr_cmd,
    input spark_afu_pkg::t_wr_state wr_state,
    output ip_reset_n
    );

    // uClk has been mapped to mmio64_to_afu.clk. We will use this clock
    // for MMIO transactions.
    logic clk;
    assign clk = mmio64_to_afu.clk;
    logic reset_n = 1'b0;
    always @(posedge clk) begin
        reset_n <= mmio64_to_afu.reset_n;
    end
    
    reg ip_reset; //active high
    //active low
    assign ip_reset_n = ~ip_reset;
 
    
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

    // The AFU ID is a unique ID for a given program.  Here we generated
    // one with the "uuidgen" program and stored it in the AFU's JSON file.
    // ASE and synthesis setup scripts automatically invoke afu_json_mgr
    // to extract the UUID into afu_json_info.vh.
    logic [127:0] afu_id = `AFU_ACCEL_UUID;

    //
    // A valid AFU must implement a device feature list, starting at MMIO
    // address 0.  Every entry in the feature list begins with 5 64-bit
    // words: a device feature header, two AFU UUID words and two reserved
    // words.
    //

    // Use a copy of the MMIO interface as registers.
    ofs_plat_axi_mem_lite_if
      #(
        // PIM-provided macro to replicate identically sized instances of an
        // AXI lite interface.
        `OFS_PLAT_AXI_MEM_LITE_IF_REPLICATE_PARAMS(mmio64_to_afu)
        )
      mmio64_reg();

    // Is a CSR read request active this cycle? The test is simple because
    // the mmio64_reg.arvalid can only be set when the read response buffer
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

    always_ff @(posedge clk)
    begin
        if (is_csr_read)
        begin
            // Current read request was handled
            mmio64_reg.arvalid <= 1'b0;
        end
        else if (mmio64_to_afu.arvalid && mmio64_to_afu.arready)
        begin
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

    always_ff @(posedge clk)
    begin
        if (is_csr_read)
        begin
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
            // Default 8-bit address range, should not need more for awhile
            case (mmio64_reg.ar.addr[10:3])
              0: // AFU DFH (device feature header)
                begin
                    // Here we define a trivial feature list.  In this
                    // example, our AFU is the only entry in this list.
                    mmio64_reg.r.data <= '0;
                    // Feature type is AFU
                    mmio64_reg.r.data[63:60] <= 4'h1;
                    // End of list (last entry in list)
                    mmio64_reg.r.data[40] <= 1'b1;
                end

              // AFU_ID_L
              1: mmio64_reg.r.data <= afu_id[63:0];

              // AFU_ID_H
              2: mmio64_reg.r.data <= afu_id[127:64];

              // DFH_RSVD0
              3: mmio64_reg.r.data <= '0;

              // DFH_RSVD1
              4: mmio64_reg.r.data <= '0;
              
              // Platform information
              5: 
                begin
                    mmio64_reg.r.data <= '0;
                    // Maximum number of bursts
                    mmio64_reg.r.data[16+:16] <= 16'(MAX_REQS_IN_FLIGHT);
                    // Maximum number of lines in a read or write burst
                    mmio64_reg.r.data[0+:16] <= 16'(MAX_BURST_SIZE); // Need to seperate this out between read and write requests
                end
              
              // Processed weights/batch data on read side
              6: 
                begin
                    mmio64_reg.r.data <= rd_state.weights_processed;
                end
              7: 
                begin
                    mmio64_reg.r.data <= rd_state.requests_pending;
                end

              default: mmio64_reg.r.data <= '0;
            endcase
        end
        else if (mmio64_to_afu.rready)
        begin
            // If a read response was pending it completed
            mmio64_reg.rvalid <= 1'b0;
        end

        if (!reset_n)
        begin
            mmio64_reg.rvalid <= 1'b0;
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
    always_ff @(posedge clk)
    begin
        if (is_csr_write)
        begin
            // Current write request was handled
            mmio64_reg.awvalid <= 1'b0;
            mmio64_reg.wvalid  <= 1'b0;
        end
        else
        begin
            // Receive new write address
            if (mmio64_to_afu.awvalid && mmio64_to_afu.awready)
            begin
                mmio64_reg.awvalid <= 1'b1;
                mmio64_reg.aw <= mmio64_to_afu.aw;
            end

            // Receive new write data
            if (mmio64_to_afu.wvalid && mmio64_to_afu.wready)
            begin
                mmio64_reg.wvalid <= 1'b1;
                mmio64_reg.w <= mmio64_to_afu.w;
            end
        end

        if (!reset_n)
        begin
            mmio64_reg.awvalid <= 1'b0;
            mmio64_reg.wvalid <= 1'b0;
        end
    end

    // Generate a CSR write response once both address and data have arrived
    assign mmio64_to_afu.bvalid = mmio64_reg.bvalid;
    assign mmio64_to_afu.b = mmio64_reg.b;

    always_ff @(posedge clk)
    begin
        if (is_csr_write)
        begin
            // New write response
            mmio64_reg.bvalid <= 1'b1;

            mmio64_reg.b <= '0;
            mmio64_reg.b.id <= mmio64_reg.aw.id;
            mmio64_reg.b.user <= mmio64_reg.aw.user;
        end
        else if (mmio64_to_afu.bready)
        begin
            // If a write response was pending it completed
            mmio64_reg.bvalid <= 1'b0;
        end

        if (!reset_n)
        begin
            mmio64_reg.bvalid <= 1'b0;
        end
    end


    //
    // Decode CSR writes into read/write engine commands.
    //
    always_ff @(posedge clk)
    begin
        // There is no flow control on the module's outgoing read/write command
        // ports. If a request was trigger in the last cycle, it was sent.
        rd_cmd.enable <= 1'b0;
        rd_cmd.load_model_weights <= 1'b0;
        wr_cmd.enable <= 1'b0;

        if (is_csr_write)
        begin
            // AXI addresses are always in byte address space. Ignore the
            // low 3 bits to index 64 bit CSRs. Ignore high bits and let the
            // address space wrap.
            case (mmio64_reg.aw.addr[10:3])
                // IP level reset, as needed
                1:
                    begin
                        ip_reset <= mmio64_reg.w.data[0];
                    end 
                // Read engine burst_size (number of beats in a single burst)
                2: 
                    begin
                        rd_cmd.burst_len <= mmio64_reg.w.data[$bits(rd_cmd.burst_len)-1 : 0];
                    end
                // Read start address
                3:
                    begin
                        rd_cmd.src_addr <= mmio64_reg.w.data[$bits(rd_cmd.src_addr)-1 : 0];
                        // Trigger a host memory read
                        rd_cmd.enable <= 1'b1;
                    end
                4:
                    begin
                        rd_cmd.dest_addr <= mmio64_reg.w.data[$bits(rd_cmd.dest_addr)-1 : 0];
                    end

                 // Write engine burst_len in a burst
                5:
                    begin
                        wr_cmd.burst_len <= mmio64_reg.w.data[$bits(wr_cmd.burst_len)-1 : 0];
                    end

                // Write start address
                6:
                    begin
                        wr_cmd.addr <= mmio64_reg.w.data[$bits(wr_cmd.addr)-1 : 0];
                        // Trigger a host memory write
                        wr_cmd.enable <= 1'b1;
                    end

                // Address for sending write completions 
                7:
                    begin
                        wr_cmd.cmpl_addr <= mmio64_reg.w.data[$bits(wr_cmd.cmpl_addr)-1 : 0];
                    end 
              
             endcase
        end
 
        if (!reset_n)
        begin
            rd_cmd.burst_len    <= 1'b1;
            rd_cmd.load_model_weights <= 1'b0;
            rd_cmd.enable       <= 1'b0;
            rd_cmd.src_addr         <= '0;
            rd_cmd.dest_addr        <= '0;
            wr_cmd.burst_len    <= 1'b0;
            wr_cmd.enable       <= 1'b0;
            wr_cmd.addr         <= '0;
            wr_cmd.cmpl_addr    <= '0;
            ip_reset            <= 1'b0;
        end
    end

endmodule

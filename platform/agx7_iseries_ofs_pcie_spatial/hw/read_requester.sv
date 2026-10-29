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

module read_requester #(
    parameter MAX_REQS_IN_FLIGHT = 32,
    parameter NUM_LOCAL_MEM_BANKS = 1
)(
    // Read command interface
    input spark_afu_pkg::t_rd_cmd  rd_cmd,
    output spark_afu_pkg::t_rd_state  rd_state,

    ofs_plat_axi_mem_if.to_sink host_mem,

    ofs_plat_axi_mem_if.to_sink ddr_mem[NUM_LOCAL_MEM_BANKS],
    ofs_plat_axi_mem_if.to_source_clk spark_ip
);
    import spark_afu_pkg::*;
    
    // Connect clocks and resets
    wire clk = host_mem.clk;
    wire reset_n = host_mem.reset_n;
    assign spark_ip.clk = clk;
    assign spark_ip.reset_n = reset_n;

    // Store incoming read commands
    t_cmd_burst_len rd_cmd_burst_len_out;
    t_cmd_host_addr rd_cmd_src_addr_out;
    t_cmd_dest_addr rd_cmd_dest_addr_out;
    wire [3:0] bank_sel = rd_cmd_dest_addr_out[3:0];
    wire is_spark_dest = (bank_sel == 4'd15);
    wire almost_full, empty, rd_en;
    wire [7:0] usedw;

    localparam  POP_READ_REQUEST = 0,
                SEND_READ_REQUEST = 1,
                WAIT_READ_REQUEST_READY = 2,
                SEND_WRITE_REQUEST = 3,
                WAIT_WRITE_REQUEST_READY = 5,
                PROCESS_RESPONSE = 6;

    logic [2:0] state;

    scfifo #(
        .intended_device_family("Agilex"),
        .lpm_numwords(MAX_REQS_IN_FLIGHT),
        .lpm_showahead("OFF"),
        .lpm_type("scfifo"),
        .lpm_width($bits(t_cmd_burst_len) + $bits(t_cmd_host_addr) + $bits(t_cmd_dest_addr)),
        .lpm_widthu($clog2(MAX_REQS_IN_FLIGHT)),
        .almost_full_value(MAX_REQS_IN_FLIGHT - 8),
        .overflow_checking("OFF"),
        .underflow_checking("OFF"),
        .use_eab("ON"),
        .add_ram_output_register("ON")
    ) 
    read_request_fifo (
        .clock(clk),
        .sclr(!reset_n),

        .data({rd_cmd.dest_addr, rd_cmd.burst_len, rd_cmd.src_addr}),
        .wrreq(!almost_full && rd_cmd.enable),
        .full(),
        .almost_full(almost_full),

        .rdreq(state == SEND_READ_REQUEST),
        .q({rd_cmd_dest_addr_out, rd_cmd_burst_len_out, rd_cmd_src_addr_out}),
        .empty(empty),
        .almost_empty(),

        .aclr(),
        .usedw(usedw),
        .eccstatus()
    );

    assign rd_state.requests_pending = usedw;
    assign rd_state.weights_processed[63:1] = 'b0;
    assign rd_state.weights_processed[0] = (state == POP_READ_REQUEST) && empty;

    /*************************************
    *                                    *
    *         Axi Transactions           *
    *                                    *
    *************************************/

    // Read IDs are supposed to be unique. Use a simple counter that is
    // large enough to know that earlier reads with the same ID are complete.
    // The PIM doesn't actually care whether IDs are unique.
    logic [$clog2(MAX_REQS_IN_FLIGHT):0] rd_id;
    always @(posedge clk) begin
        if (~reset_n)
            rd_id <= 'b0;
        else if (host_mem.arvalid && host_mem.arready)
            rd_id <= rd_id + 1;
    end

    // Configure request to host memory
    always_comb
    begin
        host_mem.ar = '0;
        host_mem.ar.id   = rd_id;
        host_mem.ar.addr = rd_cmd_src_addr_out;
        host_mem.arvalid = state == WAIT_READ_REQUEST_READY;
        host_mem.ar.len  = rd_cmd_burst_len_out;
        // Full width of the data bus
        host_mem.ar.size = host_mem.ADDR_BYTE_IDX_WIDTH;
    end
        
    // DDR bank mux infrastructure for return signals
    logic [NUM_LOCAL_MEM_BANKS-1:0] ddr_awready_vec;
    logic [NUM_LOCAL_MEM_BANKS-1:0] ddr_wready_vec;
    logic [NUM_LOCAL_MEM_BANKS-1:0] ddr_bvalid_vec;

    logic ddr_awready_muxed;
    logic ddr_wready_muxed;
    logic ddr_bvalid_muxed;

    always_comb begin
        ddr_awready_muxed = 1'b0;
        ddr_wready_muxed  = 1'b0;
        ddr_bvalid_muxed  = 1'b0;
        for (int i = 0; i < NUM_LOCAL_MEM_BANKS; i++) begin
            if (bank_sel == i[3:0]) begin
                ddr_awready_muxed = ddr_awready_vec[i];
                ddr_wready_muxed  = ddr_wready_vec[i];
                ddr_bvalid_muxed  = ddr_bvalid_vec[i];
            end
        end
    end

    // Per-bank DDR assignments
    genvar gi;
    generate
    for (gi = 0; gi < NUM_LOCAL_MEM_BANKS; gi = gi + 1) begin : gen_ddr_bank
        // Extract return signals into mux vectors
        assign ddr_awready_vec[gi] = ddr_mem[gi].awready;
        assign ddr_wready_vec[gi]  = ddr_mem[gi].wready;
        assign ddr_bvalid_vec[gi]  = ddr_mem[gi].bvalid;

        // Configure request to DDR memory
        always_comb begin
            ddr_mem[gi].aw = '0;
            ddr_mem[gi].aw.id   = rd_id;
            ddr_mem[gi].aw.addr = rd_cmd_dest_addr_out;
            ddr_mem[gi].awvalid = (bank_sel == gi[3:0]) && (state == WAIT_WRITE_REQUEST_READY);
            ddr_mem[gi].aw.len  = rd_cmd_burst_len_out;
            ddr_mem[gi].bready  = (bank_sel == gi[3:0]) && (state == PROCESS_RESPONSE);
            // Full width of the data bus
            ddr_mem[gi].aw.size = host_mem.ADDR_BYTE_IDX_WIDTH;
        end

        // Drive per-bank W channel
        assign ddr_mem[gi].wvalid = host_mem.rvalid & (state == PROCESS_RESPONSE) & (bank_sel == gi[3:0]);
        assign ddr_mem[gi].w.data  = host_mem.r.data;
        assign ddr_mem[gi].w.last  = host_mem.r.last;
        assign ddr_mem[gi].w.user = '0;
        assign ddr_mem[gi].w.strb = ~(ofs_plat_host_chan_pkg::DATA_WIDTH_BYTES'(0));

        // DDR read channel not used here
        assign ddr_mem[gi].arvalid = 1'b0;
        assign ddr_mem[gi].rready  = 1'b1;
    end
    endgenerate

    // Route read data from host to spark IP or DDR memory
    assign host_mem.rready = (state == PROCESS_RESPONSE) ? ddr_wready_muxed : spark_ip.rready;

    assign spark_ip.rvalid = host_mem.rvalid & is_spark_dest;
    assign spark_ip.r  = host_mem.r;

    // host write channel not used here
    assign host_mem.awvalid = 1'b0;
    assign host_mem.wvalid  = 1'b0;
    assign host_mem.bready  = 1'b1;

    // Only read valid, ready and data are used for spark_ip
    assign spark_ip.awready = 1'b1;
    assign spark_ip.arready  = 1'b1;
    assign spark_ip.wready  = 1'b1;
    assign spark_ip.bvalid  = 1'b0;
    
    always @(posedge clk) begin
        if (!reset_n) begin
            state <= POP_READ_REQUEST;
        end else begin
            case (state)
                POP_READ_REQUEST: begin
                    if (!empty)
                        state <= SEND_READ_REQUEST;
                end
                SEND_READ_REQUEST: begin
                    state <= WAIT_READ_REQUEST_READY;
                end
                WAIT_READ_REQUEST_READY: begin
                    if (host_mem.arready) begin
                        if (is_spark_dest)
                            state <= POP_READ_REQUEST;
                        else
                            state <= SEND_WRITE_REQUEST;
                    end
                end
                SEND_WRITE_REQUEST: begin
                    state <= WAIT_WRITE_REQUEST_READY;
                end
                WAIT_WRITE_REQUEST_READY: begin
                    if (ddr_awready_muxed)
                        state <= PROCESS_RESPONSE;
                end
                PROCESS_RESPONSE: begin
                    if (ddr_bvalid_muxed) begin
                        state <= POP_READ_REQUEST;
                    end
                end
            endcase
        end
    end


endmodule
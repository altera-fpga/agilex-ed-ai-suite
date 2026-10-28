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

//
// This is the main write engine, which consumes write commands and generates
// write requests to host memory using the incoming data stream as the payload.
//
// The write engine core is wrapped by a parent module named copy_write_engine(),
// which injects interrupts into the write stream as needed to inform the host
// that an operation is complete. Separating the two makes the logic easier
// to understand.
//

module write_engine #(
    parameter MAX_REQS_IN_FLIGHT = 128,
    parameter HOST_MEM_BUS_SIZE = 512, 
    parameter SPARK_IP_OUTPUT_BUS_SIZE = 32
) (
    // Host memory interface. Only write buses are connected.
    ofs_plat_axi_mem_if.to_sink host_mem,

    input [spark_afu_pkg::OUTPUT_NUM_BITS-1:0]  write_data [0:spark_afu_pkg::OUTPUT_NUM_LANES-1],
    input         write_data_valid,
    input         write_data_sop,
    input         write_data_last,
    output        write_data_ready,

    // Write engine control
    input  spark_afu_pkg::t_wr_cmd wr_cmd,
    output spark_afu_pkg::t_wr_state wr_state

);
    import spark_afu_pkg::*;

    //
    // Internal signals
    //
    wire clk = host_mem.clk;
    wire reset_n = host_mem.reset_n;
    localparam POP_REQUEST = 0,
                SEND_REQUEST = 1,
                WAIT_REQUEST_READY = 2,
                SEND_DATA = 3,
                PROCESS_RESPONSE = 4,
                SEND_COMPLETION_REQUEST = 5,
                SEND_COMPLETION_DATA = 6;

    logic [2:0] state;

    /*************************************
    *                                    *
    *          Input reformatting        *
    *                                    *
    *************************************/
    wire [SPARK_IP_OUTPUT_BUS_SIZE-1:0] unpacked_data;
    wire pad;

    genvar i;
    generate
        for(i = 0; i < OUTPUT_NUM_LANES; i = i + 1)begin:packing_output_from_spark
            assign unpacked_data[i*OUTPUT_NUM_BITS+:OUTPUT_NUM_BITS] = pad? 'b0 : write_data[i];
        end
    endgenerate

    
    /*************************************
    *                                    *
    *         Bus Width Converter        *
    *                                    *
    *************************************/
    // Convert from host memory bus size to SPARK IP expected bus size
    
    localparam PAD_BITS = HOST_MEM_BUS_SIZE - (HOST_MEM_BUS_SIZE/SPARK_IP_OUTPUT_BUS_SIZE)*SPARK_IP_OUTPUT_BUS_SIZE;
    logic rd_en_aligned;
    wire rd_en, full, almost_full, empty;
    logic [$clog2(spark_afu_pkg::WRITE_ENGINE_MAX_BURST):0] rd_en_counter;
    wire s2p_in_valid, s2p_out_valid;
    wire [HOST_MEM_BUS_SIZE-1:0] fifo_out, s2p_out;

    assign write_data_ready = !almost_full && !pad;
    assign rd_en = !empty && host_mem.wready && (state == SEND_DATA);

    s2p
    #(
        .DIN_WIDTH(SPARK_IP_OUTPUT_BUS_SIZE),
        .DOUT_WIDTH(HOST_MEM_BUS_SIZE)
    ) write_engine_converter
    (
        .clk(clk),
        .resetn(reset_n),
        // write side
        .din(unpacked_data),
        .din_valid(s2p_in_valid),
        // read side
        .dout(s2p_out),
        .dout_valid(s2p_out_valid)
    );
    
    scfifo #(
        .intended_device_family("Agilex"),
        .lpm_numwords(WRITE_ENGINE_MAX_BURST),
        .lpm_showahead("OFF"),
        .lpm_type("scfifo"),
        .lpm_width(HOST_MEM_BUS_SIZE),
        .lpm_widthu($clog2(WRITE_ENGINE_MAX_BURST)),
        .almost_full_value(WRITE_ENGINE_MAX_BURST - (8 > OUTPUT_SUB_VECTORS ? 8 : OUTPUT_SUB_VECTORS)),
        .overflow_checking("OFF"),
        .underflow_checking("OFF"),
        .use_eab("ON"),
        .add_ram_output_register("ON")
    ) 
    wr_data_fifo (
        .clock(clk),
        .sclr(!reset_n),

        .data(s2p_out),
        .wrreq(s2p_out_valid & !full),
        .full(full),
        .almost_full(almost_full),

        .rdreq(rd_en),
        .q(fifo_out),
        .empty(empty),
        .almost_empty(),

        .aclr(),
        .usedw(),
        .eccstatus()
    );

    always @(posedge clk) begin
        if(!reset_n)
            rd_en_aligned <= 1'b0;
        else if (host_mem.wready)
            rd_en_aligned <= rd_en;
    end
    
    
    /*************************************
    *                                    *
    *          Packet Manager            *
    *                                    *
    *************************************/
    // Generate padded sub vectors to fit in host memory bus.
    // The maximum number of subvectors per bus transaction is HOST_MEM_BUS_SIZE/SPARK_IP_OUTPUT_BUS_SIZE  
    // The number of bus transactions needed to send all subvectors is ceil(2048 / (HOST_MEM_BUS_SIZE/SPARK_IP_OUTPUT_BUS_SIZE))
    // So the number of sub vectors to flush is the product above minus the actual number of input sub vectors.
    // ie; subvectors per bus transaction * number of bus transactions - valid subvectors = padded subvectors
    localparam PAD_SUB_VECTORS = (HOST_MEM_BUS_SIZE/SPARK_IP_OUTPUT_BUS_SIZE) 
                                    * int'($ceil(real'(OUTPUT_SUB_VECTORS)/(HOST_MEM_BUS_SIZE/SPARK_IP_OUTPUT_BUS_SIZE)))
                                    - OUTPUT_SUB_VECTORS;

    write_packet_manager #(
        .SUB_VECTORS (OUTPUT_SUB_VECTORS),
        .PAD_SUB_VECTORS (PAD_SUB_VECTORS)
    ) wr_packet_manager (
        .clk(clk),
        .resetn(reset_n),

        .fifo_not_full(!almost_full),
        .s2p_input_valid(s2p_in_valid),
        .ip_valid(write_data_valid),
        .ip_first(write_data_sop),
        .ip_last(write_data_last),
        
        .pad(pad)
    );

    /*************************************
    *                                    *
    *          AXI Transactions          *
    *                                    *
    *************************************/
    wire request_fifo_empty, last;
    t_cmd_burst_len wr_cmd_burst_len_out;
    t_cmd_host_addr wr_cmd_addr_out;

    always @(posedge clk) begin
        if (!reset_n) begin
            state <= POP_REQUEST;
        end else begin
            case (state)
                POP_REQUEST: begin
                    if (!request_fifo_empty)
                        state <= SEND_REQUEST;
                end
                SEND_REQUEST: begin
                    state <= WAIT_REQUEST_READY;
                end
                WAIT_REQUEST_READY: begin
                    if (host_mem.awready)
                        state <= SEND_DATA;
                end
                SEND_DATA: begin
                    if ((rd_en_counter == wr_cmd_burst_len_out) && rd_en)
                        state <= PROCESS_RESPONSE;
                end
                PROCESS_RESPONSE: begin
                    if(host_mem.bvalid) begin
                        if(host_mem.b.id[0]) 
                            state <= SEND_COMPLETION_REQUEST;
                        else
                            state <= POP_REQUEST;
                    end
                end
                SEND_COMPLETION_REQUEST: begin
                    if(host_mem.awready)
                        state <= SEND_COMPLETION_DATA;
                end
                SEND_COMPLETION_DATA: begin
                    if(host_mem.wready)
                        state <= PROCESS_RESPONSE;
                end
                default:
                    state <= POP_REQUEST;
            endcase
        end
    end
    
    // Store incoming write commands in a FIFO that is large enough to hold
    // the maximum number of requests in flight. It is the responsibility of the
    // host not to overflow this FIFO.
    //
    wire wr_cmd_fifo_almost_full;
    wire [7:0] usedw;

    scfifo #(
        .intended_device_family("Agilex"),
        .lpm_numwords(MAX_REQS_IN_FLIGHT),
        .lpm_showahead("OFF"),
        .lpm_type("scfifo"),
        .lpm_width($bits(t_cmd_burst_len) + $bits(t_cmd_host_addr)),
        .lpm_widthu($clog2(MAX_REQS_IN_FLIGHT)),
        .almost_full_value(MAX_REQS_IN_FLIGHT - 8),
        .overflow_checking("OFF"),
        .underflow_checking("OFF"),
        .use_eab("ON"),
        .add_ram_output_register("ON")
    ) 
    wr_cmd_fifo (
        .clock(clk),
        .sclr(!reset_n),

        .data({wr_cmd.burst_len, wr_cmd.addr}),
        .wrreq(!wr_cmd_fifo_almost_full && wr_cmd.enable),
        .full(),
        .almost_full(wr_cmd_fifo_almost_full),

        .rdreq((state == SEND_REQUEST)),
        .q({wr_cmd_burst_len_out, wr_cmd_addr_out}),
        .empty(request_fifo_empty),
        .almost_empty(),

        .aclr(),
        .usedw(usedw),
        .eccstatus()
    );

    assign wr_state.requests_pending = usedw;

    //
    // Write IDs are supposed to be unique. Use a simple counter that is
    // large enough to know that earlier writes with the same ID are complete.
    logic [$clog2(MAX_REQS_IN_FLIGHT):0] wr_id;
    always_ff @(posedge clk)
    begin
        if (!reset_n)
            wr_id <= 0;
        else if (host_mem.awvalid && host_mem.awready)
            wr_id <= wr_id + 1;
    end

    //
    // Generate write requests. The host_mem interface from the PIM was configured
    // to accept write bursts up to the largest the host program will request.
    // This was done in ofs_plat_afu.sv at the declaration of host_mem.
    // There is thus a 1:1 mapping from incoming commands to AXI-MM write requests.
    //
    logic skid_state;
    //Hack to sync wr_cmd.cmpl_addr with send_completion_request state. Not a problem in send_request since
    // the state will be stable after transitioning during pop request state
    always @(posedge clk)
        skid_state <= (state == SEND_COMPLETION_REQUEST);

    always_comb begin
        host_mem.aw = '0;
        host_mem.aw.addr = skid_state ? wr_cmd.cmpl_addr : wr_cmd_addr_out;
        host_mem.aw.len = skid_state ? 0 : wr_cmd_burst_len_out;

        // The low bit of the address indicates whether to generate an interrupt
        // on completion. This will come back in the b channel.
        // Bit 1 must be 0. The interrupt injector uses bit 1.
        host_mem.aw.id = skid_state ? wr_id : { wr_id, 1'b0, wr_cmd_addr_out[0] };
        // Force the actual low address bit to 0
        host_mem.aw.addr[0] = 1'b0;

        // Full width of the data bus
        host_mem.aw.size = host_mem.ADDR_BYTE_IDX_WIDTH;
    end

    assign host_mem.bready = state == PROCESS_RESPONSE;

    always @(posedge clk) begin
        host_mem.awvalid <= state == SEND_REQUEST || state == SEND_COMPLETION_REQUEST;
        host_mem.wvalid <= rd_en_aligned || (state == SEND_COMPLETION_DATA);
        host_mem.w.user <= '0;
        host_mem.w.data <= (state == SEND_COMPLETION_DATA) ? 'b1 : fifo_out;
        // Always full data bus
        host_mem.w.strb <= ~(ofs_plat_host_chan_pkg::DATA_WIDTH_BYTES'(0));
        
    end

    /*
    ** 
    ** This behavior assumes that the AW channel will NOT pop another wr_cmd off the fifo until the 
    ** W channel has finished the current one. This is the behavior seen in simulation, but it 
    ** would also be good to look at how this can be enforced through host_mem.awvalid extra contol.
    ** Right now, awvalid is simply connected to notEmpty, so that means if awready stays true, the AW channel
    ** could flow out multiple commands. (However I guess the skid buffers in wrapper will ensure this doesnt happen?)
    ** It also might be hard to catch this issue if all write requests are same length. Will need to test this out 
    ** Uses write requests of different sizes. 
    */
    logic [$clog2(spark_afu_pkg::WRITE_ENGINE_MAX_BURST):0] num_beat_count;

    assign host_mem.w.last = (state == SEND_COMPLETION_DATA) ? 'b1 : last;
    assign last = (wr_cmd_burst_len_out == 0) ? host_mem.wvalid : (num_beat_count == wr_cmd_burst_len_out + 1);

    always @(posedge clk) begin
        if(!reset_n | (last & host_mem.wready)) begin
            num_beat_count <= '0;     
        end
        else if(rd_en_aligned && host_mem.wready) begin
            num_beat_count <= num_beat_count + 1'b1;
        end
    end
    
    // last is delayed and im too lazy to align all the signals so im making another counter to decide when to stop sending data.
    always @(posedge clk) begin
        if(!reset_n | (state == PROCESS_RESPONSE)) begin
            rd_en_counter <= '0;     
        end
        else if(rd_en) begin
            rd_en_counter <= rd_en_counter + 1'b1;
        end
    end

    //
    // Read request channel not used
    //
    assign host_mem.arvalid = 1'b0;
    assign host_mem.rready  = 1'b1;
    
endmodule
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
// Read engine. Consume read commands, generate read requests from host memory
// and stream data into the SPARK IP.
//


module read_engine #(
    //parameter VCHAN_NUM = 0,
    parameter MAX_REQS_IN_FLIGHT = 32,
    parameter MAX_BURST_SIZE = 8192,
    parameter HOST_MEM_BUS_SIZE = 512, 
    parameter SPARK_IP_INPUT_BUS_SIZE = 32     
)(
    // Host memory interface. Only read buses are connected.
    ofs_plat_axi_mem_if.to_sink host_mem,
    
    // Data stream to batch datain - wrap this in an interface - choose better naming convention
    output [spark_afu_pkg::INPUT_NUM_BITS-1:0]  read_data [0:spark_afu_pkg::INPUT_NUM_LANES-1],
    output         read_data_valid,
    output         read_data_sop,
    output         read_data_last,
    input          read_data_ready

);
    import spark_afu_pkg::*;

    //
    // Internal signals
    //
    wire clk = host_mem.clk;
    wire reset_n = host_mem.reset_n;

    /*************************************
    *                                    *
    *         Bus Width Converter        *
    *                                    *
    *************************************/
    // Convert from host memory bus size to SPARK IP expected bus size
    
    wire rd_en, full, almost_full, empty;
    wire p2s_valid, p2s_ready;
    wire [SPARK_IP_INPUT_BUS_SIZE-1:0] p2s_out, fifo_out;

    p2s
    #(
        .DIN_WIDTH(HOST_MEM_BUS_SIZE),
        .DOUT_WIDTH(SPARK_IP_INPUT_BUS_SIZE)
    ) read_engine_converter
    (
        .clk(clk),
        .resetn(reset_n),
        // write side
        .din(host_mem.r.data),
        .din_valid(host_mem.rvalid & host_mem.rready),
        .din_ready(p2s_ready),
        // read side
        .dout(p2s_out),
        .dout_valid(p2s_valid)
    );
    
    scfifo #(
        .intended_device_family("Agilex"),
        .lpm_numwords(READ_ENGINE_MAX_BURST),
        .lpm_showahead("OFF"),
        .lpm_type("scfifo"),
        .lpm_width(SPARK_IP_INPUT_BUS_SIZE),
        .lpm_widthu($clog2(READ_ENGINE_MAX_BURST)),
        .almost_full_value(READ_ENGINE_MAX_BURST - (8 > INPUT_SUB_VECTORS ? 8 : INPUT_SUB_VECTORS)),
        .overflow_checking("OFF"),
        .underflow_checking("OFF"),
        .use_eab("ON"),
        .add_ram_output_register("ON")
    ) 
    scfifo_component (
        .clock(clk),
        .sclr(!reset_n),

        .data({p2s_out}),
        .wrreq(p2s_valid & !full),
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

    assign host_mem.rready = p2s_ready & !almost_full;

    /*************************************
    *                                    *
    *          Packet Manager            *
    *                                    *
    *************************************/
    // Flush padded sub vectors to fit in host memory bus.
    // The maximum number of subvectors per bus transaction is HOST_MEM_BUS_SIZE/SPARK_IP_INPUT_BUS_SIZE  
    // The number of bus transactions needed to send all subvectors is ceil(2048 / (HOST_MEM_BUS_SIZE/SPARK_IP_INPUT_BUS_SIZE))
    // So the number of sub vectors to flush is the product above minus the actual number of input sub vectors.
    // ie; subvectors per bus transaction * number of bus transactions - valid subvectors = padded subvectors
    localparam FLUSH_SUB_VECTORS = (HOST_MEM_BUS_SIZE/SPARK_IP_INPUT_BUS_SIZE) 
                                    * int'($ceil(real'(INPUT_SUB_VECTORS)/(HOST_MEM_BUS_SIZE/SPARK_IP_INPUT_BUS_SIZE)))
                                    - INPUT_SUB_VECTORS;

    read_packet_manager #(
        .SUB_VECTORS (INPUT_SUB_VECTORS),
        .FLUSH_SUB_VECTORS (FLUSH_SUB_VECTORS)
    ) rd_packet_manager
    (
        .clk(clk),
        .resetn(reset_n),

        .ip_ready(read_data_ready),
        .fifo_not_empty(!empty),
        .fifo_rd_en(rd_en),
        .ip_valid(read_data_valid),
        .ip_first(read_data_sop),
        .ip_last(read_data_last)
    );


    /*************************************
    *                                    *
    *         Output reformatting        *
    *                                    *
    *************************************/
    genvar i;
    generate
        for(i = 0; i < INPUT_NUM_LANES; i = i + 1) begin : packing_input_to_spark
            assign read_data[i] = fifo_out[i*INPUT_NUM_BITS+:INPUT_NUM_BITS];
        end
    endgenerate

    // Write request channel not used in read engine
    //
    assign host_mem.awvalid = 1'b0;
    assign host_mem.wvalid  = 1'b0;
    assign host_mem.bready  = 1'b1;
    assign host_mem.arvalid = 1'b0;

endmodule

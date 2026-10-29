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

module read_packet_manager #(
        parameter SUB_VECTORS = 4,
        parameter FLUSH_SUB_VECTORS = 4,
        parameter HOST_MEM_BUS_SIZE = 512
    )(
        input clk,
        input resetn,

        input ip_ready,
        input fifo_not_empty,
        output fifo_rd_en,
        output logic ip_valid,
        output logic ip_first,
        output logic ip_last
);
    localparam READ = 0,
                FLUSH = 1;
    logic [1:0] state;
    logic [$clog2((SUB_VECTORS > FLUSH_SUB_VECTORS) ? SUB_VECTORS : FLUSH_SUB_VECTORS)-1:0] counter;

    logic valid_reg;

    assign fifo_rd_en = (state == READ) & ip_ready & fifo_not_empty |
                        (state == FLUSH & fifo_not_empty);
    
    always @(posedge clk) begin
        if (~resetn) begin
            state <= READ;
            counter <= 0;
            ip_valid <= 0;
        end else begin
            case (state)
                READ: begin
                    if(ip_ready) begin
                        ip_valid <= fifo_rd_en;
                        ip_first <= (counter == 0) & fifo_rd_en;
                        ip_last  <= (counter == SUB_VECTORS - 1) & fifo_rd_en;
                    end
                    if (fifo_rd_en) begin
                        counter <= counter + 1;
                        if (counter == SUB_VECTORS - 1) begin
                            counter <= 0;
                            if(FLUSH_SUB_VECTORS != 0)
                                state <= FLUSH;
                        end
                    end
                end
                FLUSH: begin
                    ip_valid <= 0;
                    ip_first <= 0;
                    ip_last  <= 0;
                    if (fifo_rd_en) begin
                        counter <= counter + 1;
                        if (counter == FLUSH_SUB_VECTORS - 1) begin
                            state <= READ;
                            counter <= 0;
                        end
                    end
                end
            endcase
        end
    end

endmodule
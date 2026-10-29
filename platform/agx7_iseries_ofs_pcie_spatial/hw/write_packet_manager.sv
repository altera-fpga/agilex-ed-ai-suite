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

module write_packet_manager #(
        parameter SUB_VECTORS = 4,
        parameter PAD_SUB_VECTORS = 4
    )(
        input clk,
        input resetn,

        input ip_valid,
        input ip_first,
        input ip_last,

        input fifo_not_full,
        output s2p_input_valid,
        output pad
);
    localparam WRITE = 0,
                PAD = 1;
    logic [1:0] state;
    logic [$clog2((SUB_VECTORS > PAD_SUB_VECTORS) ? SUB_VECTORS : PAD_SUB_VECTORS)-1:0] counter;
    
    assign s2p_input_valid = ((state == WRITE) & ip_valid & fifo_not_full) |
                        (state == PAD & fifo_not_full);
    assign pad = (state == PAD);
    
    always @(posedge clk) begin
        if (~resetn) begin
            state <= WRITE;
            counter <= 0;
        end else begin
            case (state)
                WRITE: begin
                    if (ip_last && ip_valid && PAD_SUB_VECTORS != 0)
                        state <= PAD;
                end
                PAD: begin
                    if (s2p_input_valid) begin
                        counter <= counter + 1;
                        if (counter == PAD_SUB_VECTORS - 1) begin
                            state <= WRITE;
                            counter <= 0;
                        end
                    end
                end
            endcase
        end
    end

endmodule
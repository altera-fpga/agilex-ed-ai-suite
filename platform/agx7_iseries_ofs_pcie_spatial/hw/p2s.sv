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

module p2s #(
    parameter DIN_WIDTH = 64,
    parameter DOUT_WIDTH = 8
) (
    input clk,
    input resetn,

    input [DIN_WIDTH-1:0] din,
    input din_valid,
    output din_ready,

    output [DOUT_WIDTH-1:0] dout,
    output dout_valid
);

localparam CHUNKS = DIN_WIDTH / DOUT_WIDTH;
localparam CHUNK_INDEX_SIZE = $clog2(CHUNKS+1);

generate
if (CHUNKS == 1) begin
    assign din_ready = 1'b1;
    assign dout = din;
    assign dout_valid = din_valid;
end else begin

    reg [CHUNK_INDEX_SIZE-1:0] chunks_in_sr; 
    reg [DIN_WIDTH-1:0] din_r;
    reg dout_valid_r;
    reg din_ready_r;

    assign dout_valid = dout_valid_r;
    assign din_ready = din_ready_r;
    assign dout = din_r[DOUT_WIDTH-1:0];

    always @(posedge clk) begin
        if (resetn == 0) begin
            chunks_in_sr <= 0;
            dout_valid_r <= 0;
            din_r <= 0;
            din_ready_r <= 1;
        end else begin

            din_ready_r <= 1;
            dout_valid_r <= 0;
            if (din_ready && din_valid) begin
                chunks_in_sr <= CHUNKS-1;
                din_r <= din;
                dout_valid_r <= 1;
                din_ready_r <= 0;
            end
            if (chunks_in_sr != 0) begin
                dout_valid_r <= 1;
                din_r <= {{DOUT_WIDTH{1'b0}}, din_r[DIN_WIDTH-1:DOUT_WIDTH]};
                chunks_in_sr <= chunks_in_sr - 1'b1;
            end
            if (chunks_in_sr > 1) begin
                din_ready_r <= 0;
            end
        end
    end
end
endgenerate
endmodule
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

module s2p #(
    parameter DIN_WIDTH = 8,
    parameter DOUT_WIDTH = 64
) (
    input clk,
    input resetn,

    input [DIN_WIDTH-1:0] din,
    input din_valid,

    output [DOUT_WIDTH-1:0] dout,
    output dout_valid
);

localparam CHUNKS = DOUT_WIDTH / DIN_WIDTH;
localparam CHUNK_INDEX_SIZE = $clog2(CHUNKS+1);
localparam STARTING_BIT = DIN_WIDTH*CHUNKS-1;

generate
if (CHUNKS == 1) begin
    assign din_ready = 1'b1;
    assign dout = din;
    assign dout_valid = din_valid;
end else begin

    reg [CHUNK_INDEX_SIZE-1:0] chunks_in_sr; 
    reg [DOUT_WIDTH-1:0] dout_r;
    reg dout_valid_r;

    assign dout_valid = dout_valid_r;
    assign dout = {{{DOUT_WIDTH-STARTING_BIT+1}{1'b0}}, dout_r[STARTING_BIT:0]};

    always @(posedge clk) begin
        if (resetn == 0) begin
            chunks_in_sr <= CHUNKS-1;
            dout_valid_r <= 0;
            dout_r <= 0;
        end else begin
            dout_valid_r <= 0;
            if (din_valid) begin
                chunks_in_sr <= chunks_in_sr - 'b1;
                dout_r[STARTING_BIT-:DIN_WIDTH] <= din;
                for (int i = CHUNKS-1; i > 0; i = i - 1) begin
                    dout_r[DIN_WIDTH*i-1-:DIN_WIDTH] <= dout_r[DIN_WIDTH*(i+1)-1-:DIN_WIDTH];
                end
                
                if (chunks_in_sr == 0) begin
                    dout_valid_r <= 1;
                    chunks_in_sr <= CHUNKS-1;
                end
            end
            
        end
    end
end
endgenerate
endmodule
// Copyright 2020 Altera Corporation.
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

//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
//
//  ACL ECC ENCODER
//
//  This module encodes data using a single error correct, double error detect Hamming code. As the data width get large,
//  so will the xor network and that would limit fmax. To resolve this, we slice the data into smaller groups and encode
//  each independently. Essentially we trade off more memory overhead for parity bits in order to limit the fmax
//  degradation due to ECC.
//
//  The user must specify the data width and the slicing size. From this, one can compute the number of parity bits and
//  total encoded bits (see the calculations in localparams below).
//
//  Reset: there is no reset. Pipeline stages are purely feed-forward, the intent is that reset will propagate through.
//
//  This module is actually a wrapper around the actual ECC implementation in secded_encoder. Here is the architecture.
//  For example, suppose DATA_WIDTH is 70 and ECC_GROUP_SIZE is 32, then we will slice input data into 32 + 32 + 6, and
//  3 encoders are used to produce 39 + 39 + 11 encoded bits.
//
//                                 i_data[69:0]
//                                      |
//  +------------------------------------------------------------------------+
//  |                     optional input pipeline stages                     |
//  +------------------------------------------------------------------------+
//          |                           |                           |
//      data[69:64]                 data[63:32]                 data[31:0]
//          |                           |                           |
//  +----------------+          +----------------+          +----------------+
//  | secded_encoder |          | secded_encoder |          | secded_encoder |
//  +----------------+          +----------------+          +----------------+
//          |                           |                           |
//    encoded[88:78]              encoded[77:39]              encoded[38:0]
//          |                           |                           |
//  +------------------------------------------------------------------------+
//  |                     optional output pipeline stages                    |
//  +------------------------------------------------------------------------+
//                                      |
//                                o_encoded[88:0]
//
//  Required files:
//  - dla_acl_ecc_encoder.sv
//  - dla_acl_ecc_pkg.sv
//
//  Related files (to do the corresponding decoding that this file encodes):
//  - dla_acl_ecc_decoder.sv
//
//////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////

`default_nettype none

//BEWARE: do not leave the "clock_enable" input port disconnected if any pipeline stages are used, it will default to 0 and nothing will go through

module dla_acl_ecc_encoder
import dla_acl_ecc_pkg::*;
#(
    parameter int DATA_WIDTH,                   //number of bits in the unencoded input data
    parameter int ECC_GROUP_SIZE,               //how many bits of unencoded data to group into one ecc block, see description in header comments
    parameter int INPUT_PIPELINE_STAGES = 0,    //number of pipeline stages between i_data and the ecc encoder
    parameter int OUTPUT_PIPELINE_STAGES = 0    //number of pipeline stages between the ecc encoder and o_encoded
)
(
    input  wire                                                          clock,         //clock is only needed if pipeline stages are nonzero
    input  wire                                                          clock_enable,  //set to 1 to sample i_data, intended for integration with altera_syncram, only needed if pipeline stages are nonzero
    input  wire  [DATA_WIDTH-1:0]                                        i_data,        //unencoded input data
    output logic [getEncodedBitsEccGroup(DATA_WIDTH,ECC_GROUP_SIZE)-1:0] o_encoded      //encoded output data
);

    //helper functions for determining number of bits are defined in dla_acl_ecc.svh
    localparam int ECC_NUM_GROUPS  = getNumGroups(DATA_WIDTH,ECC_GROUP_SIZE);           //how many groups to slice the data into
    localparam int LAST_GROUP_SIZE = getLastGroupSize(DATA_WIDTH,ECC_GROUP_SIZE);       //all groups have size ECC_GROUP_SIZE except possibly the last group which may be smaller since it gets the remaining bits
    localparam int ENCODED_BITS    = getEncodedBitsEccGroup(DATA_WIDTH,ECC_GROUP_SIZE);

    //internal signals
    genvar g;
    logic [DATA_WIDTH-1:0] data;
    logic [ENCODED_BITS-1:0] encoded;

    //input pipeline stages
    generate
    if (INPUT_PIPELINE_STAGES == 0) begin
        assign data = i_data;
    end
    else begin
        logic [DATA_WIDTH-1:0] data_pipe [INPUT_PIPELINE_STAGES-1:0];
        always_ff @(posedge clock) begin
            if (clock_enable) data_pipe[0] <= i_data;
        end
        for (g=1; g<INPUT_PIPELINE_STAGES; g++) begin : gen_input_pipe
            always_ff @(posedge clock) begin
                data_pipe[g] <= data_pipe[g-1];
            end
        end
        assign data = data_pipe[INPUT_PIPELINE_STAGES-1];
    end
    endgenerate

    //slice the data for each encoder
    generate
    for (g=0; g<ECC_NUM_GROUPS; g++) begin : gen_encoder
        localparam int RAW_BASE = ECC_GROUP_SIZE*g;
        localparam int ENC_BASE = getEncodedBits(ECC_GROUP_SIZE)*g;
        localparam int RAW_WIDTH = (g==ECC_NUM_GROUPS-1) ? LAST_GROUP_SIZE : ECC_GROUP_SIZE;
        localparam int ENC_WIDTH = getEncodedBits(RAW_WIDTH);

        secded_encoder #(
            .DATA_WIDTH (RAW_WIDTH)
        )
        secded_encoder_inst
        (
            .i_data     (data[RAW_BASE +: RAW_WIDTH]),
            .o_encoded  (encoded[ENC_BASE +: ENC_WIDTH])
        );
    end
    endgenerate

    //output pipeline stages
    generate
    if (OUTPUT_PIPELINE_STAGES == 0) begin
        assign o_encoded = encoded;
    end
    else begin
        logic [ENCODED_BITS-1:0] encoded_pipe [OUTPUT_PIPELINE_STAGES-1:0];
        if (INPUT_PIPELINE_STAGES == 0) begin    //this is the first pipeline stage
            always_ff @(posedge clock) begin
                if (clock_enable) encoded_pipe[0] <= encoded;
            end
        end
        else begin  //there was a previous pipeline in the input stage which would have captured the clock enable
            always_ff @(posedge clock) begin
                encoded_pipe[0] <= encoded;
            end
        end
        for (g=1; g<OUTPUT_PIPELINE_STAGES; g++) begin : gen_output_pipe
            always_ff @(posedge clock) begin
                encoded_pipe[g] <= encoded_pipe[g-1];
            end
        end
        assign o_encoded = encoded_pipe[OUTPUT_PIPELINE_STAGES-1];
    end
    endgenerate

endmodule
//end dla_acl_ecc_encoder




// Hamming code encoder, single error correct, double error detect
//
// This implementation follows the bit mapping as shown on Wikipedia, parity bits are added at power of 2 locations, data bits go in between
// For example, with DATA_WIDTH = 11, we have 4 Hamming parity bits and one overall parity bit, so the bit locations will looks like this, d means data, p means parity
// [0] = p0, [1] = p1, [2] = p2, [3] = d0, [4] = p3, [5] = d1, [6] = d2, [7] = d3, [8] = p4, [9] = d4, [10] = d5, [11] = d6, [12] = d7, [13] = d8, [14] = d9, [15] = d10

module secded_encoder
import dla_acl_ecc_pkg::*;
#(
    parameter int DATA_WIDTH                                    //number of bits in the unencoded input data
) (
    input  wire  [DATA_WIDTH-1:0]                 i_data,       //unencoded input data
    output logic [getEncodedBits(DATA_WIDTH)-1:0] o_encoded     //encoded output data
);

    //helper functions for determining number of bits are defined in dla_acl_ecc.svh
    localparam int PARITY_BITS = getParityBits(DATA_WIDTH);
    localparam int ENCODED_BITS = getEncodedBits(DATA_WIDTH);

    //parity bits go at power of 2 bit locations, data bits go in between
    //for example, with DATA_WIDTH = 11, we have 5 parity bits and the bit locations will looks like this, d means data, p means parity
    //[0] = p0, [1] = p1, [2] = p2, [3] = d0, [4] = p3, [5] = d1, [6] = d2, [7] = d3, [8] = p4, [9] = d4, [10] = d5, [11] = d6, [12] = d7, [13] = d8, [14] = d9, [15] = d10
    logic [ENCODED_BITS-1:0] data_expanded;
    always_comb begin
        for (int enc_index=0, data_index=0; enc_index<ENCODED_BITS; enc_index++) begin
            if (enc_index == 0 || (2**$clog2(enc_index)) == enc_index) begin    //enc_index is a power of 2
                data_expanded[enc_index] = 1'b0;
            end
            else begin
                data_expanded[enc_index] = i_data[data_index];
                data_index++;
            end
        end
    end

    //compute the parity bits
    logic [PARITY_BITS-1:0] parity;
    always_comb begin
        for (int parity_index=1; parity_index<PARITY_BITS; parity_index++) begin
            parity[parity_index] = 0;
            for (int enc_index=0; enc_index<ENCODED_BITS; enc_index++) begin
                if (enc_index & (1<<(parity_index-1))) begin   //bit parity_index-1 of enc_index is 1
                    parity[parity_index] = parity[parity_index] ^ data_expanded[enc_index]; //running xor
                end
            end
        end
        parity[0] = (^parity[PARITY_BITS-1:1]) ^ (^i_data);     //overall parity
    end

    //assemble the output data
    always_comb begin
        for (int enc_index=0, parity_index=0; enc_index<ENCODED_BITS; enc_index++) begin
            if (enc_index == 0 || (2**$clog2(enc_index)) == enc_index) begin    //enc_index is a power of 2
                o_encoded[enc_index] = parity[parity_index];
                parity_index++;
            end
            else begin
                o_encoded[enc_index] = data_expanded[enc_index];
            end
        end
    end

endmodule
//end secded_encoder

`default_nettype wire

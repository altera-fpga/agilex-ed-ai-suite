// Copyright 2026 Altera Corporation.
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

// Measures inference latency, taken to be the time from the last beat of the
// model input to the last beat of the model output. It is placed between the
// spatial IP and the CDC on kernel clk. The stream widths and tensor sizes come
// from the compiled model which is set by the system.tcl jinja template 

module spatial_inference_timer #(
    parameter INPUT_DATA_WIDTH   = 32,
    parameter INPUT_TOTAL_BEATS  = 1,
    parameter OUTPUT_DATA_WIDTH  = 32,
    parameter OUTPUT_TOTAL_BEATS = 1
) (
    input  wire                          clk,
    input  wire                          reset,

    // Model input tensor
    input  wire [INPUT_DATA_WIDTH-1:0]   input_sink_data,
    input  wire                          input_sink_valid,
    output wire                          input_sink_ready,
    output wire [INPUT_DATA_WIDTH-1:0]   input_source_data,
    output wire                          input_source_valid,
    input  wire                          input_source_ready,

    // Model output tensor
    input  wire [OUTPUT_DATA_WIDTH-1:0]  output_sink_data,
    input  wire                          output_sink_valid,
    output wire                          output_sink_ready,
    output wire [OUTPUT_DATA_WIDTH-1:0]  output_source_data,
    output wire                          output_source_valid,
    input  wire                          output_source_ready,

    // Avalon-MM slave
    input  wire [1:0]                    avs_address,
    input  wire                          avs_read,
    output reg  [31:0]                   avs_readdata,  // Master reads
    output wire                          avs_waitrequest
);

localparam COUNTER_WIDTH = 32;
assign avs_waitrequest = 1'b0;

wire input_last_beat;

// Count until input packet has finished streaming 
spatial_beat_counter #(
    .DATA_WIDTH  (INPUT_DATA_WIDTH),
    .TOTAL_BEATS (INPUT_TOTAL_BEATS)
) input_beats (
    .clk       (clk),
    .reset     (reset),
    .asi_data  (input_sink_data),
    .asi_valid (input_sink_valid),
    .asi_ready (input_sink_ready),
    .aso_data  (input_source_data),
    .aso_valid (input_source_valid),
    .aso_ready (input_source_ready),
    .last_beat (input_last_beat)
);

// input_done remembers when the input has received its entire tensor since
// input_last_beat is held high for one cycle
reg  input_done;
wire inference_start = input_done;

always @(posedge clk) begin
    if (reset)
        input_done <= 1'b0;
    else
        input_done <= inference_start ? 1'b0 : (input_done || input_last_beat);
end

wire output_last_beat;

// Count until output packet has finished streaming
spatial_beat_counter #(
    .DATA_WIDTH  (OUTPUT_DATA_WIDTH),
    .TOTAL_BEATS (OUTPUT_TOTAL_BEATS)
) output_beats (
    .clk       (clk),
    .reset     (reset),
    .asi_data  (output_sink_data),
    .asi_valid (output_sink_valid),
    .asi_ready (output_sink_ready),
    .aso_data  (output_source_data),
    .aso_valid (output_source_valid),
    .aso_ready (output_source_ready),
    .last_beat (output_last_beat)
);

wire [COUNTER_WIDTH-1:0] cycle_count;
wire [COUNTER_WIDTH-1:0] live_count;
wire                     running;
wire                     measured;

// Measure the number of cycles between `inference_start` and `output_last_beat`
spatial_latency_counter #(
    .COUNTER_WIDTH (COUNTER_WIDTH)
) output_latency (
    .clk         (clk),
    .reset       (reset),
    .start       (inference_start),
    .stop        (output_last_beat),
    .cycle_count (cycle_count),
    .live_count  (live_count),
    .running     (running),
    .measured    (measured)
);

// Write inference timing results
always @(posedge clk) begin
    if (reset)
        avs_readdata <= 32'h0;
    else if (avs_read) begin
        case (avs_address)
            // Addressing is also defined in setup_project.py and address_map.h
            2'd0: avs_readdata <= cycle_count;
            2'd1: avs_readdata <= {30'b0, measured, running};
            2'd2: avs_readdata <= live_count;
            default: avs_readdata <= 32'h0;
        endcase
    end
end

endmodule

// Module for each I/O port to count TOTAL_BEATS on the streamed tensor
module spatial_beat_counter #(
    parameter DATA_WIDTH  = 32,
    parameter TOTAL_BEATS = 1
) (
    input  wire                  clk,
    input  wire                  reset,

    input  wire [DATA_WIDTH-1:0] asi_data,
    input  wire                  asi_valid,
    output wire                  asi_ready,

    output wire [DATA_WIDTH-1:0] aso_data,
    output wire                  aso_valid,
    input  wire                  aso_ready,

    // raised high when the last beat of the tensor has been
    // received
    output wire                  last_beat
);

localparam COUNTER_WIDTH = (TOTAL_BEATS > 1) ? $clog2(TOTAL_BEATS) : 1;

reg [COUNTER_WIDTH-1:0] beat_count;
wire accepted = asi_valid && aso_ready;

// Forward tensor data straight through
assign aso_data   = asi_data;
assign aso_valid  = asi_valid;
assign asi_ready  = aso_ready;
assign last_beat  = accepted && (beat_count == TOTAL_BEATS - 1);

always @(posedge clk) begin
    if (reset)
        beat_count <= {COUNTER_WIDTH{1'b0}};
    else if (accepted)
        beat_count <= last_beat ? {COUNTER_WIDTH{1'b0}} : beat_count + 1'b1;
end

endmodule

// Counts the clock cycles of one inference between `start` and `stop`
module spatial_latency_counter #(
    parameter COUNTER_WIDTH = 32
) (
    input  wire                     clk,
    input  wire                     reset,
    input  wire                     start,
    input  wire                     stop,

    output reg  [COUNTER_WIDTH-1:0] cycle_count,
    output reg  [COUNTER_WIDTH-1:0] live_count,
    output reg                      running,
    output reg                      measured
);

always @(posedge clk) begin
    if (reset) begin
        live_count  <= {COUNTER_WIDTH{1'b0}};
        cycle_count <= {COUNTER_WIDTH{1'b0}};
        running     <= 1'b0;
        measured    <= 1'b0;
    end
    else if (start) begin
        // begin cycle count at 0
        live_count  <= {{COUNTER_WIDTH-1{1'b0}}, 1'b1};  // 1
        cycle_count <= {COUNTER_WIDTH{1'b0}};
        running     <= 1'b1;
        measured    <= 1'b0;
    end
    else if (running) begin
        live_count <= live_count + 1'b1;
        if (stop) begin
            cycle_count <= live_count;
            running     <= 1'b0;
            measured    <= 1'b1;
        end
    end
end

endmodule

// Copyright 2020-2024 Altera Corporation.
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

/*-------------------------------------------------------------------------------
 * Module:      dla_demux
 *
 * Description:
 *   This instance of `dla_demux` acts as a critical control element in the overlay
 *   IP dataflow, steering de-grouped crossbar output data to one of two destinations:
 *     1. Feature Writer (for spilling intermediate results to external DDR memory)
 *     2. Output Streamer (for streaming final or intermediate results out of the IP)
 *
 *   The selection of the data path is controlled via the configuration interface,
 *   which is programmed dynamically at runtime. The demux ensures that only one
 *   destination is active at a time, based on the configuration and handshake signals.
 *
 *   The `i_transmitter_done` signal serves as a synchronization and completion indicator
 *   for the current data transaction. It is asserted when either the output streamer or
 *   the feature writer has finished processing the current burst or block of data. This
 *   prevents premature reconfiguration or switching of the data path, ensuring data
 *   integrity and proper transaction sequencing.
 *
 *     - When streaming out, `i_transmitter_done` is asserted when all output data
 *       has been sent by the streamer.
 *     - When spilling to DDR, `i_transmitter_done` is asserted when the feature writer
 *       completes its DDR write transaction.
 *     - In this design, `i_transmitter_done` is the logical OR of `xbar_input_done`
 *       and `done_write_dla`, signaling completion of either operation.
 *
 *   The configuration handshake (`i_config_valid`, `o_config_ready`) ensures that new
 *   configuration data is only accepted when the demux is idle (i.e., not in the
 *   middle of an active transmission).
 *
 * Parameters:
 *   - CONFIG_WIDTH:          Width of the configuration data bus.
 *   - DATA_WIDTH:            Width of the data bus, determined by the crossbar output.
 *
 * Key Ports:
 *   - clk_dla:               Clock input for synchronous operation.
 *   - i_aresetn:             Asynchronous active-low reset.
 *   - i_config_data:         Configuration data for path selection.
 *   - i_config_valid:        Indicates configuration data is valid.
 *   - o_config_ready:        Indicates module is ready to accept configuration.
 *   - o_ready:               Back-pressure/ready signal for upstream data source.
 *   - i_valid:               Indicates valid input data.
 *   - i_data:                Input data bus.
 *   - i_transmitter_done:    Transaction completion signal (see above).
 *   - i_1_ready:             Ready signal from feature writer.
 *   - o_1_valid:             Valid signal to feature writer.
 *   - i_2_ready:             Ready signal from output streamer.
 *   - o_2_valid:             Valid signal to output streamer.
 *   - o_data:                Demultiplexed output data bus.
 *
 * Usage Notes:
 *   - Always ensure that `i_transmitter_done` accurately reflects transaction
 *     completion for all possible destinations to avoid data hazards.
 *   - The demux should only be reconfigured when idle and not in the middle of
 *     a data burst.
 *------------------------------------------------------------------------------*/

`resetall
`undefineall
`default_nettype none
`include "dla_acl_parameter_assert.svh"

module dla_demux import dla_common_pkg::*, dla_demux_pkg::*; #(
  // DLA (input data) side parameters
  parameter   int CONFIG_WIDTH                  = 32,
  parameter   int DATA_WIDTH                    = 32
) (
  input  wire                                 clk_dla,
  input  wire                                 i_aresetn,

  // config input
  input  wire  [CONFIG_WIDTH-1:0]             i_config_data,
  input  wire                                 i_config_valid,
  output logic                                o_config_ready,

  // Input Data
  output logic                                o_ready,            // backpressure to upstream
  input  wire                                 i_valid,            // valid from upstream
  input  wire [DATA_WIDTH-1:0]                i_data,             // input data from xbar
  input  wire                                 i_transmitter_done, //upstream done

  // Output 1 Data (select = 0)
  input  wire                                i_1_ready,      // backpressure from downstream 1
  output wire                                o_1_valid,      // valid to downstream 1

  // Output 2 Data (select = 1)
  input  wire                                i_2_ready,      // backpressure from downstream 2
  output wire                                o_2_valid,      // valid to downstream 2

  // Output Data
  output logic [DATA_WIDTH-1:0]              o_data          // Output data
);

// Handle Config data
    logic   [CONFIG_WIDTH-1:0] config_offset;
    logic                      config_done;
    demux_sel_config_t         cfg;
    logic                      select;     // select signal

    localparam int NUM_CONFIG_OFFSETS = divCeil($bits(cfg), CONFIG_WIDTH);

    // For now, ensure size of config is exact multiple of CONFIG_WIDTH
    `DLA_ACL_PARAMETER_ASSERT($bits(cfg) == NUM_CONFIG_OFFSETS * CONFIG_WIDTH);

    //reset parameterization
    localparam int RESET_USE_SYNCHRONIZER = 1;
    localparam int RESET_PIPE_DEPTH       = 3;
    localparam int RESET_NUM_COPIES       = 1;

    logic [RESET_NUM_COPIES-1:0] sclrn;

    /////////////////////////////
    //  Reset Synchronization  //
    /////////////////////////////

    dla_reset_handler_simple #(
        .USE_SYNCHRONIZER   (RESET_USE_SYNCHRONIZER),
        .PIPE_DEPTH         (RESET_PIPE_DEPTH),
        .NUM_COPIES         (RESET_NUM_COPIES)
    ) dla_demux_synchronizer (
        .clk                (clk_dla),
        .i_resetn           (i_aresetn),
        .o_sclrn            (sclrn)
    );

    assign select = cfg.select[0];
    assign o_config_ready = ~config_done;

    // Register to hold previous value of i_transmitter_done for edge detection.
    logic transmitted_done_d;

    // On each clock cycle, store the current value of i_transmitter_done.
    // Reset the stored value on active-low asynchronous reset.
    always_ff @(posedge clk_dla) begin
        transmitted_done_d <= i_transmitter_done;
        if (~sclrn[0]) begin
            transmitted_done_d <= 1'b0;
        end
    end

    // Generate a one-cycle pulse on the rising edge of i_transmitter_done.
    // This is used to clear config_done only once per transaction completion.
    logic transmitter_done_rise;
    assign transmitter_done_rise = i_transmitter_done & ~transmitted_done_d;

    always_ff @(posedge clk_dla) begin
        // config state machine
        if (i_config_valid & o_config_ready) begin
            // update progress in accepting NUM_CONFIG_OFFSETS transactions
            if (config_offset == NUM_CONFIG_OFFSETS-1) begin
                config_offset    <= '0;
                config_done <= 1'b1;
            end
            else begin
                config_offset  <= config_offset + 1'b1;
            end
            cfg <= (i_config_data[CONFIG_WIDTH-1:0] << ($bits(cfg) - CONFIG_WIDTH)) | (cfg >> CONFIG_WIDTH);
        end else begin
            // If a transaction just completed, clear config_done so that
            // new configuration data can be accepted.
            if (transmitter_done_rise) begin
                config_done <= 0;
            end
        end
        // resetn
        if (~sclrn[0]) begin
            config_done <= 1'b0;
            config_offset <= '0;
            cfg.select <= '0;
        end
    end

    // steer input data
    logic i_ready_comb, intermediate_out_valid;
    assign i_ready_comb = config_done ? (select ? i_2_ready : i_1_ready) : 1'b0;
    assign o_1_valid = config_done ? (select ? 1'b0 : intermediate_out_valid) : 1'b0;
    assign o_2_valid = config_done ? (select ? intermediate_out_valid : 1'b0) : 1'b0;

    dla_st_pipeline_stage #(
      .DATA_WIDTH  (DATA_WIDTH   )
    ) inp_pipe_inst (
      .clock       (clk_dla               ),
      .i_resetn    (sclrn[0]              ),
      .o_ready     (o_ready               ),
      .i_valid     (i_valid               ),
      .i_data      ({>>{i_data}}          ),
      .i_ready     (i_ready_comb          ),
      .o_valid     (intermediate_out_valid),
      .o_data      ({>>{o_data}}          )
    );

endmodule

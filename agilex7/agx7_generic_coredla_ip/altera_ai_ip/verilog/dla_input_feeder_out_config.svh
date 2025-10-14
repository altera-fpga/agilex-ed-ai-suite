// Copyright 2024 Altera Corporation.
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

/*
  This is the shared datatype between C++ compiler config generation and input feeder out module
  Config layout output side of stream buffer
  fpga/input_feeder/rtl/dla_stream_buffer_manager.sv
*/
typedef enum enum_uint8_t {
  MPBW_MODE_NORMAL,
  MPBW_MODE_WAIT_ALL_DONE,
  MPBW_MODE_DISABLE
} mpbw_mode_t;

typedef struct packed {
  uint16_t stream_id;               // padding for 32-bit alignment
  uint8_t is_no_op;                 // is the read a no op
  mpbw_mode_t min_prev_buffer_mode; // min prev buffer writes mode
  int32_t initial_read_counter;     // This is set to 1 + MPBW + 2        .                  1                 2
                                    // The two comes from a hardware latency from write/read -> counter update -> subract
                                    // The one come from converting MPBW to a read_counter
                                    // A MPBW of zero still means a write must proceed a read for every address
                                    // write counter must be ahead of read_counter by one
} input_feeder_out_config_t;

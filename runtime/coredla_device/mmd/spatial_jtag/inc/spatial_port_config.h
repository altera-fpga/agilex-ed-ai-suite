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

#ifndef SPATIAL_PORT_CONFIG_H
#define SPATIAL_PORT_CONFIG_H

#include <string>

// Runtime port geometry for the spatial IP. setup_project.py writes it per
// design into port_config.json and the MMD reads it back here.
struct SpatialPortConfig {
  unsigned input_data_width = 0;
  unsigned input_lanes = 0;
  unsigned input_subvectors = 0;
  unsigned input_packets = 0;
  unsigned output_data_width = 0;
  unsigned output_lanes = 0;
  unsigned output_subvectors = 0;
  unsigned output_packets = 0;

  unsigned input_packet_elems() const { return input_subvectors * input_lanes; }
  unsigned output_packet_elems() const { return output_subvectors * output_lanes; }
  unsigned input_tensor_elems() const { return input_packets * input_packet_elems(); }
  unsigned output_tensor_elems() const { return output_packets * output_packet_elems(); }

  // input_lanes == 0 is the unloaded sentinel
  bool loaded() const { return input_lanes != 0; }
};

// The process-wide config. Zero until load_port_config() succeeds.
const SpatialPortConfig& spatial_port_config();

#define INPUT_DATA_WIDTH (spatial_port_config().input_data_width)
#define OUTPUT_DATA_WIDTH (spatial_port_config().output_data_width)

// Load the config from `path`. Returns 0 on success.
int load_port_config(const std::string& path);

#endif  // SPATIAL_PORT_CONFIG_H

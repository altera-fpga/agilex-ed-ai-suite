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

#include "spatial_port_config.h"

#include <fstream>
#include <iostream>

#include <nlohmann/json.hpp>

namespace {

SpatialPortConfig g_spatial_port_config;

}  // namespace

const SpatialPortConfig& spatial_port_config() { return g_spatial_port_config; }

int load_port_config(const std::string& path) {
  if (path.empty()) {
    return -1;
  }

  try {
    std::ifstream in(path);
    if (!in) {
      std::cerr << "[load_port_config] Error: could not open " << path << std::endl;
      return -1;
    }

    nlohmann::json j;
    in >> j;

    SpatialPortConfig cfg;
    cfg.input_data_width = j.at("input_data_width").get<unsigned>();
    cfg.input_lanes = j.at("input_lanes").get<unsigned>();
    cfg.input_subvectors = j.at("input_subvectors").get<unsigned>();
    cfg.input_packets = j.at("input_packets").get<unsigned>();
    cfg.output_data_width = j.at("output_data_width").get<unsigned>();
    cfg.output_lanes = j.at("output_lanes").get<unsigned>();
    cfg.output_subvectors = j.at("output_subvectors").get<unsigned>();
    cfg.output_packets = j.at("output_packets").get<unsigned>();

    if (cfg.input_data_width == 0 || cfg.input_lanes == 0 || cfg.input_subvectors == 0 ||
        cfg.input_packets == 0 || cfg.output_data_width == 0 || cfg.output_lanes == 0 ||
        cfg.output_subvectors == 0 || cfg.output_packets == 0) {
      std::cerr << "[load_port_config] Error: " << path << " has a zero valued key" << std::endl;
      return -1;
    }

    g_spatial_port_config = cfg;
    return 0;
  } catch (const std::exception& e) {
    std::cerr << "[load_port_config] Error parsing " << path << ": " << e.what() << std::endl;
    return -1;
  }
}

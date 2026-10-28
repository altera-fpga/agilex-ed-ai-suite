// Copyright (C) 2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Runtime port geometry for the SPATIAL spatial IP. The geometry (data width,
// lanes, subvectors for input and output) is produced per-design by the
// example design setup and consumed here at runtime.

#include "spatial_port_config.h"

#include <cstdio>
#include <fstream>

#include <nlohmann/json.hpp>

// The single instance shared by the MMD and the plugin.
spatial_port_config_t g_spatial_port_config = {};

int load_port_config(const char* path) {
    if (!path || !*path) {
        return -1;
    }

    try {
        std::ifstream in(path);
        if (!in) {
            fprintf(stderr, "[load_port_config] Error: could not open %s\n", path);
            return -1;
        }

        nlohmann::json j;
        in >> j;

        spatial_port_config_t cfg{};
        cfg.input_data_width = j.at("input_data_width").get<unsigned>();
        cfg.input_lanes = j.at("input_lanes").get<unsigned>();
        cfg.input_subvectors = j.at("input_subvectors").get<unsigned>();
        cfg.input_packets = j.at("input_packets").get<unsigned>();
        cfg.output_data_width = j.at("output_data_width").get<unsigned>();
        cfg.output_lanes = j.at("output_lanes").get<unsigned>();
        cfg.output_subvectors = j.at("output_subvectors").get<unsigned>();
        cfg.output_packets = j.at("output_packets").get<unsigned>();

        if (cfg.input_packets == 0 || cfg.output_packets == 0) {
            fprintf(stderr,
                    "[load_port_config] Error: input_packets/output_packets must be > 0 in %s\n",
                    path);
            return -1;
        }

        g_spatial_port_config = cfg;
        return 0;
    } catch (const std::exception& e) {
        fprintf(stderr, "[load_port_config] Error parsing %s: %s\n", path, e.what());
        return -1;
    }
}

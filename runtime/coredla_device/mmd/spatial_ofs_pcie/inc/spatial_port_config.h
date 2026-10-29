// Copyright (C) 2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0

#ifndef SPATIAL_PORT_CONFIG_H
#define SPATIAL_PORT_CONFIG_H

typedef struct spatial_port_config {
    unsigned input_data_width;
    unsigned input_lanes;
    unsigned input_subvectors;
    unsigned input_packets;
    unsigned output_data_width;
    unsigned output_lanes;
    unsigned output_subvectors;
    unsigned output_packets;
} spatial_port_config_t;

extern spatial_port_config_t g_spatial_port_config;

#define INPUT_DATA_WIDTH (g_spatial_port_config.input_data_width)
#define INPUT_LANES (g_spatial_port_config.input_lanes)
#define INPUT_SUBVECTORS (g_spatial_port_config.input_subvectors)
#define INPUT_PACKETS (g_spatial_port_config.input_packets)
#define OUTPUT_DATA_WIDTH (g_spatial_port_config.output_data_width)
#define OUTPUT_LANES (g_spatial_port_config.output_lanes)
#define OUTPUT_SUBVECTORS (g_spatial_port_config.output_subvectors)
#define OUTPUT_PACKETS (g_spatial_port_config.output_packets)

#define INPUT_PACKET_ELEMS (INPUT_SUBVECTORS * INPUT_LANES)
#define OUTPUT_PACKET_ELEMS (OUTPUT_SUBVECTORS * OUTPUT_LANES)

// Load the config from the given path. Returns 0 on success.
int load_port_config(const char* path);

#endif  // SPATIAL_PORT_CONFIG_H

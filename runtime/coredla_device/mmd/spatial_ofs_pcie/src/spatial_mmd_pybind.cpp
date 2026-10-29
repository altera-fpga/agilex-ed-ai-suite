// Copyright (C) 2025 Intel Corporation
// SPDX-License-Identifier: Apache-2.0
//
// pybind11 bindings for the spatial MMD (process-wide session API).

#include <stdexcept>
#include <string>
#include <vector>

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include "fpga.h"
#include "mmd.h"

namespace py = pybind11;

namespace {

void check_rc(int rc, const char* what) {
    if (rc != 0) {
        throw std::runtime_error(std::string(what) + " failed");
    }
}

}  // namespace

PYBIND11_MODULE(spatial_mmd, m) {
    m.doc() = "Spatial MMD (process-wide FPGA session)";

    m.def("connect_to_fpga", []() { check_rc(connect_to_fpga(), "connect_to_fpga"); });
    m.def("disconnect_fpga", []() { check_rc(disconnect_fpga(), "disconnect_fpga"); });
    m.def("reset", []() { check_rc(reset(), "reset"); });
    m.def("load_port_config", [](const std::string& path) {
        check_rc(load_port_config(path.c_str()), "load_port_config");
    });
    m.def("input_data_width", []() { return INPUT_DATA_WIDTH; });
    m.def("output_data_width", []() { return OUTPUT_DATA_WIDTH; });
    m.def("load_weights", [](const std::string& dir) {
        check_rc(load_weights(dir.c_str()), "load_weights");
    });
    m.def(
        "run_inference",
        [](std::vector<uint64_t> input) {
            std::vector<uint64_t> output;
            check_rc(run_inference(input, output), "run_inference");
            return output;
        });
}

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
//
// pybind11 bindings for the spatial JTAG MMD (process-wide session API).

#include <stdexcept>
#include <string>
#include <vector>

#include <pybind11/pybind11.h>
#include <pybind11/stl.h>

#include "fpga.h"
#include "mmd.h"
#include "spatial_port_config.h"

namespace py = pybind11;

namespace {

void check_rc(int rc, const char* what) {
    if (rc != 0) {
        throw std::runtime_error(std::string(what) + " failed");
    }
}

}  // namespace

PYBIND11_MODULE(spatial_mmd, m) {
    m.doc() = "Spatial JTAG MMD (process-wide FPGA session)";

    m.def("connect_to_fpga", []() { check_rc(connect_to_fpga(), "connect_to_fpga"); });
    m.def("disconnect_fpga", []() { check_rc(disconnect_fpga(), "disconnect_fpga"); });
    m.def("reset", []() { check_rc(reset(), "reset"); });
    m.def("load_port_config", [](const std::string& path) {
        check_rc(load_port_config(path), "load_port_config");
    });
    m.def("input_data_width", []() { return spatial_port_config().input_data_width; });
    m.def("output_data_width", []() { return spatial_port_config().output_data_width; });
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
    m.def("read_timer_us", &read_timer_us);
}

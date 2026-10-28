# Copyright 2023 Altera Corporation
#
# This software and the related documents are Altera copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Altera's prior written
# permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the
# License.

project(streaming_inference_app)

set(all_files
    streaming_inference_app.cpp
    streaming_inference_app.h
    command_line.cpp
    command_line.h)

# Targets
add_executable(${PROJECT_NAME} ${all_files})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

# For FPGA plugin configs and properties.
target_include_directories(${PROJECT_NAME} PRIVATE
  "$ENV{COREDLA_ROOT}/dla_plugin/inc/"
  # Error handling utilities (header-only)
  "$ENV{COREDLA_ROOT}/util/inc/"
)

target_link_libraries(${PROJECT_NAME} PRIVATE
  openvino::runtime
)

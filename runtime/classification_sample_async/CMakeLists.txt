# Copyright (C) 2018-2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0


file (GLOB MAIN_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
)

file (GLOB MAIN_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/classification_sample_async.h
)

source_group("src" FILES ${MAIN_SRC})
source_group("include" FILES ${MAIN_HEADERS})

# Find OpenCV components if exist
find_package(OpenCV COMPONENTS core highgui imgcodecs imgproc videoio REQUIRED)

# Create library file from sources.
add_executable(classification_sample_async ${MAIN_SRC} ${MAIN_HEADERS})
target_compile_features(classification_sample_async PRIVATE cxx_std_17)

target_include_directories(classification_sample_async PRIVATE
    # Demo utils
    ${CMAKE_CURRENT_SOURCE_DIR}/../common/demo_utils/include/utils
    # FPGA plugin configs
    $ENV{COREDLA_ROOT}/dla_plugin/inc
    # Error handling utilities (header-only)
    $ENV{COREDLA_ROOT}/util/inc
)

target_link_libraries(classification_sample_async PRIVATE
    openvino::runtime
    ${OpenCV_LIBRARIES}
    format_reader
    ie_samples_utils
)
# For libcoreDlaRuntimePlugin.so - typically specified by $COREDLA_ROOT/runtime/plugins.xml
set_target_properties(classification_sample_async PROPERTIES BUILD_RPATH "\$ORIGIN/..")

# Copyright (C) 2018-2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0

file (GLOB MAIN_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
)

file (GLOB MAIN_HEADERS
    # Add headers if any
)

source_group("src" FILES ${MAIN_SRC})
source_group("include" FILES ${MAIN_HEADERS})

# Find OpenCV components if exist
find_package(OpenCV COMPONENTS core highgui imgcodecs imgproc videoio REQUIRED)

set(COREDLA_RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

# Create library file from sources.
add_executable(object_detection_demo ${MAIN_SRC} ${MAIN_HEADERS})
target_compile_features(object_detection_demo PRIVATE cxx_std_11)

target_include_directories(object_detection_demo PRIVATE
    "${COREDLA_RUNTIME_DIR}/common/demo_utils/include/utils"
    "${COREDLA_RUNTIME_DIR}/common/monitors/include"
)

target_link_libraries(object_detection_demo PRIVATE
    openvino::runtime
    openvino_dev_api
    ie_samples_utils
    ${OpenCV_LIBRARIES}
    models
    monitors
    pipelines
    ov_demo_utils
)

# For libcoreDlaRuntimePlugin.so - typically specified by $COREDLA_ROOT/runtime/plugins.xml
set_target_properties(object_detection_demo PROPERTIES BUILD_RPATH "\$ORIGIN/..")

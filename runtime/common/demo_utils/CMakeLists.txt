# Copyright (C) 2018-2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

file(GLOB_RECURSE HEADERS "${CMAKE_CURRENT_SOURCE_DIR}/include/*")
file(GLOB_RECURSE SOURCES "${CMAKE_CURRENT_SOURCE_DIR}/src/*")

source_group("src" FILES ${SOURCES})
source_group("include" FILES ${HEADERS})

add_library(ov_demo_utils STATIC ${HEADERS} ${SOURCES})
target_include_directories(ov_demo_utils PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include"
                                                 "$ENV{COREDLA_ROOT}/dla_plugin/inc/")
target_link_libraries(ov_demo_utils PRIVATE openvino::runtime opencv_core opencv_imgcodecs opencv_videoio ie_samples_utils)

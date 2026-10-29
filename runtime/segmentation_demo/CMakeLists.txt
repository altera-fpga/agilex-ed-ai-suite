# Copyright (C) 2018-2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0



file (GLOB MAIN_SRC
  ${CMAKE_CURRENT_SOURCE_DIR}/main.cpp
)

file (GLOB MAIN_HEADERS
  # Add header files here
)

source_group("src" FILES ${MAIN_SRC})
source_group("include" FILES ${MAIN_HEADERS})

# Find OpenCV components if exist
find_package(OpenCV COMPONENTS core highgui imgcodecs imgproc videoio REQUIRED)

# Create library file from sources.
add_executable(segmentation_demo ${MAIN_SRC} ${MAIN_HEADERS})
target_compile_features(segmentation_demo PRIVATE cxx_std_11)

target_include_directories(segmentation_demo PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/../common/monitors/include
  $ENV{COREDLA_ROOT}/dla_plugin/inc/
)

if (NOT TARGET ie_samples_utils)
  message (FATAL_ERROR "ie_samples_utils missing")
endif()

target_link_libraries(segmentation_demo PRIVATE
  openvino::runtime
  openvino_dev_api
  ie_samples_utils
  ${OpenCV_LIBRARIES}
  monitors
  ov_demo_utils
  models
  pipelines
)

if (NOT WIN32)
  target_link_libraries(segmentation_demo PRIVATE pthread)
endif()

# For libcoreDlaRuntimePlugin.so - typically specified by $COREDLA_ROOT/runtime/plugins.xml
set_target_properties(segmentation_demo PROPERTIES BUILD_RPATH "\$ORIGIN/..")

# Copyright (C) 2018-2024 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#

file(GLOB_RECURSE SOURCES "*.cpp" "*.hpp" "*.h")
source_group(TREE ${CMAKE_CURRENT_SOURCE_DIR} FILES ${SOURCES})

add_library(ie_samples_utils STATIC EXCLUDE_FROM_ALL ${SOURCES})
target_compile_features(ie_samples_utils PRIVATE cxx_std_17)

set_target_properties(ie_samples_utils PROPERTIES FOLDER "src")

target_include_directories(ie_samples_utils
    PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")

add_subdirectory($ENV{COREDLA_ROOT}/thirdparty/gflags-2.2.2 ${CMAKE_CURRENT_BINARY_DIR}/gflags)

if (WIN32)
else ()
  # Some warnings in the 3rd party
  foreach(target gflags_nothreads_static gflags_nothreads_shared)
    if(TARGET ${target})
    target_compile_options(${target} PRIVATE -Wno-cast-function-type -Wno-implicit-fallthrough)
    endif()
  endforeach()
endif()

target_link_libraries(ie_samples_utils PUBLIC openvino::runtime gflags)

if(COMMAND add_clang_format_target)
    add_clang_format_target(ie_samples_utils_clang FOR_TARGETS ie_samples_utils)
endif()

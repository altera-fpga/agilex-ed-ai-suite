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

project(uio)

set(header_files "")
set(source_files "")

# Header files
set(header_files ${header_files} "include/IUioDevice.h")
set(header_files ${header_files} "source/UioDevice.h")

# Source files
set(source_files ${source_files} "source/UioDevice.cpp")

set(all_files ${header_files} ${source_files})

add_library(${PROJECT_NAME} STATIC ${all_files})
target_compile_features(${PROJECT_NAME} PRIVATE cxx_std_17)

# Include directories
target_include_directories(${PROJECT_NAME} PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}/include")

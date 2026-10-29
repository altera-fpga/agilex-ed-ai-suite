# Copyright 2023 Altera Corporation

# This software and the related documents are Altera copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Altera's prior written
# permission.

# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the
# License.

project(image_streaming_app)

set(all_files ${header_files}
    command_line.cpp
    command_line.h
    image_streaming_app.cpp
    image_streaming_app.h
    raw_image.cpp
    raw_image.h
    bmp_file.cpp
    bmp_file.h
    float16.h)

# Targets
add_executable(image_streaming_app ${all_files})
target_compile_features(image_streaming_app PRIVATE cxx_std_17)

add_subdirectory(uio)
add_subdirectory(layout_transform)

target_link_libraries(image_streaming_app PRIVATE layout_transform dla_util)

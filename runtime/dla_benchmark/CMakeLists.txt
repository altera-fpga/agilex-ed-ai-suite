# Copyright (C) 2018-2020 Altera Corporation
# SPDX-License-Identifier: Apache-2.0
#

if (NOT WIN32)
  if (NOT("${CMAKE_CXX_COMPILER_ID}" STREQUAL "Intel"))
    set (CMAKE_CXX_FLAGS "-std=c++17 ${CMAKE_CXX_FLAGS}")
  endif()
endif()

file (GLOB MAIN_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/../common/utils/src/*.cpp
)

file (GLOB MAIN_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/*.hpp
)

# Create named folders for the sources within the .vcproj
# Empty name lists them directly under the .vcproj
source_group("src" FILES ${MAIN_SRC})
source_group("include" FILES ${MAIN_HEADERS})

if (DE10_AGILEX)
  add_definitions(-DDE10_AGILEX)
endif()

# Find OpenCV components if exist
find_package(OpenCV COMPONENTS core highgui imgcodecs imgproc videoio REQUIRED)

# Create library file from sources.
add_executable(dla_benchmark ${MAIN_SRC} ${MAIN_HEADERS})
target_compile_features(dla_benchmark PRIVATE
  $<$<CXX_COMPILER_ID:MSVC>:cxx_std_20>
  $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:cxx_std_17>
)

# For FPGA plugin configs and properties.
target_include_directories(dla_benchmark PRIVATE
  "$ENV{COREDLA_ROOT}/dla_plugin/inc/"
)

# SPATIAL: link MMD directly (spatial mode does not use the OpenVINO plugin)
if (SPATIAL_PLATFORM)
  target_include_directories(dla_benchmark PRIVATE
    "${CMAKE_CURRENT_SOURCE_DIR}/../coredla_device/mmd/${MMD_DIR_NAME}/inc/"
  )
  target_compile_definitions(dla_benchmark PRIVATE SPATIAL_ENABLED)
  target_link_libraries(dla_benchmark PRIVATE spatial_mmd)
endif()

target_link_libraries(dla_benchmark PRIVATE
  openvino::runtime
  openvino_dev_api
  ${OpenCV_LIBRARIES}
  format_reader
  ie_samples_utils
  dla_util
  json
)

if (OPT_ENABLE_PERFORMANCE_PROFILER)
  target_compile_definitions(dla_benchmark PUBLIC OPT_ENABLE_PERFORMANCE_PROFILER)
  target_link_libraries(dla_benchmark PRIVATE dla_performance_profiler)
endif()

if (CMAKE_CXX_COMPILER_ID STREQUAL "GNU" AND CMAKE_CXX_COMPILER_VERSION VERSION_LESS 9.0)
  # need to manually link to stdc++fs for gcc < 9
  target_link_libraries(dla_benchmark PRIVATE stdc++fs)
endif()

set_target_properties(dla_benchmark PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")


if (NOT DISABLE_JIT AND CoreDLA_FOUND)
  file(REAL_PATH ${CoreDLA_DIR}/../lib CoreDLA_LIB EXPAND_TILDE)
  # Search the locally built format_reader ahead of the packaged CoreDLA lib
  # directory. Both contain a libformat_reader.so, and the packaged copy may be
  # built against a different OpenCV than the local build. Listing the local
  # build output first keeps the process on a single, consistent OpenCV.
  set_target_properties(dla_benchmark PROPERTIES BUILD_RPATH "\$ORIGIN/..:$<TARGET_FILE_DIR:format_reader>:${CoreDLA_LIB}")
else()
  # For libcoreDlaRuntimePlugin.so - typically specified by $COREDLA_ROOT/runtime/plugins.xml
  set_target_properties(dla_benchmark PROPERTIES BUILD_RPATH "\$ORIGIN/..")
endif()

if (NOT EMULATION)
  if (DEFINED AGX7_ISERIES_SPATIAL AND AGX7_ISERIES_SPATIAL)
    target_compile_definitions(dla_benchmark PRIVATE DEFAULT_PLUGINS_PATH="$<TARGET_FILE_DIR:spatialPlugin>/plugins.xml")
  elseif (DEFINED AGX5_JTAG_SPATIAL AND AGX5_JTAG_SPATIAL)
    target_compile_definitions(dla_benchmark PRIVATE DEFAULT_PLUGINS_PATH="${CMAKE_CURRENT_BINARY_DIR}/plugins.xml")
  else()
    target_compile_definitions(dla_benchmark PRIVATE DEFAULT_PLUGINS_PATH="$<TARGET_FILE_DIR:coreDlaRuntimePlugin>/plugins.xml")
  endif()
else()
  file(TO_CMAKE_PATH "$ENV{COREDLA_ROOT}/lib/plugins.xml" DEFAULT_PLUGINS_PATH)
  target_compile_definitions(dla_benchmark PRIVATE DEFAULT_PLUGINS_PATH="${DEFAULT_PLUGINS_PATH}")
endif()

# Enable high graph logging by defining its macro
# Change to add_compile_definitions() once we move to cmake >= 3.12
if (DLA_ENABLE_LOGGING)
  target_compile_definitions(dla_benchmark PRIVATE -DENABLE_HG_LOGGING)
endif()

install(TARGETS dla_benchmark RUNTIME DESTINATION "bin" COMPONENT DEMO)

# POST_BUILD must live in this directory (where dla_benchmark is created).
# Copies the interceptor to $ORIGIN/../lib so the build-tree binary works
# without -install_dir. cmake --install still uses the parent install() rule.
if (EMULATION AND NOT WIN32)
  add_custom_command(TARGET dla_benchmark POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E make_directory
            "$<TARGET_FILE_DIR:dla_benchmark>/../lib"
    COMMAND ${CMAKE_COMMAND} -E copy_if_different
            "$<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>"
            "$<TARGET_FILE_DIR:dla_benchmark>/../lib/$<TARGET_FILE_NAME:AuditLibstdcxx::audit_libstdcxx>"
    COMMENT "Copy audit interceptor into build-tree lib/ for DT_AUDIT"
  )
endif()

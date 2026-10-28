# Copyright (C) 2018-2020 Altera Corporation
# SPDX-License-Identifier: Apache-2.0
#

set(COREDLA_RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Exlude dla_aot_splitter_example from all build targets by default
# unless specifically requested by the user via cmake --build <build_dir> --target my_excludedla_aot_splitter_example
add_executable(dla_aot_splitter_example EXCLUDE_FROM_ALL src/main.cpp)

target_compile_features(dla_aot_splitter_example PUBLIC cxx_std_11)

target_compile_definitions(dla_aot_splitter_example PRIVATE DLA_MMD)

file(GLOB SOURCES
  # coredla_device
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc/device_memory_allocator.h
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc/mmd_wrapper.h
  ${COREDLA_RUNTIME_DIR}/coredla_device/src/device_memory_allocator.cpp
  #
  src/main.cpp
)
if (SYSTEM_CONSOLE_PLATFORM)
  list(APPEND SOURCES ${CMAKE_SOURCE_DIR}/coredla_device/mmd/system_console/mmd_wrapper.cpp)
else ()
  list(APPEND SOURCES ${COREDLA_RUNTIME_DIR}/coredla_device/src/mmd_wrapper.cpp)
endif ()

target_sources (dla_aot_splitter_example PRIVATE ${SOURCES})

# Create a CMake list of link libraries for dla_aot_splitter_example
target_link_libraries(dla_aot_splitter_example PRIVATE dla_dma_constants)

# For logging headers used in the hostless ED runtime, also add Boost
if (SYSTEM_CONSOLE_PLATFORM)
  target_link_libraries(dla_aot_splitter_example PRIVATE Boost::filesystem Boost::process)
  target_include_directories(dla_aot_splitter_example PRIVATE ${CMAKE_SOURCE_DIR}/common/utils/include)
endif ()

target_link_libraries(dla_aot_splitter_example PRIVATE
  dla_util
)

target_link_libraries(dla_aot_splitter_example
  PRIVATE
    dla_compiled_result
)

if (DE10_AGILEX)
  target_link_libraries(dla_aot_splitter_example PRIVATE de10_agilex)
elseif(PAC_A10)
  target_link_libraries(dla_aot_splitter_example PRIVATE dcp_a10_pac)
elseif(AGX7_IDK)
  target_link_libraries(dla_aot_splitter_example PRIVATE agx7_i_dk)
  find_library(libjson-c_LIBRARIES
    NAMES json-c
    PATHS ${LIBOPAE-C_ROOT}/lib
    ${LIBOPAE-C_ROOT}/lib64
    /usr/local/lib
    /usr/lib
    /lib
    /usr/lib/x86_64-linux-gnu
    ${CMAKE_EXTRA_LIBS})
  target_link_libraries(dla_aot_splitter_example PRIVATE ${libjson-c_LIBRARIES})
elseif(AGX7_N6001)
  target_link_libraries(dla_aot_splitter_example PRIVATE agx7_n6001)
  find_library(libjson-c_LIBRARIES
    NAMES json-c
    PATHS ${LIBOPAE-C_ROOT}/lib
    ${LIBOPAE-C_ROOT}/lib64
    /usr/local/lib
    /usr/lib
    /lib
    /usr/lib/x86_64-linux-gnu
    ${CMAKE_EXTRA_LIBS})
  target_link_libraries(dla_aot_splitter_example PRIVATE ${libjson-c_LIBRARIES})
elseif(AGX5_MDK)
  target_link_libraries(dla_aot_splitter_example PRIVATE agx5_mdk)
  find_library(libjson-c_LIBRARIES
    NAMES json-c
    PATHS ${LIBOPAE-C_ROOT}/lib
    ${LIBOPAE-C_ROOT}/lib64
    /usr/local/lib
    /usr/lib
    /lib
    /usr/lib/x86_64-linux-gnu
    ${CMAKE_EXTRA_LIBS})
  target_link_libraries(dla_aot_splitter_example PRIVATE ${libjson-c_LIBRARIES})
elseif(SYSTEM_CONSOLE_PLATFORM)
  # Agilex 5 JTAG ED: do nothing
elseif (SYSTEM_CONSOLE_STREAMING_PLATFORM)
  # DO NOTHING
elseif(REFERENCE)
  # Reference: do nothing
else()
  message(FATAL_ERROR "Building DLA AOT Aplitter Example with unsupported platform")
endif()

target_include_directories(dla_aot_splitter_example PRIVATE
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc
  if(PAC_A10)
    ${COREDLA_RUNTIME_DIR}/coredla_device/mmd/dcp_a10_pac/host
  endif()
)

file(MAKE_DIRECTORY ${CMAKE_CURRENT_BINARY_DIR}/include)

target_sources (dla_aot_splitter_example PRIVATE
  ${CMAKE_CURRENT_BINARY_DIR}/include/arch_build.mem
  ${CMAKE_CURRENT_BINARY_DIR}/include/config.mem
  ${CMAKE_CURRENT_BINARY_DIR}/include/filter.mem
  ${CMAKE_CURRENT_BINARY_DIR}/include/input.mem
  ${CMAKE_CURRENT_BINARY_DIR}/include/inter_size.mem
  ${CMAKE_CURRENT_BINARY_DIR}/include/output_size.mem
  ${CMAKE_CURRENT_BINARY_DIR}/include/input_size.mem
)
target_include_directories(dla_aot_splitter_example PRIVATE
  ${CMAKE_CURRENT_BINARY_DIR}/include
)

if (DEFINED ENV{AOT_SPLITTER_EXAMPLE_MODEL})
  set (AOT_SPLITTER_EXAMPLE_MODEL $ENV{AOT_SPLITTER_EXAMPLE_MODEL})
else()
  if (EXISTS $ENV{COREDLA_WORK}/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml)
    set (AOT_SPLITTER_EXAMPLE_MODEL $ENV{COREDLA_WORK}/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml)
  else()
    # The path below is for Intel internal use only
    if (EXISTS /p/psg/swip/dla/caffe/caffe_reference/ngraph_ir/coredla/ModelZoo/2021_4_1/resnet_50_tf/FP32/resnet-50-tf.xml)
      set (AOT_SPLITTER_EXAMPLE_MODEL /p/psg/swip/dla/caffe/caffe_reference/ngraph_ir/coredla/ModelZoo/2021_4_1/resnet_50_tf/FP32/resnet-50-tf.xml)
    endif()
  endif()
endif()

if (DEFINED ENV{AOT_SPLITTER_EXAMPLE_INPUT})
  set (AOT_SPLITTER_EXAMPLE_INPUT $ENV{AOT_SPLITTER_EXAMPLE_INPUT})
else()
  if (EXISTS $ENV{COREDLA_ROOT}/demo/sample_images/val_00000000.bmp)
    set (AOT_SPLITTER_EXAMPLE_INPUT $ENV{COREDLA_ROOT}/demo/sample_images/val_00000000.bmp)
  else()
    # The path below is for Intel internal use only
    if (EXISTS /p/psg/swip/dla/images/imagenet/ILSVRC2012_224x224/BMP/BMP/ILSVRC2012_val_00000000.bmp)
      set (AOT_SPLITTER_EXAMPLE_INPUT /p/psg/swip/dla/images/imagenet/ILSVRC2012_224x224/BMP/BMP/ILSVRC2012_val_00000000.bmp)
    endif()
  endif()
endif()

if (EXISTS ${CoreDLA_DIR}/../bin)
  set(COREDLA_BIN ${CoreDLA_DIR}/../bin)
  set(COREDLA_LIB ${CoreDLA_DIR}/../lib)
  set(COREDLA_EXARCH ${CoreDLA_DIR}/../example_architectures)
  if(DE10_AGILEX OR AGX7_IDK OR AGX7_N6001)
    set (AOT_SPLITTER_EXAMPLE_ARCH AGX7_Performance.arch)
  elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX5_SYSTEM_CONSOLE")
    set (AOT_SPLITTER_EXAMPLE_ARCH AGX5_Small_Softmax.arch)
  elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX3_SYSTEM_CONSOLE")
    set (AOT_SPLITTER_EXAMPLE_ARCH AGX3_Small_Softmax.arch)
  else()
    set (AOT_SPLITTER_EXAMPLE_ARCH A10_Performance.arch)
  endif()
else()
  set(COREDLA_BIN $ENV{COREDLA_ROOT}/build/coredla/dla/bin)
  set(COREDLA_LIB $ENV{COREDLA_ROOT}/build/coredla/dla/lib)
  set(COREDLA_EXARCH $ENV{COREDLA_ROOT}/example_architectures)

  # The paths below are for Intel internal use only
  if(DE10_AGILEX)
    set (AOT_SPLITTER_EXAMPLE_ARCH arch/descriptions/AGX7/64x32_i5x1_fp13agx_sb31744_xbark32_clamp_preluk32_poolk4_softmax_1inst.arch)
  elseif(AGX7_IDK OR AGX7_N6001)
    set (AOT_SPLITTER_EXAMPLE_ARCH arch/descriptions/AGX7/32x64_i5x1_fp13agx_sb32768_poolk4_actk32_prelu_rclamp_sig_softmaxk1.arch)
  elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX5_SYSTEM_CONSOLE")
    set (AOT_SPLITTER_EXAMPLE_ARCH arch/descriptions/AGX5/16x16_i12x1_fp12agx_sb8192_poolk4_actk16_clamp_softmaxk1.arch)
  elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX3_SYSTEM_CONSOLE")
    set (AOT_SPLITTER_EXAMPLE_ARCH arch/descriptions/AGX3/16x16_i12x1_fp12agx_sb8192_poolk4_actk16_clamp_softmaxk1.arch)
  else()
    set (AOT_SPLITTER_EXAMPLE_ARCH arch/descriptions/A10/64x32_i4x1_fp11_sb31744_xbark32_clamp_preluk32_poolk4_softmax.arch)
  endif()
endif()

if (NOT DEFINED AOT_SPLITTER_INPUT_ARGUMENTS)
  set (AOT_SPLITTER_INPUT_ARGUMENTS )
  if (DEFINED AOT_SPLITTER_EXAMPLE_INPUT)
    set (AOT_SPLITTER_INPUT_ARGUMENTS -i ${AOT_SPLITTER_EXAMPLE_INPUT} -bgr)
  endif()
endif()

# Need to copy the system console script for Agilex 5E JTAG ED
# Also link against Boost
if (SYSTEM_CONSOLE_PLATFORM)
  add_custom_command(
    TARGET dla_aot_splitter_example POST_BUILD
    COMMAND ${CMAKE_COMMAND} -E copy
    ${CMAKE_SOURCE_DIR}/coredla_device/mmd/system_console/system_console_script.tcl
    ${CMAKE_CURRENT_BINARY_DIR}/system_console_script.tcl
  )
  target_compile_definitions(dla_aot_splitter_example PRIVATE DLA_SYSCON_SOURCE_ROOT=${CMAKE_CURRENT_BINARY_DIR})
endif()

add_custom_command(
  OUTPUT
    ${CMAKE_CURRENT_BINARY_DIR}/include/arch_build.mem
    ${CMAKE_CURRENT_BINARY_DIR}/include/config.mem
    ${CMAKE_CURRENT_BINARY_DIR}/include/filter.mem
    ${CMAKE_CURRENT_BINARY_DIR}/include/input.mem
    ${CMAKE_CURRENT_BINARY_DIR}/include/inter_size.mem
    ${CMAKE_CURRENT_BINARY_DIR}/include/output_size.mem
    ${CMAKE_CURRENT_BINARY_DIR}/include/input_size.mem
  COMMAND
    LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}:${COREDLA_LIB} ${COREDLA_BIN}/dlac --network-file ${AOT_SPLITTER_EXAMPLE_MODEL} --march ${COREDLA_EXARCH}/${AOT_SPLITTER_EXAMPLE_ARCH} --fplugin=HETERO:FPGA --foutput-format open_vino_hetero --overwrite-output-files --o ${CMAKE_CURRENT_BINARY_DIR}/resnet.aot
  COMMAND
    LD_LIBRARY_PATH=$ENV{LD_LIBRARY_PATH}:${COREDLA_LIB} $<TARGET_FILE:dla_aot_splitter> ${AOT_SPLITTER_INPUT_ARGUMENTS} -cm ${CMAKE_CURRENT_BINARY_DIR}/resnet.aot
  DEPENDS
    ${COREDLA_BIN}/dlac
    dla_benchmark
    dla_aot_splitter
    dla_aot_splitter_plugin
    ${AOT_SPLITTER_EXAMPLE_MODEL}
    ${COREDLA_EXARCH}/${AOT_SPLITTER_EXAMPLE_ARCH}
    ${AOT_SPLITTER_EXAMPLE_INPUT}
  WORKING_DIRECTORY
    ${CMAKE_CURRENT_BINARY_DIR}/include
)

cmake_minimum_required(VERSION 3.10)

# Use <package>_ROOT variables to help find_package locate packages
if (POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()

set(COREDLA_RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/..")

find_package(OpenCV COMPONENTS core highgui imgcodecs imgproc videoio REQUIRED)

add_subdirectory(dla_aot_splitter_plugin)
add_subdirectory(dla_aot_splitter_example)

if (DE10_AGILEX)
  add_library(de10_agilex ALIAS de10_agilex_mmd)
elseif (SYSTEM_CONSOLE_PLATFORM)
  # DO NOTHING
elseif (SYSTEM_CONSOLE_STREAMING_PLATFORM)
  # DO NOTHING
elseif (PAC_A10)
  add_library(dcp_a10_pac ALIAS intel_opae_mmd)
elseif(AGX7_IDK)
  add_library(agx7_i_dk ALIAS intel_opae_mmd)
elseif(AGX7_N6001)
  add_library(agx7_n6001 ALIAS intel_opae_mmd)
elseif(AGX5_MDK)
  add_library(agx5_mdk ALIAS intel_opae_mmd)
endif()

add_executable(dla_aot_splitter ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp)

target_compile_features(dla_aot_splitter PUBLIC cxx_std_11)

target_compile_definitions(dla_aot_splitter PRIVATE DEFAULT_PLUGINS_PATH="$<TARGET_FILE_DIR:coreDlaRuntimePlugin>/plugins_aot_splitter.xml")

target_sources(dla_aot_splitter PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/src/main.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/inc/dla_aot_splitter.hpp
  ${COREDLA_RUNTIME_DIR}/dla_benchmark/inputs_filling.cpp #TODO REMOVE and replace with link library
  ${COREDLA_RUNTIME_DIR}/dla_benchmark/utils.cpp #TODO REMOVE and replace with link library
  ${COREDLA_RUNTIME_DIR}/common/utils/src/slog.cpp
  ${COREDLA_RUNTIME_DIR}/common/utils/src/args_helper.cpp
  ${COREDLA_RUNTIME_DIR}/common/utils/src/latency_metrics.cpp
)

target_include_directories(dla_aot_splitter PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/inc
  $ENV{COREDLA_ROOT}/dla_plugin/inc
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dlia
  ${COREDLA_RUNTIME_DIR}/dla_benchmark #TODO REMOVE and replace with link library
)

target_link_libraries(dla_aot_splitter PRIVATE
  openvino::runtime
  openvino_dev_api
  format_reader
  ie_samples_utils
  ${OpenCV_LIBRARIES} # Needed for the directly compiled inputs_filling
  gflags
  dla_util
)

if(OPT_ENABLE_PERFORMANCE_PROFILER)
  target_compile_definitions(dla_aot_splitter PUBLIC OPT_ENABLE_PERFORMANCE_PROFILER)
  target_link_libraries(dla_aot_splitter PRIVATE dla_performance_profiler)
endif()

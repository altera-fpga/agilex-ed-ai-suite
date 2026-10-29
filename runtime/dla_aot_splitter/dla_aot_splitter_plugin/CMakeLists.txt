cmake_minimum_required(VERSION 3.10)

set(COREDLA_RUNTIME_DIR "${CMAKE_CURRENT_SOURCE_DIR}/../..")

# Plugins should use MODULE because they are dynamically loaded at runtime and do not need to be linked at build time.
add_library(dla_aot_splitter_plugin MODULE)

target_compile_features(dla_aot_splitter_plugin PUBLIC cxx_std_11)

target_compile_definitions(dla_aot_splitter_plugin PUBLIC DISABLE_JIT)

if (WIN32)
  # Fix warning C4273: inconsistent dll linkage
  target_compile_definitions(dla_aot_splitter_plugin PRIVATE XBYAK_NO_OP_NAMES
    IMPLEMENT_OPENVINO_RUNTIME_PLUGIN
    $<TARGET_PROPERTY:openvino::runtime,INTERFACE_COMPILE_DEFINITIONS>)
endif()

target_include_directories(dla_aot_splitter_plugin PRIVATE
  $ENV{COREDLA_ROOT}/dla_plugin
  $ENV{COREDLA_ROOT}/dla_plugin/inc
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dlia
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc # For abstract classes (BatchJob, Device etc.)
  #
  ${CMAKE_CURRENT_SOURCE_DIR}/inc
)
target_link_libraries(dla_aot_splitter_plugin PRIVATE dla_dma_constants)

target_sources(dla_aot_splitter_plugin PRIVATE
##
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dla_async_infer_request.h
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dla_config.hpp
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dla_compiled_model.h
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dla_runtime_log.h
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dlia_infer_request.h
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dlia_plugin.h
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dlia_utils.h
  $ENV{COREDLA_ROOT}/dla_plugin/inc/dla_plugin_config.hpp
##
  $ENV{COREDLA_ROOT}/dla_plugin/src/dla_async_infer_request.cpp
  $ENV{COREDLA_ROOT}/dla_plugin/src/dla_config.cpp
  $ENV{COREDLA_ROOT}/dla_plugin/src/dla_compiled_model.cpp
  $ENV{COREDLA_ROOT}/dla_plugin/src/dlia_infer_request.cpp
  $ENV{COREDLA_ROOT}/dla_plugin/src/dlia_plugin.cpp
  $ENV{COREDLA_ROOT}/dla_plugin/src/dla_plugin_jit_functions.cpp
  $ENV{COREDLA_ROOT}/dla_plugin/src/dlia_utils.cpp
##
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc/graph_job.h
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc/batch_job.h
  ${COREDLA_RUNTIME_DIR}/coredla_device/inc/device.h
##
  ${CMAKE_CURRENT_SOURCE_DIR}/src/raw_graph_job.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/raw_device.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/raw_batch_job.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/src/dla_aot_utils.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/inc/raw_graph_job.h
  ${CMAKE_CURRENT_SOURCE_DIR}/inc/raw_device.h
  ${CMAKE_CURRENT_SOURCE_DIR}/inc/raw_batch_job.h
  ${CMAKE_CURRENT_SOURCE_DIR}/inc/dla_aot_utils.h
  ${CMAKE_CURRENT_SOURCE_DIR}/inc/dla_aot_structs.h
)

if (WIN32)
  target_link_libraries(dla_aot_splitter_plugin
    PRIVATE
##
    dla_op_transformation
    dliaPluginIOTransformations
    openvino::runtime
    openvino_dev_api
    ${TBB_IMPORTED_TARGETS}
)
else()
  target_link_libraries(dla_aot_splitter_plugin
    PRIVATE
##
    dla_op_transformation
    dliaPluginIOTransformations
    openvino::runtime
    openvino_dev_api
    ${TBB_IMPORTED_TARGETS}
)
endif()

# Needed for dla_performance_estimator.h
target_include_directories(dla_aot_splitter_plugin PUBLIC ${COREDLA_COMPILER_INCLUDE})

if (DISABLE_JIT)
  target_link_libraries(dla_aot_splitter_plugin PRIVATE dla_compiled_result dla_util)
else()
  target_link_libraries(dla_aot_splitter_plugin
    PRIVATE
      dla_compiled_result
      archparam
      dla_util
  )
endif()

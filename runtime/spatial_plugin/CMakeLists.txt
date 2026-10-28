cmake_minimum_required(VERSION 3.10)

# spatialPlugin sources - only OpenVINO plugin code, OPAE code is in spatial_mmd
file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/src/*.cpp)
file(GLOB HEADERS
      ${CMAKE_CURRENT_SOURCE_DIR}/inc/dlia/*.hpp
      ${CMAKE_CURRENT_SOURCE_DIR}/inc/*.hpp)

add_library(spatialPlugin MODULE ${SOURCES} ${HEADERS})
target_compile_features(spatialPlugin PRIVATE cxx_std_17)

if (WIN32)
  # Fix warning C4273: inconsistent dll linkage
  target_compile_definitions(spatialPlugin PRIVATE XBYAK_NO_OP_NAMES
    IMPLEMENT_OPENVINO_RUNTIME_PLUGIN
    $<TARGET_PROPERTY:openvino::runtime,INTERFACE_COMPILE_DEFINITIONS>)
endif()

if (NOT WIN32)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -pthread -lrt")
endif()

# Normally set by parent runtime/CMakeLists.txt; fallbacks for standalone cmake.
if(DEFINED SPATIAL_MMD_INC_DIR)
  set(_SPATIAL_MMD_INC "${SPATIAL_MMD_INC_DIR}")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../coredla_device/mmd/spatial_ofs_pcie/inc/fpga.h")
  # In-tree: external/runtime/spatial_plugin next to coredla_device/mmd/spatial_ofs_pcie
  set(_SPATIAL_MMD_INC "${CMAKE_CURRENT_SOURCE_DIR}/../coredla_device/mmd/spatial_ofs_pcie/inc")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../external/runtime/coredla_device/mmd/spatial_ofs_pcie/inc/fpga.h")
  # Legacy: spatial_plugin at COREDLA_TREE root
  set(_SPATIAL_MMD_INC "${CMAKE_CURRENT_SOURCE_DIR}/../external/runtime/coredla_device/mmd/spatial_ofs_pcie/inc")
elseif(EXISTS "${CMAKE_CURRENT_SOURCE_DIR}/../runtime/coredla_device/mmd/spatial_ofs_pcie/inc/fpga.h")
  set(_SPATIAL_MMD_INC "${CMAKE_CURRENT_SOURCE_DIR}/../runtime/coredla_device/mmd/spatial_ofs_pcie/inc")
else()
  message(FATAL_ERROR "spatial_plugin: cannot locate fpga.h — set SPATIAL_MMD_INC_DIR")
endif()

target_include_directories(spatialPlugin PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/inc
  # spatial_mmd headers (OPAE/FPGA code) - matches pattern used by coreDlaRuntimePlugin with intel_opae_mmd
  ${_SPATIAL_MMD_INC}
)

target_link_libraries(spatialPlugin PUBLIC
  ${TBB_IMPORTED_TARGETS}
  openvino::runtime
  openvino_dev_api
)

# Link to spatial_mmd for OPAE/FPGA functionality
target_link_libraries(spatialPlugin PRIVATE spatial_mmd)

set_target_properties(spatialPlugin PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")

install(TARGETS spatialPlugin
  RUNTIME DESTINATION "bin" COMPONENT COREDLA
  LIBRARY DESTINATION "lib" COMPONENT COREDLA
  ARCHIVE DESTINATION "lib" COMPONENT COREDLA)

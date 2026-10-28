# Copyright (C) 2026 Altera Corporation
# SPDX-License-Identifier: Apache-2.0
#
# Spatial JTAG MMD library.
# Provides FPGA connectivity for the Agilex 5 modular spatial JTAG example design
# through system-console. Built as a static archive (libspatial_mmd.a) and a
# pybind11 module (spatial_mmd*.so).
#

cmake_minimum_required(VERSION 3.10)
project(spatial_mmd)

set(SPATIAL_MMD_SRC
    ${CMAKE_CURRENT_SOURCE_DIR}/src/fpga.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/mmd.cpp
    ${CMAKE_CURRENT_SOURCE_DIR}/src/spatial_port_config.cpp
)

set(SPATIAL_MMD_HEADERS
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/mmd.h
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/fpga.h
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/spatial_port_config.h
    ${CMAKE_CURRENT_SOURCE_DIR}/inc/address_map.h
)

# Static archive
add_library(spatial_mmd STATIC ${SPATIAL_MMD_SRC} ${SPATIAL_MMD_HEADERS})
set_target_properties(spatial_mmd PROPERTIES POSITION_INDEPENDENT_CODE ON)
target_compile_features(spatial_mmd PUBLIC cxx_std_17)
target_include_directories(spatial_mmd PUBLIC
    ${CMAKE_CURRENT_SOURCE_DIR}/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/../../inc  # For system_console_wrapper.h
)
if (NOT TARGET json)
  if (DEFINED ENV{COREDLA_ROOT} AND EXISTS "$ENV{COREDLA_ROOT}/thirdparty/json/CMakeLists.txt")
    add_subdirectory($ENV{COREDLA_ROOT}/thirdparty/json ${CMAKE_BINARY_DIR}/thirdparty/json_spatial_jtag_mmd)
  else()
    message(FATAL_ERROR "spatial_mmd: nlohmann json target not found")
  endif()
endif()
# Boost::filesystem and Boost::process are used by system_console_wrapper.h
target_link_libraries(spatial_mmd PUBLIC Boost::filesystem Boost::process PRIVATE json)

install(TARGETS spatial_mmd
    ARCHIVE DESTINATION lib COMPONENT RUNTIME
)

install(FILES ${SPATIAL_MMD_HEADERS}
    DESTINATION include/spatial_mmd
    COMPONENT RUNTIME
)

# Python bindings (pybind11) — optional if Python/pybind11 are unavailable
set(_PYBIND11_SRC "")
if(DEFINED COREDLA_TREE AND EXISTS "${COREDLA_TREE}/thirdparty/pybind11/CMakeLists.txt")
  set(_PYBIND11_SRC "${COREDLA_TREE}/thirdparty/pybind11")
elseif(DEFINED ENV{COREDLA_ROOT} AND EXISTS "$ENV{COREDLA_ROOT}/thirdparty/pybind11/CMakeLists.txt")
  set(_PYBIND11_SRC "$ENV{COREDLA_ROOT}/thirdparty/pybind11")
endif()

# spatial_python/README.md requires the user to create a venv with the required
# runtime packages. So we make sure to pin the interpreter to the venv Python
# rather than system python
set(Python3_FIND_STRATEGY LOCATION)
set(Python3_FIND_VIRTUALENV ONLY)
if(DEFINED ENV{VIRTUAL_ENV})
  # Python3_ROOT_DIR feeds the signature FindPython hashes to decide whether a
  # cached interpreter is still valid, so naming the venv here makes activating
  # or switching one re-run the search instead of silently reusing the result of
  # an earlier configure in the same build directory.
  set(Python3_ROOT_DIR "$ENV{VIRTUAL_ENV}")
endif()
find_package(Python3 COMPONENTS Interpreter Development.Module QUIET)

# thirdparty/ is not part of the installed package, so fall back to a pip installed
# pybind11 -- normally the one from spatial_python/requirements.txt. CMake does
# not search site-packages on its own, so ask the interpreter where pip put the
# CMake package and offer that as a hint to find_package. Installs that use the standard prefix
# instead (pybind11[global], conda, distro packages) are found without the hint,
# and pybind11_DIR or CMAKE_PREFIX_PATH still take precedence over it.
if(Python3_FOUND AND NOT _PYBIND11_SRC AND NOT TARGET pybind11::module)
  execute_process(
    COMMAND ${Python3_EXECUTABLE} -m pybind11 --cmakedir
    RESULT_VARIABLE _PYBIND11_CMAKEDIR_RESULT
    OUTPUT_VARIABLE _PYBIND11_CMAKEDIR
    OUTPUT_STRIP_TRAILING_WHITESPACE
    ERROR_QUIET)
  if(NOT _PYBIND11_CMAKEDIR_RESULT EQUAL 0)
    set(_PYBIND11_CMAKEDIR "")
  endif()
  # The interpreter shell quotes its output, so unwrap paths containing spaces.
  separate_arguments(_PYBIND11_CMAKEDIR UNIX_COMMAND "${_PYBIND11_CMAKEDIR}")

  set(PYBIND11_FINDPYTHON ON)
  find_package(pybind11 CONFIG QUIET HINTS "${_PYBIND11_CMAKEDIR}")
endif()

if(Python3_FOUND AND (_PYBIND11_SRC OR TARGET pybind11::module))
  if(NOT TARGET pybind11::module)
    set(PYBIND11_FINDPYTHON ON)
    add_subdirectory(${_PYBIND11_SRC} ${CMAKE_BINARY_DIR}/thirdparty/pybind11_spatial_jtag_mmd)
  endif()

  pybind11_add_module(spatial_mmd_py ${CMAKE_CURRENT_SOURCE_DIR}/src/spatial_mmd_pybind.cpp)
  set_target_properties(spatial_mmd_py PROPERTIES OUTPUT_NAME "spatial_mmd")
  target_link_libraries(spatial_mmd_py PRIVATE spatial_mmd)
  # pybind11 + LTO hits TLS relocation failures (R_X86_64_TPOFF32) with this toolchain.
  set_source_files_properties(${CMAKE_CURRENT_SOURCE_DIR}/src/spatial_mmd_pybind.cpp
      PROPERTIES COMPILE_OPTIONS "-fno-lto")
  target_compile_options(spatial_mmd_py PRIVATE -fno-lto)
  target_link_options(spatial_mmd_py PRIVATE -fno-lto)
  set_target_properties(spatial_mmd_py PROPERTIES
    INSTALL_RPATH "\$ORIGIN"
    BUILD_RPATH_USE_ORIGIN TRUE
  )

  install(TARGETS spatial_mmd_py
    LIBRARY DESTINATION lib COMPONENT RUNTIME
    RUNTIME DESTINATION lib COMPONENT RUNTIME
  )
else()
  message(WARNING "spatial_mmd: Python3/pybind11 not found — skipping Python bindings. "
                  "Install them with: pip install -r <runtime>/spatial_python/requirements.txt")
endif()

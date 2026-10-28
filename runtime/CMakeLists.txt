###############################################################################
# Build file defining build targets for the PCIe and HPS example design packages
#
# The runtime can be built in two ways which can be selected with the -disable_jit flag
# using the build_runtime.sh script. Adding the flag will build the AOT (ahead of time)
# runtime ONLY (hence disabling jit/just in time). This build flow should be used if you
# wish to build independently of the DLAC and/or want to port the runtime to your own system.
#
# Building without the -disable_jit flag will build a runtime that is dependent on
# DLAC's libraries which also enables both AOT and JIT flow.
#
# Note: HPS builds default to -disable_jit
##############################################################################

cmake_minimum_required(VERSION 3.10)

# CMake policies
# Use <PackageName>_ROOT env. variable as a prefix
if(POLICY CMP0074)
  cmake_policy(SET CMP0074 NEW)
endif()
# MSVC runtime library flags are selected by an abstraction.
#if(POLICY CMP0091)
#  cmake_policy(SET CMP0091 NEW)
#endif()
if(POLICY CMP0092)
  # Disable passing /W3 by default on MSVC
  cmake_policy(SET CMP0092 NEW)
endif()
# Honor visibility properties for all target types.
if(POLICY CMP0063)
  cmake_policy(SET CMP0063 NEW)
endif()
# find_package uses upper-case <PACKAGENAME>_ROOT
if(POLICY CMP0144)
  cmake_policy(SET CMP0144 NEW)
endif()
# find the upstream BoostConfig.cmake directly
if(POLICY CMP0167)
  cmake_policy(SET CMP0167 NEW)
endif()

set(CMAKE_CXX_VISIBILITY_PRESET hidden)
set(CMAKE_C_VISIBILITY_PRESET hidden)
set(CMAKE_VISIBILITY_INLINES_HIDDEN ON)

project(coredla_runtime)

if(NOT DEFINED ENV{COREDLA_ROOT})
  message(FATAL_ERROR "COREDLA_ROOT environment variable not set.")
endif()

if(NOT CoreDLA_DIR)
  set(CoreDLA_DIR $ENV{CoreDLA_DIR})
endif()
if(NOT CoreDLA_DIR)
  message(FATAL_ERROR "CoreDLA_DIR is not set. Pass -DCoreDLA_DIR=... (see runtime/build_runtime.sh).")
endif()

# Install prefix parent of CoreDLA cmake dir (e.g. .../build/coredla/dla): staged sources/libs from `make install`.
file(REAL_PATH "${CoreDLA_DIR}/.." COREDLA_PREFIX)
if(EXISTS "${COREDLA_PREFIX}/hetero_plugin/CMakeLists.txt")
  set(COREDLA_TREE "${COREDLA_PREFIX}")
else()
  file(TO_CMAKE_PATH "$ENV{COREDLA_ROOT}" COREDLA_TREE)
endif()
# Git checkout (always available): compiler/, full arch/, and top-level include/ are not fully staged under COREDLA_TREE.
if(EXISTS "${COREDLA_TREE}/compiler/inc")
  # dev path uses compiler/inc
  set(COREDLA_COMPILER_INCLUDE "${COREDLA_TREE}/compiler/inc")
else()
  # deploy path uses include/compiler
  set(COREDLA_COMPILER_INCLUDE "${COREDLA_TREE}/include/compiler")
endif()
list(APPEND CMAKE_MODULE_PATH "${COREDLA_TREE}/cmake")
include(set_pic_recursive)
defer_set_pic_for_module_and_shared()

if (CMAKE_SYSTEM_PROCESSOR MATCHES "^(arm.*|ARM.*|aarch64.*|AARCH64.*)")
  set(ARM ON)
endif()

if (NOT DEFINED DLA_OV_DEVICE_NAME)
  set(DLA_OV_DEVICE_NAME "FPGA")
endif()

# Boost from external source (creates Boost::headers, Boost::filesystem, etc.)
if (NOT TARGET Boost::headers)
  add_subdirectory(${COREDLA_TREE}/thirdparty/boost ${CMAKE_BINARY_DIR}/thirdparty/boost)
endif()

if (ARM)
  # Built static library to simplify ED4 files.
  option(BUILD_SHARED_LIBS "Build as a static library" OFF)
else()
  option(BUILD_SHARED_LIBS "Build as a shared library" ON)
endif()

# DLA specific modifications made to the MMD
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDLA_MMD")

if (${HW_BUILD_PLATFORM} STREQUAL "AGX5_SYSTEM_CONSOLE" OR ${HW_BUILD_PLATFORM} STREQUAL "AGX3_SYSTEM_CONSOLE")
  set (SYSTEM_CONSOLE_PLATFORM 1)
  set (MMD_DIR_NAME system_console)
  set (MMD_LIB_NAME system_console_mmd)
  add_definitions(-DUSE_SYSTEM_CONSOLE)
  add_definitions(-DAOCL_JTAG_PATH)
  # agx5e_modular_jtag clk_ddr is emif_usr_pll_0 at 300 MHz. AGX3 stays at the 200 MHz default.
  if (${HW_BUILD_PLATFORM} STREQUAL "AGX5_SYSTEM_CONSOLE")
    add_definitions(-DCOREDLA_DDR_CLOCK_FREQ_MHZ=300.0)
  endif()
elseif (${HW_BUILD_PLATFORM} STREQUAL "SYSTEM_CONSOLE_STREAMING")
  set (SYSTEM_CONSOLE_STREAMING_PLATFORM 1)
  set (MMD_DIR_NAME streaming)
  set (MMD_LIB_NAME streaming_mmd)
  add_definitions(-DUSE_SYSTEM_CONSOLE_STREAMING)
elseif (${HW_BUILD_PLATFORM} STREQUAL "DE10_AGILEX")
  set (DE10_AGILEX 1)
  set (MMD_DIR_NAME de10_agilex)
  set (MMD_LIB_NAME de10_agilex_mmd)
  add_definitions(-DUSE_DE10_AGILEX)
  # Enable query device information through MMD for DE10 Agilex.
  add_definitions(-DENABLE_QUERY_DEVICE_INFO)
elseif(${HW_BUILD_PLATFORM} STREQUAL "HPS_PLATFORM")
  set (HPS_PLATFORM 1)
  set (MMD_DIR_NAME hps_platform)
  set (MMD_LIB_NAME hps_platform_mmd)
  add_definitions(-DUSE_HPS_PLATFORM)
elseif(${HW_BUILD_PLATFORM} STREQUAL "DCP_A10_PAC")
  set (PAC_A10 1)
  set (MMD_DIR_NAME dcp_a10_pac)
  set (MMD_LIB_NAME intel_opae_mmd)
  add_definitions(-DUSE_PAC_A10)
  # Enable query device information through MMD for PAC A10.
  add_definitions(-DENABLE_QUERY_DEVICE_INFO)
elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX7_I_DK")
  set (AGX7_IDK 1)
  set (MMD_DIR_NAME ofs_pcie)
  set (MMD_LIB_NAME intel_opae_mmd)
  add_definitions(-DUSE_AGX7_IDK)
  # Enable query device information through MMD for AGX7 IDK.
  add_definitions(-DENABLE_QUERY_DEVICE_INFO)
elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX7_N6001")
  set (AGX7_N6001 1)
  set (MMD_DIR_NAME ofs_pcie)
  set (MMD_LIB_NAME intel_opae_mmd)
  add_definitions(-DUSE_N6001_BOARD)
  # Enable query device information through MMD for AGX7 N6001.
  add_definitions(-DENABLE_QUERY_DEVICE_INFO)
elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX7_ISERIES_SPATIAL")
  set (AGX7_ISERIES_SPATIAL 1)
  set (MMD_DIR_NAME spatial_ofs_pcie)
  set (MMD_LIB_NAME spatial_mmd)
  add_definitions(-DUSE_AGX7_ISERIES_SPATIAL)
  # Enable query device information through MMD for AGX7 ISERIES SPATIAL.
  add_definitions(-DENABLE_QUERY_DEVICE_INFO)
elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX5_JTAG_SPATIAL")
  set (AGX5_JTAG_SPATIAL 1)
  set (MMD_DIR_NAME spatial_jtag)
  set (MMD_LIB_NAME spatial_mmd)
  add_definitions(-DUSE_AGX5_JTAG_SPATIAL)
elseif(${HW_BUILD_PLATFORM} STREQUAL "AGX5_MDK")
  set (AGX5_MDK 1)
  set (MMD_DIR_NAME ofs_pcie)
  set (MMD_LIB_NAME intel_opae_mmd)
  add_definitions(-DUSE_AGX5_MDK)
  # Enable query device information through MMD for AGX5 MDK.
  add_definitions(-DENABLE_QUERY_DEVICE_INFO)
else()
  set (EMULATION 1)
endif()

# Spatial MMD platforms skip coreDlaRuntimePlugin
if (AGX7_ISERIES_SPATIAL OR AGX5_JTAG_SPATIAL)
  set (SPATIAL_PLATFORM 1)
endif()

# Set HPS_AGX7 if building for HPS and Agilex 7 is selected
if ("${HW_BUILD_PLATFORM}" STREQUAL "HPS_PLATFORM" AND "${HPS_BUILD_MACHINE}" STREQUAL "agilex7_dk_si_agi027fc")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHPS_AGX7")
endif()

# Set HPS_AGX5 if building for HPS and Agilex 5 is selected
if ("${HW_BUILD_PLATFORM}" STREQUAL "HPS_PLATFORM" AND "${HPS_BUILD_MACHINE}" STREQUAL "agilex5_mk_a5e065bb32aes1")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHPS_AGX5")
endif()

# Set HPS_AGX3 if building for HPS and Agilex 3 is selected
if ("${HW_BUILD_PLATFORM}" STREQUAL "HPS_PLATFORM" AND "${HPS_BUILD_MACHINE}" STREQUAL "agilex3")
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHPS_AGX3")
endif()

# Set HPS_PLATFORM if building for HPS
if (HPS_PLATFORM)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DHPS_PLATFORM")
endif()

if (NOT HPS_PLATFORM)
  set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DUSE_OLD_COREDLA_DEVICE")
endif()

# Flag to disable JIT mode
if (DISABLE_JIT)
  set (CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDISABLE_JIT")
endif()

# Use of <thread> or <mutex> requires Threads
# Many parts of the runtime uses <thread> or <mutex>
# So we perform a 'psuedo-global' link of all C++
# targets to the Threads::Threads target
set(THREADS_PREFER_PTHREAD_FLAG ON)
find_package(Threads REQUIRED)
link_libraries($<$<LINK_LANGUAGE:CXX>:Threads::Threads>)

# Build the runtime variant of the DLA plugin
add_definitions(-DRUNTIME_DLA_PLUGIN)

# Build the runtime variant of the DLA plugin
add_definitions(-DDLA_OV_DEVICE_NAME="${DLA_OV_DEVICE_NAME}")

# Include performance profiling
if (OPT_ENABLE_PERFORMANCE_PROFILER)
  # propogate to all relevant targets
  add_definitions(-DOPT_ENABLE_PERFORMANCE_PROFILER)
endif(OPT_ENABLE_PERFORMANCE_PROFILER)

##########
find_package(OpenVINO CONFIG REQUIRED)
# CMAKE_DL_LIBS is needed for executables that use dlopen() to load plugins dynamically on Linux/macOS.
set_property(TARGET openvino::runtime APPEND PROPERTY INTERFACE_LINK_LIBRARIES ${CMAKE_DL_LIBS})
#########


file(REAL_PATH ${CoreDLA_DIR}/../lib CoreDLA_LIB EXPAND_TILDE)
if (NOT DISABLE_JIT)
  if (AuditLibstdcxx_LIBSTDCXX_SO_PATHS)
    set(LIST_AuditLibstdcxx_LIBSTDCXX_SO_PATHS ${AuditLibstdcxx_LIBSTDCXX_SO_PATHS})
  endif()
  list(APPEND LIST_AuditLibstdcxx_LIBSTDCXX_SO_PATHS "${CoreDLA_LIB}" "$ENV{QUARTUS_ROOTDIR}/linux64")

  set(AuditLibstdcxx_LIBSTDCXX_SO_PATHS "${LIST_AuditLibstdcxx_LIBSTDCXX_SO_PATHS}"
      CACHE STRING "Set candidate paths for libstdc++.so.6 smart resolution")

  find_package(CoreDLA CONFIG REQUIRED)

  if (GLIBC_HEADER) # Unrelated to glibc_header but this means that certain runtime binaries can find this libstdc++.so.6 using $ORIGIN/.. in RUNPATH
    get_target_property(CHOSEN_AUDIT_LIBSTDCXX_SO AuditLibstdcxx::libstdcxx_so IMPORTED_LOCATION)
    file(COPY "${CHOSEN_AUDIT_LIBSTDCXX_SO}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
    get_filename_component(CHOSEN_AUDIT_LIBSTDCXX_SO_FILENAME ${CHOSEN_AUDIT_LIBSTDCXX_SO} NAME)
    file(RENAME "${CMAKE_CURRENT_BINARY_DIR}/${CHOSEN_AUDIT_LIBSTDCXX_SO_FILENAME}" "${CMAKE_CURRENT_BINARY_DIR}/libstdc++.so.6")
  endif()
else()
  if (NOT HPS_PLATFORM AND NOT WIN32)
    find_package(HeteroPlugin CONFIG REQUIRED PATHS "${CoreDLA_DIR}" "${CoreDLA_DIR}/cmake")
    find_package(CompiledResult CONFIG REQUIRED PATHS "${CoreDLA_DIR}" "${CoreDLA_DIR}/cmake")
    if (AuditLibstdcxx_LIBSTDCXX_SO_PATHS)
      set(LIST_AuditLibstdcxx_LIBSTDCXX_SO_PATHS ${AuditLibstdcxx_LIBSTDCXX_SO_PATHS})
    endif()
    list(APPEND LIST_AuditLibstdcxx_LIBSTDCXX_SO_PATHS "${CoreDLA_LIB}" "$ENV{QUARTUS_ROOTDIR}/linux64")

    set(AuditLibstdcxx_LIBSTDCXX_SO_PATHS "${LIST_AuditLibstdcxx_LIBSTDCXX_SO_PATHS}"
      CACHE STRING "Set candidate paths for libstdc++.so.6 smart resolution")
    find_package(AuditLibstdcxx CONFIG REQUIRED PATHS "${CoreDLA_DIR}" "${CoreDLA_DIR}/cmake")
    if (GLIBC_HEADER) # Unrelated to glibc_header but this means that certain runtime binaries can find this libstdc++.so.6 using $ORIGIN/.. in RUNPATH
      get_target_property(CHOSEN_AUDIT_LIBSTDCXX_SO AuditLibstdcxx::libstdcxx_so IMPORTED_LOCATION)
      file(COPY "${CHOSEN_AUDIT_LIBSTDCXX_SO}" DESTINATION "${CMAKE_CURRENT_BINARY_DIR}")
      get_filename_component(CHOSEN_AUDIT_LIBSTDCXX_SO_FILENAME ${CHOSEN_AUDIT_LIBSTDCXX_SO} NAME)
      file(RENAME "${CMAKE_CURRENT_BINARY_DIR}/${CHOSEN_AUDIT_LIBSTDCXX_SO_FILENAME}" "${CMAKE_CURRENT_BINARY_DIR}/libstdc++.so.6")
    endif()
  endif()
  if (EMULATION)
    add_library(dla_emulator SHARED IMPORTED)
    set_target_properties(dla_emulator PROPERTIES IMPORTED_LOCATION "${CoreDLA_LIB}/libdla_emulator.so")
  endif()
  find_package(Pugixml CONFIG REQUIRED PATHS "${CoreDLA_DIR}" "${CoreDLA_DIR}/cmake")
endif()

# Build hetero plugin locally if not already available as an imported target
if (NOT TARGET coreDLAHeteroPlugin)
  add_subdirectory(${COREDLA_TREE}/hetero_plugin ${CMAKE_CURRENT_BINARY_DIR}/hetero_plugin)
endif()

if (NOT TARGET dla_performance_profiler)
  add_subdirectory($ENV{COREDLA_ROOT}/util ${CMAKE_BINARY_DIR}/util)
  install(TARGETS dla_performance_profiler
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
else()
  install(IMPORTED_RUNTIME_ARTIFACTS dla_performance_profiler
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
endif()

if (NOT TARGET archparam)
  if (NOT TARGET libprotobuf)
    add_subdirectory(${COREDLA_TREE}/thirdparty/protobuf ${CMAKE_BINARY_DIR}/thirdparty/protobuf)
  endif()
  add_subdirectory(${COREDLA_TREE}/arch ${CMAKE_BINARY_DIR}/arch)
  install(TARGETS archparam
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
else()
  install(IMPORTED_RUNTIME_ARTIFACTS archparam
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
endif()
# archparam links protobuf::libprotobuf (installed as libarchparam.so next to libprotobuf.so in lib/).
# Upstream protobuf uses COMPONENT libprotobuf, so RUNTIME-only installs must still ship libprotobuf.
if (TARGET libprotobuf)
  install(TARGETS libprotobuf
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
else()
  # Staged CoreDLA may provide IMPORTED archparam without building libprotobuf in this project.
  set(_runtime_libprotobuf "")
  if(APPLE)
    file(GLOB _runtime_libprotobuf "${CoreDLA_LIB}/libprotobuf*.dylib")
  elseif(UNIX)
    file(GLOB _runtime_libprotobuf "${CoreDLA_LIB}/libprotobuf.so*")
  endif()
  if(_runtime_libprotobuf)
    install(FILES ${_runtime_libprotobuf} DESTINATION "lib" COMPONENT RUNTIME)
  endif()
endif()
if (NOT TARGET dla_compiled_result)
  add_subdirectory(${COREDLA_TREE}/compiled_result ${CMAKE_CURRENT_BINARY_DIR}/compiled_result)
  install(TARGETS dla_compiled_result
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
else()
  install(IMPORTED_RUNTIME_ARTIFACTS dla_compiled_result
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
endif()
if (NOT TARGET json)
  add_subdirectory($ENV{COREDLA_ROOT}/thirdparty/json ${CMAKE_BINARY_DIR}/thirdparty/json)
endif()
if (NOT TARGET fmt)
  add_subdirectory(${COREDLA_TREE}/thirdparty/fmt ${CMAKE_BINARY_DIR}/thirdparty/fmt)
endif()
if (NOT TARGET dla_util)
  add_subdirectory(${COREDLA_TREE}/util ${CMAKE_CURRENT_BINARY_DIR}/util)
endif()
if (NOT TARGET alpaca_with_default_options)
  add_subdirectory(${COREDLA_TREE}/thirdparty/alpaca ${CMAKE_BINARY_DIR}/thirdparty/alpaca)
  add_library(alpaca_with_default_options INTERFACE)
  target_compile_definitions(alpaca_with_default_options INTERFACE ALPACA_DEFAULT_OPTIONS=fixed_length_encoding|reverse_aggregate_fields|no_size_prefix)
  target_link_libraries(alpaca_with_default_options INTERFACE alpaca)
endif()
if (NOT TARGET dla_dma_constants)
  add_library(dla_dma_constants INTERFACE)
  if (HPS_PLATFORM)
    target_sources(dla_dma_constants INTERFACE
      ${CoreDLA_DIR}/../fpga/dma/dual_inc/dla_dma_constants.h
      ${CoreDLA_DIR}/../fpga/dma/dual_inc/dla_dma_constants.svh
    )
    target_include_directories(dla_dma_constants INTERFACE
      ${CoreDLA_DIR}/../fpga/dma/dual_inc
    )
  else()
    target_sources(dla_dma_constants INTERFACE
      ${CoreDLA_DIR}/../include/fpga/dla_dma_constants.h
      ${CoreDLA_DIR}/../include/fpga/dla_dma_constants.svh
    )
    target_include_directories(dla_dma_constants INTERFACE
      ${CoreDLA_DIR}/../include/fpga
    )
  endif()
endif()

# Gets a build version of {git branch}-{git hash} as an identifier for the plugin build version. Defaults to "Custom Build"
function(get_build_version output_variable)
  # Get branch name
  execute_process(
    COMMAND git rev-parse --abbrev-ref HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE result_var_branch
    OUTPUT_VARIABLE branch_name
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  # Get hash
  execute_process(
    COMMAND git rev-parse --short=10 HEAD
    WORKING_DIRECTORY ${CMAKE_SOURCE_DIR}
    RESULT_VARIABLE result_var_hash
    OUTPUT_VARIABLE git_hash
    ERROR_QUIET
    OUTPUT_STRIP_TRAILING_WHITESPACE
  )
  if(NOT ${result_var_branch} EQUAL 0 OR NOT ${result_var_hash} EQUAL 0)
    set(${output_variable} "Custom build" PARENT_SCOPE)
  else()
    set(${output_variable} "${branch_name}-${git_hash}" PARENT_SCOPE)
  endif()
endfunction()
# Call function to get Git branch name
get_build_version(PLUGIN_BUILD_VERSION)

# Pass PLUGIN_BUILD_VERSION to the source code via a define
add_definitions(-DPLUGIN_BUILD_VERSION="${PLUGIN_BUILD_VERSION}")

if (NOT ARM)
  # ED4 OV is not built with tbb threading
  find_package(TBB REQUIRED tbb)
  if ( NOT DEFINED TBB_IMPORTED_TARGETS)
    set (TBB_IMPORTED_TARGETS TBB::tbb)
  endif()
endif()

SET (INFO 0)
SET (WARNING 1)
SET (ERROR 2)
SET (FATAL 3)

if(DEBUG_RUNTIME)
  add_definitions(-DDEBUG_RUNTIME)
endif(DEBUG_RUNTIME)
if(DEBUG_RUNTIME_MEMORY_TEST)
  add_definitions(-DDEBUG_RUNTIME_MEMORY_TEST)
endif(DEBUG_RUNTIME_MEMORY_TEST)
if(RUNTIME_VERBOSITY)
  add_definitions(-DENABLE_LOGGING)
  add_definitions(-DRUNTIME_VERBOSITY=${${RUNTIME_VERBOSITY}})
endif(RUNTIME_VERBOSITY)

if(RUNTIME_POLLING)
  add_definitions(-DCOREDLA_RUNTIME_POLLING)
endif(RUNTIME_POLLING)

# OpenVINO pre-requisites to build hetero & dla plugin
add_subdirectory(${COREDLA_TREE}/thirdparty/openvino_dev_api thirdparty/openvino_dev_api)
add_subdirectory($ENV{COREDLA_XUTIL_DIR}/transformations ${CMAKE_CURRENT_BINARY_DIR}/transformations)

# Required for dla_benchmark and demos
add_subdirectory(common)

# Build runtime plugin CPU io transforms (not needed for spatial which uses spatialPlugin)
if (NOT SPATIAL_PLATFORM)
  add_subdirectory(${COREDLA_TREE}/dla_plugin/io_transformations ${CMAKE_BINARY_DIR}/dla_plugin/io_transformations)
endif()

# Build Runtime plugin (AGX7/A10/HPS/Emulator)
if(NOT EMULATION)
  add_subdirectory(coredla_device/mmd/${MMD_DIR_NAME})
  # For some reason, (${HW_BUILD_PLATFORM} STREQUAL "DE10_AGILEX") does not work in the line below
  if (DE10_AGILEX)
    add_subdirectory(fpga_jtag_reprogram)
  endif()

  # Python spatial runtimes, for every spatial target (spatial_mmd*.so is
  # installed separately under lib/ by the MMD above)
  if (SPATIAL_PLATFORM)
    install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/spatial_python/
            DESTINATION spatial_python
            COMPONENT RUNTIME
            PATTERN "__pycache__" EXCLUDE
            PATTERN "*.pyc" EXCLUDE
            PATTERN "spatial_mmd*.so" EXCLUDE)
  endif()

  # For AGX7_ISERIES_SPATIAL, build spatialPlugin only (not coreDlaRuntimePlugin)
  if (AGX7_ISERIES_SPATIAL)
    set(SPATIAL_MMD_INC_DIR "${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/mmd/spatial_ofs_pcie/inc")
    # spatial_plugin lives in this runtime tree (example-designs); not under COREDLA_TREE
    add_subdirectory(${CMAKE_CURRENT_SOURCE_DIR}/spatial_plugin ${CMAKE_CURRENT_BINARY_DIR}/spatial_plugin)

    # Set plugin entries for SPATIAL builds - use relative path from plugins.xml location
    set(DLA_PLUGIN_ENTRIES "        <plugin name=\"SPATIAL\" location=\"$<PATH:RELATIVE_PATH,$<TARGET_FILE:spatialPlugin>,${CMAKE_CURRENT_BINARY_DIR}>\"></plugin>")
    set(DLA_PLUGIN_ENTRIES_INSTALL "        <plugin name=\"SPATIAL\" location=\"${CMAKE_SHARED_LIBRARY_PREFIX}spatialPlugin${CMAKE_SHARED_LIBRARY_SUFFIX}\"></plugin>")

    # Generate plugins.xml for SPATIAL builds
    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_var_subbed.xml)
    file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_var_subbed.xml)

    configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins_install.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_install_var_subbed.xml)
    file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_install.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_install_var_subbed.xml)
  elseif (AGX5_JTAG_SPATIAL)
    # spatial_mmd is built via add_subdirectory(mmd/spatial_jtag). No OpenVINO plugin.
  else()
  # Build coreDlaRuntimePlugin for all non-spatial platforms
  file(GLOB SOURCES
    ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/src/*.cpp
    ${COREDLA_TREE}/dla_plugin/src/*.cpp
  )

  if (SYSTEM_CONSOLE_PLATFORM)
    list(REMOVE_ITEM SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/src/mmd_wrapper.cpp)
  endif()

  file(GLOB HEADERS
    ${COREDLA_TREE}/dla_plugin/inc/dlia/*.hpp
    ${COREDLA_TREE}/dla_plugin/inc/*.hpp
    ${COREDLA_TREE}/dla_plugin/inc/*.h
    ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/inc/*.h
  )

  # Plugins should use MODULE because they are dynamically loaded at runtime and do not need to be linked at build time.
  add_library(coreDlaRuntimePlugin MODULE ${SOURCES} ${HEADERS})
  if(NOT WIN32)
    target_link_options(coreDlaRuntimePlugin PRIVATE "-Wl,--no-as-needed")
  endif()
  target_link_libraries(coreDlaRuntimePlugin PRIVATE dla_dma_constants)
  target_compile_features(coreDlaRuntimePlugin PRIVATE
    $<$<CXX_COMPILER_ID:MSVC>:cxx_std_14>
    $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:cxx_std_11>
  )

  if (SYSTEM_CONSOLE_PLATFORM)
    target_sources(coreDlaRuntimePlugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/mmd/system_console/mmd_wrapper.cpp)

    add_custom_command(
      TARGET coreDlaRuntimePlugin POST_BUILD
      COMMAND ${CMAKE_COMMAND} -E copy
      ${CMAKE_SOURCE_DIR}/coredla_device/mmd/system_console/system_console_script.tcl
      ${CMAKE_CURRENT_BINARY_DIR}/system_console_script.tcl
    )
    target_link_libraries(coreDlaRuntimePlugin PRIVATE Boost::filesystem Boost::process)
    # Ensure number of inference request is 1 when using the system-console plugin, and define the system console script path
    target_compile_definitions(coreDlaRuntimePlugin PRIVATE DLA_SYSCON_SOURCE_ROOT=${CMAKE_CURRENT_BINARY_DIR} -DMAX_NUM_INFERENCE_REQUEST=1)
  else()
    target_sources(coreDlaRuntimePlugin PRIVATE ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/src/mmd_wrapper.cpp)
  endif()
  endif() # NOT SPATIAL_PLATFORM
endif() # NOT EMULATION

if (WIN32 AND NOT SPATIAL_PLATFORM)
  # Fix warning C4273: inconsistent dll linkage
  target_compile_definitions(coreDlaRuntimePlugin PRIVATE XBYAK_NO_OP_NAMES
    IMPLEMENT_OPENVINO_RUNTIME_PLUGIN
    $<TARGET_PROPERTY:openvino::runtime,INTERFACE_COMPILE_DEFINITIONS>)
endif()

if(NOT EMULATION AND NOT SPATIAL_PLATFORM)
  target_include_directories(coreDlaRuntimePlugin PUBLIC
    ${COREDLA_TREE}/dla_plugin/inc
    ${COREDLA_TREE}/dla_plugin/
    ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/inc
    ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/mmd/${MMD_DIR_NAME}/host
    ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/mmd/${MMD_DIR_NAME}/include
    ${CMAKE_CURRENT_SOURCE_DIR}/coredla_device/stream_controller/app
    ${COREDLA_COMPILER_INCLUDE}
  )
  target_link_libraries(coreDlaRuntimePlugin PUBLIC dla_util PRIVATE dla_compiled_result archparam)

  if (OPT_ENABLE_PERFORMANCE_PROFILER)
    target_link_libraries(coreDlaRuntimePlugin PUBLIC dla_performance_profiler)
  endif()

  if (NOT HPS_PLATFORM)
    target_link_libraries(coreDlaRuntimePlugin PUBLIC
      ${TBB_IMPORTED_TARGETS}
      openvino::runtime
      openvino_dev_api
      dliaPluginIOTransformations
      dla_op_transformation
      ${MMD_LIB_NAME}
    )

    if (NOT DISABLE_JIT)
      target_link_libraries(coreDlaRuntimePlugin PUBLIC
        archparam
        dla_compiler_core
        dla_compiled_result
        lpsolve5525
      )
    endif()
  else()
    target_link_libraries(coreDlaRuntimePlugin PUBLIC
      openvino::runtime
      openvino_dev_api
      dliaPluginIOTransformations
      dla_op_transformation
      ${MMD_LIB_NAME}
    )

  endif()

  # Set plugin entries for FPGA/HETERO builds (non-spatial)
  set(DLA_PLUGIN_ENTRIES "        <plugin name=\"HETERO\" location=\"$<PATH:RELATIVE_PATH,$<TARGET_FILE:coreDLAHeteroPlugin>,$<TARGET_FILE_DIR:coreDlaRuntimePlugin>>\"></plugin>\n        <plugin name=\"FPGA\" location=\"$<PATH:RELATIVE_PATH,$<TARGET_FILE:coreDlaRuntimePlugin>,$<TARGET_FILE_DIR:coreDlaRuntimePlugin>>\"></plugin>")
  set(DLA_PLUGIN_ENTRIES_INSTALL "        <plugin name=\"HETERO\" location=\"$<TARGET_FILE:coreDLAHeteroPlugin>\"></plugin>\n        <plugin name=\"FPGA\" location=\"$<TARGET_FILE_NAME:coreDlaRuntimePlugin>\"></plugin>")

  # configure_file replaces ${} variables
  # file(GENERATE replace generator expressions
  # Neither can do both
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_var_subbed.xml)
  file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_var_subbed.xml)

  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins_install.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_install_var_subbed.xml)
  file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_install.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_install_var_subbed.xml)

  if (NOT HPS_PLATFORM)
    add_subdirectory(dla_aot_splitter)
  endif()
elseif(EMULATION)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins_emulation_install.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_emulation_install_var_subbed.xml)
  file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_emulation_install.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_emulation_install_var_subbed.xml)
endif()

add_subdirectory(dla_benchmark)

# Runtime demos are not built by default.
# Pass argument -build_demo to build_runtime.sh to build runtime demos.
if (DEFINED BUILD_DEMO)
  if (DISABLE_JIT)
    message(FATAL_ERROR
      "Error: BUILD_DEMO requires JIT support, but JIT compilation disabled via DISABLE_JIT."
      "       If you did not specify these options, then they may have been cached.  Remove"
      "       ${CMAKE_BINARY_DIR} to clear the cache."
  )
  endif()
  add_subdirectory(classification_sample_async)
  add_subdirectory(object_detection_demo)
  add_subdirectory(segmentation_demo)
endif()

if (HPS_PLATFORM)
  add_subdirectory(streaming/streaming_inference_app)
  add_subdirectory(streaming/image_streaming_app)
endif()

if (NOT EMULATION AND NOT SPATIAL_PLATFORM)
  install(TARGETS coreDlaRuntimePlugin
    RUNTIME DESTINATION "bin" COMPONENT RUNTIME
    LIBRARY DESTINATION "lib" COMPONENT RUNTIME
    ARCHIVE DESTINATION "lib" COMPONENT RUNTIME
  )
endif()

# Beware ninja ORIGIN escape issues. If you use origin for ninja you must escape it as \$$ORIGIN. For make, \$ORIGIN
if (NOT WIN32)
  if (EMULATION)
    # Use a package-relative audit path so the interceptor is resolved next to
    # the installed binary via $ORIGIN, keeping the emulator relocatable.
    if ("${CMAKE_GENERATOR}" STREQUAL "Ninja")
      set_target_properties(dla_benchmark PROPERTIES AUDIT_LIBRARIES \$$ORIGIN/../lib/$<TARGET_FILE_NAME:AuditLibstdcxx::audit_libstdcxx>)
    else()
      set_target_properties(dla_benchmark PROPERTIES AUDIT_LIBRARIES \$ORIGIN/../lib/$<TARGET_FILE_NAME:AuditLibstdcxx::audit_libstdcxx>)
    endif()
  elseif ("${CMAKE_GENERATOR}" STREQUAL "Ninja")
    set_target_properties(dla_benchmark PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
  else()
    set_target_properties(dla_benchmark PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
  endif()

  if (NOT EMULATION AND DE10_AGILEX)
    # Beware ninja ORIGIN escape issues. If you use origin for ninja you must escape it as \$$ORIGIN. For make, \$ORIGIN
    if ("${CMAKE_GENERATOR}" STREQUAL "Ninja")
      set_target_properties(fpga_jtag_reprogram PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
    else()
      set_target_properties(fpga_jtag_reprogram PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
    endif()
    set_target_properties(fpga_jtag_reprogram PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
  endif()
endif()

if (NOT EMULATION)
  if (NOT DISABLE_JIT AND NOT SPATIAL_PLATFORM)
    set_target_properties(dla_benchmark PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib:$<TARGET_FILE_DIR:dla_compiler_core>")
    set_target_properties(coreDlaRuntimePlugin PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib:$<TARGET_FILE_DIR:dla_compiler_core>")
  else()
    set_target_properties(dla_benchmark PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
    if (NOT SPATIAL_PLATFORM)
      set_target_properties(coreDlaRuntimePlugin PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
    endif()
  endif()
  if("${HW_BUILD_PLATFORM}" STREQUAL "DCP_A10_PAC" OR "${HW_BUILD_PLATFORM}" STREQUAL "AGX7_I_DK" OR "${HW_BUILD_PLATFORM}" STREQUAL "AGX7_N6001" OR "${HW_BUILD_PLATFORM}" STREQUAL "AGX5_MDK")
    set_target_properties(intel_opae_mmd PROPERTIES INSTALL_RPATH
      "\$ORIGIN:$<TARGET_FILE_DIR:libopae-c>")
  endif()
endif()

if (EMULATION)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/plugins_emulation_install.xml DESTINATION "lib" RENAME "plugins.xml")
elseif (NOT AGX5_JTAG_SPATIAL)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/plugins_install.xml DESTINATION "lib" RENAME "plugins.xml")
endif()

if (NOT HPS_PLATFORM AND NOT WIN32)
  install(IMPORTED_RUNTIME_ARTIFACTS AuditLibstdcxx::libstdcxx_so
    LIBRARY DESTINATION lib
  )
endif()

# Co-locate the audit interceptor next to libstdc++.so.6 so the package-relative
# AUDIT_LIBRARIES path set above resolves from the installed layout.
if (EMULATION AND NOT WIN32)
  install(IMPORTED_RUNTIME_ARTIFACTS AuditLibstdcxx::audit_libstdcxx
    LIBRARY DESTINATION lib
  )
endif()

if (TARGET dla_aot_splitter)
  install(TARGETS dla_aot_splitter dla_aot_splitter_plugin
    RUNTIME DESTINATION "bin"
    LIBRARY DESTINATION "lib"
    ARCHIVE DESTINATION "lib"
  )
  set_target_properties(dla_aot_splitter PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
  set_target_properties(dla_aot_splitter_plugin PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
  if (NOT EMULATION AND NOT DISABLE_JIT)
    set_target_properties(dla_aot_splitter PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib:$<TARGET_FILE_DIR:dla_compiler_core>")
    set_target_properties(dla_aot_splitter_plugin PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib:$<TARGET_FILE_DIR:archparam>")
  endif()
  if (NOT WIN32)
    set_target_properties(dla_aot_splitter PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
    set_target_properties(dla_aot_splitter_example PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
  endif()
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins_aot_splitter.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter_var_subbed.xml)
  file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter_var_subbed.xml)
  configure_file(${CMAKE_CURRENT_SOURCE_DIR}/plugin_templates/plugins_aot_splitter_install.xml ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter_install_var_subbed.xml)
  file(GENERATE OUTPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter_install.xml INPUT ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter_install_var_subbed.xml)
  install(FILES ${CMAKE_CURRENT_BINARY_DIR}/plugins_aot_splitter_install.xml DESTINATION "lib" RENAME "plugins_aot_splitter.xml")
endif()

if (DEFINED BUILD_DEMO)
  set_target_properties(object_detection_demo PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
  set_target_properties(segmentation_demo PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
  set_target_properties(classification_sample_async PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib")
  #if (NOT EMULATION and NOT DISABLE_JIT)
  #  set_target_properties(object_detection_demo PROPERTIES INSTALL_RPATH "\$ORIGIN/../lib:$<TARGET_FILE_DIR:dla_compiler_core>")
  #endif()
  if (NOT WIN32)
    set_target_properties(object_detection_demo PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
    set_target_properties(segmentation_demo PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
    set_target_properties(classification_sample_async PROPERTIES AUDIT_LIBRARIES $<TARGET_FILE:AuditLibstdcxx::audit_libstdcxx>)
  endif()
  install(TARGETS object_detection_demo segmentation_demo classification_sample_async RUNTIME DESTINATION "bin")

  install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/python_demos/ DESTINATION "python_demos")
endif()

install(DIRECTORY ${CMAKE_CURRENT_SOURCE_DIR}/streaming/ed0_streaming_example/ DESTINATION streaming/ed0_streaming_example)

# Add ed0 streaming example tcl script
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/streaming/ed0_streaming_example/system_console_script.tcl
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/streaming/ed0_streaming_example/.)
file(COPY ${CMAKE_CURRENT_SOURCE_DIR}/streaming/ed0_streaming_example/include/system_console_lib.tcl
     DESTINATION ${CMAKE_CURRENT_BINARY_DIR}/streaming/ed0_streaming_example/include/.)

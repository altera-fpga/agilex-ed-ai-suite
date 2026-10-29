# Copyright (C) 2018-2022 Intel Corporation
# SPDX-License-Identifier: Apache-2.0
#


file (GLOB MAIN_SRC ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
file (GLOB LIBRARY_HEADERS ${CMAKE_CURRENT_SOURCE_DIR}/*.h)

# Create named folders for the sources within the .vcproj
# Empty name lists them directly under the .vcproj
source_group("src" FILES ${LIBRARY_SRC})
source_group("include" FILES ${LIBRARY_HEADERS})

# Create library file from sources.
add_library(format_reader SHARED ${MAIN_SRC} ${LIBRARY_HEADERS})

# Find OpenCV components if exist
find_package(OpenCV QUIET COMPONENTS core imgproc imgcodecs)
if(NOT OpenCV_FOUND)
    message(WARNING "OpenCV is disabled or not found, format_reader will be built without OpenCV support")
else()
    target_link_libraries(format_reader PRIVATE ${OpenCV_LIBRARIES} ie_samples_utils)
    if(UNIX AND NOT APPLE)
        # Workaround issue that rpath-link is missing for PRIVATE dependencies
        # Fixed in cmake 3.16.0 https://gitlab.kitware.com/cmake/cmake/issues/19556
        target_link_libraries(format_reader INTERFACE "-Wl,-rpath-link,${OpenCV_INSTALL_PATH}/lib")
    endif()
    # Make this definition public so that it's also seen by dla benchmark. As dla benchmark
    # uses this macro to identify which image extensions are supported by the image reader
    target_compile_definitions(format_reader PUBLIC USE_OPENCV)
endif()

target_compile_definitions(format_reader PRIVATE IMPLEMENT_FORMAT_READER)

target_include_directories(format_reader PUBLIC "${CMAKE_CURRENT_SOURCE_DIR}"
                                                 "${CMAKE_CURRENT_SOURCE_DIR}/..")

set_target_properties(format_reader PROPERTIES COMPILE_PDB_NAME format_reader
                                                FOLDER cpp_samples)

if(COMMAND add_clang_format_target)
    add_clang_format_target(format_reader_clang FOR_TARGETS format_reader)
endif()

install(
    TARGETS format_reader
    RUNTIME DESTINATION samples_bin/ COMPONENT samples_bin EXCLUDE_FROM_ALL
    LIBRARY DESTINATION samples_bin/ COMPONENT samples_bin EXCLUDE_FROM_ALL
)

install(TARGETS format_reader
  RUNTIME DESTINATION "bin" COMPONENT EMUTEST
  LIBRARY DESTINATION "lib" COMPONENT EMUTEST
  ARCHIVE DESTINATION "lib" COMPONENT EMUTEST)

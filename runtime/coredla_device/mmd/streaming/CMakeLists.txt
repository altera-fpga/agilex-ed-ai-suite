# (C) 2017 Intel Corporation. All rights reserved.
# Your use of Intel Corporation's design tools, logic functions and other
# software and tools, and its AMPP partner logic functions, and any output
# files any of the foregoing (including device programming or simulation
# files), and any associated documentation or information are expressly subject
# to the terms and conditions of the Intel Program License Subscription
# Agreement, Intel MegaCore Function License Agreement, or other applicable
# license agreement, including, without limitation, that your use is for the
# sole purpose of programming logic devices manufactured by Intel and sold by
# Intel or its authorized distributors.  Please refer to the applicable
# agreement for further details.

cmake_minimum_required(VERSION 2.8.12)
project(mmd)

add_definitions(-DI_DK_AFU_ID="11446C9D-AA42-4085-9B3D-4EEF9429A4AD")

# DLA specific modifications made to the MMD
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDLA_MMD")

enable_language(C ASM)

set(ASM_OPTIONS "-x assembler-with-cpp")
if(${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
  set(ASM_OPTIONS "${ASM_OPTIONS} -no-integrated-as")
endif()

set(CMAKE_ASM_FLAGS "${CFLAGS} ${ASM_OPTIONS}")

set(MMD_SRC
   ./host/mmd.cpp
   ./host/mmd_device.cpp
)

# Add a shared library target called streaming_mmd
# and build it from the MMD_SRC files
add_library(streaming_mmd SHARED ${MMD_SRC})

# Specify the include directories to be used when compiling streaming_mmd library
target_include_directories(streaming_mmd PUBLIC
                           ${CMAKE_CURRENT_SOURCE_DIR}/include
                           ${CMAKE_CURRENT_SOURCE_DIR}/../../inc  # for system_console_wrapper.h
                           )

# Boost::filesystem and Boost::process provided by thirdparty/boost
# Specify libraries needed when linking the streaming_mmd library
target_link_libraries(streaming_mmd PRIVATE Boost::filesystem Boost::process dla_util dla_dma_constants)

# Set the installation rules for the project
install(TARGETS streaming_mmd
   LIBRARY DESTINATION lib
   COMPONENT streaming_mmd
)

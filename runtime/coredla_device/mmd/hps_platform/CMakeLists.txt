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

cmake_minimum_required(VERSION 2.8.12...3.10)
project(mmd)

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

# DLA specific modifications made to the MMD
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDLA_MMD")

# Select PCIE Gen3 x8
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DGEN3_x8")

# from the opencl makefile
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DKERNEL_64BIT -DOPTION3=1 -DACL_USE_DMA=1 -DACL_COMPILER_IS_MSVC=0 -Wall -Wno-unknown-pragmas -DACL_HAS_STDLIB_STDIO")
# No _GLIBCXX_USE_CXX11_ABI=0 since OpenVINO 24.4 will force _GLIBCXX_USE_CXX11_ABI=1
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -fstack-protector -Wformat -Wformat-security -fPIC -DACL_HOST_RUNTIME_IS_STATIC=0")
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DACL_OPENCL_HOST_SYS=linux -DACL_OPENCL_HOST_BIT=64 -DACL_TARGET_SYS=linux -DACL_TARGET_BIT=64 -DLINUX -DACL_MAX_DEVICE=128")

set(CMAKE_CXX_FLAGS_RELEASE "${CMAKE_CXX_FLAGS_RELEASE} -D_FORTIFY_SOURCE=2 -O3")
enable_language(C ASM)

set(ASM_OPTIONS "-x assembler-with-cpp")
if(${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
  set(ASM_OPTIONS "${ASM_OPTIONS} -no-integrated-as")
endif()

set(CMAKE_ASM_FLAGS "${CFLAGS} ${ASM_OPTIONS}")

if(RUNTIME_POLLING)
  add_definitions(-DRUNTIME_POLLING)
endif(RUNTIME_POLLING)

set(MMD_SRC
   ./host/acl_hps.cpp
   ./host/mmd_device.cpp
   ./host/dma_device.cpp
   ./host/uio_device.cpp
)

add_library(hps_platform_mmd SHARED ${MMD_SRC})

target_include_directories(hps_platform_mmd PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)

install(TARGETS hps_platform_mmd
   LIBRARY DESTINATION lib
   COMPONENT hps_platform_mmd
)

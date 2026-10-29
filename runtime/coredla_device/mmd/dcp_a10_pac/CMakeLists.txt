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

list(APPEND CMAKE_MODULE_PATH "${CMAKE_CURRENT_SOURCE_DIR}/cmake/modules")

find_package(OPAE REQUIRED)
find_package(NUMA REQUIRED)

# DLA specific modifications made to the MMD
set(CMAKE_CXX_FLAGS "${CMAKE_CXX_FLAGS} -DDLA_MMD")

enable_language(C ASM)

set(ASM_OPTIONS "-x assembler-with-cpp")
if(${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
  set(ASM_OPTIONS "${ASM_OPTIONS} -no-integrated-as")
endif()

set(CMAKE_ASM_FLAGS "${CFLAGS} ${ASM_OPTIONS}")

set(MMD_SRC
   ./host/ccip_mmd.cpp
   ./host/ccip_mmd_device.cpp
   ./host/dma_work_thread.cpp
   ./host/fpga_dma.c
   ./host/kernel_interrupt.cpp
   ./host/mmd_dma.cpp
   ./host/memcpy_s_fast.c
   ./host/x86-sse2.S
)

# Add a shared library target called intel_opae_mmd
# and build it from the MMD_SRC files
add_library(intel_opae_mmd SHARED ${MMD_SRC})

# Specify the include directories to be used when compiling intel_opae_mmd library
target_include_directories(intel_opae_mmd PUBLIC
                            ${CMAKE_CURRENT_SOURCE_DIR}/include
                            )

# Specify libraries needed when liking the intel_opae_mmd library
target_link_libraries(intel_opae_mmd
   libopae-c
   libnuma
)

# Set the installation rules for the project
install(TARGETS intel_opae_mmd
   LIBRARY DESTINATION lib
   COMPONENT intel_opae_mmd
)

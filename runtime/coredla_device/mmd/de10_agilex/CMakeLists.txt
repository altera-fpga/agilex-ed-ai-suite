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

enable_language(C ASM)

set(ASM_OPTIONS "-x assembler-with-cpp")
if(${CMAKE_C_COMPILER_ID} STREQUAL "Clang")
  set(ASM_OPTIONS "${ASM_OPTIONS} -no-integrated-as")
endif()

set(CMAKE_ASM_FLAGS "${CFLAGS} ${ASM_OPTIONS}")

add_library(de10_agilex_mmd SHARED)

target_sources(de10_agilex_mmd PRIVATE
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_config.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_debug.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_device.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_dma_linux.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_dma_windows.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_hostch.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_mm_io.cpp
  ${CMAKE_CURRENT_SOURCE_DIR}/host/acl_pcie_timer.cpp
)

# DLA specific modifications made to the MMD
target_compile_definitions(de10_agilex_mmd PRIVATE
  "DLA_MMD"
  "ACL_MAX_DEVICE=128"
  "OPTION3=1" "ACL_USE_DMA=1"
  "ACL_HAS_STDLIB_STDIO"
  "ACL_HAS_STDLIB_STDIO"
  "ACL_OPENCL_HOST_BIT=64"
  "ACL_TARGET_BIT=64"
  "GEN3_x16"
)

if (WIN32)
  target_compile_definitions(de10_agilex_mmd PRIVATE
    "AOCL_MMD_CALL=__declspec(dllexport)"
    "ACL_COMPILER_IS_MSVC=1"
    "ACL_HOST_RUNTIME_IS_STATIC=1"
    "ACL_OPENCL_HOST_SYS=windows"
    "ACL_TARGET_SYS=windows"
    "WINDOWS"
  )
endif()

# from the opencl makefile
if (NOT WIN32)
  target_compile_definitions(de10_agilex_mmd PRIVATE
    "KERNEL_64BIT"
    "ACL_COMPILER_IS_MSVC=0"
    "ACL_HOST_RUNTIME_IS_STATIC=0"
    "ACL_OPENCL_HOST_SYS=linux"
    "ACL_TARGET_SYS=linux"
    "LINUX"
  )
endif()

target_include_directories(de10_agilex_mmd PUBLIC ${CMAKE_CURRENT_SOURCE_DIR}/include)
if (WIN32)
  # Terrasic production BSP Linux kernel space driver header files
  set(TERASIC_KERNEL_HEADER_DIR $ENV{AOCL_BOARD_PACKAGE_ROOT}/linux64/driver)
  set(TERASIC_KERNEL_HEADER_FILES
    fpga_cmd_guids.h
    hw_host_channel.h
    hw_pcie_constants.h
    hw_pcie_dma.h
  )
  if (EXISTS ${TERASIC_KERNEL_HEADER_DIR})
    foreach(header ${TERASIC_KERNEL_HEADER_FILES})
      if (EXISTS ${TERASIC_KERNEL_HEADER_DIR}/${header})
        file(COPY ${TERASIC_KERNEL_HEADER_DIR}/${header} DESTINATION ${CMAKE_CURRENT_SOURCE_DIR}/include)
      else()
        message(WARNING "Header file ${header} does not exist in ${TERASIC_KERNEL_HEADER_DIR}")
      endif()
    endforeach()
  else()
    message(FATAL_ERROR "Source directory ${TERASIC_KERNEL_HEADER_DIR} does not exist.")
  endif()

  set(HW_PCI_DMA_H ${CMAKE_CURRENT_SOURCE_DIR}/include/hw_pcie_dma.h)
  file(READ ${HW_PCI_DMA_H} HW_PCI_DMA_H_CONTENT)
  # Remove any end-of-line whitespace from the file content (spaces and tabs)
  string(REGEX REPLACE "[ \t]+(\r?\n)" "\\1" HW_PCI_DMA_H_CONTENT "${HW_PCI_DMA_H_CONTENT}")
  set(OLD_CODE_BLOCK
"PACK(
struct DMA_DESC_ENTRY {
    UINT32 src_addr_ldw;
    UINT32 src_addr_udw;
    UINT32 dest_addr_ldw;
    UINT32 dest_addr_udw;
    UINT32 ctl_dma_len;
    UINT32 reserved[3];
});")
  set(NEW_CODE_BLOCK
"#if defined(GEN3_x8)
PACK(
struct DMA_DESC_ENTRY {
    UINT32 src_addr_ldw;
    UINT32 src_addr_udw;
    UINT32 dest_addr_ldw;
    UINT32 dest_addr_udw;
    UINT32 ctl_dma_len;
    UINT32 reserved[3];
});
#elif defined(GEN3_x16)
PACK(
struct DMA_DESC_ENTRY {
    UINT64 src_addr;
    UINT64 dst_addr;
    UINT32 ctrl;
    UINT32 reserved[3];
});
#endif")
  string(REPLACE "${OLD_CODE_BLOCK}" "${NEW_CODE_BLOCK}" HW_PCI_DMA_H_CONTENT "${HW_PCI_DMA_H_CONTENT}")
  file(WRITE ${HW_PCI_DMA_H} "${HW_PCI_DMA_H_CONTENT}")

  set_target_properties(de10_agilex_mmd PROPERTIES LINK_FLAGS "-subsystem:console -nologo -fixed:no -incremental:no -opt:noref -ignore:4089 /NXCOMPAT /DYNAMICBASE")

  find_library(ACL_CHECK_SYS_CMD_LIB
    acl_check_sys_cmd
    PATHS ${CMAKE_CURRENT_SOURCE_DIR}/lib/win64)
  find_library(FPGA_LIB
    FpgaLib
    PATHS ${CMAKE_CURRENT_SOURCE_DIR}/lib/win64)

  target_link_libraries(de10_agilex_mmd PRIVATE ${ACL_CHECK_SYS_CMD_LIB} ${FPGA_LIB})
endif()

install(TARGETS de10_agilex_mmd
  RUNTIME DESTINATION "bin" COMPONENT de10_agilex_mmd
  LIBRARY DESTINATION "lib" COMPONENT de10_agilex_mmd
  ARCHIVE DESTINATION "lib" COMPONENT de10_agilex_mmd
)

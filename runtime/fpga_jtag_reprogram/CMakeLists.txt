cmake_minimum_required(VERSION 3.10)

file(GLOB SOURCES ${CMAKE_CURRENT_SOURCE_DIR}/*.cpp)
add_executable(fpga_jtag_reprogram ${SOURCES})
target_compile_features(fpga_jtag_reprogram PRIVATE
  $<$<CXX_COMPILER_ID:MSVC>:cxx_std_14>
  $<$<NOT:$<CXX_COMPILER_ID:MSVC>>:cxx_std_11>
)

target_compile_definitions(fpga_jtag_reprogram PRIVATE DLA_MMD)

target_link_libraries(fpga_jtag_reprogram PRIVATE  ${CMAKE_DL_LIBS} de10_agilex_mmd)

install(TARGETS fpga_jtag_reprogram RUNTIME DESTINATION "bin" COMPONENT COREDLA)


add_library(system_console_mmd INTERFACE)
target_include_directories(system_console_mmd INTERFACE
                           ${CMAKE_CURRENT_SOURCE_DIR}/../../inc  # for system_console_wrapper.h
                           )

# Installs an artifact from the "platforms/ "directory into an AI Suite
# installation.
#
#   platform_install(path [TYPE DIRECTORY | SCRIPT | FILE ] [INSTALL_ON_WINDOWS]
#                    [EXCLUDE <pattern>...])
#
# The function treats `path` as directory.  Use `TYPE SCRIPT` to treat it as a
# script to ensure the permissions are set correctly and it is installed into
# "platform/scripts/".  Otherwise, use `TYPE FILE` if copying over a file.
#
# The default behaviour is to skip installation on Windows.  However, this can
# be overridden with the `INSTALL_ON_WINDOWS` option.
#
# For `TYPE DIRECTORY`, `EXCLUDE` lists glob patterns to omit from the shipped
# package (for example unit-level simulation testbenches that are not part of
# the synthesis flow).
function(platform_install path)
  set(_options INSTALL_ON_WINDOWS)
  set(_oneValueArgs TYPE)
  set(_multiValueArgs EXCLUDE)
  cmake_parse_arguments(PARSE_ARGV 1 _arg "${_options}" "${_oneValueArgs}" "${_multiValueArgs}")

  # Don't do anything if on Windows and not explicitly installing on Windows.
  if(WIN32 AND NOT _arg_INSTALL_ON_WINDOWS)
    return()
  endif()

  # Resolve the installation type.
  if(NOT DEFINED _arg_TYPE)
    set(_arg_TYPE DIRECTORY)
  endif()

  if(_arg_TYPE STREQUAL "DIRECTORY")
    # Translate each EXCLUDE glob into an install(DIRECTORY) PATTERN ... EXCLUDE.
    set(_exclude_args)
    foreach(_pattern IN LISTS _arg_EXCLUDE)
      list(APPEND _exclude_args PATTERN "${_pattern}" EXCLUDE)
    endforeach()
    install(DIRECTORY "${path}" DESTINATION "platform/" USE_SOURCE_PERMISSIONS COMPONENT EXAMPLE_DESIGNS ${_exclude_args})
  elseif(_arg_TYPE STREQUAL "SCRIPT")
    install(PROGRAMS "${path}" DESTINATION "platform/scripts/" COMPONENT EXAMPLE_DESIGNS)
  elseif(_arg_TYPE STREQUAL "FILE")
    install(FILES "${path}" DESTINATION "platform/" COMPONENT EXAMPLE_DESIGNS)
  else()
    message(FATAL_ERROR "Unknown install type: ${_arg_TYPE}")
  endif()
endfunction()

# Specify the example designs to ship with the AI Suite
platform_install(agx7_de10_pcie)
platform_install(agx7_iseries_ofs_pcie)
platform_install(agx7_iseries_ofs_pcie_spatial)
platform_install(agx7_n6001_ofs_pcie)
platform_install(agx7_soc_m2m)
platform_install(agx7_soc_s2m)
platform_install(agx7_soc_m2m_preset)
platform_install(agx7_soc_s2m_preset)
platform_install(a10_soc_m2m)
platform_install(a10_soc_s2m)
platform_install(a10_soc_m2m_preset)
platform_install(a10_soc_s2m_preset)
platform_install(agx5e_modular_jtag INSTALL_ON_WINDOWS)
platform_install(agx3c_jtag INSTALL_ON_WINDOWS)
platform_install(agx5e_modular_ofs_pcie)
platform_install(agx5e_modular_spatial_jtag)
platform_install(agx7_iseries_ddrfree)
platform_install(agx5e_modular_ddrfree)
platform_install(agx5e_modular_ddrfree_ltddrwb)
platform_install(agx5_soc_m2m)
platform_install(agx5_soc_s2m)
platform_install(agx3_soc_m2m)
platform_install(agx3_soc_s2m)

# Common SoC files shared by Agilex 5/3 SoC designs
platform_install(soc_common)

# Common OFS base project
platform_install(ofs_common)

# Common DDRfree files.  The bridge RTL is synthesized into the design, but its
# unit-level testbench is not part of the flow, so keep it out of customer drops.
platform_install(ddrfree_common EXCLUDE "tests")

# Templates and RTL used in some of the example designs
platform_install(rtl INSTALL_ON_WINDOWS)
platform_install(template INSTALL_ON_WINDOWS)

# Utility scripts used in some of the example designs
platform_install(scripts/dla_flat_compile.tcl TYPE SCRIPT INSTALL_ON_WINDOWS)
platform_install(scripts/dla_adjust_pll.tcl TYPE SCRIPT INSTALL_ON_WINDOWS)

# DE10 BSP Patch
platform_install($ENV{DLA_BSP_PATCH_DIR}/de10_bsp.patch TYPE FILE)

# - Try to find libnuma
# Once done will define:
#
# NUMA_FOUND - system has libnuma
# NUMA_INCLUDE_DIRS - include directory with numa.h
# NUMA_LIBRARIES - link with this for libnuma

find_path(NUMA_INCLUDE_DIRS
  NAMES numa.h
  PATHS
  ${LIBNUMA_ROOT}/include
  /usr/include
  /p/psg/swip/dla/resources/numactl/2.0.16/include

  )

find_library(NUMA_LIBRARIES
  NAMES numa
  PATHS
  ${LIBNUMA_ROOT}/lib
  ${LIBNUMA_ROOT}/lib64
  /usr/lib
  /usr/lib64
  /p/psg/swip/dla/resources/numactl/2.0.16/lib

  )

FIND_PACKAGE_HANDLE_STANDARD_ARGS(NUMA
                                  REQUIRED_VARS NUMA_INCLUDE_DIRS NUMA_LIBRARIES)

add_library(libnuma IMPORTED SHARED)
set_target_properties(libnuma PROPERTIES
                    IMPORTED_LOCATION ${NUMA_LIBRARIES}
                    INTERFACE_INCLUDE_DIRECTORIES ${NUMA_INCLUDE_DIRS})

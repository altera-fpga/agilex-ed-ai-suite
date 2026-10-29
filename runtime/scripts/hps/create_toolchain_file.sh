#!/bin/bash
# Copyright (C) 2018-2020 Altera Corporation
# SPDX-License-Identifier: Apache-2.0
#

# Script to create a toolchain file based off the environment
# which would have been setup by Yocto SDK env script

# Check we have at least one parameter
if [ $# != 1 ]; then
    echo "./create_toolchain_file.sh <SDK Dir>"
    exit 1
fi

SDK_DIR=$1
if [ ! -e ${SDK_DIR} ]; then
    echo "SDK Dir does not exist."
    exit 1
fi

mkdir -p ${SDK_DIR}/cmake
CMAKE_FILE=${SDK_DIR}/cmake/embedded.arm.cmake

# Source the Yocto environment to get the setup
source ${SDK_DIR}/environment-setup-*
#############################################################

echo "# Copyright (C) 2018-2020 Altera Corporation" > ${CMAKE_FILE}
echo "# SPDX-License-Identifier: Apache-2.0" >> ${CMAKE_FILE}
echo "#" >> ${CMAKE_FILE}
echo "" >> ${CMAKE_FILE}

#############################################################
# Setup OS and Processor
echo "set(CMAKE_SYSTEM_NAME Linux)" >> ${CMAKE_FILE}
# Use the OECORE_TARGET_ARCH for the SYSTEM PROCESSOR
if [ "$OECORE_TARGET_ARCH" == "arm" ]; then
    echo "set(CMAKE_SYSTEM_PROCESSOR armv7l)" >> ${CMAKE_FILE}
else
    echo "set(CMAKE_SYSTEM_PROCESSOR \"$OECORE_TARGET_ARCH\")" >> ${CMAKE_FILE}
fi
echo "" >> ${CMAKE_FILE}

#############################################################
# Setup the TOOLCHAIN
TOOLCHAIN_PREFIX=${OECORE_NATIVE_SYSROOT}/${CROSS_COMPILE}
echo "set(TOOLCHAIN_PREFIX \"$TOOLCHAIN_PREFIX\")"  >> ${CMAKE_FILE}

#############################################################
# Extract the link flags
IFS='\ ' read -r -a array <<< "${LD}"
unset "array[0]"
LINK_FLAGS="${array[@]}"

#############################################################
# Setup the CC Compiler

# Split the CC to get compiler name and flags in an array
IFS='\ ' array=($CC)
#Compiler is the first entry
C_COMPILER=`which ${array[0]}`
echo "set(CMAKE_C_COMPILER \"${C_COMPILER}\")" >> ${CMAKE_FILE}
# Remove the first entry
unset "array[0]"

echo "set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} ${array[@]} ${CFLAGS}\")" >> ${CMAKE_FILE}

echo "set(CMAKE_C_LINK_FLAGS \"\${CMAKE_C_LINK_FLAGS} ${LINK_FLAGS}\")" >> ${CMAKE_FILE}

echo "set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -Wno-error=array-bounds\")" >> ${CMAKE_FILE}
#############################################################
# Setup the CXX Compiler

# Split the CXX to get compiler name and flags in an array
IFS='\ ' array=(${CXX})

#Compiler is the first entry
CXX_COMPILER=`which ${array[0]}`
echo "set(CMAKE_CXX_COMPILER \"${CXX_COMPILER}\")" >> ${CMAKE_FILE}
# Remove the first entry
unset "array[0]"

echo "set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} ${OECORE_TUNE_CCARGS} ${KCFLAGS} -Wno-psabi\")" >> ${CMAKE_FILE}

echo "set(CMAKE_CXX_LINK_FLAGS \"\${CMAKE_CXX_LINK_FLAGS} ${LINK_FLAGS}\")" >> ${CMAKE_FILE}

# Add -Wno-error=array-bounds due to a gcc 11.3 compile error
echo "set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -Wno-error=array-bounds\")" >> ${CMAKE_FILE}

# Add -Wno-error=narrowing due to a gcc 12.2 compile error for OpenVINO
echo "set(CMAKE_CXX_FLAGS \"\${CMAKE_CXX_FLAGS} -Wno-error=narrowing\")" >> ${CMAKE_FILE}


CXXFLAGS_DEBUG=${CXXFLAGS/-O2/-O0}
echo "set(CMAKE_CXX_FLAGS_DEBUG \"${CXXFLAGS_DEBUG}\")" >> ${CMAKE_FILE}
echo "set(CMAKE_CXX_FLAGS_RELEASE \"${CXXFLAGS}\")" >> ${CMAKE_FILE}

################################################################
echo "set(ENV{CFLAGS} \${CMAKE_C_FLAGS})" >> ${CMAKE_FILE}
echo "set(ENV{CXXFLAGS} \${CMAKE_CXX_FLAGS})" >> ${CMAKE_FILE}
echo "set(ENV{CC} \${CMAKE_C_COMPILER})" >> ${CMAKE_FILE}
echo "set(ENV{CXX} \${CMAKE_CXX_COMPILER})" >> ${CMAKE_FILE}
echo "set(ENV{LDFLAGS} \${LINK_FLAGS})" >> ${CMAKE_FILE}

echo "set(CMAKE_FIND_ROOT_PATH \"${OECORE_TARGET_SYSROOT}\")" >> ${CMAKE_FILE}
echo "set(CMAKE_FIND_ROOT_PATH_MODE_PROGRAM NEVER)" >> ${CMAKE_FILE}
echo "set(CMAKE_FIND_ROOT_PATH_MODE_LIBRARY ONLY)" >> ${CMAKE_FILE}
echo "set(CMAKE_FIND_ROOT_PATH_MODE_INCLUDE ONLY)" >> ${CMAKE_FILE}
echo "set(CMAKE_FIND_ROOT_PATH_MODE_PACKAGE ONLY)" >> ${CMAKE_FILE}

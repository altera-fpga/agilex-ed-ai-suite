#!/bin/bash

# Script to unpack the Yocto SDK and setup a toolchain file
unset LD_LIBRARY_PATH

SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

TOOLCHAIN_DIR=`pwd`/embedded_arm_sdk
TOOLCHAIN_FILEDIR=${TOOLCHAIN_DIR}/cmake
TOOLCHAIN_FILE=${TOOLCHAIN_FILEDIR}/embedded.arm.cmake

# If we have a parameter then use as the poky install script
POKY_FILE=`pwd`/poky*.sh
if [ $# -gt 0 ]; then
    POKY_FILE=$1
fi

###########################################################
# If the toolchain file already exists then do nothing
# If you want to recreate then delete ${TOOLCHAIN_DIR}
if [ -e ${TOOLCHAIN_DIR} ]; then
    echo "Toolchain file already exists. ${TOOLCHAIN_DIR}"
    exit 0
fi

# Install the Yocto SDK
./$POKY_FILE -y -d ${TOOLCHAIN_DIR}
if [ $? != 0 ]; then
    echo "Failed to install Yocto SDK"
    exit 1
fi

# Create the Toolchain file
${SCRIPT_PATH}/create_toolchain_file.sh ${TOOLCHAIN_DIR}
exit $?

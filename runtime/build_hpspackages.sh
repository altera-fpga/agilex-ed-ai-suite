#!/bin/bash
set -x

# Script to build extra packages for building and running on Linux based SoC FPGAs.
# This script needs to be called prior to building the CoreDLA Runtime.
# Typical Usage :  ./build_hpspackages.sh -sb
# For Help : ./build_hpspackages.sh -h

##################################################################
# Parameters
SCRIPT_DIR=$(cd "$(dirname $0)" >/dev/null 2>&1 && pwd)
RUNTIME_ROOT_DIR=$(cd "${SCRIPT_DIR}" >/dev/null 2>&1 && pwd)

DEV_HOME=`pwd`
BUILD_DIR=$DEV_HOME/hps_packages
STAGING_DIR=$BUILD_DIR/armcpu_package

YOCTO_SDK_NAME="embedded_arm_sdk"
YOCTO_SDK="`pwd`/${YOCTO_SDK_NAME}"
TOOLCHAIN_FILE="${YOCTO_SDK}/cmake/embedded.arm.cmake"
TOOLCHAIN_PREFIX="${YOCTO_SDK}/sysroots/x86_64-pokysdk-linux/usr/bin/arm-poky-linux-gnueabi/arm-poky-linux-gnueabi-"
SYSROOT="${YOCTO_SDK}/sysroots/armv7at2hf-neon-poky-linux-gnueabi"

##############################################################
function get_toolchain_prefix()
{
    (
        unset LD_LIBRARY_PATH
        source ${YOCTO_SDK}//environment-setup-*
        IFS='\ ' array=(${CC})
        CC_PATH=`which ${array[0]}`
        echo ${CC_PATH::-3}
    )
}

function get_sdksysroot()
{
    (
        unset LD_LIBRARY_PATH
        source ${YOCTO_SDK}//environment-setup-*
        echo ${OECORE_TARGET_SYSROOT}
    )
}

#################################################################
# Functions
function fail()
{
    echo "Failed : $1"
    exit 1
}

#################################################################
get_git_repo()
{
    OUTPUT=$1
    URL=$2
    SUBMODULES=$3
    TAG=$4
    if [ ! -e ${OUTPUT} ]; then

        COMMAND="git clone $URL"
        if [ ! -z ${TAG} ]; then
            COMMAND="$COMMAND -b ${TAG}"
        else
            echo "Please provide a version number for $URL"
            exit 1
        fi

        if [ "${SUBMODULES}" == "true" ]; then
            COMMAND="${COMMAND} --recurse-submodules"
        fi

        COMMAND="${COMMAND} ${OUTPUT}"
        ${COMMAND}
    else
        echo "Repo already exists - $OUTPUT"
    fi
}


#################################################################
function build_opencv()
{
    pushd $OPENCV_HOME
        CMAKE_FLAGS="-DBUILD_opencv_apps:BOOL=OFF -DBUILD_opencv_calib3d:BOOL=OFF -DBUILD_opencv_core:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_dnn:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_features2d:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_flann:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_gapi:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_highgui:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_imgcodecs:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_imgproc:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_java_bindings_generator:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_js:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_js_bindings_generator:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_ml:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_objc_bindings_generator:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_objdetect:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_photo:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_python_bindings_generator:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_python_tests:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_stitching:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_ts:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_video:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_videoio:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_opencv_world:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_GTK:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_GTK_2_X:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_1394:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_GSTREAMER:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_PNG:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_PNG:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_JPEG:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_JPEG:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_WEBP:BOOL=OFF"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_TIFF:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_TIFF:BOOL=ON"
        # CMAKE_FLAGS="${CMAKE_FLAGS} -DWITH_TBB:BOOL=ON"
        # CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_TBB:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DBUILD_ZLIB:BOOL=ON"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DCMAKE_BUILD_TYPE=${OPENCV_BUILD_TYPE}"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DCMAKE_INSTALL_PREFIX=$OPENCV_BUILD/install"
        CMAKE_FLAGS="${CMAKE_FLAGS} -DCMAKE_STAGING_PREFIX=$STAGING_DIR/opencv"

        # For some reason, OpenCV uses the machine's native ccache
        # On SLES15, this ccache is too new for the older gcc version that we arc shell
        CMAKE_FLAGS="${CMAKE_FLAGS} -DENABLE_CCACHE:BOOL=OFF"

        cmake -B ${OPENCV_BUILD} -G "Ninja" -DCMAKE_TOOLCHAIN_FILE=${TOOLCHAIN_FILE} ${CMAKE_FLAGS}
        if [ $? != 0 ]; then
            fail "Failed to configure OPENCV"
        fi
        cmake --build ${OPENCV_BUILD} --parallel $(nproc)
        if [ $? != 0 ]; then
            fail "Failed to build OPENCV"
        fi

        cmake --install ${OPENCV_BUILD}
        if [ $? != 0 ]; then
            fail "Failed to install OPENCV"
        fi
    popd
}

#################################################################
function cleanup_tmpfile() {
    local file="$1"
    rm -rf "$file"
}

#################################################################
function build_openvino()
{
    # The cmake option ENABLE_OPENVINO_DEBUG allow OV print rich debug info,
    # we turn it on here if build type in Debug
    if [[ "$OPENVINO_BUILD_TYPE" == "Debug" ]]; then
        OV_DEBUG_FLAG="ON"
    else
        OV_DEBUG_FLAG="OFF"
    fi

    # Arm plugin build options
    export extra_cc_flags="--sysroot=${SYSROOT}"
    export extra_cxx_flags="--sysroot=${SYSROOT}"
    export extra_link_flags="--sysroot=${SYSROOT}"

    # cmake throws an "Argument list too long" error if the path is too long
    # Use a temp directory symlinked to the runtime/hps_packages directory
    # If cmake was previously run, use the same temp directory
    echo "Checking for cached path"

    # Path to generated cmake cache file that contains previously used cmake cache path
    OPENVINO_CMAKE_CACHE_FILE=$OPENVINO_HOME/build_Release/CMakeCache.txt

    # Check if cmake_install.cmake exists, indicating that cmake has previously run
    if [ -e "$OPENVINO_CMAKE_CACHE_FILE" ]; then

        # Read first 2 line of the file, which contains the previously used path
        FIRST_LINES=$(head -n 2 $OPENVINO_CMAKE_CACHE_FILE)

        PATH_REGEX='\bFor build in directory:\s+(\S+)\/hps_packages\/openvino\/build_Release'

        if [[ $FIRST_LINES =~ $PATH_REGEX ]]; then
            BUILD_DIR_TEMP=${BASH_REMATCH[1]}
            echo "Using cached temp path: $BUILD_DIR_TEMP"

            mkdir -p $BUILD_DIR_TEMP

            if [ -d $BUILD_DIR_TEMP ]; then
                ln -s $BUILD_DIR $BUILD_DIR_TEMP
                trap 'cleanup_tmpfile "$BUILD_DIR_TEMP"' EXIT
            else
                echo "mkdir command failed. Cannot create temporary build directory."
            fi
        else
            echo "Could not read path from cmake_install.cmake"
        fi
    # If cmake_install.cmake does not exist, then generate a new temp directory
    else
        # Create temporary directory
        if [ -n "$TEMPDIR" ]; then
            BUILD_DIR_TEMP=$(mktemp -d -p "$TEMPDIR")
        else
            BUILD_DIR_TEMP=$(mktemp -d)
        fi

        echo "Creating new temp directory: $BUILD_DIR_TEMP"

        if [ -z "$BUILD_DIR_TEMP" ]; then
            echo "mktemp command failed. Cannot create temporary build directory."
        else
            ln -s $BUILD_DIR $BUILD_DIR_TEMP
            trap 'cleanup_tmpfile "$BUILD_DIR_TEMP"' EXIT
        fi
    fi

    # Use local versions of cmake variables
    if [ -d "$BUILD_DIR_TEMP" ]; then
        OPENVINO_HOME_LOC=$BUILD_DIR_TEMP/hps_packages/openvino
        OPENVINO_BUILD_LOC=$OPENVINO_HOME_LOC/build_Release
        STAGING_DIR_LOC=$BUILD_DIR_TEMP/hps_packages/armcpu_package
    else
        OPENVINO_HOME_LOC=$OPENVINO_HOME
        OPENVINO_BUILD_LOC=$OPENVINO_BUILD
        STAGING_DIR_LOC=$STAGING_DIR
    fi

    # Disable OpenVINO hetero plugin. ED4 should use the CoreDLA Hetero
    pushd $OPENVINO_HOME_LOC
        cmake -G "Ninja" -B $OPENVINO_BUILD_LOC \
        -DOpenCV_DIR=$STAGING_DIR_LOC/opencv/lib/cmake -DENABLE_OPENCV=OFF \
        -DENABLE_SAMPLES=OFF \
        -DENABLE_HETERO=OFF \
        -DENABLE_AUTO=OFF \
        -DENABLE_INTEL_GNA=OFF \
        -DENABLE_INTEL_GPU=OFF \
        -DENABLE_INTEL_MYRIAD=OFF \
        -DENABLE_CPPLINT=OFF \
        -DENABLE_TEMPLATE=OFF \
        -DENABLE_TESTS=OFF -DENABLE_BEH_TESTS=OFF -DENABLE_FUNCTIONAL_TESTS=OFF \
        -DENABLE_GAPI_TESTS=OFF \
        -DENABLE_DATA=OFF -DENABLE_PROFILING_ITT=OFF \
        -DCMAKE_EXE_LINKER_FLAGS=-Wl,-rpath-link,$STAGING_DIR_LOC/opencv/lib -DCMAKE_INSTALL_LIBDIR=lib \
        -DENABLE_SSE42=OFF -DENABLE_INTEL_MYRIAD=OFF  -DENABLE_INTEL_MYRIAD_COMMON=OFF\
        -DENABLE_OPENVINO_DEBUG="${OV_DEBUG_FLAG}" \
        -DENABLE_SYSTEM_TBB=OFF \
        -DTHREADING=SEQ -DENABLE_LTO=ON \
        -DENABLE_PYTHON=OFF \
        -DENABLE_TEMPLATE=OFF \
        -DENABLE_OV_ONNX_FRONTEND=OFF \
        -DENABLE_OV_PADDLE_FRONTEND=OFF \
        -DENABLE_OV_TF_FRONTEND=OFF \
        -DENABLE_SYSTEM_PUGIXML=OFF \
        -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
        -DARM_COMPUTE_TOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX} ${OPENCV_PREFIX} \
        -Dextra_cc_flags="${extra_cc_flags}" \
        -Dextra_cxx_flags="${extra_cxx_flags}" \
        -Dextra_link_flags="${extra_link_flags}" \
        -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
        -DCMAKE_STAGING_PREFIX=$STAGING_DIR_LOC \
        -DCMAKE_PREFIX_PATH=$STAGING_DIR_LOC \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DCMAKE_BUILD_TYPE=$OPENVINO_BUILD_TYPE \
        .
        if [ $? != 0 ]; then
            fail "Failed to configure OPENVINO"
        fi

        cmake --build $OPENVINO_BUILD_LOC --parallel $(nproc)
        if [ $? != 0 ]; then
            fail "Failed to build OPENVINO"
        fi

        cmake --install ${OPENVINO_BUILD_LOC}
        if [ $? != 0 ]; then
            fail "Failed to install OPENVINO"
        fi
    popd
}

#################################################################
function build_gflags()
{
    pushd $GFLAGS_HOME
        cmake -B $GFLAGS_BUILD \
        -D BUILD_STATIC_LIBS=ON \
        -D BUILD_SHARED_LIBS=ON \
        -D BUILD_gflags_nothreads_LIBS=ON \
        -D BUILD_gflags_LIBS=ON \
        -D INSTALL_HEADERS=ON \
        -DCMAKE_POLICY_VERSION_MINIMUM=3.5 \
        -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
        -DCMAKE_INSTALL_PREFIX="${GFLAGS_HOME}/install" \
        -DCMAKE_STAGING_PREFIX=$STAGING_DIR/gflags \
        -DARM_COMPUTE_TOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX} ${OPENCV_PREFIX} \
        -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
        -Dextra_link_flags=--sysroot=${SYSROOT} \
        -DCMAKE_BUILD_TYPE=$GFLAGS_BUILD_TYPE \
        $GFLAGS_PLUGIN_HOME
        if [ $? != 0 ]; then
            fail "Failed to configure GFLAGS"
        fi

        cmake --build $GFLAGS_BUILD --parallel $(nproc)
        if [ $? != 0 ]; then
            fail "Failed to build GFLAGS"
        fi

        cmake --install $GFLAGS_BUILD
        if [ $? != 0 ]; then
            fail "Failed to install GFLAGS"
        fi
    popd
}

#################################################################
function build_audit_libstdcxx()
{
    pushd $AUDIT_LIBSTDCXX_HOME
# -D_FORTIFY_SOURCE=3  redefinied
# Excluded SDL flags
 # -fcf-protection=branch -mfunction-return=thunk -mindirect-branch=thunk -mindirect-branch-register
        cmake \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE="${AUDIT_LIBSTDCXX_BUILD_TYPE}" \
          -DCMAKE_C_VISIBILITY_PRESET="hidden" \
          -DCMAKE_CXX_VISIBILITY_PRESET="hidden" \
          -DCMAKE_C_FLAGS="-Wall -Wextra -Werror -Wconversion -Wimplicit-fallthrough -Wformat -Wformat-security -Werror=format-security -Wl,-z,noexecstack -D_GLIBCXX_ASSERTIONS -Wl,-z,relro -Wl,-z,now -fstack-protector-strong -fstack-clash-protection" \
          -DCMAKE_CXX_FLAGS="-Wall -Wextra -Werror -Wconversion -Wimplicit-fallthrough -Wformat -Wformat-security -Werror=format-security -Wl,-z,noexecstack -D_GLIBCXX_ASSERTIONS -Wl,-z,relro -Wl,-z,now -fstack-protector-strong -fstack-clash-protection" \
          -DCMAKE_INSTALL_PREFIX="${AUDIT_LIBSTDCXX_HOME}/install" \
          -DCMAKE_STAGING_PREFIX="${STAGING_DIR}/audit_libstdcxx" \
          -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
          -DARM_COMPUTE_TOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX} ${OPENCV_PREFIX} \
          -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
          -Dextra_link_flags=--sysroot=${SYSROOT} \
          -DBUILD_TESTING=OFF \
          -B ${AUDIT_LIBSTDCXX_BUILD} \
          -S ${AUDIT_LIBSTDCXX_HOME}
        if [ $? != 0 ]; then
            fail "Failed to configure audit_libstdcxx"
        fi

        cmake --build ${AUDIT_LIBSTDCXX_BUILD} --parallel $(nproc)
        if [ $? != 0 ]; then
            fail "Failed to build audit_libstdcxx"
        fi

        cmake --install ${AUDIT_LIBSTDCXX_BUILD}
        if [ $? != 0 ]; then
            fail "Failed to install audit_libstdcxx"
        fi
    popd
}
#################################################################
function build_pugixml()
{
    pushd $PUGIXML_HOME
# -D_FORTIFY_SOURCE=3  redefinied
# Excluded SDL flags
 # -Wimplicit-fallthrough -fcf-protection=branch -mfunction-return=thunk -mindirect-branch=thunk -mindirect-branch-register
        cmake \
          -G "Unix Makefiles" \
          -DCMAKE_BUILD_TYPE="${PUGIXML_HOME_BUILD_TYPE}" \
          -DCMAKE_C_VISIBILITY_PRESET="hidden" \
          -DCMAKE_CXX_VISIBILITY_PRESET="hidden" \
          -DCMAKE_C_FLAGS="-Wall -Wextra -Werror -Wconversion -Wno-implicit-fallthrough -Wformat -Wformat-security -Werror=format-security -Wl,-z,noexecstack -D_GLIBCXX_ASSERTIONS -Wl,-z,relro -Wl,-z,now -fstack-protector-strong -fstack-clash-protection -fPIC" \
          -DCMAKE_CXX_FLAGS="-Wall -Wextra -Werror -Wconversion -Wno-implicit-fallthrough -Wformat -Wformat-security -Werror=format-security -Wl,-z,noexecstack -D_GLIBCXX_ASSERTIONS -Wl,-z,relro -Wl,-z,now -fstack-protector-strong -fstack-clash-protection -fPIC" \
          -DCMAKE_POSITION_INDEPENDENT_CODE=ON \
          -DCMAKE_INSTALL_PREFIX="${PUGIXML_HOME}/install" \
          -DCMAKE_STAGING_PREFIX="${STAGING_DIR}/pugixml" \
          -DCMAKE_TOOLCHAIN_FILE="${TOOLCHAIN_FILE}" \
          -DARM_COMPUTE_TOOLCHAIN_PREFIX=${TOOLCHAIN_PREFIX} ${OPENCV_PREFIX} \
          -DCMAKE_EXPORT_NO_PACKAGE_REGISTRY=ON \
          -Dextra_link_flags=--sysroot=${SYSROOT} \
          -DBUILD_TESTING=OFF \
          -B ${PUGIXML_BUILD} \
          -S ${PUGIXML_HOME}
        if [ $? != 0 ]; then
            fail "Failed to configure pugixml"
        fi

        cmake --build ${PUGIXML_BUILD} --parallel $(nproc)
        if [ $? != 0 ]; then
            fail "Failed to build pugixml"
        fi

        cmake --install ${PUGIXML_BUILD} --component PUGIXML
        if [ $? != 0 ]; then
            fail "Failed to install pugixml"
        fi
    popd
}
#################################################################
function usage
{
    echo "$script -schbxtavodp"
    echo "Options:"
    echo "  -h Display usage"
    echo "  -s get sources"
    echo "  -b build"
    echo "  -d Build debug OpenVino"
    echo "  -c clean build directory"
    echo "  -v build only OpenCV"
    echo "  -o build only OpenVINO (Requires previous OpenCV build)"
    echo "  -a build only Audit Library"
    echo "  -l build only Pugixml Library"
    echo "  -x debug script"
}

##################################################################
# Main Script
get_source=0
do_build=0
do_clean=0

do_opencv=0
do_openvino=0
do_gflags=0
do_audit=0
do_pugixml=0

clean_staging=0

BUILD_TYPE=Release

while getopts "schbavoxpdtl" optname; do
    case "$optname" in
        h)
            usage
            exit 0
            ;;
        s)
            get_source=1
            ;;
        b)
            do_build=1
            ;;
        d)
           BUILD_TYPE=Debug
            ;;
        c)
            do_clean=1
            ;;
        a)
            do_audit=1
            ;;
        v)
            do_opencv=1
            ;;
        o)
            do_openvino=1
            ;;
        g)
            do_gflags=1
            ;;
        l)
            do_pugixml=1
            ;;
        x)
            set -x
            ;;
    esac
done
shift "$(($OPTIND -1))"


#####################################################
# Parameters
OPENCV_BUILD_TYPE=Release
OPENCV_HOME=$BUILD_DIR/opencv
OPENCV_BUILD=$OPENCV_HOME/build_$OPENCV_BUILD_TYPE

OPENVINO_BUILD_TYPE=$BUILD_TYPE
OPENVINO_HOME=$BUILD_DIR/openvino
OPENVINO_BUILD=$OPENVINO_HOME/build_$OPENVINO_BUILD_TYPE

GFLAGS_BUILD_TYPE=Release
GFLAGS_HOME=$BUILD_DIR/gflags
GFLAGS_BUILD=$GFLAGS_HOME/build_$GFLAGS_BUILD_TYPE

AUDIT_LIBSTDCXX_BUILD_TYPE=Release
AUDIT_LIBSTDCXX_HOME=$BUILD_DIR/audit_libstdcxx
AUDIT_LIBSTDCXX_BUILD=$AUDIT_LIBSTDCXX_HOME/build_$AUDIT_LIBSTDCXX_BUILD_TYPE

PUGIXML_BUILD_TYPE=Release
PUGIXML_HOME=$BUILD_DIR/pugixml
PUGIXML_BUILD=$PUGIXML_HOME/build_$PUGIXML_BUILD_TYPE


######################################################
# Setup the Yocto Toolchain

if find -maxdepth 1 -type d -name "${YOCTO_SDK_NAME}" | grep -q .; then
    echo "Using previous setup Yocto toolchain at: ${YOCTO_SDK}"
else
    if find ${DEV_HOME} -maxdepth 1 -type f -name "poky*.sh" | grep -q .; then
        echo "Found poky SDK at ${DEV_HOME}"
    elif [[ ! -z "${ED4_POKY_SDK_LOC}" ]]; then
        echo "copying poky SDK in ${ED4_POKY_SDK_LOC} to ${DEV_HOME}"
        cp ${ED4_POKY_SDK_LOC} ${DEV_HOME}/
    else
        echo "Poky SDK not found. You need to copy the poky SDK to ${DEV_HOME} or"
        echo "do: export ED4_POKY_SDK_LOC=\"path_to_your_poky_sdk\""
        exit 1
    fi
    ${RUNTIME_ROOT_DIR}/scripts/hps/setup_toolchain.sh poky*.sh
fi

TOOLCHAIN_PREFIX=`get_toolchain_prefix`
SYSROOT=`get_sdksysroot`
echo $TOOLCHAIN_PREFIX
echo $SYSROOT

if [ $? != 0 ]; then
    exit 1
fi

# If not doing individual builds then enable all
if [[ ($do_opencv -eq 0) && ($do_openvino -eq 0) && ($do_gflags -eq 0) && ($do_audit -eq 0) && ($do_pugixml -eq 0)]]; then
    do_opencv=1
    do_openvino=1
    do_gflags=1
    do_audit=1
    do_pugixml=1
    if [[ $do_clean -ne 0 ]]; then
        clean_staging=1
    fi
fi


if [[  $get_source -ne 0 ]]; then
    get_git_repo ${OPENCV_HOME} https://github.com/opencv/opencv.git true 4.8.0
    get_git_repo ${OPENVINO_HOME} https://github.com/openvinotoolkit/openvino.git true 2025.4.0
    get_git_repo ${GFLAGS_HOME} https://github.com/gflags/gflags.git false v2.2.2
    get_git_repo ${AUDIT_LIBSTDCXX_HOME} https://github.com/PeterCDMcLean/audit_libstdcxx.git false main
    rm -rf ${PUGIXML_HOME}
    cp -r ${COREDLA_ROOT}/thirdparty/pugixml ${PUGIXML_HOME}

    chmod -R u+w ${PUGIXML_HOME}
fi

if [[ $do_clean -ne 0 ]]; then
    if [[ $do_opencv -ne 0 ]]; then
        if [ -e $OPENCV_BUILD ]; then
            echo "Cleaning $OPENCV_BUILD"
            rm -r $OPENCV_BUILD
        fi
    fi

    if [[ $do_openvino -ne 0 ]]; then
        if [ -e $OPENVINO_BUILD ]; then
            echo "Cleaning $OPENVINO_BUILD"
            rm -r $OPENVINO_BUILD
        fi
    fi

    if [[ $do_gflags -ne 0 ]]; then
        if [ -e $GFLAGS_BUILD ]; then
            echo "Cleaning $GFLAGS_BUILD"
            rm -r $GFLAGS_BUILD
        fi
    fi

    if [[ $do_audit -ne 0 ]]; then
        if [ -e $AUDIT_LIBSTDCXX_BUILD ]; then
            echo "Cleaning $AUDIT_LIBSTDCXX_BUILD"
            rm -r $AUDIT_LIBSTDCXX_BUILD
        fi
    fi

    if [[ $do_pugixml -ne 0 ]]; then
        if [ -e $PUGIXML_BUILD ]; then
            echo "Cleaning $PUGIXML_BUILD"
            rm -r $PUGIXML_BUILD
        fi
    fi

    if [[ $clean_staging -ne 0 ]]; then
        if [ -e $STAGING_DIR ]; then
            echo "Cleaning $STAGING_DIR"
            rm -r $STAGING_DIR
        fi
    fi
fi

if [[ $do_build -ne 0 ]]; then
    # Check we have the build sources
    if [ ! -e $OPENCV_HOME ]; then
        fail "OPENCV Source not available"
    fi

    if [ ! -e $OPENVINO_HOME ]; then
        fail "OPENVINO Source not available"
    fi

    # Apply patches to the build and check that each applied correctly
    pushd $OPENVINO_HOME >> //dev/null
        git apply ${DEV_HOME}/patches/openvino_5cee8bbf29797f4544b343e803de957e9f041f92_gcc11.3.0.patch  2> /dev/null
    popd >> //dev/null

    if [ $? != 0 ]; then
        fail "Failed to apply patch: ${DEV_HOME}/patches/openvino_5cee8bbf29797f4544b343e803de957e9f041f92_gcc11.3.0.patch"
    fi

    pushd $OPENVINO_HOME >> //dev/null
        git apply ${DEV_HOME}/patches/flags.patch  2> /dev/null
    popd >> //dev/null

    if [ $? != 0 ]; then
        fail "Failed to apply patch: ${DEV_HOME}/patches/flags.patch"
    fi

    pushd $OPENVINO_HOME/src/plugins/intel_cpu/thirdparty/ComputeLibrary >> //dev/null
        git apply ${DEV_HOME}/patches/computelibrary.patch  2> /dev/null
    popd >> //dev/null

    if [ $? != 0 ]; then
        fail "Failed to apply patch: ${DEV_HOME}/patches/computelibrary.patch"
    fi

    if [[ $do_gflags -ne 0 ]]; then
        build_gflags
    fi
    unset gflags_ROOT
    export gflags_ROOT=${GFLAGS_HOME}/install

    if [[ $do_opencv -ne 0 ]]; then
        build_opencv
    else
        OPENCV_PREFIX="-DCMAKE_PREFIX_PATH=$OPENCV_BUILD"
    fi

    if [[ $do_openvino -ne 0 ]]; then
        build_openvino
    fi

    if [[ $do_audit -ne 0 ]]; then
        build_audit_libstdcxx
    fi

    if [[ $do_pugixml -ne 0 ]]; then
        build_pugixml
    fi
fi
exit

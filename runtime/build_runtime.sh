#!/bin/bash

#=============================================================================
# Script to build runtime plugin
#=============================================================================
GDB=0

usage()
{
    echo "Build runtime plugin"
    echo "Usage: ./build_runtime.sh [OPTIONS]"
    echo "  -h                                      Show this help"
    echo "  -cmake_debug                            Flag to compile in debug mode"
    echo "  -verbosity=INFO|WARNING|ERROR|FATAL     Enable logging at desired verbosity"
    echo "  -build_dir=<path>                       Location of the runtime build"
    echo "  -install_dir=<path>                     Location of the runtime install"
    echo "  -disable_jit                            Disable JIT execution mode - this removes dependencies on precompiled DLA libraries"
    echo "  -build_demo                             Build runtime demos"
    echo "  -target_de10_agilex                     Target the DE10 Agilex board"
    echo "  -target_agx7_i_dk                       Target the Agilex 7 I-Series board"
    echo "  -target_agx7_n6001                      Target the Agilex 7 N6001 board"
    echo "  -target_spatial_ofs_pcie                Target the Agilex 7 I-Series board for spatial IP"
    echo "  -target_agx5_jtag_spatial               Target the Agilex 5 E-Series Modular JTAG spatial example design"
    echo "  -target_agx5_e_mdk                      Target the Agilex 5 E-Series MDK board"
    echo "  -target_emulation                       Target the software emulation (aka emulator) build"
    echo "  -target_sim                             Target the simulation environment"
    echo "  -target_agx5_mdk_jtag_system_console    Target the Agilex 5 Modular Development Kit Hostless JTAG Example Design"
    echo "  -target_agx3_dev_jtag_system_console    Target the Agilex 3 Development Kit Hostless JTAG Example Design"
    echo "  -target_system_console_streaming        Target a device, with a streaming architecture, that communicates with the host via system-console"
    echo "  -hps_platform                           Target HPS-based hardware."
    echo "                                          This option should be used only via the create_hps_image.sh script"
    echo "  -hps_machine=<machine>                  Target a specific machine. Used with -hps_platform. Options: arria10 (Arria 10 SoC),"
    echo "                                          agilex7_dk_si_agi027fc (Agilex 7 SoC), agilex5_mk_a5e065bb32aes1 (Agilex 5 SoC), agilex3 (Agilex 3 SoC) [if not specified,"
    echo "                                          default is Arria 10]"
    echo "  -aot_splitter_example                   Build the aot splitter example"
    echo "  -disable_performance_profiler           Disable performance profiler in the runtime (specifically compile it out from the runtime)."
}

hidden_usage()
{
    usage
    echo "  -coredla_dir_cmake=<path>               Intended for regtest which packages coredla and runtime separately"
    echo "  -coredla_dir_lib=<path>                 Intended for regtest which packages coredla and runtime separately"
    echo "  -no_make                                Skip final make command for Klocwork"
    echo "  -polling                                Use polling instead of interrupts"
    echo "  -target_a10_pac                         Target the Arria 10 PAC [EOL 2024.1 Release]"
    echo "  -run_tests                              Runs short build tests. For Altera internal usage only."
    echo "  -glibc_header                           Force inclusion of glibc pinning header. "
    echo "                                          Use with caution if runtime binaries must be distributed to machines with differeing GLIBC versions"
}

OPT_RUNTIME_POLLING=false
OPT_DISABLE_JIT=false
OPT_BUILD_DEMO=false
OPT_RUN_TESTS=false
OPT_GLIBC_HEADER=false
RUNTIME_VERBOSITY=""
INSTALL_DIR=""
TARGET=""
CFLAGS="${CFLAGS}"
CXXFLAGS="${CXXFLAGS}"
OPT_ENABLE_PERFORMANCE_PROFILER=true

#Terrasic production BSP kernel space driver header files
TERASIC_KERNEL_HEADER_FILES="hw_host_channel.h hw_pcie_constants.h pcie_linux_driver_exports.h"

for i in "$@"; do
    case $i in
        -h | --help )                                   usage
                                                        exit
                                                        ;;
        -cmake_debug | --cmake_debug )                  GDB=1
                                                        ;;
        -verbosity=* | --verbosity=* )                  RUNTIME_VERBOSITY="-DRUNTIME_VERBOSITY=${i#*=}"
                                                        shift # pass argument=value
                                                        ;;
        -build_dir=* | --build_dir=* )                  BUILD_DIR_USER="${i#*=}"
                                                        shift
                                                        ;;
        -install_dir=* | --install_dir=* )              INSTALL_DIR="${i#*=}"
                                                        shift
                                                        ;;
        -disable_jit | --disable_jit )                  OPT_DISABLE_JIT=true
                                                        ;;
        -build_demo | --build_demo )                    OPT_BUILD_DEMO=true
                                                        ;;
        -target_de10_agilex | --target_de10_agilex )    PLATFORM_NAME="Terasic DE 10"
                                                        CMAKE_PRESET="de10_agilex"
                                                        ;;
        -target_a10_pac | --target_a10_pac )            PLATFORM_NAME="PAC A10"
                                                        CMAKE_PRESET="a10_pac"
                                                        ;;
        -target_agx7_i_dk | --target_agx7_i_dk )        PLATFORM_NAME="AGX7 ISERIES DK"
                                                        CMAKE_PRESET="agx7_i_dk"
                                                        ;;
        -target_agx7_n6001 | --target_agx7_n6001 )      PLATFORM_NAME="AGX7 N6001"
                                                        CMAKE_PRESET="agx7_n6001"
                                                        ;;
        -target_spatial_ofs_pcie | --target_spatial_ofs_pcie )
                                                        PLATFORM_NAME="AGX7 ISERIES SPATIAL"
                                                        CMAKE_PRESET="agx7_iseries_spatial"
                                                        ;;
        -target_agx5_jtag_spatial | --target_agx5_jtag_spatial )
                                                        PLATFORM_NAME="AGX5 JTAG SPATIAL"
                                                        CMAKE_PRESET="agx5_jtag_spatial"
                                                        ;;
        -target_agx5_e_mdk | --target_agx5_e_mdk )      PLATFORM_NAME="AGX5 ESERIES MDK"
                                                        CMAKE_PRESET="agx5_mdk"
                                                        ;;
        -target_emulation | --target_emulation )        PLATFORM_NAME="EMULATION"
                                                        CMAKE_PRESET="emulation"
                                                        ;;
        -target_sim | --target_sim )                    PLATFORM_NAME="EMULATION"
                                                        CMAKE_PRESET="emulation"
                                                        TARGET_SIM=1
                                                        ;;
        -target_agx5_mdk_jtag_system_console | --target_agx5_mdk_jtag_system_console ) PLATFORM_NAME="AGX5 SYSTEM CONSOLE"
                                                        OPT_RUNTIME_POLLING=true
                                                        CMAKE_PRESET="agx5_system_console"
                                                        ;;
        -target_agx3_dev_jtag_system_console | --target_agx3_dev_jtag_system_console ) PLATFORM_NAME="AGX3 SYSTEM CONSOLE"
                                                        OPT_RUNTIME_POLLING=true
                                                        CMAKE_PRESET="agx3_system_console"
                                                        ;;
        -target_system_console_streaming | --target_system_console_streaming ) PLATFORM_NAME="SYSTEM CONSOLE STREAMING"
                                                        OPT_RUNTIME_POLLING=true
                                                        CMAKE_PRESET="system_console_streaming"
                                                        ;;
        # If HPS then we disable the JIT.
        -hps_platform | --hps_platform )                PLATFORM_NAME="ARM Soc FPGA Platform"
                                                        OPT_DISABLE_JIT=true
                                                        HPS_PLATFORM_BUILD=1
                                                        OPT_RUNTIME_POLLING=true
                                                        HPS_BUILD_MACHINE="-DHPS_BUILD_MACHINE=arria10"
                                                        CMAKE_PRESET="hps_platform"
                                                        ;;
        # Specify the HPS machine. Default is Arria 10.
        -hps_machine=* | --hps_machine=* )              if [ -z ${HPS_PLATFORM_BUILD} ]; then
                                                            echo "Error: -hps_machine can only be specified with -hps_platform"
                                                            exit 1
                                                        fi
                                                        HPS_BUILD_MACHINE="-DHPS_BUILD_MACHINE=${i#*=}"
                                                        ;;
        -aot_splitter_example | --aot_splitter_example ) TARGET="dla_aot_splitter_example"
                                                         ;;
        -disable_performance_profiler | --disable_performance_profiler ) OPT_ENABLE_PERFORMANCE_PROFILER=false
                                                         ;;
        # all options below are hidden features and therefore not listed in usage()
        -hidden_help | --hidden_help )                  hidden_usage
                                                        exit
                                                        ;;
        -coredla_dir_cmake=* | --coredla_dir_cmake=* )  COREDLA_DIR_USER_CMAKE="${i#*=}"
                                                        shift
                                                        ;;
        -coredla_dir_lib=* | --coredla_dir_lib=* )      COREDLA_DIR_USER_LIB="${i#*=}"
                                                        shift
                                                        ;;
        -compiler_c_flags=* | --compiler_c_flags=* )    CFLAGS="${CFLAGS} ${i#*=}"
                                                        shift
                                                        ;;
        -compiler_cxx_flags=* | --compiler_cxx_flags=* ) CXXFLAGS="${CXXFLAGS} ${i#*=}"
                                                        shift
                                                        ;;
        -no_make | --no_make )                          SKIP_MAKE=1
                                                        ;;
        -polling | --polling )                          OPT_RUNTIME_POLLING=true
                                                        ;;
        -run_tests | --run_tests )                      OPT_RUN_TESTS=true
                                                        ;;
        -glibc_header | --glibc_header )                OPT_GLIBC_HEADER=true
                                                        ;;
        * )                                             echo "Error: Unrecognised argument: $i"
                                                        usage
                                                        exit 1
    esac
    shift
done

if [[ -z "${PLATFORM_NAME}"  ]]; then
    echo "Error: Please specify which platform to build the runtime for. Run ./build_runtime.sh -h to see usage"
    exit 1
fi

if [ "${TARGET_SIM}" = "1" ]; then
    if [ "$GDB" = "1" ]; then
        echo "Error: -cmake_debug is not supported with -target_sim"
        exit 1
    fi
fi

# Ensure the environment variables are set up correctly when the AI Suite was installed via 'pip'.
if command -v dla_env --format=bash 2>&1; then
    echo "Setting environment variables"
    $(dla_env --format=bash)
fi

# Currently runtime demos do not work with the AOT flow. Throw an error to remind the user.
if $OPT_DISABLE_JIT && $OPT_BUILD_DEMO; then
    echo "Error: Cannot build runtime demos with JIT disabled."
    exit 1
fi

if [[ -z "${COREDLA_ROOT}" ]]; then
    echo "Error: COREDLA_ROOT environment variable not set. Run init_env.sh script first."
    exit 1
fi

# if CoreDLA Config Directory is not under root check under build directory
COREDLA_DIR_CMAKE=${COREDLA_ROOT}/cmake
COREDLA_DIR_LIB=${COREDLA_ROOT}/lib

echo ${COREDLA_DIR_USER_CMAKE}

# Only need to check if cmake exists since COREDLA_ROOT/cmake and COREDLA_ROOT/lib are in same paths
if [[ ! -e "${COREDLA_DIR_CMAKE}/CoreDLATargets.cmake" && -d "${COREDLA_ROOT}/build/coredla/dla/cmake" ]]; then
    COREDLA_DIR_CMAKE=${COREDLA_ROOT}/build/coredla/dla/cmake
    COREDLA_DIR_LIB=${COREDLA_ROOT}/build/coredla/dla/lib
fi
if [ ! -z "$COREDLA_DIR_USER_CMAKE" ]; then
    COREDLA_DIR_CMAKE=${COREDLA_DIR_USER_CMAKE}
    COREDLA_DIR_LIB=${COREDLA_DIR_USER_LIB}
fi
if [ ! -d "$COREDLA_DIR_CMAKE" ]; then
   # This error should not be possible in a correctly deployed build.  It should
   # only happen in a developer environment.
   echo "Error: $COREDLA_DIR_CMAKE not found.  Did you remember to do: cd \$COREDLA_ROOT && make"
   exit 1
fi

# A deployed build has $COREDLA_ROOT/util/compiled_result/, $COREDLA_ROOT/util/transformations/,
# whereas an Intel-internal developer build has these as just $COREDLA_ROOT/compiled_result/, etc.
# Would prefer to syncrhonize these.  They could be found within cmake by ${CoreDLA_DIR}/../util/,
# but that would mean developer changes to compiled_result/ and transformations/ need a `make`
# before they are visible to the runtime build.
if [ -d "$COREDLA_ROOT"/util/transformations ]; then
   COREDLA_XUTIL_DIR="$COREDLA_ROOT"/util
else
   COREDLA_XUTIL_DIR="$COREDLA_ROOT"
fi
export COREDLA_XUTIL_DIR

if [ ! -z "${PLATFORM_NAME}" ]; then
    echo "Building runtime for ${PLATFORM_NAME}"
fi

if $OPT_BUILD_DEMO; then
    echo "Runtime demos will be built."
    if [ "$GDB" == "1" ]; then
        echo "To test the runtime demo performance, please use the release build instead."
    fi
fi

SCRIPT_DIR=$(cd "$(dirname $0)" >/dev/null 2>&1 && pwd)
RUNTIME_ROOT_DIR=$(cd "${SCRIPT_DIR}" >/dev/null 2>&1 && pwd)

cd ${RUNTIME_ROOT_DIR}

BUILD_TYPE=Release

if [ "$GDB" == "1" ]; then
    echo "Building in debug mode"
    BUILD_TYPE=Debug
fi

if [ "${TARGET_SIM}" = "1" ]; then
    BUILD_DIR=${SCRIPT_DIR}/build_SIM
else
    BUILD_DIR=${SCRIPT_DIR}/build_${BUILD_TYPE}
fi
if [ ! -z "$BUILD_DIR_USER" ]; then
    BUILD_DIR=${BUILD_DIR_USER}
fi


if [ ! -d "$BUILD_DIR" ]; then
    mkdir -p ${BUILD_DIR}
fi

# Checking the type of build
if [ "${PLATFORM_NAME}" = "Terasic DE 10" ]; then
    if [ ! -z "${AOCL_BOARD_PACKAGE_ROOT}" ]; then
        echo "Copying necessary header files from Terasic Production BSP"
        for i in $TERASIC_KERNEL_HEADER_FILES; do
            if ! cp "${AOCL_BOARD_PACKAGE_ROOT}/linux64/driver/${i}" "${RUNTIME_ROOT_DIR}/coredla_device/mmd/de10_agilex/host/"; then
                echo "Error: Unable to copy ${i} from ${AOCL_BOARD_PACKAGE_ROOT}/linux64/driver"
                exit 1
            fi
        done
    else
        echo "Error: Environment variable AOCL_BOARD_PACKAGE_ROOT must be set to the Terasic BSP path."
        exit 1
    fi
fi

if [ "${PLATFORM_NAME}" = "PAC A10" ]; then
    if [[ -z "${OPAE_SDK_ROOT}" ]]; then
        echo "Error: OPAE_SDK_ROOT environment variable not set. Run OPAE setup script before."
        echo "       If OPAE has been installed into the default location, use: export OPAE_SDK_ROOT=/usr"
        exit 1
    fi
    # Some quick checks that OPAE exists where we expect it.  Note that
    # coredla_device/mmd/dcp_a10_pac/cmake/modules/FindOPAE.cmake has some search locations
    # for OPAE hardcoded - so in reality, we will find it in /usr/ even if $OPAE_SDK_ROOT
    # points to the wrong directory; but prefer to enforce a valid $OPAE_SDK_ROOT here.
    if [ ! -f "$OPAE_SDK_ROOT/include/opae/fpga.h" -o \
            ! \( -f "$OPAE_SDK_ROOT/lib/libopae-c.so" -o -f "$OPAE_SDK_ROOT/lib64/libopae-c.so" \) ]
    then
        echo "Error: OPAE not found at location specified by OPAE_SDK_ROOT."
        exit 1
    fi

    OPAE_DIR="-DLIBOPAE-C_ROOT=${OPAE_SDK_ROOT}/"
fi

if [ "${PLATFORM_NAME}" = "AGX7 ISERIES DK" ] || [ "${PLATFORM_NAME}" = "AGX7 N6001" ]  || [ "${PLATFORM_NAME}" = "AGX5 ESERIES MDK" ] || [ "${PLATFORM_NAME}" = "AGX7 ISERIES SPATIAL" ]; then
    if [[ -z "${OPAE_SDK_ROOT}" ]]; then
        echo "Error: OPAE_SDK_ROOT environment variable not set. Run OPAE setup script before."
        echo "       If OPAE has been installed into the default location, use: export OPAE_SDK_ROOT=/usr"
        exit 1
    fi
    # Some quick checks that OPAE exists where we expect it.  Note that
    # coredla_device/mmd/ofs_pcie/cmake/modules/FindOPAE.cmake has some search locations
    # for OPAE hardcoded - so in reality, we will find it in /usr/ even if $OPAE_SDK_ROOT
    # points to the wrong directory; but prefer to enforce a valid $OPAE_SDK_ROOT here.
    if [ ! -f "$OPAE_SDK_ROOT/include/opae/fpga.h" -o \
            ! \( -f "$OPAE_SDK_ROOT/lib/libopae-c.so" -o -f "$OPAE_SDK_ROOT/lib64/libopae-c.so" \) ]
    then
        echo "Error: OPAE not found at location specified by OPAE_SDK_ROOT."
        exit 1
    fi

    OPAE_DIR="-DLIBOPAE-C_ROOT=${OPAE_SDK_ROOT}/"
fi

if [ "${PLATFORM_NAME}" = "EMULATION" ]; then
    if [ -z "${COREDLA_DIR_LIB}/libdla_emulator.so" ]; then
         # This should not happen in a correctly deployed build
        echo "The software emulator shared library libdla_emulator.so does not exist in ${COREDLA_DIR_LIB}"
        exit 1
    fi
fi

if $OPT_RUNTIME_POLLING; then
    echo "Warning: using polling instead of interrupts"
fi

if $OPT_DISABLE_JIT; then
    echo "Building without just-in-time (JIT) execution functionality"
fi

# We must specify a default for $RUNTIME_POLLING so that cmake does a rebuild if
# the polling option changes.
RUNTIME_POLLING="";
$OPT_RUNTIME_POLLING && RUNTIME_POLLING="-DRUNTIME_POLLING=1"

# We must specify a default for $DSIABLE_JIT sot hat cmake does a rebuild if the
# option changes.
DISABLE_JIT="";
$OPT_DISABLE_JIT && DISABLE_JIT="-DDISABLE_JIT=1"

# We must specify a default for $OPT_ENABLE_PERFORMANCE_PROFILER so that cmake does a rebuild if the
# option changes. Default is enabled (set to 1), only empty when explicitly disabled with -disable_performance_profiler.
PERFORMANCE_PROFILER="";
$OPT_ENABLE_PERFORMANCE_PROFILER && PERFORMANCE_PROFILER="-DOPT_ENABLE_PERFORMANCE_PROFILER=1"

# We use a default of "" for BUILD_DEMO.  This means that cmake will not force a rebuild
# if the -build_demo option is specified on a first build and then not specified on a second
# build (unless something else forces a rebuild, of course).
#
BUILD_DEMO=""
$OPT_BUILD_DEMO && BUILD_DEMO="-DBUILD_DEMO=1"

GLIBC_HEADER=""
$OPT_GLIBC_HEADER && \
  GLIBC_HEADER="-DGLIBC_HEADER=1" && \
  CFLAGS="-include ${COREDLA_ROOT}/thirdparty/glibc_version_header/force_link_glibc_2.17.h ${CFLAGS}" && \
  CXXFLAGS="-include ${COREDLA_ROOT}/thirdparty/glibc_version_header/force_link_glibc_2.17.h ${CXXFLAGS}"

# On Ubuntu18 devices demos may break with:
# "Cannot load library ... libcoreDLARuntimePlugin.so ... undefined symbol: dla_mmd_ddr_write"
# This is caused if /opt/intelFPGA_pro/quartus_19.2.0b57/hld/host/linux64/lib is in LD_LIBRARY_PATH
# The known fix is to simply remove it
# On RHEL9, lsb_release doesn't exist.
if command -v lsb_release >/dev/null 2>&1; then
  os_release=$(lsb_release -rs)
else
  # fallback, e.g. parse /etc/os-release or handle missing command
  os_release=$(grep '^VERSION_ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
fi

conflicting_dir="intelFPGA_pro/quartus_19.2.0b57/hld/host/linux64/lib"
if [[ "$os_release" == "18."* && "$OPT_BUILD_DEMO" == true && ":$LD_LIBRARY_PATH:" == *"$conflicting_dir:"* ]]; then
    echo -e "\e[91mError: Ubuntu18 runtime demo build detected. The demos may break with $conflicting_dir in the LD_LIBRARY_PATH. Please remove and recompile.\e[0m"
    exit 1
fi

if [ -z ${HPS_PLATFORM_BUILD} ]; then
    if [ -z "${COREDLA_GCC}" ]; then
        COREDLA_GCC=gcc
        COREDLA_GXX=g++
    else
        COREDLA_GXX=$(dirname $COREDLA_GCC)/g++
    fi
    # When this happens (ie: differing g++ and gcc versions), the resulting link errors can be
    # rather confusing.  Perhaps testing for this is overkill?  We used to allow an environment
    # variable override of CXX, which is what made it easier to induce the version mismatch.
    CC_VERSION=$(${COREDLA_GCC} --version | head -1 | awk '{print $NF}')
    CXX_VERSION=$(${COREDLA_GXX} --version | head -1 | awk '{print $NF}')
    if [ "$CC_VERSION" = "" -o "$CC_VERSION" != "$CXX_VERSION" ]; then
        echo "Error: ${COREDLA_GCC} version is \"$CC_VERSION\" but ${COREDLA_GXX} version is \"$CXX_VERSION\""
        echo "       Both compilers must have the same version number."
        exit 1
    fi

    set -x

    # Runtime demos will not be built by default. Use the -build_demo flag to build them.
    CC=${COREDLA_GCC} CXX=${COREDLA_GXX} CFLAGS=${CFLAGS} CXXFLAGS=${CXXFLAGS} \
      cmake --preset ${CMAKE_PRESET} ${RUNTIME_VERBOSITY} ${RUNTIME_POLLING} \
      -DCoreDLA_DIR=${COREDLA_DIR_CMAKE} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} \
      -S ${RUNTIME_ROOT_DIR} -B ${BUILD_DIR} ${DISABLE_JIT} ${BUILD_DEMO} ${GLIBC_HEADER} ${PERFORMANCE_PROFILER}

    cmake_exit_code=$?
    set +x

else
    # Setup the Yocto Toolchain
    ${RUNTIME_ROOT_DIR}/scripts/hps/setup_toolchain.sh poky*.sh
    if [ $? != 0 ]; then
        echo -e "\nNote: Directly calling build_runtime.sh --hps_platform is for internal only. "\
                "If you are building runtime for ED4, use ${RUNTIME_ROOT_DIR}/create_hps_image.sh instead.\n"
        exit 1
    fi
    TOOLCHAIN_FILE=${RUNTIME_ROOT_DIR}/embedded_arm_sdk/cmake/embedded.arm.cmake

    HPS_PACKAGES_DIR=`pwd`/hps_packages
    HPS_INSTALL_PACKAGES=${HPS_PACKAGES_DIR}/armcpu_package

    export INTEL_OPENVINO_DIR=${HPS_INSTALL_PACKAGES}
    # Check that the Local OPENVINO build has been done
    if [ ! -e ${INTEL_OPENVINO_DIR} ]; then
        echo "Error: Pre-built openvino package not found."
        echo "     : Run ./build_hpspackages.sh -sb"
        echo -e "\nNote: Directly calling build_runtime.sh --hps_platform is for internal only. "\
                "If you are building runtime for ED4, use ${RUNTIME_ROOT_DIR}/create_hps_image.sh instead.\n"
        exit 1
    fi
    # in OpenVINO 2022.3, setupvars.sh sits in ${INTEL_OPENVINO_DIR}, not in S{INTEL_OPENVINO_DIR}/bin
    source ${INTEL_OPENVINO_DIR}/setupvars.sh

    unset gflags_ROOT
    export gflags_ROOT=${HPS_INSTALL_PACKAGES}/gflags
    CMAKE_OPTIONS=-DCMAKE_STAGING_PREFIX=${HPS_INSTALL_PACKAGES}

    set -x

    CFLAGS=${CFLAGS} CXXFLAGS=${CXXFLAGS} cmake --preset ${CMAKE_PRESET} \
      ${RUNTIME_VERBOSITY} ${RUNTIME_POLLING} ${HPS_BUILD_MACHINE} \
      -DCoreDLA_DIR=${COREDLA_DIR_CMAKE} -DCMAKE_BUILD_TYPE=${BUILD_TYPE} ${DISABLE_JIT} ${BUILD_DEMO} ${CMAKE_OPTIONS} \
      -S ${RUNTIME_ROOT_DIR} -B ${BUILD_DIR} ${GLIBC_HEADER} ${PERFORMANCE_PROFILER}

    cmake_exit_code=$?
    set +x
fi

if [ $cmake_exit_code != 0 ]; then
    echo "Error: cmake failed"
    exit 1
fi

function version { echo "$@" | awk -F. '{ printf("%d%03d%03d%03d\n", $1,$2,$3,$4); }'; }
cmake_dot_version=$(cmake --version | grep 'cmake version' | awk '{print $3}')
CMAKE_PARALLEL=
if [ $(version ${cmake_dot_version} ) -ge $(version "3.12.0") ]; then
  # Check total_mem so that we are consistent between runs (even through free_mem is arguably
  # more relevant).
  total_mem=`free -g | grep Mem | awk '{print $2}'`
  if [ "$total_mem" -gt 48 ]; then
    CMAKE_PARALLEL="--parallel"
  fi
fi

# Check if we should skip the make process
if [ "$SKIP_MAKE" != "1" ]; then
    if [ "${TARGET}" != "" ]; then
        # Ensure if TARGET is dla_aot_splitter_example, then HW_PLATFORM is in {"AGX3 SYSTEM CONSOLE", "AGX5 SYSTEM CONSOLE", "Terasic DE 10"}
        if [ "${TARGET}" = "dla_aot_splitter_example" ] && \
           [ "${PLATFORM_NAME}" != "AGX3 SYSTEM CONSOLE" ] && \
           [ "${PLATFORM_NAME}" != "AGX5 SYSTEM CONSOLE" ] && \
           [ "${PLATFORM_NAME}" != "Terasic DE 10" ]; then
            echo "Error: dla_aot_splitter_example can only be built for platform flags -target_de10_agilex, -target_agx5_mdk_jtag_system_console, and -target_agx3_dev_jtag_system_console"
            exit 1
        fi
        set -x
        cmake --build ${BUILD_DIR} --target "${TARGET}" ${CMAKE_PARALLEL}
        make_result=$?
        set +x
    else
        set -x
        cmake --build ${BUILD_DIR} ${CMAKE_PARALLEL}
        make_result=$?
        set +x
    fi

    # If the build failed, exit with the make result
    if [ $make_result -ne 0 ]; then
        exit $make_result
    fi
fi

if [ "$INSTALL_DIR" != "" ]; then
    set -x
    cmake --install ${BUILD_DIR} --prefix ${INSTALL_DIR}
    make_result=$?
    set +x

    # If the install failed, exit with the make result
    if [ $make_result -ne 0 ]; then
        exit $make_result
    fi
fi

# Check if tests should be run based on OPT_RUN_TESTS variable
if [ "$OPT_RUN_TESTS" = "true" ]; then
    # linker_test.sh is internal to coredla (CI-only smoke test for OpenVINO
    # linker issues, not shipped to customers).  Look for it in priority
    # order across known consumer layouts:
    #
    #   1. Coredla CI / source tree:  $COREDLA_ROOT/runtime_internal/scripts/internal/
    #      (canonical location after the decoupling)
    #   2. Coredla CI legacy layout:  $GITHUB_WORKSPACE/runtime/scripts/internal/
    #      (pre-decoupling — kept for any consumers still on old branches)
    #   3. Local source tree of this repo (example-designs):  $RUNTIME_ROOT_DIR/scripts/internal/
    #      (legacy — used to live here before being moved to coredla/runtime_internal/.
    #      Standalone example-designs checkouts don't have it; tests are skipped.)
    LINKER_TEST_SCRIPT=""
    LINKER_TEST_CANDIDATES=()
    if [[ -n "$COREDLA_ROOT" ]]; then
        LINKER_TEST_CANDIDATES+=("$COREDLA_ROOT/runtime_internal/scripts/internal/linker_test.sh")
    fi
    if [[ -n "$GITHUB_REPOSITORY_OWNER" ]]; then
        LINKER_TEST_CANDIDATES+=(
            "$GITHUB_WORKSPACE/runtime_internal/scripts/internal/linker_test.sh"
            "$GITHUB_WORKSPACE/runtime/scripts/internal/linker_test.sh"
        )
    fi
    LINKER_TEST_CANDIDATES+=("$RUNTIME_ROOT_DIR/scripts/internal/linker_test.sh")

    for candidate in "${LINKER_TEST_CANDIDATES[@]}"; do
        if [ -f "$candidate" ]; then
            LINKER_TEST_SCRIPT="$candidate"
            break
        fi
    done

    if [ -n "$LINKER_TEST_SCRIPT" ]; then
        # Notify that the build was successful and tests are starting
        echo -e "\033[1;33mBuild successful. Running linker test ($LINKER_TEST_SCRIPT)...\033[0m"
        # Append COREDLA_DIR_LIB to LD_LIBRARY_PATH
        export LD_LIBRARY_PATH="${LD_LIBRARY_PATH:+${LD_LIBRARY_PATH}:}${COREDLA_DIR_LIB}"
        if ! "$LINKER_TEST_SCRIPT" "$BUILD_DIR" "$PLATFORM_NAME" "$OPT_DISABLE_JIT"; then
            echo "Error: Linker test script failed with a non-zero return code." >&2
            exit 1
        fi
    elif [[ -n "$GITHUB_REPOSITORY_OWNER" ]]; then
        # In CI we should always find the test.  If not, that's a setup bug.
        echo "Error: linker_test.sh not found in any of:"
        printf '  %s\n' "${LINKER_TEST_CANDIDATES[@]}"
        exit 1
    fi
fi

# If we reach this point, the build and any tests were successful
exit 0

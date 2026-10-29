#! /bin/bash
set -o errexit

#
# This script is a starter script for building an ED4 SD Card image on the HPS platform.
# This script wraps the following steps:
# 1. Build bitstreams (S2M) if specified
# 2. Build Yocto SD card image (.wic) to obtain the toolchain SDK or use prebuilt .wic.
# 3. Use the SDK to cross-build HPS packages and CoreDLA runtime
# 4. Update the .wic image with CoreDLA executable, libraries, and FPGA bitstreams

if [[ -z "${COREDLA_ROOT}" ]]; then
    echo "Error: COREDLA_ROOT environment variable not set. Run init_env.sh script first."
    exit 1
fi


SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# runtime
RUNTIME_DIR="${SCRIPT_PATH}"  # this script should always be located in runtime
RUNTIME_BUILD_TYPE="Release"  # Release or Debug. Debug will build OpenVINO and DLA in debug mode
RUNTIME_BUILD_DIR="${RUNTIME_DIR}/build_${RUNTIME_BUILD_TYPE}"
BUILD_RUNTIME_SCRIPT="${RUNTIME_DIR}/build_runtime.sh"

# hps/ can live in $COREDLA_WORK (auto-download), $COREDLA_ROOT/external
# (dev source tree), or $COREDLA_ROOT (manual copy into the install tree).
if [[ -n "${COREDLA_WORK}" && -d "${COREDLA_WORK}/hps" ]]; then
    ED4_DIR="${COREDLA_WORK}/hps"
elif [[ -d "${COREDLA_ROOT}/external/hps" ]]; then
    ED4_DIR="${COREDLA_ROOT}/external/hps"
else
    ED4_DIR="${COREDLA_ROOT}/hps"
fi
ED4_SCRIPT_DIR="${ED4_DIR}/scripts"
UPDATE_SDCARD_SCRIPT="${ED4_SCRIPT_DIR}/update_sd_card.sh"
USING_PREBUILT_YOCTO=false
UPDATE_SDCARD=false
YOCTO_DIR="${ED4_DIR}/yocto"
YOCTO_BUILD_SCRIPT="${YOCTO_DIR}/run-build.sh"
YOCTO_BUILD_DIR="${RUNTIME_DIR}/build_Yocto"
HPS_TARGET="arria10"  # default board
source "${ED4_DIR}/boards.sh"

# HPS packages
BUILD_HPSPACKAGES_SCRIPT="${RUNTIME_DIR}/build_hpspackages.sh"
HPSPACKAGES_BUILD_DIR="${RUNTIME_DIR}/hps_packages"

# Build bitstreams
BUILD_BITSTREAM=false
BUILD_BITSTREAM_SCRIPT="${COREDLA_ROOT}/bin/dla_build_example_design.py"

# Experimental
BUILD_EXPERIMENTAL_SCRIPT=${COREDLA_SOURCE_ROOT}/scripts/internal/build_experimental.sh
BUILD_EXPERIMENT_FEATURE=false

# Performance Profiler
DISABLE_PERFORMANCE_PROFILER=false

#################################################################
function usage
{
    echo -e "\nThis script is a starter script for building an ED4 SD Card image on the HPS platform."\
            "This script wraps the following steps:"\
            "\n\t1. Build an S2M bitstream of choice for Arm-based SoC (if specified)"\
            "\n\t2. Build a Yocto SD card image (.wic) and obtain the toolchain SDK."\
            "\n\t3. Use the SDK from step 2 to cross-compile dependency packages and CoreDLA runtime"\
            "\n\t4. Update the .wic image with CoreDLA runtime, libraries, and FPGA bitstream"\
            "\n"
    echo "create_hps_image.sh -o <PATH> [-f <PATH>] [-y] [-u] [-b] [-h] [-a <PATH>] [-m <Board>] [-p]"
    echo ""
    echo "Options:"
    echo -e "  -h Display usage"
    echo -e "  -c Clean the runtime directory back to its default state"
    echo -e "  -o (Required) Path to the output directory to save the updated SD card image."
    echo -e "  -u (Optional) Specify this to update the SD card .wic image at the end.  If this option is set, the DLA runtime"
    echo -e "     and the FPGA bitstream specified by -f will be written to .wic image at the end.  This option is helpful"
    echo -e "     if a user only wants to build the DLA runtime without a working bitstream. In this case, you can skip"
    echo -e "     setting -u and -f."
    echo -e "  -b (Optional) Whether to build a bitstream (S2M) using the arch file specified by -a."
    echo -e "  -a (Optional) Path to the architecture file. Required if -b is set. "
    echo -e "  -f (Optional) Path to the FPGA directory that contains the target FPGA bitstreams."
    echo -e "      This is a REQUIRED argument if at least one of the following conditions is met: "
    echo -e "      1. -u is set, i.e., update SD card with the bitstreams in this directory at the end."
    echo -e "         The directory must contain top.core.rbf top.periph.rbf;"
    echo -e "      2. -b is set, i.e., build bitstream and save to this location"
    echo -e "  -y (Optional) Path to a pre-built Yocto image directory.   If given, this script skips"
    echo -e "     building the Yocto image from scratch and use the .wic image and the poky SDK file from"
    echo -e "     this build directory instead"
    echo -e "  -m (Optional) Board.  Options: arria10 (Arria 10 SoC), agilex7_dk_si_agi027fc (Agilex 7 SoC),"
    echo -e "     mk-a5e065bb32aes1 (Agilex 5 ES modular kit), mk-a5e065bb32aea (Agilex 5 production modular kit),"
    echo -e "     dk-a3w135bm16aea (Agilex 3 SoC). Default: arria10"
    echo -e "     A Yocto MACHINE name (agilex3) is also accepted when -b and -u are not set,"
    echo -e "     or when only one board uses that MACHINE. agilex5_mk_a5e065bb32aes1 is a deprecated"
    echo -e "     alias for mk-a5e065bb32aes1. Both Agilex 5 boards use the agilex5_mk_a5e065bb32aes1 Yocto image."
    echo -e "  -p (Optional) Disable performance profiler in the runtime (specifically compile it out from the runtime)."
    echo
}

function clean_runtime()
{
    echo "Cleaning runtime directory"

    echo "rm -rf ${RUNTIME_BUILD_DIR}"
    rm -rf ${RUNTIME_BUILD_DIR}

    echo "rm -rf ${RUNTIME_DIR}/embedded_arm_sdk"
    rm -rf ${RUNTIME_DIR}/embedded_arm_sdk

    echo "rm -rf ${HPSPACKAGES_BUILD_DIR}"
    rm -rf ${HPSPACKAGES_BUILD_DIR}

    # Search for presence of Poky SDK file
    ED4_POKY_SDK_NAME="poky*.sh"
    ED4_POKY_SDK_FILE_LOC="$(find ${RUNTIME_DIR} -maxdepth 1 -type f -name ${ED4_POKY_SDK_NAME})"

    # Confirm presence of Poky SDK file and remove it
    if [ -e "${ED4_POKY_SDK_FILE_LOC}" ]; then
        echo "rm -rf ${ED4_POKY_SDK_FILE_LOC}"
        rm -rf ${ED4_POKY_SDK_FILE_LOC}
    fi
}

while getopts "hcebuf:o:y:m:a:p" optname; do
    case "$optname" in
        h)
            usage
            exit 0
            ;;
        c)
            clean_runtime
            exit 0
            ;;
        f)
            if [[ ${OPTARG} != /* ]]; then
                ED4_BITSTREAM_DIR="$(pwd)/${OPTARG}"
            else
                ED4_BITSTREAM_DIR=${OPTARG}
            fi
            ;;
        e)
            BUILD_EXPERIMENT_FEATURE=true
            ;;
        o)
            if [[ ${OPTARG} != /* ]]; then
                ED4_SDCARD_DIR="$(pwd)/${OPTARG}"
            else
                ED4_SDCARD_DIR=${OPTARG}
            fi
            ED4_ROOTFS_DIR="${ED4_SDCARD_DIR}/ed4_root"
            ED4_APP_DIR="${ED4_ROOTFS_DIR}/home/root/app"
            ;;
        u)
            UPDATE_SDCARD=true
            ;;
        b)
            BUILD_BITSTREAM=true
            ;;
        y)
            if [[ ${OPTARG} != /* ]]; then
                YOCTO_BUILD_DIR="$(pwd)/${OPTARG}"
            else
                YOCTO_BUILD_DIR=${OPTARG}
            fi
            USING_PREBUILT_YOCTO=true
            ;;
        m)
            HPS_TARGET=${OPTARG}
            ;;
        a)
            if [[ ${OPTARG} != /* ]]; then
                ARCH_FILE="$(pwd)/${OPTARG}"
            else
                ARCH_FILE=${OPTARG}
            fi
            ;;
        p)
            DISABLE_PERFORMANCE_PROFILER=true
            ;;
    esac
done

if [[ -z ${ED4_SDCARD_DIR} ]]; then
    usage
    echo "Error: -o is required"
    exit 1;
fi

# The board picks the FPGA platform and device; the Yocto image and runtime only need the MACHINE
if [[ -n "${BOARD_ALIASES[${HPS_TARGET}]}" ]]; then
    echo "Warning: ${HPS_TARGET} is deprecated; use board ${BOARD_ALIASES[${HPS_TARGET}]}"
fi
if board_lookup "${HPS_TARGET}" 2>/dev/null; then
    MACHINE=${BOARD_MACHINE}
elif [[ -n "$(boards_for_machine "${HPS_TARGET}")" && "${UPDATE_SDCARD}" == false && "${BUILD_BITSTREAM}" == false ]]; then
    MACHINE=${HPS_TARGET}
    BOARD=""
else
    usage
    board_lookup "${HPS_TARGET}" || true
    exit 1
fi
echo "Board: ${BOARD:-<none>}  Yocto MACHINE: ${MACHINE}"

if [[ "${UPDATE_SDCARD}" == true && ! -d ${ED4_BITSTREAM_DIR} && "${BUILD_BITSTREAM}" == false ]]; then
    usage
    echo "Error: -f is required and must exist if -u is set. "\
         "Add -b if you want to build bitstreams"
    exit 1;
fi

if [[ "${BUILD_BITSTREAM}" == true ]]; then
    if [[ -z ${ED4_BITSTREAM_DIR} ]]; then
        usage
        echo "Error: -f must be specified if building a bitstream"
        exit 1;
    fi
    if [[ -z ${ARCH_FILE} ]]; then
        usage
        echo "Error: -a must be specified if building a bitstream"
        exit 1;
    fi
    if [[ -d ${ED4_BITSTREAM_DIR} && "$(ls -A ${ED4_BITSTREAM_DIR})" ]]; then
        echo "Error: ${ED4_BITSTREAM_DIR} is not empty. "
        exit 1;
    fi
fi

function build_s2m_bitstream()
{
    if [ ! -f "${BUILD_BITSTREAM_SCRIPT}" ]; then
        echo "Error: Cannot find ${BUILD_BITSTREAM_SCRIPT}."
        exit 1
    fi

    echo "Building bitstream for ${BOARD}"

    ed="${BOARD_S2M_PLATFORM}"
    if [[ -z "${ed}" ]]; then
        echo "Error: no S2M platform for board ${BOARD} yet."
        exit 1
    fi

    ${BUILD_BITSTREAM_SCRIPT} build -o ${ED4_BITSTREAM_DIR} -n 1 ${ed} ${ARCH_FILE}
    BUILD_BITSTREAM_RESULT=$?
    if [ $BUILD_BITSTREAM_RESULT -eq 1 ]; then
        echo "Bitstream failed to build. "
        exit 1
    fi

    if [ "${MACHINE}" == "arria10" ]; then
        if [[ $(find ${ED4_BITSTREAM_DIR} -maxdepth 1 -name '*.periph.rbf' | wc -l) -eq 1 &&
            $(find ${ED4_BITSTREAM_DIR} -maxdepth 1 -name '*.core.rbf' | wc -l) -eq 1 ]]; then
            periph=$(find ${ED4_BITSTREAM_DIR} -maxdepth 1 -name '*.periph.rbf')
            core=$(find ${ED4_BITSTREAM_DIR} -maxdepth 1 -name '*.core.rbf')
            mv $periph "${ED4_BITSTREAM_DIR}/top.periph.rbf"
            mv $core "${ED4_BITSTREAM_DIR}/top.core.rbf"
        else
            echo "Error: You should have exactly 1 periph.rbf and 1 core.rbf in ${ED4_BITSTREAM_DIR}"
            exit 1
        fi
    else
        if [[ $(find ${ED4_BITSTREAM_DIR} -maxdepth 1 -name '*.sof' | wc -l) -eq 1 ]]; then
            top=$(find ${ED4_BITSTREAM_DIR} -maxdepth 1 -name '*.sof')
            mv $top "${ED4_BITSTREAM_DIR}/top.sof"
        else
            echo "Error: You should have exactly 1 .sof file in ${ED4_BITSTREAM_DIR}"
            exit 1
        fi
    fi
}

function build_yocto()
{
    if [ ! -f "${YOCTO_BUILD_SCRIPT}" ]; then
        echo "Error: Cannot find run-build.sh at ${YOCTO_DIR}."
        exit 1
    fi
    echo "Building Yocto for ${MACHINE}"
    if [[ "${USING_PREBUILT_YOCTO}" == false ]]; then
        umask a+rx u+rwx
    fi
    pushd $YOCTO_DIR
        # -i: build_image; -s: build_sdk, -b <build_directory>: build location
        if [[ "${USING_PREBUILT_YOCTO}" == false ]]; then
            ${YOCTO_BUILD_SCRIPT} -is -b ${YOCTO_BUILD_DIR} ${MACHINE}
        else
            echo "Using prebuilt Yocto: ${YOCTO_BUILD_DIR}"
        fi
        YOCTO_BUILD_RESULT=$?
        if [ $YOCTO_BUILD_RESULT -eq 0 ]; then
            echo "Yocto built successfully. "
            YOCTO_SDK_DIR="${YOCTO_BUILD_DIR}/build/tmp/deploy/sdk"
            export SEARCH_NAME="poky*${MACHINE}*.sh"
            export ED4_POKY_SDK_LOC="$(find ${YOCTO_SDK_DIR} -name ${SEARCH_NAME})"
            if [ ! -f "${ED4_POKY_SDK_LOC}" ]; then
                echo "Error: Cannot find the POKY SDK in ${YOCTO_SDK_DIR}. "
                exit 1
            else
                echo "The POKY SDK can be found at ${ED4_POKY_SDK_LOC}"
            fi

            # Newer versions of Yocto generate a symlink to the .wic file with an extension of .rootfs.wic
            # instead of just .wic. To keep everything working, make a copy of the file without the .rootfs extension.
            YOCTO_WIC_DIR="${YOCTO_BUILD_DIR}/build/tmp/deploy/images/${MACHINE}"
            YOCTO_WIC_FILE="coredla-image-${MACHINE}.wic"
            YOCTO_ROOTFS_WIC_FILE="coredla-image-${MACHINE}.rootfs.wic"

            # Check if the .wic file is missing
            if [ ! -f "${YOCTO_WIC_DIR}/${YOCTO_WIC_FILE}" ]; then

                # Check if the .rootfs.wic file is present
                if [ -f "${YOCTO_WIC_DIR}/${YOCTO_ROOTFS_WIC_FILE}" ]; then
                    cp -a "${YOCTO_WIC_DIR}/${YOCTO_ROOTFS_WIC_FILE}" "${YOCTO_WIC_DIR}/${YOCTO_WIC_FILE}"
                else
                    echo "Error: ${YOCTO_WIC_DIR}/${YOCTO_ROOTFS_WIC_FILE} missing"
                    exit 1
                fi
            fi

            WIC_COPY_RESULT=$?
            if [ $WIC_COPY_RESULT -eq 0 ]; then
                echo "The .wic file can be found at ${YOCTO_WIC_DIR}/${YOCTO_WIC_FILE}"
            else
                echo "Error: ${YOCTO_WIC_DIR}/${YOCTO_WIC_FILE} missing"
                exit 1
            fi

            # The same issue as above applies to the .cpio file
            YOCTO_CPIO_FILE="coredla-image-${MACHINE}.cpio"
            YOCTO_ROOTFS_CPIO_FILE="coredla-image-${MACHINE}.rootfs.cpio"

            # Check if the .cpio file is missing
            if [ ! -f "${YOCTO_WIC_DIR}/${YOCTO_CPIO_FILE}" ]; then

                # Check if the .rootfs.cpio file is present
                if [ -f "${YOCTO_WIC_DIR}/${YOCTO_ROOTFS_CPIO_FILE}" ]; then
                    cp -a "${YOCTO_WIC_DIR}/${YOCTO_ROOTFS_CPIO_FILE}" "${YOCTO_WIC_DIR}/${YOCTO_CPIO_FILE}"
                else
                    echo "Error: ${YOCTO_WIC_DIR}/${YOCTO_ROOTFS_CPIO_FILE} missing"
                    exit 1
                fi
            fi

            CPIO_COPY_RESULT=$?
            if [ $CPIO_COPY_RESULT -eq 0 ]; then
                echo "The .cpio file can be found at ${YOCTO_WIC_DIR}/${YOCTO_CPIO_FILE}"
            else
                echo "Error: ${YOCTO_WIC_DIR}/${YOCTO_CPIO_FILE} missing"
                exit 1
            fi

        else
            echo "Yocto failed to build"
            exit 1
        fi
    popd
}

function build_hpspackages()
{
    if [ ! -f "${BUILD_HPSPACKAGES_SCRIPT}" ]; then
        echo "Error: Cannot find build_hpspackages.sh at ${RUNTIME_DIR}."
        exit 1
    fi

    echo "Building hps packages..."
    pushd $RUNTIME_DIR
        if [[ $RUNTIME_BUILD_TYPE == "Release" ]]; then
            ${BUILD_HPSPACKAGES_SCRIPT} -bs  # -b: build; -s: get sources
        elif [[ $RUNTIME_BUILD_TYPE == "Debug" ]]; then
            ${BUILD_HPSPACKAGES_SCRIPT} -bds  # -b: build; -s: get sources -d: build openvino with cmake debug
        fi
        HPSPACKAGES_BUILD_RESULT=$?
        if [ $HPSPACKAGES_BUILD_RESULT -eq 0 ]; then
            echo "HPS packages built successfully. "
        else
            echo "HPS packages failed to build. "
            exit 1
        fi
    popd

}

function build_experimental() {
    # Check if the build script exists
    if [ ! -f "${BUILD_EXPERIMENTAL_SCRIPT}" ]; then
        echo "Error: Cannot find ${BUILD_EXPERIMENTAL_SCRIPT}. Build experimental features is internal only."
        exit 1
    fi

    echo "Building experiment target..."

    pushd $RUNTIME_DIR

        # Execute the build script
        COREDLA_ROOT=${COREDLA_SOURCE_ROOT} ${BUILD_EXPERIMENTAL_SCRIPT}  # add -d for developer option
        BUILD_EXPERIMENTAL_RESULT=$?

        # Check the result
        if [ $BUILD_EXPERIMENTAL_RESULT -eq 0 ]; then
            echo "Experiment target built successfully."
        else
            echo "Experiment target failed to build."
            exit 1
        fi

    popd
}

function build_hps_dla_runtime()
{
    if [ ! -f "${BUILD_RUNTIME_SCRIPT}" ]; then
        echo "Error: Cannot find build_runtime.sh at ${RUNTIME_DIR}."
        exit 1
    fi

    # arm32 or arm64 platform depends on arria10 or agilex7/agilex5/agilex3
    ARM_ARCH="armv7l"
    if [[ "${MACHINE}" == "agilex3" || "${MACHINE}" == "agilex5_mk_a5e065bb32aes1" || "${MACHINE}" == "agilex7_dk_si_agi027fc" ]]; then
        ARM_ARCH="aarch64"
    fi

    echo "Building runtime with the HPS platform..."
    pushd $RUNTIME_DIR
        if [[ $RUNTIME_BUILD_TYPE == "Release" ]]; then
            CMD="${BUILD_RUNTIME_SCRIPT} --hps_platform --hps_machine=${MACHINE} --build_dir=${RUNTIME_BUILD_DIR}"
            if [[ "${DISABLE_PERFORMANCE_PROFILER}" == true ]]; then
                CMD="${CMD} --disable_performance_profiler"
            fi
            ${CMD}
        elif [[ $RUNTIME_BUILD_TYPE == "Debug" ]]; then
            CMD="${BUILD_RUNTIME_SCRIPT} --hps_platform --hps_machine=${MACHINE} --build_dir=${RUNTIME_BUILD_DIR} -cmake_debug"
            if [[ "${DISABLE_PERFORMANCE_PROFILER}" == true ]]; then
                CMD="${CMD} --disable_performance_profiler"
            fi
            ${CMD}
        else
            echo "Unrecognized build type ${RUNTIME_BUILD_TYPE}. "
            exit 1
        fi

        RUNTIME_BUILD_RESULT=$?
        if [ $RUNTIME_BUILD_RESULT -eq 0 ]; then
            echo "DLA runtime built successfully. "
        else
            echo "DLA runtime failed to build. "
            exit 1
        fi
    popd

    # extract executable and libraries for ED4
    mkdir -p "${ED4_APP_DIR}"

    if [[ "${BUILD_EXPERIMENT_FEATURE}" == true ]]; then
        mkdir -p "${ED4_APP_DIR}/.experimental"
    fi

    pushd $ED4_APP_DIR
        # rsync is used for convenience to select/exclude files destined for the SD card
        rsync -avzP  ${RUNTIME_BUILD_DIR}/dla_benchmark/dla_benchmark .

        # OpenVINO ships libprotobuf.so but CoreDLA needs its cross-built copy (matching archparam ABI).
        rsync -avzP --exclude 'libprotobuf.so*' \
            ${HPSPACKAGES_BUILD_DIR}/openvino/bin/${ARM_ARCH}/${RUNTIME_BUILD_TYPE}/*.so* .
        rsync -avzP  ${HPSPACKAGES_BUILD_DIR}/openvino/bin/${ARM_ARCH}/Release/libopenvino_arm_cpu_plugin.so .

        rsync -avzP  ${RUNTIME_BUILD_DIR}/common/format_reader/libformat_reader.so .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/coredla_device/mmd/hps_platform/libhps_platform_mmd.so .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/hetero_plugin/libcoreDLAHeteroPlugin.so .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/hetero_plugin/libcoreDLAHeteroPlugin.so ./hetero_plugin/
        rsync -avzP  ${RUNTIME_BUILD_DIR}/compiled_result/libdla_compiled_result.so .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/compiled_result/libdla_compiled_result.so ./compiled_result/
        rsync -avzP  ${RUNTIME_BUILD_DIR}/arch/libarchparam.so .

        RUNTIME_LIBPROTOBUF_DIR=""
        for _candidate in \
            "${RUNTIME_DIR}/install/lib" \
            "${RUNTIME_BUILD_DIR}/thirdparty/protobuf/protobuf"; do
            _libprotobuf_real=$(readlink -f "${_candidate}/libprotobuf.so.3.21.12.0" 2>/dev/null || true)
            if [[ -f "${_libprotobuf_real}" ]]; then
                RUNTIME_LIBPROTOBUF_DIR="${_candidate}"
                break
            fi
        done
        if [[ -z "${RUNTIME_LIBPROTOBUF_DIR}" ]]; then
            echo "Error: CoreDLA libprotobuf.so not found under runtime/install/lib or" \
                 "${RUNTIME_BUILD_DIR}/thirdparty/protobuf/protobuf."
            exit 1
        fi
        rsync -avzP "${RUNTIME_LIBPROTOBUF_DIR}"/libprotobuf.so* .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/util/libdla_performance_profiler.so .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/libcoreDlaRuntimePlugin.so .
        rsync -avzP  ${RUNTIME_BUILD_DIR}/plugins.xml .

        rsync -avzP  --exclude libopencv_highgui.so \
                    --exclude libopencv_core.so \
                    --exclude libopencv_imgcodecs.so \
                    --exclude libopencv_imgproc.so \
                    --exclude libopencv_videoio.so \
                    ${HPSPACKAGES_BUILD_DIR}/armcpu_package/opencv/lib/*.so* .

        rsync -avzP ${RUNTIME_BUILD_DIR}/streaming/image_streaming_app/image_streaming_app .
        rsync -avzP ${RUNTIME_BUILD_DIR}/streaming/streaming_inference_app/streaming_inference_app .
        rsync -avzP ${RUNTIME_DIR}/streaming/runtime_scripts/run_image_stream.sh .
        rsync -avzP ${RUNTIME_DIR}/streaming/runtime_scripts/run_inference_stream.sh .
        rsync -avzP ${RUNTIME_DIR}/streaming/streaming_inference_app/categories.txt .

        if [[ "${BUILD_EXPERIMENT_FEATURE}" == true ]]; then
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/bin/dlac ./.experimental
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/plugins.xml ./.experimental/plugins_aot_arm.xml
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/libcoreDLAAotPlugin.so ./.experimental/
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/libarchparam.so ./.experimental/
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/libprotobuf.so* ./.experimental/
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/liblpsolve*.so ./.experimental/
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/libdla_compiler_core.so ./.experimental/
            rsync -avzP ${RUNTIME_DIR}/arm_build/coredla/dla/lib/libdla_compiled_result.so ./.experimental/
            # change the CPU plugin in plugins.xml to armPlugin
            sed -i "s/libopenvino_intel_cpu_plugin.so/libopenvino_arm_cpu_plugin.so/" ./.experimental/plugins_aot_arm.xml
        fi
        rsync -avzP ${RUNTIME_DIR}/streaming/streaming_inference_app/categories.txt .

        rsync -avzP ${COREDLA_ROOT}/build_version.txt .
        rsync -avzP ${COREDLA_ROOT}/build_os.txt .
    popd

    # Derive the .arch file from the selected MACHINE
    # Note: If the bitstream was built with an .arch file other than Performance then
    # run_inference_stream.sh will have to be updated manually
    ARCH_FILE_NAME="A10_Performance.arch"
    if [ "${MACHINE}" == "agilex7_dk_si_agi027fc" ]; then
        ARCH_FILE_NAME="AGX7_Performance_LayoutTransform.arch"
    elif [ "${MACHINE}" == "agilex5_mk_a5e065bb32aes1" ]; then
        ARCH_FILE_NAME="AGX5_Performance_LayoutTransform.arch"
    elif [ "${MACHINE}" == "agilex3" ]; then
        ARCH_FILE_NAME="AGX3_Performance.arch"
    fi

    # update the -arch flag in run_inference_stream.sh to match the selected MACHINE
    sed -i "s/A10_Performance.arch/$ARCH_FILE_NAME/" $ED4_APP_DIR/run_inference_stream.sh

    if [ "${MACHINE}" == "agilex7_dk_si_agi027fc" ] || [ "${MACHINE}" == "agilex5_mk_a5e065bb32aes1" ] || [ "${MACHINE}" == "agilex3" ]; then
        # Append flag to image_streaming_app call to skip external layout transform on AGX7.
        sed -i 's|-rate=50|& -skip_external_transform|' $ED4_APP_DIR/run_image_stream.sh

        # Check if using lightweight layout transform architecture
        # Check ARCH_FILE if provided (from -a option), otherwise check default ARCH_FILE_NAME
        IS_LIGHTWEIGHT_LT=false
        if [[ -n "${ARCH_FILE}" ]]; then
            # User provided custom arch file - check its content or name for lw_lt pattern
            if grep -q "lightweight_layout_transform_params" "${ARCH_FILE}" 2>/dev/null || [[ "${ARCH_FILE}" == *"lw_lt"* ]]; then
                IS_LIGHTWEIGHT_LT=true
            fi
        elif [[ "${ARCH_FILE_NAME}" == *"LightweightLayoutTransform"* ]]; then
            IS_LIGHTWEIGHT_LT=true
        fi

        # Only swap to folding model if NOT using lightweight layout transform
        if [ "${IS_LIGHTWEIGHT_LT}" == false ]; then
            # Change run_inference_stream to use RN50_Performance_b1.aot instead of RN50_Performance_no_folding.aot
            # AGX7 and AGX5 example designs support folding (except for lightweight layout transform)
            sed -i "s/RN50_Performance_no_folding.aot/RN50_Performance_b1.aot/" $ED4_APP_DIR/run_inference_stream.sh

            # Delete the comment about no folding
            sed -i "/# The model must be compiled with no folding/d" $ED4_APP_DIR/run_inference_stream.sh
        fi
    fi

    # Sending images at 50 FPS is too fast for AGX3, so reduce the default to 20
    if [ "${MACHINE}" == "agilex3" ]; then
        sed -i 's/-rate=50/-rate=20/' $ED4_APP_DIR/run_image_stream.sh
    fi

    # change the CPU plugin in plugins.xml to armPlugin
    sed -i "s/libopenvino_intel_cpu_plugin.so/libopenvino_arm_cpu_plugin.so/" $ED4_APP_DIR/plugins.xml
}

function update_sd_card_image()
{
    if [ ! -f "${UPDATE_SDCARD_SCRIPT}" ]; then
        echo "Error: Cannot find update_sd_card.sh at ${ED4_SCRIPT_DIR}."
        exit 1
    fi
    export SDCARD_IMAGE_LOC="$(find ${YOCTO_BUILD_DIR}/build/tmp/deploy/images -name *coredla-image-${MACHINE}.wic)"
    if [ ! -f "${SDCARD_IMAGE_LOC}" ]; then
        echo "Error: Cannot find SD Card image (.wic) at ${YOCTO_BUILD_DIR}/build/tmp/deploy/images. Have you built Yocto?."
        exit 1
    fi

    echo "Updating SD Card image..."
    pushd $ED4_SCRIPT_DIR
        ${UPDATE_SDCARD_SCRIPT} -w ${SDCARD_IMAGE_LOC} -o ${ED4_SDCARD_DIR} -f ${ED4_BITSTREAM_DIR} -r ${ED4_ROOTFS_DIR} -b ${BOARD}
        UPDATE_SDCARD_RESULT=$?
        if [ $UPDATE_SDCARD_RESULT -eq 0 ]; then
            echo "Updated SD card image successfully. "
        else
            echo "Failed to update SD card image. "
            exit 1
        fi
    popd

    if [[ $(find ${ED4_SDCARD_DIR} -name '*.wic' | wc -l) ]]; then
        echo "The .wic image can be found here:"
        echo $(find ${ED4_SDCARD_DIR} -name '*.wic')
    else
        echo "Cannot find updated .wic image in ${ED4_SDCARD_DIR}"
        exit 1
    fi
}
#################################################################


# step 0: build bitstream
if [[ "${BUILD_BITSTREAM}" == true ]]; then
    build_s2m_bitstream
fi
# step 1: build Yocto
build_yocto
# step 2: build hps packages
build_hpspackages
# step 3: build experimental features
if [[ "${BUILD_EXPERIMENT_FEATURE}" == true ]]; then
    build_experimental
fi
# step 3: build coredla runtime on the hps platform
build_hps_dla_runtime
# step 4: update the .wic image from step 1 with hps runtime and fpga bitstreams
if [[ "${UPDATE_SDCARD}" == true ]]; then
    update_sd_card_image
fi

echo "All steps succeeded"

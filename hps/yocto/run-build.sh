#!/bin/bash

# Build script used for building the Yocto Linux Image to be used by the Coredla SoC Example Designs.
# Supports building for Arria10, Agilex7, Agilex5 and Agilex3 devices.
# See "usage" for further options

SCRIPT_DIR=$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )
MACHINE="arria10"

function usage
{
    echo "$script -hiskm [arria10]"
    echo "Options:"
    echo "  -h Display usage"
    echo "  -i Build image"
    echo "  -s Build SDK"
    echo "  -b <build_dir> Path to build directory"
    echo "  -k Include Kernel Sources in SDK"
    echo "  -m <mirror> Enable Mirror"
    echo "  Default : arria10"
}

build_image=0
build_sdk=0
build_sdk_with_kernel_sources=0

# Default build directory
build_dir=./build 
while getopts "hiskm:b:" optname; do
    case "$optname" in
        h)
            usage
            exit 0
            ;;
        i)
            build_image=1
            ;;
        s)
            build_sdk=1
            ;;
        k)
            build_sdk_with_kernel_sources=1
            ;;
        b)
            build_dir=${OPTARG}
            ;;
	    m)
	        mirror=${OPTARG}
            ;;
    esac
done
shift "$(($OPTIND -1))"

#############################
# Check MACHINE is valid
#############################
if [ ! -z $* ]; then
    MACHINE=$*
    if ! [[  "${MACHINE}" == "agilex3" || "${MACHINE}" == "agilex5_mk_a5e065bb32aes1" || "${MACHINE}" == "agilex7_dk_si_agi027fc" || "${MACHINE}" == "arria10" ]]; then
        usage
        exit 1
    fi
fi
echo "[INFO] ${MACHINE} is a valid machine"

# Create the build directory
mkdir -p ${build_dir}
mkdir -p ${build_dir}/layers

# Convert the build path to the real path
build_dir=$(cd ${build_dir} && pwd)
CHECKOUT_DIR=${build_dir}/layers

#### Clone all required repos

# Get correct commit hashes
if [ ! -f ${SCRIPT_DIR}/source_revisions.sh ]; then
    echo "Cannot find source_revisions.sh in ${SCRIPT_DIR}"
    exit 1
fi
source ${SCRIPT_DIR}/source_revisions.sh

#### Init Yocto build area
source ${CHECKOUT_DIR}/poky/oe-init-build-env ${build_dir}/build

#### Configure local.conf for selected MACHINE
DEVICE_CONF=$(grep -i -o -m 1 ${MACHINE} conf/local.conf 2>/dev/null)
if [[ -z "${DEVICE_CONF}" ]]; then
    cat << EOF >> conf/local.conf
MACHINE = "${MACHINE}"
DISTRO_FEATURES:remove = " tk x11 3g wayland pulseaudio"
DISTRO_FEATURES:append = " usrmerge systemd vfat"
BB_CHECK_SSL_CERTS = "0"

# Don't include kernel in rootfs image
RDEPENDS_\${KERNEL_PACKAGE_NAME}-base = "kernel-modules"

# Remove debug libraries and executables from rootfs
INHIBIT_PACKAGE_DEBUG_SPLIT = "1"

# Archive source files
INHERIT += "archiver"
ARCHIVER_MODE[src] = "original"

EOF

    #### add layers to build
    bitbake-layers add-layer ${CHECKOUT_DIR}/meta-intel-fpga && \
    bitbake-layers add-layer $SCRIPT_DIR/meta-altera-fpga-coredla
fi

#### Do we want the kernel sources add?
if [[ $build_sdk_with_kernel_sources -ne 0 ]]; then
    KERNEL_SOURCE=$(grep -i -o -m 1 TOOLCHAIN_TARGET_TASK conf/local.conf 2>/dev/null)
    if [[ -z "${KERNEL_SOURCE}" ]]; then
        echo "[INFO] Adding Kernel Sources to the SDK"
        echo TOOLCHAIN_TARGET_TASK:append = \" kernel-devsrc\" >> conf/local.conf
    fi
fi

#### Do we want to use a mirror?
if [[ ! -z $mirror ]]; then
    if [ ! -e $mirror ]; then
       echo "Error: $mirror does not exist."
       exit 1
    fi
    MIRROR_SOURCE=$(grep -i -o -m 1 SOURCE_MIRROR_URL conf/local.conf 2>/dev/null)
    if [[ "${MIRROR_SOURCE}" ]]; then
        echo "Error: Mirror already set."
        exit 1
    fi

    echo INHERIT += \"own-mirrors\" >> conf/local.conf
    echo SOURCE_MIRROR_URL = \"file://${mirror?}\" >> conf/local.conf
    echo BB_GENERATE_MIRROR_TARBALLS = \"1\" >> conf/local.conf
fi
 
#############################
# Build commands
#############################
if [[ $build_image -ne 0 ]]; then
    echo "[INFO] Building coredla-image..."
    bitbake coredla-image
fi

if [[ $build_sdk -ne 0 ]]; then
	echo "[INFO] Building coredla-image SDK..."
    bitbake coredla-image -c populate_sdk
fi

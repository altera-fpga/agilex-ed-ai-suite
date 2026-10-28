#! /bin/bash
set -o errexit

# Script to create the Agilex 5 E-Series modular kit (agilex5e) FPGA programming files
START_PATH=`pwd`
SCRIPT_PATH="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

if [ $# -lt 4 ]; then
    echo Usage: $0 fpga_dir out_dir hex_file board
    exit 1
fi

fpga_dir=$1
out_dir=$2
hex_file=$3

source ${SCRIPT_PATH}/../boards.sh
board_lookup $4
if [[ "${BOARD_MACHINE}" != "agilex5_mk_a5e065bb32aes1" ]]; then
    echo Error - $0: ${BOARD} is not an Agilex 5 board
    exit 1
fi

jic_file=$out_dir/`basename $hex_file`.jic
sof_file=$out_dir/`basename $hex_file`.sof

echo Info - ${FUNCNAME[0]}: Add FPGA Dir $fpga_dir
if [ ! -e $fpga_dir/top.sof ]; then
    echo Error : Failed to find $fpga_dir/top.sof
    exit 2
fi

# Check that QUARTUS_ROOTDIR is set
if [ -z $QUARTUS_ROOTDIR ]; then
    echo Error - ${FUNCNAME[0]}: QUARTUS_ROOTDIR not set
    exit 2
fi

if [ ! -e $fpga_dir/top.sof ]; then
    echo Error - ${FUNCNAME[0]}: $fpga_dir/top.sof does not exist
    exit 2
fi

if [ ! -e $hex_file ]; then
    echo Error - ${FUNCNAME[0]}: $hex_file does not exist
    exit 2
fi

mkdir -p $out_dir

# determine where quartus_pfg is
QUARTUS_ROOTDIR_BIN=$QUARTUS_ROOTDIR/bin
if [[ ! -d $QUARTUS_ROOTDIR_BIN ]]; then
    if [[ ! -d $QUARTUS_ROOTDIR/bin64 ]]; then
        echo Error - ${FUNCNAME[0]}: Cannot find either bin or bin64 folder inside $QUARTUS_ROOTDIR
        exit 2
    fi
    QUARTUS_ROOTDIR_BIN=$QUARTUS_ROOTDIR/bin64
fi

# Create the JIC file for programming to the flash
$QUARTUS_ROOTDIR_BIN/quartus_pfg -c $fpga_dir/top.sof $jic_file \
-o device=${BOARD_QSPI_DEVICE} \
-o flash_loader=${BOARD_FLASH_LOADER} \
-o hps_path=$hex_file \
-o mode=ASX4
if [ $? != 0 ]; then
    echo Error - ${FUNCNAME[0]}: Failed to create JIC file.
    exit 2
fi

# Create the SOF for JTAG boot
$QUARTUS_ROOTDIR_BIN/quartus_pfg -c $fpga_dir/top.sof $sof_file \
-o hps_path=$hex_file
if [ $? != 0 ]; then
    echo Error - ${FUNCNAME[0]}: Failed to create SOF file.
    exit 2
fi

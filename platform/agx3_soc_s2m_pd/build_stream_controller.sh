#! /bin/bash

################################################################################
# In Streaming mode a NIOS-V CPU is used to control the streaming-dma engine and
# start DLA inferencing jobs.
#
# This script will launch the NIOS application compiler and generate a HEX file
# The Quartus build picks up this HEX file and embeds the Application into the
# NIOS memory.
#
# When the S2M FPGA starts up, the NIOS will automatically run from the code
# stored in the HEX file and be read for mailbox commands to be sent.
#
# There is no need to download anything to the NIOS for normal operation.
#
# During customer developmens, users can still download their own NIOS
# applications over the top of this initial image
################################################################################

quartus_project=$1
qsys_file=$2
hex_file=$3

usage()
{
    echo "Usage:"
    echo "    build_stream_controller.sh <quartus_project_file> <qsys_file> <destination_hex_file>"
}

if [ -z "$quartus_project" ]; then
    usage
    exit 1
fi

if [ -z "$qsys_file" ]; then
    usage
    exit 1
fi

if [ -z "$hex_file" ]; then
    usage
    exit 1
fi

# Get absolute path to the files
quartus_project=`readlink -f $quartus_project`
qsys_file=`readlink -f $qsys_file`
hex_file=`readlink -f $hex_file`

if [ ! -f "$quartus_project" ]; then
    echo Quartus project file not found "$quartus_project"
    usage
    exit 1
fi

if [ ! -f "$qsys_file" ]; then
    echo qsys file not found "$qsys_file"
    usage
    exit 1
fi

if [ "$COREDLA_WORK" != "" ]; then
   runtimedir="$COREDLA_WORK"
elif [ -w "$COREDLA_ROOT/runtime" ]; then
   runtimedir="$COREDLA_ROOT"
elif [ -w "$COREDLA_ROOT/external/runtime" ]; then
   runtimedir="$COREDLA_ROOT/external"
else
   echo "Error: Unable to find writeable runtime/ directory"
   echo "       Please run dla_init_local_directory.sh to setup a work directory"
   exit 1
fi

cd $runtimedir/runtime/coredla_device/stream_controller
# agx3_soc_s2m uses a 48 KB Nios V RAM (0x0-0xbfff); pass the RAM end so elf2hex
# sizes the hex to match. Other platforms keep the 0x1ffff (128 KB) default.
./build.sh "$quartus_project" "$qsys_file" "$hex_file" 0xbfff

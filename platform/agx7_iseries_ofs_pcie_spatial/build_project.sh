#!/bin/bash

# Build the Spatial example design bitstream.
# This can only run after calling 'setup_project.sh'.

set -eu

# Check OFS environment
if [ -z "${OPAE_PLATFORM_ROOT:-}" ]; then
    echo "Error: OPAE_PLATFORM_ROOT environment variable is not set."
    exit 1
fi

if [ -z "${COREDLA_ROOT:-}" ]; then
    echo "Error: COREDLA_ROOT environment variable is not set."
    exit 1
fi

OFS_BIN=$OPAE_PLATFORM_ROOT/bin

if [ ! -f "$OFS_BIN/run.sh" ]; then
    echo "Error: Could not find $OFS_BIN/run.sh"
    exit 1
fi

# Locate the Spark RTL sources (internal Altera development environment)
SPARK_PATH="$COREDLA_ROOT/build/coredla/dla/spark"
if [ ! -d "$SPARK_PATH" ]; then
    SPARK_PATH="$COREDLA_ROOT/spark"
fi
SPARK_RTL_PATH="$SPARK_PATH/rtl"

BUILD_DIR="ofs"
echo "Creating build directory: $BUILD_DIR"

# Run afu_synth_setup to set up the Quartus project
afu_synth_setup -f -s hw/sources.txt "$BUILD_DIR"

# Resolve the Quartus synthesis project directory
shopt -s nullglob
syn_top_matches=("$BUILD_DIR"/build/syn/board/*/syn_top)
shopt -u nullglob
if [ ${#syn_top_matches[@]} -ne 1 ]; then
    echo "Error: Expected exactly one syn_top directory, found ${#syn_top_matches[@]}: ${syn_top_matches[*]:-}"
    exit 1
fi
QUARTUS_PROJ_DIR=$(realpath "${syn_top_matches[0]}")
echo "  Resolved quartus_proj_dir: $QUARTUS_PROJ_DIR"

# Copy hex files
shopt -s nullglob
for hex_file in "$SPARK_RTL_PATH"/common/dsdk/*.hex; do
    cp -p "$hex_file" "$QUARTUS_PROJ_DIR/"
    echo "  copied $hex_file -> $QUARTUS_PROJ_DIR/$(basename "$hex_file")"
done
shopt -u nullglob

# Copy dump_files
if [ -d dump_files ]; then
    mkdir -p "$QUARTUS_PROJ_DIR/dump_files"
    cp -r dump_files/. "$QUARTUS_PROJ_DIR/dump_files/"
    echo "  copied dump_files -> $QUARTUS_PROJ_DIR/dump_files"
fi

# Copy latencies.vh
cp -p "$SPARK_RTL_PATH/common/include/latencies.vh" "$QUARTUS_PROJ_DIR/latencies.vh"
echo "  copied $SPARK_RTL_PATH/common/include/latencies.vh -> $QUARTUS_PROJ_DIR/latencies.vh"

echo "-- Setup complete"

source $OFS_BIN/build_env_config

echo "-- Compile bitstream"
cd ofs
$OFS_BIN/run.sh

# Remove copy of Quartus compile directory
# otherwise the QoR parser finds two copies of the report files
rm -rf ./build/quartus_proj_dir

echo "-- Build complete"
echo "   Bitstream: ofs/spark_demo.gbs"

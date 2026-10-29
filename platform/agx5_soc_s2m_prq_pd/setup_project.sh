#!/bin/bash
set -e

# Setup the Quartus project used to compile the bitstream for the
# streaming-to-memory Agilex 5 SoC example design.
#
# This script expects two arguments:
#   - The architecture IP name (e.g., AGX7_Performance_AGX7)
#   - The path to the directory containing the DLA IP RTL files

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <arch_ip_name> <dla_ip_dir>"
  exit -1
fi

ARCH_IP_NAME=$1
DLA_IP_DIR=$2

if [  -d qsys ]; then
  echo "INFO: Cleaning up old project"
  rm -Rf qsys
fi

if [  -d qdb ]; then
  echo "INFO: Cleaning up old databases"
  rm -Rf qdb
fi

# Create the Qsys system one directory down in "qsys" to keep top directory clean
mkdir qsys
cp system.tcl qsys/

# Clone DLA IPX and adjust path relative to this project.
cp $DLA_IP_DIR/altera.ipx qsys/
sed -i 's+file="+file="'../$(basename $DLA_IP_DIR)'/+g' qsys/altera.ipx

# Add additional IPs for Qsys
mkdir qsys/ip/
cp ip/f2sdram_adapter_hw.tcl qsys/ip/
cp ip/msgdma2axi4_hw.tcl qsys/ip/
cp ip/msgdma2axi4.v qsys/ip/

# Change DLA Architecture based on cmd-line configuration.
sed -i "s+AGX5_Performance_AGX5+$ARCH_IP_NAME+g" qsys/system.tcl

# Check that the architecture has layout transform configured and enabled.
# dla_build_example_design.py copies the .arch into the Quartus project (CWD).
# $DLA_IP_DIR/../hw is a fallback for older layouts.
lt_config_pattern="^\s*(lightweight_)?layout_transform_params\s*"
arch_basename="${ARCH_IP_NAME%_*}.arch"

if [ -f "$arch_basename" ]; then
  ARCH_FILE="$arch_basename"
elif [ -f "$DLA_IP_DIR/../hw/$arch_basename" ]; then
  ARCH_FILE="$DLA_IP_DIR/../hw/$arch_basename"
else
  ARCH_FILE=""
fi

if [ -n "$ARCH_FILE" ]; then
  if grep -qE "$lt_config_pattern" "$ARCH_FILE"; then
    echo "INFO: CoreDLA layout transform is enabled."
  else
    echo "ERROR: CoreDLA layout transform is not enabled in the provided architecture: ${ARCH_IP_NAME}."
    echo "This design example requires that the layout transform be enabled in the architecture\
    file to do pre-processing of feature data. Exiting."
    exit 1
  fi
else
  echo "Did not find architecture file: make sure the layout transform is enabled in the architecture ${ARCH_IP_NAME}"
  exit 1
fi

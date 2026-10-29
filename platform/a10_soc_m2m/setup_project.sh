#!/bin/bash
set -e

# Setup the Quartus project used to compile the bitstream for the
# memory-to-memory Arria 10 SoC example design.
#
# This script expects two arguments:
#   - The architecture IP name (e.g., A10_Performance_A10)
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

# Change DLA Architecture based on cmd-line configuration.
sed -i "s+A10_Performance_A10+$ARCH_IP_NAME+g" qsys/system.tcl

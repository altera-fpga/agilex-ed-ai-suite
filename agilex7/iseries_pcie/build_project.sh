#!/bin/bash

# Build the I-Series PCIe-attach example design bitstream.  This can only run
# after calling 'setup_project.sh'.

source ./ofs_build_env
init_ofs_build_env

set -eu

echo "-- Compile bitstream"
cd ofs
$OFS_BIN/run.sh


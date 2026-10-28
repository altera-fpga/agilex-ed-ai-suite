#!/bin/bash

# Setup and initialize the Spatial example design Quartus project.
# Arguments:
#   $1 - Architecture name with device family suffix ({arch}_{family})
#   $2 - Generated IP root
#   $3 - Model name (verilog/{model}_{arch}_{family}/)
#
# Run from the example design output directory (output_dir from dla_build_example_design).
#
# Environment variables:
#   COREDLA_ROOT         - Root directory of the CoreDLA/Spatial installation)

set -eu

SCRIPT_DIR=$(dirname $(realpath ${BASH_SOURCE[0]}))
exec python3 "$SCRIPT_DIR/setup_project.py" "$@"

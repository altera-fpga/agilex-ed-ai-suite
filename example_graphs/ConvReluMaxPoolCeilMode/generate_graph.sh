#!/bin/bash
# This script is an example of how to generate a small Conv + Add + Relu + MaxPool with ceil_mode = True graph
# with Pytorch.

# It is also an example of how to generate the OpenVINO Intermediate Representation (IR) of the model
# which gets inputted into dla_compiler so that a Pytorch model with MaxPool ceil_mode = True can be fully supported on the FPGA.

# Include common functions
source "$(dirname "${BASH_SOURCE[0]}")/../common_functions.sh"

TF_OR_PY=$1
check_py_or_tf $TF_OR_PY

MODEL_NAME="ConvReluMaxPoolCeilMode"
ARCH_FILE="AGX5_Generic"

# Run the Python script based on the framework
if [ "$TF_OR_PY" == "PT" ]; then
    MODEL_PYTHON_FILE="model_pt.py"
    # Check pytorch is installed
    check_package_installed torch
    check_package_installed torchvision
else
    echo "TensorFlow version is not supported for this example."
    exit 1
fi

# Check if python and convert_model exists
check_python_ovc_installed

# If both checks pass, then proceed with the script
echo "Assumes python and OVC are installed."

run_python "$MODEL_PYTHON_FILE"

echo "Compiling..."

dla_compiler "$MODEL_NAME" "$ARCH_FILE"

echo "SUCCESS, Model is supported on FPGA"
exit 0

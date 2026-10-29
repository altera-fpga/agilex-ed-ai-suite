#!/bin/bash
# This script is an example of how to generate a MLP graph with
# a TensorFlow hardsigmoid or PyTorch HardSigmoid (OpenVINO HSigmoid) on the FPGA
#
# It is also an example of how to generate the OpenVINO Intermediate Representation (IR) of the model
# which gets inputted into dla_compiler so that HardSigmoid can be ran on the FPGA
# It has equivalent PyTorch and TensorFlow graphs depending on the argument provided

source "$(dirname "${BASH_SOURCE[0]}")/../common_functions.sh"

TF_OR_PY=$1
check_py_or_tf $TF_OR_PY

MODEL_NAME="HardSigmoid"
ARCH_FILE="AGX5_Generic"

# Run the Python script based on the framework
if [ "$TF_OR_PY" == "PT" ]; then
    MODEL_PYTHON_FILE="model_pt.py"
    MODEL_FILE="HardSigmoid.onnx"
    # Check pytorch is installed
    check_package_installed torch
    check_package_installed torchvision
else
    MODEL_PYTHON_FILE="model_tf.py"
    MODEL_FILE="HardSigmoid.keras"
    # Tested with tensorflow version 2.18.0
    # Check if tensorflow is installed
    check_package_installed tensorflow
fi

# Check if python and convert_model exists
check_python_ovc_installed

# If both checks pass, then proceed with the script
echo "Assumes python and OVC are installed."

run_python "$MODEL_PYTHON_FILE"

run_python "../run_convert_model.py" "$MODEL_FILE" --framework "$TF_OR_PY" --output_name "$MODEL_NAME"

echo "Compiling..."

dla_compiler "$MODEL_NAME" "$ARCH_FILE"

echo "SUCCESS, Model is supported on FPGA"
exit 0

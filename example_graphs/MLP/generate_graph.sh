#!/bin/bash

# This file generates a folder named images (if it does not exist) and the binary input files input_0.bin to input_4999.bin if
# --in_file is left unspecified. It will also generate a classification file in correct_classifications.txt , the graph outputs file in output.txt,
# and the MLP graph in model.onnx from model_pt.py or in ./model from model_tf.py
#
# It is also an example of how to generate the OpenVINO Intermediate Representation (IR) of the model
# which gets inputted into dla_compiler so that this MLP graph can be ran on the FPGA
# It has equivalent PyTorch and TensorFlow graphs depending on the argument provided
#
# For further usage details, use -h or reference convert_model_README.md

# Include common functions
source "$(dirname "${BASH_SOURCE[0]}")/../common_functions.sh"

TF_OR_PY=$1
check_py_or_tf $TF_OR_PY

MODEL_NAME="model"
ARCH_FILE="AGX5_Generic"

# Run the Python script based on the framework
if [ "$TF_OR_PY" == "PT" ]; then
    MODEL_PYTHON_FILE="model_pt.py"
    MODEL_FILE="model.onnx"
    # Check pytorch is installed
    check_package_installed torch
    check_package_installed torchvision
else
    MODEL_PYTHON_FILE="model_tf.py"
    MODEL_FILE="model.keras"
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

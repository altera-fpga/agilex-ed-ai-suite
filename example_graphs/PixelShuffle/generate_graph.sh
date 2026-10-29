#!/bin/bash
# This script is an example of how to generate a MLP graph
# with PyTorch's PixelShuffle or TensorFlow DepthToSpace on the FPGA

# It is also an example of how to generate the OpenVINO Intermediate Representation (IR) of the model
# which gets inputted into dla_compiler so that
# PyTorch PixelShuffle with supported block sizes can be ran on the FPGA

# Include common functions
source "$(dirname "${BASH_SOURCE[0]}")/../common_functions.sh"

TF_OR_PY=$1
check_py_or_tf $TF_OR_PY
ARCH_FILE="AGX5_Generic"

# Run the Python script based on the framework
if [ "$TF_OR_PY" == "PT" ]; then
    MODEL_PYTHON_FILE="model_pt.py"
    MODEL_NAME="PixelShuffle"
    # Check pytorch is installed
    check_package_installed torch
    check_package_installed torchvision
else
    MODEL_PYTHON_FILE="model_tf.py"
    MODEL_NAME="DepthToSpace"
    # Tested with tensorflow version 2.18.0
    # Check if tensorflow is installed
    check_package_installed tensorflow
fi

# Check if python and ovc (convert_model) exists
check_python_ovc_installed

# If both checks pass, then proceed with the script
echo "Assumes python and OVC are installed."

# Run the Python script with different block_size supported factors
for factor in 2 4 8; do

    run_python "$MODEL_PYTHON_FILE" "$factor"

    if [ "$TF_OR_PY" == "PT" ]; then
        MODEL_FILE="${MODEL_NAME}_${factor}.onnx"
    else
        MODEL_FILE="${MODEL_NAME}_${factor}.keras"
    fi

    run_python "../run_convert_model.py" "$MODEL_FILE" --framework "$TF_OR_PY" --output_name "${MODEL_NAME}_${factor}"

    echo "Compiling..."

    dla_compiler "${MODEL_NAME}_${factor}" "$ARCH_FILE"

    echo "SUCCESS, $MODEL_NAME Model with block_size=$factor is supported on FPGA"
done

exit 0

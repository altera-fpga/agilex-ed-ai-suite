#!/bin/bash

# Function to check if a package is installed
check_package_installed() {
    package_name=$1
    if pip3 list | grep -q "^${package_name} "; then
        echo "${package_name} is installed."
    else
        echo "${package_name} is not installed. Please install first"
        exit 1
    fi

    return 0  # Return success if everything passed
}

# Function to check if python and OpenVINO convert_model (OVC) is installed.
# On OpenVINO 2025.x, convert_model is a top-level export, not openvino.convert_model.
check_python_ovc_installed() {
    # Check if Python is installed
    if ! command -v python3 &> /dev/null; then
        echo "Python is not installed. Please install Python 3."
        exit 1
    fi

    if ! python3 -c "from openvino import convert_model" &> /dev/null; then
        echo "OpenVINO convert_model is not available. Please install the OpenVINO Python package."
        exit 1
    fi

    return 0  # Return success if everything passed
}

# Function to check if pytorch or tensorflow argument passed in
check_py_or_tf() {
    # Check if no argument was passed
    if [ $# -eq 0 ]; then
        echo "No argument supplied. Please run generate_graph.sh with either 'PT' for PyTorch or 'TF' for TensorFlow"
        exit 1
    fi
    # Check if the argument is either PY or TF
    if [ "$1" == "PT" ]; then
        echo "Running generate_graph.sh for PyTorch model..."
        # Insert your PyTorch graph generation commands here
    elif [ "$1" == "TF" ]; then
        echo "Running generate_graph.sh for TensorFlow model..."
        # Insert your TensorFlow graph generation commands here
    else
        echo "Invalid argument: $1. Please specify 'PT' for PyTorch or 'TF' for TensorFlow."
        exit 1
    fi

    return 0  # Return success if everything passed
}

# Function to print and run a command
print_and_run_cmd() {
    CMD=$1
    GREP_PATTERN=${2-}  # Optional grep pattern
    echo "====================================================================="
    echo " Running ${CMD} ..."
    echo "====================================================================="
    OUTPUT=$(eval ${CMD})
    CMD_EXIT_CODE=$?  # Capture the exit code of the command

    # Print the captured output
    echo "$OUTPUT"

    if [[ $CMD_EXIT_CODE -ne 0 ]]; then
        echo "$CMD FAILED"
        return $CMD_EXIT_CODE  # Return the command's exit code if it failed
    elif [[ ! -z "$GREP_PATTERN" ]]; then
        # Proceed with grep for single FPGA subgraph only if the command was successful
        echo "$OUTPUT" | grep -q "$GREP_PATTERN"
        GREP_EXIT_CODE=$?
        if [[ $GREP_EXIT_CODE -ne 0 ]]; then
            echo "A single FPGA subgraph is NOT generated"
            return 1
        fi
    fi

    return 0  # Return success if everything passed
}

# Function to that compiles IR from OpenVINO
dla_compiler() {
    MODEL=$1
    ARCH=$2
    # IF $COREDLA_ROOT/bin/dla_compiler exists use that
    # Else, use $COREDLA_ROOT/build/coredla/dla/bin/dla_compiler
    if [ -f "$COREDLA_ROOT/bin/dla_compiler" ]; then
        DLA_COMPILER_PATH="$COREDLA_ROOT/bin/dla_compiler"
        ARCHITECTURE_PATH="$COREDLA_ROOT/example_architectures/$ARCH.arch"
    else
        DLA_COMPILER_PATH="$COREDLA_ROOT/build/coredla/dla/bin/dla_compiler"
        ARCHITECTURE_PATH="$COREDLA_ROOT/build/example_architectures/$ARCH.arch"
    fi
    if [ ! -f "$DLA_COMPILER_PATH" ]; then
        echo "dla_compiler not found at $DLA_COMPILER_PATH."
        exit 1
    fi
    if [ ! -f "$ARCHITECTURE_PATH" ]; then
        echo "Architecture file not found at $ARCHITECTURE_PATH. Please check the architecture name."
        exit 1
    fi
    # Compile using dla_compiler and see if graph is implemented in a single FPGA subgraph
    CMD="$DLA_COMPILER_PATH --network-file ./output/$MODEL.xml --march $ARCHITECTURE_PATH --dumpdir --overwrite-output-files"
    FPGA_SUPPORT_PATTERN="1 subgraph(s), FPGA"
    print_and_run_cmd "$CMD" "$FPGA_SUPPORT_PATTERN"
    EXIT_CODE=$?

    # Check if compiled successfully
    if [[ ${EXIT_CODE} -ne 0 ]]; then
        echo "FLOW FAILED at dla_compiler stage"
        exit 1
    fi

    return 0  # Return success if everything passed
}

# Function to execute the python script
run_python() {
    PYTHON_FILE=$1
    shift  # Shift the position to handle additional arguments in "$@"

    # Run the Python script with all additional arguments
    CMD="python3 $PYTHON_FILE $@"
    print_and_run_cmd "$CMD"
    EXIT_CODE=$?

    # Check if the Python script exited successfully
    if [[ ${EXIT_CODE} -ne 0 ]]; then
        echo "FLOW FAILED at python3 stage"
        exit 1
    fi

    return 0  # Return success if everything passed
}

@echo off
:: This script is an example of how to generate a MLP graph
:: with PyTorch's PixelShuffle or TensorFlow DepthToSpace on the FPGA
::
:: It is also an example of how to generate the OpenVINO Intermediate Representation (IR) of the model
:: which gets inputted into dla_compiler so that
:: PyTorch PixelShuffle with supported block sizes can be ran on the FPGA

cd /d "%~dp0"

if not defined COREDLA_ROOT (
    echo COREDLA_ROOT is not set. Please run setupvars.bat first.
    exit /b 1
)

set "CF=%~dp0..\common_functions.bat"

set "TF_OR_PT=%~1"
call "%CF%" :check_py_or_tf "%TF_OR_PT%"
if errorlevel 1 exit /b 1

set "ARCH_FILE=AGX5_Generic"

if /i "%TF_OR_PT%"=="PT" (
    set "MODEL_PYTHON_FILE=model_pt.py"
    set "MODEL_NAME=PixelShuffle"
    call "%CF%" :check_package_installed torch
    if errorlevel 1 exit /b 1
    call "%CF%" :check_package_installed torchvision
    if errorlevel 1 exit /b 1
) else (
    set "MODEL_PYTHON_FILE=model_tf.py"
    set "MODEL_NAME=DepthToSpace"
    :: Tested with tensorflow version 2.18.0
    call "%CF%" :check_package_installed tensorflow
    if errorlevel 1 exit /b 1
)

:: Check if python and ovc (convert_model) exists
call "%CF%" :check_python_ovc_installed
if errorlevel 1 exit /b 1

echo Assumes python and OVC are installed.

setlocal enabledelayedexpansion
for %%F in (2 4 8) do (
    echo =====================================================================
    echo  Running python !MODEL_PYTHON_FILE! %%F ...
    echo =====================================================================
    python "!MODEL_PYTHON_FILE!" %%F
    if errorlevel 1 (
        echo FLOW FAILED at python stage
        exit /b 1
    )

    if /i "!TF_OR_PT!"=="PT" (
        set "MODEL_FILE=!MODEL_NAME!_%%F.onnx"
    ) else (
        set "MODEL_FILE=!MODEL_NAME!_%%F.keras"
    )

    echo =====================================================================
    echo  Running python ..\run_convert_model.py !MODEL_FILE! --framework !TF_OR_PT! --output_name !MODEL_NAME!_%%F ...
    echo =====================================================================
    python "..\run_convert_model.py" "!MODEL_FILE!" --framework "!TF_OR_PT!" --output_name "!MODEL_NAME!_%%F"
    if errorlevel 1 (
        echo FLOW FAILED at python stage
        exit /b 1
    )

    echo Compiling...

    call "%CF%" :dla_compiler "!MODEL_NAME!_%%F" "%ARCH_FILE%"
    if errorlevel 1 exit /b 1

    echo SUCCESS, !MODEL_NAME! Model with block_size=%%F is supported on FPGA
)

exit /b 0

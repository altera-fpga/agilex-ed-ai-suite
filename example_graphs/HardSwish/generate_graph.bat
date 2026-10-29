@echo off
:: This script is an example of how to generate a MLP graph
:: with PyTorch's HardSwish or TensorFlow's HardSwish (equivalent OpenVINO HSwish)
::
:: It is also an example of how to generate the OpenVINO Intermediate Representation (IR) of the model
:: which gets inputted into dla_compiler so that HardSwish can be ran on the FPGA
:: It has equivalent PyTorch and TensorFlow graphs depending on the argument provided

cd /d "%~dp0"

if not defined COREDLA_ROOT (
    echo COREDLA_ROOT is not set. Please run setupvars.bat first.
    exit /b 1
)

set "CF=%~dp0..\common_functions.bat"

set "TF_OR_PT=%~1"
call "%CF%" :check_py_or_tf "%TF_OR_PT%"
if errorlevel 1 exit /b 1

set "MODEL_NAME=HardSwish"
set "ARCH_FILE=AGX5_Generic"

if /i "%TF_OR_PT%"=="PT" (
    set "MODEL_PYTHON_FILE=model_pt.py"
    set "MODEL_FILE=HardSwish.onnx"
    call "%CF%" :check_package_installed torch
    if errorlevel 1 exit /b 1
    call "%CF%" :check_package_installed torchvision
    if errorlevel 1 exit /b 1
) else (
    set "MODEL_PYTHON_FILE=model_tf.py"
    set "MODEL_FILE=HardSwish.keras"
    :: Tested with tensorflow version 2.18.0
    call "%CF%" :check_package_installed tensorflow
    if errorlevel 1 exit /b 1
)

call "%CF%" :check_python_ovc_installed
if errorlevel 1 exit /b 1

echo Assumes python and OVC are installed.

echo =====================================================================
echo  Running python %MODEL_PYTHON_FILE% ...
echo =====================================================================
python "%MODEL_PYTHON_FILE%"
if errorlevel 1 (
    echo FLOW FAILED at python stage
    exit /b 1
)

echo =====================================================================
echo  Running python ..\run_convert_model.py %MODEL_FILE% --framework %TF_OR_PT% --output_name %MODEL_NAME% ...
echo =====================================================================
python "..\run_convert_model.py" "%MODEL_FILE%" --framework "%TF_OR_PT%" --output_name "%MODEL_NAME%"
if errorlevel 1 (
    echo FLOW FAILED at python stage
    exit /b 1
)

echo Compiling...

call "%CF%" :dla_compiler "%MODEL_NAME%" "%ARCH_FILE%"
if errorlevel 1 exit /b 1

echo SUCCESS, Model is supported on FPGA
exit /b 0

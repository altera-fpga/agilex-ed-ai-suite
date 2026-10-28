@echo off
:: Windows equivalent of common_functions.sh.
:: Called by generate_graph.bat files via:
::   call "%~dp0..\common_functions.bat" :<function_name> [args...]

if "%~1"=="" exit /b 0
goto %~1

:: ─── check_package_installed ─────────────────────────────────────────────────
:: Usage: call common_functions.bat :check_package_installed <package>
:check_package_installed
where python >nul 2>&1
if errorlevel 1 (
    echo Python is not installed. Please install Python 3.
    exit /b 1
)
python -c "import %~2" >nul 2>&1
if errorlevel 1 (
    echo %~2 is not installed. Please install first
    exit /b 1
)
echo %~2 is installed.
exit /b 0

:: ─── check_python_ovc_installed ──────────────────────────────────────────────
:: Usage: call common_functions.bat :check_python_ovc_installed
:check_python_ovc_installed
where python >nul 2>&1
if errorlevel 1 (
    echo Python is not installed. Please install Python 3.
    exit /b 1
)
python -c "from openvino import convert_model" >nul 2>&1
if errorlevel 1 (
    echo OpenVINO convert_model is not available. Please install the OpenVINO Python package.
    exit /b 1
)
exit /b 0

:: ─── check_py_or_tf ──────────────────────────────────────────────────────────
:: Usage: call common_functions.bat :check_py_or_tf <PT|TF>
:check_py_or_tf
if "%~2"=="" (
    echo No argument supplied. Please run generate_graph.bat with either 'PT' for PyTorch or 'TF' for TensorFlow.
    exit /b 1
)
if /i "%~2"=="PT" (
    echo Running generate_graph.bat for PyTorch model...
    exit /b 0
)
if /i "%~2"=="TF" (
    echo Running generate_graph.bat for TensorFlow model...
    exit /b 0
)
echo Invalid argument: %~2. Please specify 'PT' for PyTorch or 'TF' for TensorFlow.
exit /b 1

:: ─── dla_compiler ────────────────────────────────────────────────────────────
:: Usage: call common_functions.bat :dla_compiler <model_name> <arch_file>
:dla_compiler
setlocal enabledelayedexpansion
set "_MODEL=%~2"
set "_ARCH=%~3"
set "_DLA_COMPILER="
set "_ARCH_PATH="

if exist "%COREDLA_ROOT%\bin\dla_compiler.py" (
    set "_DLA_COMPILER=%COREDLA_ROOT%\bin\dla_compiler.py"
    set "_ARCH_PATH=%COREDLA_ROOT%\example_architectures\%_ARCH%.arch"
) else if exist "%COREDLA_ROOT%\build\coredla\dla\bin\dla_compiler.py" (
    set "_DLA_COMPILER=%COREDLA_ROOT%\build\coredla\dla\bin\dla_compiler.py"
    set "_ARCH_PATH=%COREDLA_ROOT%\build\example_architectures\%_ARCH%.arch"
)

if not defined _DLA_COMPILER (
    echo dla_compiler not found under %COREDLA_ROOT%.
    exit /b 1
)
if not exist "%_ARCH_PATH%" (
    echo Architecture file not found at %_ARCH_PATH%. Please check the architecture name.
    exit /b 1
)

set "_DLA_OUT=%TEMP%\dla_out_%RANDOM%.txt"
echo =====================================================================
echo  Running python "%_DLA_COMPILER%" --network-file .\output\%_MODEL%.xml --march "%_ARCH_PATH%" --dumpdir --overwrite-output-files ...
echo =====================================================================
python "%_DLA_COMPILER%" --network-file ".\output\%_MODEL%.xml" --march "%_ARCH_PATH%" --dumpdir --overwrite-output-files > "%_DLA_OUT%" 2>&1
set _DLA_EXIT=%errorlevel%
type "%_DLA_OUT%"

if %_DLA_EXIT% neq 0 (
    del "%_DLA_OUT%" 2>nul
    echo FLOW FAILED at dla_compiler stage
    exit /b 1
)
findstr /c:"1 subgraph(s), FPGA" "%_DLA_OUT%" >nul 2>&1
set _GREP_EXIT=%errorlevel%
del "%_DLA_OUT%" 2>nul
if %_GREP_EXIT% neq 0 (
    echo A single FPGA subgraph is NOT generated
    exit /b 1
)
exit /b 0

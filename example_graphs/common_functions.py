#!/usr/bin/env python3
"""
Common helper functions for example_graphs scripts.
Cross-platform equivalent of common_functions.sh — works on Windows and Linux.
"""

import importlib.util
import os
import subprocess
import sys
from pathlib import Path


def check_package_installed(package_name: str) -> None:
    """Check that a Python package is importable (mirrors check_package_installed)."""
    if importlib.util.find_spec(package_name) is None:
        print(f"{package_name} is not installed. Please install first")
        sys.exit(1)
    print(f"{package_name} is installed.")


def check_python_ovc_installed() -> None:
    """Check that openvino.convert_model (OVC API) is available.

    On OpenVINO 2025.x, convert_model is exported from the top-level openvino
    package (from openvino import convert_model), not as openvino.convert_model.
    """
    try:
        from openvino import convert_model  # noqa: F401
    except ImportError:
        print(
            "OpenVINO convert_model is not available. "
            "Please install the OpenVINO Python package "
        )
        sys.exit(1)


def check_pt_or_tf(framework: str) -> None:
    """Validate that the framework argument is PT or TF."""
    if framework == "PT":
        print("Running generate_graph for PyTorch model...")
    elif framework == "TF":
        print("Running generate_graph for TensorFlow model...")
    else:
        print(
            f"Invalid argument: {framework}. "
            "Please specify 'PT' for PyTorch or 'TF' for TensorFlow."
        )
        sys.exit(1)


def print_and_run_cmd(cmd: list, grep_pattern: str = "") -> int:
    """Print a command, run it, stream output, and optionally verify a pattern in stdout."""
    cmd_str = " ".join(str(c) for c in cmd)
    print("=" * 69)
    print(f" Running {cmd_str} ...")
    print("=" * 69)

    result = subprocess.run(
        cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True
    )
    output = result.stdout or ""
    print(output, end="")

    if result.returncode != 0:
        print(f"{cmd_str} FAILED")
        return result.returncode

    if grep_pattern and grep_pattern not in output:
        print("A single FPGA subgraph is NOT generated")
        return 1

    return 0


def run_python(script: str, *args) -> None:
    """Run a Python script using the current interpreter."""
    cmd = [sys.executable, script] + [str(a) for a in args]
    exit_code = print_and_run_cmd(cmd)
    if exit_code != 0:
        print("FLOW FAILED at python stage")
        sys.exit(exit_code)


def dla_compiler(model: str, arch: str) -> None:
    """Compile an OpenVINO IR model for FPGA using dla_compiler."""
    coredla_root = os.environ.get("COREDLA_ROOT", "").rstrip("/\\")
    if not coredla_root:
        print(
            "COREDLA_ROOT is not set. "
            "Please run setupvars.bat (Windows) or source setupvars.sh (Linux) first."
        )
        sys.exit(1)

    root = Path(coredla_root)

    # Prefer installed location; fall back to in-tree dev build.
    # On Linux the script may be named 'dla_compiler' (no .py); on Windows 'dla_compiler.py'.
    dla_compiler_py = None
    arch_path = None
    for name in ("dla_compiler.py", "dla_compiler"):
        candidate = root / "bin" / name
        if candidate.exists():
            dla_compiler_py = candidate
            arch_path = root / "example_architectures" / f"{arch}.arch"
            break
    if dla_compiler_py is None:
        for name in ("dla_compiler.py", "dla_compiler"):
            candidate = root / "build" / "coredla" / "dla" / "bin" / name
            if candidate.exists():
                dla_compiler_py = candidate
                arch_path = root / "build" / "example_architectures" / f"{arch}.arch"
                break
    if dla_compiler_py is None:
        print(f"dla_compiler not found under {root}.")
        sys.exit(1)

    if not arch_path.exists():
        print(
            f"Architecture file not found at {arch_path}. "
            "Please check the architecture name."
        )
        sys.exit(1)

    cmd = [
        sys.executable,
        str(dla_compiler_py),
        "--network-file", f"./output/{model}.xml",
        "--march", str(arch_path),
        "--dumpdir",
        "--overwrite-output-files",
    ]
    exit_code = print_and_run_cmd(cmd, "1 subgraph(s), FPGA")
    if exit_code != 0:
        print("FLOW FAILED at dla_compiler stage")
        sys.exit(exit_code)

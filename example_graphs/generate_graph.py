#!/usr/bin/env python3
"""
Generate FPGA-ready example graphs for all supported models.
Cross-platform equivalent of the per-model generate_graph.sh scripts.

Usage:
    python generate_graph.py <MODEL> [PT|TF]

MODEL is case-insensitive. Framework defaults to PT when omitted.

Supported models:
    ConvReluMaxPoolCeilMode, DepthWise, ElementWiseMultiplication,
    HardSigmoid, HardSwish, MLP, PReLU, PixelShuffle, Sigmoid, Swish

Examples:
    python generate_graph.py MLP
    python generate_graph.py mlp TF
    python generate_graph.py PixelShuffle TF
    python generate_graph.py ConvReluMaxPoolCeilMode
"""

import os
import sys
from pathlib import Path

sys.path.insert(0, str(Path(__file__).parent))
import common_functions as cf  # noqa: E402

_DEFAULT_ARCH = "AGX5_Generic"

# Per-model configuration.
# Keys:
#   model_name  : output name passed to run_convert_model / dla_compiler
#   arch        : architecture file base name (no .arch extension)
#   pt_only     : if True, TF is not supported for this model
#   skip_ovc    : if True, model_pt.py produces the OV IR directly — skip run_convert_model
#   block_sizes : list of ints — PixelShuffle only; triggers the multi-factor loop
#   tf_name_base: TF model name prefix — PixelShuffle only (PT uses the folder name)
MODEL_CONFIG = {
    "ConvReluMaxPoolCeilMode": {
        "model_name": "ConvReluMaxPoolCeilMode",
        "arch": _DEFAULT_ARCH,
        "pt_only": True,
        "skip_ovc": True,
    },
    "DepthWise": {
        "model_name": "DepthWise",
        "arch": _DEFAULT_ARCH,
    },
    "ElementWiseMultiplication": {
        "model_name": "FeatureMultiplyNet",
        "arch": _DEFAULT_ARCH,
    },
    "HardSigmoid": {
        "model_name": "HardSigmoid",
        "arch": _DEFAULT_ARCH,
    },
    "HardSwish": {
        "model_name": "HardSwish",
        "arch": _DEFAULT_ARCH,
    },
    "MLP": {
        "model_name": "model",
        "arch": _DEFAULT_ARCH,
    },
    "PReLU": {
        "model_name": "PReLU",
        "arch": _DEFAULT_ARCH,
    },
    "PixelShuffle": {
        "arch": _DEFAULT_ARCH,
        "block_sizes": [2, 4, 8],
        "tf_name_base": "DepthToSpace",
    },
    "Sigmoid": {
        "model_name": "Sigmoid",
        "arch": _DEFAULT_ARCH,
    },
    "Swish": {
        "model_name": "Swish",
        "arch": _DEFAULT_ARCH,
    },
}


def _run_standard(model_dir: Path, model_key: str, cfg: dict, framework: str) -> None:
    os.chdir(model_dir)
    model_name = cfg["model_name"]
    arch = cfg["arch"]
    pt_only = cfg.get("pt_only", False)
    skip_ovc = cfg.get("skip_ovc", False)

    if framework == "PT":
        model_python_file = "model_pt.py"
        model_file = f"{model_name}.onnx"
        cf.check_package_installed("torch")
        cf.check_package_installed("torchvision")
    elif pt_only:
        print(f"TensorFlow is not supported for {model_key}.")
        sys.exit(1)
    else:
        model_python_file = "model_tf.py"
        model_file = f"{model_name}.keras"
        cf.check_package_installed("tensorflow")

    cf.check_python_ovc_installed()
    print("Assumes python and OVC are installed.")

    cf.run_python(model_python_file)

    if not skip_ovc:
        cf.run_python(
            "../run_convert_model.py", model_file,
            "--framework", framework, "--output_name", model_name,
        )

    print("Compiling...")
    cf.dla_compiler(model_name, arch)
    print("SUCCESS, Model is supported on FPGA")


def _run_pixelshuffle(model_dir: Path, cfg: dict, framework: str) -> None:
    os.chdir(model_dir)
    arch = cfg["arch"]
    block_sizes = cfg["block_sizes"]

    if framework == "PT":
        model_python_file = "model_pt.py"
        model_name_base = "PixelShuffle"
        model_ext = "onnx"
        cf.check_package_installed("torch")
        cf.check_package_installed("torchvision")
    else:
        model_python_file = "model_tf.py"
        model_name_base = cfg["tf_name_base"]
        model_ext = "keras"
        cf.check_package_installed("tensorflow")

    cf.check_python_ovc_installed()
    print("Assumes python and OVC are installed.")

    for factor in block_sizes:
        model_name = f"{model_name_base}_{factor}"
        cf.run_python(model_python_file, str(factor))
        cf.run_python(
            "../run_convert_model.py", f"{model_name}.{model_ext}",
            "--framework", framework, "--output_name", model_name,
        )
        print("Compiling...")
        cf.dla_compiler(model_name, arch)
        print(f"SUCCESS, {model_name_base} Model with block_size={factor} is supported on FPGA")


def main() -> None:
    supported = ", ".join(sorted(MODEL_CONFIG))

    if len(sys.argv) < 2:
        print("Usage: python generate_graph.py <MODEL> [PT|TF]")
        print(f"Supported models: {supported}")
        sys.exit(1)

    # Case-insensitive model lookup
    model_arg = sys.argv[1]
    model_key = next((k for k in MODEL_CONFIG if k.lower() == model_arg.lower()), None)
    if model_key is None:
        print(f"Unknown model '{model_arg}'.")
        print(f"Supported models: {supported}")
        sys.exit(1)

    # Framework is optional — defaults to PT
    framework = sys.argv[2].upper() if len(sys.argv) >= 3 else "PT"

    cf.check_pt_or_tf(framework)

    cfg = MODEL_CONFIG[model_key]
    model_dir = Path(__file__).parent / model_key

    if "block_sizes" in cfg:
        _run_pixelshuffle(model_dir, cfg, framework)
    else:
        _run_standard(model_dir, model_key, cfg, framework)


if __name__ == "__main__":
    main()

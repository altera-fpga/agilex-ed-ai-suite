#!/usr/bin/env python3
# Copyright 2025 Altera Corporation.
#
# This software and the related documents are Altera copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Altera's prior written
# permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the
# License.
"""
FPGA spatial runtime for image classification models (e.g. ResNet8 / CIFAR-10).

- Accepts a standard image (JPG/PNG/BMP/...).
- Converts to NCHW pixels and encodes them for the MMD input port (BF16 / FP32).
- Decodes MMD outputs to FP32 (16-bit BF16 shift or 32-bit reinterpret).
- Maps the argmax to CIFAR-10 class names.
"""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path

import numpy as np
from mmd_binding import (MmdDevice, bits_to_float32, encode_floats_for_mmd,
                         open_mmd)
from PIL import Image

# CIFAR-10 label order used by EclipseAidge/resnet8 and standard CIFAR loaders.
CIFAR10_LABELS = [
    "airplane",
    "automobile",
    "bird",
    "cat",
    "deer",
    "dog",
    "frog",
    "horse",
    "ship",
    "truck",
]


def image_to_nchw_floats(path: str | Path, resize_hw: tuple[int, int] | None = None) -> np.ndarray:
    """Load an image as RGB, optionally resize, return flat NCHW float32 pixels (N=1).

    Pixels stay in 0..255: resnet8 carries its own input scaling, so rescaling
    here drives the whole feature map to zero and every image scores alike.
    """
    img = Image.open(path).convert("RGB")
    if resize_hw is not None:
        img = img.resize((resize_hw[1], resize_hw[0]), Image.BILINEAR)
    arr = np.asarray(img, dtype=np.uint8)  # HWC RGB
    chw = np.transpose(arr, (2, 0, 1))
    return chw.astype(np.float32).reshape(-1)


def classify(
    mmd: MmdDevice,
    image_path: str | Path,
    resize_hw: tuple[int, int] | None = None,
) -> tuple[int, str, np.ndarray, float]:
    pixels = image_to_nchw_floats(image_path, resize_hw=resize_hw)
    flat = encode_floats_for_mmd(pixels, mmd.input_data_width)
    # ResNet8 / CIFAR-10: one 32x32x3 frame is 96 input packets and 1 output packet for the classification.
    start = time.perf_counter()
    raw = mmd.run_inference(flat)
    inference_s = time.perf_counter() - start
    scores = np.asarray(bits_to_float32(raw, mmd.output_data_width), dtype=np.float32)
    pred = int(np.argmax(scores))
    name = CIFAR10_LABELS[pred] if pred < len(CIFAR10_LABELS) else str(pred)
    return pred, name, scores, inference_s


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument("--image", required=True, help="Path to an input image")
    p.add_argument(
        "--mmd-lib",
        default=None,
        help="Directory containing spatial_mmd*.so (pybind module); default: auto-detect",
    )
    p.add_argument("--port-config", required=True, help="port_config.json")
    p.add_argument(
        "--load-weights",
        default=None,
        metavar="DIR",
        help="Optional directory of weights_ddr_*.bin files; if omitted, weights are not loaded",
    )
    p.add_argument("--resize", default=None, metavar="HxW", help="Optional resize, e.g. 32x32 for CIFAR/ResNet8")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    resize_hw = None
    if args.resize:
        h, w = args.resize.lower().split("x")
        resize_hw = (int(h), int(w))

    kwargs = {
        "port_config": args.port_config,
        "lib_path": args.mmd_lib,
        "load_weights": args.load_weights,
    }

    with open_mmd(**kwargs) as mmd:
        pred, name, scores, inference_s = classify(mmd, args.image, resize_hw=resize_hw)
        top = min(5, scores.size)
        order = np.argsort(-scores)[:top]
        print(f"predicted: {pred} ({name})")
        print("top scores:")
        for i in order:
            label = CIFAR10_LABELS[i] if i < len(CIFAR10_LABELS) else str(i)
            print(f"  {int(i):3d}  {label:12s}  {float(scores[i]):.6g}")
        print(f"inference latency: {inference_s * 1000:.2f} ms")
        print(f"throughput:        {1.0 / inference_s:.2f} FPS")
    return 0


if __name__ == "__main__":
    sys.exit(main())

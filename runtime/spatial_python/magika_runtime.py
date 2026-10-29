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
FPGA spatial runtime for Magika file-type classification.

Preprocess matches external/spatial_examples/magika/magika_spatial.py:
  Magika feature extraction -> beg[:1024] + end[-1024] -> int tokens.

Output words are decoded to FP32; the predicted index is looked up in
Magika()._target_labels_space.
"""

from __future__ import annotations

import argparse
import sys
import time
from io import BytesIO
from pathlib import Path

import numpy as np
from magika import Magika
from magika.types import Seekable
from mmd_binding import MmdDevice, bits_to_float32, open_mmd

magika_helper = Magika()


def preprocess_input(input_data: str | Path | bytes) -> np.ndarray:
    """Same feature layout as magika_spatial.preprocess_input."""
    if isinstance(input_data, (str, Path)):
        file_bytes = Path(input_data).read_bytes()
    else:
        file_bytes = input_data

    _result, features = magika_helper._get_result_or_features_from_seekable(
        Seekable(BytesIO(file_bytes))
    )
    if features is None:
        raise RuntimeError("Magika feature extraction failed")
    assert 1024 == magika_helper._model_config.beg_size == magika_helper._model_config.end_size
    assert 0 == magika_helper._model_config.mid_size
    tokens = np.array(features.beg[:1024] + features.end[-1024:], dtype=np.int32)
    return tokens.astype(np.uint64).reshape(-1)


def classify(mmd: MmdDevice, file_path: str | Path) -> tuple[int, str, np.ndarray, float]:
    labels = list(magika_helper._target_labels_space)
    # Magika: 2048 UINT tokens is 1 input packet; 214 class scores is 1 output packet.
    input_data = preprocess_input(file_path)
    start = time.perf_counter()
    raw = mmd.run_inference(input_data)
    inference_s = time.perf_counter() - start
    scores = np.asarray(bits_to_float32(raw, mmd.output_data_width), dtype=np.float32)
    usable = scores[: len(labels)] if scores.size >= len(labels) else scores
    pred = int(np.argmax(usable))
    name = labels[pred] if pred < len(labels) else str(pred)
    return pred, name, scores, inference_s


def print_result(
    file_path: str | Path,
    pred: int,
    name: str,
    scores: np.ndarray,
    inference_s: float,
) -> None:
    labels = list(magika_helper._target_labels_space)
    print(f"{file_path}: predicted {pred} ({name})")
    top = min(5, scores.size)
    order = np.argsort(-scores)[:top]
    print("top scores:")
    for i in order:
        label = labels[i] if i < len(labels) else str(i)
        print(f"  {int(i):3d}  {label:20s}  {float(scores[i]):.6g}")
    print(f"inference latency: {inference_s * 1000:.2f} ms")


def _is_quit(text: str) -> bool:
    return text.lower() in ("quit", "exit", "q")


def interactive_loop(mmd: MmdDevice) -> None:
    print("Enter a file path, or quit/exit/q to stop.")
    while True:
        try:
            path = input("\nFile: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            return
        if not path:
            continue
        if _is_quit(path):
            print("Goodbye!")
            return
        file_path = Path(path).expanduser()
        if not file_path.is_file():
            print(f"not a file: {file_path}")
            continue
        try:
            pred, name, scores, inference_s = classify(mmd, file_path)
        except Exception as exc:
            print(f"failed: {exc}")
            continue
        print_result(file_path, pred, name, scores, inference_s)


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
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
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    kwargs = {
        "port_config": args.port_config,
        "lib_path": args.mmd_lib,
        "load_weights": args.load_weights,
    }

    print("[magika] loading feature extractor...", flush=True)
    t0 = time.perf_counter()
    print(f"[magika] ready in {time.perf_counter() - t0:.1f}s", flush=True)

    if args.load_weights:
        print(f"[magika] connecting to FPGA, loading weights from {args.load_weights}...", flush=True)
    else:
        print("[magika] connecting to FPGA...", flush=True)
    t0 = time.perf_counter()
    with open_mmd(**kwargs) as mmd:
        print(f"[magika] FPGA ready in {time.perf_counter() - t0:.1f}s", flush=True)
        interactive_loop(mmd)
    return 0


if __name__ == "__main__":
    sys.exit(main())

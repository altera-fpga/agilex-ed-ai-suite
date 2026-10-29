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
"""BF16 / FP32 encode and decode helpers for MMD uint64 words."""

from __future__ import annotations

import numpy as np


def bits_to_float32(bits: int | np.ndarray, data_width: int) -> float | np.ndarray:
    """Decode spatial output words to FP32.

    16-bit: treat as BF16 (place in the upper half of an FP32 word).
    32-bit: reinterpret bits as FP32.
    """
    arr = np.asarray(bits, dtype=np.uint64)
    if data_width == 16:
        fp32_bits = (arr & np.uint64(0xFFFF)).astype(np.uint32) << np.uint32(16)
    elif data_width == 32:
        fp32_bits = (arr & np.uint64(0xFFFFFFFF)).astype(np.uint32)
    else:
        raise ValueError(
            f"Unsupported data_width for float decode: {data_width} (expected 16 or 32)"
        )
    values = fp32_bits.view(np.float32)
    if np.ndim(bits) == 0:
        return float(values)
    return values.copy()


def float32_to_bf16_u64(values: np.ndarray) -> np.ndarray:
    """Truncate float32 values as BF16-in-u64 words."""
    bits = np.asarray(values, dtype=np.float32).view(np.uint32) >> np.uint32(16)
    return bits.astype(np.uint64).reshape(-1)


def float32_to_fp32_u64(values: np.ndarray) -> np.ndarray:
    bits = np.asarray(values, dtype=np.float32).view(np.uint32)
    return bits.astype(np.uint64).reshape(-1)


def encode_floats_for_mmd(values: np.ndarray, data_width: int) -> np.ndarray:
    if data_width == 16:
        return float32_to_bf16_u64(values)
    if data_width == 32:
        return float32_to_fp32_u64(values)
    raise ValueError(f"Unsupported input data_width: {data_width} (expected 16 or 32)")

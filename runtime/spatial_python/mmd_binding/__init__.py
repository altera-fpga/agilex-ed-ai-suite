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
"""Spatial MMD Python package (pybind11 + helpers).

The native extension `spatial_mmd` is built with the AGX7 spatial runtime and
installed next to this package. It exposes the C++ vector-based session API.
"""

from .conversions import (bits_to_float32, encode_floats_for_mmd,
                          float32_to_bf16_u64, float32_to_fp32_u64)
from .device import SpatialMmd, open_mmd
from .interface import MmdDevice

__all__ = [
    "MmdDevice",
    "SpatialMmd",
    "open_mmd",
    "bits_to_float32",
    "encode_floats_for_mmd",
    "float32_to_bf16_u64",
    "float32_to_fp32_u64",
]

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

from __future__ import annotations

import sys
from pathlib import Path
from typing import Sequence

import numpy as np


def _install_lib_dir() -> Path:
    # device.py lives in <INSTALL_DIR>/spatial_python/mmd_binding → lib is <INSTALL_DIR>/lib
    return Path(__file__).resolve().parents[2] / "lib"


def _ensure_module_search_path(module_dir: str | Path | None = None) -> None:
    candidates: list[Path] = []
    if module_dir is not None:
        candidates.append(Path(module_dir).resolve())
    candidates.append(_install_lib_dir())

    for candidate in candidates:
        if candidate.is_dir() and str(candidate) not in sys.path:
            sys.path.insert(0, str(candidate))


def _import_spatial_mmd(module_dir: str | Path | None = None):
    _ensure_module_search_path(module_dir)
    try:
        import spatial_mmd  # type: ignore[import-not-found]
        return spatial_mmd
    except ImportError as e:
        raise ImportError(
            "Could not import spatial_mmd (pybind11 module). Expected under the install directory "
            f"{_install_lib_dir()}, or pass --mmd-lib <dir>.\n"
            f"Original error: {e}"
        ) from e


class SpatialMmd:
    """Python front-end for the spatial MMD via pybind11."""

    def __init__(self, port_config: str | Path, module_dir: str | Path | None = None):
        self._mmd = _import_spatial_mmd(module_dir)
        self._connected = False
        self._mmd.load_port_config(str(port_config))

    @property
    def input_data_width(self) -> int:
        return int(self._mmd.input_data_width())

    @property
    def output_data_width(self) -> int:
        return int(self._mmd.output_data_width())

    def connect_to_fpga(self) -> None:
        self._mmd.connect_to_fpga()
        self._connected = True

    def load_weights(self, path: str | Path) -> None:
        self._require_connected()
        self._mmd.load_weights(str(path))

    def reset(self) -> None:
        self._require_connected()
        self._mmd.reset()

    def run_inference(self, input_data: Sequence[int] | np.ndarray) -> np.ndarray:
        self._require_connected()
        inp = np.ascontiguousarray(np.asarray(input_data, dtype=np.uint64).reshape(-1))
        return np.asarray(self._mmd.run_inference(inp), dtype=np.uint64)

    def disconnect_fpga(self) -> None:
        if self._connected:
            self._mmd.disconnect_fpga()
            self._connected = False

    def _require_connected(self) -> None:
        if not self._connected:
            raise RuntimeError("connect_to_fpga must be called first")

    def __enter__(self) -> "SpatialMmd":
        return self

    def __exit__(self, exc_type, exc, tb) -> None:
        self.disconnect_fpga()


def open_mmd(
    port_config: str | Path,
    lib_path: str | Path | None = None,
    load_weights: str | Path | None = None,
) -> SpatialMmd:
    """Construct MMD (port config at init), connect, optional weights, reset.

    lib_path may be a directory containing the spatial_mmd pybind module.
    """
    mmd = SpatialMmd(port_config, module_dir=lib_path)
    mmd.connect_to_fpga()
    if load_weights is not None:
        mmd.reset()
        mmd.load_weights(load_weights)
    mmd.reset()
    return mmd

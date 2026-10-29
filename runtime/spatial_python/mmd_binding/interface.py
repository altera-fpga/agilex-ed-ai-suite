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

from pathlib import Path
from typing import Protocol, Sequence, runtime_checkable

import numpy as np


@runtime_checkable
class MmdDevice(Protocol):
    """Mandatory Python MMD surface used by the three runtimes."""

    @property
    def input_data_width(self) -> int: ...

    @property
    def output_data_width(self) -> int: ...

    def connect_to_fpga(self) -> None: ...

    def load_weights(self, path: str | Path) -> None: ...

    def reset(self) -> None: ...

    def run_inference(
        self,
        input_data: Sequence[int] | np.ndarray,
    ) -> np.ndarray: ...

    def disconnect_fpga(self) -> None: ...

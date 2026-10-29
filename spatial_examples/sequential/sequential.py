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

import argparse

import numpy as np
from fpga_ai_suite.spatial.flow import run_flow
from fpga_ai_suite.spatial.layers import (Activation, Add_bias, Dot,
                                          Sequential, Softmax)

# Define all weights
num_weights = 10


def generate_random_weight_bf16(shape):
    weights = (
        np.random.randint(2, size=shape, dtype=np.uint32) << 31
        | np.random.randint(101, 151, size=shape, dtype=np.uint32) << 23
        | np.random.randint((1 << 7), size=shape, dtype=np.uint32) << 16)

    weights = weights.view(np.float32)
    return weights


vector_fp = generate_random_weight_bf16((num_weights, 128))
vector_fp2 = generate_random_weight_bf16((num_weights, 32))
matrix_fp = generate_random_weight_bf16((num_weights, 32, 128))
matrix_fp2 = generate_random_weight_bf16((num_weights, 128, 128))
matrix_fp3 = generate_random_weight_bf16((num_weights, 128, 32))


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--sim", action="store_true")
    parser.add_argument("--compile", action="store_true")
    parser.add_argument("--output_path", type=str, default=None)

    args = parser.parse_args()

    # Model definition
    model = Sequential(
        name="MLP",
        layers=[
            Dot(weights=matrix_fp, num_lanes_in=16, num_lanes_out=4, dtype="BF16", num_packets_per_weight=1, mif_init=True),
            Add_bias(bias=vector_fp, num_lanes=4, dtype="BF16", mif_init=True),
            Activation(activation="relu", num_lanes=4, dw=16, dtype="BF16"),
            Dot(weights=matrix_fp2, num_lanes_in=4, num_lanes_out=4, dtype="BF16", num_packets_per_weight=1, mif_init=True),
            Add_bias(bias=vector_fp, num_lanes=4, dtype="BF16", mif_init=True),
            Activation(activation="relu", num_lanes=4, dw=16, dtype="BF16"),
            Dot(weights=matrix_fp3, num_lanes_in=4, num_lanes_out=4, dtype="BF16", num_packets_per_weight=1, mif_init=True),
            Add_bias(bias=vector_fp2, num_lanes=4, dtype="BF16", mif_init=True),
            Softmax(num_lanes=4),
        ],
    )

    model.generate_test_inputs()
    model()

    ret = run_flow(
        model,
        sim=args.sim,
        recompile=True,
        validate_timing=True,
        quartus_compile=args.compile,
        validate_resource_usage=False,
        output_path=args.output_path
    )
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")

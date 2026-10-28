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
from fpga_ai_suite.spatial.layers import (Activation, Add_bias,
                                          Directed_acyclic_graph, Dot)

# Define all weights
num_weights = 10


def generate_random_weight_bf16(shape):
    matrix = (
        np.random.randint(2, size=shape, dtype=np.uint32) << 31
        | np.random.randint(101, 151, size=shape, dtype=np.uint32) << 23
        | np.random.randint((1 << 7), size=shape, dtype=np.uint32) << 16)

    matrix = matrix.view(np.float32)
    return matrix


vector_fp = generate_random_weight_bf16((num_weights, 128))
vector_fp2 = generate_random_weight_bf16((num_weights, 32))
matrix_fp = generate_random_weight_bf16((num_weights, 32, 128))
matrix_fp2 = generate_random_weight_bf16((num_weights, 128, 128))
matrix_fp3 = generate_random_weight_bf16((num_weights, 128, 32))


# Model definition
class hidden_layer(Directed_acyclic_graph):
    def __init__(self, weights, bias):
        self.weights_matrix = weights
        self.bias_vector = bias
        super().__init__(module_name="hidden_layer")

    def init_topology(self):
        self.input = self.create_input("din", 16, 4, "BF16")
        self.output = self.create_output("dout", 16, 4, "BF16")
        self.create_weight_port("weights", internal_rd_channel_width=32)

        self.dot = self.add_node(Dot(weights=self.weights_matrix))
        self.add_bias = self.add_node(Add_bias(bias=self.bias_vector))
        self.activation = self.add_node(Activation("relu"))

    def forward(self, din):
        x = self.dot(din)
        x = self.add_bias(x)
        x = self.activation(x)
        return x,


class my_model(Directed_acyclic_graph):
    def __init__(self):
        super().__init__(module_name="MLP")

    def init_topology(self):
        self.input = self.create_input("din", 16, 4, "BF16")
        self.output = self.create_output("dout", 16, 4, "BF16")
        self.create_weight_port("weights", internal_rd_channel_width=32)

        self.l1 = self.add_node(hidden_layer(weights=matrix_fp, bias=vector_fp))
        self.l2 = self.add_node(hidden_layer(weights=matrix_fp2, bias=vector_fp))
        self.l3 = self.add_node(hidden_layer(weights=matrix_fp3, bias=vector_fp2))

    def forward(self, din):
        x = self.l1(din)
        x = self.l2(x)
        x = self.l3(x)
        return x,


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--save_model", action="store_true")
    parser.add_argument("--output_path", type=str, default=None)

    args = parser.parse_args()

    model = my_model()
    model.set_shape(din_shape=(1, 1, 32))

    ret = run_flow(
        model,
        save_model=args.save_model,
        output_path=args.output_path
    )
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")

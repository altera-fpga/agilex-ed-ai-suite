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
from pathlib import Path

import numpy as np
import torch
from fpga_ai_suite.spatial.flow import run_flow
from fpga_ai_suite.spatial.layers import (Activation, Directed_acyclic_graph,
                                          Linear, Softmax)


class MNIST_MLP(Directed_acyclic_graph):
    def __init__(self, weights, num_lanes, num_lanes_out):
        self.weights_data = weights
        self.dw = 16
        self.num_lanes = num_lanes
        self.num_lanes_out = num_lanes_out
        super().__init__(module_name="mnist_mlp")

    def init_topology(self):
        self.create_weight_port("weights", internal_rd_channel_width=32)
        self.input_layer = self.add_node(
            Linear(
                weights=self.weights_data["input_layer.weight"],
                num_lanes_in=self.num_lanes,
                num_lanes_out=self.num_lanes,
                num_packets_per_weight=1,
                dtype="BF16",
                bias=self.weights_data["input_layer.bias"],
            )
        )
        self.relu1 = self.add_node(
            Activation(activation="relu", num_lanes=self.num_lanes, dw=16, dtype="BF16")
        )
        self.mid_layer = self.add_node(
            Linear(
                weights=self.weights_data["mid_layer.weight"],
                num_lanes_in=self.num_lanes,
                num_lanes_out=self.num_lanes,
                num_packets_per_weight=1,
                dtype="BF16",
                bias=self.weights_data["mid_layer.bias"],
            )
        )
        self.relu2 = self.add_node(
            Activation(activation="relu", num_lanes=self.num_lanes, dw=16, dtype="BF16")
        )
        self.output_layer = self.add_node(
            Linear(
                weights=self.weights_data["output_layer.weight"],
                num_lanes_in=self.num_lanes,
                num_lanes_out=self.num_lanes_out,
                num_packets_per_weight=1,
                dtype="BF16",
                bias=self.weights_data["output_layer.bias"],
            )
        )
        self.softmax = self.add_node(Softmax(num_lanes=self.num_lanes_out))
        self.din = self.create_input("din", self.dw, self.num_lanes, "BF16")
        self.dout = self.create_output("dout", self.dw, self.num_lanes_out, "BF16")

    def forward(self, din):
        x = self.relu1(self.input_layer(din))
        x = self.relu2(self.mid_layer(x))
        x = self.softmax(self.output_layer(x))
        return (x,)


if __name__ == "__main__":
    parser = argparse.ArgumentParser()
    parser.add_argument("--sim", action="store_true")
    parser.add_argument("--compile", action="store_true")
    args = parser.parse_args()

    model_path = Path("mnist_mlp/pytorch_model.bin")
    if not model_path.is_file():
        raise FileNotFoundError(
            f"Missing model file: {str(model_path)!r}.\n"
            "Download with:\n"
            "  hf download dacorvo/mnist-mlp --local-dir ./mnist_mlp\n"
            "See README.md for download instructions."
        )
    state_dict = torch.load(
        model_path,
        map_location="cpu",
        weights_only=False,
    )

    weights = {
        k: v.float().numpy().T if "weight" in k else v.float().numpy()
        for k, v in state_dict.items()
    }
    mlp = MNIST_MLP(weights, 4, 5)

    from torchvision import datasets, transforms

    transform = transforms.Compose(
        [
            transforms.ToTensor(),
            transforms.Normalize((0.1307,), (0.3081,)),
            transforms.Lambda(lambda x: torch.flatten(x)),
        ]
    )
    test_data_path = Path("./mnist_data")
    if not test_data_path.exists():
        test_set = datasets.MNIST(test_data_path, train=False, download=True, transform=transform)
    else:
        test_set = datasets.MNIST(test_data_path, train=False, download=False, transform=transform)

    num_test_images = 100
    imgs = test_set.data.float().numpy().reshape(-1, 1, 28 * 28)[:num_test_images]
    labels = test_set.targets.numpy()[:num_test_images]
    actual = np.argmax(mlp(imgs)[0].reshape(num_test_images, 10), axis=1)

    ret = run_flow(mlp, sim=args.sim, recompile=True, quartus_compile=args.compile)
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")
    print("Accuracy:", np.mean(actual == labels))

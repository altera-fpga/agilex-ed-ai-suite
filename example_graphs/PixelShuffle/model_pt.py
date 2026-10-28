# This script generates a graph saved in 'PixelShuffleModel_<blocksize>.onnx'
#
# Run generate_graph.sh which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that this MLP graph is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

import inspect
import sys

import torch
import torch.nn as nn


# Define the PixelShuffle module
class PixelShuffleNet(nn.Module):
    def __init__(self, block_size):
        super(PixelShuffleNet, self).__init__()
        # Assuming the input has a channel size that is square of block_size for simplicity
        self.conv = nn.Conv2d(in_channels=3, out_channels=3 * (block_size ** 2), kernel_size=3, padding=1)
        self.pixel_shuffle = nn.PixelShuffle(block_size)

    def forward(self, x):
        x = self.conv(x)
        x = self.pixel_shuffle(x)
        return x


def main(block_size):
    # Instantiate the model with the desired configuration
    model = PixelShuffleNet(block_size)

    # Define a dummy input for exporting the model
    x = torch.randn(1, 3, 24, 24)  # Example input tensor

    # Export the model to an ONNX file
    _export_kwargs = {"export_params": True, "opset_version": 11}
    if "dynamo" in inspect.signature(torch.onnx.export).parameters:
        _export_kwargs["dynamo"] = False
    torch.onnx.export(model, x, f"PixelShuffle_{block_size}.onnx", **_export_kwargs)


if __name__ == "__main__":
    # Check if an block_size was passed as a command-line argument
    if len(sys.argv) != 2:
        print("Usage: python3 model_py.py <block_size>")
        exit(1)

    # Convert the first command-line argument to an integer
    block_size = int(sys.argv[1])
    main(block_size)

# This script generates a graph saved in 'DepthWise.onnx'
#
# Run generate_graph.sh with a PT argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that DepthWise Seperable Convolution is on the FPGA
#
# Depthwise will work with and without depthwise set in .arch file
# However, it will have higher performance (but higher area) if it is specified
# depthwise {
#  ...
#  ...
# }
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

# Steps
# Perform a depthwise convolution first by
# Spliting the input channels
# Filter each channel with their own respective filter
# Stack convolved outputs together
# Create a linear combination of the output of the depthwise convolution (pointwise convolution)

import inspect

import torch
import torch.nn as nn


# Define the depthwise separable convolution neural network
class DepthwiseSeparableConvNet(nn.Module):
    def __init__(self, in_channels, out_channels, kernel_size, stride=1, padding=0):
        super(DepthwiseSeparableConvNet, self).__init__()
        self.depthwise = nn.Conv2d(in_channels, in_channels, kernel_size=kernel_size, stride=stride, padding=padding, groups=in_channels)
        self.pointwise = nn.Conv2d(in_channels, out_channels, kernel_size=1)

    def forward(self, x):
        x = self.depthwise(x)
        x = self.pointwise(x)
        return x


def main():
    # This can be adjusted depending on your needs
    in_channels = 3
    out_channels = 64
    kernel_size = 3
    stride = 1
    padding = 1

    # Instantiate the model with the desired configuration
    model = DepthwiseSeparableConvNet(in_channels=in_channels, out_channels=out_channels, kernel_size=kernel_size,
                                      stride=stride, padding=padding)

    # Define a dummy input for exporting the model
    x = torch.randn(1, 3, 8, 8)

    # Export the model to an ONNX file
    _export_kwargs = {"export_params": True}
    if "dynamo" in inspect.signature(torch.onnx.export).parameters:
        _export_kwargs["dynamo"] = False
    torch.onnx.export(model, x, "DepthWise.onnx", **_export_kwargs)


if __name__ == "__main__":
    main()

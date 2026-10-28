# This script generates a graph saved in 'HardSwish.onnx'
#
# Run generate_graph.sh with a PT argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that PyTorch HardSwish is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file
# Requires enable_eltwise_mult : true in .arch file

import inspect

import torch
import torch.nn as nn


# Define the neural network
class HSwishNet(nn.Module):
    def __init__(self):
        super(HSwishNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 64, 1, 1, bias=True)
        self.activation = nn.Hardswish()

    def forward(self, x):
        x = self.conv1(x)
        x = self.activation(x)
        return x


def main():
    # Instantiate the model
    model = HSwishNet()

    # Define a dummy input for exporting the model
    x = torch.randn(1, 3, 16, 16)

    # Export the model to an ONNX file
    _export_kwargs = {"export_params": True}
    if "dynamo" in inspect.signature(torch.onnx.export).parameters:
        _export_kwargs["dynamo"] = False
    torch.onnx.export(model, x, "HardSwish.onnx", **_export_kwargs)


if __name__ == "__main__":
    main()

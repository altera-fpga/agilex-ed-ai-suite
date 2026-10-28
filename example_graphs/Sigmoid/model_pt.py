# This script generates a graph saved in 'Sigmoid.onnx'
#
# Run generate_graph.sh with a PT argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that PyTorch Sigmoid is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, or enable_round_clamp : true in .arch file
# Requires enable_sigmoid : true in .arch file

import inspect

import torch
import torch.nn as nn


# Define the neural network
class SigmoidNet(nn.Module):
    def __init__(self):
        super(SigmoidNet, self).__init__()
        self.linear1 = nn.Linear(in_features=10, out_features=5)
        self.sigmoid = nn.Sigmoid()
        self.linear2 = nn.Linear(in_features=5, out_features=2)

    def forward(self, x):
        x = self.linear1(x)
        x = self.sigmoid(x)
        x = self.linear2(x)
        return x


def main():
    # Initialize the model
    model = SigmoidNet()

    # Dummy input for exporting the model
    dummy_input = torch.randn(1, 10)

    # Export the model to an ONNX file
    _export_kwargs = {"verbose": True}
    if "dynamo" in inspect.signature(torch.onnx.export).parameters:
        _export_kwargs["dynamo"] = False
    torch.onnx.export(model, dummy_input, "Sigmoid.onnx", **_export_kwargs)


if __name__ == "__main__":
    main()

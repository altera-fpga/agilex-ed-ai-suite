# This script generates a graph saved in 'ElementWiseNet.onnx' and 'FeatureMultiplyNet.onnx'
#
# Run generate_graph.sh with a PT argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so an elementwise multiplication of feature * filter and feature * feature will be on the FPGA respectively
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file
# Requires enable_eltwise_mult: true in the arch file

import inspect

import torch
import torch.nn as nn


# Define the neural network with element-wise multiplication of features
class FeatureMultiplyNet(nn.Module):
    def __init__(self):
        super(FeatureMultiplyNet, self).__init__()
        self.conv1 = nn.Conv2d(3, 64, kernel_size=3, stride=1, padding=1)

    def forward(self, x):
        # Apply convolution to input feature to get feature map
        feature_map1 = self.conv1(x)
        # Apply the same convolution to get another feature map
        feature_map2 = self.conv1(x)
        # Perform element-wise multiplication of the two feature maps
        return feature_map1 * feature_map2


def main():
    # Define a dummy input for exporting the model
    x = torch.randn(1, 3, 8, 8)

    # Instantiate the feature by feature multiply model
    model = FeatureMultiplyNet()

    # Export the model to an ONNX file
    _export_kwargs = {"export_params": True}
    if "dynamo" in inspect.signature(torch.onnx.export).parameters:
        _export_kwargs["dynamo"] = False
    torch.onnx.export(model, x, "FeatureMultiplyNet.onnx", **_export_kwargs)


# Execute the main function to export the model
if __name__ == "__main__":
    main()

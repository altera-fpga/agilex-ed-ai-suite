#!/usr/bin/env python3
"""
Test model with Conv + Add + ReLU + MaxPool.
This example graph can be used for streaming by supplying the graph.xml along with the padded img.bin generated from this script.
This example graph also shows how to convert to OpenVINO IR without the intermediate ONNX step.
"""
from pathlib import Path

import numpy as np
import openvino as ov
import torch
import torch.nn as nn


class ConvReluPoolModel(nn.Module):
    """Model: Conv + Add bias + ReLU + MaxPool"""
    def __init__(self):
        super().__init__()
        # Conv: 3 input channels, 64 output channels, 7x7 kernel, stride 2, padding 3
        self.conv1 = nn.Conv2d(3, 64, kernel_size=7, stride=2, padding=3, bias=False)
        # Separate bias as a parameter (will become Add layer in IR)
        self.bias = nn.Parameter(torch.ones(1, 64, 1, 1) * 0.01)
        self.relu = nn.ReLU()
        # MaxPool: 3x3 kernel, stride 2, ceil_mode for "ceil" rounding
        self.maxpool = nn.MaxPool2d(kernel_size=3, stride=2, padding=0, ceil_mode=True)

    def forward(self, x):
        x = self.conv1(x)
        x = x + self.bias
        x = self.relu(x)
        x = self.maxpool(x)
        return x


def main():
    output_dir = Path("output")

    # Create model
    model = ConvReluPoolModel()
    model.eval()

    # Use 156x156 input for 16-byte alignment: 3*156*156 = 73008 bytes (divisible by 16)
    input_shape = (1, 3, 156, 156)
    example_input = torch.randn(input_shape)

    # Test forward pass to verify shapes
    with torch.no_grad():
        output = model(example_input)

    print(f"Input shape:  {example_input.shape}")
    print(f"Output shape: {output.shape}")
    print(f"Input bytes:  {3 * 156 * 156} = 73008 (aligned to 16)")
    # Convert to OpenVINO IR with static shapes
    print("\nConverting to OpenVINO IR format...")

    # Convert model directly to OpenVINO IR without exporting to ONNX first
    ov_model = ov.convert_model(model, example_input=example_input)

    # Reshape to ensure static shapes (dynamic dimensions not supported by the IP)
    ov_model.reshape(input_shape)

    # Save the model - disable FP16 compression to avoid Convert nodes
    output_path = output_dir / "ConvReluMaxPoolCeilMode.xml"
    ov.save_model(ov_model, output_path, compress_to_fp16=False)

    print("\nModel saved to:")
    print(f"  {output_path}")
    print(f"  {output_dir / 'img.bin'}")

    # Create a sample input image (random data, uint8)
    img_path = output_dir / "img.bin"

    # Input is 3*156*156 = 73,008 bytes (already aligned)
    img_data = np.random.randint(0, 256, size=(3, 156, 156), dtype=np.uint8)
    img_data.tofile(img_path)
    print(f"  {img_path} ({img_data.nbytes} bytes)")

    print("\nDone! Graph has: Parameter -> Conv -> Add -> ReLU -> MaxPool -> Result")


if __name__ == "__main__":
    main()

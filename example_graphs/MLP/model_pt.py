# This file generates a folder named images (if it does not exist) and the
# binary input files input_0.bin to input_4999.bin if --in_file is left
# unspecified. It will also generate a classification file in
# correct_classifications.txt , the graph outputs file in output.txt,
# and the MLP graph in model.onnx.
#
# Run generate_graph.sh with a PT argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that this MLP graph is on the FPGA
#
# For further usage details, use -h or reference convert_model_README.md
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

import argparse
import inspect
import os

import numpy as np
import torch
from torch import nn, onnx


class MLP(nn.Module):
    def __init__(self):
        super(MLP, self).__init__()
        self.model = nn.Sequential(
            nn.Linear(10, 128),
            nn.Linear(128, 80),
            nn.Linear(80, 10),
        )

    def forward(self, x):
        return self.model(x)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out_file", type=str, help="path to Pytorch output file", default="./output.txt")
    parser.add_argument("--out_dir", type=str, help="path to binary output directory", default="./inputs")
    parser.add_argument("--onnx_file", type=str, help="path to model .onnx file", default="./model.onnx")
    parser.add_argument("--in_file", type=str, help="path to .bin file that contains the input feature")
    parser.add_argument("--mu", type=float, help="mu of input feature, mu in N(mu, sigma^2) (normal distribution)", default=0)
    parser.add_argument("--sigma", type=float, help="sigma of input feature, sigma in N(mu, sigma^2) (normal distribution)", default=1)
    args = parser.parse_args()

    model = MLP()
    f = open(args.out_file, "w")
    c = open("correct_classifications.txt", "w")
    if (not args.in_file) and (not os.path.exists(args.out_dir)):
        os.mkdir(args.out_dir)
    for i in range(5000):
        # assume num_batch = 1, depth=10 for input feature
        if args.in_file:
            x = torch.from_numpy(np.fromfile(args.in_file, dtype=np.float32)).reshape(1, -1)
        else:
            num = str(i).zfill(4)
            a = (np.random.randn(1, 10) * args.sigma + args.mu).astype(np.float32)
            a.tofile(args.out_dir + "/input" + str(num) + ".bin")
            x = torch.from_numpy(a)
        print("network input: {}".format(x))

        logits = model(x)
        print("network output: {}".format(logits))

        classification = torch.argmax(logits)
        print("correct classification: {}".format(classification))

        # assume x only has 1 row
        for i in logits[0]:
            f.write(str(i.item()) + "\n")

        c.write(str(classification.item()) + "\n")

        if args.in_file:
            break

    f.close()
    c.close()
    _export_kwargs = {"export_params": True}
    if "dynamo" in inspect.signature(onnx.export).parameters:
        _export_kwargs["dynamo"] = False
    onnx.export(model, x, args.onnx_file, **_export_kwargs)


if __name__ == '__main__':
    main()

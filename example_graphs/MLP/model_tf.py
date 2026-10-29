# This is a TensorFlow equivalent of model_pt.py
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that this MLP graph is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

import argparse
import os

import numpy as np
import tensorflow as tf
from tensorflow.keras.layers import Dense, Input
from tensorflow.keras.models import Model


def MLP(input_shape=(10,)):
    inputs = Input(shape=input_shape, batch_size=1, name='input')
    x = Dense(128)(inputs)
    x = Dense(80)(x)
    outputs = Dense(10)(x)
    return Model(inputs={'input': inputs}, outputs=outputs, name="MLP")


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--out_file", type=str, help="path to TensorFlow output file", default="./output.txt")
    parser.add_argument("--out_dir", type=str, help="path to binary output directory", default="./inputs")
    parser.add_argument("--model_file", type=str, help="path to model directory", default="./model.keras")
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
            x = np.fromfile(args.in_file, dtype=np.float32).reshape(1, -1)
        else:
            num = str(i).zfill(4)
            a = (np.random.randn(1, 10) * args.sigma + args.mu).astype(np.float32)
            a.tofile(f"{args.out_dir}/input{num}.bin")
            x = a
        print("network input: {}".format(x))

        logits = model(x)
        print("network output: {}".format(logits))

        classification = tf.argmax(logits, axis=1)
        print("correct classification: {}".format(classification.numpy()))

        for i in logits.numpy()[0]:
            f.write(str(i) + "\n")

        c.write(str(classification.numpy()[0]) + "\n")

        if args.in_file:
            break

    f.close()
    c.close()

    model.summary()
    model.save(args.model_file)


if __name__ == "__main__":
    main()

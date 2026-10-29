# This script generates a folder named 'DepthToSpace' which contains the saved model from model_tf.py
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that TensorFlow PReLU is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from custom_tf_layers import DepthToSpaceLayer  # noqa: E402
from tensorflow.keras.layers import Input  # noqa: E402
from tensorflow.keras.models import Model  # noqa: E402


def DepthToSpaceNet(input_shape, block_size):
    inputs = Input(shape=input_shape, name='input', dtype='float32')
    output = DepthToSpaceLayer(block_size)(inputs)
    model = Model(inputs={'input': inputs}, outputs=output, name=f"DepthToSpace_{block_size}")
    return model


def main(block_size):
    # Specify the input shape. Ensure the depth (channels) is a multiple of block_size^2.
    # Example: If block_size is 2 and your input has 4 channels, then the depth is compatible.
    # Example input shape with compatible depth for supported block sizes
    # The feature dimension also has to be divisible by a multiple of block_size^2 for OpenVINO (128 divisible by 2^2)
    input_shape = (128, 128, 64)

    model = DepthToSpaceNet(input_shape, block_size)
    model.save("DepthToSpace_{}.keras".format(block_size))

    print("Models saved successfully.")


if __name__ == "__main__":
    # Check if an block_size was passed as a command-line argument
    if len(sys.argv) != 2:
        print("Usage: python3 model_tf.py <block_size>")
        exit(1)

    # Convert the first command-line argument to an integer
    block_size = int(sys.argv[1])
    main(block_size)

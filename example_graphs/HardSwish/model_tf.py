# This is a TensorFlow example of HardSwish
# This script generates a folder named 'HardSwish' which contains the saved model from model_tf.py
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that TensorFlow HardSwish is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

import os
import sys

sys.path.append(os.path.abspath(os.path.join(os.path.dirname(__file__), '..')))
from custom_tf_layers import HardSwishLayer  # noqa: E402
from tensorflow.keras.layers import Dense, Input, ReLU  # noqa: E402
from tensorflow.keras.models import Model  # noqa: E402


def HardSwishNet(num_neurons, input_dim):
    inputs = Input(shape=(input_dim,), batch_size=num_neurons, name="input")
    x = Dense(num_neurons)(inputs)
    x = ReLU()(x)
    x = Dense(1)(x)
    x = HardSwishLayer(name="hard_swish")(x)
    return Model(inputs={'input': inputs}, outputs=x, name="HardSwishNet")


def main():
    num_neurons = 8
    input_dim = 2
    model = HardSwishNet(num_neurons, input_dim)
    model.summary()
    model.save('HardSwish.keras')


if __name__ == "__main__":
    main()

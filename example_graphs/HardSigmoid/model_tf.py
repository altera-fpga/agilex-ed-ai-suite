# This is a TensorFlow example of HardSigmoid
# This script generates a folder named 'HardSigmoid' which contains the saved model from model_tf.py
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that TensorFlow HardSigmoid is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file

import tensorflow as tf
from tensorflow.keras.layers import Activation, Dense, Input, ReLU
from tensorflow.keras.models import Model


def HardSigmoidNet(num_neurons, input_dim):
    inputs = Input(shape=(input_dim,), batch_size=num_neurons, name="input")
    x = Dense(num_neurons)(inputs)
    x = ReLU()(x)
    x = Dense(1)(x)
    x = Activation(tf.keras.activations.hard_sigmoid, name="hard_sigmoid")(x)
    return Model(inputs={'input': inputs}, outputs=x, name="HardSigmoidNet")


def main():
    num_neurons = 8
    input_dim = 2
    model = HardSigmoidNet(num_neurons, input_dim)
    model.build((num_neurons, input_dim))
    model.save("HardSigmoid.keras")


if __name__ == "__main__":
    main()

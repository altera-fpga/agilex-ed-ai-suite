# This is a TensorFlow example of PReLU
# This script generates a folder named 'PReLU' which contains the saved model from model_tf.py
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that TensorFlow PReLU is on the FPGA
#
# Requires at least one of enable_sigmoid, enable_leaky_relu, enable_relu,
# enable_clamp, or enable_round_clamp : true in .arch file
# Requires enable_prelu : true in .arch file

import tensorflow as tf
from tensorflow.keras.layers import Dense, Input, PReLU
from tensorflow.keras.models import Model


def PReLUNet(num_neurons):
    inputs = Input(shape=(num_neurons,), batch_size=1, name="input")
    x = Dense(num_neurons, name="dense1")(inputs)
    x = PReLU(alpha_initializer=tf.keras.initializers.RandomNormal(mean=0.1, stddev=0.05),
              shared_axes=None,
              name="prelu")(x)
    outputs = Dense(1, name="dense2")(x)
    return Model(inputs={'input': inputs}, outputs=outputs, name="PReLUNet")


def main():
    num_neurons = 8
    model = PReLUNet(num_neurons)
    model.summary()
    model.save('PReLU.keras')


if __name__ == "__main__":
    main()

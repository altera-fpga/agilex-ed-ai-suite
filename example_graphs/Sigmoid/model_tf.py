# This is a TensorFlow example of Sigmoid
# This script generates a folder named 'Sigmoid' which contains the saved model from model_tf.py
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that TensorFlow Sigmoid is on the FPGA
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, or enable_round_clamp : true in .arch file
# Requires enable_sigmoid : true in .arch file

from tensorflow.keras.layers import Activation, Dense, Input, ReLU
from tensorflow.keras.models import Model


def SigmoidNet(num_neurons):
    inputs = Input(shape=(num_neurons,), batch_size=1, name="input")
    x = Dense(num_neurons, name="dense1")(inputs)
    x = ReLU(name="relu")(x)
    x = Dense(1, name="dense2")(x)
    outputs = Activation("sigmoid", name="sigmoid")(x)
    return Model(inputs={'input': inputs}, outputs=outputs, name="SigmoidNet")


def main():
    num_neurons = 8
    model = SigmoidNet(num_neurons)
    model.summary()
    model.save('Sigmoid.keras')


if __name__ == "__main__":
    main()

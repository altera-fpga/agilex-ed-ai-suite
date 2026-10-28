# This is the TensorFlow example of ElementWise Multiplication
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so an elementwise multiplication of feature * filter and feature * feature will be on the FPGA respectively
#
# This script generates two folders called ElementWiseNet and FeatureMultiplyNet
# which contains the two saved models from model_tf.py that perform
# Feature by filter multiplication and feature by feature multiplication respectively
#
# Requires at least one of enable_prelu, enable_leaky_relu, enable_relu,
# enable_clamp, enable_round_clamp, or enable_sigmoid : true in .arch file
# Requires enable_eltwise_mult: true in the arch file

from tensorflow.keras.layers import Conv2D, Input
from tensorflow.keras.models import Model


def FeatureMultiplyNet(input_shape):
    # Define the input layer
    inputs = Input(shape=input_shape, name='input', dtype='float32')

    # Create two convolutions
    feature_map1 = Conv2D(filters=64, kernel_size=3, strides=1, padding='same')(inputs)
    feature_map2 = Conv2D(filters=64, kernel_size=3, strides=1, padding='same')(inputs)

    # Create the model
    model = Model(inputs={'input': inputs}, outputs=feature_map1 * feature_map2, name='FeatureMultiplyNet')

    return model


def main():
    # Create the model
    input_shape = (8, 8, 3)
    model = FeatureMultiplyNet(input_shape)
    model.build((1, *input_shape))
    model.save("FeatureMultiplyNet.keras")

    print("Models saved successfully.")


if __name__ == "__main__":
    main()

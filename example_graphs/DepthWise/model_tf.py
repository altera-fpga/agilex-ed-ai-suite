# This is a TensorFlow example of DepthWise Separable Convolution
#
# Run generate_graph.sh with a TF argument which will run this Python script and
# then generate an OpenVINO IR to be compiled with the dla compiler
# so that DepthWise Seperable Convolution is on the FPGA
#
# This script generates a graph file named 'DepthWise.keras'
# which contains the saved model from model_tf.py

from tensorflow.keras.layers import Conv2D, DepthwiseConv2D, Input
from tensorflow.keras.models import Model


def DepthwiseSeparableConvNet(input_shape):
    # Define the input layer
    inputs = Input(shape=input_shape, name='input', dtype='float32')

    # Depthwise Convolution with bias
    depthwise_conv = DepthwiseConv2D(kernel_size=3, strides=1, padding='same', use_bias=True, name='depthwise_conv')(inputs)

    # Pointwise Convolution with bias
    pointwise_conv = Conv2D(filters=64, kernel_size=1, strides=1, padding='same', use_bias=True, name="output")(depthwise_conv)

    # Create the model
    model = Model(inputs={'input': inputs}, outputs=pointwise_conv, name='DepthWise')

    return model


def main():
    # Create the model
    input_shape = (224, 224, 3)
    model = DepthwiseSeparableConvNet(input_shape)

    model.save("DepthWise.keras")


if __name__ == "__main__":
    main()

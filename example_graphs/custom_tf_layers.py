"""This module defines custom TensorFlow layers"""
import tensorflow as tf
from tensorflow.keras.layers import Layer


@tf.keras.utils.register_keras_serializable()
class DepthToSpaceLayer(Layer):
    def __init__(self, block_size, **kwargs):
        super().__init__(**kwargs)
        self.block_size = block_size

    def call(self, inputs):
        return tf.nn.depth_to_space(inputs, self.block_size)

    def get_config(self):
        config = super().get_config()
        config.update({'block_size': self.block_size})
        return config


@tf.keras.utils.register_keras_serializable()
class HardSwishLayer(Layer):
    def call(self, features):
        fdtype = features.dtype
        return features * tf.nn.relu6(features + tf.cast(3., fdtype)) * (1. / 6.)

    def get_config(self):
        base_config = super().get_config()
        return base_config

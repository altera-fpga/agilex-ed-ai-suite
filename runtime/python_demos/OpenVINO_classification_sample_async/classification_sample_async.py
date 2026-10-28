#!/usr/bin/env python3
# -*- coding: utf-8 -*-
# Copyright (C) 2018-2022 Altera Corporation
# SPDX-License-Identifier: Apache-2.0

import argparse
import logging as log
import os
import sys
import warnings

import cv2
import numpy as np
from openvino.preprocess import PrePostProcessor
from openvino.runtime import AsyncInferQueue, Core, InferRequest, Layout, Type


def parse_args() -> argparse.Namespace:
    """Parse and return command line arguments."""
    parser = argparse.ArgumentParser(add_help=False)
    args = parser.add_argument_group('Options')
    # fmt: off
    args.add_argument('-h', '--help', action='help',
                      help='Show this help message and exit.')
    args.add_argument('-m', '--model', type=str, required=True,
                      help='Required. Path to an .xml or .onnx file with a trained model.')
    args.add_argument('-i', '--input', type=str, required=True, nargs='+',
                      help='Required. Path to an image file(s).')
    args.add_argument('-d', '--device', type=str, default='CPU',
                      help='Optional. Specify the target device to infer on; CPU, GPU, MYRIAD, HDDL or HETERO: '
                      'is acceptable. The sample will look for a suitable plugin for device specified. '
                      'Default value is CPU.')
    # fmt: on
    return parser.parse_args()


def completion_callback(infer_request: InferRequest, image_path: str) -> None:
    predictions = next(iter(infer_request.results.values()))

    # Change a shape of a numpy.ndarray with results to get another one with one dimension
    probs = predictions.reshape(-1)

    # Get an array of 10 class IDs in descending order of probability
    top_10 = np.argsort(probs)[-10:][::-1]

    header = 'class_id probability'

    log.info(f'Image path: {image_path}')
    log.info('Top 10 results: ')
    log.info(header)
    log.info('-' * len(header))

    for class_id in top_10:
        probability_indent = ' ' * (len('class_id') - len(str(class_id)) + 1)
        log.info(f'{class_id}{probability_indent}{probs[class_id]:.7f}')

    log.info('')


def main() -> int:
    log.basicConfig(format='[ %(levelname)s ] %(message)s', level=log.INFO, stream=sys.stdout)
    args = parse_args()

# --------------------------- Step 1. Initialize OpenVINO Runtime Core ------------------------------------------------
    log.info('Creating OpenVINO Runtime Core')
    dla_plugins = os.environ.get('DLA_PLUGINS', default='')
    if dla_plugins == '':
        # Backwards compatability for old DLA_PLUGINS_XML_FILE
        warnings.warn("DLA_PLUGINS_XML_FILE option is deprecated as of 2024.1, Please use DLA_PLUGINS") 
        dla_plugins = os.environ.get('DLA_PLUGINS_XML_FILE', default='')
    core = Core(dla_plugins)
    if "FPGA" in args.device:
        dla_arch_file = os.environ.get('DLA_ARCH_FILE')
        if dla_arch_file is None:
            raise Exception(f"To use FPGA, you need to specify the path to an arch_file!")
        core.set_property(device_name="FPGA", properties={"ARCH_PATH": dla_arch_file})

# --------------------------- Step 2. Read a model --------------------------------------------------------------------
    log.info(f'Reading the model: {args.model}')
    # (.xml and .bin files) or (.onnx file)
    model = core.read_model(args.model)

    if len(model.inputs) != 1:
        log.error('Sample supports only single input topologies')
        return -1

    if len(model.outputs) != 1:
        log.error('Sample supports only single output topologies')
        return -1

# --------------------------- Step 3. Set up input --------------------------------------------------------------------
    # Read input images
    images = [cv2.imread(image_path) for image_path in args.input]

    # Resize images to model input dims
    # Assuming we always have w=h, we will 
    # figure out the layout from the dimensions
    # start with the assumption of NHWC (TF)
    _, h, w, c = model.input().shape

    if h != w:
        c = h
        h = w

    resized_images = [cv2.resize(image, (w, h)) for image in images]

    # Add N dimension
    input_tensors = [np.expand_dims(image, 0) for image in resized_images]

    # Transpose from NHWC to NCHW
    input_tensors = [np.transpose(tensor, (0, 3, 1, 2)) for tensor in input_tensors]

# --------------------------- Step 4. Apply preprocessing -------------------------------------------------------------
    ppp = PrePostProcessor(model)

    # 1) Set input tensor information:
    # - input() provides information about a single model input
    # - layout of data is 'NCHW'
    ppp.input().tensor().set_layout(Layout('NCHW'))  # noqa: N400

    # 2) Here we suppose model has 'NCHW' layout for input
    # DLA --> We let the demo select the layout based on the model
    # ppp.input().model().set_layout(Layout('NCHW'))

    # 3) Set output tensor information:
    # - precision of tensor is supposed to be 'f32'
    ppp.output().tensor().set_element_type(Type.f32)

    # 4) Apply preprocessing modifing the original 'model'
    model = ppp.build()

# --------------------------- Step 5. Loading model to the device -----------------------------------------------------
    log.info('Loading the model to the plugin')
    compiled_model = core.compile_model(model, args.device)

# --------------------------- Step 6. Create infer request queue ------------------------------------------------------
    log.info('Starting inference in asynchronous mode')
    # create async queue with optimal number of infer requests
    infer_queue = AsyncInferQueue(compiled_model)
    infer_queue.set_callback(completion_callback)

# --------------------------- Step 7. Do inference --------------------------------------------------------------------
    for i, input_tensor in enumerate(input_tensors):
        infer_queue.start_async({0: input_tensor}, args.input[i])

    infer_queue.wait_all()
# ----------------------------------------------------------------------------------------------------------------------
    log.info('This sample is an API example, for any performance measurements please use the dedicated benchmark_app tool\n')
    return 0


if __name__ == '__main__':
    sys.exit(main())

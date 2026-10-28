# This script runs the OpenVINO convert_model functionality to convert various models
# to OpenVINO IR format - .xml, .bin files.
#
# The PyTorch / ONNX path (--framework PT) only requires the OpenVINO Python package.
# TensorFlow is imported lazily and only when --framework TF is used.

import argparse
import sys
from pathlib import Path

import openvino as ov


def convert_tf_model(model_file: Path, output_ir_path: Path):
    # Lazy imports: keep the PT/ONNX path free of TensorFlow (and its dependency fights
    # with the OpenVINO / FPGA AI Suite Python environment).
    import custom_tf_layers  # noqa: F401  # registers custom Keras layers for load_model
    import tensorflow as tf

    model = tf.keras.models.load_model(model_file)
    inputs = model.inputs
    outputs = model.outputs
    # Force batch size 1 for all inputs
    input_shapes = {}

    for inp in inputs:
        name = inp.name.split(":")[0]
        shape = list(inp.shape)
        if len(shape) == 4:
            shape = [1] + [d if d is not None else -1 for d in shape[1:]]
        else:
            shape = [d if d is not None else -1 for d in shape]
        input_shapes[name] = shape
    ov_model = ov.convert_model(model, input=input_shapes)

    # TensorFlow uses NHWC layout by default while OpenVINO expects NCHW. We transpose
    # everything to NCHW here so that OpenVINO does not insert transpose nodes in the graph
    # that would be unsupported by the FPGA
    prep = ov.preprocess.PrePostProcessor(ov_model)
    for idx, input in enumerate(inputs):
        if len(input.shape) < 4:
            continue
        name = input.name.split(":")[0]
        prep.input(name).model().set_layout(ov.Layout("nhwc"))
        prep.input(name).tensor().set_layout(ov.Layout("nchw"))

    for idx, output in enumerate(outputs):
        if len(output.shape) < 4:
            continue
        name = output.name.split(":")[0]
        prep.output(name).model().set_layout(ov.Layout("nhwc"))
        prep.output(name).tensor().set_layout(ov.Layout("nchw"))
    ov_model = prep.build()

    ov.save_model(ov_model, output_ir_path, compress_to_fp16=False)


def convert_pt_model(model_file: Path, output_ir_path: Path):
    model = ov.convert_model(model_file)
    ov.save_model(model, output_ir_path, compress_to_fp16=False)


if __name__ == "__main__":
    # Special case: if first argument is "YOLOv8", delegate to YOLOv8 converter
    if len(sys.argv) > 1 and sys.argv[1] == "YOLOv8":
        # Import and run YOLOv8 converter
        script_dir = Path(__file__).parent
        yolov8_dir = script_dir / "YOLOv8"

        if not (yolov8_dir / "converter.py").exists():
            print("Error: YOLOv8 converter not found!")
            sys.exit(1)

        # Add yolov8 directory to path and import converter
        sys.path.insert(0, str(yolov8_dir))
        from converter import YOLOv8Converter

        # Create converter and run it
        converter = YOLOv8Converter()

        # Create parser for YOLOv8
        parser = argparse.ArgumentParser(
            description=converter.description,
            prog=f"{sys.argv[0]} YOLOv8"
        )
        converter.add_arguments(parser)

        # Parse arguments (excluding "YOLOv8")
        args = parser.parse_args(sys.argv[2:])

        # Convert the model
        output_path = converter.convert(args)
        print(f"YOLOv8 model successfully converted to {output_path}")
        sys.exit(0)

    parser = argparse.ArgumentParser(
        description=(
            "Convert TensorFlow or PyTorch model to OpenVINO IR format."
            "Note: YOLOv8 models are also supported via a separate flow."
            "To convert a YOLOv8 model, run this script with 'YOLOv8' as the first argument."
            "For example: python run_convert_model.py YOLOv8 --h"
        )
    )
    parser.add_argument('model_file', type=str,
                        help="Path to the model file to convert")
    parser.add_argument('--output_dir', type=str, default='./output',
                        help="Directory to save the OpenVINO IR files. Default is './output'.")
    parser.add_argument('--framework', type=str, required=False, default='TF',
                        choices=['TF', 'PT'],
                        help="Framework of the model to convert. Default is TensorFlow (TF)")
    parser.add_argument('--output_name', type=str, default='graph',
                        help="Name of the output IR model file. Default is 'graph'.")
    args = parser.parse_args()

    model_file = Path(args.model_file)
    if not model_file.exists():
        raise FileNotFoundError(f"Model file {model_file} does not exist.")

    output_ir_path = Path(args.output_dir) / f"{args.output_name}.xml"
    if not output_ir_path.parent.exists():
        output_ir_path.parent.mkdir(parents=True, exist_ok=True)

    if args.framework == "TF":
        convert_tf_model(model_file, output_ir_path)
    else:  # PT
        convert_pt_model(model_file, output_ir_path)

    print(f"Model successfully converted to {output_ir_path}")

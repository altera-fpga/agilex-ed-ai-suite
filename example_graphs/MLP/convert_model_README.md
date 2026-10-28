# README for MLP graph generation and convert model

This file describes how to generate multilayer perceptron (MLP) graphs
and how to convert them to OpenVINO IR for `dla_compiler`.

The OpenVINO Model Optimizer CLI (`mo`) is **not** used. Conversion uses
`run_convert_model.py`, which calls OpenVINO's `convert_model` API (OVC).

## Recommended flow (PyTorch / ONNX)

Default path — no TensorFlow required. `../requirements.txt` is
self-contained, so a fresh virtual environment is enough; the suite-wide
requirements and packages belonging to other samples (such as OpenCV)
are not needed here:

```bash
cd "$COREDLA_WORK/example_graphs" 2>/dev/null || cd "$COREDLA_ROOT/example_graphs"
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt
python generate_graph.py MLP
```

An existing FPGA AI Suite or OpenVINO environment works too; the pins
match the ones the suite ships.

That runs `MLP/model_pt.py` (writes `model.onnx`), converts with
`run_convert_model.py --framework PT` (OpenVINO only), then invokes
`dla_compiler`.

### Manual steps (same PT path)

```bash
cd "$COREDLA_WORK/example_graphs/MLP" 2>/dev/null || cd "$COREDLA_ROOT/example_graphs/MLP"
python3 model_pt.py
python3 ../run_convert_model.py model.onnx --framework PT --output_name model --output_dir ./output
```

`model_pt.py` also generates `images/input_0.bin` &hellip; `input_4999.bin`
(if `--in_file` is unspecified), `correct_classifications.txt`, and
`output.txt`. Run `python3 model_pt.py -h` for options.

## Dependencies

| Path | Packages |
|---|---|
| PyTorch / ONNX (default) | `../requirements.txt` &mdash; `torch`, `torchvision`, `onnx`, `numpy`, `openvino`, all pinned. Self-contained; **do not install TensorFlow** for this path. |
| TensorFlow (optional) | `../requirements-tf.txt` in a separate venv. TensorFlow resolves `numpy` and `ml-dtypes` versions that break `onnx` and `model_pt.py` if mixed into the PyTorch environment. |

## Obtaining Prerequisites

To obtain the required OpenVINO Toolkit Components, follow the
`Installing Required OpenVINO Toolkit Components` section of the
Getting Started Guide. You only need the OpenVINO development
environment for conversion; packages used by other samples (for
example OpenCV) are not required for MLP.

## Running Convert Model (standalone)

After activating the OpenVINO environment:

```bash
python3 ../run_convert_model.py {PATH-TO-MODEL.onnx} --framework PT --output_name model --output_dir {OUTPUT-DIRECTORY}
```

Example:

```bash
python3 ../run_convert_model.py ~/neural_net.onnx --framework PT --output_name new_model --output_dir ~/temp
```

This creates `new_model.xml` and `new_model.bin`. For ONNX / PT,
TensorFlow is not imported.

## Running DLA Benchmark

To run the dla benchmark, first build the developer package and then the runtime:

```bash
cd $COREDLA_WORK/runtime
./build_runtime.sh -target_de10_agilex
```

After building the developer package and the runtime, you will be able
to run the dla benchmark on CPU. To run the dla benchmark on FPGA, you
must load a bitstream onto the fpga first:

```bash
cd $COREDLA_WORK/runtime/build_Release
./dla_benchmark/dla_benchmark -b=<batch_size> -m=<path to graph.xml> -d=HETERO:FPGA,CPU -i <path to images folder> -niter=<number of iterations> -plugins=./plugins.xml -arch_file=<path to .arch file> -api=async -groundtruth_loc=<path to groundtruth file, optional> -perf_est -nireq=<number of inference request>
```

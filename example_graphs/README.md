# Example Graphs

Sample neural-network graphs used to exercise the FPGA AI Suite
compiler on representative workloads.  Each graph is available in
both PyTorch and TensorFlow (unless noted), gets serialized to an
ONNX or TF SavedModel format, and is then converted to OpenVINO
Intermediate Representation (IR) via OpenVINO&rsquo;s Model Converter
API (`openvino.convert_model` / OVC).  The resulting IR is what the
DLA compiler (`dla_compiler`) ingests.

The OpenVINO Model Optimizer CLI (`mo`) is **not** used and is not
available in OpenVINO 2025.x. Use `generate_graph.py` or
`run_convert_model.py` instead.

## Prerequisites

- **Python 3.12** (verified; 3.8+ is expected to work)
- **Packages for these samples** &mdash; see below.
- **FPGA AI Suite** &mdash; only needed to compile the resulting IR with
  `dla_compiler`. Generating the graphs and converting them to IR needs
  nothing beyond the requirements files below.

### Sample packages

Each path ships its own requirements file, and each one is
self-contained: it installs everything needed in a fresh virtual
environment, `openvino` included. You do not need the suite-wide
`$COREDLA_ROOT/requirements.txt`, and you do not need packages that
belong to other samples (for example OpenCV).

| File | Covers | Pinned packages |
|---|---|---|
| `requirements.txt` | `model_pt.py` &rarr; `.onnx` &rarr; IR (default) | `torch`, `torchvision`, `onnx`, `numpy`, `openvino` |
| `requirements-tf.txt` | `model_tf.py` / `generate_graph.py <MODEL> TF` | `tensorflow`, `openvino` |
| `YOLOv8/requirements.txt` | `run_convert_model.py YOLOv8` | `ultralytics`, `torch`, `torchvision`, `openvino` |

```bash
python3 -m venv venv && source venv/bin/activate
pip install -r requirements.txt        # from this directory (example_graphs/)
```

Every version is pinned, and the pins match the ones the FPGA AI Suite
itself ships in `$COREDLA_ROOT/requirements.txt`, so these samples can
also be installed into an existing FPGA AI Suite environment.

Install `requirements-tf.txt` in a **separate** virtual environment.
TensorFlow 2.18.0 resolves `numpy` 2.0.2 and `ml-dtypes` 0.4.1, which
conflict with the `numpy` 2.2.6 and `onnx` 1.22.0 that the PyTorch path
needs.

`train_kws_mlp.py` is a training helper rather than a graph sample; it
additionally needs `librosa`, `tensorflow`, and `kagglehub`.

## Available graphs

| Directory | Frameworks | Notes |
|---|---|---|
| `ConvReluMaxPoolCeilMode/` | PyTorch | Conv &rarr; ReLU &rarr; MaxPool (ceil mode). |
| `DepthWise/` | PyTorch, TensorFlow | Depthwise convolution. |
| `ElementWiseMultiplication/` | PyTorch, TensorFlow | Element-wise multiply. |
| `HardSigmoid/` | PyTorch, TensorFlow | Hard-sigmoid activation. |
| `HardSwish/` | PyTorch, TensorFlow | Hard-swish activation. |
| `MLP/` | PyTorch, TensorFlow | Multilayer perceptron (see `MLP/convert_model_README.md` for a walkthrough). |
| `PReLU/` | PyTorch, TensorFlow | Parametric ReLU. |
| `PixelShuffle/` | PyTorch, TensorFlow | Pixel-shuffle / depth-to-space. |
| `Sigmoid/` | PyTorch, TensorFlow | Sigmoid activation. |
| `Swish/` | PyTorch, TensorFlow | Swish activation. |
| `YOLOv8/` | (converter only) | Provides `converter.py` for the Ultralytics YOLOv8 model.  Requires the YOLOv8 checkpoint separately. |

## Generating a graph

There are two entry points; use whichever is more convenient for your
platform.

### Cross-platform (recommended)

The top-level `generate_graph.py` runs any of the supported models on
Linux, macOS, or Windows. The default framework is PyTorch (no
TensorFlow required):

```bash
python generate_graph.py MLP           # defaults to PyTorch / ONNX
python generate_graph.py MLP TF        # TensorFlow (optional; needs requirements-tf.txt)
python generate_graph.py PixelShuffle  # any of the models above
```

For per-model options, invoke the underlying model script directly:

```bash
python MLP/model_pt.py -h
python MLP/model_tf.py -h
```

### Per-model shell wrappers (Linux only)

Each model directory ships `generate_graph.sh` (Linux) and
`generate_graph.bat` (Windows) wrappers:

```bash
# Linux
cd "$COREDLA_WORK/example_graphs/MLP" 2>/dev/null || cd "$COREDLA_ROOT/example_graphs/MLP"
./generate_graph.sh PT              # PyTorch (recommended)
./generate_graph.sh TF              # TensorFlow (optional)
```

Each wrapper generates:

- `model.onnx` (PyTorch) or a TensorFlow SavedModel / `.keras` file
- `images/input_0.bin` &hellip; `input_4999.bin` &mdash; random-input
  binaries in the input tensor&rsquo;s expected shape
- `output.txt` &mdash; expected outputs (used as ground-truth for the
  DLA emulator)
- `correct_classifications.txt` &mdash; expected classifications for
  each input, where applicable

## Converting to OpenVINO IR

Once you have `model.onnx` (or a TensorFlow model), convert it to
OpenVINO IR with `run_convert_model.py`. For ONNX / PyTorch this uses
only OpenVINO (`ov.convert_model`); TensorFlow is not imported:

```bash
source ~/build-openvino-dev/openvino_env/bin/activate
python run_convert_model.py <path-to-model.onnx> \
    --framework PT \
    --output_dir <output-directory> \
    --output_name <base-name>
```

This produces `<base-name>.xml` and `<base-name>.bin`, which are the
inputs the DLA compiler accepts.

## Running through DLA

After you have the OpenVINO IR, build the runtime (from the `runtime/`
tree, also in this repository) and run inference through
`dla_benchmark`:

```bash
cd $COREDLA_WORK/runtime
./build_runtime.sh -target_de10_agilex

cd $COREDLA_WORK/runtime/build_Release
./dla_benchmark/dla_benchmark \
    -b=<batch_size> \
    -m=<path-to-graph.xml> \
    -d=HETERO:FPGA,CPU \
    -i <path-to-images-folder> \
    -niter=<number-of-iterations> \
    -plugins=./plugins.xml \
    -arch_file=<path-to-arch-file> \
    -api=async \
    -perf_est \
    -nireq=<number-of-inference-requests>
```

See the FPGA AI Suite Getting Started Guide for a complete inference
walkthrough including bitstream loading, architecture-file selection,
and performance interpretation.

## Common utility files

| File | Purpose |
|---|---|
| `requirements.txt` | Packages for the default PyTorch / ONNX path. |
| `requirements-tf.txt` | Packages for the optional TensorFlow path; use a separate venv. |
| `YOLOv8/requirements.txt` | Packages for the YOLOv8 converter only. |
| `common_functions.sh` / `.bat` / `.py` | Shared helpers used by the per-model wrappers. |
| `custom_tf_layers.py` | Custom TensorFlow layer definitions referenced by some TF models. |
| `run_convert_model.py` | Thin wrapper around OpenVINO&rsquo;s `convert_model` API (OVC). TF is optional and only loaded for `--framework TF`. |
| `train_kws_mlp.py` | Trains the KWS (Keyword Spotting) MLP model used in some downstream demos. |
| `generate_graph.py` | Cross-platform entry point that dispatches to per-model scripts. |

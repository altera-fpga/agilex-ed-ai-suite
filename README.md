# FPGA AI Suite Example Designs

This repo hosts the runtime, example designs, and sample neural-network
graphs for the [FPGA AI Suite](https://www.altera.com/products/development-tools/fpga-ai-suite):

- **`platform/`** &mdash; a set of configured example designs covering the
  different development boards, connectivity types, and FPGA families that
  the FPGA AI Suite supports.  Each project drives Quartus (and, where
  applicable, OFS) through a common build utility.
- **`runtime/`** &mdash; the FPGA AI Suite runtime and its demo applications:
  `dla_benchmark`, `dla_aot_splitter`, the OpenVINO plugin, python demos,
  and MMD device backends (JTAG, OFS PCIe, DCP A10 PAC).
- **`hps/`** &mdash; scripts and Yocto recipes used to build the HPS
  (Hard Processor System) images that run the runtime on SoC boards.
- **`example_graphs/`** &mdash; sample neural-network graphs (PyTorch,
  TensorFlow) processed via OpenVINO's OVC tool into IR, used to
  exercise the FPGA AI Suite compiler on representative workloads.
- **`spatial_examples/`** &mdash; Various different examples showcasing
  how to use the spatial compiler, emulation, and developer API for different models.

The FPGA AI Suite is a collection of tools for efficiently running AI
inference on Altera FPGAs.  You can obtain a copy from the
[official downloads page](https://www.altera.com/products/development-tools/fpga-ai-suite).

> [!IMPORTANT]
> All examples have a hard limit of 100&nbsp;000 inference requests.
> Please refer to the documentation on
> ["--licensed/--unlicensed" IP generation](https://docs.altera.com/r/docs/863373/2026.1.1/fpga-ai-suite-handbook/ip-generation-utility-command-line-options)
> for details about this limitation.

Full details on how to install the FPGA AI Suite, including all software
and hardware requirements, are available in
[Chapter 4](https://docs.altera.com/r/docs/863373/2026.1.1/installing-the-fpga-ai-suite-compiler-and-ip-generation-tools)
of the [FPGA AI Suite Handbook](https://docs.altera.com/r/docs/863373/2026.1.1/fpga-ai-suite-handbook/fpga-ai-suite-handbook).
The individual READMEs for each example also contain any additional
requirements and setup instructions particular to that example.

## Repository layout

```text
.
├── platform/         Example-design projects (per board) + shared build scripts
├── runtime/          FPGA AI Suite runtime, demo apps, MMD backends
├── hps/              HPS Yocto recipes and SD-card build scripts
└── example_graphs/   Sample neural-network graphs (PyTorch, TF -> OpenVINO IR)
└── spatial_examples/ Examples of how to run certain models in Spatial
```

See [`platform/README.md`](platform/README.md) for the example-design
project structure, the `dla_build_example_design.py` compile flow, and
the QoR reporting utility.

## Installation

Two options: automatic (recommended) or manual.

### Automatic

`dla_init_local_directory.sh` (shipped with the FPGA AI Suite)
downloads the matching release into `$COREDLA_WORK/` if `platform/`,
`runtime/`, `hps/`, or `example_graphs/` are not already under
`$COREDLA_ROOT/`.  Downstream tools check both locations, so nothing
else is needed.  This is the recommended path for installations where
`$COREDLA_ROOT` is read-only (`.rpm` / `.deb` installs).

### Manual

For offline installs, or when you have a writable install tree and
want the content under `$COREDLA_ROOT/`, clone this repository and
copy the four subtrees into the FPGA AI Suite install root.  Use the
HTTPS URL shown under GitHub's **Code** dropdown for the clone step:

```bash
git clone <repository URL> example-designs
cp -r example-designs/{platform,runtime,hps,example_graphs} "$COREDLA_ROOT/"
```

Only those four subtrees are needed &mdash; repository-only files
(`LICENSE.md`, `README.md`, `SECURITY.md`, `.github/`) do not belong
in the install tree.

### Choosing a release

Releases here are tagged `rel-<version>` to match the paired FPGA AI
Suite release version.  For example, if your installed FPGA AI Suite
reports version `26.3` (visible in the install root&rsquo;s
`build_version.txt`), check out `rel-26.3` in this repository before
running the installation steps above.

Example designs are also updated between FPGA AI Suite releases.  Those
updates are tagged `rel-<version>-<N>`, so `rel-26.3-1` is the first
update for FPGA AI Suite 26.3.  They pair with the same FPGA AI Suite
release, and the highest `<N>` is the newest.

[`platform/version.txt`](platform/version.txt) records which of these
you have, written without the `rel-` prefix.

## Example designs

Example designs live under [`platform/`](platform/).  Boards with a
dedicated README document any board-specific setup; the remaining
projects share the common flow described in
[`platform/README.md`](platform/README.md).

### Hostless

Hostless example designs demonstrate how to directly control the FPGA
AI Suite IP over JTAG.

| Family | Development Board |
| ------ | ----------------- |
| Agilex 3 | [Agilex 3C Development Kit](platform/agx3c_jtag/) |
| Agilex 5 | [Agilex 5E Modular Development Kit](platform/agx5e_modular_jtag/) |
| Agilex 5 | [Agilex 5E Modular &mdash; spatial JTAG](platform/agx5e_modular_spatial_jtag/) |

### PCIe-attach

PCIe-attach example designs demonstrate how a host computer can use the
FPGA AI Suite to offload AI workloads onto an FPGA via PCIe.

| Family | Development Board |
| ------ | ----------------- |
| Agilex 5 | [Agilex 5 FPGA E-Series 065B Modular Development Kit](platform/agx5e_modular_ofs_pcie/) |
| Agilex 7 | [Terasic DE10-Agilex Development Board](platform/agx7_de10_pcie/) |
| Agilex 7 | [Agilex 7 FPGA I-Series Development Kit (2x R-Tile and 1x F-Tile)](platform/agx7_iseries_ofs_pcie/) |
| Agilex 7 | [Intel FPGA SmartNIC N6001-PL Platform](platform/agx7_n6001_ofs_pcie/) |

### SoC (m2m / s2m)

SoC example designs demonstrate the memory-to-memory (m2m) and
stream-to-memory (s2m) flows on Altera SoC FPGAs.  Refer to
[`platform/README.md`](platform/README.md) for the common build
utility; per-board projects live under `platform/{a10,agx3,agx5,agx7}_soc_*`.

## Example graphs

Sample neural-network graphs used to exercise the FPGA AI Suite
compiler on representative workloads.  Each graph ships with PyTorch
and TensorFlow model definitions, a generator script that emits ONNX
or TF SavedModel plus deterministic input/output binaries for
regression testing, and (for most) both Linux `.sh` and Windows
`.bat` wrappers.  A cross-platform `generate_graph.py` entry point
dispatches to any of the models on Linux, macOS, and Windows.

See [`example_graphs/README.md`](example_graphs/README.md) for the
full generate &rarr; OVC-convert &rarr; `dla_benchmark` workflow.

| Graph | Frameworks | Demonstrates |
| ----- | ---------- | ------------ |
| [ConvReluMaxPoolCeilMode](example_graphs/ConvReluMaxPoolCeilMode/) | PyTorch | Conv &rarr; ReLU &rarr; MaxPool with ceil-mode rounding. |
| [DepthWise](example_graphs/DepthWise/) | PyTorch, TensorFlow | Depthwise-separable convolution. |
| [ElementWiseMultiplication](example_graphs/ElementWiseMultiplication/) | PyTorch, TensorFlow | Element-wise multiply between two tensors. |
| [HardSigmoid](example_graphs/HardSigmoid/) | PyTorch, TensorFlow | Piecewise-linear sigmoid approximation. |
| [HardSwish](example_graphs/HardSwish/) | PyTorch, TensorFlow | `x * ReLU6(x + 3) / 6` &mdash; MobileNet-v3-style activation. |
| [MLP](example_graphs/MLP/) | PyTorch, TensorFlow | Multilayer perceptron classifier (also see [`MLP/convert_model_README.md`](example_graphs/MLP/convert_model_README.md)). |
| [PReLU](example_graphs/PReLU/) | PyTorch, TensorFlow | Parametric ReLU with a learnable negative slope. |
| [PixelShuffle](example_graphs/PixelShuffle/) | PyTorch, TensorFlow | Sub-pixel convolution / depth-to-space rearrangement. |
| [Sigmoid](example_graphs/Sigmoid/) | PyTorch, TensorFlow | Standard sigmoid activation. |
| [Swish](example_graphs/Swish/) | PyTorch, TensorFlow | `x * sigmoid(x)` activation. |
| [YOLOv8](example_graphs/YOLOv8/) | Converter only | Wrapper around the Ultralytics YOLOv8 checkpoint. |

## License

See [`LICENSE.md`](LICENSE.md) at the repository root.  Individual file
headers control for the files they cover.

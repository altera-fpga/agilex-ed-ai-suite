# Agilex 7 I-Series OFS PCIe Spatial Example Design

PCIe-attached Spatial (SPARK) inference on the Agilex 7 FPGA I-Series Development Kit
with OFS. Design ID: `agx7_iseries_ofs_pcie_spatial`.

**Constraint:** this example design supports **exactly one input port and one
output port**. Models with multiple inputs or outputs are rejected during
project setup.

## Prerequisites

- Quartus Prime matching the design’s required version (see `example_design.json`).
- OFS FIM PR template on `OPAE_PLATFORM_ROOT`, for example:

```bash
export OPAE_PLATFORM_ROOT=/p/psg/swip/dla/ofs_fim/2025.1/iseries/pr_build_template
```

- A **spatial** `.arch` file (for example Magika’s `magika_agx7.arch` under
  `external/spatial_examples/magika/`, or another AGX7 spatial arch).

Kick off every hardware build with `dla_build_example_design.py`. It generates
Spatial IP (via `dla_create_ip`), stages the OFS AFU, and runs Quartus.

---

## 1. Compiler (push-button)

Use an OpenVINO IR (`.xml` + `.bin`) and a spatial `.arch`. The build
script compiles the graph to Spatial RTL, embeds stimulus/golden data, and
builds the bitstream.

```bash
export ARCH="$COREDLA_ROOT/external/spatial_examples/magika/magika_agx7.arch"
export MODEL="$COREDLA_ROOT/python/model_zoo/models/magika-standard-v3-3/IR/magika-standard-v3-3.xml"
export OUTPUT_DIR="$PWD/iseries_ofs_build"

dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --model "$MODEL" \
  --output-dir "$OUTPUT_DIR"
```

`--model` must be a single-input / single-output network for this ED.

To reuse IP already generated under `$OUTPUT_DIR/coredla_ip`:

```bash
dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --skip-ip-gen --ip-dir "$OUTPUT_DIR/coredla_ip" \
  --output-dir "$PWD/iseries_ofs_reuse"
```

A full Magika walkthrough (IR export, arch, and OFS build) is in
[`external/spatial_examples/magika/README.md`](../../spatial_examples/magika/README.md).

---

## 2. Developer API (saved model)

A complete DAG + `save_model` example is also in
[`external/spatial_examples/create_ip_flow/`](../../spatial_examples/create_ip_flow/).

### Build the example design from the saved model

```bash
ARCH="$COREDLA_ROOT/external/spatial_examples/magika/magika_agx7.arch"   # or your spatial .arch. Simple arch is sufficient for developer API.
MODEL_DIR="$PWD/saved_model" # `$MODEL_DIR` must contain `model.protobuf` and `data.safetensors`.
OUTPUT_DIR="$PWD/iseries_ofs_build"

dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --model "$MODEL_DIR" \
  --output-dir "$OUTPUT_DIR"
```

To reuse IP already generated under `$OUTPUT_DIR/coredla_ip`:

```bash
dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --skip-ip-gen --ip-dir "$OUTPUT_DIR/coredla_ip" \
  --output-dir "$PWD/iseries_ofs_reuse"
```

---

## 3. Runtime
Please refer to runtime/spatial_python for instructions on how to run magika, resnet or a generic LLM. Or runtime/dla_benchmark for instructions on how to run a generic image model.
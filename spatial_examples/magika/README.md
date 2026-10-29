## Magika Spatial examples

Two scripts emulate the same Magika file-type classifier on Spatial:

- `magika_spatial.py` hand-built DAG with the Spatial developer API (the `MAGIKA`
  class), loading weights straight from the Magika ONNX model.
- `magika_spatial_small.py` hand-built DAG with the Spatial developer API. 
  Modified to fit on Agilex 5 JTAG ED.
- `spatial_emulator.py` compiles the exported OpenVINO IR with `sc.compile()` and
  runs the resulting Spatial model.

Both share Magika's feature extraction / label lookup, can be cross-checked against
a reference backend, and can drive `run_flow()` to simulate or Quartus-compile the RTL.

## Install

Install the host-side dependencies from [`requirements.txt`](requirements.txt).
[`uv`](https://docs.astral.sh/uv/) is the preferred method.

```bash
uv venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
```

### Alternative: plain Python / pip / venv

If you prefer not to use `uv`:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -U pip
pip install -r requirements.txt
```

## Fetch and convert the OpenVINO IR

Pull the Magika ONNX from the catalog and convert it to OpenVINO IR with
`altera_model_zoo`.
See [`python/model_zoo/README.md`](../../../python/model_zoo/README.md) for more on the catalog and CLI.
Once virtual environment is setup for `altera_model_zoo`, use the following command to export an OpenVINO magika model.
```bash
altera_model_zoo convert magika-standard-v3-3
```

The IR lands at
`python/model_zoo/models/magika-standard-v3-3/IR/magika-standard-v3-3.xml`
(paired `.bin` next to it).

## Running the hand-built example (magika_spatial.py)

Run `python magika_spatial.py` to run emulation and dump files.

Arguments:
--reference onnx|openvino_cpu|none to cross-check the Spatial result against a ground-truth backend (default onnx)
--sim for VCS simulation and compare results against emulation (estimated runtime 30 mins)
--compile for Quartus compile and see fmax and resource usage (estimated runtime 40 mins)
--dump-input-only to generate only the input hex file without running emulation
--evaluate-output-only <file> to evaluate an output hex file and print the predicted class
--file <path> to specify an input file for classification

Example with the model-zoo IR:

```bash
python magika_spatial.py
```

## Running the compiler example (spatial_emulator.py)

Compile the OpenVINO IR with the Spatial compiler and emulate the Spatial model:

```bash
python spatial_emulator.py \
  --ov-model $COREDLA_ROOT/python/model_zoo/models/magika-standard-v3-3/IR/magika-standard-v3-3.xml
```

Arguments:
--ov-model <path> OpenVINO XML from altera_model_zoo to compile (default magika.xml)
--reference onnx|openvino_cpu|none to cross-check the Spatial result against a ground-truth backend (default onnx)
--dump-path <path> directory for Spatial compilation outputs (default ./spatial_emulator_dump)
--sim for VCS simulation and compare results against emulation (estimated runtime 30 mins)
--compile for Quartus compile and see fmax and resource usage (estimated runtime 40 mins)
--file <path> to specify an input file for classification

## `dla_compiler` push-button flow

Use the checked-in Magika architecture with the model-zoo IR:

```bash
ARCH="$PWD/magika_agx7.arch"
MODEL="$COREDLA_ROOT/python/model_zoo/models/magika-standard-v3-3/IR/magika-standard-v3-3.xml"

dla_compiler \
  --march "$ARCH" \
  --network-file "$MODEL"
```

The `.bin` file paired with the OpenVINO `.xml` must remain in the same
directory.

## Generate a standalone Spatial IP or build an OFS example design

Use `dla_create_ip` directly when you need a standalone IP or saved DAG:

```bash
ARCH="$PWD/magika_agx7.arch"
MODEL="$COREDLA_ROOT/python/model_zoo/models/magika-standard-v3-3/IR/magika-standard-v3-3.xml"
IP_DIR="$PWD/coredla_ip"

dla_create_ip \
  --arch "$ARCH" \
  --model "$MODEL" \
  --ip-dir "$IP_DIR"
```

The completed DAG is saved under
`$IP_DIR/altera_ai_ip/verilog/<model>_<arch-stem>_<family>/saved_model/`.

Alternatively, call `dla_build_example_design.py` directly. It invokes
`dla_create_ip`, so the standalone command above is not a prerequisite:

```bash
OUTPUT_DIR="$PWD/magika_ofs"

dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --model "$MODEL" \
  --output-dir "$OUTPUT_DIR"
```

To reuse the generated IP without compiling the model again:

```bash
dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --skip-ip-gen --ip-dir "$OUTPUT_DIR/coredla_ip" \
  --output-dir "$PWD/magika_ofs_reuse"
```

Catalog tag: `magika-standard-v3-3` (Google Magika standard v3.3 ONNX).

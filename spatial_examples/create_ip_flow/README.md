# Spatial Python API IP creation example

`MLP.py` demonstrates how a model built directly with the Spatial Python layer
API is passed to `dla_create_ip`.

The model is a three-layer MLP. Each hidden layer contains a `Dot`, `Add_bias`,
and ReLU `Activation` layer. The script creates random BF16 weights, constructs
the layer graph, and sets its input shape to `(1, 1, 32)`.

## Create the saved model

From this directory, run:

```bash
python MLP.py --save_model --output_path MLP
```

This calls `run_flow()` and serializes the Python layer graph into `MLP/`:

- `model.protobuf` contains the graph topology and layer configuration.
- `data.safetensors` contains the generated weights and other tensor data.

The resulting `MLP/` directory is the model input to `dla_create_ip`; the
original `MLP.py` file is not passed directly.

## Generate and simulate the IP

After initializing the FPGA AI Suite environment, run the complete flow from
this directory:

```bash
MODEL_DIR="$(pwd)/MLP"
ARCH="$COREDLA_ROOT/example_architectures/AGX7_Simple_Spatial.arch"
IP_DIR="$PWD/coredla_ip"

python MLP.py --save_model --output_path "$MODEL_DIR"

dla_create_ip \
  --arch "$ARCH" \
  --model "$MODEL_DIR" \
  --ip-dir "$IP_DIR"

cd "$IP_DIR/altera_ai_ip/sim"
python dla_sim.py \
  --model "$MODEL_DIR" \
  --arch "$ARCH" \
  --simulation_tool questa
```

`dla_create_ip` restores the saved Spatial model, including its input shape,
and generates the RTL and simulation environment under `coredla_ip/`. It also
normalizes the completed DAG to
`coredla_ip/altera_ai_ip/verilog/<model>_<arch-stem>_<family>/saved_model/`,
containing `model.protobuf` and `data.safetensors`. Replace `questa` with `vcs`
to use VCS.

The same IP can be reused by an example-design build:

```bash
dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --skip-ip-gen --ip-dir "$IP_DIR" \
  --output-dir "$IP_DIR/../ofs_build"
```

Because `MLP.py` generates random weights, the saved tensor data changes each
time the script runs.

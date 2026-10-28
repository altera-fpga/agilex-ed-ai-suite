# Spatial Python MMD runtimes

Host-side preprocess / postprocess helpers that bind to the **pybind11**
`spatial_mmd` module (built and installed with the AGX7 spatial runtime).

| Path | Role |
|------|------|
| `mmd_binding/` | Package: dtype conversions, `SpatialMmd`, pybind `spatial_mmd*.so` |
| `image_classification_runtime.py` | Image → NCHW integers → MMD → FP32 → CIFAR-10 |
| `magika_runtime.py` | Magika features → MMD → FP32 → Magika labels |
| `llm_runtime.py` | `--model` (HuggingFace id) → tokenizer + embeddings → prefill/decode |
| `requirements.txt` | Python packages needed to build and run the above |

### `mmd_binding` layout

| Module | Contents |
|--------|----------|
| `conversions.py` | BF16/FP32 encode/decode helpers |
| `interface.py` | `MmdDevice` protocol |
| `device.py` | `SpatialMmd`, `open_mmd()` |
| `spatial_mmd*.so` | pybind11 extension (built by runtime CMake) |

## Building / packaging

From the repository root:

```bash
cd runtime

python -m venv my_venv
source my_venv/bin/activate
pip install -r spatial_python/requirements.txt

# Agilex 7 I-Series OFS PCIe spatial
./build_runtime.sh -target_spatial_ofs_pcie -install_dir=install_dir

# Agilex 5 E-Series Modular JTAG spatial
./build_runtime.sh -target_agx5_jtag_spatial -install_dir=install_dir
```

Install layout:

```
install_dir/
  lib/
    libspatial_mmd.a                # static (spatialPlugin)
    spatial_mmd*.so                 # pybind module
  spatial_python/
    mmd_binding/
      device.py
      …
    llm_runtime.py                  # Python runtime wrappers
    requirements.txt
    ...
```

## pybind API (process-wide session)

| Symbol | Notes |
|--------|--------|
| `connect_to_fpga` | Opens process-wide session |
| `load_port_config` | Load `port_config.json` into the MMD session |
| `input_data_width` / `output_data_width` | Geometry from the loaded port config |
| `load_weights` | Scan a directory for `weights_ddr_*.bin` |
| `disconnect_fpga` | Close session |
| `reset` | Soft-reset the IP |
| `run_inference(input)` | 1-D `uint64` numpy array in; output sized from port_config packet ratio |

Weights are **optional** in Python: pass `--load-weights DIR` only when needed to initialize DDR.

## Examples

Run the wrappers from `install_dir` so `mmd_binding` can find `lib/spatial_mmd*.so`,
with the same virtual environment active that was used for the build.

```bash
source my_venv/bin/activate
cd install_dir

# Image classification
python spatial_python/image_classification_runtime.py \
  --image cat.png --resize 32x32 \
  --port-config port_config.json

# Magika (prompts for a file path)
python spatial_python/magika_runtime.py \
  --port-config port_config.json

# LLM (tokenizer + embeddings from HuggingFace; prompts for text)
python spatial_python/llm_runtime.py \
  --model Qwen/Qwen3-0.6B \
  --port-config port_config.json \
  --load-weights dump_files
```

Image classification reports device inference latency and FPS. Magika reports
device inference latency and files/s for each entered path. The LLM reports
TTFT, prefill and average decode inference latency, total FPGA inference time,
end-to-end generation tokens/s, and FPGA tokens/s.

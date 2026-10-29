# Qwen example: `altera_model_zoo`, `spatial_emulator_driver.py`, `dla_compiler`

Using Qwen/Qwen3-0.6B, this README outlines the usage of the following:
- Pulling OpenVINO IRs from the FPGA AI Suite model zoo (`altera_model_zoo`)
- Driving emulation (`spatial_emulator_driver.py`)
- Push button flow (`dla_compiler`)

## Requirements and install

- Python 3.12
- OpenVINO 2025.4.0
- The `fpga_ai_suite.spatial` package (built from `python/spark`)
- Dependencies from [`requirements.txt`](requirements.txt) (**OpenVINO/2025.4.0**)

Install the host-side dependencies from [`requirements.txt`](requirements.txt).
[`uv`](https://docs.astral.sh/uv/) is the preferred method.

```bash
uv venv .venv
source .venv/bin/activate
uv pip install -r requirements.txt
export OMP_NUM_THREADS=16
```

### Alternative: plain Python / pip / venv

If you prefer not to use `uv`:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install -U pip
pip install -r requirements.txt
export OMP_NUM_THREADS=16
```

**Early access:** This example is an **early access** release. You may encounter **unexpected behaviour**, **unsupported layers**, or other gaps compared to production toolchains.

---

## Fetch the OpenVINO IRs

The driver needs two graphs: the single-step body (`qwen3-0_6b-seq1`) and the
fixed-seq reference (`qwen3-0_6b`). Both are produced by `altera_model_zoo
fetch` (these tags set `do-not-use-model-converter`, so use `fetch`, not
`convert`).

```bash
altera_model_zoo fetch qwen3-0_6b-seq1
altera_model_zoo fetch qwen3-0_6b
```

Artifacts land under `python/model_zoo/models/`:

| Tag | Role | IR |
|-----|------|----|
| `qwen3-0_6b-seq1` | body (seq 1) | `models/qwen3-0_6b-seq1/IR/model_seqlen1.xml` |
| `qwen3-0_6b` | reference (seq 128) | `models/qwen3-0_6b/IR/model_seqlen128.xml` |

Other Qwen catalog tags follow the same pattern (`qwen2_5-1_5b`, `qwen2_5-3b`,
`qwen3-1_7b`, each with a `-seq1` body tag). See
[`python/model_zoo/README.md`](../../../python/model_zoo/README.md) for more on
the catalog and CLI.

---

## `spatial_emulator_driver.py`

### Motivation

This script is an end-to-end language model emulation driver for fixed-sequence
**OpenVINO IR** exports. It connects:

- The model **tokenizer** (chat template, vocab) to
- One or two **OpenVINO `.xml` / `.bin`** graphs, and
- Either the **Spatial compiler** (hybrid graph + KV-cache reference) or a plain **OpenVINO CPU** baseline.

Typical uses:

1. **`--backend spark`** — Compile the single-step body IR with the Spatial compiler, attach the full-context reference IR as the KV-cache reference, load embeddings when needed, then run token-by-token prefill and decode. Compiler artifacts go under `./spatial_emulator_dump/` (paths in code).
2. **`--backend openvino_cpu`** — Greedy decode by repeatedly executing the **fixed-seq** reference IR on CPU (full sequence padded each step). Useful to sanity-check logits when debugging Spatial/KV behavior.

The driver expects IRs from the model zoo that match `--model-name` and `--seq-len`.

### End-to-end workflow

#### 1. Fetch OpenVINO IRs

Follow [Fetch the OpenVINO IRs](#fetch-the-openvino-irs) above.

#### 2. Run the driver

Activate your venv (with **OpenVINO/2025.4.0**). Pass paths to the `.xml` files for `--ov-model` (seq_len-1 body) and `--ov-model-ref` (full-seq reference).

```bash
python spatial_emulator_driver.py \
  --model-name "Qwen/Qwen3-0.6B" \
  --seq-len 128 \
  --ov-model $COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b-seq1/IR/model_seqlen1.xml \
  --ov-model-ref $COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b/IR/model_seqlen128.xml \
  --backend spark \
  --prompt "Who are you?"
```

OpenVINO-only reference decode (no Spatial compile):

```bash
python spatial_emulator_driver.py \
  --model-name "Qwen/Qwen3-0.6B" \
  --seq-len 128 \
  --ov-model $COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b-seq1/IR/model_seqlen1.xml \
  --ov-model-ref $COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b/IR/model_seqlen128.xml \
  --backend openvino_cpu \
  --prompt "Who are you?"
```

Provide both `--ov-model` and `--ov-model-ref` when your copy of the driver expects them at startup. The `openvino_cpu` path only **executes** the reference IR during decode.

### CLI reference (`spatial_emulator_driver.py`)

| Argument | Default | Meaning |
|----------|---------|---------|
| `--model-name` | `Qwen/Qwen3-0.6B` | Hugging Face model id (tokenizer + config; must match export) |
| `--seq-len` | `128` | Fixed KV / IR sequence length; must match the **reference** IR export |
| `--max-new-tokens` | `64` | Cap on tokens generated after the prompt |
| `--backend` | `spark` | `spark` — Spatial compile + engine; `openvino_cpu` — greedy decode on reference IR only |
| `--prompt` | `Who are you?` | User message (wrapped with the tokenizer chat template) |
| `--ov-model` | — | Path to **seq_len-1** body `.xml` (required for `spark`) |
| `--ov-model-ref` | — | Path to **seq_len-`N`** reference `.xml` |
| `--arch` | `qwen_agx7.arch` | Spatial `.arch` (device + compile knobs + `attention` dims for KV-cache) |

### Practical constraints

- **Context budget:** `prompt` length + `max-new-tokens` must not exceed `--seq-len`, or the driver raises.
- **Model family:** Defaults and chat templates match **Qwen-style** chat models; other architectures may need tokenizer or template changes.

---

## `dla_compiler` (Push Button Flow)

**You need:**
- `seq_len-1` and `seq_len-128` IRs from **`altera_model_zoo fetch`** (same workflow as above).
- `dla_compiler` and your site’s CoreDLA / DLA toolchain on `PATH` (same environment as the Emulation Driver environment)
- Spatial architecture file

**Example** (adjust paths if your IRs live elsewhere):

```bash
dla_compiler \
  --march qwen_agx7.arch \
  --network-file $COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b-seq1/IR/model_seqlen1.xml \
  --ref-network-file $COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b/IR/model_seqlen128.xml
```

**Arguments**

| Token | Role |
|-------|------|
| `dla_compiler` | Compiler driver on `PATH`: invokes the CoreDLA flow for the given march and one or more OpenVINO IR graphs (exact outputs depend on your toolchain). |
| `--march` | Spatial architecture file (`.arch`). Describes the target device family (here AGX7), Spatial mapping, and blocks such as attention/KV sizing so they line up with the reference graph. |
| `--network-file` | **Body network:** OpenVINO **`.xml`** for the **single-step** forward (exported at **`seq_len-1`**). This is the subgraph advanced one token at a time during decode. |
| `--ref-network-file` | **Reference / prefill network:** OpenVINO **`.xml`** for the **full fixed length** (here **`seq_len-128`**). Used to build the KV-cache transformation during Spatial compilation. |

Both network options expect a paired **`.bin`** next to the `.xml` where
OpenVINO normally places it. For bitstreams, reports, and environment setup,
use your internal DLA docs.

### Generate a standalone Spatial IP or build an OFS example design

`dla_create_ip` uses `--model` for the body graph and `--ref-model` for the
fixed-sequence reference graph. Use it directly when you need a standalone IP
or saved DAG.

```bash
ARCH="$PWD/qwen_agx7.arch"
BODY="$COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b-seq1/IR/model_seqlen1.xml"
REFERENCE="$COREDLA_ROOT/python/model_zoo/models/qwen3-0_6b/IR/model_seqlen128.xml"
IP_DIR="$PWD/coredla_ip"

dla_create_ip --arch "$ARCH" --model "$BODY" --ref-model "$REFERENCE" \
  --ip-dir "$IP_DIR"
```

This creates the simulation environment and saves the completed DAG at
`$IP_DIR/altera_ai_ip/verilog/<model>_AGX7_Spatial_Qwen_AGX7/saved_model/`.

Alternatively, call `dla_build_example_design.py` directly. It invokes
`dla_create_ip` before platform setup, so the standalone command above is not a
prerequisite:

```bash
OUTPUT_DIR="$PWD/qwen_ofs"
dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --model "$BODY" --ref-model "$REFERENCE" \
  --output-dir "$OUTPUT_DIR"
```

To reuse the IP generated by that build without recompiling the models:

```bash
dla_build_example_design.py build agx7_iseries_ofs_pcie_spatial "$ARCH" \
  --skip-ip-gen --ip-dir "$OUTPUT_DIR/coredla_ip" \
  --output-dir "$PWD/qwen_ofs_reuse"
```

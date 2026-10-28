# GPT-Neo Spatial emulation example

Emulate `EleutherAI/gpt-neo-1.3B` on Spatial: pull the OpenVINO IRs from
the FPGA AI Suite model zoo, then run greedy decode with `spatial_emulator.py`.

## 1. Install (OpenVINO 2025.4.0)

Install the host-side dependencies from [`requirements.txt`](requirements.txt).
[`uv`](https://docs.astral.sh/uv/) is the preferred method.

```bash
uv venv .venv
source $COREDLA_ROOT/setupvars.sh
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
export OMP_NUM_THREADS=16
```

## 2. Fetch the OpenVINO IRs

The driver needs two graphs: the single-step body (`gpt-neo-1_3b-seq1`) and the
fixed-seq reference (`gpt-neo-1_3b`). Both are produced by `altera_model_zoo
fetch` (these tags set `do-not-use-model-converter`, so use `fetch`, not
`convert`).

```bash
altera_model_zoo fetch gpt-neo-1_3b-seq1
altera_model_zoo fetch gpt-neo-1_3b
```

Artifacts land under `python/model_zoo/models/`:

| Tag | Role | IR |
|-----|------|----|
| `gpt-neo-1_3b-seq1` | body (seq 1) | `models/gpt-neo-1_3b-seq1/IR/model_seqlen1.xml` |
| `gpt-neo-1_3b` | reference (seq 128) | `models/gpt-neo-1_3b/IR/model_seqlen128.xml` |

See [`python/model_zoo/README.md`](../../../python/model_zoo/README.md) for more
on the catalog and CLI.

## 3. Run the emulator

```bash
python spatial_emulator.py \
  --seq-len 128 \
  --ov-model $COREDLA_ROOT/python/model_zoo/models/gpt-neo-1_3b-seq1/IR/model_seqlen1.xml \
  --ov-model-ref $COREDLA_ROOT/python/model_zoo/models/gpt-neo-1_3b/IR/model_seqlen128.xml \
  --backend spark \
  --prompt "What are FPGAs?"
```

`--backend openvino_cpu` decodes on the reference IR only (no Spatial compile) as a
sanity check. `prompt` length + `--max-new-tokens` must not exceed `--seq-len`.

## 4. `dla_compiler` push-button flow

You need the `seq_len-1` body IR, the `seq_len-128` reference IR, and a Spatial
architecture whose attention settings match the model.

```bash
dla_compiler \
  --march gptneo_agx7.arch \
  --network-file $COREDLA_ROOT/python/model_zoo/models/gpt-neo-1_3b-seq1/IR/model_seqlen1.xml \
  --ref-network-file $COREDLA_ROOT/python/model_zoo/models/gpt-neo-1_3b/IR/model_seqlen128.xml
```

| Option | Role |
|--------|------|
| `--march` | Spatial architecture file containing the matching attention and KV-cache settings. |
| `--network-file` | Single-token body network exported at `seq_len-1`. |
| `--ref-network-file` | Fixed-length reference network exported at `seq_len-128`; used to construct the KV cache. |

Both network files require their companion `.bin` files in the same
directories.

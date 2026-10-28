# Copyright 2025 Altera Corporation.
#
# This software and the related documents are Altera copyrighted materials,
# and your use of them is governed by the express license under which they
# were provided to you ("License"). Unless the License provides otherwise,
# you may not use, modify, copy, publish, distribute, disclose or transmit
# this software or the related documents without Altera's prior written
# permission.
#
# This software and the related documents are provided as is, with no express
# or implied warranties, other than those that are expressly stated in the
# License.

"""Shared helpers for the tiny_story spatial examples."""

from pathlib import Path

import numpy as np
import torch

VALID_MODELS = ("1M", "3M", "8M")
# DDR requires 3M or larger (see README.md).
DDR_VALID_MODELS = ("3M", "8M", "28M", "33M")
REQUIRED_MODEL_FILES = ("config.json", "vocab.json", "pytorch_model.bin")

# Older TinyStories GPT-Neo checkpoints still ship causal-mask buffers that newer
# transformers rebuild at runtime, so they show up as UNEXPECTED on load.
_GPT_NEO_UNEXPECTED_KEY_PATTERNS = (
    r"h\.\d+\.attn\.attention\.bias",
    r"h\.\d+\.attn\.attention\.masked_bias",
    r"h\.\d+\.attn\.masked_bias",
)


def require_model_dir(model_size):
    """Validate that the Hugging Face checkpoint was downloaded as in README.md."""
    model_path = Path(f"TinyStories-{model_size}")
    download_cmd = (
        f"hf download roneneldan/TinyStories-{model_size} --local-dir ./{model_path}"
    )
    if not model_path.is_dir():
        raise FileNotFoundError(
            f"Missing model directory: {model_path!r}.\n"
            "Download with:\n"
            f"  {download_cmd}\n"
            "See README.md for download instructions."
        )
    missing = [
        name for name in REQUIRED_MODEL_FILES if not (model_path / name).is_file()
    ]
    if missing:
        raise FileNotFoundError(
            f"Missing model files in {model_path!r}: {', '.join(missing)}.\n"
            "Download with:\n"
            f"  {download_cmd}\n"
            "See README.md for download instructions."
        )
    return model_path


def load_tinystories_model(model_path, torch_dtype):
    """Load a TinyStories GPT-Neo checkpoint, ignoring obsolete mask buffers."""
    from transformers import AutoModelForCausalLM, GPTNeoForCausalLM

    GPTNeoForCausalLM._keys_to_ignore_on_load_unexpected = list(
        _GPT_NEO_UNEXPECTED_KEY_PATTERNS
    )
    return AutoModelForCausalLM.from_pretrained(
        Path(model_path).as_posix(), dtype=torch_dtype
    )


def print_token(tokenizer, token_id):
    """Decode and stream a single token id to stdout."""
    print(
        tokenizer.decode([int(token_id)], skip_special_tokens=True),
        end="",
        flush=True,
    )


def _stack_weights(data):
    return {
        k: (
            np.concatenate([d[k] for d in data], axis=0)
            if data[0][k].ndim == 3
            else np.stack([d[k] for d in data], axis=0)
        )
        for k in data[0].keys()
    }


def extract_tinystories_weights(model_original, num_layers, num_heads, hidden_size):
    """Convert a GPT-Neo TinyStories model into SPARK weights and an embed_idx fn."""
    size_of_head = hidden_size // num_heads
    with torch.no_grad():
        new_weights = {"ln1": [], "attention": [], "post": []}
        for i in range(num_layers):
            layer = model_original.transformer.h[i]
            attn = layer.attn.attention
            new_weights["ln1"].append(
                {
                    "m1": layer.ln_1.weight.float().numpy(),
                    "b1": layer.ln_1.bias.float().numpy(),
                }
            )
            new_weights["attention"].append(
                {
                    "q_w": (
                        attn.q_proj.weight.float()
                        .numpy()
                        .reshape((num_heads, size_of_head, hidden_size))
                        .transpose(0, 2, 1)
                    ),
                    "k_w": (
                        attn.k_proj.weight.float()
                        .numpy()
                        .reshape((num_heads, size_of_head, hidden_size))
                        .transpose(0, 2, 1)
                    ),
                    "v_w": (
                        attn.v_proj.weight.float()
                        .numpy()
                        .reshape((num_heads, size_of_head, hidden_size))
                        .transpose(0, 2, 1)
                    ),
                    "o_w": (
                        attn.out_proj.weight.float()
                        .numpy()
                        .T.reshape((num_heads, size_of_head, hidden_size))
                    ),
                    "o_b": attn.out_proj.bias.float().numpy(),
                }
            )
            new_weights["post"].append(
                {
                    "m1": layer.ln_2.weight.float().numpy(),
                    "b1": layer.ln_2.bias.float().numpy(),
                    "d1": layer.mlp.c_fc.weight.float().numpy().T,
                    "b2": layer.mlp.c_fc.bias.float().numpy(),
                    "d2": layer.mlp.c_proj.weight.float().numpy().T,
                    "b3": layer.mlp.c_proj.bias.float().numpy(),
                }
            )

        new_weights["ln1"] = _stack_weights(new_weights["ln1"])
        new_weights["attention"] = _stack_weights(new_weights["attention"])
        new_weights["post"] = _stack_weights(new_weights["post"])
        new_weights["lnf"] = {
            "m1": model_original.transformer.ln_f.weight.float().numpy(),
            "b1": model_original.transformer.ln_f.bias.float().numpy(),
        }
        new_weights["lm_head"] = {
            "d1": model_original.lm_head.weight.float().numpy().T
        }

        def embed_idx(token, idx):
            with torch.no_grad():
                return (
                    model_original.transformer.wte(torch.tensor([token]))
                    + model_original.transformer.wpe(torch.tensor(idx))
                ).detach()

        return new_weights, embed_idx

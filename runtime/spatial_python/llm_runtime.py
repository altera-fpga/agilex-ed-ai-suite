#!/usr/bin/env python3
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
"""
Generalized FPGA spatial LLM runtime.

  1. Prefill: embed ALL prompt tokens, concatenate, one run_inference.
  2. Decode: emit tokens until EOS (or --max-new-tokens).

The accelerator returns a token index directly (no float decode / argmax).

--model <HuggingFace model id> loads tokenizer AND input embeddings
from the Hub (safetensors shard, with a full-model fallback).
"""

from __future__ import annotations

import argparse
import sys
import time
from pathlib import Path
from typing import Any

import numpy as np
import torch
from mmd_binding import MmdDevice, encode_floats_for_mmd, open_mmd
from transformers import AutoModelForCausalLM, AutoTokenizer

# Input embedding tensor names across common causal-LM checkpoints.
EMBEDDING_KEYS = (
    "model.embed_tokens.weight",
    "transformer.wte.weight",
    "embed_tokens.weight",
    "wte.weight",
)


def _locate_embedding_shard(model_id: str) -> tuple[Path, str | None]:
    """Download the safetensors shard that holds the embedding table.

    Returns (path, key); key is None when the file must be searched.
    """
    import json

    from huggingface_hub import hf_hub_download
    from huggingface_hub.utils import EntryNotFoundError

    try:
        return Path(hf_hub_download(model_id, "model.safetensors")), None
    except EntryNotFoundError:
        pass

    index_path = hf_hub_download(model_id, "model.safetensors.index.json")
    weight_map = json.loads(Path(index_path).read_text())["weight_map"]
    for key in EMBEDDING_KEYS:
        if key in weight_map:
            return Path(hf_hub_download(model_id, weight_map[key])), key
    raise KeyError(f"no known embedding tensor in {model_id}; tried {EMBEDDING_KEYS}")


def _embeddings_via_safetensors(model_arg: str) -> np.ndarray:
    """Read just the embedding tensor, converting to float32 with a progress bar."""
    from safetensors import safe_open
    from tqdm.auto import tqdm

    path, key = _locate_embedding_shard(model_arg)
    print(f"[llm] reading embeddings from {path.name}", flush=True)

    # framework="pt": safetensors cannot hand bfloat16 to numpy directly.
    with safe_open(str(path), framework="pt") as f:
        if key is None:
            key = next((k for k in EMBEDDING_KEYS if k in f.keys()), None)
            if key is None:
                raise KeyError(f"no known embedding tensor in {path}; tried {EMBEDDING_KEYS}")
        tensor = f.get_tensor(key)

    if tensor.ndim != 2:
        raise ValueError(f"model embeddings must be 2D [vocab, dim], got shape {tuple(tensor.shape)}")

    rows, dim = int(tensor.shape[0]), int(tensor.shape[1])
    out = np.empty((rows, dim), dtype=np.float32)
    chunk = 8192
    for start in tqdm(
        range(0, rows, chunk),
        desc="[llm] embeddings",
        unit="chunk",
        leave=False,
    ):
        stop = min(start + chunk, rows)
        out[start:stop] = tensor[start:stop].float().cpu().numpy()
    return out


def load_embeddings_from_model(model_arg: str) -> np.ndarray:
    """Pull the input embedding table from a HuggingFace causal LM checkpoint."""
    try:
        return _embeddings_via_safetensors(model_arg)
    except Exception as exc:
        print(f"[llm] fast path unavailable ({exc}); loading the full model instead", flush=True)

    print(f"[llm] loading model weights from {model_arg} (for embeddings)...", flush=True)
    model = AutoModelForCausalLM.from_pretrained(
        model_arg,
        dtype=torch.float32,
        low_cpu_mem_usage=True,
    )
    weight = model.get_input_embeddings().weight.detach().cpu().numpy()
    del model
    if weight.ndim != 2:
        raise ValueError(f"model embeddings must be 2D [vocab, dim], got shape {weight.shape}")
    return weight.astype(np.float32, copy=False)


def resolve_embeddings_and_tokenizer(model_arg: str) -> tuple[np.ndarray, Any]:
    print("[llm] loading embeddings...", flush=True)
    t0 = time.perf_counter()
    embeddings = load_embeddings_from_model(model_arg)
    print(
        f"[llm] embeddings {embeddings.shape} {embeddings.dtype} "
        f"in {time.perf_counter() - t0:.1f}s",
        flush=True,
    )

    print("[llm] loading tokenizer...", flush=True)
    t0 = time.perf_counter()
    tokenizer = AutoTokenizer.from_pretrained(model_arg)
    print(f"[llm] tokenizer ready in {time.perf_counter() - t0:.1f}s", flush=True)
    return embeddings, tokenizer


def embed_tokens(embeddings: np.ndarray, token_ids: list[int]) -> np.ndarray:
    missing = [t for t in token_ids if t < 0 or t >= embeddings.shape[0]]
    if missing:
        raise IndexError(f"token id(s) out of range for embeddings table: {missing[:8]}...")
    return np.stack([embeddings[t] for t in token_ids], axis=0)


def mmd_next_token(mmd: MmdDevice, emb: np.ndarray) -> tuple[int, float]:
    """Run inference and return the last token index plus device latency.

    Each token is one input packet (hidden size). N input packets produce N
    output packets; the next generated token is the last of those.
    """
    width = mmd.input_data_width
    flat = encode_floats_for_mmd(np.asarray(emb, dtype=np.float32).reshape(-1), width)
    start = time.perf_counter()
    raw = mmd.run_inference(flat)
    inference_s = time.perf_counter() - start
    token_id = int(np.asarray(raw, dtype=np.uint64).reshape(-1)[-1])
    return token_id, inference_s


def generate(
    mmd: MmdDevice,
    embeddings: np.ndarray,
    tokenizer: Any,
    prompt: str,
    max_new_tokens: int = 256,
    enable_thinking: bool = False,
) -> str:
    """Prefill all prompt tokens in one MMD call, then decode until EOS."""
    # Base completion models (e.g. TinyStories / GPT-Neo) ship no chat template;
    # their prompt is used verbatim.
    if getattr(tokenizer, "chat_template", None):
        messages = [{"role": "user", "content": prompt}]
        text = tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
            enable_thinking=enable_thinking,
        )
    else:
        text = prompt

    encoded = tokenizer([text])
    input_ids = list(encoded["input_ids"][0])
    if not input_ids:
        print()
        return ""

    print(tokenizer.decode(input_ids), end="", flush=True)

    t_start = time.perf_counter()
    prompt_emb = embed_tokens(embeddings, input_ids)
    next_id, prefill_inference_s = mmd_next_token(mmd, prompt_emb)
    t_first = time.perf_counter()
    ttft_s = t_first - t_start

    generated: list[int] = []
    decode_inference_s = 0.0
    decode_calls = 0
    eos_id = getattr(tokenizer, "eos_token_id", None)
    for index in range(max_new_tokens):
        if eos_id is not None and next_id == eos_id:
            break
        generated.append(next_id)
        print(tokenizer.decode([next_id]), end="", flush=True)
        if index + 1 == max_new_tokens:
            break
        step_emb = embed_tokens(embeddings, [next_id])
        next_id, inference_s = mmd_next_token(mmd, step_emb)
        decode_inference_s += inference_s
        decode_calls += 1

    t_end = time.perf_counter()
    print()

    n_gen = len(generated)
    gen_s = t_end - t_first
    generated_after_first = max(n_gen - 1, 0)
    end_to_end_tps = generated_after_first / gen_s if gen_s > 0 else 0.0
    device_tps = decode_calls / decode_inference_s if decode_inference_s > 0 else 0.0
    decode_latency_s = decode_inference_s / decode_calls if decode_calls else 0.0
    print(f"  Time to first token:       {ttft_s * 1000:.2f} ms")
    print(f"  Prefill inference latency: {prefill_inference_s * 1000:.2f} ms")
    print(f"  Decode inference latency:  {decode_latency_s * 1000:.2f} ms/token")
    print(f"  Generated tokens:          {n_gen}")
    print(f"  Generate tokens/s:         {end_to_end_tps:.2f}")
    print(f"  FPGA tokens/s:             {device_tps:.2f}")
    return tokenizer.decode(generated)


def _is_quit(text: str) -> bool:
    return text.lower() in ("quit", "exit", "q")


def interactive_loop(
    mmd: MmdDevice,
    embeddings: np.ndarray,
    tokenizer: Any,
    max_new_tokens: int,
    enable_thinking: bool,
) -> None:
    print("Enter a prompt, or quit/exit/q to stop.")
    while True:
        try:
            user_prompt = input("\nPrompt: ").strip()
        except (EOFError, KeyboardInterrupt):
            print("\nGoodbye!")
            return
        if not user_prompt:
            continue
        if _is_quit(user_prompt):
            print("Goodbye!")
            return
        generate(
            mmd,
            embeddings,
            tokenizer,
            user_prompt,
            max_new_tokens=max_new_tokens,
            enable_thinking=enable_thinking,
        )


def parse_args(argv: list[str] | None = None) -> argparse.Namespace:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "--model",
        required=True,
        help="HuggingFace model id. Loads tokenizer and input embeddings from the Hub.",
    )
    p.add_argument(
        "--mmd-lib",
        default=None,
        help="Directory containing spatial_mmd*.so (pybind module); default: auto-detect",
    )
    p.add_argument("--port-config", required=True, help="port_config.json")
    p.add_argument(
        "--load-weights",
        default=None,
        metavar="DIR",
        help="Optional directory of weights_ddr_*.bin files; if omitted, weights are not loaded",
    )
    p.add_argument("--max-new-tokens", type=int, default=256)
    p.add_argument("--enable-thinking", action="store_true")
    return p.parse_args(argv)


def main(argv: list[str] | None = None) -> int:
    args = parse_args(argv)
    embeddings, tokenizer = resolve_embeddings_and_tokenizer(args.model)

    kwargs = {
        "port_config": args.port_config,
        "lib_path": args.mmd_lib,
        "load_weights": args.load_weights,
    }

    if args.load_weights:
        print(f"[llm] connecting to FPGA, loading weights from {args.load_weights}...", flush=True)
    else:
        print("[llm] connecting to FPGA...", flush=True)
    t0 = time.perf_counter()
    with open_mmd(**kwargs) as mmd:
        print(f"[llm] FPGA ready in {time.perf_counter() - t0:.1f}s", flush=True)
        interactive_loop(
            mmd,
            embeddings,
            tokenizer,
            max_new_tokens=args.max_new_tokens,
            enable_thinking=args.enable_thinking,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())

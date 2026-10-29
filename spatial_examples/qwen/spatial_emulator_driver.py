from __future__ import annotations

import argparse
import os
import time
from typing import Optional

import numpy as np
import openvino as ov
import torch
from fpga_ai_suite.spatial.compiler import spark_compiler as sc
from fpga_ai_suite.spatial.layers.model_saver import restore_model, save_model
from transformers import AutoConfig, AutoModelForCausalLM, AutoTokenizer

# Spatial arch file (target device family + compile knobs) used when --arch is omitted.
DEFAULT_ARCH_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "qwen_agx7.arch")

# Populated by _init_driver_globals() (defaults + CLI).
SEQ_LEN: int
OV_MODEL: str
OV_MODEL_REF: str
MODEL_NAME: str


def _init_driver_globals(
    model_name: str,
    seq_len: int,
    ov_model_path: Optional[str] = None,
    ov_model_ref_path: Optional[str] = None,
) -> None:
    """Set module-level paths and HF config from model id and KV seq length.

    If ``ov_model_path`` / ``ov_model_ref_path`` are omitted, paths are derived next to
    ``model_convert/`` from ``model_name`` and ``seq_len`` (same layout as convert_qwen3.py).
    """
    global SEQ_LEN, MODEL_NAME, OV_MODEL, OV_MODEL_REF, config

    SEQ_LEN = seq_len
    MODEL_NAME = model_name
    OV_MODEL = os.path.abspath(ov_model_path)
    OV_MODEL_REF = os.path.abspath(ov_model_ref_path)

    config = AutoConfig.from_pretrained(
        model_name,
        dtype=torch.float32,
        torchscript=True,
        use_cache=False,
        device_map="auto",
    )


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Spatial emulator / OpenVINO CPU driver for Qwen-style greedy decode.",
    )
    p.add_argument(
        "--model-name",
        default="Qwen/Qwen3-0.6B",
        help="Hugging Face model id (default: %(default)s)",
    )
    p.add_argument("--seq-len", type=int, default=512, help="KV / IR sequence length (default: %(default)s)")
    p.add_argument(
        "--max-new-tokens",
        type=int,
        default=64,
        help="Max new tokens to generate after the prompt (default: %(default)s)",
    )
    p.add_argument(
        "--backend",
        choices=("spark", "openvino_cpu"),
        default="spark",
        help="spark: compile with SPARK; openvino_cpu: greedy decode on fixed-seq IR (default: %(default)s)",
    )
    p.add_argument(
        "--prompt",
        default="Who are you?",
        help="User prompt text (default: %(default)s)",
    )
    p.add_argument(
        "--ov-model",
        default=None,
        metavar="PATH",
        help="OpenVINO XML for the single-step SPARK body (seq_len-1). "
        "Default: model_convert/<model_stem>.seq_len-1.xml",
    )
    p.add_argument(
        "--ov-model-ref",
        default=None,
        metavar="PATH",
        help="OpenVINO XML for the KV / fixed-seq reference graph. "
        "Default: model_convert/<model_stem>.seq_len-<seq_len>.xml",
    )
    p.add_argument(
        "--arch",
        default="qwen_agx7.arch",
        metavar="PATH",
        help="Spatial .arch file with target device and compile knobs (spark backend only). "
        "Default: qwen_agx7.arch next to this script.",
    )
    return p.parse_args()


def _require_spark_ir_files() -> None:
    for label, path in (
        ("single-step body", OV_MODEL),
        ("KV / prefill reference", OV_MODEL_REF),
    ):
        if not os.path.isfile(path):
            raise FileNotFoundError(
                f"Missing {label} IR: {path!r}. "
                f"For seq_len-{SEQ_LEN} export, run model_convert/convert_qwen3.py; "
                f"seq_len-1.xml must be supplied separately for SPARK."
            )


def _tokenizer_pad_id(tokenizer) -> int:
    if tokenizer.pad_token_id is not None:
        return int(tokenizer.pad_token_id)
    return int(tokenizer.eos_token_id)


def _next_token_id_from_output(out, *, pos=-1):
    """Greedy token id at sequence position ``pos`` from model output.

    Supports float logits ``(batch, seq, vocab)`` and TopK/argmax indices
    ``(batch, seq, 1)`` (or integer ``(batch, seq)``). Do not call ``argmax`` on
    an already-selected token id; that always returns 0 for a length-1 slice.
    """
    a = np.asarray(out)
    if a.ndim == 3 and a.shape[-1] == 1:
        return int(a[0, pos, 0])
    if a.ndim == 2 and np.issubdtype(a.dtype, np.integer):
        return int(a[0, pos])
    a = np.asarray(out, dtype=np.float32)
    if a.ndim == 1:
        return int(a.argmax())
    if a.ndim == 2:
        return int(a[pos].argmax())
    if a.ndim == 3:
        return int(a[0, pos].argmax())
    raise ValueError(f"unexpected output shape {a.shape} ndim={a.ndim}")


def _embedding_weight_matrix_from_hf(model_id: str) -> np.ndarray:
    """Same matrix as a typical `{MODEL}_embeddings.pkl`: [vocab_size, hidden_size] float32."""
    m = AutoModelForCausalLM.from_pretrained(
        model_id,
        config=config,
    )
    w = m.get_input_embeddings().weight.detach().cpu().float().numpy()
    del m
    return w


def _subdag_io_port(container, base, extra_keys=()):
    """Hybrid sub-DAGs name boundary ports din_0, dout_0, ...; flat DAGs use din, dout.

    When the embedding runs inside SPARK, the body primary input keeps the OpenVINO
    Parameter name (e.g. input_ids) instead of din / din_0.
    """
    for key in (base, f"{base}_0", *extra_keys):
        if key in container:
            return container[key]
    raise AttributeError(
        f"expected '{base}', '{base}_0', or {list(extra_keys)} in IO container; "
        f"keys are {list(container.keys())}"
    )


def _subdag_datain_port(sub_dag):
    """Primary activations input: token ids (embedding in SPARK) or din (embedding off-chip)."""
    return _subdag_io_port(sub_dag.inputs, "din", extra_keys=("input_ids",))


def _subdag_dataout_port(sub_dag):
    """LM head / Result keeps OV friendly names (e.g. Result_38433); grouped sub-DAGs use dout."""
    outs = sub_dag.outputs
    for key in ("dout", "dout_0"):
        if key in outs:
            return outs[key]
    if len(outs) == 1:
        return next(iter(outs.values()))
    raise AttributeError(
        f"expected 'dout', 'dout_0', or a single output port; keys are {list(outs.keys())}"
    )


class SpatialLlmEngine:
    def __init__(self, seq_len, arch=None):
        """seq_len must match the KV-cache reference IR (IR_STEM.seq_len-{seq_len}.xml under model_convert)."""
        _require_spark_ir_files()
        self.seq_len = seq_len
        self.arch = arch or DEFAULT_ARCH_FILE
        if not os.path.isfile(self.arch):
            raise FileNotFoundError(f"Missing spatial arch file: {self.arch!r}.")
        self.embeddings = None
        core = ov.Core()
        ov_model = core.read_model(OV_MODEL)
        spark_model, hybrid_model = sc.compile(
            ov_model,
            self.arch,
            dump_path="./spatial_emulator_dump",
            dump_data_rtl_testbench=False,
            ov_model_ref=core.read_model(OV_MODEL_REF),
            print_compile_progress=True,
            print_summary=False,
            generate_pta=False,
        )

        save_model(spark_model, "./spatial_emulator_dump/spark_model")
        restore_model("./spatial_emulator_dump/spark_model", "./spatial_emulator_dump/spark_model.py")

        self.sub_dag = spark_model
        self._din = _subdag_datain_port(self.sub_dag)
        self._dout = _subdag_dataout_port(self.sub_dag)
        # Subgraph after off-chip embedding uses din / din_0; full body uses OV input names.
        self._use_precomputed_embeddings = self._din.name in ("din", "din_0")
        if self._use_precomputed_embeddings:
            self.embeddings = _embedding_weight_matrix_from_hf(MODEL_NAME)

    def forward(self, input_id):
        assert input_id.shape == (1, 1), "{input_id.shape = } is not supported. Only (1,1) is supported"
        tid = int(np.asarray(input_id, dtype=np.int64).reshape(-1)[0])
        if self._use_precomputed_embeddings:
            # Fancy indexing with (1,1) arrays is easy to get wrong; always pick one row.
            self._din.data = self.embeddings[tid : tid + 1]
        else:
            self._din.data = input_id
        self.sub_dag()
        return self._dout.data

    __call__ = forward


class SpatialLlmLoop:
    def __init__(
        self,
        seq_len=128,
        max_new_tokens=64,
        eager_spark_engine: bool = True,
        arch: Optional[str] = None,
    ):
        """
        seq_len: fixed KV / attention context length; must match OpenVINO IR
                 ``OV_MODEL_REF``.
        max_new_tokens: default cap on generated tokens after the prompt.
        eager_spark_engine: if False, ``SpatialLlmEngine`` is created only when ``generate()`` runs
            (so ``generate_openvino_cpu()`` can be used without seq_len-1.xml / SPARK compile).
        arch: spatial .arch file (target device + compile knobs) passed to SPARK compile;
            defaults to ``DEFAULT_ARCH_FILE`` (ignored for ``openvino_cpu`` backend).
        """
        self.seq_len = seq_len
        self.max_new_tokens = max_new_tokens
        self.arch = arch
        self._engine: Optional[SpatialLlmEngine] = (
            SpatialLlmEngine(seq_len, arch=arch)
            if eager_spark_engine
            else None
        )
        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

    def _get_engine(self) -> SpatialLlmEngine:
        if self._engine is None:
            self._engine = SpatialLlmEngine(
                self.seq_len,
                arch=self.arch,
            )
        return self._engine

    def _ensure_context(self, prompt_len: int, max_new: int) -> None:
        need = prompt_len + max_new
        if need > self.seq_len:
            raise ValueError(
                f"prompt ({prompt_len} tokens) + max_new_tokens ({max_new}) = {need} > "
                f"compiled seq_len={self.seq_len}. Raise seq_len, shorten the prompt, or lower "
                f"max_new_tokens."
            )

    def generate(self, prompt, max_new_tokens=None):
        max_new = self.max_new_tokens if max_new_tokens is None else max_new_tokens
        messages = [
            {"role": "user", "content": prompt}
        ]
        text = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
            enable_thinking=False
        )
        model_inputs = self.tokenizer([text])
        input_ids, = model_inputs["input_ids"]
        input_ids = list(input_ids)
        if not input_ids:
            print()
            return

        self._ensure_context(len(input_ids), max_new)

        prompt_n = len(input_ids)
        t_wall0 = time.perf_counter()

        # Prefill: one forward per prompt token; keep logits from the last prompt forward for decode.
        eng = self._get_engine()
        for tid in input_ids[:-1]:
            print(self.tokenizer.decode([tid]), end="", flush=True)
            eng(np.array([[tid]]))
        print(self.tokenizer.decode([input_ids[-1]]), end="", flush=True)
        logits = eng(np.array([[input_ids[-1]]]))

        t_decode0 = time.perf_counter()

        for _ in range(max_new):
            next_id = _next_token_id_from_output(logits)
            input_ids.append(next_id)
            print(self.tokenizer.decode([next_id]), end="", flush=True)
            if next_id == self.tokenizer.eos_token_id:
                break
            logits = eng(np.array([[next_id]]))
        print()

        t_wall1 = time.perf_counter()
        new_tokens = len(input_ids) - prompt_n
        prefill_s = t_decode0 - t_wall0
        decode_s = t_wall1 - t_decode0
        wall_s = t_wall1 - t_wall0
        if new_tokens > 0 and decode_s > 0:
            decode_tps = new_tokens / decode_s
            print(
                f"tokens/s (decode): {decode_tps:.2f}  "
                f"({new_tokens} new tokens in {decode_s:.3f}s; "
                f"prefill {prompt_n} tok in {prefill_s:.3f}s; wall {wall_s:.3f}s)",
                flush=True,
            )
        else:
            print(
                f"tokens/s (decode): n/a  (new_tokens={new_tokens}, decode_s={decode_s:.3f}s; "
                f"prefill {prompt_n} tok in {prefill_s:.3f}s; wall {wall_s:.3f}s)",
                flush=True,
            )

    def generate_openvino_cpu(self, prompt, max_new_tokens=None, enable_thinking: bool = False):
        """Greedy decode using the **fixed-seq** OpenVINO IR on CPU (no SPARK, no KV).

        Recomputes the full sequence each step so attention matches the exported ``seq_len-L``
        graph. Use when ``--backend spark`` output is wrong (e.g. KV insert failed silently).
        """
        max_new = self.max_new_tokens if max_new_tokens is None else max_new_tokens
        messages = [{"role": "user", "content": prompt}]
        text = self.tokenizer.apply_chat_template(
            messages,
            tokenize=False,
            add_generation_prompt=True,
            enable_thinking=enable_thinking,
        )
        prompt_ids = list(self.tokenizer.encode(text, add_special_tokens=False))
        if not prompt_ids:
            print()
            return

        self._ensure_context(len(prompt_ids), max_new)

        if not os.path.isfile(OV_MODEL_REF):
            raise FileNotFoundError(
                f"OpenVINO CPU path needs {OV_MODEL_REF!r} (and .bin). "
                f"Export with model_convert/convert_qwen3.py for this model and --seq-len {self.seq_len}."
            )

        core = ov.Core()
        ov_m = core.read_model(OV_MODEL_REF)
        compiled = core.compile_model(ov_m, "CPU")
        in_port = compiled.inputs[0]
        pad_id = _tokenizer_pad_id(self.tokenizer)
        eos_id = int(self.tokenizer.eos_token_id)
        seq_len = self.seq_len
        ids = list(prompt_ids)
        prompt_n = len(ids)

        t0 = time.perf_counter()
        for _ in range(max_new):
            if len(ids) > seq_len:
                raise ValueError("sequence length exceeded IR seq_len")
            pad = seq_len - len(ids)
            row = ids + [pad_id] * pad
            inp = np.array([row], dtype=np.int64)
            out = np.asarray(next(iter(compiled({in_port: inp}).values())))
            last_real = len(ids) - 1
            next_id = _next_token_id_from_output(out, pos=last_real)
            ids.append(next_id)
            print(self.tokenizer.decode([next_id]), end="", flush=True)
            if next_id == eos_id:
                break
        print()
        elapsed = time.perf_counter() - t0
        new_tokens = len(ids) - prompt_n
        if new_tokens > 0 and elapsed > 0:
            print(
                f"[openvino_cpu] tokens/s: {new_tokens / elapsed:.2f} ({new_tokens} tokens in {elapsed:.3f}s)",
                flush=True,
            )


def main() -> None:
    args = parse_args()
    _init_driver_globals(
        model_name=args.model_name,
        seq_len=args.seq_len,
        ov_model_path=args.ov_model,
        ov_model_ref_path=args.ov_model_ref,
    )
    llm_loop = SpatialLlmLoop(
        seq_len=args.seq_len,
        max_new_tokens=args.max_new_tokens,
        eager_spark_engine=(args.backend == "spark"),
        arch=args.arch,
    )
    if args.backend == "openvino_cpu":
        llm_loop.generate_openvino_cpu(prompt=args.prompt)
    else:
        llm_loop.generate(prompt=args.prompt)


if __name__ == "__main__":
    main()

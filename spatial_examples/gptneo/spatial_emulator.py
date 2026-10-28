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

# Spatial arch file (target device family + compile knobs) for this example.
ARCH_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "gptneo_agx7.arch")

# End-to-end spatial emulation driver for GPT-Neo greedy decode.
#
# GPT-Neo is a base (non-instruction-tuned) causal LM, so its tokenizer has no
# chat template; the prompt is tokenized directly as a plain completion. The
# driver compiles the single-step (seq_len-1) body IR with SPARK, attaches the
# fixed-seq reference IR as the KV-cache reference, and runs token-by-token
# prefill + decode. Export both IRs with convert_model.py.

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
    """Set module-level paths and HF config from model id and KV seq length."""
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
        description="Spatial emulator / OpenVINO CPU driver for GPT-Neo greedy decode.",
    )
    p.add_argument(
        "--model-name",
        default="EleutherAI/gpt-neo-1.3B",
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
        choices=("spark", "openvino_cpu", "compare"),
        default="spark",
        help="spark: compile with SPARK; openvino_cpu: greedy decode on fixed-seq IR; "
        "compare: run SPARK and the CPU reference in lockstep and report the first "
        "next-token divergence (default: %(default)s)",
    )
    p.add_argument(
        "--prompt",
        default="What are FPGAs?",
        help="Prompt text, completed directly (no chat template) (default: %(default)s)",
    )
    p.add_argument(
        "--metrics",
        action="store_true",
        help="In 'compare' backend, print per-position SPARK-vs-reference logit "
        "metrics (cosine, max abs diff, rank). Off by default: tokens are printed "
        "one at a time as they are decoded.",
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
    return p.parse_args()


def _require_spark_ir_files() -> None:
    for label, path in (
        ("single-step body", OV_MODEL),
        ("KV / prefill reference", OV_MODEL_REF),
    ):
        if not os.path.isfile(path):
            raise FileNotFoundError(
                f"Missing {label} IR: {path!r}. "
                f"Export both seq_len-1 and seq_len-{SEQ_LEN} graphs with convert_model.py."
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


def _embedding_matrices_from_hf(model_id: str):
    """Token and position embedding matrices: ([vocab, hidden], [max_pos, hidden]) float32.

    GPT-Neo's input is wte(token) + wpe(position). The token matrix is the usual
    `{MODEL}_embeddings.pkl`. The position matrix (transformer.wpe) is needed
    because the seq_len=1 SPARK body bakes the position embedding at position 0
    (it was traced with position_ids=[0]); the driver advances it per step.
    """
    m = AutoModelForCausalLM.from_pretrained(
        model_id,
        config=config,
    )
    wte = m.get_input_embeddings().weight.detach().cpu().float().numpy()
    wpe = None
    pos_emb = getattr(getattr(m, "transformer", None), "wpe", None)
    if pos_emb is not None:
        wpe = pos_emb.weight.detach().cpu().float().numpy()
    del m
    return wte, wpe


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
    def __init__(self, seq_len):
        """seq_len must match the KV-cache reference IR (IR_STEM.seq_len-{seq_len}.xml).

        Attention dims (q_num_heads / q_head_size / seq_len for KV-cache insert)
        come from the spatial arch ``attention`` block.
        """
        _require_spark_ir_files()
        self.seq_len = seq_len
        self.embeddings = None
        core = ov.Core()
        ov_model = core.read_model(OV_MODEL)
        spark_model, hybrid_model = sc.compile(
            ov_model,
            ARCH_FILE,
            dump_path="./spatial_emulator_dump",
            dump_data_rtl_testbench=False,
            ov_model_ref=core.read_model(OV_MODEL_REF),
            visualize_graphs=False,
            print_compile_progress=True,
            print_optimization_progress=False,
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
        self.position_embeddings = None
        # Decode position, advanced once per forward(); reset via reset_position().
        self._pos = 0
        if self._use_precomputed_embeddings:
            self.embeddings, self.position_embeddings = _embedding_matrices_from_hf(MODEL_NAME)

    def reset_position(self):
        self._pos = 0

    def forward(self, input_id):
        assert input_id.shape == (1, 1), "{input_id.shape = } is not supported. Only (1,1) is supported"
        tid = int(np.asarray(input_id, dtype=np.int64).reshape(-1)[0])
        if self._use_precomputed_embeddings:
            # Fancy indexing with (1,1) arrays is easy to get wrong; always pick one row.
            emb = self.embeddings[tid : tid + 1]
            if self.position_embeddings is not None:
                # The seq_len=1 body bakes wpe[0] as a constant Add_bias on its
                # input (traced at position 0), so it adds wpe[0] every step. Feed
                # wte[token] + wpe[pos] - wpe[0]; the graph then adds wpe[0] back,
                # giving the correct wte[token] + wpe[pos]. Matches the body at pos 0.
                wpe = self.position_embeddings
                emb = emb + (wpe[self._pos : self._pos + 1] - wpe[0:1])
            self._din.data = emb
        else:
            self._din.data = input_id
        self.sub_dag()
        self._pos += 1
        return self._dout.data

    __call__ = forward


class SpatialLlmLoop:
    def __init__(
        self,
        seq_len=128,
        max_new_tokens=64,
        eager_spark_engine: bool = True,
    ):
        """
        seq_len: fixed KV / attention context length; must match OpenVINO IR
                 ``OV_MODEL_REF`` and the arch ``attention.seq_len``.
        max_new_tokens: default cap on generated tokens after the prompt.
        eager_spark_engine: if False, ``SpatialLlmEngine`` is created only when ``generate()`` runs
            (so ``generate_openvino_cpu()`` can be used without seq_len-1.xml / SPARK compile).
        """
        self.seq_len = seq_len
        self.max_new_tokens = max_new_tokens
        self._engine: Optional[SpatialLlmEngine] = (
            SpatialLlmEngine(seq_len) if eager_spark_engine else None
        )
        self.tokenizer = AutoTokenizer.from_pretrained(MODEL_NAME)

    def _get_engine(self) -> SpatialLlmEngine:
        if self._engine is None:
            self._engine = SpatialLlmEngine(self.seq_len)
        return self._engine

    def _ensure_context(self, prompt_len: int, max_new: int) -> None:
        need = prompt_len + max_new
        if need > self.seq_len:
            raise ValueError(
                f"prompt ({prompt_len} tokens) + max_new_tokens ({max_new}) = {need} > "
                f"compiled seq_len={self.seq_len}. Raise seq_len, shorten the prompt, or lower "
                f"max_new_tokens."
            )

    def _encode_prompt(self, prompt) -> list:
        """GPT-Neo has no chat template; tokenize the prompt as a plain completion."""
        return list(self.tokenizer.encode(prompt))

    def generate(self, prompt, max_new_tokens=None):
        max_new = self.max_new_tokens if max_new_tokens is None else max_new_tokens
        input_ids = self._encode_prompt(prompt)
        if not input_ids:
            print()
            return

        self._ensure_context(len(input_ids), max_new)

        prompt_n = len(input_ids)
        t_wall0 = time.perf_counter()

        # Prefill: one forward per prompt token; keep logits from the last prompt forward for decode.
        eng = self._get_engine()
        eng.reset_position()
        for tid in input_ids[:-1]:
            eng(np.array([[tid]]))
        logits = eng(np.array([[input_ids[-1]]]))

        t_decode0 = time.perf_counter()

        # Stream each decoded token as it is produced.
        print("GENERATED: ", end="", flush=True)
        generated_ids = []
        stopped_on_eos = False
        for _ in range(max_new):
            next_id = _next_token_id_from_output(logits)
            if next_id == self.tokenizer.eos_token_id:
                stopped_on_eos = True
                break
            generated_ids.append(next_id)
            print(self.tokenizer.decode([next_id]), end="", flush=True)
            logits = eng(np.array([[next_id]]))
        print()

        t_wall1 = time.perf_counter()

        prompt_text = self.tokenizer.decode(input_ids)
        generated_text = self.tokenizer.decode(generated_ids)

        bar = "=" * 70
        print(f"{bar}\nPROMPT:\n{prompt_text}\n{'-' * 70}\nGENERATED:\n{generated_text}\n{bar}")
        print(f"FULL TEXT:\n{prompt_text}{generated_text}\n{bar}")
        if stopped_on_eos:
            print("(stopped on end-of-text token)")

        new_tokens = len(generated_ids)
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

    def generate_compare(self, prompt, max_new_tokens=None, show_metrics=False):
        """Run SPARK (BF16) and the CPU reference (fp32) in lockstep on the same
        teacher-forced sequence.

        By default each decoded SPARK token is printed one at a time. With
        ``show_metrics=True`` (the --metrics flag) it also prints per-position
        closeness metrics: SPARK and the CPU reference are NOT expected to match
        bit-exactly (BF16 vs fp32, rounding compounds across layers), so these
        report cosine similarity of the logit vectors, max abs diff, and the
        rank the reference's top token gets in SPARK's logits rather than an
        exact argmax match. Small drift (cosine ~1, ref-top near rank 0) is
        expected/healthy; a collapse (cosine far below 1, ref-top buried at a
        high rank) indicates a real breakage.
        """
        max_new = self.max_new_tokens if max_new_tokens is None else max_new_tokens
        input_ids = self._encode_prompt(prompt)
        if not input_ids:
            print("empty prompt")
            return
        self._ensure_context(len(input_ids), max_new)

        if not os.path.isfile(OV_MODEL_REF):
            raise FileNotFoundError(f"compare needs the reference IR {OV_MODEL_REF!r} (and .bin).")

        core = ov.Core()
        ref_compiled = core.compile_model(core.read_model(OV_MODEL_REF), "CPU")
        ref_in = ref_compiled.inputs[0]
        pad_id = _tokenizer_pad_id(self.tokenizer)
        seq_len = self.seq_len

        def ref_logits_vec(ids):
            row = ids + [pad_id] * (seq_len - len(ids))
            out = np.asarray(next(iter(ref_compiled({ref_in: np.array([row], dtype=np.int64)}).values())),
                             dtype=np.float32)
            return out[0, len(ids) - 1]  # logits at the last real position

        def metrics(spark_vec, ref_vec):
            s = np.asarray(spark_vec, dtype=np.float32).reshape(-1)
            r = np.asarray(ref_vec, dtype=np.float32).reshape(-1)
            cos = float(np.dot(s, r) / (np.linalg.norm(s) * np.linalg.norm(r) + 1e-9))
            max_abs = float(np.abs(s - r).max())
            ref_top = int(r.argmax())
            # Rank of the reference's top token within SPARK's logits (0 == best).
            ref_top_rank = int((s > s[ref_top]).sum())
            return cos, max_abs, ref_top, int(s.argmax()), ref_top_rank

        eng = self._get_engine()
        eng.reset_position()

        ids = list(input_ids)
        steps = min(len(ids) - 1 + max_new, seq_len - 1)
        cur = list(ids[:1])
        spark_logits = eng(np.array([[ids[0]]]))
        if not show_metrics:
            print("GENERATED (teacher-forced): ", end="", flush=True)
        for step in range(steps):
            ref_vec = ref_logits_vec(cur)
            cos, max_abs, ref_top, spark_top, ref_top_rank = metrics(spark_logits, ref_vec)
            if show_metrics:
                agree = "OK" if spark_top == ref_top else f"rank{ref_top_rank}"
                print(f"step {step:3d} pos {len(cur)-1:3d} | cos={cos:.4f} max|d|={max_abs:8.3f} "
                      f"| spark_top={spark_top:>6} {self.tokenizer.decode([spark_top])!r:>10} "
                      f"ref_top={ref_top:>6} {self.tokenizer.decode([ref_top])!r:>10} | {agree}",
                      flush=True)
            else:
                print(self.tokenizer.decode([spark_top]), end="", flush=True)
            if step + 1 < len(input_ids):
                nxt = input_ids[step + 1]
            else:
                nxt = ref_top
            cur.append(nxt)
            spark_logits = eng(np.array([[nxt]]))
        if not show_metrics:
            print()

    def generate_openvino_cpu(self, prompt, max_new_tokens=None):
        """Greedy decode using the **fixed-seq** OpenVINO IR on CPU (no SPARK, no KV).

        Recomputes the full sequence each step so attention matches the exported ``seq_len-L``
        graph. Use when ``--backend spark`` output is wrong (e.g. KV insert failed silently).
        """
        max_new = self.max_new_tokens if max_new_tokens is None else max_new_tokens
        prompt_ids = self._encode_prompt(prompt)
        if not prompt_ids:
            print()
            return

        self._ensure_context(len(prompt_ids), max_new)

        if not os.path.isfile(OV_MODEL_REF):
            raise FileNotFoundError(
                f"OpenVINO CPU path needs {OV_MODEL_REF!r} (and .bin). "
                f"Export with convert_model.py for this model and --seq-len {self.seq_len}."
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

        print("GENERATED: ", end="", flush=True)
        generated_ids = []
        stopped_on_eos = False
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
            if next_id == eos_id:
                stopped_on_eos = True
                break
            ids.append(next_id)
            generated_ids.append(next_id)
            print(self.tokenizer.decode([next_id]), end="", flush=True)
        print()

        prompt_text = self.tokenizer.decode(prompt_ids)
        generated_text = self.tokenizer.decode(generated_ids)
        bar = "=" * 70
        print(f"\n{bar}\nPROMPT:\n{prompt_text}\n{'-' * 70}\nGENERATED:\n{generated_text}\n{bar}")
        print(f"FULL TEXT:\n{prompt_text}{generated_text}\n{bar}")
        if stopped_on_eos:
            print("(stopped on end-of-text token)")
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
    )
    if args.backend == "openvino_cpu":
        llm_loop.generate_openvino_cpu(prompt=args.prompt)
    elif args.backend == "compare":
        llm_loop.generate_compare(prompt=args.prompt, show_metrics=args.metrics)
    else:
        llm_loop.generate(prompt=args.prompt)


if __name__ == "__main__":
    main()

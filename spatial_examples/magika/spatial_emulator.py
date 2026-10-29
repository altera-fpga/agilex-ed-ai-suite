from __future__ import annotations

import argparse
import os
import time
from io import BytesIO
from pathlib import Path

import numpy as np
import onnx
import onnxruntime as rt
import openvino as ov
from fpga_ai_suite.spatial.compiler import spark_compiler as sc
from fpga_ai_suite.spatial.flow import run_flow
from fpga_ai_suite.spatial.layers.model_saver import restore_model, save_model
from magika import Magika
from magika.types import Seekable

# Compile the Magika file-type classifier OpenVINO IR with SPARK and run the
# resulting spatial model. This is the compiler counterpart to magika_spatial.py:
# where that script hand-builds the DAG with the SPARK layer API, this one takes
# the exported OpenVINO IR, runs it through sc.compile(), and emulates the spatial
# model on Magika's feature extraction. The result can be cross-checked against a
# reference backend and can drive run_flow() to simulate or Quartus-compile the RTL.

DUMP_PATH = "./spatial_emulator_dump"

# Spatial arch file (target device family + compile knobs) for this example.
ARCH_FILE = os.path.join(os.path.dirname(os.path.abspath(__file__)), "magika_agx7.arch")


def _log(msg: str) -> None:
    print(f"[spatial_emulator] {msg}", flush=True)


def _subdag_io_port(container, base, extra_keys=()):
    """Hybrid sub-DAGs name boundary ports din_0, dout_0, ...; flat DAGs use din, dout.

    When the gather/embedding stays inside SPARK, the body primary input keeps the
    OpenVINO Parameter name (Magika's is ``bytes``) instead of din / din_0.
    """
    for key in (base, f"{base}_0", *extra_keys):
        if key in container:
            return container[key]
    raise AttributeError(
        f"expected '{base}', '{base}_0', or {list(extra_keys)} in IO container; "
        f"keys are {list(container.keys())}"
    )


def _subdag_datain_port(sub_dag):
    """Primary input: Magika's OV Parameter is named ``bytes``; grouped sub-DAGs use din."""
    return _subdag_io_port(sub_dag.inputs, "din", extra_keys=("bytes",))


def _subdag_dataout_port(sub_dag):
    """Result keeps OV friendly names (e.g. target_label); grouped sub-DAGs use dout."""
    outs = sub_dag.outputs
    for key in ("dout", "dout_0"):
        if key in outs:
            return outs[key]
    if len(outs) == 1:
        return next(iter(outs.values()))
    raise AttributeError(
        f"expected 'dout', 'dout_0', or a single output port; keys are {list(outs.keys())}"
    )


class MagikaSpatialEngine:
    """Compile the Magika OV IR with SPARK and run the spatial emulator on features."""

    def __init__(self, ov_model_path: str, dump_path: str = DUMP_PATH):
        if not os.path.isfile(ov_model_path):
            raise FileNotFoundError(
                f"Missing Magika IR: {ov_model_path!r}."
            )
        core = ov.Core()
        ov_model = core.read_model(ov_model_path)

        spark_model = sc.compile(
            ov_model,
            ARCH_FILE,
            dump_path=dump_path,
            dump_data_rtl_testbench=False,
            visualize_graphs=False,
            print_compile_progress=True,
            print_optimization_progress=False,
            print_summary=False,
            generate_pta=False,
        )

        save_model(spark_model, dump_path + "/spark_model")
        restore_model(dump_path + "/spark_model", dump_path + "/spark_model.py")

        self.sub_dag = spark_model
        self._din = _subdag_datain_port(self.sub_dag)
        self._dout = _subdag_dataout_port(self.sub_dag)

    def classify(self, features: np.ndarray) -> np.ndarray:
        """Run one forward on (1, 1, 2048) byte-token features; return flat scores."""
        self._din.data = features
        self.sub_dag()
        return np.asarray(self._dout.data).flatten()


def preprocess_input(input_data):
    # Converts input file to a byte array and extracts features using Magika's helper
    magika_helper = Magika()
    if isinstance(input_data, Path):
        with open(input_data, "rb") as f:
            file_bytes = f.read()
    else:
        file_bytes = input_data

    result, features = magika_helper._get_result_or_features_from_seekable(Seekable(BytesIO(file_bytes)))
    assert features is not None, "Feature extraction failed."
    assert 1024 == magika_helper._model_config.beg_size == magika_helper._model_config.end_size
    assert 0 == magika_helper._model_config.mid_size
    my_inputs = np.array(features.beg[:1024] + features.end[-1024:], dtype=np.int32).reshape(1, 1, 2048)
    return my_inputs


def evaluate_output(output_scores):
    # Postprocesses the output scores to get the predicted label
    magika_helper = Magika()
    predicted_label_index = np.argmax(output_scores)
    predicted_label = magika_helper._target_labels_space[predicted_label_index]
    return predicted_label


def _onnx_reference_scores(features: np.ndarray) -> np.ndarray:
    """Run the original Magika ONNX model on CPU as the ground-truth reference."""
    magika_helper = Magika()
    magika_original = onnx.load(magika_helper._model_path)
    session = rt.InferenceSession(
        magika_original.SerializeToString(), providers=["CPUExecutionProvider"]
    )
    scores = session.run(["target_label"], {"bytes": features.reshape(1, 2048)})[0]
    return scores.flatten()


def _openvino_cpu_scores(ov_model_path: str, features: np.ndarray) -> np.ndarray:
    """Run the OpenVINO IR through OpenVINO on CPU; return flat scores."""
    core = ov.Core()
    compiled = core.compile_model(core.read_model(ov_model_path), "CPU")
    in_port = compiled.inputs[0]
    inp = features.reshape(list(in_port.shape)).astype(in_port.get_element_type().to_dtype())
    out = next(iter(compiled({in_port: inp}).values()))
    return np.asarray(out).flatten()


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Compile the Magika OpenVINO IR with SPARK and emulate the spatial model.",
    )
    p.add_argument(
        "--ov-model",
        default="magika.xml",
        metavar="PATH",
        help="OpenVINO XML model file (default: %(default)s)",
    )
    p.add_argument(
        "--file",
        default=None,
        metavar="PATH",
        help="File to classify. Default: a short Python snippet.",
    )
    p.add_argument(
        "--reference",
        choices=("onnx", "openvino_cpu", "none"),
        default="onnx",
        help="Ground-truth to cross-check the spatial result against: onnx runs the "
        "original Magika ONNX model, openvino_cpu runs the IR on CPU, none skips it "
        "(default: %(default)s)",
    )
    p.add_argument(
        "--dump-path",
        default=DUMP_PATH,
        metavar="PATH",
        help="Directory for SPARK compilation outputs (default: %(default)s)",
    )
    p.add_argument(
        "--sim",
        action="store_true",
        help="Run VCS RTL simulation and validate it against the emulator (~30 min)",
    )
    p.add_argument(
        "--compile",
        action="store_true",
        help="Run Quartus compilation to report fmax and resource usage (~40 min)",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()

    source = Path(args.file) if args.file is not None else b'# -*- coding: utf-8 -*-\nprint("Hello World!")'
    features = preprocess_input(source)

    engine = MagikaSpatialEngine(args.ov_model, dump_path=args.dump_path)
    t0 = time.perf_counter()
    actual = engine.classify(features)

    _log(f"compiler prediction: {evaluate_output(actual)} ({time.perf_counter() - t0:.3f}s)")
    print("Actual scores:")
    print(actual)

    if args.reference != "none":
        if args.reference == "onnx":
            expected = _onnx_reference_scores(features)
        else:
            expected = _openvino_cpu_scores(args.ov_model, features)
        print(f"Expected scores ({args.reference}):")
        print(expected)
        print("Expected prediction:", evaluate_output(expected))
        max_abs_diff = float(np.abs(actual - expected).max())
        label_match = bool(actual.argmax() == expected.argmax())
        _log(f"compare: max_abs_diff={max_abs_diff:.3e} label_match={label_match}")

    # Test the generated RTL: --sim runs VCS and validates the RTL output against the
    # emulator; --compile runs Quartus. With neither flag, skip the (slow) RTL flow.
    if args.sim or args.compile:
        ret = run_flow(
            engine.sub_dag,
            sim=args.sim,
            recompile=True,
            validate_timing=True,
            quartus_compile=args.compile,
            validate_resource_usage=False,
        )
        if ret != 0:
            raise RuntimeError(f"run_flow failed with exit code {ret}")


if __name__ == "__main__":
    main()

from __future__ import annotations

import argparse
import time
from pathlib import Path

import numpy as np
import openvino as ov
from fpga_ai_suite.spatial.compiler import spark_compiler as sc
from fpga_ai_suite.spatial.compiler.spatial_arch import SpatialCompileSettings
from fpga_ai_suite.spatial.flow import run_flow

# Compile the ResNet8 OpenVINO IR with SPARK and emulate the spatial model. Mirrors
# autoencoder.py / magika's spatial_emulator.py: the IR is compiled via sc.compile()
# rather than hand-building the DAG with the SPARK Developer API.

DEFAULT_OV_MODEL = "./resnet8/resnet8.xml"
DEFAULT_DUMP_PATH = "./my_dumps"

# BF16 SPARK math vs FP32 OpenVINO CPU -- exact match is not expected.
RTOL = 3e-2
ATOL = 3e-2

# Raw CIFAR-10 ".bin" image layout: 3*32*32 uint8 values, stored channel-planar
# (1024 R bytes, then 1024 G, then 1024 B) i.e. CHW. resnet8's Parameter_0 is
# NCHW float32 (1,3,32,32) -- same channel order -- so no transpose is needed.
INPUT_SHAPE_CHW = (3, 32, 32)
INPUT_NUM_BYTES = int(np.prod(INPUT_SHAPE_CHW))


def _log(msg: str) -> None:
    print(f"[resnet8_spatial] {msg}", flush=True)


def _require_ov_model(ov_model_path: str) -> None:
    """Validate that the OpenVINO IR was downloaded/converted as in README.md."""
    xml_path = Path(ov_model_path)
    bin_path = xml_path.with_suffix(".bin")
    if xml_path.is_file() and bin_path.is_file():
        return
    missing = []
    if not xml_path.is_file():
        missing.append(str(xml_path))
    if not bin_path.is_file():
        missing.append(str(bin_path))
    raise FileNotFoundError(
        f"Missing OpenVINO IR: {', '.join(missing)}.\n"
        "Download and convert with:\n"
        "  hf download EclipseAidge/resnet8 resnet8.onnx --local-dir .\n"
        "  altera_model_converter resnet8.onnx onnx -o ./resnet8\n"
        "See README.md for download instructions."
    )


def preprocess_input(bin_path: str, expected_shape) -> np.ndarray:
    """Load a raw ``.bin`` file of 3*32*32 uint8 CIFAR-style pixels and convert it
    to the float32 tensor the compiled model expects.

    Args:
        bin_path: path to a binary file containing exactly 3*32*32=3072 uint8
            values in CHW-planar order (standard CIFAR-10 .bin image layout).
        expected_shape: the compiled model's primary input shape (e.g. from
            ``in_port.ov_shape``), used to sanity-check compatibility.
    """
    raw = Path(bin_path).read_bytes()
    if len(raw) != INPUT_NUM_BYTES:
        raise ValueError(
            f"{bin_path!r}: expected {INPUT_NUM_BYTES} bytes "
            f"({'x'.join(map(str, INPUT_SHAPE_CHW))} uint8 CIFAR-style image), "
            f"got {len(raw)} bytes"
        )
    img_chw = np.frombuffer(raw, dtype=np.uint8).reshape(INPUT_SHAPE_CHW)
    img = img_chw.reshape((1, *INPUT_SHAPE_CHW)).astype(np.float32)

    expected_shape = tuple(int(d) for d in expected_shape)
    if img.shape != expected_shape:
        raise ValueError(
            f"preprocessed input shape {img.shape} is incompatible with the "
            f"compiled model's expected input shape {expected_shape}; resnet8's "
            f"input layout may have changed and this function needs updating"
        )
    return img


def _openvino_cpu_infer(ov_model_path: str, inp: np.ndarray) -> np.ndarray:
    """Run the IR on OpenVINO CPU; return the primary output as an ndarray."""
    core = ov.Core()
    compiled = core.compile_model(core.read_model(ov_model_path), "CPU")
    in_port = compiled.inputs[0]
    feed = inp.reshape(list(in_port.shape)).astype(in_port.get_element_type().to_dtype())
    return np.asarray(next(iter(compiled({in_port: feed}).values())))


def _run_emulation_and_compare(model, ov_model_path: str, in_vec: np.ndarray | None = None) -> None:
    assert len(model.inputs) == 1, f"expected a single primary input, got {list(model.inputs.keys())}"
    in_name, in_port = next(iter(model.inputs.items()))
    if in_vec is None:
        in_vec = np.random.randn(*in_port.ov_shape).astype(np.float32)
    else:
        expected_shape = tuple(int(d) for d in in_port.ov_shape)
        assert tuple(in_vec.shape) == expected_shape, (
            f"input shape {in_vec.shape} does not match model input shape {expected_shape}"
        )

    spark_out = np.asarray(model(**{in_name: in_vec})[0])
    ref_out = _openvino_cpu_infer(ov_model_path, in_vec)

    spark_flat = spark_out.astype(np.float32).reshape(-1)
    ref_flat = ref_out.astype(np.float32).reshape(-1)
    assert spark_flat.shape == ref_flat.shape, (
        f"shape mismatch: spark={spark_out.shape} ref={ref_out.shape}"
    )

    max_abs_diff = float(np.max(np.abs(spark_flat - ref_flat)))
    max_rel_diff = float(
        np.max(np.abs(spark_flat - ref_flat) / np.maximum(np.abs(ref_flat), 1e-8))
    )
    print(f"spark output shape: {spark_out.shape}")
    print(f"ref   output shape: {ref_out.shape}")
    print(f"compare: max_abs_diff={max_abs_diff:.3e} max_rel_diff={max_rel_diff:.3e}")

    np.testing.assert_allclose(spark_flat, ref_flat, rtol=RTOL, atol=ATOL)
    print(f"PASS: hybrid emulator matches OpenVINO CPU within rtol={RTOL} atol={ATOL}")


def parse_args() -> argparse.Namespace:
    p = argparse.ArgumentParser(
        description="Compile the ResNet8 OpenVINO IR with SPARK, emulate it against "
        "OpenVINO CPU, and optionally run RTL simulation / Quartus compilation.",
    )
    p.add_argument(
        "--ov-model",
        default=DEFAULT_OV_MODEL,
        metavar="PATH",
        help="OpenVINO XML model file (default: %(default)s)",
    )
    p.add_argument(
        "--dump-path",
        default=DEFAULT_DUMP_PATH,
        metavar="PATH",
        help="Directory for SPARK compilation outputs (default: %(default)s)",
    )
    p.add_argument(
        "--file",
        default=None,
        metavar="PATH",
        help="Raw .bin file of 3*32*32=3072 uint8 CIFAR-style pixel values to "
        "classify. Default: a random input (for regression-testing the compile).",
    )
    p.add_argument(
        "--sim",
        action="store_true",
        help="Run VCS RTL simulation and validate it against the emulator (slow)",
    )
    p.add_argument(
        "--compile",
        action="store_true",
        help="Run Quartus compilation to report fmax and resource usage (slow)",
    )
    return p.parse_args()


def main() -> None:
    args = parse_args()

    _require_ov_model(args.ov_model)
    core = ov.Core()
    ov_model = core.read_model(args.ov_model)

    # With hybrid_graph_support=True, unsupported ops stay as Virtual_layer nodes
    # (OpenVINO evaluate) and mapped SPARK layers (e.g. AvgPool) run in the emulator.
    # Returns (spark_model, hybrid_model): SPARK-only sub-DAG, and full mixed DAG.
    spark_model, hybrid_model = sc.compile(
        ov_model,
        SpatialCompileSettings(
            hybrid_graph_support=True,
            loop_rolling=False,
        ),
        dump_path=args.dump_path,
        dump_data_rtl_testbench=True,
        print_compile_progress=True,
        print_summary=False,
        generate_pta=False,
    )

    # Prefer hybrid_model for end-to-end SW emulation when unmapped ops remain.
    # If the graph fully lowers, hybrid_model is None -- fall back to spark_model.
    emulation_model = hybrid_model if hybrid_model is not None else spark_model

    in_vec = None
    if args.file is not None:
        assert len(emulation_model.inputs) == 1, (
            f"expected a single primary input, got {list(emulation_model.inputs.keys())}"
        )
        in_port = next(iter(emulation_model.inputs.values()))
        in_vec = preprocess_input(args.file, in_port.ov_shape)
        _log(f"loaded input from {args.file!r}: shape={in_vec.shape} dtype={in_vec.dtype}")

    t0 = time.perf_counter()
    _run_emulation_and_compare(emulation_model, args.ov_model, in_vec=in_vec)
    _log(f"emulation + compare took {time.perf_counter() - t0:.3f}s")

    # Test the generated RTL: --sim runs VCS and validates the RTL output against the
    # emulator; --compile runs Quartus. With neither flag, skip the (slow) RTL flow.
    # run_flow needs the pure SPARK sub-DAG (spark_model): hybrid_model may still
    # contain Virtual_layer nodes (OpenVINO evaluate) that aren't synthesizable.
    if args.sim or args.compile:
        ret = run_flow(
            spark_model,
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

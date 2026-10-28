import argparse
from pathlib import Path

import numpy as np
import openvino as ov
from fpga_ai_suite.spatial.compiler import spark_compiler as sc
from fpga_ai_suite.spatial.flow import run_flow

DEFAULT_OV_MODEL = "./ad01_fp32/ad01_fp32.xml"


def _require_ov_model(ov_model_path: str) -> None:
    """Validate that the OpenVINO IR was fetched/converted as in README.md."""
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
        "Fetch and convert with:\n"
        "  altera_model_zoo convert ad01_fp32 --output-dir ./ad01_fp32\n"
        "See README.md for download instructions."
    )


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument("--sim", action="store_true")
    parser.add_argument("--compile", action="store_true")
    args = parser.parse_args()

    _require_ov_model(DEFAULT_OV_MODEL)
    core = ov.Core()
    ov_model = core.read_model(DEFAULT_OV_MODEL)

    # SPARK
    spark_model = sc.compile(
        ov_model,
        dump_path='./my_dumps',
        dump_data_rtl_testbench=False,
        print_compile_progress=True,
    )

    # Emulation
    batch_size = 4
    in_vec = np.random.random((batch_size, 640))
    out_vec, = spark_model(input_1=in_vec)

    # RTL sim
    ret = run_flow(spark_model, sim=args.sim, recompile=True, quartus_compile=args.compile)
    if ret != 0:
        raise RuntimeError(f"run_flow failed with exit code {ret}")

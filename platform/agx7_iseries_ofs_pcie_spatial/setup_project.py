from jinja2 import Template
from fpga_ai_suite.spatial.layers import Directed_acyclic_graph
from fpga_ai_suite.spatial.layers.model_saver import restore_model, load_model
import argparse
import json
import re
import shutil
import tempfile
from pathlib import Path


def _render_template(output_file: Path, template_dir: Path, template_name: str, **context) -> None:
    with open(output_file, "w", encoding="utf-8") as f:
        template_path = template_dir / template_name
        template = Template(template_path.read_text(encoding="utf-8"))
        rendered_output = template.render(**context)
        f.write(rendered_output)


def _write_hw_sources(sources_path: Path, platform_hw_path: Path,
                      model_sv_path: Path, spark_sv_files: list[Path]) -> None:
    platform_entries = [
        "spark_demo.json",
        "write_engine.sv",
        "p2s.sv",
        "csr_mgr.sv",
        "read_engine.sv",
        "read_packet_manager.sv",
        "read_requester.sv",
        "write_packet_manager.sv",
        "s2p.sv",
        "spark_afu_pkg.sv",
        "spark_afu_top.sv",
        "ofs_plat_afu.sv",
    ]

    with sources_path.open("w", encoding="utf-8") as f:
        f.write("# AFU files\n")
        for entry in platform_entries:
            f.write(f"{platform_hw_path / entry}\n")
        f.write("\n# model and spark rtl\n")
        f.write(f"{model_sv_path}\n")
        for sv_file in spark_sv_files:
            f.write(f"{sv_file}\n")


def _port_config_from_model(in_port, out_port) -> dict:
    # SPARK port shape is (packets, n, m); data.shape[0] matches when data is set.
    input_packets = in_port.shape[0]
    output_packets = out_port.shape[0]
    return {
        "input_data_width": in_port.dw,
        "input_lanes": in_port.num_lanes,
        "input_subvectors": in_port.sub_vectors,
        "input_packets": input_packets,
        "output_data_width": out_port.dw,
        "output_lanes": out_port.num_lanes,
        "output_subvectors": out_port.sub_vectors,
        "output_packets": output_packets,
    }


def _write_port_config(path: Path, in_port, out_port) -> None:
    with path.open("w", encoding="utf-8") as f:
        json.dump(_port_config_from_model(in_port, out_port), f, indent=4)
        f.write("\n")


def _generated_model_dir(ip_dir: Path, model: str, arch_name: str) -> Path:
    """Return verilog/{model}_{arch_name} for this create-ip dump."""
    return ip_dir / "altera_ai_ip" / "verilog" / f"{model}_{arch_name}"


def _model_rtl_path(model, generated_model_dir: Path) -> Path:
    """Find the generated SystemVerilog file that declares the model's top module."""
    rtl_dir = generated_model_dir / "rtl"
    if not rtl_dir.is_dir():
        raise ValueError(
            f"Expected create-ip RTL directory at {rtl_dir}."
        )
    module_declaration = re.compile(
        rf"^\s*module\s+{re.escape(model.module_name)}(?:\s|#|\()",
        re.MULTILINE,
    )
    matches = [
        path
        for path in rtl_dir.iterdir()
        if path.suffix == ".sv"
        and module_declaration.search(path.read_text(encoding="utf-8"))
    ]
    if len(matches) != 1:
        raise ValueError(
            f"Expected one RTL file declaring module '{model.module_name}' in "
            f"{rtl_dir}; found {len(matches)}."
        )
    return matches[0]


def _copy_generated_data(generated_model_dir: Path, dump_files_dir: Path) -> None:
    """Copy create-ip dump_files/ (mifs, vectors) into the ED dump_files dir."""
    dump_files_dir.mkdir(parents=True, exist_ok=True)
    src_dump = generated_model_dir / "dump_files"
    if not src_dump.is_dir():
        raise ValueError(
            f"Expected create-ip dump_files directory at {src_dump}."
        )
    for path in src_dump.iterdir():
        if path.is_file():
            shutil.copy2(path, dump_files_dir / path.name)


def get_ofs_files(
    model,
    generated_model_dir: Path,
    dump_path="OFS_PCIE_ED",
):
    """!
    Dumps the OFS configuration files for this DAG.

    @param dump_path the path to dump the OFS configuration files into
    """
    Path(dump_path).mkdir(parents=True, exist_ok=True)

    OFS_ED_src_path = Path(__file__).resolve().parent
    platform_hw_path = OFS_ED_src_path / "hw"
    generated_hw_path = Path(dump_path) / "hw"
    generated_hw_path.mkdir(parents=True, exist_ok=True)
    if platform_hw_path.resolve() != generated_hw_path.resolve():
        shutil.copytree(platform_hw_path, generated_hw_path, dirs_exist_ok=True)

    in_port = next(iter(model.inputs.values()))
    out_port = next(iter(model.outputs.values()))

    template_dir = OFS_ED_src_path / "templates"

    _render_template(generated_hw_path / "ofs_plat_afu.sv", template_dir, "ofs_plat_afu_template.jinja2", num_weight_channels=len(model.weights))
    _render_template(generated_hw_path / "spark_afu_pkg.sv", template_dir, "spark_afu_pkg_template.jinja2", in_port=in_port, out_port=out_port)
    _render_template(generated_hw_path / "spark_afu_top.sv", template_dir, "spark_afu_top_template.jinja2", top=model, in_port=in_port, out_port=out_port)

    # create-ip dump_ip_component layout: SPARK + DAG RTL under verilog/{model}_{arch}_{family}/rtl/
    spark_rtl_path = generated_model_dir / "rtl"
    if not spark_rtl_path.is_dir():
        raise ValueError(f"Expected create-ip RTL directory at {spark_rtl_path}.")
    model_sv_name = f"{model.module_name}.sv"
    sv_files = sorted(
        path.resolve()
        for path in spark_rtl_path.rglob("*.sv")
        if path.name != model_sv_name
    )
    model_sv_path = Path(dump_path) / "rtl" / model_sv_name

    _write_hw_sources(
        generated_hw_path / "sources.txt",
        generated_hw_path.resolve(),
        model_sv_path.resolve(),
        sv_files,
    )


def setup_project(
    model: Directed_acyclic_graph,
    dirname: Path,
    generated_model_dir: Path,
) -> None:
    """Setup and initialize the Spatial example design Quartus project."""
    dirname.mkdir(parents=True, exist_ok=True)

    in_port = next(iter(model.inputs.values()))
    out_port = next(iter(model.outputs.values()))
    _write_port_config(dirname / "port_config.json", in_port, out_port)

    rtl_dir = dirname / "rtl"
    rtl_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(
        _model_rtl_path(model, generated_model_dir),
        rtl_dir / f"{model.module_name}.sv",
    )
    _copy_generated_data(generated_model_dir, dirname / "dump_files")

    get_ofs_files(model, generated_model_dir, dump_path=dirname)

    print("-- Setup complete")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Setup and initialize the Spatial example design Quartus project."
    )
    parser.add_argument(
        "arch_name",
        help="Architecture name",
    )
    parser.add_argument(
        "ip_dir",
        type=Path,
        help="Generated IP root",
    )
    parser.add_argument(
        "model",
        help="Model name used in verilog/{model}_{arch}_{family}/",
    )

    args = parser.parse_args()

    generated_model_dir = _generated_model_dir(
        args.ip_dir, args.model, args.arch_name
    )
    model_dir = generated_model_dir / "saved_model"
    required_files = ("model.protobuf", "data.safetensors")
    missing_files = [name for name in required_files if not (model_dir / name).is_file()]
    if missing_files:
        raise ValueError(
            f"Serialized model at {model_dir} is missing: "
            f"{', '.join(missing_files)}."
        )

    with tempfile.TemporaryDirectory() as temporary_dir:
        restored_model_path = Path(temporary_dir) / "model.py"
        restore_model(model_dir, restored_model_path)
        model = load_model(model_dir, restored_model_path)
        model.auto_connect_weights()
        model.validate_weight_connections()

        # Delete any unconnected weight ports to avoid dumping artifacts.
        for weight_port in model.weights.ports():
            weight_port.prepare_for_dumping()
            if len(weight_port.dests) == 0:
                print(f"Warning: No weight port connections found for {weight_port.name}.")
                del model.weights[weight_port.name]

    if len(model.inputs) != 1 or len(model.outputs) != 1:
        raise ValueError("OFS example design only supports 1 input and 1 output for now.")

    # Restored model should already have data
    for in_port in model.inputs.ports():
        if in_port.data is None:
            raise ValueError(f"Input port {in_port.name} has no data. Please save the model after running forward or setting the input.")

    for out_port in model.outputs.ports():
        if out_port.data is None:
            model()
            break

    setup_project(model, Path.cwd(), generated_model_dir)

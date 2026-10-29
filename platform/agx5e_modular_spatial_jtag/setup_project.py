from jinja2 import Template
from fpga_ai_suite.spatial.layers import Directed_acyclic_graph, IO_port
from fpga_ai_suite.spatial.layers.model_saver import restore_model, load_model
import argparse
import json
import shutil
import tempfile
from pathlib import Path

# This example design builds one input and one output only, so the Avalon memory
# mapped region below is fixed. This same comment is found in
# runtime/coredla_device/mmd/spatial_jtag/inc/address_map.h 
#
# Timer (16 bytes) at 0x00000000
#   |_ Cycle count, latched when the inference ends (4 bytes)
#   |_ Status (4 bytes)
#   |_ Live cycle count, while an inference is running (4 bytes)
#   |_ 0 (4 bytes)
#
# mSGDMA (128 bytes total). The 64 byte ingress msgdma descriptor begins at
# 0x00000020 and the 64 byte egress msgdma at 0x00000060. Both are sized the
# same as an EMIF beat
#   Each descriptor:
#   CSR (32 bytes)
#   |_ CSR status (4 bytes)
#   |_ CSR Control (4 bytes)
#   |_ reserved (24 bytes)
#   Descriptor (32 bytes)
#   |_ Descriptor read address, low word (4 bytes)
#   |_ Descriptor write address, low word (4 bytes)
#   |_ Descriptor length (4 bytes)
#   |_ Descriptor sequence number and burst counts (4 bytes)
#   |_ Descriptor read and write stride (4 bytes)
#   |_ Descriptor read address, high word (4 bytes)
#   |_ Descriptor write address, high word (4 bytes)
#   |_ Descriptor control (4 bytes)
#
# Address span extender control (32 bytes total). DDR bank 0 begins
# at 0x00000100 and bank 1 begins at 0x00000110 -> 16 bytes per bank
# Per bank:
#   |_ Window byte base, low word (4 bytes)
#   |_ Window byte base, high word (4 bytes)
#
# DDR windows (2GB windows total) at 0x40000000 for bank 0 and 0x80000000 for bank 1.
# Bank 0 carries weights and the input and output tensors. Bank 1 carries
# weights only. A design with no DDR-offloaded weights still brings up bank 0
# so the mSGDMAs have somewhere to stage features.
#
# ===========================================================================
# THE ADDRESS AND DDR CONSTANTS BELOW MUST MATCH
# runtime/coredla_device/mmd/spatial_jtag/inc/address_map.h EXACTLY.
# The runtime will get port_config.json which ONLY holds port geometry
# determined at compile time
#
# ANY EDIT HERE MUST BE MADE IN that address_map.h IN THE SAME CHANGE, AND THE
# OTHER WAY AROUND.
# ===========================================================================

########### TIMER ADDRESS CONSTANTS ###########
# JTAG to Avalon MM address
TIMER_BASE_ADDR = 0x00000000
TIMER_ADDRESS_WIDTH = 2

########### msgdma + DMA CONSTANTS ###########
# JTAG to Avalon MM addresses
DMA_INGRESS_BASE_ADDR = 0x00000020
DMA_EGRESS_BASE_ADDR = 0x00000060
# Offsets into the ingress/egress base address
DMA_CSR_OFFSET = 0x0
DMA_DESCRIPTOR_OFFSET = 0x20

########### SYSTEM CONSTANTS ###########
# Default spatial ip frequency. THis is adjusted by dla_adjust_pll.tcl after fitting
DEFAULT_KERNEL_CLK_MHZ = 300.0

########### SPAN EXTENDER CONSTANTS ###########
# JTAG to Avalon MM address
SPAN_EXTENDER_CNTL_BASE = 0x00000100
SPAN_EXTENDER_CNTL_STRIDE = 0x10

########### DDR CONSTANTS ###########
FEATURE_BANK = 0
NUM_DDR_BANKS = 2
# JTAG to Avalon MM addresses
DDR_BANK_BASE_ADDR = 0x40000000
# 1GB window for sliding across the banks
DDR_WINDOW_SIZE = 0x40000000
# The EMIF presents a 256 bit AXI4 user interface. This is also the "emif beat"
DDR_CHANNEL_WIDTH = 256
# 8GB storage per bank -> 33-bit address space
DDR_BANK_CAPACITY_BYTES = 8 * 1024**3
DDR_SLAVE_ADDR_WIDTH = 33

########### FEATURE STAGING CONSTANTS ###########
# Restrict input and output tensor(s) DDR windows to 1GB
FEATURE_REGION_BYTES = 1 * 1024**3
# The feature regions sit at the top of the feature bank with weights
# occupying the memory space below it
INPUT_FEATURE_BASE = DDR_BANK_CAPACITY_BYTES - 2 * FEATURE_REGION_BYTES
OUTPUT_FEATURE_BASE = DDR_BANK_CAPACITY_BYTES - FEATURE_REGION_BYTES
FEATURE_BANK_WEIGHT_LIMIT = INPUT_FEATURE_BASE

# Used for comments in templates and top module generation
DDR_BANK_PROFILES = (
    {
        "io_bank": "2B",
        # Top level port prefix
        "port_prefix": "ddr4_2b",
        "pin_file": "ddr4_2b_pins.tcl",
        "dq_width": 32,
        "dqs_width": 4,
    },
    {
        "io_bank": "3B",
        "port_prefix": "ddr4_3b",
        "pin_file": "ddr4_3b_pins.tcl",
        # 3B carries an ECC byte
        "dq_width": 40,
        "dqs_width": 5,
    },
)


def _packet_count(port: IO_port) -> int:
    """Get the number of packets per port tensor."""
    # (p, n, m) shape
    return int(port.shape[0])


def _emif_beat_bytes() -> int:
    """Bytes in one fabric-EMIF user beat"""
    return DDR_CHANNEL_WIDTH // 8


def _subvector_bits(port: IO_port) -> int:
    """Calculate the size of one spark subvector"""
    return port.dw * port.num_lanes


def _subvectors_per_emif_beat(port: IO_port) -> int:
    """Number of whole subvectors that fit in one EMIF/msgDMA/IP beat.

    The spatial IP packs those subvectors contiguously from the LSB. Bits above
    that are padding when the subvector width does not divide the beat.
    """
    bits = _subvector_bits(port)
    if bits <= 0 or bits > DDR_CHANNEL_WIDTH:
        raise ValueError(
            f"Port '{port.name}' needs a {bits}-bit subvector "
            f"({port.dw}-bit data x {port.num_lanes} lanes), which is wider than the "
            f"{DDR_CHANNEL_WIDTH}-bit EMIF beat this example design uses."
        )
    # floor div
    return DDR_CHANNEL_WIDTH // bits


def _stream_port_config(port: IO_port, is_input: bool) -> dict:
    """Construct the configuration for input/output `port`."""
    dma_addr = DMA_INGRESS_BASE_ADDR if is_input else DMA_EGRESS_BASE_ADDR
    packets = _packet_count(port)
    subvectors_per_beat = _subvectors_per_emif_beat(port)
    # ceil(subvectors in a packet / subvectors in an emif beat)
    beats_per_packet = (port.sub_vectors + subvectors_per_beat - 1) // subvectors_per_beat
    bus_beats = packets * beats_per_packet  # Number of emif beats per io tensor
    tensor_bytes = bus_beats * _emif_beat_bytes()
    if tensor_bytes > FEATURE_REGION_BYTES:
        raise ValueError(
            f"Port '{port.name}' needs {tensor_bytes} bytes for one tensor, more "
            f"than the {FEATURE_REGION_BYTES} byte DDR region this example design "
            f"reserves per input."
        )

    return {
        "name": port.name,
        # data width
        "dw": port.dw,
        "num_lanes": port.num_lanes,
        # Number of subvectors per packet
        "sub_vectors": port.sub_vectors,
        # Avalon-ST, msgDMA and spatial IP I/O width. Always one EMIF beat
        "stream_width": DDR_CHANNEL_WIDTH,
        # Number of subvectors per emif beat
        "subvectors_per_beat": subvectors_per_beat,
        # Number of emif beats per packet
        "beats_per_packet": beats_per_packet,
        # EMIF beats in one tensor after per-packet beat rounding
        "bus_beats": bus_beats,
        # Exact tensor length the ingress/egress descriptor transfers
        "tensor_bytes": tensor_bytes,
        # Number of packets per tensor
        "packets": packets,
        # DDR addresses during staging
        "ddr_base_addr": INPUT_FEATURE_BASE if is_input else OUTPUT_FEATURE_BASE,
        "ddr_region_bytes": FEATURE_REGION_BYTES,
        # msgdma addresses
        "dma_csr_addr": dma_addr,
        "dma_descriptor_addr": dma_addr + DMA_DESCRIPTOR_OFFSET,
    }


def _require_single_io(model: Directed_acyclic_graph) -> None:
    """Fail on models that do not have exactly one input and one output."""
    if len(model.inputs) != 1 or len(model.outputs) != 1:
        raise ValueError(
            f"This example design only supports 1 input and 1 output. The model has "
            f"{len(model.inputs)} input(s) and {len(model.outputs)} output(s)."
        )

    # PD seems to silently drop interfaces with '__' in their name. Fail this situation
    # before compilation starts
    for label, port in (
        ("Input", next(iter(model.inputs.ports()))),
        ("Output", next(iter(model.outputs.ports()))),
    ):
        if "__" in port.name:
            raise ValueError(
                f"{label} port '{port.name}' contains '__', which cannot be used "
                f"as a Platform Designer interface name. Rename the port without "
                f"consecutive underscores."
            )


def _weight_bytes_per_bank(dump_dir: Path) -> dict:
    """Calculate the number of weight bytes placed in each DDR bank

    The spark compiler places weight files in `dump_dir/` with the name
    weights_ddr_<bank index>_<byte offset>.bin. The `byte offset` portion
    is the DDR starting byte where the IP will begin reading from
    """
    extents = {}
    for dump in dump_dir.glob("weights_ddr_*.bin"):
        fields = dump.stem.split("_")
        if len(fields) != 4:
            raise ValueError(f"Cannot read a bank and an offset out of {dump.name}.")
        bank, offset = int(fields[2]), int(fields[3])
        extents[bank] = max(extents.get(bank, 0), offset + dump.stat().st_size)
    return extents


def _weight_ports(model: Directed_acyclic_graph) -> dict:
    """DDR weight ports keyed by bank. Empty when every weight comes from a MIF."""
    ports = {}
    for port in model.weights.ports():
        if len(port.dests) == 0 or port.interface != "DDR":
            continue
        if port.bank >= NUM_DDR_BANKS:
            raise ValueError(
                f"Weight port '{port.name}' asks for DDR bank {port.bank}. This "
                f"example design has banks 0 through {NUM_DDR_BANKS - 1}."
            )
        if port.ddr_channel_width != DDR_CHANNEL_WIDTH:
            raise ValueError(
                f"Weight port '{port.name}' has a {port.ddr_channel_width} bit DDR "
                f"channel, but the EMIF on this board is {DDR_CHANNEL_WIDTH} bits. "
                f"Rebuild the model with ddr_channel_width={DDR_CHANNEL_WIDTH}."
            )
        # Platform Designer will not map a DDR bank an emif that cannot address
        # all of it
        if port.ddr_addr_width < DDR_SLAVE_ADDR_WIDTH:
            raise ValueError(
                f"Weight port '{port.name}' drives a {port.ddr_addr_width} bit DDR "
                f"address, too narrow for the {DDR_SLAVE_ADDR_WIDTH} bit EMIF "
                f"subordinate. Rebuild the model with "
                f"ddr_addr_width={DDR_SLAVE_ADDR_WIDTH}."
            )
        ports[port.bank] = port
    return ports


def _bank_config(index: int, port, used: int) -> dict:
    """Configuration for one DDR bank. `port` is None when the bank holds no weights.
    `used` is the number of weight bytes
    """
    holds_features = index == FEATURE_BANK
    weight_capacity = FEATURE_BANK_WEIGHT_LIMIT if holds_features else DDR_BANK_CAPACITY_BYTES
    if used > weight_capacity:
        raise ValueError(
            f"The model puts {used} bytes of weights in DDR bank {index}, more "
            f"than the {weight_capacity} bytes reserved for weights on that bank."
        )

    return {
        "bank": index,  # An index into the DDR_BANK_PROFILES array
        # Empty when this bank has no weight port
        "port_name": port.name if port is not None else "",
        # Window the host slides over this bank, and the register that
        # slides it
        "jtag_base_addr": DDR_BANK_BASE_ADDR + index * DDR_WINDOW_SIZE,
        "window_bytes": DDR_WINDOW_SIZE,
        "cntl_addr": SPAN_EXTENDER_CNTL_BASE + index * SPAN_EXTENDER_CNTL_STRIDE,
        "holds_features": holds_features,
    }


def _ddr_bank_configs(model: Directed_acyclic_graph, dump_dir: Path) -> list:
    """
    Get ddr bank configuration to template hardware
    """
    ports = _weight_ports(model)
    weight_bytes = _weight_bytes_per_bank(dump_dir)

    banks = []
    for index in range(NUM_DDR_BANKS):
        port = ports.pop(index, None)
        used = weight_bytes.pop(index, 0)
        if port is None and used:
            raise ValueError(
                f"{dump_dir} holds weights for DDR bank {index}, which no weight "
                f"port on the model reads."
            )
        if port is not None or index == FEATURE_BANK:
            banks.append(_bank_config(index, port, used))

    # Check if any layers are assigned to DDR bank > 2 
    if ports or weight_bytes:
        leftover = sorted(set(ports) | set(weight_bytes))
        raise ValueError(
            f"{dump_dir} holds weights for DDR bank(s) {leftover}, which "
            f"no weight port on the model reads."
        )

    return banks


def system_config(model: Directed_acyclic_graph, dump_dir: Path) -> dict:
    """Gather the configuration the templates need to render the hardware.

    This never reaches the runtime. The demo gets the port geometry through
    port_config.json and declares every address for itself in
    external/runtime/coredla_device/mmd/spatial_jtag/inc/address_map.h
    """
    # this example design builds one stream in each direction
    _require_single_io(model)

    input_port = _stream_port_config(next(iter(model.inputs.ports())), is_input=True)
    output_port = _stream_port_config(next(iter(model.outputs.ports())), is_input=False)

    ddr_banks = _ddr_bank_configs(model, dump_dir)

    return {
        "module_name": model.module_name,
        "input_port": input_port,
        "output_port": output_port,
        "kernel_clk_mhz": DEFAULT_KERNEL_CLK_MHZ,
        "timer_base_addr": TIMER_BASE_ADDR,
        "ddr_banks": ddr_banks,
        "feature_bank": FEATURE_BANK,
        "ddr_channel_width": DDR_CHANNEL_WIDTH,
    }


def _port_config(config: dict) -> dict:
    """The port geometry the runtime reads back out of port_config.json."""
    input_port = config["input_port"]
    output_port = config["output_port"]
    return {
        "input_data_width": input_port["dw"],
        "input_lanes": input_port["num_lanes"],
        "input_subvectors": input_port["sub_vectors"],
        "input_packets": input_port["packets"],
        "output_data_width": output_port["dw"],
        "output_lanes": output_port["num_lanes"],
        "output_subvectors": output_port["sub_vectors"],
        "output_packets": output_port["packets"],
    }


def _render_template(output_file: Path, template_file: Path, **context) -> None:
    template = Template(
        template_file.read_text(encoding="utf-8"),
        keep_trailing_newline=True,
        trim_blocks=False,
    )
    output_file.write_text(template.render(**context), encoding="utf-8")


def _generated_model_dir(ip_dir: Path, model: str, arch_name: str) -> Path:
    """Return verilog/{model}_{arch_name} for this create-ip dump."""
    return ip_dir / "altera_ai_ip" / "verilog" / f"{model}_{arch_name}"


def _copy_ip_component(
    model: Directed_acyclic_graph,
    generated_model_dir: Path,
    ip_dir: Path,  # destination ip directory inside the quartus project tree
) -> None:
    """Copy the necessary ip files, including the spatial pd wrapper, into the ED."""
    required_paths = (
        generated_model_dir / f"{model.module_name}_hw.tcl",  # spatial ip pd component tcl script
        generated_model_dir / f"{model.module_name}_PD_component.sv",  # pd wrapper tcl script
        generated_model_dir / "rtl",  # spatial ip rtl files
        generated_model_dir / "dump_files",  # mif, simulation files
    )
    missing_paths = [path for path in required_paths if not path.exists()]
    if missing_paths:
        raise ValueError(
            "Generated spatial IP component is missing: "
            + ", ".join(str(path) for path in missing_paths)
        )

    ip_dir.mkdir(parents=True, exist_ok=True)
    shutil.copy2(required_paths[0], ip_dir)
    shutil.copy2(required_paths[1], ip_dir)
    shutil.copytree(required_paths[2], ip_dir / "rtl", dirs_exist_ok=True)
    shutil.copytree(
        required_paths[3], ip_dir / "dump_files", dirs_exist_ok=True
    )


def setup_project(
    model: Directed_acyclic_graph,
    dirname: Path,
    generated_model_dir: Path,
) -> None:
    """Setup and initialize the Spatial example design Quartus project."""
    dirname.mkdir(parents=True, exist_ok=True)

    config = system_config(model, generated_model_dir / "dump_files")
    template_dir = Path(__file__).resolve().parent / "templates"

    # copy ip files
    _copy_ip_component(model, generated_model_dir, dirname / "ip")

    # If a model has no memory_interfaces, then ddr_pins.tcl and ddr_clocks.sdc come up empty
    for output_name, template_name in (
        ("system.tcl", "system.tcl.jinja2"),
        ("system_top.sv", "system_top.sv.jinja2"),
        ("ddr_pins.tcl", "ddr_pins.tcl.jinja2"),
        ("ddr_clocks.sdc", "ddr_clocks.sdc.jinja2"),
    ):
        _render_template(
            dirname / output_name,
            template_dir / template_name,
            board=DDR_BANK_PROFILES,
            **config,
        )

    # Write port configuration file for use by the runtime
    (dirname / "port_config.json").write_text(
        json.dumps(_port_config(config), indent=4) + "\n", encoding="utf-8"
    )

    # Kernel frequency is adjusted after fitting. generate_sof.tcl rewrites
    # the following file with the final fmax
    (dirname / "kernel_clk.json").write_text(
        json.dumps({"kernel_clk_mhz": DEFAULT_KERNEL_CLK_MHZ}, indent=4) + "\n",
        encoding="utf-8",
    )

    shutil.copytree(
        generated_model_dir / "dump_files",
        dirname / "dump_files",
        dirs_exist_ok=True,
    )

    print("-- Setup complete")


if __name__ == "__main__":
    parser = argparse.ArgumentParser(
        description="Setup and initialize the Spatial example design Quartus project."
    )
    parser.add_argument(
        "arch_name",  # This is suffixed with _{device family}
        help="Architecture name",
    )
    parser.add_argument(
        "ip_dir",
        type=Path,
        help="Generated IP root",
    )
    parser.add_argument(
        "model",
        help="Model name used in {ip_dir}/altera_ai_ip/verilog/{model}_{arch}_{family}/",
    )

    args = parser.parse_args()

    generated_model_dir = _generated_model_dir(
        args.ip_dir, args.model, args.arch_name
    )
    model_dir = generated_model_dir / "saved_model"
    required_model_files = ("model.protobuf", "data.safetensors")

    # Check that the saved model is present
    missing_files = [name for name in required_model_files if not (model_dir / name).is_file()]
    if missing_files:
        raise ValueError(
            f"Serialized model at {model_dir} is missing: "
            f"{', '.join(missing_files)}."
        )

    # Load the serialized model to extract input/output port shapes and names
    with tempfile.TemporaryDirectory() as temporary_dir:
        restored_model_path = Path(temporary_dir) / "model.py"
        restore_model(model_dir, restored_model_path)
        model = load_model(model_dir, restored_model_path)

    setup_project(
        model,
        Path.cwd(),
        generated_model_dir,
    )

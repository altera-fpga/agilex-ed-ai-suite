#!/usr/bin/env python3
# ============================================================================
# This script takes as input, paths to two files, where the first file indicates
# the location of the Terasic BSP and the second file indicates the target
# directory for the patched BSP.
#
# The script does the following
#
#   1. Copies the Terasic stock BSP to the CoreDLA root directory
#
#   2. Runs the patch command with the diff files
#
#   3. Copy the modified BSP to platform/de10_agilex
#
# ============================================================================

import argparse
import os
import shutil
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory
from typing import List, Optional, Union

# Terasic exclusive files
BASE_FILES = [
    "acl_kernel_clk_agilex_reconfig_hw.tcl",
    "acl_kernel_interface_agilex_hw.tcl",
    "base.qar",
    "base.qsf",
    "board_spec.xml",
    "compile_script.tcl",
    "scripts",
]
IP_FILES = ["freeze_wrapper.v", "pr_region.v"]
BOARD_FILES = [
    "board_acl_avalon_mm_bridge_s10_1.ip",
    "board_clock_bridge_0.ip",
    "board_constant_address_bridge_0.ip",
    "board_dma_pr_reordering_buffer_0.ip",
    "board_kernel_clk_export.ip",
    "board_kernel_interface_agilex_1.ip",
    "board_memory_bank_divider_ddr4a.ip",
    "board_mm_bridge_0.ip",
    "board_mm_bridge_1.ip",
    "board_mm_bridge_2.ip",
    "board_mm_bridge_3.ip",
    "board_npor_export.ip",
    "board_pcie_refclk.ip",
    "board_pr_region_controller_0.ip",
    "board_reset_controller_0.ip",
    "board_s10_pr_0.ip",
]
MEM_FILES = ["mem_acl_clock_crossing_bridge_0.ip", "mem_kernel_clk_in.ip"]


def run_cmd(*args: Union[Path, str], cwd: Optional[Path] = None) -> None:
    call_args: list[str] = []
    for arg in args:
        if isinstance(arg, Path):
            arg = arg.as_posix()
        call_args.append(arg)

    print(f"Run {' '.join(call_args)}")
    subprocess.check_call(call_args, cwd=cwd)


def copy_terasic_bsp(terasic_path: Path, coredla_path: Path, new_bsp_path: Path) -> int:
    # create a new directory for the Terasic BSP under platform/de10_agilex
    print(f"Copy Terasic BSP to {new_bsp_path}")
    shutil.rmtree(new_bsp_path)

    # check terasic bsp path exists
    if not os.path.exists(terasic_path):
        sys.exit("Error: Path to Terasic BSP does not exist!")

    # copy the bsp to the new location
    src = terasic_path / "hardware" / "B2E2_8GBx4"
    shutil.copytree(src, new_bsp_path)

    return 1


def patch_terasic_bsp(new_bsp_path: Path, coredla_path: Path) -> int:
    # $DLA_BSP_PATCH_DIR is used internally during development
    patch_file_loc = os.environ.get("DLA_BSP_PATCH_DIR")
    if patch_file_loc is not None:
        patch_file_loc = Path(patch_file_loc) / "de10_bsp.patch"
    else:
        patch_file_loc = coredla_path / "platform" / "de10_bsp.patch"

    if not os.path.isfile(patch_file_loc):
        sys.exit(
            f"Error: Unable to find patch file for Terasic BSP at directory {patch_file_loc}"
        )

    # Make sure the patching process is going to work
    run_cmd("patch", "-s", "--dry-run", "-p0", "-i", patch_file_loc, cwd=new_bsp_path)
    # Apply the patch
    run_cmd("patch", "-s", "-p0", "-i", patch_file_loc, cwd=new_bsp_path)

    return 1


def cleanup(new_bsp_path: Path) -> int:
    # remove files exclusive to terasic
    to_remove: List[Path] = []
    to_remove.extend(Path(f) for f in BASE_FILES)
    to_remove.extend(Path("ip") / f for f in IP_FILES)
    to_remove.extend(Path("ip") / "board" / f for f in BOARD_FILES)
    to_remove.extend(Path("ip") / "mem" / f for f in MEM_FILES)

    remove_list = [new_bsp_path / f for f in to_remove]
    for f in remove_list:
        if f.is_dir():
            shutil.rmtree(f)
        else:
            f.unlink()

    return 1


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("bsp", type=Path, help="Path to Terasic BSP")
    parser.add_argument("output", type=Path, help="Path to patched BSP")
    args = parser.parse_args()

    terasic_path: Path = args.bsp
    new_bsp_path: Path = args.output
    coredla_path: Path = Path(os.environ["COREDLA_ROOT"]).resolve()

    with TemporaryDirectory() as tmpdir_name:
        tmpdir = Path(tmpdir_name)
        print(f"Staging BSP in {tmpdir}")

        # Step 1: Copy the Terasic BSP over to the DLA root directory
        copy_terasic_bsp(terasic_path, coredla_path, tmpdir)

        # Step 2: Run the Patch command
        patch_terasic_bsp(tmpdir, coredla_path)

        # Step 3: Some cleanup
        cleanup(tmpdir)

        # Step 4: Copy the patched BSP into the desired location
        print(f"Copy {tmpdir} to {new_bsp_path.resolve()}")
        shutil.copytree(tmpdir, new_bsp_path, dirs_exist_ok=True)

    return 0


if __name__ == "__main__":
    main()

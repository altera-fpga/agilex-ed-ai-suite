"""YOLOv8 model converter."""

import argparse
import os
import subprocess
import sys
from pathlib import Path
from tempfile import TemporaryDirectory

import openvino as ov
from ultralytics import YOLO

DOWNLOAD_VERSION = "v8.2.0"
BASE_URL = "https://github.com/ultralytics/assets/releases/download"

YOLOV8_DOWNLOADS = {
    "yolov8n.pt": f"{BASE_URL}/{DOWNLOAD_VERSION}/yolov8n.pt",
    "yolov8s.pt": f"{BASE_URL}/{DOWNLOAD_VERSION}/yolov8s.pt",
    "yolov8m.pt": f"{BASE_URL}/{DOWNLOAD_VERSION}/yolov8m.pt",
    "yolov8l.pt": f"{BASE_URL}/{DOWNLOAD_VERSION}/yolov8l.pt",
    "yolov8x.pt": f"{BASE_URL}/{DOWNLOAD_VERSION}/yolov8x.pt",
}


class YOLOv8Converter:
    """Converter for YOLOv8 models."""

    def __init__(self):
        self.name = "yolov8"
        self.description = "Convert YOLOv8 models to OpenVINO IR format"

    def add_arguments(self, parser: argparse.ArgumentParser) -> None:
        """Add YOLOv8-specific arguments."""
        parser.add_argument(
            '--variant',
            type=str,
            default='yolov8n.pt',
            choices=list(YOLOV8_DOWNLOADS.keys()),
            help="YOLOv8 model variant to download and convert. Default is 'yolov8n.pt'."
        )
        parser.add_argument(
            '--output_dir',
            type=Path,
            default=None,
            help="Directory to save the OpenVINO IR files. Default is '$COREDLA_WORK/output'."
        )
        parser.add_argument(
            '--output_name',
            type=str,
            default='yolov8',
            help="Name of the output IR model file. Default is 'yolov8'."
        )

    @staticmethod
    def download_with_curl(url: str, dst: Path) -> None:
        """Download file using curl, respecting corporate proxies."""
        if dst.exists():
            return
        dst.parent.mkdir(parents=True, exist_ok=True)
        cmd = [
            "curl",
            "-L",             # follow redirects
            "--fail",         # fail on HTTP errors
            url,
            "-o", str(dst)
        ]
        print(f"Downloading {url} -> {dst}")
        subprocess.run(cmd, check=True)

    def convert(self, args: argparse.Namespace) -> Path:
        """Convert YOLOv8 model to OpenVINO IR format."""
        # Check environment
        coredla_work = os.environ.get("COREDLA_WORK")
        if coredla_work is None:
            print(
                "ERROR: COREDLA_WORK environment variable is not set. "
                "Please refer to documentation on how to create a working directory"
            )
            sys.exit(1)

        if args.output_dir is None:
            args.output_dir = Path(coredla_work) / "output"

        # Prepare output path
        output_ir_path = args.output_dir / f"{args.output_name}.xml"
        output_ir_path.parent.mkdir(parents=True, exist_ok=True)

        with TemporaryDirectory() as td:
            pt_model = Path(td) / args.variant

            # Download weights from ultralytics HuggingFace via curl
            url = YOLOV8_DOWNLOADS[args.variant]
            self.download_with_curl(url, pt_model)

            # Load YOLO model from local path
            model = YOLO(pt_model.as_posix())

            # Export to ONNX first
            exported_filename = model.export(format="onnx")

            # Convert to OpenVINO IR
            ov_model = ov.convert_model(input_model=exported_filename, input=[1, 3, 640, 640])
            ov.save_model(ov_model, output_ir_path, compress_to_fp16=False)

        return output_ir_path

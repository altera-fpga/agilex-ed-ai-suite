## Instructions for running resnet8_spatial.py

resnet8 is a small CIFAR-10 image classifier
([EclipseAidge/resnet8](https://huggingface.co/EclipseAidge/resnet8) on HuggingFace).

### Download and convert the model

From this directory, download `resnet8.onnx` with the Hugging Face CLI
(`pip install -U huggingface_hub` if `hf` is not on your PATH), then convert it
to OpenVINO IR:

```bash
hf download EclipseAidge/resnet8 resnet8.onnx --local-dir .
altera_model_converter resnet8.onnx onnx -o ./resnet8
```

This produces `resnet8/resnet8.xml` and `resnet8/resnet8.bin` next to
`resnet8_spatial.py` (the default `--ov-model` path is `./resnet8/resnet8.xml`).

### Run

```bash
python resnet8_spatial.py
```

This compiles the model with SPARK, emulates it, and compares the result against
OpenVINO CPU.

Arguments:

- `--ov-model <path>` OpenVINO XML model file (default: `./resnet8/resnet8.xml`)
- `--dump-path <path>` directory for SPARK compilation outputs (default: `./my_dumps`)
- `--file <path>` raw `.bin` file of 3*32*32=3072 uint8 CIFAR-style pixel values
  (CHW-planar) to classify. Default: a random input (sufficient for regression-testing
  the compile + emulation).
- `--sim` for VCS simulation and compare results against emulation (estimated runtime: a few minutes).
  Synopsys VCS must be installed and `vcs` must be on `PATH`.
- `--compile` for Quartus compile and see fmax and resource usage (estimated runtime: ~15 mins).

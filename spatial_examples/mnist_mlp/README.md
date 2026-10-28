## Instructions for running mnist_mlp.py

### Download the model

From this directory, download the checkpoint with the Hugging Face CLI
(`pip install -U huggingface_hub` if `hf` is not on your PATH):

```bash
hf download dacorvo/mnist-mlp --local-dir ./mnist_mlp
```

This creates `./mnist_mlp/pytorch_model.bin` beside this README.

### Dependencies

Use an environment with PyTorch and torchvision, or install them with
`pip install torch torchvision`.

### Run

```bash
python mnist_mlp.py
```

Arguments:

- `--sim`: VCS simulation and compare results against emulation (estimated runtime 40 mins)
- `--compile`: Quartus compile and see fmax and resource usage (estimated runtime 20 mins)

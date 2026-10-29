## Instructions for running lstm_addition.py

### Download the model

From this directory, download the SavedModel with the Hugging Face CLI
(`pip install -U huggingface_hub` if `hf` is not on your PATH):

```bash
hf download keras-io/addition-lstm --local-dir ./lstm-addition
```

This creates `./lstm-addition/` (with `saved_model.pb` and `variables/`) beside
this README.

### Dependencies

Use an environment with TensorFlow, or install it with `pip install tensorflow`.

### Run

```bash
python lstm_addition.py
```

Arguments:

- `--sim`: VCS simulation and compare results against emulation (estimated runtime 1 min)
- `--compile`: Quartus compile and see fmax and resource usage (estimated runtime 20 mins)

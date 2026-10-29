## Running `tiny_story.py`

This model is not available to run with the hardware runtimes due to the modified tokenizer. However, you may modify  the python LLM runtime to use the updated tokenizer and embeddings.

### Download a model

From this directory, download a TinyStories checkpoint with the Hugging Face CLI
(`pip install -U huggingface_hub` if `hf` is not on your PATH):

```bash
# Replace '1M' in the download path below with the model size to use.
# Non-DDR (tiny_story.py): '1M', '3M', or '8M'.
# DDR (tiny_story_ddr.py): '3M', '8M', '28M', or '33M'.
hf download roneneldan/TinyStories-1M  --local-dir ./TinyStories-1M
```

This creates the matching local directory beside this README (for example
`./TinyStories-1M` containing `config.json`, `vocab.json`, and
`pytorch_model.bin`).

| Model | Hugging Face repo | Local directory | Scripts |
|-------|-------------------|-----------------|---------|
| 1M | [roneneldan/TinyStories-1M](https://huggingface.co/roneneldan/TinyStories-1M) | `./TinyStories-1M` | `tiny_story.py` |
| 3M | [roneneldan/TinyStories-3M](https://huggingface.co/roneneldan/TinyStories-3M) | `./TinyStories-3M` | both |
| 8M | [roneneldan/TinyStories-8M](https://huggingface.co/roneneldan/TinyStories-8M) | `./TinyStories-8M` | both |
| 28M | [roneneldan/TinyStories-28M](https://huggingface.co/roneneldan/TinyStories-28M) | `./TinyStories-28M` | `tiny_story_ddr.py` |
| 33M | [roneneldan/TinyStories-33M](https://huggingface.co/roneneldan/TinyStories-33M) | `./TinyStories-33M` | `tiny_story_ddr.py` |

### Dependencies

Use an environment with PyTorch and Transformers installed, or install them
with `pip install torch transformers`.

### Run

Run `python tiny_story.py --model 1M` to emulate the model and dump files. Generated story will appear at the end of the dump.
Run `python tiny_story_ddr.py --model 3M` for the DDR-based example. DDR
requires a 3M or larger model.

Arguments:

- `--model`: required. `tiny_story.py`: `1M`, `3M`, or `8M`. `tiny_story_ddr.py`: `3M`, `8M`, `28M`, or `33M`.
- `--sim`: run VCS simulation and compare against emulation. Estimated
  runtimes for 1M, 3M, and 8M are 30 minutes, 1.25 hours, and 3.5 hours,
  respectively, with `tensor_len=64`. Using `tensor_len=32` is faster.
- `--compile`: run Quartus compilation to report fMAX and resource usage.
  Estimated runtimes for 1M, 3M, and 8M are 20 minutes, 30 minutes, and
  1 hour, respectively.

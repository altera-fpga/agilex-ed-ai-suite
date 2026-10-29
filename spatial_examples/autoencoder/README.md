## Running the autoencoder example

Run all commands from this directory.

Use the FPGA AI Suite model zoo to download and convert `ad01_fp32` to
OpenVINO IR:

```bash
altera_model_zoo convert ad01_fp32 --output-dir ./ad01_fp32
```

This generates `ad01_fp32.xml` and `ad01_fp32.bin`; keep both files together.

To see the `altera_model_zoo` API, run `altera_model_zoo --help`.

Now to run the autoencoder:

```bash
python autoencoder.py
```

Optional arguments:

- `--sim`: run VCS simulation and compare against emulation (about 1 minute).
  Synopsys VCS must be installed and `vcs` must be on `PATH`.
- `--compile`: run Quartus compilation to report fMAX and resource usage
  (about 15 minutes).

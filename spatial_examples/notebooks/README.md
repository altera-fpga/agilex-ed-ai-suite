# Spatial DAG teaching notebooks

Hand-build Spatial directed acyclic graphs with the Developer API
(`Directed_acyclic_graph`, `connect`, `run_flow`).

| Notebook | Topic |
|----------|--------|
| [`1_getting_started.ipynb`](1_getting_started.ipynb) | Instantiate a single layer, emulation, resource/latency estimates, `run_flow`, and global/local config |
| [`2_dags.ipynb`](2_dags.ipynb) | Build a DAG, emulation, `run_flow`, Platform Designer IP, saving and restoring models |
| [`3_roms.ipynb`](3_roms.ipynb) | Output-only nodes (`Rom` / `Constant`), `register_rom_dependency`, packet sources |
| [`4_weight_ports.ipynb`](4_weight_ports.ipynb) | On-chip MIF vs classic streaming vs DDR AXI weight ports |
| [`5_advanced_layers.ipynb`](5_advanced_layers.ipynb) | Using `Loop_controller`, `Rnn`, and `If_controller` |
| [`6_feed_forward_buffers.ipynb`](6_feed_forward_buffers.ipynb) | Reconverging feed-forward forks: insert `Buffer` on the fast path to avoid backpressure deadlock |

## Environment

These notebooks need the Spatial Python package (`fpga_ai_suite.spatial`), and optionally
QuestaSim, VCS, and Quartus for simulation and compilation cells.

Install the host-side packages from [`requirements.txt`](requirements.txt):

```bash
pip install -r requirements.txt
```

Then register a kernel (for example from `python/spark/.venv`) and open a notebook:

```bash
python -m ipykernel install --user --name spatial --display-name "Spatial"
jupyter notebook <notebook path>
```

### Simulation (VCS)

GCC <= 13.2.0 is required for running VCS simulation. If you have multiple GCC versions installed, you may specify the correct path using the gcc_path argument in run_flow.

```python
from pathlib import Path
GCC = Path("/p/psg/ctools/gcc/13.2.0/1/linux64/suse15/bin")
run_flow(model, sim=True, recompile=True, gcc_path=GCC)
```

### Runtime notes

- Keep working directories under this folder (`work_*/`). Simulation and Quartus
  cells can take tens of minutes even on tiny graphs.
- Generated trees (`sim_*`, `quartus_*`
  dumps) are local artifacts that may be deleted.

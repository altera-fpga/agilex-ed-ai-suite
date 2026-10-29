# Spatial JTAG Design Example

This directory contains the VDS system, RTL files, and ancillary build scripts for deploying the FPGA AI-Suite Spatial IP on the Agilex 5 E-Series Modular Development Kit. This example can be built by invoking the `dla_build_example_design.py` script.

## Introduction
The design relies on the JTAG-to-Avalon IP to allow a host running system console to communicate with DDR, mSGDMA and CSR registers. A batch of input features and their respective inference results are staged into external DDR. The ingress mSGDMA streams input tensors one at a time from DDR to the IP and the egress mSGDMA writes results back. Weights are held in on-chip MIF ROMs when they fit, and streamed from external DDR when they do not.

The two fabric DDR banks have fixed roles. Bank 0 (IO 2B) carries weights and the input and output tensors. Bank 1 (IO 3B) carries weights only.

## Clock Domains
There are three clock domains:
1. Spatial IP Clock - Spatial IP, Inference Timer
2. JTAG Clock (100MHz) - JTAG-to-Avalon, mSGDMA
3. EMIF Clock (200MHz) - EMIF AXI User Clock

The 100MHz system reference clock feeds into an IOPLL that generates the above three clock domains. The Spatial IP Clock is dynamically fitted using `dla_adjust_pll.tcl` which legalizes fmax to an achievable IOPLL frequency.

## Memory Map
- 0x00000000, 16 bytes, holds the inference timing results
- 0x00000020, 64 bytes, ingress mSGDMA CSR and descriptor (DDR to the Spatial IP)
- 0x00000060, 64 bytes, egress mSGDMA CSR and descriptor (Spatial IP to DDR)
- 0x00000100, 16 bytes, span extender control for DDR bank 0
- 0x00000110, 16 bytes, span extender control for DDR bank 1
- 0x40000000, 1GB window onto DDR bank 0
- 0x80000000, 1GB window onto DDR bank 1

The span extenders allow the 32-bit JTAG-to-Avalon master to reach the entire 8GB DDR space. A full breakdown can be found in the `setup_project.py` script.

## Input and output tensors
Tensors live in DDR bank 0: the input region starts at byte 6GB and the output region at byte 7GB, 1GB each. The host stages a whole batch through that bank's window, then the ingress mSGDMA streams it to the IP and egress writes the output region.

## DDR weights
A model whose weights do not fit in on-chip MIF ROMs can offload them to one or both fabric DDR banks. Bank 0 shares its 8GB with the feature regions, so weights there must stay below byte 6GB. Bank 1 is weights only and all 8GB of it is usable.


## Build
To generate a bitstream for the Design, please use the `dla_build_example_design.py` script. The script compiles a spatial model, generates RTL, and runs a Quartus compilation to generate the board level bitstream.

`dla_build_example_design.py build agx5e_modular_spatial_jtag $COREDLA_ROOT/platform/agx5e_modular_spatial_jtag/sample_spark_agx5.arch --model <OpenVINO XML or saved model>`

Similar to the `agx7_iseries_ofs_pcie_spatial` example design, this generates a `port_config.json` file describing key parameterizations of the hardware design. 

## Limitations

### Model / graph
- Exactly **one input port** and **one output port**. Multi-I/O models are rejected.
- One tensor, and a whole batch of them, is limited to the **1 GB** DDR region each direction gets. Larger tensor(s) are rejected at setup time and larger batches when the demo starts.
- A port subvector (`num_lanes x element data width`) must be no wider than the **256-bit** EMIF beat.

### DDR weights
- At most **two** DDR weight channels: bank 0 (IO **2B**) shared with the input and output tensors, and bank 1 (IO **3B**) weights only. Weights on bank 0 must stay below the 6GB feature-region floor.
- Weight ports must use **`ddr_channel_width=256`** and **`ddr_addr_width=33`** to match this EMIF.

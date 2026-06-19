# FPGA AI Suite Example Designs

This repo contains a set of configured example designs that demonstrate
different features of the [FPGA AI Suite](https://www.altera.com/products/development-tools/fpga-ai-suite).
The FPGA AI Suite is a collection of tools for efficiently running AI inference
on Altera FPGAs.  The examples in this repo cover the different development
boards, connectivity types, and FPGA families that the AI Suite supports.

Each example will walk you through a standard workflow to demonstrate how to
use to the AI Suite to:

* Compile the AI Suite IP into an FPGA bitstream.
* Program an FPGA with the AI Suite IP bitstream.
* Prepare an AI model graph for inference.
* Run inference on an FPGA using a benchmark dataset.

You may obtain a copy of the FPGA AI Suite from the
[official downloads page](https://www.altera.com/products/development-tools/fpga-ai-suite).

> [!IMPORTANT]
> All examples have a hard limit of 100'000 inference requests.  Please
> refer to the documentation on
> ["--licensed/--unlicensed" IP generation](https://docs.altera.com/r/docs/863373/2026.1.1/fpga-ai-suite-handbook/ip-generation-utility-command-line-options)
> for details about this limitation.

Full details on how to install the FPGA AI Suite, including all software and
hardware requirements, are available in
[Chapter 4](https://docs.altera.com/r/docs/863373/2026.1.1/installing-the-fpga-ai-suite-compiler-and-ip-generation-tools)
of the [FPGA AI Suite Handbook](https://docs.altera.com/r/docs/863373/2026.1.1/fpga-ai-suite-handbook/fpga-ai-suite-handbook)
The individual READMEs for each example also contain any additional requirements
and setup instructions that are particular to that example.

## Example Designs

### Hostless

Hostless example designs demonstrate how to directly control the FPGA AI Suite
IP over JTAG.

| Family | Development Board |
| ------ | ----------------- |
| Agilex 3 | [Agilex 3C Development Kit](agilex3/jtag/README.md) |
| Agilex 5 | [Agilex 5E Modular Development Kit](agilex5/modular_jtag/README.md) |

### PCIe-attach

PCIe-attach example designs demonstrate how a host computer can use the FPGA AI
Suite to offload AI workloads onto an FPGA via PCIe.

| Family | Development Board |
| ------ | ----------------- |
| Agilex 5 | [Agilex 5 FPGA E-Series 065B Modular Development Kit](agilex5/modular_ofs_pcie/README.md) |
| Agilex 7 | [Terasic DE10-Agilex Development Board](agilex7/de10_pcie/README.md) |
| Agilex 7 | [Agilex 7 FPGA I-Series Development Kit (2x R-Tile and 1x F-Tile)](agilex7/iseries_ofs_pcie/README.md) |
| Agilex 7 | [Intel FPGA SmartNIC N6001-PL Platform (without an Ethernet controller)](agilex7/n6001_ofs_pcie/README.md) |


## Documentation

* [Using the OpenVINO Open Model Zoo](docs/using-model-zoo.md)

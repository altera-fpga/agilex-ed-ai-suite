This directory contains an example system-console tcl script for the hostless
streaming example design on the Agilex 7 I-series Development Kit.

The system-console tcl script does the following:
  1. Initialize path to JTAG Avalon Master IP
  2. Initiates a reset via sources IP
  3. Writes to coreDLA's CSR registers to prime for inference
  4. Streams input data (img.bin) into on-chip memory via JTAG
  5. Writes a descriptor into egress DMA (coreDLA -> on-chip memory)
  6. Writes a descriptor into ingress DMA - (on-chip memory -> coreDLA)
  7. Streams output from onchip memory to output.bin via JTAG

For more information please consult Chapter 13 of the Design Examples User Guide.

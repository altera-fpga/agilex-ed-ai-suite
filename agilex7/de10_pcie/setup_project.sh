#!/bin/bash

# Copyright 2024-2025 Altera Corporation

# Setup the Quartus project used to compile the PCIe-attach example design for
# the Terasic DE10-Agilex Development Board.  This requires that the DE10 BSP
# already be installed and that the AOCL_BOARD_PACKAGE_ROOT environment variable
# contains to the BSP install path.

if [[ -z $"${AOCL_BOARD_PACKAGE_ROOT}" ]]; then
    echo "Error: Please ensure the AOCL_BOARD_PACKAGE_ROOT environment variable points to the BSP installation path."
    exit -1
fi

python3 ./patch_de10_bsp.py $AOCL_BOARD_PACKAGE_ROOT .

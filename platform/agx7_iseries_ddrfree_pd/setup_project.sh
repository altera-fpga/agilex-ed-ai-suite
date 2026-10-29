#!/bin/sh
# To be called by $COREDLA_ROOT/scripts/dla_build_example_design.py
# Purpose: set up the files necessary for Quartus project, without invoking any Quartus tools

# This script expects two arguments:
#   - The architecture IP name (e.g., A10_Performance_A10)
#   - The path to the directory containing the DLA IP RTL files

if [[ $# -ne 2 ]]; then
  echo "usage: $0 <arch_ip_name> <dla_ip_dir>"
  exit -1
fi

ARCH_IP_NAME=$1
DLA_IP_DIR=$2

# Open up the file `$COREDLA_IP_DIR/altera_ai_ip/verilog/$ARCH_IP_NAME/dla_dma_param.svh` and grab the value `AXI_ISTREAM_DATA_WIDTH`
# from the file.
if [ ! -f $DLA_IP_DIR/altera_ai_ip/verilog/$ARCH_IP_NAME/dla_dma_param.svh ]; then
  echo "ERROR: DLA IP parameter file not found: $DLA_IP_DIR/altera_ai_ip/verilog/$ARCH_IP_NAME/dla_dma_param.svh"
  exit -1
fi

AXI_ISTREAM_DATA_WIDTH=$(grep -oP 'localparam int AXI_ISTREAM_DATA_WIDTH = \K\d+' $DLA_IP_DIR/altera_ai_ip/verilog/$ARCH_IP_NAME/dla_dma_param.svh)

if [ -z "$AXI_ISTREAM_DATA_WIDTH" ]; then
  echo "ERROR: Unable to determine AXI_ISTREAM_DATA_WIDTH from $DLA_IP_DIR/altera_ai_ip/verilog/$ARCH_IP_NAME/dla_dma_param.svh"
  exit -1
fi
echo "INFO: AXI_ISTREAM_DATA_WIDTH = $AXI_ISTREAM_DATA_WIDTH"

# Now, we need to modify the `board.tcl` file to set the adapter's AXI width:
BOARD_TCL_FILE="$DLA_IP_DIR/../hw/board.tcl"

if [ ! -f $BOARD_TCL_FILE ]; then
  echo "ERROR: QSYS board tcl file not found: $BOARD_TCL_FILE"
  exit -1
fi

sed -i "/add_instantiation_interface_port out_0 out_0_data data INPUT_DATA_WIDTH STD_LOGIC_VECTOR Output/s/INPUT_DATA_WIDTH/${AXI_ISTREAM_DATA_WIDTH}/" $BOARD_TCL_FILE
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to update right value in $BOARD_TCL_FILE"
  exit -1
fi

sed -i "/set_component_parameter_value outDataWidth {INPUT_DATA_WIDTH}/s/INPUT_DATA_WIDTH/$AXI_ISTREAM_DATA_WIDTH/" "$BOARD_TCL_FILE"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to update right value in $BOARD_TCL_FILE"
  exit -1
fi

AXI_ISTREAM_DATA_WIDTH_IN_BYTES=$((AXI_ISTREAM_DATA_WIDTH / 8))
sed -i "/set_instantiation_interface_parameter_value out_0 symbolsPerBeat {INPUT_DATA_WIDTH_IN_BYTES}/s/INPUT_DATA_WIDTH_IN_BYTES/$AXI_ISTREAM_DATA_WIDTH_IN_BYTES/" "$BOARD_TCL_FILE"
if [ $? -ne 0 ]; then
  echo "ERROR: Failed to update right value in $BOARD_TCL_FILE"
  exit -1
fi

echo "INFO: Updated AXI width in board.tcl to $AXI_ISTREAM_DATA_WIDTH"

# System variables
alias cp="cp --verbose"


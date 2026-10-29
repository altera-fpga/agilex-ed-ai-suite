#!/bin/bash
set -e

# Build the bitstream for the memory-to-memory
# Agilex 5 SoC example design.  This script takes in no arguments and must run
# after calling 'setup_project.sh'.

# Generate Qsys system
pushd qsys
qsys-script --new-quartus-project=system --script=system.tcl

# Addresses a bug where the "altera:category" is incorrect
sed -i "s+categories>Systems+categories>System+g" *.qsys

popd
qsys-generate --quartus-project=top qsys/system.qsys --synthesis

# Compile the Quartus project
quartus_sh --flow compile top 2>&1 | tee quartus_sh.log

# Extract the QoR report
quartus_sh -t dla_parse_report.tcl \
    -project top \
    -ip-clock "system_inst|dla_pll|dla_pll_clk_dla" \
    -platform-clock "MAIN_CLOCK"

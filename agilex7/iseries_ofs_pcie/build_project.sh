#!/bin/bash

# Build the I-Series PCIe-attach example design bitstream.  This can only run
# after calling 'setup_project.sh'.

source ./ofs_build_env
init_ofs_build_env

set -eu

echo "-- Compile bitstream"
cd ofs
$OFS_BIN/run.sh

# remove copy of Quartus compile directory
# otherwise the QoR parser finds two copies of the report files
rm -rf ./build/quartus_proj_dir

echo "-- Extracting QoR metrics"
cd $QUARTUS_BUILD_DIR
quartus_sh -t $REL_ROOT_DIR/../dla_parse_report.tcl \
    -project $Q_PROJECT \
    -revision $Q_PR_REVISION \
    -ip-clock "afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|qph_user_clk_iopll|iopll_0_outclk0" \
    -platform-clock "afu_top|pg_afu.port_gasket|user_clock|qph_user_clk|qph_user_clk_iopll|iopll_0_outclk0" \
    -user-clock-file "./output_files/user_clock_freq.txt"

mv dla_compile_report.json $ED_BUILD_ROOT/.

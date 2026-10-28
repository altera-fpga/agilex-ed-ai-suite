#!/bin/bash

# Setup and initialize the example design Quartus project.  It takes in no
# arguments and must run before any bitstream compilation.

source ./ofs_build_env

check_opae_platform_root n6001
check_ofs_util afu_synth_setup
check_ofs_util ip-deploy

set -eu

afu_synth_setup -f -s filelist_agx7_n6001_ofs_pcie.txt ofs

# ip-deploy discovers components via <name>_hw.tcl; keep the platform-specific
# source and expose it under the required name for Platform Designer.
ln -sfn dla_afu_hw_agx7_n6001_ofs_pcie.tcl dla_afu_hw.tcl
ln -sfn ase_hw_agx7_n6001_ofs_pcie.tcl ase_hw.tcl

ip-deploy --component-name=dla_afu --output-directory=. --search-path=.,ip/afu_id_avmm_slave,ip/sw_reset,$

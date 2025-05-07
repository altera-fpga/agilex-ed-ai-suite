#!/bin/bash

# Setup and initialize the example design Quartus project.  It takes in no
# arguments and must run before any bitstream compilation.

source ./ofs_build_env

check_opae_platform_root iseries-dk
check_ofs_util afu_synth_setup
check_ofs_util ip-deploy

set -eu

afu_synth_setup -f -s filelist.txt ofs
ip-deploy --component-name=dla_afu --output-directory=. --search-path=.,ip/afu_id_avmm_slave,ip/sw_reset,$

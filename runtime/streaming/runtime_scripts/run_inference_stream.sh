#! /bin/sh
# This script should be run from the /home/root/app folder.

# Set the location of the shared libraries:
export LD_LIBRARY_PATH=.

# Immediately after startup, a Linux process rngd sometimes
# runs at 100% CPU for a few minutes. This can be stopped
# safely as there is no dependency on this
killall -9 rngd >& /dev/null

# Run the inference app, specifying the compiled model, the architecture file and the CoreDLA device name
# The model must be compiled with no folding. Use the option --ffolding-option=0 with the dlac compiler
./streaming_inference_app -model=/home/root/resnet-50-tf/RN50_Performance_no_folding.aot -arch=/home/root/resnet-50-tf/A10_Performance.arch -device=HETERO:FPGA,CPU

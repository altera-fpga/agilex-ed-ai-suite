# PCIe-attach Example Design on Agilex 7 Intel I-Series Development Kit (2x R-Tile and 1x F-Tile)

This example design demonstrates how to run the AI Suite on an Agilex 7 Intel
I-Series Development Kit (2x R-Tile and 1x F-Tile) connected to a host via PCIe.
The example design uses the `AGX7_Generic.arch` architecture.

## Requirements

> [!NOTE]
> All AI Suite example designs based on OFS use an [Out-of-Tree PR FIM](https://ofs.github.io/ofs-2024.2-1/hw/iseries_devkit/dev_guides/fim_dev/ug_ofs_iseries_dk_fim_dev/#223-out-of-tree-pr-fim).
> Please refer to the [AFU Developer Guide](https://ofs.github.io/ofs-2024.2-1/hw/common/user_guides/afu_dev/ug_dev_afu_ofs_agx7_pcie_attach/ug_dev_afu_ofs_agx7_pcie_attach/)
> on how to setup your development environment.  Please also refer to the
> [OFS FPGA Device Setup](../../docs/ofs-device-setup.md) for the one-time setup
> necessary to prepare the FPGA for inference.

* AI Suite
* Quartus Prime 24.1
    * Agilex 7 device support
    * Agilex common files
* OpenVINO 2023.3.0 Runtime
* [OFS 2024.2-1](https://github.com/OFS/ofs-agx7-pcie-attach/releases/tag/ofs-2024.2-1)
    * [OFS for Agilex 7 FPGA I-Series Development Kit (2xR-Tile, 1xF-Tile)](https://ofs.github.io/ofs-2024.2-1/hw/iseries_devkit/user_guides/ug_qs_ofs_iseries/ug_qs_ofs_iseries/)

## Compiling (Optional)

> [!TIP]
> You can skip compilation by downloading the pre-compiled .gbs file from the
> [latest release]https://github.com/altera-fpga/agilex-ed-ai-suite/releases).

Prepare the Quartus project with
(Assuming Quartus is installed $HOME/intelFPGA_pro/24.1)

```bash
# Install OPAE

# Install OFS etc.

# Enable Quartus environment
export QUARTUS_VERSION=24.1
export QUARTUS_INSTALL_DIR=$HOME/intelFPGA_pro/$QUARTUS_VERSION
export QUARTUS_ROOTDIR="$QUARTUS_INSTALL_DIR/quartus"
export QUARTUS_DIR="$QUARTUS_ROOTDIR"
export DSPBA_ROOTDIR="$QUARTUS_ROOTDIR/dspba"
export PATH="$DSPBA_ROOTDIR:$QUARTUS_ROOTDIR/bin:$QUARTUS_ROOTDIR/linux64:$QUARTUS_INSTALL_DIR/qsys/bin:$PATH"
export QUARTUS_64BIT=1
export LM_LICENSE_FILE="your_quartus_lic.dat"

# Install OpenVINO Runtime into the default location in /opt/intel
sudo mkdir /opt/intel
curl -L https://storage.openvinotoolkit.org/repositories/openvino/packages/2023.3/linux/l_openvino_toolkit_rhel8_2023.3.0.13775.ceeafaf64f3_x86_64.tgz --output openvino_2023.3.0.tgz
tar -xf openvino_2023.3.0.tgz
sudo mv l_openvino_toolkit_rhel8_2023.3.0.13775.ceeafaf64f3_x86_64 /opt/intel/openvino_2023.3.0

# Install required system dependencies on Linux
cd /opt/intel/openvino_2023.3.0
sudo -E ./install_dependencies/install_openvino_dependencies.sh

# Create a symbolic link
cd /opt/intel
sudo ln -s openvino_2023.3.0 openvino_2023

# Install the AI Suite into the default location in /opt/intel
sudo subscription-manager repos --enable codeready-builder-for-rhel-8-x86_64-rpms
wget https://downloads.intel.com/akdlm/software/fpga_ai_suite/2024.3/intel-fpga-ai-suite-2024.3-1.el8.x86_64.rpm
sudo dnf install intel-fpga-ai-suite-2024.3-1.el8.x86_64.rpm

# Enable the OpenVINO and the AI Suite environments
source /opt/intel/openvino_2023/setupvars.sh
source /opt/intel/fpga_ai_suite_2024.3/dla/setupvars.sh

# Clone this github repo
git clone https://github.com/altera-fpga/agilex-ed-ai-suite
cd ai-suit-ed/agilex7/iseries_pcie

# Prepare the OFS setup
export OPAE_PLATFORM_ROOT="??/ofs_fim/2024.2/iseries/pr_build_template"
./setup_project.sh
```

Compile the bitstream by running

```bash
./build_project.sh
```

The `dla_afu.gbs` bitstream file will be located in the `ofs/` directory.

## Running Inference

> [!NOTE]
> This is a condensed version of the [FPGA AI Suite Quick Start Tutorial](https://www.intel.com/content/www/us/en/docs/programmable/768970/2024-3/quick-start-tutorial.html).

Running inference requires that you first build the AI Suite runtime and program
the FPGA device.  This example will assume you are using `~/ai_suite_example` as
your working directory but you can use any path of your choice.

The first thing we will do is setup the working directory.  For convenience, the
steps to setup the Open Model Zoo are included below.  More details can be found
in [Using the OpenVINO Open Model Zoo](../../docs/using-model-zoo.md).  We will
then download the ResNet-50 TF model to use for inferencing.

```shell
# Initialize the working directory
mkdir ~/ai_suite_example
cd ~/ai_suite_example
source dla_init_local_directory.sh

# Clone the OMZ repo and checkout the version associated with the latest
# supported OpenVINO release.
cd demo
git clone https://github.com/openvinotoolkit/open_model_zoo.git

cd open_model_zoo
git switch --detach 2023.3.0

# Download and convert the ResNet-50 TF model into OpenVINO's internal format
python -m venv venv
source ./venv/bin/activate
pip install "openvino-dev[caffe, pytorch, tensorflow]==2023.3.0"
omz_downloader --name resnet-50-tf --output_dir ../models
omz_converter --name resnet-50-tf --download_dir ../models --output_dir ../models
```

> [!TIP]
> If `source dla_init_local_directory.sh` fails then you need to reinitialize
> your local environment again with:
>
> ```shell
> source /opt/intel/openvino_2023/setupvars.sh
> source /opt/intel/fpga_ai_suite_2024.3/dla/setupvars.sh
> ```

The model that we will run inference with is stored in
`~/ai_suite_example/demos/models/public/resnet-50-tf/FP32`.

You will now need to build the AI Suite runtime to program your FPGA device and
run inference with `dla_benchmark`.

```shell
cd ~/ai_suite_example/runtime

# If OPAE has been installed into the default location, use:
export OPAE_SDK_ROOT=/usr

# Build the runtime
./build_runtime.sh -target_agx7_i_dk

# Reprogram the FPGA
fpgaconf -V /path/to/dla_afu.gbs

# Run inference with the Just-in-Time (JIT) compile flow
./build_Release/dla_benchmark/dla_benchmark \
    -b=1 \
    -m ../demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    -d=HETERO:FPGA,CPU \
    -niter=8 \
    -plugins plugins.xml \
    -arch_file $COREDLA_ROOT/example_architectures/AGX7_Generic.arch \
    -api=async \
    -perf_est \
    -nireq=4 \
    -bgr \
    -i ../demo/sample_images \
    -groundtruth_loc ../demo/sample_images/TF_ground_truth.txt
```

### Ahead-of-Time Compile Flow

The Ahead-of-Time (AOT) compile flow is broadly similar to the JIT flow.
However, the main difference, beyond running `dla_compiler` to compile the
graph, is to ensure the runtime is build with `-disable_jit`.  This is so that
`dla_benchmark` does not require an architecture file to be provided along with
the compiled model.  The steps are summarized below.

```shell
cd ~/ai_suite_example/runtime
rm -rf build_Release

# Build the runtime
./build_runtime.sh -disable_jit -target_agx7_i_dk

# Compile the model with 'dla_compiler'
dla_compiler \
    --march $COREDLA_ROOT/example_architectures/AGX7_Generic.arch \
    --foutput-format open_vino_hetero \
    --network-file ../demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    --o ../demo/RN50_Generic_b1.bin \
    --batch-size=1 \
    --fanalyze-performance

# Reprogram the FPGA (optional if it was already programmed)
fpgaconf -V /path/to/dla_afu.gbs

# Run inference in AOT mode
./build_Release/dla_benchmark/dla_benchmark \
    -b=1 \
    -cm ../demo/RN50_Generic_b1.bin \
    -d=HETERO:FPGA,CPU \
    -niter=8 \
    -plugins plugins.xml \
    -api=async \
    -nireq=4 \
    -bgr \
    -i ../demo/sample_images \
    -groundtruth_loc ../demo/sample_images/TF_ground_truth.txt
```

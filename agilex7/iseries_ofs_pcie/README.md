# Agilex 7 PCIe-Attached Example Design with OFS

Demonstrates ML inference using the Agilex 7 FPGA I-Series Development Kit (2x R-Tile and 1x F-Tile)

## Description

This example design demonstrates how to run the AI Suite on an Agilex 7 Intel
I-Series Development Kit (2x R-Tile and 1x F-Tile) connected to a host via PCIe.
The example design uses the `AGX7_Generic.arch` architecture.


## Requirements

> [!NOTE]
> All OFS-based AI Suite example designs use an
> [Out-of-Tree PR FIM](https://ofs.github.io/ofs-2024.3-1/hw/iseries_devkit/dev_guides/fim_dev/ug_ofs_iseries_dk_fim_dev/#223-out-of-tree-pr-fim).
>
> Please refer to
> [[OFS-PCIE] Getting Started with Open FPGA Stack (OFS) for PCIe Attach Design Examples](https://www.intel.com/content/www/us/en/docs/programmable/848957/2025-1/getting-started-with-for-attach-design.html)
> in the [Design Examples User Guide](https://www.intel.com/content/www/us/en/docs/programmable/848957/2025-1/design-examples-user-guide.html)
> for more details.

* AI Suite 2025.1
* Quartus Prime 24.3
    * Agilex 7 device support
    * Agilex common files
* OpenVINO 2024.6.0 Runtime
* [OFS 2024.3-1 I-Series Development Kit Slim FIM](https://github.com/OFS/ofs-agx7-pcie-attach/releases/download/ofs-2024.3-1/iseries-dk-slimfim-images_ofs-2024-3-1.tar.gz)
* [OPAE 2.13.0-2 Driver](https://github.com/OFS/opae-sdk/releases/tag/2.13.0-2)

## Compiling (Optional)

> [!TIP]
> You can skip compilation by downloading the pre-compiled bitstream file from
> the [latest release](https://github.com/altera-fpga/agilex-ed-ai-suite/releases).

Compile the Quartus project with

```bash
# Enable the OpenVINO and the AI Suite environments
source /opt/intel/openvino_2024.6.0/setupvars.sh
source /opt/altera/fpga_ai_suite_2025.1/dla/setupvars.sh

# If OPAE has been installed into the default location, use:
export OPAE_SDK_ROOT=/usr

# Prepare the OFS setup
export OPAE_PLATFORM_ROOT="$HOME/OFS/iseries-dk-slimfim-images_ofs-2024-3-1/pr_build_template"

# Prepare and compile the Quartus project.
cd $EXAMPLES_PATH/agilex7/iseries_ofs_pcie
./setup_project.sh
./build_project.sh
```

`$EXAMPLES_PATH` is the location where this git repo was cloned to.

The `dla_afu.gbs` bitstream file will be located in the
`$EXAMPLES_PATH/agilex7/iseries_ofs_pcie/ofs/` directory.

## Running Inference

> [!NOTE]
> This is a condensed version of the
> [FPGA AI Suite Quick Start Tutorial](https://www.intel.com/content/www/us/en/docs/programmable/768970/2025-1/quick-start-tutorial.html).
> If you're using a pre-compiled bitstream then replace any paths to
> `dla_afu.gbs` with the location where you saved
> `agx7_iseries_ofs_pcie.gbs`.

Running inference requires that you first build the AI Suite runtime and program
the FPGA device.  This example will assume you are using `~/ai_suite_example` as
your working directory but you can use any path of your choice.

The first thing we will do is setup the working directory.  For convenience, the
steps to setup the Open Model Zoo are included below.  More details can be found
in [Using the OpenVINO Open Model Zoo](../../docs/using-model-zoo.md).  We will
then download the ResNet-50 TF model to use for inferencing.

```bash
# Initialize the working directory
mkdir ai_suite_example
cd ai_suite_example
source dla_init_local_directory.sh

# Clone the OMZ repo and checkout the version associated with the latest
# supported OpenVINO release.
cd demo
git clone https://github.com/openvinotoolkit/open_model_zoo.git

cd open_model_zoo
git switch --detach 2024.6.0

# Download and convert the ResNet-50 TF model into OpenVINO's internal format
python3 -m venv venv
source ./venv/bin/activate
pip install "openvino-dev[caffe, pytorch, tensorflow]==2024.6.0"
omz_downloader --name resnet-50-tf --output_dir ../models
omz_converter --name resnet-50-tf --download_dir ../models --output_dir ../models
```

> [!TIP]
> If `source dla_init_local_directory.sh` fails then you need to reinitialize
> your local environment again with:
>
> ```shell
> source /opt/intel/openvino_2024.6.0/setupvars.sh
> source /opt/altera/fpga_ai_suite_2025.1/dla/setupvars.sh
> ```

We will now run inference with this model.  It is located in
`$COREDLA_WORK/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml`.  The
`$COREDLA_WORK` environment variable is set by `dla_init_local_directory.sh` and
will point to `~/ai_suite_example`.

You will now need to build the AI Suite runtime to program your FPGA device and
run inference with `dla_benchmark`.

```bash
cd $COREDLA_WORK/runtime
# If OPAE has been installed into the default location, use:
export OPAE_SDK_ROOT=/usr

# Build the runtime
./build_runtime.sh -target_agx7_i_dk

# Reprogram the FPGA
fpgaconf -V $EXAMPLES_PATH/agilex7/iseries_ofs_pcie/ofs/dla_afu.gbs

# Run inference with the Just-in-Time (JIT) compile flow
./build_Release/dla_benchmark/dla_benchmark \
    -b=1 \
    -m $COREDLA_WORK/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    -d=HETERO:FPGA,CPU \
    -niter=8 \
    -plugins $COREDLA_WORK/runtime/build_Release/plugins.xml \
    -arch_file $COREDLA_ROOT/example_architectures/AGX7_Generic.arch \
    -api=async \
    -perf_est \
    -nireq=4 \
    -bgr \
    -i $COREDLA_WORK/demo/sample_images \
    -groundtruth_loc $COREDLA_WORK/demo/sample_images/TF_ground_truth.txt
```

### Ahead-of-Time Compile Flow

The Ahead-of-Time (AOT) compile flow is broadly similar to the JIT flow.
However, the main difference, beyond running `dla_compiler` to compile the
graph, is to ensure the runtime is build with `-disable_jit`.  This is so that
`dla_benchmark` does not require an architecture file to be provided along with
the compiled model.  The steps are summarized below.

```bash
# Note: You only need to do this if the 'build_Release' directory already
# exists.
cd $COREDLA_WORK/runtime
rm -rf build_Release
# If OPAE has been installed into the default location, use:
export OPAE_SDK_ROOT=/usr

# Build the runtime
./build_runtime.sh -disable_jit -target_agx7_i_dk

# Compile the model with 'dla_compiler'
dla_compiler \
    --march $COREDLA_ROOT/example_architectures/AGX7_Generic.arch \
    --foutput-format open_vino_hetero \
    --network-file $COREDLA_WORK/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    --o $COREDLA_WORK/demo/RN50_Generic_b1.bin \
    --batch-size=1 \
    --fanalyze-performance

# Reprogram the FPGA (optional if it was already programmed)
fpgaconf -V $EXAMPLES_PATH/agilex7/iseries_ofs_pcie/ofs/dla_afu.gbs

# Run inference in AOT mode
./build_Release/dla_benchmark/dla_benchmark \
    -b=1 \
    -cm $COREDLA_WORK/demo/RN50_Generic_b1.bin \
    -d=HETERO:FPGA,CPU \
    -niter=8 \
    -plugins $COREDLA_WORK/runtime/build_Release/plugins.xml \
    -api=async \
    -nireq=4 \
    -bgr \
    -i $COREDLA_WORK/demo/sample_images \
    -groundtruth_loc $COREDLA_WORK/demo/sample_images/TF_ground_truth.txt
```

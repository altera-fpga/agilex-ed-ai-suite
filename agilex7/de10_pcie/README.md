# Agilex 7 PCIe-Attached Example Design

Demonstrates ML inference using the Terasic DE10-Agilex Development Board

## Description

This example design demonstrates how to run the AI Suite on a Terasic
DE10-Agilex Development Board connected to a host via PCIe.  The example design
uses the `AGX7_Generic.arch` architecture.


## Requirements

> [!NOTE]
> Use of the Terasic DE10-Agilex Development board requires some
> AI Suite-specific setup.  You will encounter errors, such as the
> `AOCL_BOARD_PACKAGE_ROOT` environment variable not being set, if this setup is
> not done.
>
> Please refer to the
> [Installing the FPGA AI Suite PCIe-Based Design Example Prerequisites](https://www.intel.com/content/www/us/en/docs/programmable/768970/2025-1/installing-the-pcie-based-design-example.html)
> of the [Getting Started Guide](https://www.intel.com/content/www/us/en/docs/programmable/768970/2025-1/getting-started-guide.html)
> for the setup instructions.

* AI Suite 2025.1
* Quartus Prime 25.1
    * Agilex 7 device support
    * Agilex common files
* OpenVINO 2024.6.0 Runtime
* Terasic BSP

## Compiling (Optional)

> [!TIP]
> You can skip compilation by downloading the pre-compiled bitstream file from
> the [latest release](https://github.com/altera-fpga/agilex-ed-ai-suite/releases).

Compile the Quartus project with

```bash
# Enable the OpenVINO and the AI Suite environments
source /opt/intel/openvino_2024.6.0/setupvars.sh
source /opt/altera/fpga_ai_suite_2025.1/dla/setupvars.sh

# Prepare and compile the Quartus project.
cd $EXAMPLES_PATH/agilex7/de10_pcie
./setup_project.sh
quartus_sh -t generate_sof.tcl
```

`$EXAMPLES_PATH` is the location where this git repo was cloned to.

The `generate_sof.tcl` script can also be run through the Quartus GUI directly.
The bitstream file, `flat.sof`, will be located in
`$EXAMPLES_PATH/agilex7/de10_pcie/flat.sof`.

## Running Inference

> [!NOTE]
> This is a condensed version of the
> [FPGA AI Suite Quick Start Tutorial](https://www.intel.com/content/www/us/en/docs/programmable/768970/2025-1/quick-start-tutorial.html).
> If you're using a pre-compiled bitstream then replace any paths to
> `flat.sof` with the location where you saved
> `agx7_de10_pcie.sof`.

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

# Build the runtime
./build_runtime.sh -target_de10_agilex

# Reprogram the FPGA
./build_Release/fpga_jtag_reprogram/fpga_jtag_reprogram $EXAMPLES_PATH/agilex7/de10_pcie/flat.sof

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

# Build the runtime
./build_runtime.sh -disable_jit -target_de10_agilex

# Compile the model with 'dla_compiler'
dla_compiler \
    --march $COREDLA_ROOT/example_architectures/AGX7_Generic.arch \
    --foutput-format open_vino_hetero \
    --network-file $COREDLA_WORK/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    --o $COREDLA_WORK/demo/RN50_Generic_b1.bin \
    --batch-size=1 \
    --fanalyze-performance

# Reprogram the FPGA (optional if it was already programmed)
./build_Release/fpga_jtag_reprogram/fpga_jtag_reprogram $EXAMPLES_PATH/agilex7/de10_pcie/flat.sof

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

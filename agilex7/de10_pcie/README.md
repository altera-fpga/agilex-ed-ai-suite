# PCIe-attach Example Design on Terasic DE10-Agilex Development Board

This example design demonstrates how to run the AI Suite on a Terasic
DE10-Agilex Development Board connected to a host via PCIe.  The example design
uses the `AGX7_Generic.arch` architecture.

## Requirements

> [!NOTE]
> Use of the Terasic DE10-Agilex Development board requires some
> AI Suite-specific setup.  You will encounter errors, such as the
> `AOCL_BOARD_PACKAGE_ROOT` environment variable not being set, if this setup is
> not done. Please refer to the
> [Additional Software Prerequisites for the PCIe-based Design Example for Agilex™ 7 Devices](https://www.intel.com/content/www/us/en/docs/programmable/768970/2024-3/additional-software-prerequisites-for.html)
> of the Getting Started Guide for the setup instructions.

* AI Suite
* Quartus Prime 24.3
    * Agilex 7 device support
    * Agilex common files
* OpenVINO 2023.3.0 Runtime
* Terasic BSP

## Compiling (Optional)

> [!TIP]
> You can skip compilation by downloading the pre-compiled .sof file from the
> [latest release](https://github.com/altera-fpga/agilex-ed-ai-suite/releases).

Prepare the Quartus project with

```bash
# Enable the OpenVINO and the AI Suite environments
source /opt/intel/openvino_2023/setupvars.sh
source /opt/intel/fpga_ai_suite_2024.3/dla/setupvars.sh

# Clone this github repo
git clone https://github.com/altera-fpga/agilex-ed-ai-suite
cd ai-suite-ed/agilex7/de10_pcie

# Prepare the Quartus project
./setup_project.sh
```

Compile the bitstream by running the `generate_sof.tcl` script.  This can be
done either through the Quartus GUI or, for example, the command line:

```bash
quartus_sh -t generate_sof.tcl
```

The bitstream `flat.sof` file will be located in same folder as
`generate_sof.tcl`.

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
python3 -m venv venv
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

# Build the runtime
./build_runtime.sh -target_de10_agilex

# Reprogram the FPGA
./build_Release/fpga_jtag_reprogram/fpga_jtag_reprogram /path/to/flat.sof

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
./build_runtime.sh -disable_jit -target_de10_agilex

# Compile the model with 'dla_compiler'
dla_compiler \
    --march $COREDLA_ROOT/example_architectures/AGX7_Generic.arch \
    --foutput-format open_vino_hetero \
    --network-file ../demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    --o ../demo/RN50_Generic_b1.bin \
    --batch-size=1 \
    --fanalyze-performance

# Reprogram the FPGA (optional if it was already programmed)
./build_Release/fpga_jtag_reprogram/fpga_jtag_reprogram /path/to/flat.sof

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

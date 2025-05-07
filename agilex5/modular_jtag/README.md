# Agilex 5 Hostless JTAG Example Design

Demonstrate inference over JTAG and target FPGA AI Suite IP on the Agilex 5E Modular Development Kit

## Description

This example design demonstrates how to run the AI Suite on an Altera Agilex 5
E-Series 065B Modular Development Kit in a hostless configuration.  The example
design supports sending inference requests via JTAG in order to demonstrate how
commands can be sent to the AI Suite IP.

The example design uses the `AGX5_Generic.arch` architecture.


## Requirements

> [!NOTE]
> Please refer to the
> [[HL-JTAG] Prerequisites](https://www.intel.com/content/www/us/en/docs/programmable/848957/2025-1/prerequisites.html)
> section of the
> [Design Examples User Guide](https://www.intel.com/content/www/us/en/docs/programmable/848957/2025-1/design-examples-user-guide.html)
> for the setup instructions.

* AI Suite 2025.1
* Quartus Prime 25.1
    * Agilex 5 device support
    * Agilex common files
* OpenVINO 2024.6.0 Runtime

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
cd $EXAMPLES_PATH/agilex5/modular_jtag
quartus_sh -t generate_sof.tcl
```

`$EXAMPLES_PATH` is the location where this git repo was cloned to.

The `generate_sof.tcl` script can also be run through the Quartus GUI directly.
The bitstream file, `top.sof`, will be located in
`$EXAMPLES_PATH/agilex5/modular_jtag/output_files/top.sof`.

## Running Inference

> [!NOTE]
> The hostless example designs provide some extra options that affect
> inferencing beyond what is described in this section.  Please refer to
> [[HL-JTAG] Performing Inference on the Agilex 5 FPGA E-Series 065B Modular Development Kit](https://www.intel.com/content/www/us/en/docs/programmable/848957/2025-1/performing-inference-on-the.html)
> for details.

> [!NOTE]
> This is a condensed version of the
> [FPGA AI Suite Quick Start Tutorial](https://www.intel.com/content/www/us/en/docs/programmable/768970/2025-1/quick-start-tutorial.html).
> If you're using a pre-compiled bitstream then replace any paths to
> `top.sof` with the location where you saved
> `agx5e_modular_jtag.sof`.

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
./build_runtime.sh -target_system_console

# Reprogram the FPGA
quartus_pgm -c 1 -m jtag -o "p;$EXAMPLES_PATH/agilex5/modular_jtag/output_files/top.sof"

# Run inference with the Just-in-Time (JIT) compile flow
./build_Release/dla_benchmark/dla_benchmark \
    -b=1 \
    -m $COREDLA_WORK/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    -d=HETERO:FPGA,CPU \
    -niter=8 \
    -plugins $COREDLA_WORK/runtime/build_Release/plugins.xml \
    -arch_file $COREDLA_ROOT/example_architectures/AGX5_Generic.arch \
    -api=async \
    -perf_est \
    -nireq=1 \
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
./build_runtime.sh -disable_jit -target_system_console

# Compile the model with 'dla_compiler'
dla_compiler \
    --march $COREDLA_ROOT/example_architectures/AGX5_Generic.arch \
    --foutput-format open_vino_hetero \
    --network-file $COREDLA_WORK/demo/models/public/resnet-50-tf/FP32/resnet-50-tf.xml \
    --o $COREDLA_WORK/demo/RN50_Generic_b1.bin \
    --batch-size=1 \
    --fanalyze-performance

# Reprogram the FPGA (optional if it was already programmed)
quartus_pgm -c 1 -m jtag -o "p;$EXAMPLES_PATH/agilex5/modular_jtag/output_files/top.sof"

# Run inference in AOT mode
./build_Release/dla_benchmark/dla_benchmark \
    -b=1 \
    -cm $COREDLA_WORK/demo/RN50_Generic_b1.bin \
    -d=HETERO:FPGA,CPU \
    -niter=8 \
    -plugins $COREDLA_WORK/runtime/build_Release/plugins.xml \
    -api=async \
    -nireq=1 \
    -bgr \
    -i $COREDLA_WORK/demo/sample_images \
    -groundtruth_loc $COREDLA_WORK/demo/sample_images/TF_ground_truth.txt
```


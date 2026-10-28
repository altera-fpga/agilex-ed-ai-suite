# FPGA AI Suite: dla_benchmark C++ Tool

## Overview
The `dla_benchmark` tool is a C++ command-line utility for benchmarking deep learning inference performance using FPGA AI Suite and OpenVINO toolkit. \
It supports multiple execution flows and hardware platforms, including PCIe-attached FPGAs, SoC FPGAs, hostless (JTAG/DDR-free) and emulation.

This tool enables you to:
* Run AI models on supported FPGAs with OpenVINO integration
* Measure synchronous (latency-oriented) and asynchronous (throughput-oriented) inference
* Validate functional correctness and report accuracy metrics (Top-1/Top-5, mAP, COCO AP)
* Collect detailed system and IP performance statistics

> **NOTE:** This topic describes usage of C++ implementation of the Benchmark Tool. For the Python* implementation, refer to [Benchmark Python* Tool](../python_demos/OpenVINO_benchmark_app/README.md).

## New Features

Some of the changes made in the dla_benchmark C++ tool for the FPGA AI Suite are:
* Dumping output values into a text file named `result.txt`.
* In the `result.txt` file, in addition to output values, output tensor index is added to each value after the # sign to allow easier identification when the graph has multiple outputs.
* In addition to `result.txt`, the dla_benchmark will generate another text file named `result_tensor_boundaries.txt` that lists which lines of the result.txt file are for which output tensor as well as the layout and dimension of each output tensor.
* Top1/top5 accuracy check is added.
* Ability to specify the amount of available DDR bandwidth
* Performance estimation of the IP
* Mean Average Precision on supported YOLO graphs
* Logging of CSR accesses
* Report of LSU counters
* Different graph compile options
* A debug network for ease of debugging hardware issues
* Ability to dump a JSON with detailed performance profiling information


## Supported Flows

* **Ahead-of-Time (AOT) Flow:**
  * User manually compiles the IR model with DLA Compiler before running inference.
* **Just-In-Time (JIT) Flow:**
  * `dla_benchmark` automatically calls the DLA Compiler when provided with an IR model from OpenVINO (xml format) and the necessary architecture file.
* **Device & Platform Support:**
  * PCIe-attached FPGAs
  * SoC FPGAs
  * Hostless flows
  * Emulation mode

## Quick Start Examples
1. JIT Flow \
Provide an IR model (xml format) and architecture file; `dla_benchmark` handles compilation \
```sh
./dla_benchmark -m <model.xml> -arch_file <arch_file> -d HETERO:FPGA,CPU -i <images_dir> -niter 10 -api async -b 1 -groundtruth_loc <groundtruth.txt>
```

2. AOT Flow \
Compile the model first, then run `dla_benchmark`
```sh
dla_compiler --network-file <model.xml> --march <arch_file> --o <compiled_model.aot>
./dla_benchmark -cm <compiled_model.aot> -arch_file <arch_file> -d HETERO:FPGA,CPU -i <images_dir> -niter 10 -api async -b 1 -groundtruth_loc <groundtruth.txt>
```

3. Emulation Mode \
Use software-only emulation of the FPGA for functional and performance validation.
```sh
./dla_benchmark -m <model.xml> -arch_file <arch_file> -plugins emulation -i <images_dir> -niter 1
```

4. Object Detection with Accuracy Report
```sh
./dla_benchmark -m <yolo_model.xml> -arch_file <arch_file> -d HETERO:FPGA,CPU -i <val_images_dir> -niter 5000 -enable_object_detection_ap -yolo_version yolov8 -groundtruth_loc <gt_dir>
```

5. Include Performance Profiling
```sh
./dla_benchmark -cm <compiled_model.aot> -arch_file <arch_file> -d HETERO:FPGA,CPU -i <images_dir> -niter 10 -api async -b 1 -groundtruth_loc <groundtruth.txt> -enable_performance_profiler
```

## Spatial Examples
DLA_benchmark serves as a generic spatial runtime for image models. Assumes the board is programmed with a spatial bitstream.

Any `-spatial_input` image (bmp/png/jpg/...) is loaded as RGB, optionally resized with `-spatial_resize HxW`, and automatically laid out as a flat NCHW tensor (batch 1, 3 channels, pixel values 0..255) encoded to the port data type from `port_config.json`. You do not need to pre-convert the image to NCHW.

Build and install:

```sh
cd runtime

# Agilex 7 I-Series OFS PCIe spatial
./build_runtime.sh -target_spatial_ofs_pcie -install_dir=install_dir

# Agilex 5 E-Series Modular JTAG spatial
./build_runtime.sh -target_agx5_jtag_spatial -install_dir=install_dir
```

Run the following in install_dir

```sh
# Image classification (ResNet8 / CIFAR-10 style)
./bin/dla_benchmark \
  -spatial \
  -spatial_input cat.png \
  -spatial_config port_config.json \
  -spatial_resize 32x32

# Optional DDR weights (directory of weights_ddr_*.bin)
./bin/dla_benchmark \
  -spatial \
  -spatial_input cat.png \
  -spatial_config port_config.json \
  -spatial_resize 32x32 \
  -spatial_weights dump_files

# Optional ground-truth class index (one int) and output directory
./bin/dla_benchmark \
  -spatial \
  -spatial_input cat.png \
  -spatial_config port_config.json \
  -spatial_resize 32x32 \
  -spatial_golden groundtruth.txt \
  -output_dir results
```

Required flags: `-spatial`, `-spatial_input`, `-spatial_config`.
Optional: `-spatial_resize HxW`, `-spatial_weights DIR`, `-spatial_golden FILE`,
`-output_dir DIR`.

Example output:

```
[SPATIAL MODE] Image classification via MMD.
[SPATIAL MODE] Loaded image: cat.png (784 pixels NCHW uint64)
[SPATIAL MODE] No -spatial_weights; skipping weight load.
[SPATIAL MODE] Inference latency: 11.1 ms
[SPATIAL MODE] Throughput: 90.1 FPS
image 0 top 5:
3 : 0.671875
5 : 0.145508
2 : 0.0913086
6 : 0.0898438
0 : 4.67896e-06
[SPATIAL MODE] Wrote float scores to: results/result.txt (10 values)
3 : truth
top1 accuracy: 100 %
top5 accuracy: 100 %
[SPATIAL MODE] Wrote accuracy report to: results/accuracy_report.txt
[SPATIAL MODE] Inference complete.
```

## How It Works

Upon start-up, the application reads command-line parameters and loads a network and images/binary files to the Inference Engine plugin, which is chosen depending on a specified device. The number of infer requests and execution approach depend on the mode defined with the `-api` command-line parameter.

> **NOTE**: By default, Inference Engine samples, tools and demos expect input with BGR channels order. If you trained your model to work with RGB order, you need to manually rearrange the default channels order in the sample or demo application or reconvert your model using the Model Optimizer tool with `--reverse_input_channels` argument specified. For more information about the argument, refer to [Input Shape and Layout Considerations](https://docs.openvino.ai/2025/model-server/ovms_docs_binary_input_layout_and_shape.html) from OoenVINO.

* If you run the application in the synchronous mode, it creates one infer request and executes the `Infer` method.
* If you run the application in the asynchronous mode, it creates as many infer requests as specified in the `-nireq` command-line parameter and executes the `StartAsync` method for each of them. If `-nireq` is not set, the application will use the default value for specified device.s:
* Number of iterations is specified with the `-niter` command-line argument

During the execution, the application collects latency for each executed infer request.

Reported latency value is calculated as a median value of all collected latencies. Reported throughput value is reported
in frames per second (FPS) and calculated as a derivative from:
* Reported latency in the Sync mode
* The total execution time in the Async mode

Throughput value also depends on batch size.

The application can save a summary of the run, including the selected command line parameters and a copy of the high-level execution statistics (e.g. overall throughput, execution wall-clock time), by setting the `-save_run_summary` flag. This summary is saved in dla_benchmark_run_summary.csv.

## Command line options
Run the application with the `-h` option to get a list of all our command line options

Below are fragments of sample output for CPU and FPGA devices:

* For CPU:
   ```
   [Step 10/11] Measuring performance (Start inference asynchronously, 2 inference requests, limits: 60000 ms duration)
   [ INFO ] Benchmarking in inference only mode (inputs filling are not included in measurement loop).
   [ INFO ] First inference took 37.27 ms
   [Step 11/11] Dumping statistics report
   [ INFO ] Count:        5470 iterations
   [ INFO ] Duration:     60028.56 ms
   [ INFO ] Latency:
   [ INFO ]    Median:     21.79 ms
   [ INFO ]    Average:    21.92 ms
   [ INFO ]    Min:        20.60 ms
   [ INFO ]    Max:        37.19 ms
   [ INFO ] Throughput:   91.12 FPS
   ```

* For FPGA:
   ```
   [Step 10/12] Measuring performance (Start inference asyncronously, 2 inference requests using 3 streams for CPU, limits: 2 iterations with each graph, 1 graph(s))
    ----------------------------------------------------------------
    Resnet50_0 reported throughput: 3643.96 fps
    TOTAL DDR SPACE REQUIRED = 0.304443 MB
        DDR INPUT & OUTPUT BUFFER SIZE = 0.17334 MB
        DDR CONFIG BUFFER SIZE = 0.00292969 MB
        DDR FILTER BUFFER SIZE = 0.128174 MB
        DDR INTERMEDIATE BUFFER SIZE = 0 MB
    NOTE: THIS ESTIMATE ASSUMES 1x I/O BUFFER. THE COREDLA RUNTIME DEFAULTS TO 5
    TOTAL DDR TRANSFERS REQUIRED = 0.268097 MB
        DDR FILTER READS REQUIRED   = 0.128174 MB
        DDR FEATURE READS REQUIRED  = 0.0293274 MB
        DDR FEATURE WRITES REQUIRED = 0.107666 MB
    NUMBER OF DDR FEATURE READS = 1
    MINIMUM AVERAGE DDR BANDWIDTH REQUIRED = 976.934 MB/s
    ASSUMED DDR BANDWIDTH PER IP INSTANCE = 21328 MB/s
    ----------------------------------------------------------------
    Performance Estimator Throughput Breakdown
    Arch: kvec16xcvec16_i1x6_fp11_sb8192_xbark16_actk4_poolk4
    Number of DLA instances                          = 1
    Number of DDR Banks per DLA instance             = 1
    CoreDLA Target Fmax                              = 606 MHz
    PE Target Fmax                                   = 606 MHz
    Batch Size                                       = 1
    PE-only Conv Throughput No DDR                   = 3719 fps
    PE-only Conv Throughput                          = 3719 fps
    Overall Throughput Inf PE Buf Depth (zero MPBW)  = 3718 fps
    Overall Throughput Zero PE Buf Depth (zero MPBW) = 3715 fps
    Overall Throughput Inf PE Buf Depth              = 3709 fps
    Overall Throughput Zero PE Buf Depth             = 3706 fps
    ----------------------------------------------------------------
    FINAL THROUGHPUT = 3643.96 fps
    FINAL THROUGHPUT PER FMAX (CoreDLA) = 6.00978 fps/MHz
    FINAL THROUGHPUT PER FMAX (PE)      = 6.00978 fps/MHz

    [Step 11/12] Dumping statistics report
    count:             2 iterations
    system duration:   1.4309 ms
    IP duration:       0.2749 ms
    latency:           1.3289 ms
    system throughput: 1397.7041 FPS
    number of hardware instances: 4
    number of network instances: 1
    IP throughput per instance: 3638.2158 FPS
    IP throughput per fmax per instance: 6.0003 FPS/MHz
    IP clock frequency measurement: 606.3380 MHz
    estimated IP throughput per instance: 3643.9598 FPS (606 MHz assumed)
    estimated IP throughput per fmax per instance: 6.0098 FPS/MHz
    [Step 12/12] Dumping the output values
    [ INFO ] Dumping result of Resnet50 to dla_benchmark_output_dir/result.txt
    [ INFO ] Dumping per-batch result (raw output) of Resnet50 to dla_benchmark_output_dir/result_{batch}.bin
    [ INFO ] Dumping inference meta data of Resnet50 to dla_benchmark_output_dir/result_meta.json
    [ INFO ] Dumping Debug Network profiling counters
   ```

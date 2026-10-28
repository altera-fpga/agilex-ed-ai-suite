# CoreDLA Python API Usage

This README.md documents how to use OpenVINO's Python API with FPGA AI Suite.

## OpenVINO Benchmark Python Tool (Just In Time Flow)

A port of the OpenVINO Python benchmark_app is included in this directory. For more details on OpenVINO Python benchmark_app, see [README.md](./OpenVINO_benchmark_app/README.md). Note that this OpenVINO Python benchmark_app has slightly lower performance than the DLA C++ dla_benchmark in `runtime/dla_benchmark`.

To run this Python implementation of benchmark_app:

1. Follow instructions in the *FPGA AI Suite: Getting Started Guide* to program the bitstream onto the FPGA device.

2. `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COREDLA_ROOT/lib:$COREDLA_WORK/runtime/build_Release`
    - `$COREDLA_ROOT/lib` is needed to find `libcoreDLAHeteroPlugin.so`
    - `$COREDLA_WORK/runtime/build_Release` is needed to find `libcoreDLARuntimePlugin.so`

3. This step assumes that $curarch specifies the .arch file corresponding to the bitstream currently
programmed onto the FPGA board (as is done in the FPGA AI Suite Getting Started Guide).
```bash
imagedir=$COREDLA_WORK/demo/sample_images
xmldir=$COREDLA_WORK/demo/models/public/
DLA_PLUGINS=$COREDLA_WORK/runtime/build_Release/plugins.xml \
  DLA_ARCH_FILE=$curarch \
  python $COREDLA_WORK/runtime/python_demos/OpenVINO_benchmark_app/benchmark_app.py \
    -b=1 \
    -m $xmldir/resnet-50-tf/FP32/resnet-50-tf.xml \
   -d=HETERO:FPGA,CPU \
   -niter=8 \
   -api=async \
   -nireq=4 \
   -i $imagedir \
   -ip=f32 \
```

   which will estimate the latency and throughput for resnet-50.

Below is a fragment of sample output for HETERO:FPGA,CPU:

```text
[Step 10/11] Measuring performance (Start inference asynchronously, 4 inference requests using 4 streams for CPU, limits: 8 iterations)
[ INFO ] First inference took <number> ms
[Step 11/11] Dumping statistics report
Count:      8 iterations
Duration:   <Duration> ms
Latency:    <Latency> ms
Throughput: <Throughput> FPS
```
**Note**: When the target FPGA design uses JTAG to access the CSRs on the FPGA AI Suite IP (e.g. the Agilex 5E Premium Development Kit JTAG Design Example), the only supported value of *nireq* is 1.

## OpenVINO Benchmark Python Tool (Ahead Of Time Flow)

A port of the OpenVINO Python benchmark_app is included in this directory. For more details on OpenVINO Python benchmark_app, see [README.md](./OpenVINO_benchmark_app/README.md). Note that this OpenVINO Python benchmark_app has slightly lower performance than the DLA C++ dla_benchmark in `runtime/dla_benchmark`.

To run this Python implementation of benchmark_app:

1. Follow instructions in the *FPGA AI Suite: Getting Started Guide* to generate an AOT file. The architecture used should correspond to the same bitstream programmed in step 4.

2. Follow instructions in the *FPGA AI Suite: Getting Started Guide* to program the bitstream onto the FPGA device.

3. `export LD_LIBRARY_PATH=$LD_LIBRARY_PATH:$COREDLA_ROOT/lib:$COREDLA_WORK/runtime/build_Release`
    - `$COREDLA_ROOT/lib` is needed to find `libcoreDLAHeteroPlugin.so`
    - `$COREDLA_WORK/runtime/build_Release` is needed to find `libcoreDLARuntimePlugin.so`

4. This step assumes that:
    - `$curarch` specifies the .arch file corresponding to the bitstream currently programmed onto the FPGA board (as is done in the FPGA AI Suite Getting Started Guide).
    -  `graph.aot` is the compiled graph from step 1.
```bash
imagedir=$COREDLA_WORK/demo/sample_images
xmldir=$COREDLA_WORK/demo/models/public/
DLA_PLUGINS=$COREDLA_WORK/runtime/build_Release/plugins.xml \
  DLA_ARCH_FILE=$curarch \
  python $COREDLA_WORK/runtime/python_demos/OpenVINO_benchmark_app/benchmark_app.py \
    -b=1 \
    -m $COREDLA_WORK/graph.aot \
   -d=HETERO:FPGA,CPU \
   -niter=8 \
   -api=async \
   -nireq=4 \
   -i $imagedir \
   -ip=f32 \
```

   which will estimate the latency and throughput for resnet-50.

Below is a fragment of sample output for HETERO:FPGA,CPU:

```text
[Step 10/11] Measuring performance (Start inference asynchronously, 4 inference requests using 4 streams for CPU, limits: 8 iterations)
[ INFO ] First inference took <number> ms
[Step 11/11] Dumping statistics report
Count:      8 iterations
Duration:   <Duration> ms
Latency:    <Latency> ms
Throughput: <Throughput> FPS
```

## OpenVINO Benchmark Python Tool Precision (AOT and JIT)

The OpenVINO Python application supports various input tensor precisions. For compatibility with the FPGA AI Suite, which only supports f16 and f32 precisions in the input transformations module, please specify the desired precision using the `-ip` (or `--input_precision`) flag.

## OpenVINO Image Classification Async Python Sample

Another example is a port of OpenVINO Image Classification Async Python Sample. For more details, see it's [README.md](./OpenVINO_classification_sample_async/README.md).

To run this demo, follow step 1 and 2 above in the previous section and run

```bash
imagedir=$COREDLA_WORK/demo/sample_images
xmldir=$COREDLA_WORK/demo/models/public/
DLA_PLUGINS=$COREDLA_WORK/runtime/build_Release/plugins.xml \
  DLA_ARCH_FILE=$curarch \
  python $COREDLA_WORK/runtime/python_demos/OpenVINO_classification_sample_async/classification_sample_async.py \
    -m $xmldir/resnet-50-tf/FP32/resnet-50-tf.xml \
    -d=HETERO:FPGA,CPU \
    -i $imagedir/val_00000000.bmp $imagedir/val_00000001.bmp
```

Below is a fragment of the output:

```txt
[ INFO ] Starting inference in asynchronous mode
[ INFO ] Infer request 0 returned 0
[ INFO ] Image path: /absolute/path/of/demo/sample_images/val_00000000.bmp
[ INFO ] Top 10 results:
[ INFO ] classid probability
[ INFO ] -------------------
[ INFO ] 872     0.9995117
[ INFO ] 999     0.0000000
[ INFO ] 327     0.0000000
[ INFO ] 340     0.0000000
[ INFO ] 339     0.0000000
[ INFO ] 338     0.0000000
[ INFO ] 337     0.0000000
[ INFO ] 336     0.0000000
[ INFO ] 335     0.0000000
[ INFO ] 334     0.0000000
[ INFO ]
[ INFO ] Infer request 1 returned 0
[ INFO ] Image path: /absolute/path/of/demo/sample_images/val_00000001.bmp
[ INFO ] Top 10 results:
[ INFO ] classid probability
[ INFO ] -------------------
[ INFO ] 769     0.9672852
[ INFO ] 845     0.0292053
[ INFO ] 778     0.0005350
[ INFO ] 798     0.0005350
[ INFO ] 710     0.0003245
[ INFO ] 767     0.0002230
[ INFO ] 418     0.0001737
[ INFO ] 587     0.0001533
[ INFO ] 542     0.0000820
[ INFO ] 600     0.0000820
```

## Instructions on how to run the software emulator model

1. All steps are the same as above except `DLA_PLUGINS` should be set to $COERDLA_ROOT/lib/plugins_emulation.xml (`DLA_PLUGINS=$COREDLA_ROOT/lib/plugins_emulation.xml`)

**NOTE** The software emulator model is slower than a hardware run. Thus, it is highly recommended to run the commands above with the `DLA_PLUGINS` and `-niter=1` and `-nireq=1`

## Modifications Needed

OpenVINO's Python demos and benchmark_app requires slight modification to work with CoreDLA.

Please see the `.patch` file for the exact changes applied to port the OpenVINO Python benchmark_app to the FPGA AI Suite.

These patches are created using

- `cd $COREDLA_WORK/runtime/python_demos/OpenVINO_benchmark_app/`
- `diff -u $INTEL_OPENVINO_DIR/python/openvino/tools/benchmark/benchmark.py benchmark.py > benchmark.patch`
- `diff -u $INTEL_OPENVINO_DIR/python/openvino/tools/benchmark/main.py main.py > main.patch`
- `cd $COREDLA_WORK/runtime/python_demos/OpenVINO_classification_sample_async/`
- `diff -u $INTEL_OPENVINO_DIR/samples/python/classification_sample_async/classification_sample_async.py classification_sample_async.py > classification_sample_async.patch`

To run these demos and benchmark_app, pass the absolute path of the plugin file and arch file as environment variables as shown in the example above.

---

**IMPORTANT**: OpenVINO's sample applications, tools, and demos are designed to work with images in BGR channel order by default. If your model was trained using images in RGB channel order, you will need to take additional steps to ensure compatibility:

1. **Modify the Application**: Update the channel order within the sample or demo application code to match the RGB order expected by your model.

---

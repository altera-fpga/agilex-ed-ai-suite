# Intel AI Suite Core DLA 'AoT Splitter'

This tool is intended to split a compiled HETERO:FPGA OpenVINO model into Input memory, Config memory, and Filter memory data blobs that would normally exist in the DDR memory of a runtime CoreDLA IP. These blobs can be used to directly run an inference on the IP without using OpenVINO Runtime.

# How to Build the Splitter, Plugin, and Example

First, follow all instructions to install CoreDLA compiler development environment

Change directory to the dla runtime folder

```
sh build_runtime.sh -target_de10_agilex
```

# How to Run the Splitter Executable

The executable outputs the memory blobs to the current working directory. Change directory to the location where you want the outputs to be generated

```
cd directory_where_you_want_output

runtime/build_Release/dla_aot_splitter/dla_aot_splitter -cm compiled_hetero_fpga_model.aot -i path/to/image.bmp -bgr
```

Ensure that the libdla_aot_splitter.so, libcoreDLAHeteroPlugin.so and other shared libraries are available to the utility.

The tool outputs the following artifacts:
 - arch_build.mem / arch_build.bin
 - config.mem / config.bin
 - filter.mem /filter.bin
 - input.mem / input.bin
 - inter_size.mem
 - output_size.mem
 - input_size.mem

# Building the Example Inference Program

The example inference program with static input,config,filter data is compiled with the following environment variables
and option to build_runtime.sh

## DE10 Agilex
```
export AOT_SPLITTER_EXAMPLE_MODEL=<path/to/model.xml>
export AOT_SPLITTER_EXAMPLE_INPUT=<path/to/image.bmp>
sh build_runtime.sh -aot_splitter_example -target_de10_agilex
```

This program directly embeds the input, config and filter data into the resulting exectuable file for direct use.

## PCIE

The emulation inference program uses the PCIE MMD driver from the example design to connect to and provision the IP.
Your system may require a different driver to provision the IP

# Image Classification C++ Sample Async

### Running with CoreDLA
In addition to the options described below, include the arguments:
-  `-plugins=<path the plugins.xml>`, using the path to [plugins.xml](../plugins.xml)
- `-d HETERO:FPGA,CPU`
- `-arch_file <path to arch file>`, using the path to the architecture used when creating the FPGA bitstream

Use the -build_demo option to the runtime/build_runtime.sh script to build this demo.

See the documentation that is included with the example design.

For detailed information on the OpenVINO Classification Sample Async Demo, please see the [README](https://github.com/openvinotoolkit/openvino/tree/2025.4.0/samples/cpp/classification_sample_async) in the OpenVINO repository. Make sure to match the git tag with your installed version of OpenVINO for compatibility.

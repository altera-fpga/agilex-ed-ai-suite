# Image Segmentation C++ Demo

### Running with CoreDLA
In addition to the options described below, include the arguments:

-  `-plugins=<path the plugins.xml>`, using the path to [plugins.xml](../plugins.xml)
- `-d HETERO:FPGA,CPU`
- `-arch_file <path to arch file>`, using the path to the architecture used when creating the FPGA bitstream

Use the `-build_demo` option to the runtime/build_runtime.sh script to build the demos.

See the documentation that is included with the example design.

Use the `unet_camvid_onnx_0001` with the segmentation demo.  The `semantic-segmentation-adas-0001` graph is not supported in the current release of the FPGA AI Suite and will not work.

For detailed information on the OpenVINO C++ Segmentation Demo, please see the [README](https://github.com/openvinotoolkit/open_model_zoo/blob/2025.4.0/demos/segmentation_demo/cpp/README.md) in the OpenVINO repository. Make sure to match the git tag with your installed version of OpenVINO for compatibility.

# Using the OpenVINO Open Model Zoo

The example graphs used for testing inferencing with the AI Suite can be
obtained through the Open Model Zoo (OMZ).  This process is the same, regardless
of example design.

> [!TIP]
> You can find an up-to-date list of supported OMZ models in the
> [FPGA AI Suite: IP Reference Manual](https://www.intel.com/content/www/us/en/docs/programmable/768974/2025-1/supported-models.html)

## Model Zoo Setup

The first time setup requires cloning the [OMZ GitHub repo](https://github.com/openvinotoolkit/open_model_zoo.git)
and installing the required Python dependencies.

```shell
# Clone the OMZ repo and switch to the currently supported OpenVINO LTS release
git clone https://github.com/openvinotoolkit/open_model_zoo.git
cd open_model_zoo
git switch --detach 2024.6.0

# Install the necessary OpenVINO utilities
python3 -m venv .venv
source .venv/bin/activate
pip install "openvino-dev[caffe, pytorch, tensorflow]==2024.6.0"
```

## Downloading a Model

Downloading a model and converting it into OpenVINO intermediate representation
(IR) is done the with the following two commands:

```shell
# Download and convert ResNet-50 TensorFlow
#
# NOTE: Make sure that the virtualenv is activated!  If not, run
#   source .venv/bin/activate

omz_downloader --name resnet-50-tf --output_dir ./model_downloads
omz_converter --name resnet-50-tf --download_dir ./model_downloads --output_dir ./model_downloads
```

The models will be downloaded to `./model_downloads` and then converted into
OpenVINO IR.  In this case, the results will be in `./model_downloads/public/resnet-50-tf/FP32/`.

You can change the download location from `./model_downloads`, which will be in
your current working directory, to wherever is most convenient.

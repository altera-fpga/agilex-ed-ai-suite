#! /bin/sh
# This script should be run from the /home/root/app folder.

# Run the image streaming app, specifying the folder containing the source
# images, and an upload rate
./image_streaming_app -images_folder=/home/root/resnet-50-tf/sample_images -rate=50


// Copyright 2022-2023 Altera Corporation.
//
// This software and the related documents are Altera copyrighted materials,
// and your use of them is governed by the express license under which they
// were provided to you ("License"). Unless the License provides otherwise,
// you may not use, modify, copy, publish, distribute, disclose or transmit
// this software or the related documents without Altera's prior written
// permission.
//
// This software and the related documents are provided as is, with no express
// or implied warranties, other than those that are expressly stated in the
// License.

#pragma once

#include <gflags/gflags.h>
#include <iostream>
#include <string>
#include <vector>

/// @brief message for help argument
static const char help_message[] = "Print a usage message";

/// @brief message for images argument
static const char input_message[] =
    "Optional. Path to a folder with images and/or binaries or to specific image or binary file.";

/// @brief message for compiled model argument
static const char compiled_model_message[] = "Optional. Path to a .aot file with a trained compiled model";

// @brief message for the custom plugins.xml file option
static const char plugins_message[] = "Optional. Select a custom plugins to use.";

// @brief message folding_option flag
static const char folding_option_message[] = "Optional. Set the folding options for dla compiler: options 0-3.";

// @brief message fold_preprocessing flag
static const char fold_preprocessing_message[] = "Optional. Enable fold preprocessing option for dla compiler.";

// @brief message bgr flag
static const char bgr_message[] = "Optional. Indicate images are in bgr format.";

// @brief message binary flag
static const char bin_data_message[] =
    "Optional. Specify that the input should be read as binary data (otherwise, if input tensor has depth 1, or 3 it "
    "will default to U8 image processing).";

/// @brief message resize flag
static const char input_image_resize_message[] =
    "Optional. Input image resizing methods when the input image width and height do not match the desired "
    "input width and height of the model. resize: Resizing the input image to the model input size; "
    "pad_resize: Pad the input image with black pixels (i.e., 0) into a squared image and "
    "resize the padded image to model input size.";

/// @brief message enable early-access features flag
static const char enable_early_access_message[] =
    "Optional. Enables early access (EA) features of FPGA AI Suite. These are features that are actively being "
    "developed and have not yet met production quality standards. These features may have flaws. "
    "Consult the FPGA AI Suite documentation for details.";

/// @brief Define flag for showing help message <br>
DEFINE_bool(h, false, help_message);

/// @brief Declare flag for showing help message <br>
DECLARE_bool(help);

/// @brief Define parameter for set image file <br>
/// i or mif is a required parameter
DEFINE_string(i, "", input_message);

/// @brief Define parameter for compiled model file <br>
/// It is not a required parameter
DEFINE_string(cm, "", compiled_model_message);

/// @brief Path to a plugins_xml file
DEFINE_string(plugins, "", plugins_message);

/// @brief Define flag whether the image is in bgr format
DEFINE_bool(bgr, false, bgr_message);

/// Select folding options; 0,1,2,3
DEFINE_int32(folding_option, 1, folding_option_message);

/// @brief Define flag for enabling folding preprocessing
DEFINE_bool(fold_preprocessing, false, fold_preprocessing_message);

/// @brief Specify that the inputs should be read as binary.
DEFINE_bool(bin_data, false, bin_data_message);

/// @brief Define flag for using input image resize <br>
DEFINE_string(resize_type, "", input_image_resize_message);

/// @brief Enables early-access (EA) features of CoreDLA <br>
DEFINE_bool(enable_early_access, false, enable_early_access_message);

/**
 * @brief This function show a help message
 */
static void showUsage() {
  std::cout << std::endl;
  std::cout << "aot_splitter [OPTION]" << std::endl;
  std::cout << "Options:" << std::endl;
  std::cout << std::endl;
  std::cout << "    -h, --help                                  " << help_message << std::endl;
  std::cout << "    -i \"<path>\"                                 " << input_message << std::endl;
  std::cout << "    -cm \"<path>\"                                " << compiled_model_message << std::endl;
  std::cout << "    -plugins                           " << plugins_message << std::endl;
  std::cout << "    -bgr                                        " << bgr_message << std::endl;
  std::cout << "    -bin_data                                   " << bin_data_message << std::endl;
  std::cout << "    -resize_type \"resize/pad_resize\"            " << input_image_resize_message << std::endl;
  std::cout << "    -folding_option                             " << folding_option_message << std::endl;
  std::cout << "    -fold_preprocessing                         " << fold_preprocessing_message << std::endl;
  std::cout << "    -enable_early_access                        " << enable_early_access_message << std::endl;
}

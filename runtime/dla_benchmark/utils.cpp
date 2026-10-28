// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: Utility functions handling command line arguments and network input info for DLA's runtime.
//              Loosely based off OpenVino's benchmark_app/utils.cpp
//              [openvinotoolkit/openvino › samples/cpp/benchmark_app/utils.cpp]
//              Future OpenVino uplifts should refer to the file listed above.

#include <format_reader_ptr.h>
#include <gflags/gflags.h>
#include <sys/stat.h>

#include <algorithm>
#include <cstdint>
#include <filesystem>
#include <fstream>
#include <map>
#include <string>
#include <utility>
#include <vector>
#include <functional>
#include <samples/common.hpp>
#include <samples/slog.hpp>

#include "dla_stl_utils.h"
#include "utils.hpp"

/**
 * @brief Namespace dla_benchmark contains utility functions for working with network inputs.
 */
namespace dla_benchmark {

/**
 * @brief Checks if the input layout represents an image.
 *
 * This function determines whether the layout is compatible with image data based on the
 * layout string and the number of channels.
 *
 * @return True if the layout is for an image, False otherwise.
 */
bool InputInfo::IsImage() const {
  if ((layout != "NCHW" && layout != "NHWC")) return false;
  return (GetChannels() == 1 || GetChannels() == 3);
}

/**
 * @brief Checks if the input layout represents image information.
 *
 * This function checks if the layout corresponds to image information.
 *
 * @return True if the layout is for image information, False otherwise.
 */
bool InputInfo::IsImageInfo() const {
  if (layout != "NC") return false;
  return (GetChannels() >= 2);
}

/**
 * @brief Checks if the input layout represents video data.
 *
 * This function determines whether the layout is compatible with video data based on the
 * layout string and the number of channels.
 *
 * @return True if the layout is for video data, False otherwise.
 */
bool InputInfo::IsVideo() const {
  if (layout != "NCDHW" && layout != "NDHWC") return false;
  return (GetChannels() == 3);
}

/**
 * @brief Gets the width dimension of the data shape based on the layout.
 *
 * @return The width dimension of the data shape.
 */
size_t InputInfo::GetWidth() const { return data_shape.at(ov::layout::width_idx(layout)); }

/**
 * @brief Gets the height dimension of the data shape based on the layout.
 *
 * @return The height dimension of the data shape.
 */
size_t InputInfo::GetHeight() const { return data_shape.at(ov::layout::height_idx(layout)); }

/**
 * @brief Gets the number of channels based on the layout.
 *
 * @return The number of channels.
 */
size_t InputInfo::GetChannels() const { return data_shape.at(ov::layout::channels_idx(layout)); }

/**
 * @brief Gets the batch size based on the layout.
 *
 * @return The batch size.
 */
size_t InputInfo::GetBatch() const { return data_shape.at(ov::layout::batch_idx(layout)); }

/**
 * @brief Gets the depth dimension of the data shape based on the layout.
 *
 * @return The depth dimension of the data shape.
 */
size_t InputInfo::GetDepth() const { return data_shape.at(ov::layout::depth_idx(layout)); }

}  // namespace dla_benchmark

/** @brief Best effort cast an openvino tensor data to float type */
std::vector<float> cast_to_float(ov::Tensor& tensor) {
  std::vector<float> result;
  const size_t size = tensor.get_size();

  if (tensor.get_element_type() == ov::element::f32) {
    // Direct cast
    const float* data = tensor.data<float>();
    return std::vector<float>(data, data + size);
  } else if (tensor.get_element_type() == ov::element::i32) {
    const int32_t* data = tensor.data<int32_t>();
    result.reserve(size);
    for (size_t i = 0; i < size; ++i)
      result.push_back(static_cast<float>(data[i]));
  } else if (tensor.get_element_type() == ov::element::i64) {
    const int64_t* data = tensor.data<int64_t>();
    result.reserve(size);
    for (size_t i = 0; i < size; ++i)
      result.push_back(static_cast<float>(data[i]));
  } else if (tensor.get_element_type() == ov::element::f16) {
    const ov::float16* data = tensor.data<ov::float16>();
    result.reserve(size);
    for (size_t i = 0; i < size; ++i) {
      result.push_back(static_cast<float>(data[i]));
    }
  } else {
    throw std::runtime_error("Unsupported tensor element type for casting to float.");
  }

  return result;
}

/**
 * @brief Parses number of streams for each device from a string argument.
 *
 * @param devices vector of supported DLA devices, ie FPGA, CPU
 * @param values_string string arg of the format: <device1>:<value1>,<device2>:<value2>
 * @return A map of device : number of streams
 */
std::map<std::string, uint32_t> ParseNStreamsValuePerDevice(const std::vector<std::string>& devices,
                                                            const std::string& values_string) {
  auto values_string_upper = values_string;
  std::map<std::string, uint32_t> result;
  auto device_value_strings = split(values_string_upper, ',');
  for (auto& device_value_string : device_value_strings) {
    auto device_value_vec = split(device_value_string, ':');
    if (device_value_vec.size() == 2) {
      auto device_name = device_value_vec.at(0);
      auto nstreams = device_value_vec.at(1);
      auto it = std::find(devices.begin(), devices.end(), device_name);
      if (it != devices.end()) {
        result[device_name] = std::stoi(nstreams);
      } else {
        throw std::logic_error("Can't set nstreams value " + std::string(nstreams) + " for device '" + device_name +
                               "'! Incorrect device name!");
      }
    } else if (device_value_vec.size() == 1) {
      uint32_t value = std::stoi(device_value_vec.at(0));
      for (auto& device : devices) {
        result[device] = value;
      }
    } else if (device_value_vec.size() != 0) {
      throw std::runtime_error("Unknown string format: " + values_string);
    }
  }
  return result;
}

/**
 * @brief Parses CLI flag args -mean_values or -scale_values. Helper to GetInputsInfo()
 *
 * Parsing example: -mean_values data[255,255,255] is stored as data as the key, and a vector of 3 floats as the value
 *
 * @param arg raw string from CLI in the form of the example above
 * @param inputs_info struct used to check that the input name exists in the graph
 * @returns a map of input name and its respective mean/scale value vector
 */
std::map<std::string, std::vector<float>> ParseScaleOrMeanValues(const std::string& arg,
                                                                 const dla_benchmark::InputsInfo& inputs_info) {
  std::map<std::string, std::vector<float>> return_value;
  // Create a copy of the input string for processing
  std::string search_string = arg;
  // Find the first '[' character in the string
  auto start_pos = search_string.find_first_of('[');

  while (start_pos != std::string::npos) {
    // Find the matching ']' character
    auto end_pos = search_string.find_first_of(']');
    if (end_pos == std::string::npos) break;
    // Extract the input name and value string between '[' and ']'
    const std::string input_name = search_string.substr(0, start_pos);
    const std::string input_value_string = search_string.substr(start_pos + 1, end_pos - start_pos - 1);
    // Split the input value string into a vector of floats using a custom function SplitFloat
    std::vector<float> input_value = SplitFloat(input_value_string, ',');
    if (!input_name.empty()) {
      // If the input name is not empty and exists in the inputs_info map, store the value
      if (inputs_info.count(input_name)) {
        return_value[input_name] = input_value;
      } else {
        // Ignore wrong input names but gives a warning
        std::string network_input_names = "";
        for (auto it = inputs_info.begin(); it != inputs_info.end(); ++it) {
          network_input_names += it->first;
          if (std::next(it) != inputs_info.end()) {
              network_input_names += ", ";
          }
        }
        slog::warn << "Scale values or mean values are applied to '" << input_name << "' but '" << input_name
        << "' does not exist in network inputs. The available network inputs are: " << network_input_names
        << slog::endl;
      }
    } else {
      // If the input name is empty, apply the value to all image inputs in inputs_info
      for (auto& item : inputs_info) {
        if (item.second.IsImage()) return_value[item.first] = input_value;
      }
      // Clear the search string and exit the loop
      search_string.clear();
      break;
    }
    // Remove processed substring from the search string
    search_string = search_string.substr(end_pos + 1);
    // If the string is empty or doesn't start with a comma, exit the loop
    if (search_string.empty() || search_string.front() != ',') {
      break;
    }
    // Remove the leading comma and search for the next '[' character
    search_string = search_string.substr(1);
    start_pos = search_string.find_first_of('[');
  }
  // If there are remaining characters in the search string, it's an error
  if (!search_string.empty()) {
    throw std::logic_error("Can't parse input parameter string: " + arg);
  }

  return return_value;
}

/**
 * @brief Splits command-line input arguments containing multiple image file paths
 *        into separate vectors based on a specified separator.
 * Modified from parseInputFilesArguments() in [openvinotoolkit/openvino ›
 * inference-engine/samples/common/utils/src/args_helper.cpp]
 *
 * @param net_size The number of networks (multigraph functionality).
 * @return A vector of vectors, where each inner vector contains image file paths
 *         corresponding to a specific network graph.
 */
std::vector<std::vector<std::string>> SplitMultiInputFilesArguments(size_t net_size) {
  std::vector<std::vector<std::string>> paths;
  std::vector<std::string> args = gflags::GetArgvs();
  const auto is_image_arg = [](const std::string& s) { return s == "-i" || s == "--images" || s.substr(0, 3) == "-i=" || s.substr(0, 9) == "--images="; };
  const auto is_arg = [](const std::string& s) { return s.front() == '-'; };
  const auto img_start = std::find_if(begin(args), end(args), is_image_arg);  // looking for all `-i` or `--images` args
  if (img_start == end(args)) {
    // By default: if no -i argument is specified, then we should generate random
    // input image data.  The fillBlobs() function will do that later when it sees
    // an empty vector for its current network.
    paths.push_back(std::vector<std::string>());
    return paths;
  }
  std::vector<std::string>::iterator img_begin;
  if (img_start->substr(0, 3) == "-i=") {
    *img_start = img_start->substr(3);
    img_begin = img_start;
  } else if (img_start->substr(0, 9) == "--images=") {
    *img_start = img_start->substr(9);
    img_begin = img_start;
  } else {
    img_begin = std::next(img_start);
  }
  const auto img_end = std::find_if(img_begin, end(args), is_arg);
  for (auto img = img_begin; img != img_end; ++img) {
    auto multiFiles = split(*img, MULTIGRAPH_SEP);  // split this images arguments

    if (multiFiles.size() != 1 && multiFiles.size() != net_size) {
      slog::err << "Size of Input argument " << multiFiles.size() << " mismatch graph size " << net_size << " : "
                << *img << slog::endl;
      paths.clear();
      break;
    }
    for (size_t i = 0; i < multiFiles.size(); i++)
      slog::info << "Reading " << multiFiles[i] << " for graph index " << i << slog::endl;
    while (paths.size() < multiFiles.size()) paths.push_back(std::vector<std::string>());

    for (size_t i = 0; i < multiFiles.size(); i++) {
      paths[i].push_back(multiFiles[i]);
    }
  }
  return paths;
}

/**
 * @brief Returns the stem of a file path.
 *
 * The stem is the base name of the file without its extension. This function
 * takes a file path as input and extracts the stem, which is the part of the
 * file name before the last period ('.') character.
 *
 * @param path The input file path.
 * @return The stem of the file, excluding the extension.
 */
std::string GetStem(std::string path) {
  auto last_index = path.rfind('/');

  if (std::string::npos != last_index) {
    path.erase(0, last_index + 1);
  }

  last_index = path.rfind('.');
  if (std::string::npos != last_index) {
    path.erase(last_index);
  }

  return path;
}

/**
 * @brief Splits a string into substrings using a specified delimiter.
 *
 * @param s The input string to be split.
 * @param delim The delimiter character used to separate the substrings.
 * @return A vector of strings containing the substrings from the input string.
 */
std::vector<std::string> split(const std::string& s, char delim) {
  std::vector<std::string> result;
  std::stringstream ss(s);
  std::string item;

  while (getline(ss, item, delim)) {
    result.push_back(item);
  }
  return result;
}

/**
 * @brief Splits a string of floats into floats using a specified delimiter.
 *
 * @param s The input string to be split.
 * @param delim The delimiter character used to separate the floats.
 * @return A vector of floats containing the floats from the input string.
 */
std::vector<float> SplitFloat(const std::string& s, char delim) {
  std::vector<float> result;
  std::stringstream ss(s);
  std::string item;

  while (getline(ss, item, delim)) {
    result.push_back(std::stof(item));
  }
  return result;
}

/**
 * @brief Parses a list of devices from a string
 *
 * @param device_string The input string to be split. The delimiter is ':'
 * @return A vector of strings containing the devices
 */
std::vector<std::string> ParseDevices(const std::string& device_string) {
  std::string comma_separated_devices = device_string;
  if (comma_separated_devices.find(":") != std::string::npos) {
    comma_separated_devices = comma_separated_devices.substr(comma_separated_devices.find(":") + 1);
  }
  auto devices = split(comma_separated_devices, ',');
  for (auto& device : devices) device = device.substr(0, device.find_first_of(".("));
  return devices;
}

/**
 * @brief Gets information about a network's inputs.
 *
 * Reads all input nodes from a network, determines tensor layout, shapes, precision, etc.
 * Saves into dla::benchmark::InputsInfo which maps each input info struct to an input name.
 *
 * @param batch_size Network batch size from the user via the batch size flag
 * @param input_info Vector of input nodes. Obtained from ov::Model.inputs() or ov::CompiledModel.inputs()
 * @param reshape_required boolean flag indicating that the model needs to be reshaped according to the batch size flag
 * @param is_binary_data User flag indicating that the data is binary data and not image data
 * @param mean_string CLI arg specifying image mean value. Example: input[255,255,255]. (Optional)
 * @param scale_string CLI arg specifying image scale value. Example: input[255,255,255]. (Optional)
 * @return dla::benchmark::InputsInfo which is a map of input names and its respective input information
 */
dla_benchmark::InputsInfo GetInputsInfo(const size_t batch_size,
                                        const std::vector<ov::Output<const ov::Node>>& input_info,
                                        bool& reshape_required,
                                        const bool is_binary_data,
                                        const std::string& mean_string = "",
                                        const std::string& scale_string = "") {
  reshape_required = false;
  dla_benchmark::InputsInfo info_map;

  bool is_there_at_least_one_batch_dim = false;
  for (auto& item : input_info) {
    dla_benchmark::InputInfo info;
    const std::string& name = item.get_any_name();

    // Layout
    info.layout = dynamic_cast<const ov::op::v0::Parameter&>(*item.get_node()).get_layout();

    // Calculating default layout values if needed
    std::string newLayout = "";
    if (info.layout.empty()) {
      const size_t rank = item.get_partial_shape().size();
      const std::string newLayout = dla::util::getTensorLayout(rank);
      if (newLayout != "") {
        info.layout = ov::Layout(newLayout);
        slog::warn << name << ": layout is not set explicitly through model optimizer"
                   << (newLayout != "" ? std::string(", so it is defaulted to ") + newLayout : "")
                   << ". It is recommended to explicity set layout via model optmizer." << slog::endl;
      }
    }

    // Partial Shape
    info.partial_shape = item.get_partial_shape();
    info.data_shape = info.partial_shape.get_shape();

    // DLA only supports static shapes
    if (info.partial_shape.is_dynamic()) {
      throw std::runtime_error(
          "DLA only supports static shapes. Check your model and make sure all shapes are defined (No dims of -1).");
    }

    // Precision
    // Edwinzha: setting input data to u8 for image data instead of the defined precision in .xml
    // leads to accuracy loss that didn't exist prior to API 2.0. Should investigate or remove this condition.
    // info.IsImage() && !is_binary_data ? ov::element::u8 : item.get_element_type();
    info.type = item.get_element_type();

    // Update shape with batch if needed (only in static shape case)
    // Update blob shape only not affecting network shape to trigger dynamic batch size case
    if (batch_size != 0) {
      if (ov::layout::has_batch(info.layout)) {
        is_there_at_least_one_batch_dim = true;
        std::size_t batch_index = ov::layout::batch_idx(info.layout);
        if (info.data_shape.at(batch_index) != batch_size) {
          info.partial_shape[batch_index] = batch_size;
          info.data_shape[batch_index] = batch_size;
          reshape_required = true;
        }
      } else {
        slog::warn << "Input '" << name
                   << "' doesn't have batch dimension in layout. -b option will be ignored for this input."
                   << slog::endl;
      }
    }
    info_map[name] = info;
  }

  if (batch_size > 1 && !is_there_at_least_one_batch_dim) {
    throw std::runtime_error(
        "-b option is provided in command line, but there's no inputs with batch(B) "
        "dimension in input layout, so batch cannot be set. "
        "You may specify layout explicitly using -layout option.");
  }

  // Update scale and mean
  std::map<std::string, std::vector<float>> scale_map = ParseScaleOrMeanValues(scale_string, info_map);
  std::map<std::string, std::vector<float>> mean_map = ParseScaleOrMeanValues(mean_string, info_map);

  for (auto& item : info_map) {
    dla_benchmark::InputInfo& info = item.second;
    if (info.IsImage()) {
      if (info.GetChannels() == 3) {  // Image is RGB or BGR
        info.scale_values.assign({1, 1, 1});
        info.mean_values.assign({0, 0, 0});
      } else if (info.GetChannels() == 1) {  // Image is greyscale
        info.scale_values.assign({1});
        info.mean_values.assign({0});
      } else {
        std::string err =
            "Input is image but is not of 3 channels (RGB, BGR) or 1 channel (Greyscale). Cannot assign mean and/or "
            "scale values";
        throw std::logic_error(err);
      }
      if (scale_map.count(item.first)) {
        info.scale_values = scale_map.at(item.first);
      }
      if (mean_map.count(item.first)) {
        info.mean_values = mean_map.at(item.first);
      }
    }
  }
  return info_map;
}

/**
 * @brief Gets information about a network's inputs.
 *
 * Reads all input nodes from a network, determines tensor layout, shapes, precision, etc.
 * Saves into dla::benchmark::InputsInfo which maps each input info struct to an input name.
 * Used in AOT flow where reshaping is not required (Handled by compiler)
 *
 * @param batch_size Network batch size from the user via the batch size flag
 * @param input_info Vector of input nodes. Obtained from ov::Model.inputs() or ov::CompiledModel.inputs()
 * @param is_binary_data User flag indicating that the data is binary data and not image data
 * @return dla::benchmark::InputsInfo which is a map of input names and its respective input information
 */
dla_benchmark::InputsInfo GetInputsInfo(const size_t batch_size,
                                        const std::vector<ov::Output<const ov::Node>>& input_info,
                                        const bool is_binary_data) {
  bool reshape_required = false;
  return GetInputsInfo(batch_size, input_info, reshape_required, is_binary_data);
}

/**
 * @brief Extracts the file extension from a given file name.
 *
 * @param name The file name from which to extract the extension.
 * @return The file extension as a string, or an empty string if no extension is found.
 */
std::string GetExtension(const std::string& name) {
  auto extension_position = name.rfind('.', name.size());
  return extension_position == std::string::npos ? "" : name.substr(extension_position + 1, name.size() - 1);
}

/**
 * @brief Filters a list of file paths by specified file extensions (case insensitive).
 *
 * @param file_paths A vector of file paths to be filtered.
 * @param extensions A vector of file extensions to filter by.
 * @return A vector of filtered file paths that match the specified extensions.
 */
std::vector<std::string> FilterFilesByExtensions(const std::vector<std::string>& file_paths,
                                                 const std::vector<std::string>& extensions) {
  std::vector<std::string> filtered;
  for (auto& file_path : file_paths) {
    auto extension = GetExtension(file_path);
    std::transform(extension.begin(), extension.end(), extension.begin(), ::tolower);
    if (std::find(extensions.begin(), extensions.end(), extension) != extensions.end()) {
      filtered.push_back(file_path);
    }
  }
  return filtered;
}

/**
 * @brief Dumps output tensor into result.txt. Mainly used for regtesting, only runs with -dump_output flag
 *
 * @param output_tensor Output tensor to dump
 * @param output_node Output node corresponding to the output tensor to dump
 * @param output_size Size of the output tensor
 * @param result_file ofstream object corresponding to result.txt
 */
void DumpResultTxtFile(ov::Tensor& output_tensor,
                       const ov::Output<const ov::Node>& output_node,
                       const unsigned int output_size,
                       std::ofstream& result_file) {
  size_t C = 1;
  size_t H = 1;
  size_t W = 1;
  size_t D = 1;

  // allow dumping the data as txt for all layouts, but not dumping layout if it's unknown
  bool unknown_layout = false;

  const ov::Layout& layout = ov::layout::get_layout(output_node);
  const ov::Shape& shape = output_tensor.get_shape();
  const std::string& name = output_node.get_any_name();
  const size_t num_dims = shape.size();
  const size_t tensor_size = std::accumulate(shape.begin(), shape.end(), 1, std::multiplies<size_t>());
  if (num_dims == 2) {
    C = shape[1];
  } else if (num_dims == 4) {
    C = shape[1];
    H = shape[2];
    W = shape[3];
  } else if (num_dims == 5) {
    C = shape[1];
    D = shape[2];
    H = shape[3];
    W = shape[4];
  } else {
    unknown_layout = true;
  }

  const std::vector<float> data_vector = cast_to_float(output_tensor);
  const float* data = data_vector.data();

  if (data == nullptr) {
    throw std::runtime_error("Unable to dump result tensors because tensor data is NULL");
  }
  if (!result_file.is_open()) {
    // Fix coverity, this should always be open from dla_benchmark/main.cpp
    throw std::runtime_error("Unable to dump result tensors due to result ofstream not being open!");
  }
  // Save the original formatting flags for coverity
  std::ios_base::fmtflags original_flags = result_file.flags();

  for (size_t idx = 0; idx < tensor_size; ++idx) {
    // Explicity set precision for coverity
    result_file << std::fixed << std::setprecision(6) << data[idx] << std::defaultfloat;
    if (!unknown_layout) {
      size_t n = idx / (C * D * H * W);
      size_t c = (idx / (D * H * W)) % C;
      size_t d = (idx / (H * W)) % D;
      size_t h = (idx / W) % H;
      size_t w = idx % W;
      result_file <<" # Layout: " << layout.to_string() << "; ";
      result_file << "Index: " << n << " " << c;
      if (num_dims == 4) {
        result_file << " " << h << " " << w;
      }
      if (num_dims == 5) {
        result_file << " " << d << " " << h << " " << w;
      }
    } else {
      result_file << " # Index: " << idx;
    }

    if (idx == 0) {
      result_file << " start of " << name;
    } else if (idx == output_size - 1) {
      result_file << " end of " << name << ", see result_tensor_boundaries.txt for details";
    }
    result_file << std::endl;
  }
  // restore orginal formatting flags
  result_file.flags(original_flags);
}

/**
 * @brief Dumps output tensor as binaries into result.bin.
 * Can be useful in postprocessing of the result tensor using Python numpy,
 * or when the tensor layout is not supported by DLA.
 *
 * @param output_tensor Output tensor to dump
 * @param result_file ofstream object corresponding to result.bin
 */
void DumpResultBinFile(ov::Tensor& output_tensor,
                       std::ofstream& result_file) {
  const ov::Shape& shape = output_tensor.get_shape();
  size_t total_size = std::accumulate(shape.begin(), shape.end(), 1, std::multiplies<size_t>());
  const std::vector<float> data_vector = cast_to_float(output_tensor);
  const float* data = data_vector.data();
  if (data == nullptr) {
    throw std::runtime_error("Unable to dump result tensors because tensor data is NULL");
  }
  for (size_t idx = 0; idx < total_size; ++idx) {
    result_file.write(reinterpret_cast<const char*>(&data[idx]), sizeof(float));
  }
}

/**
 * @brief Dumps inference metadata as a JSON file into result_meta.json
 * Useful for postprocessing and reviewing inference arguments
 *
 * @param metadata Meta data to dump
 * @param result_file ofstream object corresponding to result_meta.json
 */
void DumpResultMetaJSONFile(const dla_benchmark::InferenceMetaData& metadata,
                            std::ofstream& result_file) {
  result_file << "{\n";
  // batch size
  result_file << "\t\"batch_size\": " << metadata.batch_size << ",\n";

  // niter
  result_file << "\t\"niter\": " << metadata.niter << ",\n";

  // nireq
  result_file << "\t\"nireq\": " << metadata.nireq << ",\n";

  // groundtruth loc
  result_file << "\t\"groundtruth_loc\": \"" << metadata.groundtruth_loc << "\",\n";

  // input info: model_input_info
  result_file << "\t\"input_info\": [\n";
  long unsigned int idx = 0;
  for (const auto &name_input_pair : metadata.model_input_info) {
    // to collect scale_values and mean_values
    std::ostringstream oss_scale_vals, oss_mean_vals;
    unsigned int scale_values_size = name_input_pair.second.scale_values.size();
    if (scale_values_size != name_input_pair.second.mean_values.size()) {
      throw std::logic_error("scale_values and mean_values should always have the same size");
    }
    oss_scale_vals << "[";
    oss_mean_vals << "[";
    for (long unsigned int i = 0; i < scale_values_size; i++) {
      oss_scale_vals << name_input_pair.second.scale_values[i];
      oss_mean_vals << name_input_pair.second.mean_values[i];
      if (i < scale_values_size - 1) {
        oss_scale_vals << ",";
        oss_mean_vals << ",";
      }
    }
    oss_scale_vals << "]";
    oss_mean_vals << "]";
    result_file <<  "\t\t{\"name\": \"" << name_input_pair.first << "\", \"shape\": \""
                << name_input_pair.second.data_shape.to_string() << "\", \"scale_values\": \""
                << oss_scale_vals.str() << "\", \"mean_values\": \""
                << oss_mean_vals.str() << "\", \"layout\": \""
                << name_input_pair.second.layout.to_string() << "\"}";
    if (idx == metadata.model_input_info.size() - 1) {
      result_file << "\n";
    } else {
      result_file << ",\n";
    }
    idx += 1;
  }
  result_file << "\t],\n";

  // output info: model_output_info preserves the order multi-tensor output
  result_file << "\t\"output_info\": [\n";
  for (long unsigned int i = 0; i < metadata.model_output_info.size(); i++) {
    dla_benchmark::OutputInfo info = metadata.model_output_info[i];
    result_file <<  "\t\t{\"name\": \"" << info.name << "\", \"shape\": \"" << info.shape.to_string() << "\"}";
    if (i == metadata.model_output_info.size() - 1) {
      result_file << "\n";
    } else {
      result_file << ",\n";
    }
  }
  result_file << "\t],\n";

  // input files
  result_file << "\t\"input_files\": [\n";
  for (long unsigned int i = 0; i < metadata.input_files.size(); i++) {
    std::string input_file = metadata.input_files[i];
    result_file <<  "\t\t\"" << input_file << "\"";
    if (i == metadata.input_files.size() - 1) {
      result_file << "\n";
    } else {
      result_file << ",\n";
    }
  }
  result_file << "\t]\n";

  result_file << "}\n";
}

bool ExistsTest(const std::string& name) {
  struct stat buffer;
  return (stat(name.c_str(), &buffer) == 0);
}

bool isFile(const std::string& path) {
  std::filesystem::path fs_path(path);
  return std::filesystem::exists(fs_path) && std::filesystem::is_regular_file(fs_path);
}

void CreateDir(const std::string& path) {
  if (!ExistsTest(path)) {
    slog::info << "Specified output directory: " << path << " does not exist" << slog::endl;
    try {
      std::filesystem::create_directories(path);
      slog::info << "Created output directory: " << path << slog::endl;
    } catch (std::filesystem::filesystem_error& e) {
      slog::err << "Failed to create output directory: " << path << " : " << e.what() << slog::endl;
      throw std::runtime_error("Cannot create directory: " + path);
    }
  }
}

bool DirOpenTest(const std::string& name) {
  std::filesystem::path dir_path(name);
  if (std::filesystem::exists(dir_path) && std::filesystem::is_directory(dir_path)) {
    try {
      for (const auto& entry : std::filesystem::directory_iterator(dir_path)) {
        (void)entry;  // Suppress unused variable warning
      }
    } catch (std::exception& e) {
      return false;
    }
    return true;
  }
  return false;
}

bool LoadU64File(const std::string& path, std::vector<uint64_t>& out, int base) {
  std::ifstream f(path);
  if (!f.is_open()) {
    return false;
  }
  out.clear();
  std::string line;
  while (std::getline(f, line)) {
    // Trim whitespace
    const auto first = line.find_first_not_of(" \t\r\n");
    if (first == std::string::npos) {
      continue;
    }
    const auto last = line.find_last_not_of(" \t\r\n");
    line = line.substr(first, last - first + 1);
    if (line.empty()) {
      continue;
    }
    try {
      const auto v = static_cast<uint64_t>(std::stoull(line, nullptr, base));
      out.push_back(v);
    } catch (...) {
      return false;
    }
  }
  return !out.empty();
}

bool WriteU64File(const std::string& path, const std::vector<uint64_t>& data, bool hex) {
  std::ofstream f(path);
  if (!f.is_open()) {
    return false;
  }
  for (const auto& v : data) {
    if (hex) {
      f << std::uppercase << std::hex << v << std::dec << "\n";
    } else {
      f << v << "\n";
    }
  }
  return true;
}

// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: Utility functions handling command line arguments and network input info for DLA's runtime.
//              Loosely based off OpenVino's benchmark_app/utils.hpp
//              [openvinotoolkit/openvino › samples/cpp/benchmark_app/utils.hpp]
//              Future OpenVino uplifts should refer to the file listed above.

#pragma once

#include <cstdint>
#include <map>
#include <string>
#include <vector>

#include "dla_runtime_log.h"

#define MULTIGRAPH_SEP ',' /* seperator used in argument line when multigraph activated */

// Constants
constexpr size_t BYTE_TO_MEGABYTE = 1024 * 1024;
constexpr size_t MAX_COUT_WITHOUT_VERBOSE = 20;  // How many couts can be printed w/o VERBOSE=1

typedef std::chrono::high_resolution_clock Time;
typedef std::chrono::nanoseconds ns;

#ifdef USE_OPENCV
// This is the full list of image extensions supported by the opencv reader:
// "bmp", "dib", "jpeg", "jpg", "jpe",
// "jp2", "png", "pbm", "pgm", "ppm",
// "sr", "ras", "tiff", "tif"
// However, the ones in the list below are already
// tested using the synthetic graphs infrastructure.
// Only jpeg, jpg, jpe extensions of very high quality
// and with subsampling disabled were tested.
// TODO(meldafra): Check why the remaining extensions are not passing and fix them
static const std::vector<std::string> supported_image_extensions = {
    "bmp", "png", "pbm", "pgm", "ppm", "jpeg", "jpg", "jpe"};

#else
static const std::vector<std::string> supported_image_extensions = {"bmp"};
#endif
static const std::vector<std::string> supported_binary_extensions = {"bin"};
static const std::vector<std::string> supported_video_extensions = {"mp4", "gif"};

/**
 * @brief Namespace dla_benchmark contains utility functions for working with network inputs.
 */
namespace dla_benchmark {
struct InputInfo {
  ov::element::Type type;
  ov::PartialShape partial_shape;
  ov::Shape data_shape;
  ov::Layout layout;
  std::vector<float> scale_values;
  std::vector<float> mean_values;
  bool IsImage() const;
  bool IsImageInfo() const;
  bool IsVideo() const;
  size_t GetWidth() const;
  size_t GetHeight() const;
  size_t GetChannels() const;
  size_t GetBatch() const;
  size_t GetDepth() const;
};

struct OutputInfo {
  std::string name;
  ov::Shape shape;
};

using InputsInfo = std::map<std::string, InputInfo>;
using OutputsInfoVec = std::vector<OutputInfo>;
using PartialShapes = std::map<std::string, ov::PartialShape>;

struct InferenceMetaData {
  std::vector<std::string> input_files;  // Input files used inferencing
  std::string groundtruth_loc;  // The directory that contains the groundtruth files
  unsigned int batch_size;  // The batch size used in the inference
  unsigned int niter;  // The number of iterations set by -niter in dla_benchmark
  unsigned int nireq;  // The number of inference requests set by -nireq in dla_benchmark
  dla_benchmark::InputsInfo model_input_info;  // the metadata of the model input
  dla_benchmark::OutputsInfoVec model_output_info;  // the metadata of the model output
};
}  // namespace dla_benchmark

/**
 * @brief Parses number of streams for each device from a string argument.
 *
 * @param devices vector of supported DLA devices, ie FPGA, CPU
 * @param values_string string arg of the format: <device1>:<value1>,<device2>:<value2>
 * @return A map of device : number of streams
 */
std::map<std::string, uint32_t> ParseNStreamsValuePerDevice(const std::vector<std::string>& devices,
                                                            const std::string& values_string);
/**
 * @brief Splits a string into substrings using a specified delimiter.
 *
 * @param s The input string to be split.
 * @param delim The delimiter character used to separate the substrings.
 * @return A vector of strings containing the substrings from the input string.
 */
std::vector<std::string> split(const std::string& s, char delim);

/**
 * @brief Splits a string of floats into floats using a specified delimiter.
 *
 * @param s The input string to be split.
 * @param delim The delimiter character used to separate the floats.
 * @return A vector of floats containing the floats from the input string.
 */
std::vector<float> SplitFloat(const std::string& s, char delim);

// To enable multigraph operations to all CNNNetworks, inputs are mutable
template <typename T, typename S, typename Functor>
inline std::vector<T> VectorMap(std::vector<S>& inputs, Functor fn) {
  std::vector<T> results;
  for (auto& input : inputs) results.push_back(fn(input));
  return results;
}

// Supports temporary object or constant expression
template <typename T, typename S, typename Functor>
inline std::vector<T> VectorMap(const std::vector<S>& inputs, Functor fn) {
  std::vector<T> results;
  for (auto& input : inputs) results.push_back(fn(input));
  return results;
}

template <typename T, typename S, typename Functor>
inline std::vector<T> vectorMapWithIndex(const std::vector<S>& inputs, Functor fn) {
  std::vector<T> results;
  uint32_t index = 0;
  for (auto& input : inputs) results.push_back(fn(input, index++));
  return results;
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
std::vector<std::vector<std::string>> SplitMultiInputFilesArguments(size_t net_size);

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
std::string GetStem(std::string path);

/**
 * @brief Extracts the file extension from a given file name.
 *
 * @param name The file name from which to extract the extension.
 * @return The file extension as a string, or an empty string if no extension is found.
 */
std::string GetExtension(const std::string& path);

/**
 * @brief Parses a list of devices from a string
 *
 * @param device_string The input string to be split. The delimiter is ':'
 * @return A vector of strings containing the devices
 */
std::vector<std::string> ParseDevices(const std::string& device_string);

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
                                        const std::string& mean_string,
                                        const std::string& scale_string);

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
                                        const bool isBinaryData);

/**
 * @brief Filters a list of file paths by specified file extensions (case insensitive).
 *
 * @param file_paths A vector of file paths to be filtered.
 * @param extensions A vector of file extensions to filter by.
 * @return A vector of filtered file paths that match the specified extensions.
 */
std::vector<std::string> FilterFilesByExtensions(const std::vector<std::string>& file_paths,
                                                 const std::vector<std::string>& extensions);

// Helper function to dump result.txt with tensor indicies
void DumpResultTxtFile(ov::Tensor& output_tensor,
                       const ov::Output<const ov::Node>& output_node,
                       const unsigned int output_size,
                       std::ofstream& result_file);

// Helper function to dump the output tensor as binaries in result.bin
void DumpResultBinFile(ov::Tensor& output_tensor,
                       std::ofstream& result_file);

// Helper function to dump the inference metadata into result_meta.json
void DumpResultMetaJSONFile(const dla_benchmark::InferenceMetaData& metadata,
                            std::ofstream& result_file);

/**
 * @brief Gets the appriopriate DLA supported tensor layout from a node.
 *
 * @param node Node to determine the tensor layout. Obtained from ov::Model.inputs()/outputs()
 *             or ov::CompiledModel.inputs()/outputs()
 * @param allow_partial_defined Whether to allow partial defined layout. When set true, DLA tolerates
 *             dumping custom layouts e.g., when the rank of shape is 3. The layout will have ? in
 *             all dimensions. e.g., [???].
 *             This param should ONLY be used when dumping graph output of irregular layout.
 * @return OpenVino's tensor layout object.
 */
ov::Layout GetTensorLayout(const ov::Output<ov::Node>& node, const bool allow_partial_defined = false);
/**
 * @brief Tests if a file or directory exists.
 * @param name Path to check.
 * @return true if the path exists.
 */
bool ExistsTest(const std::string& name);

/**
 * @brief Tests if a path is a regular file.
 * @param path Path to check.
 * @return true if the path is a file.
 */
bool isFile(const std::string& path);

/**
 * @brief Creates a directory (and parent directories) if it doesn't exist.
 * @param path Directory path to create.
 */
void CreateDir(const std::string& path);

/**
 * @brief Tests if a directory can be opened and iterated.
 * @param name Directory path to test.
 * @return true if directory can be opened.
 */
bool DirOpenTest(const std::string& name);

/**
 * @brief Load uint64 values from a text file (one value per line).
 * @param path Path to the input file.
 * @param out Vector to store loaded values.
 * @param base Numeric base for parsing (10 for decimal, 16 for hex).
 * @return true if file was loaded successfully with at least one value.
 */
bool LoadU64File(const std::string& path, std::vector<uint64_t>& out, int base = 10);

/**
 * @brief Write uint64 values to a text file (one value per line).
 * @param path Path to the output file.
 * @param data Vector of values to write.
 * @param hex If true, write in uppercase hex format; otherwise decimal.
 * @return true if file was written successfully.
 */
bool WriteU64File(const std::string& path, const std::vector<uint64_t>& data, bool hex = false);

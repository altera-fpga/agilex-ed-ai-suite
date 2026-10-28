// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: This file implements all supported formats of filling input tensors with input data.
//              Functions in this file has been based off/modified from OpenVINO's input filling algorithms,
//              which would be a good place to start for future OpenVINO uplifts.
//              Ref: [openvinotoolkit/openvino › samples/cpp/benchmark_app/input_fillings.cpp]

#include "inputs_filling.hpp"

#include <algorithm>
#include <cstdlib>
#include <memory>
#include <functional>
#include <limits>
#include <tuple>
#include <string>
#include <utility>
#include <vector>

#include <opencv2/videoio.hpp>
#include <opencv2/opencv.hpp>
#include <samples/slog.hpp>
#include "format_reader_ptr.h"
#include "utils.hpp"

/**
 * @brief Struct to store info of an image read by the FormatReader::Reader class
*/
struct ReaderInfo {
  std::shared_ptr<uint8_t> data;  // Image data
  const size_t file_index;        // Index of the image in the file_paths vector
  const size_t channels;          // Number of channels used by the reader to store the image

  ReaderInfo(std::shared_ptr<uint8_t>& data, size_t file_index, size_t channels)
      : data(data), file_index(file_index), channels(channels) {}
};

// Since the reader always expands the image being read into an rgb image.
// The only way to tell that an image is in fact an rgb and not a grayscale
// image, it to find if the values in channel 0 differ from channel 1 or 2.
// Return true if this is a grayscale image or an rgb image than can safely
// be considered a grayscale image since all channel values are the same.
static bool IsGrayScaleImage(const ReaderInfo& reader_info, uint32_t image_size) {
  const auto num_channels = reader_info.channels;
  const auto& image_data = reader_info.data;
  // Iterate through the image surface
  for (size_t pid = 0; pid < image_size; pid++) {
    // Iterate through the image channels
    for (size_t ch = 1; ch < num_channels; ++ch) {
      if (image_data.get()[pid * num_channels + ch] != image_data.get()[pid * num_channels]) return false;
    }
  }
  return true;
}

template <typename T>
using uniformDistribution = typename std::conditional<
    std::is_floating_point<T>::value,
    std::uniform_real_distribution<T>,
    typename std::conditional<std::is_integral<T>::value, std::uniform_int_distribution<T>, void>::type>::type;

/**
 * @brief Fills a tensor with image data from input files
 *
 * Helper function to GetStaticTensors(), not used outside this file.
 * Determines which image to use based of of input_id, batch_size, input_size, and request_id.
 * Reads that data as uint8 and creates an input tensor of type T corresponding to input element type.
 *
 * @param files vector of file paths to the input images
 * @param input_id image input id, ie image 1, image 2...
 * @param batch_size batch size of the tensor
 * @param input_size number of images to be used
 * @param request_id infer request id
 * @param input_info InputInfo struct corresponding to the input node of the tensor
 * @param input_name name of the input
 * @param bgr boolean indicating if input channels need to be reversed
 * @param verbose prints extra logging information if true
 * @return ov::Tensor containing the input data extracted from the image
*/
template <typename T>
ov::Tensor CreateTensorFromImage(const std::vector<std::string>& files,
                                 const size_t input_id,
                                 const size_t batch_size,
                                 const size_t input_size,
                                 const size_t request_id,
                                 const dla_benchmark::InputInfo& input_info,
                                 const std::string& input_name,
                                 const FormatReader::Reader::ResizeType resize_type,
                                 const bool bgr = false,
                                 const bool verbose = false) {
  // Need to force the layout of the image tensor to NCHW
  const size_t num_channels = input_info.GetChannels();
  const size_t width = input_info.GetWidth();
  const size_t height = input_info.GetHeight();
  size_t img_batch_size = 1;
  if (!input_info.layout.empty() && ov::layout::has_batch(input_info.layout)) {
    img_batch_size = batch_size;
  } else {
    slog::warn << input_name << ": layout does not contain batch dimension. Assuming batch 1 for this input"
               << slog::endl;
  }
  auto tensor = ov::Tensor(ov::element::from<T>(), {img_batch_size, num_channels, height, width});
  // Zero-initialize the data
  auto data = tensor.data<T>();

  /** Collect images data ptrs **/
  std::vector<ReaderInfo> vreader;
  vreader.reserve(batch_size);

  for (size_t i = 0, input_idx = request_id * batch_size * input_size + input_id; i < img_batch_size; i++, input_idx += input_size) {
    input_idx %= files.size();
    FormatReader::ReaderPtr reader(files[input_idx].c_str());
    if (input_idx <= MAX_COUT_WITHOUT_VERBOSE || verbose) {
      slog::info << "Prepare image " << files[input_idx] << slog::endl;
      if (!verbose && input_idx == MAX_COUT_WITHOUT_VERBOSE) {
        slog::info << "Truncating list of input files. Run with --verbose for complete list." << slog::endl;
      }
    }
    if (reader.get() == nullptr) {
      slog::warn << "Image " << files[input_idx] << " cannot be read!" << slog::endl << slog::endl;
      continue;
    }

    /** Getting image data **/
    std::shared_ptr<uint8_t> image_data(reader->getData(input_info.GetWidth(), input_info.GetHeight(), resize_type));
    if (image_data) {
      // Store the number of channels used in storing the image in the reader
      // If the image is grayscale, the reader would will still store it as a three
      // channel image and therefore to read the image correctly we need to read the
      // first channel value and then skip the next two.
      const auto reader_channels = reader->size() / (reader->width() * reader->height());
      vreader.emplace_back(image_data, input_idx, reader_channels);
    }
  }

  const size_t image_size = width * height;  // Calculate the image size

  // Lambda expression for calculating the pixel index in inputBlobData
  // Fill input tensor with image. First b channel, then g and r channels
  const auto get_index = [=](size_t image_id, size_t pid, size_t ch) {
    // Reverse the channel index if bgr is set to true
    return image_id * image_size * num_channels + (bgr ? ch : (num_channels - ch - 1)) * image_size + pid;
  };

  // Lambda expression for calculating the channel (if bgr)
  const auto get_channel = [=](size_t ch) {
    return bgr ? ch : (num_channels - ch - 1);
  };

  /** Iterate over all input images **/
  for (size_t image_id = 0; image_id < vreader.size(); ++image_id) {
    const auto& reader_info = vreader.at(image_id);
    // Error out of the graph has a single channel input and the image is not grayscale
    if (num_channels == 1 && !IsGrayScaleImage(reader_info, image_size)) {
      OPENVINO_THROW(
          "Graph input is grayscale (has a single channel) and the following image is in RGB format:\n\t",
          files.at(reader_info.file_index));
    }
    const auto reader_channels = reader_info.channels;
    /** Iterate over all pixel in image (b,g,r) **/
    for (size_t pid = 0; pid < image_size; pid++) {
      /** Iterate over all channels **/
      for (size_t ch = 0; ch < num_channels; ++ch) {
        // check if scale values are 0
        if (input_info.scale_values[get_channel(ch)] == 0) {
          OPENVINO_THROW("Cannot apply scale value of 0");
        }
        // Reader is created with the assumption that the number of channels is always the maximum
        data[get_index(image_id, pid, ch)] = static_cast<T>(
            (reader_info.data.get()[pid * reader_channels + ch] - input_info.mean_values[get_channel(ch)]) /
            input_info.scale_values[get_channel(ch)]);
      }
    }
  }

  return tensor;
}

/**
 * @brief Fills a tensor with video data from input files
 *
 * Helper function to GetStaticTensors(), not used outside this file.
 * Determines which image to use based of of input_id, batch_size, input_size, and request_id.
 * Reads that and creates an input tensor of type T corresponding to input element type.
 *
 * @param file_paths vector of file paths to the input images
 * @param input_id binary input id, ie video 1, video 2...
 * @param batch_size batch size of the tensor
 * @param input_size number of images to be used
 * @param request_id infer request id
 * @param input_info InputInfo struct corresponding to the input node of the tensor
 * @param input_name name of the input
 * @param bgr boolean indicating if input channels need to be reversed
 * @param verbose prints extra logging information if true
 * @return ov::Tensor containing the input data extracted from the video
*/
template <typename T>
ov::Tensor CreateTensorFromVideo(const std::vector<std::string>& file_paths,
                                 const size_t input_id,
                                 const size_t batch_size,
                                 const size_t input_size,
                                 const size_t request_id,
                                 const dla_benchmark::InputInfo& input_info,
                                 const std::string& input_name,
                                 const bool bgr = false,
                                 const bool verbose = false) {
  const size_t channels = input_info.GetChannels();
  const size_t height = input_info.GetHeight();
  const size_t width = input_info.GetWidth();
  const size_t frame_count = input_info.GetDepth();
  const size_t batch = input_info.GetBatch();
  auto tensor = ov::Tensor(ov::element::from<T>(), {batch, channels, frame_count, height, width});
  auto data = tensor.data<T>();

  const size_t input_idx = (request_id * input_size + input_id) % file_paths.size();

  std::vector<cv::Mat> frames_to_write;
  frames_to_write.reserve(batch_size * frame_count);
  if (verbose) slog::info << "Prepare Video " << file_paths[input_idx] << slog::endl;

  // Open Video
  cv::VideoCapture cap(file_paths[input_idx]);
  if (!cap.isOpened()) {
    throw std::runtime_error("Video file " + file_paths[input_idx] + " cannot be read!");
  }

  // Get amount of frames in video and calculate a step to partition the video into clips
  size_t video_frames = 0;
  size_t step;
  size_t cur_video_pos = 0;
  cv::Mat calc_frame;

  // Using while loop instead of cv::get() since cv::get() isn't guaranteed to return
  // the correct amount of frames
  while ((cap.read(calc_frame))) {
    if (calc_frame.empty()) {
      break;
    }
    video_frames++;
  }

  // Reopen the file at the starting position
  cap.release();
  cap.open(file_paths[input_idx].c_str());
  if (!cap.isOpened()) {
    throw std::runtime_error("Video file " + file_paths[input_idx] + " cannot be read!");
  }

  if (verbose) {
    slog::info << "Video file " << file_paths[input_idx] << " contains " << video_frames << " readable frames."
               << slog::endl;
  }

  // Calculate step to partition video into "batch_size" amount of clips
  if (batch_size == 1) {
    step = frame_count;
  } else if (video_frames < frame_count) {
    step = 1;
  } else {
    step = std::max((size_t)1, (video_frames - frame_count) / (batch_size - 1));
  }

  // Get frames
  for (size_t clip_start = 0; clip_start < batch_size * step; clip_start += step) {
    // Attempt to set position using OpenCV + Video Codec
    bool success = cap.set(cv::CAP_PROP_POS_FRAMES, clip_start);

    // Unsupported by codec, set manually
    if (!success) {
      if (cur_video_pos < clip_start) {
        while (cur_video_pos != clip_start) {
          cap.read(calc_frame);
          cur_video_pos++;
        }
      } else if (cur_video_pos > clip_start) {
        // Reopen the file at the starting position
        cap.release();
        cap.open(file_paths[input_idx].c_str());
        if (!cap.isOpened()) {
          throw std::runtime_error("Video file " + file_paths[input_idx] + " cannot be read!");
        }
        cur_video_pos = 0;
        while (cur_video_pos != clip_start) {
          cap.read(calc_frame);
          cur_video_pos++;
        }
      }
    }

    for (size_t curr_frame = 0; curr_frame < frame_count; curr_frame++) {
      cv::Mat frame;
      cap.read(frame);

      // Frame is empty -> Clip is shorter than frame_count, loop from start of clip
      if (frame.empty()) {
        if (verbose)
          slog::info << "A video clip was shorter than the desired frame count, looping video." << slog::endl;
        bool success = cap.set(cv::CAP_PROP_POS_FRAMES, clip_start);

        // If unsupported by codec, set manually
        if (!success) {
          // Reopen the file at the starting position
          cap.release();
          cap.open(file_paths[input_idx].c_str());
          if (!cap.isOpened()) {
            throw std::runtime_error("Video file " + file_paths[input_idx] + " cannot be read!");
          }
          cur_video_pos = 0;
          while (cur_video_pos != clip_start) {
            cap.read(calc_frame);
            cur_video_pos++;
          }
        } else {
          cur_video_pos = clip_start;
        }

        cap.read(frame);

        // If it's still empty, then there's an error with reading
        if (frame.empty()) {
          slog::err << "Video file " << file_paths[input_idx] << " frames cannot be read!" << slog::endl << slog::endl;
          continue;
        }
      }

      cur_video_pos++;
      // If bgr=false, convert to RGB
      if (!bgr) {
        cv::cvtColor(frame, frame, cv::COLOR_BGR2RGB);
      }

      // Check frame sizing, resize if it doesn't match expected blob size
      cv::Mat resized_frame(frame);
      if (static_cast<int>(width) != frame.size().width || static_cast<int>(height) != frame.size().height) {
        // Resizes to 256 and centre crops based on actual needed dimensions, may add a flag for this in the future
        // to be cleaner
        if (static_cast<int>(width) < 256 && static_cast<int>(height) < 256) {
          double scale;
          if (frame.size().width <= frame.size().height)
            scale = double(256) / frame.size().width;
          else
            scale = double(256) / frame.size().height;
          cv::resize(frame, resized_frame, cv::Size(0, 0), scale, scale);
          const int offsetW = (resized_frame.size().width - static_cast<int>(width)) / 2;
          const int offsetH = (resized_frame.size().height - static_cast<int>(height)) / 2;
          const cv::Rect roi(offsetW, offsetH, static_cast<int>(width), static_cast<int>(height));
          resized_frame = resized_frame(roi).clone();
        } else {
          cv::resize(frame, resized_frame, cv::Size(width, height));
        }
      }
      // Save frame to write
      frames_to_write.emplace_back(resized_frame);
    }
  }

  // Write frames to blob
  for (size_t b = 0; b < batch_size; b++) {
    size_t batch_offset = b * channels * frame_count * height * width;
    for (size_t c = 0; c < channels; c++) {
      size_t channel_offset = c * frame_count * height * width;
      for (size_t frameId = b * frame_count; frameId < (b + 1) * frame_count; frameId++) {
        const cv::Mat& frame_to_write = frames_to_write.at(frameId);
        size_t frame_offset_id = frameId % frame_count;
        size_t frame_offset = frame_offset_id * height * width;
        for (size_t h = 0; h < height; h++) {
          for (size_t w = 0; w < width; w++) {
            data[batch_offset + channel_offset + frame_offset + h * width + w] = frame_to_write.at<cv::Vec3b>(h, w)[c];
          }
        }
      }
    }
  }
  cap.release();
  return tensor;
}

/**
 * @brief Fills a tensor with image info data
 *
 * Helper function to GetStaticTensors(), not used outside this file.
 *
 * @param image_size Size of image width x height
 * @param batch_size batch size of the tensor
 * @param input_info InputInfo struct corresponding to the input node of the tensor
 * @param input_name name of the input
 * @return ov::Tensor containing the input data
*/
template <typename T>
ov::Tensor CreateTensorImInfo(const std::pair<size_t, size_t>& image_size,
                              size_t batch_size,
                              const dla_benchmark::InputInfo& input_info,
                              const std::string& input_name) {
  size_t tensor_size =
      std::accumulate(input_info.data_shape.begin(), input_info.data_shape.end(), 1, std::multiplies<size_t>());
  auto tensor = ov::Tensor(input_info.type, input_info.data_shape);
  char* data = static_cast<char*>(tensor.data());

  size_t info_batch_size = 1;
  if (!input_info.layout.empty() && ov::layout::has_batch(input_info.layout)) {
    info_batch_size = batch_size;
  } else {
    slog::warn << input_name << ": layout is not set or does not contain batch dimension. Assuming batch 1. "
               << slog::endl;
  }

  for (size_t b = 0; b < info_batch_size; b++) {
    size_t im_info_size = tensor_size / info_batch_size;
    for (size_t i = 0; i < im_info_size; i++) {
      size_t index = b * im_info_size + i;
      if (0 == i)
        data[index] = static_cast<char>(image_size.first);
      else if (1 == i)
        data[index] = static_cast<char>(image_size.second);
      else
        data[index] = static_cast<char>(1);
    }
  }

  return tensor;
}

/**
 * @brief Fills a tensor with binary data from input files
 *
 * Helper function to GetStaticTensors(), not used outside this file.
 * Determines which image to use based of of input_id, batch_size, input_size, and request_id.
 * Reads that and creates an input tensor of type T corresponding to input element type.
 *
 * @param files vector of file paths to the input images
 * @param input_id binary input id, ie binary 1, binary 2...
 * @param batch_size batch size of the tensor
 * @param input_size number of images to be used
 * @param request_id infer request id
 * @param input_info InputInfo struct corresponding to the input node of the tensor
 * @param input_name name of the input
 * @param verbose prints extra logging information if true
 * @return ov::Tensor containing the input data extracted from the binary
*/
template <typename T>
ov::Tensor CreateTensorFromBinary(const std::vector<std::string>& files,
                                  const size_t input_id,
                                  const size_t batch_size,
                                  const size_t input_size,
                                  const size_t request_id,
                                  const dla_benchmark::InputInfo& input_info,
                                  const std::string& input_name,
                                  const bool verbose = false) {
  size_t tensor_size =
      std::accumulate(input_info.data_shape.begin(), input_info.data_shape.end(), 1, std::multiplies<size_t>());
  auto tensor = ov::Tensor(input_info.type, input_info.data_shape);
  char* data = static_cast<char*>(tensor.data());
  size_t binary_batch_size = 1;
  if (!input_info.layout.empty() && ov::layout::has_batch(input_info.layout)) {
    binary_batch_size = batch_size;
  } else {
    slog::warn << input_name
               << ": layout is not set or does not contain batch dimension. Assuming that binary "
                  "data read from file contains data for all batches."
               << slog::endl;
  }

  for (size_t b = 0, input_idx = request_id * batch_size * input_size + input_id; b < binary_batch_size; b++, input_idx += input_size) {
    input_idx %= files.size();
    if (input_idx <= MAX_COUT_WITHOUT_VERBOSE || verbose) {
      slog::info << "Prepare binary file " << files[input_idx] << slog::endl;
      if (!verbose && input_idx == MAX_COUT_WITHOUT_VERBOSE) {
        slog::info << "Truncating list of input files. Run with --verbose for complete list." << slog::endl;
      }
    }
    std::ifstream binary_file(files[input_idx], std::ios_base::binary | std::ios_base::ate);
    OPENVINO_ASSERT(binary_file, "Cannot open ", files[input_idx]);

    auto file_size = static_cast<std::size_t>(binary_file.tellg());
    binary_file.seekg(0, std::ios_base::beg);
    OPENVINO_ASSERT(binary_file.good(), "Can not read ", files[input_idx]);
    auto input_size = tensor_size * sizeof(T) / binary_batch_size;
    OPENVINO_ASSERT(file_size == input_size,
                    "File ",
                    files[input_idx],
                    " contains ",
                    file_size,
                    " bytes, but the model expects ",
                    input_size);

    if (input_info.layout != "CN") {
      binary_file.read(&data[b * input_size], input_size);
    } else {
      for (size_t i = 0; i < input_info.GetChannels(); i++) {
        binary_file.read(&data[(i * binary_batch_size + b) * sizeof(T)], sizeof(T));
      }
    }
  }

  return tensor;
}

/**
 * @brief Randomly fills input tensor, used when no input files is provided
 *
 * Helper function to GetStaticTensors(), not used outside this file.
 *
 * @param input_info InputInfo struct corresponding to the input node of the tensor
 * @param rand_min Min. random value
 * @param rand_max Max. random value
 * @return ov::Tensor containing the the randomly generated input data
*/
template <typename T>
ov::Tensor CreateTensorRandom(const dla_benchmark::InputInfo& input_info,
                              T rand_min = std::numeric_limits<uint8_t>::min(),
                              T rand_max = std::numeric_limits<uint8_t>::max()) {
  // Decide the shape first
  ov::Shape tensor_shape = input_info.data_shape;
  // FPGA model only supports channel first.
  // The transpose for case NDHWC and NHWC and HWC below is ok since the tensor has randomly generated input data.
  if (input_info.layout == "NDHWC") {
    // Use NCDHW instead of NDHWC since FPGA model only supports channel first.
    tensor_shape = {input_info.GetBatch(), input_info.GetChannels(), input_info.GetDepth(),
                    input_info.GetHeight(), input_info.GetWidth()};
  } else if (input_info.layout == "NHWC") {
    // Use NCHW instead of NHWC since FPGA model only supports channel first.
    tensor_shape = {input_info.GetBatch(), input_info.GetChannels(),
                    input_info.GetHeight(), input_info.GetWidth()};
  } else if (input_info.layout == "HWC") {
    // Use CHW instead of HWC since FPGA model only supports channel first.
    tensor_shape = {input_info.GetChannels(), input_info.GetHeight(), input_info.GetWidth()};
  }

  size_t tensor_size =
      std::accumulate(tensor_shape.begin(), tensor_shape.end(), 1, std::multiplies<size_t>());
  auto tensor = ov::Tensor(ov::element::from<T>(), tensor_shape);
  auto data = tensor.data<T>();

  std::mt19937 gen(0);

  for (size_t i = 0; i < tensor_size; i++) {
    T value = static_cast<T>(i%255);
    data[i] = value;
  }
  return tensor;
}

/**
 * @brief Wrapper for CreateImageTensorFromImage, uses approriate stl data type for precision
 *
 * See CreateImageTensorFromImage for params. Helper for GetStaticTensors, not used outside this file.
*/
ov::Tensor GetImageTensor(const std::vector<std::string>& files,
                          const size_t input_id,
                          const size_t batch_size,
                          const size_t input_size,
                          const size_t request_id,
                          const std::pair<std::string, dla_benchmark::InputInfo>& input_info,
                          const FormatReader::Reader::ResizeType resize_type,
                          const bool bgr = false,
                          const bool verbose = false) {
  // Edwinzha: All image data will be read as U8 but saved as a float in tensor data structure.
  // Saving as U8 results in accuracy loss in diff check, especially in mobilenet graphs.
  const ov::element::Type_t type = input_info.second.type;
  if (type == ov::element::f16) {
    return CreateTensorFromImage<ov::float16>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, resize_type, bgr, verbose);
  } else  {
    return CreateTensorFromImage<float>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, resize_type, bgr, verbose);
  }
}

/**
 * @brief Wrapper for CreateTensorFromVideo, uses appropriate stl data type for precision
 *
 * See CreateTensorFromVideo for params. Helper for GetStaticTensors, not used outside this file.
*/
ov::Tensor GetVideoTensor(const std::vector<std::string>& files,
                          const size_t input_id,
                          const size_t batch_size,
                          const size_t input_size,
                          const size_t request_id,
                          const std::pair<std::string, dla_benchmark::InputInfo>& input_info,
                          const bool bgr = false,
                          const bool verbose = false) {
  auto type = input_info.second.type;
  if (type == ov::element::f32) {
    return CreateTensorFromVideo<float>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, bgr, verbose);
  } else if (type == ov::element::u8) {
    return CreateTensorFromVideo<uint8_t>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, bgr, verbose);
  } else if (type == ov::element::i32) {
    return CreateTensorFromVideo<int32_t>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, bgr, verbose);
  } else if (type == ov::element::f16) {
    return CreateTensorFromVideo<ov::float16>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, bgr, verbose);
  } else {
    OPENVINO_THROW("Video input tensor type is not supported: " + input_info.first);
  }
}

/**
 * @brief Wrapper for CreateTensorRandom, uses appropriate stl data type for precision
 *
 * See CreateTensorRandom for params. Helper for GetStaticTensors, not used outside this file.
*/
ov::Tensor GetRandomTensor(const std::pair<std::string, dla_benchmark::InputInfo>& input_info) {
  auto type = input_info.second.type;
  if (type == ov::element::f32) {
    return CreateTensorRandom<float>(input_info.second);
  } else if (type == ov::element::f16) {
    return CreateTensorRandom<ov::float16>(input_info.second);
  } else if (type == ov::element::i32) {
    return CreateTensorRandom<int32_t>(input_info.second);
  } else if (type == ov::element::u8) {
    // uniform_int_distribution<uint8_t> is not allowed in the C++17
    // standard and vs2017/19
    return CreateTensorRandom<uint8_t>(input_info.second);
  } else if (type == ov::element::i8) {
    // uniform_int_distribution<int8_t> is not allowed in the C++17 standard
    // and vs2017/19
    return CreateTensorRandom<int8_t>(
        input_info.second, std::numeric_limits<int8_t>::min(), std::numeric_limits<int8_t>::max());
  } else if (type == ov::element::u16) {
    return CreateTensorRandom<uint16_t>(input_info.second);
  } else if (type == ov::element::i16) {
    return CreateTensorRandom<int16_t>(input_info.second);
  } else {
    OPENVINO_THROW("Random input tensor type is not supported: " + input_info.first);
  }
}

/**
 * @brief Creates tensor where data is initialized to zero. Data is expected to be streamed in.
 *
*/
ov::Tensor GetStreamingTensor(const std::pair<std::string, dla_benchmark::InputInfo>& input_info) {
  const dla_benchmark::InputInfo& info = input_info.second;
  // If the layout is NHWC or HWC, always set the tensor layout as *CHW, regardless of the input layout.
  // FPGA model only supports channel first.
  // The transpose for case NHWC and HWC below is ok since the tensor is filled with 0s, and the real data is
  // supplied to the software model via pipe.
  // TODO(linqiaol): revisit this reordering when we want to pass "streaming" data to FPGA hardware from dla_benchmark.
  ov::Shape _shape = info.data_shape;
  if (info.layout == "NHWC") {
    const size_t num_channels = info.GetChannels();
    const size_t width = info.GetWidth();
    const size_t height = info.GetHeight();
    const size_t batch = info.GetBatch();
    _shape = ov::Shape({batch, num_channels, height, width});
  } else if (info.layout == "HWC") {
    const size_t num_channels = info.GetChannels();
    const size_t width = info.GetWidth();
    const size_t height = info.GetHeight();
    const size_t batch = 1;
    _shape = ov::Shape({batch, num_channels, height, width});
  }
  auto tensor = ov::Tensor(info.type, _shape);

  std::size_t num_elements = tensor.get_size();

  if (info.type == ov::element::f32) {
    auto data = tensor.data<float>();
    std::fill(data, data + num_elements, 0.0f);
  } else if (info.type == ov::element::f16) {
    auto data = tensor.data<ov::float16>();
    std::fill(data, data + num_elements, ov::float16(0.0f));
  } else if (info.type == ov::element::i32) {
    auto data = tensor.data<int32_t>();
    std::fill(data, data + num_elements, 0);
  } else if (info.type == ov::element::u8) {
    auto data = tensor.data<uint8_t>();
    std::fill(data, data + num_elements, uint8_t(0));
  } else if (info.type == ov::element::i8) {
    auto data = tensor.data<int8_t>();
    std::fill(data, data + num_elements, int8_t(0));
  } else if (info.type == ov::element::u16) {
    auto data = tensor.data<uint16_t>();
    std::fill(data, data + num_elements, uint16_t(0));
  } else if (info.type == ov::element::i16) {
    auto data = tensor.data<int16_t>();
    std::fill(data, data + num_elements, int16_t(0));
  } else {
    OPENVINO_THROW("Streaming input tensor type is not supported for input '"
                   + input_info.first + "': " + info.type.get_type_name());
  }

  return tensor;
}

/**
 * @brief Wrapper for CreateTensorImInfo, uses appropriate stl data type for precision
 *
 * See CreateTensorImInfo for params. Helper for GetStaticTensors, not used outside this file.
*/
ov::Tensor GetImInfoTensor(const std::pair<size_t, size_t>& image_size,
                           size_t batch_size,
                           const std::pair<std::string, dla_benchmark::InputInfo>& input_info) {
  auto type = input_info.second.type;
  if (type == ov::element::f32) {
    return CreateTensorImInfo<float>(image_size, batch_size, input_info.second, input_info.first);
  } else if (type == ov::element::f64) {
    return CreateTensorImInfo<double>(image_size, batch_size, input_info.second, input_info.first);
  } else if (type == ov::element::f16) {
    return CreateTensorImInfo<ov::float16>(image_size, batch_size, input_info.second, input_info.first);
  } else if (type == ov::element::i32) {
    return CreateTensorImInfo<int32_t>(image_size, batch_size, input_info.second, input_info.first);
  } else if (type == ov::element::i64) {
    return CreateTensorImInfo<int64_t>(image_size, batch_size, input_info.second, input_info.first);
  } else {
    OPENVINO_THROW("Image info input tensor type is not supported:" + input_info.first);
  }
}

/**
 * @brief Wrapper for GetBinaryTensor, uses appropriate stl data type for precision
 *
 * See GetBinaryTensor for params. Helper for GetStaticTensors, not used outside this file.
*/
ov::Tensor GetBinaryTensor(const std::vector<std::string>& files,
                           const size_t input_id,
                           const size_t batch_size,
                           const size_t input_size,
                           const size_t request_id,
                           const std::pair<std::string, dla_benchmark::InputInfo>& input_info,
                           const bool verbose = false) {
  const auto& type = input_info.second.type;
  if (type == ov::element::f32) {
    return CreateTensorFromBinary<float>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, verbose);
  } else if (type == ov::element::f16) {
    return CreateTensorFromBinary<ov::float16>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, verbose);
  } else if (type == ov::element::i32) {
    return CreateTensorFromBinary<int32_t>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, verbose);
  } else if ((type == ov::element::u8)) {
    return CreateTensorFromBinary<uint8_t>(
        files, input_id, batch_size, input_size, request_id, input_info.second, input_info.first, verbose);
  } else {
    OPENVINO_THROW("Binary input tensor type is not supported: " + input_info.first);
  }
}

/**
 * @brief Main function used by DLA benchmark, creates input tensors based off of input files and precision
 *
 * Only creates static tensors (no dims of -1). Calls all other functions in this file.
 *
 * @param input_files vector of input file paths
 * @param batch_size batch size of input
 * @param inputs_info map of input name to InputInfo struct which contains useful input information
 *                    such as precision, tensor layout
 * @param requests_num number of infer requests
 * @param bgr boolean indicating if channels are reversed, corresponds to user bgr flag
 * @param is_binary_data boolean indicating if the image data should be binary, corresponding to user binary flag
 * @param streaming_data boolean indication if dla benchmark is expecting data to be streamed in
 * @param verbose Verbosity boolean. If true, additional logs are printed
 * @return A map of input name with tensor vectors. TensorVector being an alias of ov::Tensors where
 *         each index corresponds to the batch
*/
std::map<std::string, ov::TensorVector> GetStaticTensors(const std::vector<std::string>& input_files,
                                                         const size_t& batch_size,
                                                         dla_benchmark::InputsInfo& inputs_info,
                                                         size_t requests_num,
                                                         FormatReader::Reader::ResizeType resize_type_enum,
                                                         bool bgr = false,
                                                         bool is_binary_data = false,
                                                         bool streaming_data = false,
                                                         bool verbose = false) {
  std::map<std::string, ov::TensorVector> blobs;
  std::vector<std::pair<size_t, size_t>> net_input_im_sizes;
  std::vector<std::tuple<size_t, size_t, size_t>> net_input_vid_sizes;

  if (resize_type_enum != FormatReader::Reader::ResizeType::RESIZE && resize_type_enum != FormatReader::Reader::ResizeType::PAD_RESIZE) {
    slog::err << "Please enter a valid resize option -resize_type=resize or -resize_type=pad_resize" << slog::endl;
    exit(1);
  }

  // Streaming data in means there's no preprocessing done on DLA benchmark
  if (streaming_data && bgr) {
    slog::warn << "DLA Benchmark can not reverse input channels and stream data in." << slog::endl;
  }

  for (auto& item : inputs_info) {
    const std::string& name = item.first;
    const auto& input_info = item.second;
    if (input_info.IsImage() && !is_binary_data) {
      net_input_im_sizes.emplace_back(input_info.GetWidth(), input_info.GetHeight());
    } else if (input_info.IsVideo()) {
      net_input_vid_sizes.emplace_back(input_info.GetDepth(), input_info.GetWidth(), input_info.GetHeight());
    }
    slog::info << "Network input '" << name << "' precision " << input_info.type << ", dimensions "
               << input_info.layout.to_string() << ": [";
    for (size_t i = 0; i < input_info.data_shape.size(); ++i) {
      slog::info << input_info.data_shape[i];
      if (i < input_info.data_shape.size() - 1) {
        slog::info << " ";
      }
    }
    slog::info << "]" << slog::endl;
  }

  size_t img_input_count = net_input_im_sizes.size();
  size_t vid_input_count = net_input_vid_sizes.size();
  size_t bin_input_count = inputs_info.size() - img_input_count - vid_input_count;

  std::vector<std::string> binary_files;
  std::vector<std::string> image_files;
  std::vector<std::string> video_files;

  if (input_files.empty()) {
    slog::warn << "No input files were given: all inputs will be filled with random values!" << slog::endl;
  } else {
    binary_files = FilterFilesByExtensions(input_files, supported_binary_extensions);
    std::sort(std::begin(binary_files), std::end(binary_files));

    auto bins_to_be_used = bin_input_count * batch_size * requests_num;
    if (bins_to_be_used > 0 && binary_files.empty()) {
      std::stringstream ss;
      for (auto& ext : supported_binary_extensions) {
        if (!ss.str().empty()) {
          ss << ", ";
        }
        ss << ext;
      }
      slog::warn << "No supported binary inputs found! Please check your file extensions: " << ss.str() << slog::endl;
    } else if (bins_to_be_used > binary_files.size()) {
      slog::warn << "Some binary input files will be duplicated: " << bins_to_be_used << " files are required but only "
                 << binary_files.size() << " are provided" << slog::endl;
    } else if (bins_to_be_used < binary_files.size()) {
      slog::warn << "Some binary input files will be ignored: only " << bins_to_be_used << " are required from "
                 << binary_files.size() << slog::endl;
    }

    image_files = FilterFilesByExtensions(input_files, supported_image_extensions);
    std::sort(std::begin(image_files), std::end(image_files));

    auto imgs_to_be_used = img_input_count * batch_size * requests_num;
    if (imgs_to_be_used > 0 && image_files.empty()) {
      std::stringstream ss;
      for (auto& ext : supported_image_extensions) {
        if (!ss.str().empty()) {
          ss << ", ";
        }
        ss << ext;
      }
      slog::warn << "No supported image inputs found! Please check your file extensions: " << ss.str() << slog::endl;
    } else if (imgs_to_be_used > image_files.size()) {
      slog::warn << "Some image input files will be duplicated: " << imgs_to_be_used << " files are required but only "
                 << image_files.size() << " are provided" << slog::endl;
    } else if (imgs_to_be_used < image_files.size()) {
      slog::warn << "Some image input files will be ignored: only " << imgs_to_be_used << " are required from "
                 << image_files.size() << slog::endl;
    }

    video_files = FilterFilesByExtensions(input_files, supported_video_extensions);
    std::sort(std::begin(video_files), std::end(video_files));
    auto vids_to_be_used = vid_input_count * requests_num;
    if (vids_to_be_used > 0 && video_files.empty()) {
      std::stringstream ss;
      for (auto& ext : supported_video_extensions) {
        if (!ss.str().empty()) {
          ss << ", ";
        }
        ss << ext;
      }
      slog::warn << "No supported video inputs found! Please check your file extensions: " << ss.str() << slog::endl;
    } else if (vids_to_be_used > video_files.size()) {
      slog::warn << "Some video input files will be duplicated: " << vids_to_be_used << " files are required but only "
                 << video_files.size() << " are provided" << slog::endl;
    } else if (vids_to_be_used < video_files.size()) {
      slog::warn << "Some video input files will be ignored: only " << vids_to_be_used << " are required from "
                 << video_files.size() << slog::endl;
    }
  }

  for (size_t i = 0; i < requests_num; ++i) {
    size_t img_input_id = 0;
    size_t bin_input_id = 0;
    size_t vid_input_id = 0;

    for (auto& item : inputs_info) {
      const std::string& input_name = item.first;
      const auto& input_info = item.second;
      if (item.second.IsImage() && !is_binary_data) {
        if (!image_files.empty()) {
          // Fill with images
          blobs[input_name].push_back(GetImageTensor(
              image_files, img_input_id++, batch_size, img_input_count, i, {input_name, input_info}, resize_type_enum, bgr, verbose));
          continue;
        }
      } else if (input_info.IsVideo()) {
        if (!video_files.empty()) {
          // Fill with videos
          blobs[input_name].push_back(GetVideoTensor(
              video_files, vid_input_id++, batch_size, vid_input_count, i, {input_name, input_info}, bgr, verbose));
          continue;
        }
      } else {
        if (!binary_files.empty()) {
          // Fill with binary files
          blobs[input_name].push_back(
              GetBinaryTensor(binary_files, bin_input_id++, batch_size, bin_input_count, i, {input_name, input_info}, verbose));
          continue;
        }
        if (input_info.IsImageInfo() && (net_input_im_sizes.size() == 1)) {
          // Most likely it is image info: fill with image information
          auto image_size = net_input_im_sizes.at(0);
          blobs[input_name].push_back(GetImInfoTensor(image_size, batch_size, {input_name, input_info}));
          continue;
        }
      }

      if (streaming_data) {
        blobs[input_name].push_back(GetStreamingTensor({input_name, input_info}));
      } else {
        // Fill random
        slog::info << "No suitable input data found, filling input tensors with random data.\n";
        blobs[input_name].push_back(GetRandomTensor({input_name, input_info}));
      }
    }
  }
  return blobs;
}

/**
 * @brief Reads an input data buffer for a streaming input from a set of files
 *
 * @param files vector of input file paths
 * @param input_idx input request index
 * @param unpadded_input_size number of bytes in each input without padding
 * @param padded_input_size number of bytes in each input with padding to a multiple of input bus size
 * @param verbose if true, does not limit the number of input files printed to console
 * @return A byte vectors corresponding to an inference input buffer
 */
std::vector<uint8_t> GetStreamingData(const std::vector<std::string>& files,
                                      size_t input_idx,
                                      const size_t unpadded_input_size,
                                      const size_t padded_input_size,
                                      const bool verbose = false) {
  std::vector<uint8_t> data(padded_input_size);
  // since batch size can impact the padding to bytes for non byte aligned fp sizes
  // we assume that batch size is accounted for in the binary data
  if (input_idx <= MAX_COUT_WITHOUT_VERBOSE || verbose) {
    slog::info << "Prepare binary file " << files[input_idx%files.size()] << slog::endl;
    if (!verbose && input_idx == MAX_COUT_WITHOUT_VERBOSE) {
      slog::info << "Truncating list of input files. Run with --verbose for complete list." << slog::endl;
    }
  }
  input_idx %= files.size();
  std::ifstream binary_file(files[input_idx], std::ios_base::binary | std::ios_base::ate);
  OPENVINO_ASSERT(binary_file, "Cannot open ", files[input_idx]);

  auto file_size = static_cast<std::size_t>(binary_file.tellg());
  binary_file.seekg(0, std::ios_base::beg);
  OPENVINO_ASSERT(binary_file.good(), "Can not read ", files[input_idx]);
  OPENVINO_ASSERT(file_size == unpadded_input_size || file_size == padded_input_size,
                  "File ",
                  files[input_idx],
                  " contains ",
                  file_size,
                  " bytes, but the model expects ",
                  unpadded_input_size,
                  " unpadded size or ",
                  padded_input_size,
                  " padded size.");
  if (file_size != padded_input_size && (input_idx < MAX_COUT_WITHOUT_VERBOSE || verbose)) {
    slog::info << "Input binary file " << files[input_idx] << " is not padded to a multiple of input_stream_interface.data_width."
               << " The input data will be padded to be " << padded_input_size << " bytes." << slog::endl;
  }
  binary_file.read(reinterpret_cast<char*>(data.data()), file_size);

  return data;
}

/**
 * @brief Fills a vector with random data for streaming input
 *
 * Since the data is some unknown floating point format this will almost certainly result in nans.
 *
 * @param input_info InputInfo struct corresponding to the input node of the tensor
 * @return std::vector<uint8_t> containing the randomly generated input data
*/
std::vector<uint8_t> GetRandomStreamingData(const int expected_input_size,
                                         uint8_t rand_min = std::numeric_limits<uint8_t>::min(),
                                         uint8_t rand_max = std::numeric_limits<uint8_t>::max()) {
  std::vector<uint8_t> data(expected_input_size);
  for (size_t i = 0; i < expected_input_size; i++) {
    // should be random, but replicating the behavior of other input filling functions
    data[i] = i%255;
  }
  return data;
}

/**
 * @brief Creates input data buffers for streaming inputs
 *
 * @param input_files vector of input file paths
 * @param unpadded_input_size number of bytes in each input without padding
 * @param padded_input_size number of bytes in each input with padding to a multiple of input bus size
 * @param requests_num number of infer requests
 * @return A vector of byte vectors, each byte vector corresponds to one inference input buffer
 */
std::vector<std::vector<uint8_t>> GetStreamingInputs(const std::vector<std::string>& input_files,
                                                     const size_t unpadded_input_size,
                                                     const size_t padded_input_size,
                                                     size_t requests_num) {
  std::vector<std::vector<uint8_t>> blobs;

  size_t bin_input_count = requests_num;

  std::vector<std::string> binary_files;

  if (input_files.empty()) {
    slog::warn << "No input files were given: all inputs will be filled with random values!" << slog::endl;
  } else {
    binary_files = FilterFilesByExtensions(input_files, supported_binary_extensions);
    std::sort(std::begin(binary_files), std::end(binary_files));

    auto bins_to_be_used = bin_input_count * requests_num;
    if (bins_to_be_used > 0 && binary_files.empty()) {
      std::stringstream ss;
      for (auto& ext : supported_binary_extensions) {
        if (!ss.str().empty()) {
          ss << ", ";
        }
        ss << ext;
      }
      slog::warn << "No supported binary inputs found! Please check your file extensions: " << ss.str() << slog::endl;
      slog::info << "No suitable input data found, filling input tensors with random data.\n";
    } else if (bins_to_be_used > binary_files.size()) {
      slog::warn << "Some binary input files will be duplicated: " << bins_to_be_used << " files are required but only "
                 << binary_files.size() << " are provided" << slog::endl;
    } else if (bins_to_be_used < binary_files.size()) {
      slog::warn << "Some binary input files will be ignored: only " << bins_to_be_used << " are required from "
                 << binary_files.size() << slog::endl;
    }
  }

  size_t bin_input_id = 0;
  for (size_t i = 0; i < requests_num; ++i) {
    if (!binary_files.empty()) {
      // Fill with binary files
      blobs.push_back(GetStreamingData(binary_files, bin_input_id++, unpadded_input_size, padded_input_size));
    } else {
      // Fill random
      blobs.push_back(GetRandomStreamingData(padded_input_size));
    }
  }
  return blobs;
}

/**
 * @brief Copies data from a source OpenVINO Tensor to a destination Tensor.
 *
 * @param dst The destination Tensor where data will be copied.
 * @param src The source Tensor from which data will be copied.
 */
void CopyTensorData(ov::Tensor& dst, const ov::Tensor& src) {
  if (src.get_shape() != dst.get_shape() || src.get_byte_size() != dst.get_byte_size()) {
    throw std::runtime_error(
        "Source and destination tensors shapes and byte sizes are expected to be equal for data copying.");
  }

  // const_cast needed because data() on const tensor is deprecated in 2025.4
  // (will return const void* in 2026.0). We're only reading from src.
  memcpy(dst.data(), const_cast<ov::Tensor&>(src).data(), src.get_byte_size());
}

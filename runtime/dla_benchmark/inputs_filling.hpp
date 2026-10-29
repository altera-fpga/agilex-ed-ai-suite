// Copyright (C) 2018-2023 Altera Corporation
// SPDX-License-Identifier: Apache-2.0
//
// Description: This file defines methods to fill input data into tensors

#pragma once

#include <map>
#include <string>
#include <vector>
#include <utility>

#include <openvino/openvino.hpp>
#include "infer_request_wrap.hpp"
#include "format_reader_ptr.h"

/**
 * @brief Main function used by DLA benchmark, creates input tensors based off of input files and precision
 *
 * Only creates static tensors (no dims of -1). Calls all other functions in this file except those related to streaming.
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
                                                         dla_benchmark::InputsInfo& app_inputs_info,
                                                         size_t requests_num,
                                                         FormatReader::Reader::ResizeType resize_type_enum,
                                                         bool bgr,
                                                         bool is_binary_data,
                                                         bool streaming_data,
                                                         bool verbose);

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
                                                     size_t requests_num);

/**
 * @brief Copies data from a source OpenVINO Tensor to a destination Tensor.
 *
 * @param dst The destination Tensor where data will be copied.
 * @param src The source Tensor from which data will be copied.
 */
void CopyTensorData(ov::Tensor& dst, const ov::Tensor& src);

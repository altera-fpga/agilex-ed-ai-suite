// Copyright 2020 Altera Corporation.
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

/*
  This file contains some helper utilities to output coredla data blobs to files
  in the current working directory
*/

#include <memory>
#include <cstring>

#include "dla_aot_utils.h"

// The resulting file is expected to be consumed by RTL testbench or hardware.
static void writeBufferToBinFile(const uint8_t *buffer, uint32_t buffer_size,
                              const char *file_path) {
  FILE *fp = fopen(file_path, "wb");
  assert(nullptr != fp);

  if (buffer_size && !fwrite(buffer, buffer_size, 1, fp))
  {
    std::cout << "ERROR writing to output file " << file_path << std::endl;
  }

  fclose(fp);
}

// The resulting file is expected to be consumed by RTL testbench or hardware.
static void writeBufferToFile(const uint8_t *buffer, uint32_t buffer_size,
                              const char *file_path) {
  FILE *fp = fopen(file_path, "w");
  assert(nullptr != fp);

  // Write buffer size (in bytes) to the first line
  for (uint32_t b = 0; b < buffer_size; b+=4) {
    if (b && ((b % 128) == 0))
    {
      fprintf(fp, "\n");
    }
    fprintf(fp, "0x%08x", *((uint32_t*)&buffer[b]));
    if(b + 4 < buffer_size)
    {
      fprintf(fp, ",");
    }
  }

  fclose(fp);
}

// Create all files that the splitter is responsible for
void writeInputOutputToFiles (
  const std::array<int32_t, ARCH_HASH_WORD_SIZE>& arch_hash,
  const std::string& build_version,
  const std::string& arch_name,
  const DLAInput &input,
  const DLAOutput &output
) {
  uint8_t arch_build[ARCH_HASH_SIZE + BUILD_VERSION_SIZE + ARCH_NAME_SIZE];

  memset(&arch_build[0], 0, ARCH_HASH_SIZE + BUILD_VERSION_SIZE);
  memcpy(&arch_build[0], arch_hash.data(), ARCH_HASH_SIZE);
  memcpy(&arch_build[ARCH_HASH_SIZE], build_version.c_str(), std::min(build_version.length(),static_cast<size_t>(BUILD_VERSION_SIZE)));
  memcpy(&arch_build[ARCH_HASH_SIZE + BUILD_VERSION_SIZE], arch_name.c_str(), std::min(arch_name.length(),static_cast<size_t>(ARCH_NAME_SIZE)));
  writeBufferToFile(arch_build,
                    sizeof(arch_build),
                    "arch_build.mem");
  writeBufferToFile(arch_build,
                    sizeof(arch_build),
                    "arch_build.bin");
  const auto &config_fbs_buffer =
    input.compiled_result->get_config_filter_bias_scale_array();

  // Only dump filters and config memory file when they are saved in DDR
  if (!input.compiled_result->get_ddrfree_header().enable_on_chip_parameters) {
    writeBufferToFile(&(config_fbs_buffer[0][0]),
                      input.config_buffer_size,
                      "config.mem");
    writeBufferToBinFile(&(config_fbs_buffer[0][0]),
                      input.config_buffer_size,
                      "config.bin");
    writeBufferToFile(&(config_fbs_buffer[0][0]) + input.config_buffer_size,
                      input.filter_bias_scale_buffer_size,
                      "filter.mem");
    writeBufferToBinFile(&(config_fbs_buffer[0][0]) + input.config_buffer_size,
                      input.filter_bias_scale_buffer_size,
                      "filter.bin");
  } else {
    std::cout << "Graph filters and DLA configs are not dumped because parameter ROM is enabled in the AOT file." << std::endl;
  }
  uint8_t* input_buffer = nullptr;
  uint32_t input_size = 0;
  if (input.input_feature_buffer) {
    input_buffer = input.input_feature_buffer;
    input_size = input.input_feature_buffer_size;
  }
  writeBufferToFile(input_buffer,
                    input_size,
                    "input.mem");
  writeBufferToBinFile(input_buffer,
                    input_size,
                    "input.bin");
  writeBufferToFile((const uint8_t*)&input_size,
                     sizeof(input_size),
                     "input_size.mem");
  uint32_t inter_size = input.intermediate_feature_buffer_size;
  writeBufferToFile((const uint8_t*)&inter_size,
                     sizeof(inter_size),
                     "inter_size.mem");
  uint32_t output_size = input.output_feature_buffer_size;
  writeBufferToFile((const uint8_t*)&output_size,
                     sizeof(output_size),
                     "output_size.mem");
}

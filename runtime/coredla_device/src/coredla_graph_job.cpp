// Copyright 2020-2023 Altera Corporation.
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

#include "coredla_graph_job.h"  //CoreDlaGraphJob
#include "dla_exception.h"

#include <cinttypes>
#include <cstdlib>   //std::getenv
#include <iomanip>   //std::hex
#include <iostream>  //std::cerr
#include <sstream>   //std::stringstream
#include <string>    //std::string

#include "dla_aligned_allocator.h"

using AlignedVecUChar = std::vector<unsigned char, aligned_allocator<unsigned char, kMsgDMAMaxBurstBytes>>;

#define BUILD_VERSION_CSR_OFFSET (ARCH_HASH_SIZE)
#define ARCH_NAME_CSR_OFFSET (ARCH_HASH_SIZE + BUILD_VERSION_SIZE)

#define FLAG_DISABLE_ARCH_CHECK "DLA_DISABLE_ARCH_CHECK"
#define FLAG_DISABLE_VERSION_CHECK "DLA_DISABLE_VERSION_CHECK"

std::unique_ptr<GraphJob> CoreDlaGraphJob::MakeUnique(DeviceMemoryAllocator *ddrBufferAllocator,
                                                      MmdWrapper *mmdWrapper,
                                                      const dla::CompiledResult *compiledResult,
                                                      uint64_t numPipelines,
                                                      int instance,
                                                      std::shared_ptr<StreamControllerComms> spStreamControllerComms) {
  return std::unique_ptr<GraphJob>(new CoreDlaGraphJob(
      ddrBufferAllocator, mmdWrapper, compiledResult, numPipelines, instance, spStreamControllerComms));
}

std::string get_env_var_wrapper(const std::string &env_var) {
  const char *env_var_ptr = std::getenv(env_var.c_str());
  if (env_var_ptr == nullptr) {
    return "";
  }

  return std::string(env_var_ptr);
}

std::string arch_hash_to_string(const std::array<int32_t, ARCH_HASH_WORD_SIZE> &arch_hash) {
  std::stringstream s;
  for (size_t i = 0; i < ARCH_HASH_WORD_SIZE; ++i) {
    s << std::setfill('0') << std::setw(8) << std::hex << std::right << arch_hash[i] << " ";
  }

  return s.str();
}

std::string read_string_from_bitstream_rom(MmdWrapper *mmdWrapper,
                                           const int instance,
                                           const uint32_t str_word_size_in_bytes,
                                           const uint32_t str_offset_in_rom) {
  std::string str_from_rom;
  bool done = false;
  for (uint32_t i = 0; i < str_word_size_in_bytes && (!done); ++i) {
    int chunk = mmdWrapper->ReadFromCsr(instance, str_offset_in_rom + i * 4);
    // Parse the int word into chars. Stops at any NUL char.
    for (int j = 0; j < 4; ++j) {
      char rom_char = (chunk >> (j * 8)) & 0xFF;
      if (rom_char == 0) {
        done = true;
        break;
      } else {
        str_from_rom.push_back(rom_char);
      }
    }
  }
  return str_from_rom;
}

CoreDlaGraphJob::CoreDlaGraphJob(DeviceMemoryAllocator *ddrBufferAllocator,
                                 MmdWrapper *mmdWrapper,
                                 const dla::CompiledResult *compiledResult,
                                 uint64_t numPipelines,
                                 int instance,
                                 std::shared_ptr<StreamControllerComms> spStreamControllerComms)
    : configFilterBiasBufferSizeDDR_(0),
      intermediateBufferSizeDDR_(0),
      ddrBufferAllocator_(ddrBufferAllocator),
      mmdWrapper_(mmdWrapper),
      batchJobsRequested_(0),
      instance_(instance) {
  // First read the arch_md5, build_version_string and arch_name string from
  // the metadata stored in the bitstream discovery ROM, then compare them
  // against the information present in the compiled result. Fail if it does not match.

  // ARCH_HASH_SIZE bytes for the arch hash.
  std::array<int32_t, ARCH_HASH_WORD_SIZE> bitstream_arch_hash;
  DLA_LOG("Read hash from bitstream ROM...\n");
  for (size_t i = 0; i < bitstream_arch_hash.size(); ++i) {
    bitstream_arch_hash[i] = (mmdWrapper_->ReadFromCsr(instance_, i * 4));
  }

  // Next BUILD_VERSION_SIZE bytes are for the build version string
  DLA_LOG("Read build version string from bitstream ROM...\n");
  std::string bitstream_build_version =
      read_string_from_bitstream_rom(mmdWrapper_, instance_, BUILD_VERSION_WORD_SIZE, BUILD_VERSION_CSR_OFFSET);

  // Next ARCH_NAME_SIZE bytes are for the arch name string
  DLA_LOG("Read arch name string from bitstream ROM...\n");
  std::string bitstream_arch_name =
      read_string_from_bitstream_rom(mmdWrapper_, instance_, ARCH_NAME_WORD_SIZE, ARCH_NAME_CSR_OFFSET);

  // ************************ Perform all checks *******************************
  // ***************************************************************************
  if (get_env_var_wrapper(FLAG_DISABLE_ARCH_CHECK) != "1") {
    DLA_LOG("Runtime arch check is enabled. Check started...\n");

    for (size_t i = 0; i < ARCH_HASH_WORD_SIZE; ++i) {
      if (compiledResult->get_arch_hash()[i] != bitstream_arch_hash[i]) {
        throw dla::errors::runtime_error("Arch check failed: compiledResult arch hash is " + arch_hash_to_string(compiledResult->get_arch_hash())
                  + ", compiledResult arch is " + compiledResult->get_arch_name() + ", bitstream arch_hash is "
                  + arch_hash_to_string(bitstream_arch_hash) + ", bitstream arch is " + bitstream_arch_name
                  + "\nThis check can be disabled by setting environment variable " FLAG_DISABLE_ARCH_CHECK "=1.");
      }
    }
    DLA_LOG("Runtime arch check passed.\n");
  } else {
    DLA_ERROR(
        "Environment variable %s is set to 1; "
        "architecture check will be skipped. "
        "This might cause undefined behavior including hanging, "
        "and the user should only disable the check if "
        "they understand the potential consequences.\n",
        FLAG_DISABLE_ARCH_CHECK);
  }

  if (get_env_var_wrapper(FLAG_DISABLE_VERSION_CHECK) != "1") {
    DLA_LOG(
        "Runtime build version check is enabled. "
        "Check started...\n");
    if (bitstream_build_version != compiledResult->get_build_version_string()) {
      std::cerr << "Build version check failed:"
                << "compiledResult build version is " << compiledResult->get_build_version_string()
                << ", bitstream build version is " << bitstream_build_version << std::endl;

      std::cerr << "This check can be disabled by setting environment variable " << FLAG_DISABLE_VERSION_CHECK << "=1."
                << std::endl;

      std::exit(1);
    }
    DLA_LOG("Runtime build version check passed.\n");
  } else {
    DLA_ERROR(
        "Environment variable %s is set to 1; "
        "build version check will be skipped. "
        "This might cause undefined behavior including hanging, "
        "and the user should only disable the check if "
        "they understand the potential consequences.\n",
        FLAG_DISABLE_VERSION_CHECK);
  }

  const auto &input_config = compiledResult->get_input_configuration();
  const auto &lt_parameters = input_config.begin()->second.transform_parameters;
  const uint32_t post_lt_tensor_size = lt_parameters._output_channels *
                                       lt_parameters._output_height *
                                       lt_parameters._output_width *
                                       lt_parameters._output_depth *
                                       sizeof(uint16_t);
  const auto& arch = compiledResult->get_arch();

  const bool enable_istream = arch->is_streaming_input_enabled();
  const bool enable_ostream = arch->is_streaming_out_arch();
  const bool enable_on_chip_parameters = arch->is_on_chip_parameters_enabled();
  const bool enable_lt_writeback = arch->is_layout_transform_writeback_enabled();
  constexpr uint64_t kMaxBurstSize = kMsgDMAMaxBurstBytes;
  auto pad_to_burst = [](uint64_t size) {
    return dla::util::nextDivisible(size, kMaxBurstSize);
  };

  // Checks completed. Allocate buffers and write to DDR
  intermediateBufferSizeDDR_ = pad_to_burst(compiledResult->get_conv_intermediate_size_in_bytes());
  uint64_t totalConfigBytes = compiledResult->get_ddrfree_header().enable_on_chip_parameters  ?
                                0 :
                                compiledResult->get_config_size_in_bytes();
  auto &config_fbs_array = compiledResult->get_config_filter_bias_scale_array();



  configFilterBiasBufferSizeDDR_ = compiledResult->get_ddrfree_header().enable_on_chip_parameters  ?
                                    0 :
                                    config_fbs_array[0].size();

  // TODO: uncomment when buffer_t object is added
  // assert(config_filter_bias_graph_buffer_size_ddr == config_filter_bias_buffer->size_in_bytes());
  // Allocate graph buffer (config, filter, bias, io) in DDR
  uint64_t inputSizeDDR = enable_istream
    ? arch->pad_streaming_input_size(compiledResult->get_streaming_input_size())
    : pad_to_burst(compiledResult->get_conv_input_size_in_bytes());

  uint64_t outputSizeDDR = pad_to_burst(compiledResult->get_conv_output_size_in_bytes());

  if (enable_ostream) {
    auto dims = compiledResult->get_output_configuration().dims[0];
    outputSizeDDR = mmdWrapper_->SetOStreamOutputShape(dims[1], dims[2], dims[3], compiledResult->get_ddrfree_header().c_vector);
  }

  // DMA data path width in bytes for feature and filter data
  // TODO: move this into the arch
  constexpr uint64_t featureWordSize = 64;
  constexpr uint64_t filterWordSize = 64;

  // Sanity check that buffer sizes are sufficiently aligned to ensure address alignment.
  // Input, output, and intermediate buffers contain feature words.
  assert(intermediateBufferSizeDDR_ % featureWordSize == 0);
  // filter contains filter words, and config must be padded to a filter word size
  assert(totalConfigBytes % filterWordSize == 0);
  assert(configFilterBiasBufferSizeDDR_ % filterWordSize == 0);

  // Allocate the intermediate buffer.
  ddrBufferAllocator_->AllocateSharedBuffer(intermediateBufferSizeDDR_, instance_);

  // Allocate the input/output buffer.
  // Output buffer must come immediately after the input buffer, so from an allocation perspective this is one buffer.
  // Note there is an input/output buffer pair allocated for each pipeline. The input/output pair must be contiguous for
  // each pipeline, but input/output pairs from different pipelines are allowed to have a gap. We could call the
  // allocator for each input/output buffer pair, however because everything is sized and aligned to the feature word
  // size, we won't get gaps between them due to alignment. Calling the allocator once per pipeline would result in the
  // same allocation as calling the allocator just once and using offsets within this big buffer for each pipeline.
  uint64_t inputOutputBufferSize = 0;  // how much space to allocate
  if (!enable_istream) {
    assert(inputSizeDDR % featureWordSize == 0);
    inputOutputBufferSize += numPipelines * inputSizeDDR;
  }
  if (!enable_ostream) {
    assert(outputSizeDDR % featureWordSize == 0);
    inputOutputBufferSize += numPipelines * outputSizeDDR;
  }

  uint64_t inputOutputBufferAlignment = featureWordSize;
  uint64_t inputOutputBufferAddr = 0;  // where the allocator places this buffer
  if (inputOutputBufferSize > 0) {
    ddrBufferAllocator_->AllocatePrivateBuffer(inputOutputBufferSize, inputOutputBufferAlignment, inputOutputBufferAddr);
  }

  // Allocate the config/filter buffer.
  // Filter buffer must come immediately after the config buffer, so from an allocation perspective this is one buffer.
  uint64_t configFilterBufferSize = configFilterBiasBufferSizeDDR_;
  uint64_t configFilterBufferAlignment = filterWordSize;
  uint64_t configFilterBufferAddr = 0;


  if (configFilterBufferSize > 0) {
    ddrBufferAllocator_->AllocatePrivateBuffer(
        configFilterBufferSize, configFilterBufferAlignment, configFilterBufferAddr);
  }

  // Print the allocation results
  bool print_allocation_result = getenv("COREDLA_RUNTIME_DEBUG") != nullptr;
  ios_base::fmtflags coutFlags = cout.flags();  // printing in both decimal and hex, save cout state to undo it later
  if (print_allocation_result) {
    DLA_LOG("FPGA DDR allocation results\n");
    // Intermediate buffer address is hardcoded to 0 in device_memory_allocator.cpp, don't bother printing this
    DLA_LOG("  Config buffer is at address %" PRIu64, configFilterBufferAddr);
    DLA_LOG(" (%#" PRIx64 ")\n", configFilterBufferAddr);
    const uint64_t filter_buffer_address = configFilterBufferAddr + totalConfigBytes;
    DLA_LOG("  Filter/bias/scale buffer is at address %" PRIu64, filter_buffer_address);
    DLA_LOG(" (%#" PRIx64 ")\n", filter_buffer_address);
  }

  // Write graph buffer to DDR
  mmdWrapper_->enableCSRLogger();
  if (!compiledResult->get_ddrfree_header().enable_on_chip_parameters) {
    if (config_fbs_array.empty()) {  //Below block added replacing old mmdWrapper_->WriteToDDR
      throw std::runtime_error("config_fbs_array is empty");
    }
    size_t size = config_fbs_array[0].size();
    size_t padded_size = configFilterBufferSize;
    if (padded_size < size || padded_size == 0) {
      throw std::runtime_error("padded_size is invalid (smaller than data or zero)");
    }
    AlignedVecUChar aligned_buf(padded_size, 0); // zero-fill padding
    memcpy(aligned_buf.data(), config_fbs_array[0].data(), size); // copy real data
    mmdWrapper_->WriteToDDR(instance_, configFilterBufferAddr, padded_size, aligned_buf.data()); // DMA full burst
  } else {
    DLA_LOG("  Ddrfree graph constants are not written to DDR.\n");
  }
  mmdWrapper_->disableCSRLogger();

  for (uint64_t i = 0; i < numPipelines; i++) {
    uint64_t inputAddrDDR = inputOutputBufferAddr + i * (inputSizeDDR + outputSizeDDR);
    uint64_t outputAddrDDR = inputAddrDDR + inputSizeDDR;
    if (print_allocation_result) {
      DLA_LOG("  Input buffer %" PRIu64 " is at address %" PRIu64, i, inputAddrDDR);
      DLA_LOG(" (%#" PRIx64 ")\n", inputAddrDDR);
      DLA_LOG("  Output buffer %" PRIu64 " is at address %" PRIu64, i, outputAddrDDR);
      DLA_LOG(" (%#" PRIx64 ")\n", outputAddrDDR);
    }
    const bool disableExternalMemory = compiledResult->get_ddrfree_header().disable_external_memory;
    batchJobs_.push_back(move(CoreDlaBatchJob::MakeShared(mmdWrapper_,
                                                          totalConfigBytes,
                                                          configFilterBufferAddr,
                                                          inputAddrDDR,
                                                          outputAddrDDR,
                                                          inputSizeDDR,
                                                          outputSizeDDR,
                                                          enable_istream,
                                                          enable_ostream,
                                                          enable_lt_writeback,
                                                          enable_on_chip_parameters,
                                                          disableExternalMemory,
                                                          instance_,
                                                          spStreamControllerComms,
                                                          post_lt_tensor_size)));
  }
  cout.flags(coutFlags);  // restore the state of cout
}

std::shared_ptr<BatchJob> CoreDlaGraphJob::GetBatchJob() {
  graphJobMutex.lock();
  if (batchJobsRequested_ >= batchJobs_.size()) {
    graphJobMutex.unlock();
    return nullptr;
  }
  auto batchJob = batchJobs_[batchJobsRequested_];
  batchJobsRequested_++;
  graphJobMutex.unlock();
  return batchJob;
}

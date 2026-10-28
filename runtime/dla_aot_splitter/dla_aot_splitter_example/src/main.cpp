// Copyright 2022 Altera Corporation.
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

//
// This small tool demonstrates the minimum number of steps necessary to run an
// inference on the FPGA while using the output files from the AoT splitter.
//

#include <iostream>
#include <iomanip>
#include <fstream>
#include <stdint.h>
#include <array>
#include <cstring> //memcpy
#include <cstdlib> //getenv()
#include <vector>

uint32_t arch_build_mem_32[] =
{
  #include "arch_build.mem"
};
uint8_t* const arch_build_mem = (uint8_t*)&arch_build_mem_32[0];
const uint32_t arch_build_mem_size = sizeof(arch_build_mem_32);

uint32_t input_mem_32[] =
{
  #include "input.mem"
};
uint8_t* const input_mem = sizeof(input_mem_32) ? (uint8_t*)&input_mem_32[0] : nullptr;
constexpr uint32_t input_mem_size =
  #include "input_size.mem"
;

uint32_t config_mem_32[] =
{
  #include "config.mem"
};
uint8_t* const config_mem = (uint8_t*)&config_mem_32[0];
const uint32_t config_mem_size = sizeof(config_mem_32);

uint32_t filter_mem_32[] =
{
  #include "filter.mem"
};
uint8_t* const filter_mem = (uint8_t*)&filter_mem_32[0];
const uint32_t filter_mem_size = sizeof(filter_mem_32);

constexpr uint32_t output_mem_size =
  #include "output_size.mem"
;

constexpr uint32_t inter_mem_size =
  #include "inter_size.mem"
;

const bool enableCSRLog = true;

#include "mmd_wrapper.h"
#include "device_memory_allocator.h"
#include "dla_dma_constants.h"  //DLA_DMA_CSR_OFFSET_***
#include "dla_aligned_allocator.h"
#include "dla_stl_utils.h"  //dla::util::nextDivisible

using AlignedVec = std::vector<uint8_t, aligned_allocator<uint8_t, kMsgDMAMaxBurstBytes>>;

#define FLAG_DISABLE_ARCH_CHECK "DLA_DISABLE_ARCH_CHECK"
#define FLAG_DISABLE_VERSION_CHECK "DLA_DISABLE_VERSION_CHECK"

int main(int argc, char *argv[]) {
  constexpr uint64_t kMaxBurstSize = kMsgDMAMaxBurstBytes;
  auto pad_to_burst = [](uint64_t size) {
    return dla::util::nextDivisible(size, kMaxBurstSize);
  };
  uint64_t padded_input_mem_size   = pad_to_burst(input_mem_size);
  uint64_t padded_output_mem_size  = pad_to_burst(output_mem_size);
  uint64_t padded_inter_mem_size   = pad_to_burst(inter_mem_size);
  uint64_t padded_config_mem_size  = pad_to_burst(config_mem_size);
  uint64_t padded_filter_mem_size  = pad_to_burst(filter_mem_size);
  AlignedVec actual_output_mem(padded_output_mem_size);
  for (uint64_t i=0u; i < actual_output_mem.size();i++)
  {
    actual_output_mem[i] = (0xDEADBEEF) >> ((3-(i%4)) * 8);
  }
  std::cout << "AOT Splitter Example" << std::endl;
  constexpr int instance = 0;
  constexpr int _maxNumPipelines = 5;
  constexpr int numPipelines = _maxNumPipelines;
  // TODO: retrieve this from the arch file
  // Picking safe values for word sizes
  constexpr uint64_t featureWordSize = 64;
  constexpr uint64_t filterWordSize = 64;


  constexpr int ARCH_HASH_SIZE = 16;
  constexpr int BUILD_VERSION_SIZE = 32;

  #ifdef AOCL_JTAG_PATH
  MmdWrapper mmdWrapper("", enableCSRLog);
  #else
  MmdWrapper mmdWrapper(enableCSRLog);
  #endif
  DeviceMemoryAllocator ddrAllocator{};

  const char* env_disable_arch_check = std::getenv(FLAG_DISABLE_ARCH_CHECK);
  // Working with C-style strings makes a little bit more sense here because that's what std::getenv() returns.
  // The '2' in strncmp() is to make sure the comparison is only done on at most two characters (the one you want plus the '\0' at the end)
  bool enable_arch_check = env_disable_arch_check == nullptr || strncmp(env_disable_arch_check, "1", 2) != 0;

  if (!enable_arch_check) {
    std::cout << "WARNING: Architecture check is disabled. This may cause undefined behavior including hanging."
              << std::endl;
  }
  if (enable_arch_check) {
    for (size_t i = 0; i < ARCH_HASH_SIZE; i+=4) {
      uint32_t arch_build_word_from_device = mmdWrapper.ReadFromCsr(instance, i);
      if (arch_build_mem_32[i/4] != arch_build_word_from_device)
      {
        std::cout << "Arch hash mismatch at word " << i <<  " : expected " <<
          std::setfill('0') << std::setw(8) << std::uppercase << std::hex << (uint32_t)arch_build_mem_32[i/4] <<
          " != " <<
          std::setfill('0') << std::setw(8) << std::uppercase << std::hex << (uint32_t)arch_build_word_from_device << std::endl;
        return 1;
      }
    }
  }
  char expected_build_version[BUILD_VERSION_SIZE + 1];
  expected_build_version[BUILD_VERSION_SIZE] = '\0';
  std::memcpy(expected_build_version, (uint8_t*)&arch_build_mem_32[ARCH_HASH_SIZE/sizeof(uint32_t)], BUILD_VERSION_SIZE);

  char actual_build_version[BUILD_VERSION_SIZE + 1];
  actual_build_version[BUILD_VERSION_SIZE] = '\0';

  const char* env_disable_version_check = std::getenv(FLAG_DISABLE_VERSION_CHECK);
  bool enable_version_check = env_disable_version_check == nullptr || strncmp(env_disable_version_check, "1", 2) != 0;
  if (!enable_version_check) {
    std::cout << "WARNING: Build version check is disabled. This may cause undefined behavior including hanging."
              << std::endl;
  }
  if (enable_version_check) {
    for (uint32_t i=0;i < BUILD_VERSION_SIZE; i+=4)
    {
      uint32_t chunk = mmdWrapper.ReadFromCsr(instance, ARCH_HASH_SIZE + i);
      for (uint8_t j=0;j < 4; j++)
      {
        actual_build_version[i+j] = chunk & 0xFF;
        chunk >>= 8;
      }
    }
    if (0 != std::strncmp(expected_build_version, actual_build_version, BUILD_VERSION_SIZE))
    {
      std::cout << "Build version mismath. Expected " << expected_build_version << " actual " << actual_build_version << std::endl;
      return 1;
    }
  }

  ddrAllocator.Initialize(mmdWrapper.GetDDRSizePerInstance(), &mmdWrapper);

  mmdWrapper.enableCSRLogger();
  ddrAllocator.AllocateSharedBuffer(padded_inter_mem_size, instance);
  // mmdWrapper.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_INTERMEDIATE_BASE_ADDR, 0);


  uint64_t inputOutputBufferSize = numPipelines * (padded_input_mem_size + padded_output_mem_size);
  uint64_t inputOutputBufferAlignment = featureWordSize;  // starting address must be aligned to this
  uint64_t inputOutputBufferAddr;                         // where did the allocator place this buffer
  ddrAllocator.AllocatePrivateBuffer(inputOutputBufferSize, inputOutputBufferAlignment, inputOutputBufferAddr);

  uint64_t configFilterBufferSize = padded_config_mem_size + padded_filter_mem_size;
  uint64_t configFilterBufferAlignment = filterWordSize;
  uint64_t configFilterBufferAddr;
  ddrAllocator.AllocatePrivateBuffer(configFilterBufferSize, configFilterBufferAlignment, configFilterBufferAddr);

  mmdWrapper.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_INTERRUPT_MASK, 0);
  mmdWrapper.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_INTERRUPT_CONTROL, 3);
  uint32_t completionCount = mmdWrapper.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_COMPLETION_COUNT);
  std::cout << "Initial completion count " << completionCount << std::endl;

  mmdWrapper.WriteToDDR(instance, inputOutputBufferAddr, padded_input_mem_size, input_mem);

  mmdWrapper.WriteToDDR(instance, configFilterBufferAddr, padded_config_mem_size, config_mem);
  mmdWrapper.WriteToDDR(instance, configFilterBufferAddr + padded_config_mem_size, padded_filter_mem_size, filter_mem);
  mmdWrapper.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_CONFIG_BASE_ADDR, configFilterBufferAddr);
  constexpr int CONFIG_READER_DATA_BYTES = 8;  // May want to move to a header in production code
  mmdWrapper.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_CONFIG_RANGE_MINUS_TWO, ((config_mem_size) / CONFIG_READER_DATA_BYTES) - 2);


  std::cout << "Finished setup, starting inference. " << std::endl;
  // base address for feature reader -- this will trigger one run of DLA
  mmdWrapper.WriteToCsr(instance, DLA_DMA_CSR_OFFSET_INPUT_OUTPUT_BASE_ADDR, inputOutputBufferAddr);

  int i=0;
  while(mmdWrapper.ReadFromCsr(instance, DLA_DMA_CSR_OFFSET_COMPLETION_COUNT) == completionCount)
  {
    i++;
    if (i % 100000 == 0) {
      std::cout << "Timeout" << std::endl;
      return 1;
    }
  }

  std::cout << "Completed infered in " << i << " polling intervals" << std::endl;

  //Reading from pipeline zero
  mmdWrapper.ReadFromDDR(instance, inputOutputBufferAddr + padded_input_mem_size, padded_output_mem_size, actual_output_mem.data());
  mmdWrapper.disableCSRLogger();

  std::ofstream of ("actual_output.mem", std::ios_base::out | std::ios_base::binary);
  if (of) {
    of.write((const char*)actual_output_mem.data(), actual_output_mem.size());
  }
  of.close();

  return 0;
}

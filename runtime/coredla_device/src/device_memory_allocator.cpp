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

#include "device_memory_allocator.h"  //DeviceMemoryAllocator
#include "dla_dma_constants.h"        //DLA_DMA_CSR_OFFSET_***

#include <stdexcept>  //std::runtime_error
#include <string>     //std::string

void DeviceMemoryAllocator::Initialize(uint64_t totalSize, MmdWrapper* mmdWrapper) {
  totalGlobalMemSize_ = totalSize;
  mmdWrapper_ = mmdWrapper;
  currentIntermediateMaxBufferSizeAllocated_ = 0;
  currentStartAddressGraphBufferSpace_ = totalSize;
}

// The intermediate buffer is shared among all graphs. It gets placed at the lowest address
// and grows upwards (if a new graph is added which needs a bigger intermediate buffer).
void DeviceMemoryAllocator::AllocateSharedBuffer(uint64_t bufferSize, int instance) {
  if (bufferSize > currentIntermediateMaxBufferSizeAllocated_) {
    currentIntermediateMaxBufferSizeAllocated_ = bufferSize;

    // error intermediate buffer grows into the region of memory used for private buffers
    if (currentIntermediateMaxBufferSizeAllocated_ > currentStartAddressGraphBufferSpace_) {
      std::string msg = "FPGA DDR allocation failed, intermediate buffer grew upwards to " +
                        std::to_string(currentIntermediateMaxBufferSizeAllocated_) +
                        ", remaining unallocated space is limited to " +
                        std::to_string(currentStartAddressGraphBufferSpace_);
      throw std::runtime_error(msg);
    }

    // tell the fpga where the intermediate buffer is located. At address 0 now. Will change in future with multiple
    // pe_arrays
    mmdWrapper_->WriteToCsr(instance, DLA_DMA_CSR_OFFSET_INTERMEDIATE_BASE_ADDR, 0);
  }
}

// The config, filter, input, and output buffers are specific to a graph and therefore require
// their own space in device memory. Note that filter must come immediately after config, so the
// allocator allocates both of these together as one buffer. Likewise output must come immediately
// after input. Private buffers are allocated from the highest to lowest address since the size is
// known at allocation time. Hardware requires the address to have some alignment, which is
// specified by the bufferAlignment argument.
void DeviceMemoryAllocator::AllocatePrivateBuffer(uint64_t bufferSize, uint64_t bufferAlignment, uint64_t& bufferAddr) {
  uint64_t maxInflatedBufferSize = bufferSize + bufferAlignment;  // be conservative for how much space buffer may take

  // error if the graph does not fit in fpga ddr
  if (currentIntermediateMaxBufferSizeAllocated_ + maxInflatedBufferSize > currentStartAddressGraphBufferSpace_) {
    std::string msg =
      "FPGA DDR allocation failed, allocating buffer of size " + std::to_string(maxInflatedBufferSize) +
      " exceeds the remaining space available of size " +
      std::to_string(currentStartAddressGraphBufferSpace_ - currentIntermediateMaxBufferSizeAllocated_) +
      ". This could be caused by the graph being too large or splitting the graph into too many subgraphs. " +
      "Memory requirements for large graphs can be reduced by selecting different folding options, " +
      "reducing batch size or selecting architectures with less padding.";
    throw std::runtime_error(msg);
  }

  currentStartAddressGraphBufferSpace_ -= bufferSize;  // allocate from highest to lowest address
  currentStartAddressGraphBufferSpace_ -=
      (currentStartAddressGraphBufferSpace_ % bufferAlignment);  // correct for alignment
  bufferAddr = currentStartAddressGraphBufferSpace_;
}

void DeviceMemoryAllocator::Clear() {
  currentIntermediateMaxBufferSizeAllocated_ = 0;
  currentStartAddressGraphBufferSpace_ = totalGlobalMemSize_;
}

DeviceMemoryAllocator::~DeviceMemoryAllocator() { Clear(); }

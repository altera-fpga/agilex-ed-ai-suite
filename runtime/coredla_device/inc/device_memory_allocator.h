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

#pragma once

#include "mmd_wrapper.h"  //MmdWrapper

#include <cstdint>  //uint64_t

/*! DeviceMemoryAllocator class allocates multiple DLA graph buffers in DDR
 * Each graph is expected to have one contigous buffer containing all data (config, filter, bias, I/O)
 * A graph buffer is allocated in DDR from right to left
 * A scratchpad space is allocated in DDR to be shared across all graphs for intermediate feature data
 * This intermediate buffer space is allocated from left to right (starting address is 0)
 * and is expanded based on graph's requirement
 */
class DeviceMemoryAllocator {
 public:
  void Initialize(uint64_t totalSize, MmdWrapper *mmdWrapper);
  ~DeviceMemoryAllocator();

  // Buffers that can be shared across multiple graphs may grow in size after they are allocated. The intermediate
  // buffer is an example of this. We have decided to allocate this at the lowest address and let it grow upwards.
  // @param bufferSize - the size of the buffer in bytes
  // @param instance - there can be multiple instances of DLA on FPGA, specify which DLA instance is this buffer for
  void AllocateSharedBuffer(uint64_t bufferSize, int instance);

  // Buffers that are private to one graph will not change in size after allocation. The config/filter buffer is
  // an example of this. We have decided to allocate this at the upper address and allocate downwards from there.
  // Hardware requires the starting address of each buffer to have some alignment, and the allocator will add
  // as much padding as needed to ensure this. Each contiguous section in device memory should have its own call
  // to the allocator.
  // @param bufferSize - the size of the buffer in bytes
  // @param bufferAlignment - specify how much address alignment is needed for this buffer, must be a power of 2
  // @param bufferAddr - the allocator indicates where it placed this buffer
  void AllocatePrivateBuffer(uint64_t bufferSize, uint64_t bufferAlignment, uint64_t &bufferAddr);

  // Clears whole DDR space including the intermediate buffer
  void Clear();

 private:
  // total DDR size (BSP parameter)
  uint64_t totalGlobalMemSize_;
  // For access to MMD
  MmdWrapper *mmdWrapper_;
  // current starting address of allocated graph buffer region
  // graph buffers are allocated right to left
  uint64_t currentStartAddressGraphBufferSpace_;
  // current maximum allocated size for intermediate data
  uint64_t currentIntermediateMaxBufferSizeAllocated_;
};

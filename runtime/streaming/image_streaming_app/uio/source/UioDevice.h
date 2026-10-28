// Copyright 2023 Altera Corporation.
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

#include <filesystem>
#include <memory>
#include <string>
#include <vector>
#include "IUioDevice.h"

namespace UIO {
class Device : public IDevice {
 public:
  Device(const DeviceItem& deviceItem);
  ~Device();

  // IDevice interface
  uint32_t Read(uint32_t registerIndex) override;
  void Write(uint32_t registerIndex, uint32_t value) override;
  void ReadBlock(void* host_addr, size_t offset, size_t size) override;
  void WriteBlock(const void* host_addr, size_t offset, size_t size) override;

  bool IsValid();
  static uint64_t ReadValueFromFile(const std::filesystem::path& path);
  static std::string ReadStringFromFile(const std::filesystem::path& path);
  static void SplitIndexedDeviceName(std::string& indexedDeviceName, std::string& deviceName, uint32_t& index);

 private:
  Device() = delete;
  Device(Device const&) = delete;
  void operator=(Device const&) = delete;

  bool MapRegion();
  void UnmapRegion();

  DeviceItem _deviceItem;
  uint32_t _maximumRegisterIndex = 0;
  int _fd = -1;  // File pointer to UIO - Used to indicate the the Device is valid
  uint64_t _physicalAddress = 0;
  uint64_t _size = 0;         // Size of the mmapped region
  uint64_t _offset = 0;       // Offset of the first register
  uint8_t* _pBase = nullptr;  // Base of the mmapped region
  uint32_t* _pPtr = nullptr;  // The first register
};
}  // namespace UIO
